#
# Directly compare FFI::Platypus vs XS xsubs
#

use strict;
use warnings;
use v5.10;

use FFI::Platypus::Declare;
use ZMQ::LibZMQ3;
use ZMQ::FFI::Constants qw(:all);
use Benchmark qw(:all :hireswallclock);
use ExtUtils::Embed qw(ccopts);
use Inline;
use FFI::TinyCC;

lib 'libzmq.so';

attach(
    ['zmq_ctx_new' => 'zmqffi_ctx_new']
        => [] => 'pointer'
);

attach(
    ['zmq_socket' => 'zmqffi_socket']
        => ['pointer', 'int'] => 'pointer'
);

attach(
    ['zmq_bind' => 'zmqffi_bind']
        => ['pointer', 'string'] => 'int'
);

package FFIsock;

use ZMQ::LibZMQ3;

sub new {
  return bless [], $_[0];
}

my $ffi = FFI::Platypus->new;

my $sockobj = FFIsock->new;
my $sockobj2 = FFIsock->new;
my $sockobj3 = FFIsock->new;

$ffi->lib('libzmq.so');

$ffi->attach_method([$ffi],
    ['zmq_send' => 'ffi']
        => ['pointer', 'string', 'size_t', 'int'] => 'int'
);

$ffi->attach_method(['FFIsock'], ['zmq_send' => 'ffi2']
		    => ['pointer', 'string', 'size_t', 'int'] => 'int');

my $ffi_ctx = main::zmqffi_ctx_new();
die 'ffi ctx error' unless $ffi_ctx;

use ZMQ::FFI::Constants qw(:all);
my $ffi_socket = main::zmqffi_socket($ffi_ctx, ZMQ_PUB);
die 'ffi socket error' unless $ffi_socket;

$ffi->attach_method([$sockobj=>$ffi_socket], ['zmq_send'=>'ffio'], ['pointer', 'string', 'size_t', 'int'] => 'int');
$ffi->attach_method([$sockobj2=>$ffi_socket], ['zmq_send'=>'ffio'], ['pointer', 'string', 'size_t', 'int'] => 'int');
$ffi->attach_method([$sockobj3=>$ffi_socket], ['zmq_send'=>'ffio'], ['pointer', 'string', 'size_t', 'int'] => 'int');
package main;

attach(
  ['zmq_send' => 'ffi2']
  => ['pointer', 'string', 'size_t', 'int'] => 'int',
    );

attach(
    ['zmq_version' => 'zmqffi_version'] 
        => ['int*', 'int*', 'int*'] => 'void'
);

$ffi->attach_method([$sockobj=>$ffi_socket], ['zmq_send'=>'ffio'], ['pointer', 'string', 'size_t', 'int'] => 'int');

$ffi->attach_method([$sockobj2=>$ffi_socket], ['zmq_send'=>'ffio'], ['pointer', 'string', 'size_t', 'int'] => 'int');

$ffi->attach_method([$sockobj3=>$ffi_socket], ['zmq_send'=>'ffio'], ['pointer', 'string', 'size_t', 'int'] => 'int');

my $ffi_hash = { socket => $ffi_socket };

my $rv;

$rv = zmqffi_bind($ffi_socket, "ipc:///tmp/zmq-ffi-bench-$$");
die 'ffi bind error' if $rv == -1;

my $xs_ctx = zmq_ctx_new();
die 'xs ctx error' unless $xs_ctx;

my $xs_socket = zmq_socket($xs_ctx, ZMQ_PUB);
die 'xs socket error' unless $xs_socket;

$rv = zmq_bind($xs_socket, "ipc:///tmp/zmq-xs-bench-$$");
die 'xs bind error' if $rv == -1;


my ($major, $minor, $patch);
zmqffi_version(\$major, \$minor, \$patch);

say "FFI ZMQ Version: " . join(".", $major, $minor, $patch);
say "XS  ZMQ Version: " . join(".", ZMQ::LibZMQ3::zmq_version());
use bytes;

