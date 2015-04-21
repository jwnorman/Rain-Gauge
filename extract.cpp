#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>
#include <vector>

using namespace std;

void getDimension(string, int[2]&); // syntax is probably wrong
void calculate(string, vector<double>&);
double mean(vector<string>);
double range(vector<string>);
double meanDiff(vector<string>);

int main(int argc, const char * argv[]) {
	if (argc != 3) {
		cout << "Usage: ./extract <input file> <output file>" << endl;
		return(0);
	} 
	int dim[2]; // nrow by ncol
	// int NROWS = atoi(argv[3]);
	// int NCOLS = atoi(argv[4]);
	int numFunctions = 3;
	vector<string> varsPerLineTemp;
	int NROWS = atoi(argv[3]);
	int NCOLS = atoi(argv[4]);
	int numFunctions = 1; // meanDiff
	ifstream datafile;
	ofstream rainSummary;
	string linetemp;
	string temp;
	vector<double> statsTemp;

	getDimension(argv[1], dim);
	int NROWS = dim[1];
	int NCOLS = dim[2];

	datafile.open(argv[1]);
	rainSummary.open (argv[2]);
	if (datafile.good()) {
		for (int nrow = 0; nrow < NROWS; nrow++) {
			stringstream iss;
			getline(datafile, linetemp);
			iss << linetemp;
			for (int ncol = 0; ncol < NCOLS; ncol++) {
				getline(iss, temp, ',');
				if (nrow != 0) {
					varsPerLineTemp.push_back(temp);
				}
			}
			for (vector<string>::iterator it = varsPerLineTemp.begin();
				 it != varsPerLineTemp.end(); it++) {
				calculate(temp, statsTemp);
				if (ncol*numFunctions+1 != NCOLS*numFunctions-1) {
					for (vector<double>::iterator it = statsTemp.begin();
		 				 it != statsTemp.end();
						 it++) {
						rainSummary << *it << ",";
					}
				} else {
					for (vector<double>::iterator it = statsTemp.begin();
		 				 (it + 1) != statsTemp.end();
						 it++) {
						rainSummary << *it << ",";
					}
					rainSummary << statsTemp[statsTemp.size()-1] << endl;
				}
				statsTemp.clear();
			}
		}
	}
	datafile.close(); // close input file
	rainSummary.close(); // close output file
}

void getDimension(string fn, int[2]& dimArr) {
	int nrow = 0;
	int ncol = 0;
	string linetemp;
	ifstream tempFile;
	tempFile.open(fn);
	while (datafile.good() && !datafile.eof()) {
		getline(datafile, linetemp);
		nrow++;
		for (int col = 0; col < linetemp.length(); col++){
			if (linetemp[col] == ',') {
				ncol++;
			}
		}
	}
	dimArr[1] = nrow;
	dimArr[2] = ncol;
}

void calculate(string numbers, vector<double>& storage) {
	vector<string> tokens;
	istringstream iss(numbers);
	do {
		string temp;
		iss >> temp;
		tokens.push_back(temp);
	} while(iss);

	// storage.push_back(mean(tokens));
	// storage.push_back(range(tokens));
	storage.push_back(meanDiff(tokens));
}

double mean(vector<string> numbers) {
	int n = 0;
	double sum = 0.0;
	double mean = 0.0;
	for (vector<string>::iterator it = numbers.begin();
		 it != numbers.end();
		 it++) {
		if (!(*it == "-99900.0" || *it == "-99901.0" || 
			  *it == "-99902.0" || *it == "-99903.0" || 
			  *it == "nan" || *it == "999.0" || 
			  *it == "" || *it == " " || *it == "\n")) {
			n++;
			sum += stod(*it);
		}
	}
	mean = (n > 0) ? (sum / n) : (-99999.0);
	return(mean);
}

double range(vector<string> numbers) {
	double range = 0.0;
	double min =  99999.0;
	double max = -99999.0;
	for (vector<string>::iterator it = numbers.begin();
		 it != numbers.end();
		 it++) {
		if (!(*it == "-99900.0" || *it == "-99901.0" || 
			  *it == "-99902.0" || *it == "-99903.0" || 
			  *it == "nan" || *it == "999.0" || 
			  *it == "" || *it == " " || *it == "\n")) {
			if (min == 99999.0 || (stod(*it) < min)) {
				min = stod(*it);
			}
			if (max == -99999.0 || (stod(*it) > max)) {
				max = stod(*it);
			}
		}
	}
	range = (min != 99999.0) ? (max - min) : (-99900.0);
	return(range);
}

double meanDiff(vector<string> numbers) {
	// eventually you should change this so
	// it calculates the slope (with the time left til hour as
	// the x value)
	vector<int> nums;
	double sum = 0.0;
	int n = 0;
	double mean;
	for (vector<string>::iterator it = numbers.begin();
		 it != numbers.end();
		 it++) {
		if (!(*it == "-99900.0" || *it == "-99901.0" || 
			  *it == "-99902.0" || *it == "-99903.0" || 
			  *it == "nan" || *it == "999.0" || 
			  *it == "" || *it == " " || *it == "\n")) {
			nums.push_back(stod(*it));
		}
	}
	if (nums.size() > 1) {
		for (vector<int>::iterator it = nums.begin();
			(it + 1) != nums.end();
			it++) {
			sum += (*(it + 1) - *it);
			n++;
		}
		mean = sum/n;
	} else {
		mean = -99999;
	}
	return(mean);
}