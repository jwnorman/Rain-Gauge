#include <iostream>
#include <fstream>
#include <cmath>
#include <string>
#include <cstring>
#include <cstdio>

using namespace std;

	// int MROWS = 1126695;
	int NROWS = 100; // for testing purposes
	int NCOLS = 19;

int main(int argc, const char * argv[]) {
	if (argc == 1) {
		cout << "No argument given; the data file to be read needs to be given." << endl;
		return(0);
	} 

	// work variables
	ifstream datafile;
	int lineCounter = 1;

	// string variables
	string temp;

	char * pch; 



	// there needs to be a file given


	datafile.open(argv[1]);
	while (datafile.good() & (lineCounter <= NROWS)) {
		getline(datafile, temp, ',');
		cout << temp << endl;
		lineCounter++;
	}
	datafile.close();
}

