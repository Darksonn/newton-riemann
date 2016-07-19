
eval: eval.o func.o
	gcc eval.o func.o -lm -O2 -o eval

eval.o: eval.c func.h
	gcc eval.c -O2 -c
func.o: func.c func.h
	gcc func.c -O2 -c

