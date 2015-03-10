oprofile_data: zmq-bench.pl
	operf --callgraph perl ./zmq-bench.pl

call-graph: oprofile_data
	opreport --callgraph > call-graph

nytprof.out: zmq-bench.pl
	perl -d:NYTProf ./zmq-bench.pl

opannotate.c: oprofile_data
	opannotate --source > opannotate.c

bench.txt: zmq-bench.pl
	perl ./zmq-bench.pl > bench.txt