use Inline C => qq{
typedef int (*send_t)(void *, const char *, long, int);

void loop_Inline(void *send, void *socket, const char *data, long size, int flags, void *die)
{
  send_t s = send;
  void (*d)(void) = die;
  int i;
  for(i=0; i<100*1000*1000; i++) {
    if(s(socket, data, size, flags) == 1)
      d();
  }
}
};

my $tcc = FFI::TinyCC->new;

$tcc->compile_string(q{
  void
  loop(int (*f)(void *, const char *, long, int), void *arg0, const char *arg1, long arg2, int arg3, void (*die)(void))
  {
    int i;
    for(i=0; i<100*1000*1000; i++)
      if(f(arg0, arg1, arg2, arg3) == -1)
        die();
  }
});

my $address = $tcc->get_symbol('loop');

lib 'libzmq.so';
my $zmqsend = sub { FFI::Platypus::Declare::_ffi_object }->()->find_symbol('zmq_send');

type('(opaque, string, long, int)->int', 'f_closure');
type('()->void', 'die_closure');
attach([$address => 'loop'] => [qw(f_closure opaque string long int die_closure)] => 'void');

my $r3;
$r3 = timethese 1, {
  TinyCC => sub {
    my $die_closure = closure  { die "zmq_send error"};

    loop($zmqsend, $ffi_socket, 'ohhai', 5, 0, $die_closure);
  },
  Inline => sub {
    my $die_closure = closure { die "zmq_send error" };

    loop_Inline($zmqsend, $ffi_socket, 'ohhai', 5, 0, $die_closure);
  },
  Python => sub {
    # this is a little unfair, since there's overhead for starting
    # python and waiting for it, but that's on the order of a tenth of
    # a second ...
    system("python ./zmq-bench.py");
  },
  'Perl exec' => sub {
    system("perl ./zmq-bench-selfcontained.pl");
  }
} if 0;

my $tcc2 = FFI::TinyCC->new;
$tcc2->detect_sysinclude_path;
$tcc2->set_options(ExtUtils::Embed::ccopts);

$tcc2->compile_string(q{
#define __builtin_expect(e,v) (e)
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

XS(xsub)
{
  dXSARGS; dVAR; dXSTARG;

  if(items != 4)
    croak("usage: blahblah");

  if(!SvOK(ST(0)) || !SvOK(ST(1)) || !SvOK(ST(2)) || !SvOK(ST(3)))
    croak("would have to fall back to fastcall.c");

  XSprePUSH;
  PUSHi(zmq_send(SvIV(ST(0)), SvPV_nolen(ST(1)), SvIV(ST(2)), SvIV(ST(3))));
  
  XSRETURN(1);
}

void body(pTHX_ void *data, int extra_arguments)
{
  dVAR; dXSARGS; dXSTARG;

  if((items != 4) || !SvOK(ST(1)) || !SvOK(ST(2)) || !SvOK(ST(3)))
    croak("would have to fall back to fastcall.c");

  XSprePUSH;
  PUSHi(zmq_send(SvIV(ST(0)), SvPV_nolen(ST(1)), SvIV(ST(2)), SvIV(ST(3))));

  XSRETURN(1);
}

void install_xsub(void)
{
  dTHX;
  newXS("main::xsub", xsub, "inline:1");
}
}) or die "couldn't compile string";

$tcc2->add_symbol('zmq_send', $ffi->find_symbol('zmq_send'));

my $tcc2_addr = $tcc2->get_symbol('install_xsub');
warn $tcc2->get_symbol('xsub');

$ffi->function($tcc2_addr, [] => 'void')->call();

use Data::Dumper;
use Scalar::Util qw(refaddr);

warn Dumper($ffi->_get_other_methods('FFIsock::ffio'));
$ffi->_get_other_methods('FFIsock::ffio')->{refaddr($sockobj2)}->{body} = $tcc2->get_symbol('body');
$ffi->_get_other_methods('FFIsock::ffio')->{refaddr($sockobj2)}->{argument} = $ffi_socket;
warn Dumper($ffi->_get_other_methods('FFIsock::ffio'));

