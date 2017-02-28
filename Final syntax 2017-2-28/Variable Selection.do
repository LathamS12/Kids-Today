/***************************************************************
* Author: Scott Latham
* Purpose: This file selects variables from the ECLS-K and
*			ECLS-K 2011 for inclusion in the analysis of 
*			changes across ECLS cohorts
* 
* Creates: "F:\Scott\Change in K knowledge\Generated Datasets\Cross-Cohort Raw"
*
* Created: 8/5/2013
* Last modified: 2/5/2017
********************************************************/

clear all
set more off
set maxvar 10000
pause on
	
*******************
*  Base year 1998
*******************	
	use "$data\ECLS-K 98 BY.dta", clear
	
		keep /*

		ID variables
		*/ CHILDID PARENTID T1_ID T2_ID S1_ID S2_ID P1FIRKDG /*
	
	////////////////////////////
	// Demographic characteristics
	////////////////////////////
	
		Child characteristics - Two race variables
		*/ GENDER RACE R1_KAGE DOBMM DOBYY WKSESL WKPOVRTY P1PRIMPK P2CHPLAC P2CITIZN P1AGEENT  /*
		
		Parental reports of family characteristics
		*/ P1MOMWRK WKMOMED WKDADED P1ANYLNG P1ENGLIS CREGION KURBAN /*
		
		Parent beliefs about school readiness
		*/ P1COUNT-P1VERBAL	/*
		
		Parent activities w/child
		*/ P1READBO-P1SPORT P1CHLBOO P1CHLPIC P1CHREAD /*
		*/ P2LIBRAR-P2SPORT	P2DANCE-P2NOENGL P2HOMECM P2COMPWK P2TCHMAT P2NONEDU	/*

		Child height/weight
		*/ C1HEIGHT C1WEIGHT /*

	//////////////////////
	//	Outcome variables
	/////////////////////
		
		Behavioral outcomes
			*/ T1LEARN T1CONTRO T1INTERP T1EXTERN T1INTERN /*		
			*/ T2LEARN T2CONTRO T2INTERP T2EXTERN T2INTERN /*
			*/ P1LEARN P1CONTRO P1SOCIAL P1SADLON P1IMPULS /*

		Direct child assessments
			*/ C1RSCALE C1RTSCOR C1MSCALE C1MTSCOR /*
			*/ C2RSCALE C2RTSCOR C2MSCALE C2MTSCOR /*

		Teacher reported student abilities
			*/ T1CMPSEN-T1PRINT T1SORTS-T1STRAT T1OBSRV T1EXPLN T1CLSSFY /*
			*/ T2CMPSEN-T2PRINT T2SORTS-T2STRAT /*

		Student reports of liking/not liking school
			*/ P1COMPL P1UPSET P1PRETEN P1GOOD P1LIKET P1LOOKFO  /*

	
	////////////////////////
	// Classroom variables
	////////////////////////
		Teacher characteristics
			*/ B1TGEND-B1HGHSTD B1EARLY-B1MTHDSC B1ELEMCT B1ERLYCT  /*
	
		# of students below grade level
			*/ A2MTHBL A2RDBLO A2TARDY A2ABSEN /*		

		Preschool participation
			*/ P1CPREK P1CSAMEK S2PRKNDR S2KPUPRI P1HSPREK P1CFEEPK /*

		Classroom characteristics		
			*/ A1HRSDA A1DYSWK A1TOTAG B1FNSHT-B1COMM P1CHRSPK P1HSHRS /*
			*/ A1LETT A1WORD A1SNTNC A1BEHVR A1PBLK	A1PHIS A1PMIN A1BLACK A1HISP /*
		
		Dates of completing survey
			*/ T1RSCOMM T1RSCODD T1RSCOYY A1COMPMM A1COMPDD A1COMPYY /*
				
		Weight
			*/ C1CPTW0 C2CPTW0
			
		gen NEW_COHORT = 0
				
		save "$path\BY-1998", replace
	
	******************************
	* First grade (location data)
	******************************	
	/*	use "$data\1st Grade", clear
			
			keep CHILDID R3FIPSST R3FIPSCT R3CCDLEA R3CCDSID R4FIPSST R4FIPSCT R4CCDLEA R4CCDSID


		//Generate a district identifier
			replace R3CCDLEA = "" if R3CCDLEA =="-1" | R3CCDLEA == "-9"
			replace R4CCDLEA = "" if R4CCDLEA =="-1" | R4CCDLEA == "-9"
		
			gen leaid = R4CCDLEA
			replace leaid = R3CCDLEA if R4CCDLEA =="" & R3CCDLEA != ""
			
		save "$path\1st gr 1998", replace
	*/

	************************
	* Eighth grade outcomes
	*************************
		use "$data\ECLS-K 98 eighth", clear
		
			keep CHILDID C5R4MSCL C6R4MSCL C7R4MSCL C5R4RSCL C6R4RSCL C7R4RSCL 

		save "$path\8th gr 1998", replace
	
	
	//Merge datasets

		use "$path\BY-1998", clear

		//merge 1:1 CHILDID using "$path\1st gr 1998"
		//drop _merge
		
		merge 1:1 CHILDID using "$path\8th gr 1998"
		drop _merge

		save "$path\1998 data raw", replace
			
		
