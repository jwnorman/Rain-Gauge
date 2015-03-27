Todo
====

- ~~Make jumbo data frame (with the composite variables unlisted) for the test dataset~~
- Fix the column names of the tr.Unlisted and te.Unlisted datasets
- Calculate the true value for Kdp instead of the incorrect all-0 current Kdp
- For every variable that has missing values, create a separate column that has factors for each type of missing value incase the type of missing value is predictive. 
- Then get rid of the current codes (-99901.0, -99900.0, etc.) to be R's NA so that R doesn't treat -99901.0 as what it looks like
