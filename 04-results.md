### Results ###

#### 2015-03-12 ####

 - lazy branch at https://github.com/pipcet/FFI-Platypus/tree/180246074f910b8fae4e6dcfd1b6191243d905ed
 - gist at TBD

```
		       Rate method xsub(hash) method (2) method (3) TinyCC method xsub TinyCC method (2) TinyCC method (3) Inline method   XS Inline method (2) Inline method (3) Inline xsub TinyCC xsub
method            1811594/s     --        -1%        -9%        -9%          -10% -15%              -18%              -18%          -22% -27%              -29%              -32%        -36%        -36%
xsub(hash)        1831502/s     1%         --        -8%        -8%           -9% -14%              -17%              -17%          -21% -27%              -28%              -31%        -35%        -36%
method (2)        1996008/s    10%         9%         --        -0%           -1%  -7%              -10%              -10%          -14% -20%              -22%              -25%        -29%        -30%
method (3)        2000000/s    10%         9%         0%         --           -1%  -6%               -9%              -10%          -14% -20%              -21%              -25%        -29%        -30%
TinyCC method     2012072/s    11%        10%         1%         1%            --  -6%               -9%               -9%          -14% -19%              -21%              -25%        -29%        -29%
xsub              2136752/s    18%        17%         7%         7%            6%   --               -3%               -4%           -8% -14%              -16%              -20%        -24%        -25%
TinyCC method (2) 2207506/s    22%        21%        11%        10%           10%   3%                --               -0%           -5% -11%              -13%              -17%        -22%        -23%
TinyCC method (3) 2217295/s    22%        21%        11%        11%           10%   4%                0%                --           -5% -11%              -13%              -17%        -21%        -22%
Inline method     2331002/s    29%        27%        17%        17%           16%   9%                6%                5%            --  -7%               -8%              -13%        -17%        -18%
XS                2493766/s    38%        36%        25%        25%           24%  17%               13%               12%            7%   --               -2%               -6%        -11%        -12%
Inline method (2) 2544529/s    40%        39%        27%        27%           26%  19%               15%               15%            9%   2%                --               -5%        -10%        -11%
Inline method (3) 2666667/s    47%        46%        34%        33%           33%  25%               21%               20%           14%   7%                5%                --         -5%         -6%
Inline xsub       2816901/s    55%        54%        41%        41%           40%  32%               28%               27%           21%  13%               11%                6%          --         -1%
TinyCC xsub       2849003/s    57%        56%        43%        42%           42%  33%               29%               28%           22%  14%               12%                7%          1%          --
```

Comments:
 - `method` is what I'd actually use today. It uses the attach_method feature to cache a raw pointer for a Perl object without going through its hash, and it's nearly as fast as using an XSUB and going through a hash lookup (`xsub(hash)`). `method (2)` and `method (3)` are variants that don't go through Perl's method resolution mechanism.
 - `TinyCC method` is what we would get if we JIT-compiled C code. It's quite a bit faster than `method`, and I believe can be said to be faster than `xsub` based on variant `(3)`.
 - `Inline method` is the same thing with Inline::C *and very aggressive optimization*. I think the gain is not worth it in this case, because Inline has a huge run-time overhead and caches results based only on the C code, not the compiler options or machine type; thus, it is very easy to end up with an _Inline directory that doesn't run on the machine it's on.
 - `XS` is the vanilla LibZMQ3 XS code. It's not been optimized further, which reflects reality.
 - `TinyCC xsub` is a JIT-generated C XSUB compiled with TinyCC. Going through Inline and enabling aggressive optimization turns out not to make a difference for this very short piece of code.