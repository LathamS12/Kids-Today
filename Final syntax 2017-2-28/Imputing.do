/***********************************************************************
* Author: Scott Latham
* Purpose: This file imputes missing data for the "Kids Today" project
* 			and constructs variables that need to be constructed AFTER
*			imputation
*
* Created: 8/7/2014
* Last modified: 11/9/2016
************************************************************************/

	use "${path}\Cross-Cohort Clean", clear
	pause on


	capture log close
	log using "Z:\save here\Scott Latham\Kids Today\Logs\Imputation", replace

	//Dropping missing observations for variables that are missing <100
		* Makes the imputation model more parsimonious    

		drop if NEW_COHORT ==.
		drop if BLACK ==.
		drop if MALE ==.
			

	#delimit ;

		gl impute "AGE_AUGK_MO MONTHS_K
					P1ANYLNG NO_ENG NOUS_BORN NONCITIZEN CITY RURAL PUBLIC
					SESQ1 SESQ2 SESQ3 SESQ4 SESQ1INT SESQ2INT SESQ3INT SESQ4INT ";

		gl impute2 "FORMAL FORMHRS P1CSAMEK S2PRKNDR 
						HI_COUNT HI_SHARE HI_PENCIL HI_STILL HI_LETTER HI_VERBAL
						READBO_ED TELLST_ED SINGSO_ED CHORES_ED GAMES_ED NATURE_ED BUILD_ED SPORT_ED
						P2HOMECM P2TCHMAT P2NONEDU P2COMPED
										
						B1TMALE B1TAGE B1HISP B1ASIAN B1BLACK B1OTHER B1TGRAD B1YRSKIN B1YRSCH 									 
						B1EARLY B1ELEM B1DEVLP B1MTHDRD B1MTHDMA B1MTHDSC B1ELEMCT B1ERLYCT B1SPECED B1ESL" ;

		gl reg "MALE MALEINT BLACK HISP ASIAN OTHER BLACKINT HISPINT ASIANINT OTHERINT MIDWEST SOUTH WEST PUBLIC_PREK WEIGHT WEIGHT2 SWEIGHT";

	#delimit cr

		sum $impute $impute2 $reg
		
	//Set and register the data
		mi set wide
		mi register imputed $impute $impute2
		mi register regular $reg

		set seed 30012 //Arbitrary seed value


		//Including all controls
			mi impute chained (regress) $impute $impute2 = $reg, add(20) dots
			log close

			save "${path}\Cross-Cohort All Controls", replace


