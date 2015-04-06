all: extract

extract: extract.o
	g++ extract.o -o extract

extract.o: extract.cpp
	g++ -c extract.cpp

clean:
	rm *o extract