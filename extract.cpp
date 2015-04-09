#include <iostream>
#include <fstream>
#include <cmath>
#include <string>
#include <cstring>
#include <cstdio>
#include <sstream>
#include <iomanip>

using namespace std;

void calculate(string numbers, double (&storage)[3]); // hardcoded
void printData(string headers[], double stats[][3*20], int nr); // hardcoded

int main(int argc, const char * argv[]) {
	if (argc == 1) {
		cout << "No argument given; the data file to be read needs to be given." << endl;
		return(0);
	} 
	// int MROWS = 1126695;
	int NROWS = 3; // for testing purposes
	int NCOLS = 20;
	ifstream datafile;
	string linetemp;
	string temp;
	string *colNames = new string[NCOLS];
	string funNames[] = {"mean", "median", "range"};
	// int *dataCollector = new int[NROWS][3*20]; // 3 corresponds to number of functions; 20 corresponds to number of columns. How do do this dynamicall? Vectors I guess...
	double dataCollector[20][3*20]; // hardcoded
	double statsTemp[3]; // hardcoded

	datafile.open(argv[1]);
	if (datafile.good()) {
		for (int nrow = 0; nrow < NROWS; nrow++) {
			stringstream iss; // needed in for loop to be reset. what's the better way to reset?
			getline(datafile, linetemp);
			iss << linetemp;
			for (int ncol = 0; ncol < NCOLS; ncol++) {
				getline(iss, temp, ',');
				if (nrow == 0) { // grab header names
					colNames[ncol] = temp;
				} else {
					cout << colNames[ncol-1] << endl;
					cout << "nrow: " << nrow + 1<< endl;
					cout << "ncol: " << ncol + 1<< endl;
					cout << temp << endl << endl << endl;
					calculate(temp, statsTemp);
					dataCollector[nrow][ncol*3] = statsTemp[0];
					dataCollector[nrow][ncol*3+1] = statsTemp[1];
					dataCollector[nrow][ncol*3+2] = statsTemp[2];
				} // else
			}  // for
		} // if
	}
	datafile.close();
	printData(colNames, dataCollector, NROWS);
}

void calculate(string numbers, double (&storage)[3]) { // hardcoded
	// storage[0] = 0.0; storage[1] = 1.0; storage[2] = 2.0;
	// break string to numbers
	

	// mean
	storage[0]

	// median

	// range
}

void printData(string headers[], double stats[][3*20], int nr) {
	for (int h = 0; h < 20; h++) { // hardcoded
		cout << headers[h] << ",,,";
	}
	cout << "\n";
	for (int i = 0; i < nr; i++) {
		for (int j=0; j < 3*20-1; j++) { // hardcoded
			cout << setprecision(3) << stats[i][j] << ",";
		}
		cout << setprecision(3) << stats[i][3*20] << "\n";
	}
}
