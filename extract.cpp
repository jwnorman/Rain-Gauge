#include <iostream>
#include <fstream>
#include <cmath>
#include <string>
#include <cstring>
#include <cstdio>
#include <sstream>
#include <iomanip>
#include <vector>

using namespace std;

void calculate(string numbers, double (&storage)[2]); // hardcoded
void printData(string headers[], double stats[][2*20], int nr); // hardcoded
void write2File(double stats[][2*20], int nr);
double calcMean(vector<string>);
double calcMedian(vector<string>);
double calcRange(vector<string>);

int main(int argc, const char * argv[]) {
	if (argc == 1) {
		cout << "No argument given; the data file to be read needs to be given." << endl;
		return(0);
	} 
	int NROWS = 10000;
	int NCOLS = 20;
	ifstream datafile;
	string linetemp;
	string temp;
	string *colNames = new string[NCOLS];
	string funNames[] = {"mean", "range"};
	// int *dataCollector = new int[NROWS][2*20]; // 2 corresponds to number of functions; 20 corresponds to number of columns. How do do this dynamicall? Vectors I guess...
	double dataCollector[10000][2*20]; // hardcoded
	double statsTemp[2]; // hardcoded

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
					// cout << colNames[ncol-1] << endl;
					// cout << "nrow: " << nrow + 1<< endl;
					// cout << "ncol: " << ncol + 1<< endl;
					// cout << temp << endl;
					calculate(temp, statsTemp);
					// cout << "storage mean: " << statsTemp[0] << endl;
					// cout << "storage range: " << statsTemp[1] << endl << endl;
					dataCollector[nrow][ncol*2] = statsTemp[0];
					dataCollector[nrow][ncol*2+1] = statsTemp[1];
				} // else
			}  // for
		} // if
	}
	datafile.close();
	// printData(colNames, dataCollector, NROWS);
	write2File(dataCollector, NROWS);
}

void calculate(string numbers, double (&storage)[2]) { // hardcoded
	//storage[0] = 0.0; storage[1] = 1.0; storage[2] = 2.0;
	// break string to numbers
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
	//cout << "mean: " << mean << endl;
	return(mean);
}

double calcRange(vector<string> numbers) {
	//vector<double> numsWOmissing;
	double range = 0.0;
	double min =  99999;
	double max = -99999;
	for (vector<string>::iterator it = numbers.begin();
		 it != numbers.end();
		 it++) {
		if (!(*it == "-99900.0" || *it == "-99901.0" || *it == "-99902" || *it == "nan" || *it == "999.0" || *it == "" || *it == " " || *it == "\n")) {
			//numsWOmissing.push_back(stod(*it));
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
	//cout << "range: " << range << endl;
	return(range);
}

void printData(string headers[], double stats[][2*20], int nr) {
	// for (int h = 0; h < 19; h++) { // hardcoded
	// 	cout << headers[h] << ".mean,";
	// 	cout << headers[h] << ".range,";
	// }
	// cout << headers[19] << ".mean,";
	// cout << headers[19] << ".range";
	// cout << "\n";
	for (int i = 1; i < nr; i++) {
		for (int j=0; j < 2*19-1; j++) { // hardcoded
			cout << stats[i][j] << ",";
		}
		cout << stats[i][2*19] << endl << endl;
	}
}

void write2File(double stats[][2*20], int nr) {
	ofstream datafile;
	datafile.open ("data.csv");
	for (int i = 1; i < nr; i++) {
		for (int j=0; j < 2*19-1; j++) { // hardcoded
			datafile << stats[i][j] << ",";
		}
		datafile << stats[i][2*19] << endl << endl;
	}
	datafile.close();
}