Inline->bind(C => qq{
//#define zmq_send ((int (*)(void *, void *, unsigned long, int))${zmqsend}L)
extern int zmq_send(void *, void *, unsigned long, int);
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

XS(xsub2)
{
  dXSARGS; dVAR; dXSTARG;

  if(items != 4)
    croak("usage: blahblah");

  if(!SvOK(ST(0)) || !SvOK(ST(1)) || !SvOK(ST(2)) || !SvOK(ST(3)))
    croak("would have to fall back to fastcall.c");

  XSprePUSH;
  IV i = zmq_send(SvIV(ST(0)), SvPV_nolen(ST(1)), SvIV(ST(2)), SvIV(ST(3)));
  PUSHi(i);
  
  XSRETURN(1);
}

void body(pTHX)
{
  dVAR; dXSARGS; dXSTARG;

  if((items != 4) || !SvOK(ST(1)) || !SvOK(ST(2)) || !SvOK(ST(3)))
    croak("would have to fall back to fastcall.c");

  XSprePUSH;
  PUSHi(zmq_send(SvIV(ST(0)), SvPV_nolen(ST(1)), SvIV(ST(2)), SvIV(ST(3))));

  XSRETURN(1);
}

unsigned long get_body()
{
  return (unsigned long)body;
}

void install_xsub2() 
{
  dTHX;
  newXS("main::xsub2"  , xsub2, "inline:1");
}
}, ccflags => (ExtUtils::Embed::ccopts . " -O6 -std=c11 -march=native -mtune=native -lzmq3"), libs=>'-lzmq3 -lzmq');

install_xsub2();

warn Dumper($ffi->_get_other_methods('FFIsock::ffio'));
$ffi->_get_other_methods('FFIsock::ffio')->{refaddr($sockobj3)}->{body} = get_body();
warn Dumper($ffi->_get_other_methods('FFIsock::ffio'));

my $r = {};

sleep(1);
while(1)
{
my $new_r = timethese 10_000_000, {
    'class method' => sub {
        die 'ffi send error' if -1 == FFIsock->ffi2($ffi_socket, 'ohhai', 5, 0);
    },

    'class method(hash)' => sub {
        die 'ffi send error' if -1 == FFIsock->ffi2($ffi_hash->{socket}, 'ohhai', 5, 0);
    },

    'method' => sub {
        die 'ffi send error' if -1 == $sockobj->ffio('ohhai', 5, 0);
    },

    'TinyCC method' => sub {
        die 'ffi send error' if -1 == $sockobj2->ffio('ohhai', 5, 0);
    },

    'Inline method' => sub {
        die 'ffi send error' if -1 == $sockobj3->ffio('ohhai', 5, 0);
    },

    'Inline xsub' => sub {
        die 'ffi send error' if -1 == xsub2($ffi_socket, 'ohhai', 5, 0);
    },

    'TinyCC xsub' => sub {
        die 'ffi send error' if -1 == xsub($ffi_socket, 'ohhai', 5, 0);
    },

    'xsub' => sub {
        die 'ffi send error' if -1 == ffi2($ffi_socket, 'ohhai', 5, 0);
    },

    'xsub(hash)' => sub {
        die 'ffi send error' if -1 == ffi2($ffi_hash->{socket}, 'ohhai', 5, 0);
    },

    'XS'  => sub {
        die 'xs send error ' if -1 == zmq_send($xs_socket, 'ohhai', 5, 0);
    },
};

for my $key (keys %$new_r)
{
  if(!defined $r->{$key} or $new_r->{$key}->cpu_a < $r->{$key}->cpu_a) {
    $r->{$key} = $new_r->{$key};
  }
}

for my $key (keys %$r3)
{
  $r->{$key} = $r3->{$key};
  # HACK! we're accessing the Benchmark object's internal struct
  $r->{$key}->[5] = 100_000_000;
}

cmpthese($r);
}
