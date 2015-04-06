#include <iostream>
#include <fstream>
#include <cmath>

using namespace std;

int main(int argc, const char * argv[]) {
	if (argc == 1) {
		cout << "No argument given; the data file to be read needs to be given." << endl;
		return(0);
	}
	ifstream datafile;
	datafile.open(argv[1]);
		if (datafile.is_open()) {
			cout << "file opened successfully" << endl;
		}
	datafile.close();
}