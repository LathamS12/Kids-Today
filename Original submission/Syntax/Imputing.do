/***********************************************************************
* Author: Scott Latham
* Purpose: This file imputes missing data for the "Kids Today" project
* 			and constructs variables that need to be constructed AFTER
*			imputation
*
* Created: 8/7/2014
* Last modified: 4/23/2015
************************************************************************/

	use "C:\Users\sal3ff\Scott\Kids Today\Generated Datasets\Cross-Cohort Clean", clear
	pause on


	capture log close
	log using "C:\Users\sal3ff\Scott\Kids Today\Logs\Imputation", replace

	//Dropping missing observations for variables that are missing <100
		* Makes the imputation model more parsimonious    

		drop if NEW_COHORT ==.
		drop if BLACK ==.
		drop if MALE ==.


	#delimit ;

		gl impute "AGE_SEPTK SURV_DATE	
				 P1ANYLNG NO_ENG NOUS_BORN NONCITIZEN CITY RURAL PUBLIC	
				
				 SESQ1 SESQ2 SESQ3 SESQ4 SESQ1INT SESQ2INT SESQ3INT SESQ4INT
				BLACKSES1* BLACKSES2* BLACKSES3* BLACKSES4*
				WHITESES1* WHITESES2* WHITESES3* WHITESES4*
				HISPSES1* HISPSES2* HISPSES3* HISPSES4*					
				FORMAL  ";
				
		//FORMINT BLACKFORM HISPFORM ASIANFORM OTHERFORM BLACKFORMINT HISPFORMINT ASIANFORMINT OTHERFORMINT
		
		gl impute2 " FORMHRS P1CSAMEK S2PRKNDR 
							
				 P1COUNTr P1SHAREr P1PENCILr P1STILLr P1LETTERr P1VERBALr
				 P1READBO P1TELLST P1SINGSO P1CHORES P1GAMES P1NATURE P1BUILD P1SPORT
								
				 B1TMALE B1TAGE B1HISP B1ASIAN B1BLACK B1OTHER B1TGRAD B1YRSKIN B1YRSCH 									 
				 B1EARLY B1ELEM B1DEVLP B1MTHDRD B1MTHDMA B1MTHDSC B1ELEMCT B1ERLYCT B1SPECED B1ESL" ;

		gl reg "MALE BLACK HISP ASIAN OTHER MIDWEST SOUTH WEST MALEINT BLACKINT HISPINT ASIANINT OTHERINT WEIGHT WEIGHT2";

	#delimit cr

	//Set and register the data
		mi set wide
		mi register imputed $impute $impute2
		mi register regular $reg

		set seed 30012

		//Including demographics only
			*mi impute chained (regress) $impute = $reg, add(5)		
			*log close

			*save "F:\Scott\Kids Today\Generated Datasets\Cross-Cohort Demographics", replace

		//Including all controls
			mi impute chained (regress) $impute $impute2 = $reg, add(5)
			log close

			save "C:\Users\sal3ff\Scott\Kids Today\Generated Datasets\Cross-Cohort All Controls", replace


