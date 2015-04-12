#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>
#include <vector>

using namespace std;

void calculate(string, vector<double>&);
double mean(vector<string>);
double range(vector<string>);

int main(int argc, const char * argv[]) {
	if (argc != 5) {
		cout << "Usage: ./extract <input file> <output file> <nrows> <ncols>" << endl;
		return(0);
	} 
	int NROWS = atoi(argv[3]);
	int NCOLS = atoi(argv[4]);
	int numFunctions = 2; // mean, range
	ifstream datafile;
	ofstream rainSummary;
	string linetemp;
	string temp;
	vector<double> statsTemp;

	datafile.open(argv[1]);
	rainSummary.open (argv[2]);
	if (datafile.good()) {
		for (int nrow = 0; nrow < NROWS; nrow++) {
			stringstream iss; // needed in for loop to be reset. what's the better way to reset?
			getline(datafile, linetemp);
			iss << linetemp;
			for (int ncol = 0; ncol < NCOLS; ncol++) {
				getline(iss, temp, ',');
				if (nrow == 0) {
					// do nothing
				} else {
					calculate(temp, statsTemp);
					if (ncol*numFunctions+1 != NCOLS*numFunctions-1) {
						for (vector<double>::iterator it = statsTemp.begin();
			 				 it != statsTemp.end();
							 it++) {
							rainSummary << *it << ",";
						}
					} else {
						for (vector<double>::iterator it = statsTemp.begin();
			 				 (it + 1) != statsTemp.end(); // will this work?
							 it++) {
							rainSummary << *it << ",";
						}
						rainSummary << statsTemp[statsTemp.size()-1] << endl;
					}
					statsTemp.clear();
				} // else
			}  // for
		} // if
	}
	datafile.close();
	rainSummary.close();
}

void calculate(string numbers, vector<double>& storage) {
	vector<string> tokens;
	istringstream iss(numbers);
	do {
		string temp;
		iss >> temp;
		tokens.push_back(temp);
	} while(iss);

	storage.push_back(mean(tokens));
	storage.push_back(range(tokens));
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
	mean = (n > 0) ? (sum / n) : (-99900.0);
	return(mean);
}

double range(vector<string> numbers) {
	double range = 0.0;
	double min =  99999;
	double max = -99999;
	for (vector<string>::iterator it = numbers.begin();
		 it != numbers.end();
		 it++) {
		if (!(*it == "-99900.0" || *it == "-99901.0" || 
			  *it == "-99902.0" || *it == "-99903.0" || 
			  *it == "nan" || *it == "999.0" || 
			  *it == "" || *it == " " || *it == "\n")) {
			if (min == 99999 || (stod(*it) < min)) {
				min = stod(*it);
			}
			if (max == -99999 || (stod(*it) > max)) {
				max = stod(*it);
			}
		}
	}
	range = (min != 99999) ? (max - min) : (-99900.0);
	return(range);
}