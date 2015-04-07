#include <iostream>
#include <fstream>
#include <cmath>
#include <string>
#include <cstring>
#include <cstdio>
#include <sstream>

using namespace std;

	// int MROWS = 1126695;
	int NROWS = 3; // for testing purposes
	int NCOLS = 20;

int main(int argc, const char * argv[]) {
	if (argc == 1) {
		cout << "No argument given; the data file to be read needs to be given." << endl;
		return(0);
	} 

	ifstream datafile;
	stringstream iss;
	string linetemp;
	string temp;
	string colNames[NCOLS]; 

	datafile.open(argv[1]);
	if (datafile.good()) {
		for (int nrow = 1; nrow <= NROWS; nrow++) {
			getline(datafile, linetemp);
			iss << linetemp;
			for (int ncol = 1; ncol <= NCOLS; ncol++) {
				getline(iss, temp, ',');
				if (nrow == 1) colNames[ncol-1] = temp; // assign column names
				cout << colNames[ncol-1] << endl;
				cout << "nrow: " << nrow << endl;
				cout << "ncol: " << ncol << endl;
				cout << temp << endl << endl << endl;
			}
			getline(iss, temp); // extra to grab the number?
		}
	}
	datafile.close();
}

