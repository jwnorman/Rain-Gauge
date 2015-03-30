Rain Details
------------

- QPEs: 	Quantitative Precipitation Estimates

- CRPS: 	Continuous Ranked Probability Score

		- H(x):		Heaviside step function

						=0 if x < 0

						=1 if x >= 0
					It is the cumulative distribution function of a random variable which is almost surely 0.
		- z:			The actual recorded gauge value (in mm)
		- N:			Testing dataset size

- HCA:	Hydrometeor Classifaction Algorithm

			HA: hail
			HR: heavy rain, etc.

- KDP:	Specific Differential Phase

			- Good explanation at http://www.erh.noaa.gov/rah/downloads/Dual_Pol/KDP_v1.pdf
			- The dual polarity has two radar being sent from the observation place to the storm cloud. One radar is horizontal, one is vertical. When they go through a certain medium, like rain or hail, they get slow. They slow differently, though, so there is a difference in where they end up. KDP is the horizontal pulse minus the vertical pulse.
			- KDP will be positive if the medium droplets are oval elongated horizontally and negative if the medium droplets are oval elongated vertically and near 0 if perfectly round.
			- The more dense the medium (heavy rain), the more shift. In other words, as KDP increases absolutely, so should the expected rain amount.
			- ranges from -2 to 7

- dbZ:	Decibals relative to Z

			5: Hardly noticeable
			10: Light mist
			...
			35: Moderate rain
			...
			65: Extreme/large hail

- QC:		Quality-controlled (reflectivity)

- RhoHV: 	Rho (correlation coefficient), H (horizontal), V (vertical)

- ZDR:	Differential Reflectivity

			- Good explanation at http://www.erh.noaa.gov/rah/downloads/Dual_Pol/ZDR_v1.pdf
			- Measurement in decibals of the log of the ratio of horiz power to vertical power
			- Ranges -7.9 to 7.9

- NEXRAD

	- Polarimetric radar data
	- US National Weather Service's weather radar network
	- Err by biological echoes (birds, bats, etc.), and drops may evaporate or blow off by the time they reach the ground

- MADIS

	- Rain gauge data
	- Err by siting, wind, or splashing

Variable Notes
==============

- TimeToEnd
	- no missing values
	- "time to the end of the hour" is pretty much uniformly random between 0 and 60 = .012 to .016. The exceptions are 0 (.0018) and 61 (.003762)
	- as TimeToEnd goes up (approaches 60), the percentage of non-0 Expected (i.e., there is some rain) goes up.
		- 0:2mm and 61mm are the exceptions.
		- goes up from about .245 to .268 so for small but noticeable difference
		- nonlinear increase
	- near 0 correlation with all other integer/numeric explanatory variables
