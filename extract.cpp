#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>
#include <vector>

using namespace std;

void calculate(string numbers, double (&storage)[2]); // hardcoded
double calcMean(vector<string>);
double calcMedian(vector<string>);
double calcRange(vector<string>);

int main(int argc, const char * argv[]) {
	if (argc == 1 || argc == 2) {
		cout << "Missing an argument. Need a data input file and an empty output file." << endl;
		return(0);
	} 
	int NROWS = 3;
	int NCOLS = 20;
	ifstream datafile;
	ofstream rainSummary;
	string linetemp;
	string temp;
	string *colNames = new string[NCOLS];
	string funNames[] = {"mean", "range"};
	double statsTemp[2]; // hardcoded

	datafile.open(argv[1]);
	rainSummary.open (argv[2]);
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
					calculate(temp, statsTemp);
					if (ncol*2+1 != NCOLS*2-1) {
						rainSummary << statsTemp[0] << ",";
						rainSummary << statsTemp[1] << ",";
					} else {
						rainSummary << statsTemp[0] << ",";
						rainSummary << statsTemp[1] << endl;
					}
					
				} // else
			}  // for
		} // if
	}
	datafile.close();
	rainSummary.close();
}

void calculate(string numbers, double (&storage)[2]) { // hardcoded
	vector<string> tokens;
	istringstream iss(numbers);
	do {
		string temp;
		iss >> temp;
		tokens.push_back(temp);
	} while(iss);

	storage[0] = calcMean(tokens);
	storage[1] = calcRange(tokens);
}

double calcMean(vector<string> numbers) {
	int n = 0;
	double sum = 0.0;
	double mean = 0.0;
	for (vector<string>::iterator it = numbers.begin();
		 it != numbers.end();
		 it++) {
		if (!(*it == "-99900.0" || *it == "-99901.0" || *it == "-99902" || *it == "nan" || *it == "999.0" || *it == "" || *it == " " || *it == "\n")) {
			n++;
			sum += stod(*it);
		}
	}
	mean = (n > 0) ? (sum / n) : (-99900.0);
	return(mean);
}

double calcRange(vector<string> numbers) {
	double range = 0.0;
	double min =  99999;
	double max = -99999;
	for (vector<string>::iterator it = numbers.begin();
		 it != numbers.end();
		 it++) {
		if (!(*it == "-99900.0" || *it == "-99901.0" || *it == "-99902" || *it == "nan" || *it == "999.0" || *it == "" || *it == " " || *it == "\n")) {
			if ((stod(*it) < min)) {
				min = stod(*it);
			}
			if (!max || (stod(*it) > max)) {
				max = stod(*it);
			}
		}
	}
	if (!min) {
		range = max - min;
	} else {
		range = -99900.0;
	}
	return(range);
}