Todo
====

- ~~Make jumbo data frame (with the composite variables unlisted) for the test dataset~~
- ~~Fix the column names of the tr.Unlisted and te.Unlisted datasets~~
- ~~Accidentally omitted a column from the test dataset (MassWeightedSD); get that back!~~
- ~~When finished with NAs, make sure the classes are all correct (factor, integer, numeric, etc.)~~
- ~~Calculate the true value for Kdp instead of the incorrect all-0 current Kdp~~
- ~~For every variable that has missing values, create a separate column that has factors for each type of missing value in case the type of missing value is predictive.~~
- ~~Then get rid of the current codes (-99901.0, -99900.0, etc.) to be R's NA so that R doesn't treat -99901.0 as what it looks like~~
- Explore: each day, explore a different variable; start off with TimeToEnd, then DistanceToRadar, and so on. Keep notes and observations on Notes.md
- Create new variable noting the number of hours for each Id using TimeToEnd. If TimeToEnd for a partic Id is 59 20 58 40 30, then numHours is 2
- Create function to create pdf and or cdf from 0 to 69 mm
- Create function to "grade" a set of guesses (CRPS)
- Create the ability to condense tr.Unlisted to tr (so each Id has only one row)
