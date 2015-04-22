#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>
#include <vector>

using namespace std;

void getDimension(string, int[2]); // syntax is probably wrong
void calculate(string, vector<double>&);
double mean(vector<string>);
double range(vector<string>);
double meanDiff(vector<string>);
int hydroMeteorMode(vector <string>);

int main(int argc, const char * argv[]) {
	if (argc < 3) {
		cout << "Usage: ./extract <input file> <output file> <optional: nrows> <optional: ncols>" << endl;
		return(0);
	} 
	int NROWS, NCOLS;
	int dim[2]; // nrow, ncol
	string temp;
	string linetemp;
	vector<string> varsPerLineTemp;
	vector<double> statsTemp;
	ifstream datafile;
	ofstream rainSummary;
	if (argc == 3) {
		getDimension(argv[1], dim);
		NROWS = dim[0];
		NCOLS = dim[1];
	} else if (argc == 4) {
		cout << "Please either supply both nrow and ncol or neither." << endl;
		return(0);
	} else if (argc == 5) {
		NROWS = atoi(argv[3]);
		NCOLS = atoi(argv[4]);
	}
	cout << "NROWS: " << NROWS << endl;
	cout << "NCOLS: " << NCOLS << endl;
	datafile.open(argv[1]);
	rainSummary.open (argv[2]);
	if (datafile.good()) {
		getline(datafile, linetemp); // get rid of header
		for (int nrow = 1; nrow < NROWS; nrow++) {
			stringstream iss;
			getline(datafile, linetemp);
			iss << linetemp;
			for (int ncol = 0; ncol < NCOLS; ncol++) {
				getline(iss, temp, ',');
				varsPerLineTemp.push_back(temp);
			}
			/* these for loops could be combined, but i'm doing it 
			this way in case i want to only do calculations on
			certain variables */
			int colCount = 1;
			for (vector<string>::iterator it = varsPerLineTemp.begin();
				 it != varsPerLineTemp.end(); it++, colCount++) {
				if (colCount == 6) { // hydrometeor type
					calculate(*it, statsTemp);
				}
			}
			for (vector<double>::iterator it2 = statsTemp.begin();
 				 (it2+1) != statsTemp.end();
				 it2++) {
				rainSummary << *it2 << ",";	
			}
			rainSummary << statsTemp.back() << endl;
			statsTemp.clear();
			varsPerLineTemp.clear();
		}
	}
	datafile.close();
	rainSummary.close();
}

void getDimension(string fn, int dimArr[2]) {
	int nrow = 0;
	int ncol = 0;
	string linetemp;
	ifstream tempFile;
	tempFile.open(fn);
	while (tempFile.good() && !tempFile.eof()) {
		getline(tempFile, linetemp);
		nrow++;
		if (ncol == 0) {
			for (int col = 0; col < linetemp.length(); col++){
				if (linetemp[col] == ',') {
					ncol++;
				}
			}		
		}
	}
	dimArr[0] = nrow-1;
	dimArr[1] = ncol+1;
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
	//storage.push_back(meanDiff(tokens));
	storage.push_back(hydroMeteorMode(tokens));
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
	vector<int> nums; // ints??
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

int hydroMeteorMode(vector <string> numbers) {
	vector<int> nums;
	int n = 0;
	int mode;
	int hydrometeorArray[15];
	for (int i = 0; i < 15; i++) {
		hydrometeorArray[i] = 0;
	}
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
	if (nums.size() > 0) {
		for (vector<int>::iterator it = nums.begin();
			(it + 1) != nums.end();
			it++) {
			hydrometeorArray[*it]++;
		}
		mode = 0;
		for (int i = 0; i < 15; i++) {
			if (hydrometeorArray[i] > hydrometeorArray[mode]) {
				mode = i;
			}
		}
	} else {
		mode = -99999;
	}
	return(mode);
}