*******************
*  Base year 2010
*******************	
	use "$data\ECLS-K 10 K-1", clear
		
		clonevar A1ZBEHVR = A1ABEHVR //way around a really weird glitch I can't account for
	
		keep /*

		ID variables
		*/ CHILDID PARENTID T1_ID T2_ID S1_ID S2_ID X1FIRKDG X1REGION X1LOCALE *FIPS* /*
		*/ F1CCDLEA F1CCDSID F2CCDLEA F2CCDSID	/*
			
	///////////////////////////////
	// Demographic characteristics
	////////////////////////////////

		Child characteristics - Two race variables (Parent interview/parent and school report)
		*/ X_CHSEX X_RACETH_R X_RACETHP_R X1KAGE X1AGEENT X2KAGE X_DOBMM X_DOBYY X12SESL X2POVTY X12PRIMPK /*
		*/	P1ANYLNG P1ENGTOO P2BTHPLC P2CITIZN		/*

		Parental reports of family characteristics
		*/ X1PAR1EMP X12PAR1ED_I X12PAR2ED_I /*
				
		Parent beliefs about school readiness
		*/ P1COUNT-P1SAYND	/*

		Parent activities w/child
		*/ P1TELLST-P1SPORT P1READBK P1CHLDBK P1PICBKS P1CHREAD		/*
		*/ P2DANCLS-P2NONENG P2LIBRAR-P2SPORT P2HOMECM P2USECMP P2LRNPRG P2INTRNT	/*

		Student height/weight
		*/ C1HGT1 C1WGT1 C1HGT2 C1WGT2 /*

	//////////////////////
	//	Outcome variables
	/////////////////////	
		
		Behavioral outcomes	
			*/ X1TCHCON X1TCHPER X1TCHEXT X1TCHINT X1TCHAPP /*
			*/ X2TCHCON X2TCHPER X2TCHEXT X2TCHINT X2TCHAPP /*
			*/ X1PRNAPP X1PRNCON X1PRNSOC X1PRNSAD X1PRNIMP /*

		Direct child assessments
			*/ X1RTHET X1RSETH X1RSCAL X1MTHET X1MSETH X1MSCAL /*	
			*/ X2RTHET X2RSETH X2RSCAL X2MTHET X2MSETH X2MSCAL /*	

		Teacher reported student ability
			*/  T1CMPSEN-T1PRINT T1SORTS-T1STRAT T1OBSRV T1EXPLN T1CLSSFY /*
			*/  T2CMPSEN-T2PRINT T2SORTS-T2STRAT /*

		Reports of liking/not liking school
			*/ P1COMPLN-P1EAGER /*
	
	////////////////////////
	// Classroom variables
	////////////////////////

		Teacher characteristics 
			*/ A1TGEND-A1YRSTCH A1EARLY-A1MTHDSC A1ELEMCT A1ERLYCT /*	
		
		# of students below grade level
			*/ A2*MTHBL A2*RDBLO A2*TARDY A2*ABSEN /*

		Classroom characteristics	
			*/ A1FULDAY A1HALF* A1*HRSDA A1FNSHT-A1COMM P1HSPKCN P1CHRSPK /*
			*/ A1*TOTAG A1*LETT A1*WORD A1*SNTNC A1*BEHVR A1*BLACK A1*HISP /*

		Preschool variables
			*/ P1CSAMEK S2PRKNDR X2PUBPRI P1HSPKCN P1CPREK P1CTRST /*

		Dates of completion
			*/ T1COMPMM T1COMPDD T1COMPYY	/*
				
			Weight 
			*/ 	W1P0 W1T0 W12T0
	
		//Rename variables to align with the 1998 cohort
		*************************************************
			rename X1FIRKDG 	P1FIRKDG
			rename X_CHSEX 		GENDER
			rename X_RACETH_R	RACE
			rename X1KAGE 		R1_KAGE
			rename X2KAGE 		R2_KAGE 
			rename X_DOBMM		DOBMM 
			rename X_DOBYY 		DOBYY  
			rename X12PAR1ED_I 	WKMOMED
			rename X12PAR2ED_I 	WKDADED
			rename X1PAR1EMP 	P1MOMWRK
			rename X2POVTY 		WKPOVRTY
			rename P1SAYND		P1VERBAL
			rename P1PAYATT		P1STILL
			rename P1ENGTOO		P1ENGLIS
			rename P2BTHPLC		P2CHPLAC
			rename T1COMPMM 	T1RSCOMM
			rename T1COMPDD 	T1RSCODD
			rename T1COMPYY 	T1RSCOYY
			rename X1REGION		CREGION
			rename X1LOCALE		KURBAN
			rename P1READBK		P1READBO

			rename A1TGEND 		B1TGEND
			rename A1YRBORN 	B1YRBORN
			rename A1YRSCH		B1YRSCH
			rename A1ELEMCT		B1ELEMCT
			rename A1ERLYCT		B1ERLYCT

			rename A1HISP 		B1HISP
			rename A1AMINAN		B1RACE1
			rename A1ASIAN		B1RACE2
			rename A1BLACK		B1RACE3
			rename A1HAWPI		B1RACE4
			rename A1WHITE		B1RACE5

			rename X1TCHAPP T1LEARN
			rename X1TCHCON T1CONTRO
			rename X1TCHPER T1INTERP 
			rename X1TCHEXT T1EXTERN 
			rename X1TCHINT T1INTERN 

			rename X1PRNAPP P1LEARN
			rename X1PRNCON P1CONTRO
			rename X1PRNSOC P1SOCIAL
			rename X1PRNSAD P1SADLON
			rename X1PRNIMP P1IMPULS
    
			rename X2TCHAPP T2LEARN
			rename X2TCHCON T2CONTRO
			rename X2TCHPER T2INTERP 
			rename X2TCHEXT T2EXTERN 
			rename X2TCHINT T2INTERN

			rename P1COMPLN P1COMPL     
			rename P1UPSET	P1UPSET
			rename P1FKSICK P1PRETEN
			rename P1GOOD	P1GOOD
			rename P1LKTCHR P1LIKET
			rename P1EAGER	P1LOOKFO

			rename X2PUBPRI S2KPUPRI 

			rename P2DANCLS P2DANCE
			rename P2ARTLSN P2ARTCRF
			rename P2PERFRM P2ORGANZ
			rename P2NONENG P2NOENGL

			rename P1CHLDBK P1CHLBOO
			rename P1PICBKS P1CHLPIC
			rename P1HLPART P1HELPAR
			
			rename P2USECMP P2COMPWK  
			rename P2LRNPRG P2TCHMAT
			rename P2INTRNT P2NONEDU

			
			gen C1HEIGHT = (C1HGT1 + C1HGT2)/2
			gen C1WEIGHT = (C1WGT1 + C1WGT2)/2

			foreach x in FNSHT CNT20 SHARE PRBLMS PENCIL NOTDSR ENGLAN SENSTI SITSTI ALPHBT FOLWDR IDCOLO COMM	{

				rename A1`x' B1`x'
			}

			//Generate a district identifier
				gen leaid = F1CCDLEA
				replace leaid = F2CCDLEA if leaid == ""
				replace leaid = "" if leaid == "-1"
	
		******************************************************************		

		//Recode variables as necessary to make appending possible		
			gen NEW_COHORT = 1 

			save "$path\2010 data raw", replace
	
	
		
	//Append the datasets together	
		use "$path\1998 data raw", clear
		
		append using "$path\2010 data raw"
	
		save "$path\Cross-Cohort raw", replace
	
	//Erase extra datasets
		
		erase "$path\BY-1998.dta"
		//erase "$path\1st gr 1998.dta"
		erase "$path\8th gr 1998.dta"

		erase "$path\1998 data raw.dta"
		erase "$path\2010 data raw.dta"
   
