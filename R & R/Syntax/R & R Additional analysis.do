/***************************************************************
* Author: Scott Latham
* Purpose: This file analyzes variables from ECLS-K and
*			ECLS-K 2010 to determine whether kindergarten knowledge
*			has changed across cohorts
* 
* Creates: 
*
* Created: 8/6/2013
* Last modified: 2/29/2016
********************************************************/

	pause on
	use "C:\Users\sal3ff\Scott\Kids Today\Generated Datasets\Cross-Cohort All Controls", clear //Imputed using all control variables
	
	/////////////////////////////////
	//  Setting up macros
	/////////////////////////////////
		
		//Outcomes
			gl cognitive 	"MATH1z MATH_LO2 MATH_HI2 READ1z READ_LO2 READ_HI2 "
			gl lit			"READ1z READ_LO2 READ_HI2 "
			gl math			"MATH1z MATH_LO2 MATH_HI2 "
			gl lo_hi 		"MATH_LO2 MATH_HI2 READ_LO2 READ_HI2 "
					
			gl bad_behav1 	"CONTRO_LO1 INTERP_LO1 LEARN_LO1 EXTERN_HI1 INTERN_HI1"

			gl abilities    "T1CMPSEN T1STORY T1LETTER T1PRDCT T1READS T1WRITE T1PRINT T1SORTS T1ORDER T1RELAT T1SOLVE T1GRAPH T1MEASU T1STRAT"

			gl bounded 		"MATH1_b MATH_LO2_b MATH_HI2_b READ1_b READ_LO2_b READ_HI2_b "
		
		//Controls
			gl age		"AGE_AUGK_MO MONTHS_K " 
			gl race	 	"BLACK HISP ASIAN OTHER "
			gl ses		"SESQ1 SESQ2 SESQ3 SESQ4 "
			gl lang 	"P1ANYLNG NO_ENG NOUS_BORN NONCITIZEN" 
			gl region 	"CITY RURAL MIDWEST SOUTH WEST"

			gl dems		"MALE $race $ses $lang $region PUBLIC "
			gl dem_low	"MALE $race SESQ1 $lang $region PUBLIC"
			gl dem_hi	"MALE $race SESQ3 SESQ4 $lang $region PUBLIC"
			
			gl cent 		"FORMAL FORMHRS P1CSAMEK S2PRKNDR PUBLIC_PREK" 
			
			gl parbeliefs	"HI_COUNT HI_SHARE HI_PENCIL HI_STILL HI_LETTER HI_VERBAL "
			gl activities	"READBO_ED TELLST_ED SINGSO_ED CHORES_ED GAMES_ED NATURE_ED BUILD_ED SPORT_ED "			
			gl comp			"P2HOMECM P2COMPED P2TCHMAT P2NONEDU"
			
		#delimit ;
			gl tchars "B1TMALE B1TAGE B1HISP B1ASIAN B1BLACK B1OTHER B1TGRAD B1YRSKIN B1YRSCH 
				B1EARLY B1ELEM B1DEVLP B1MTHDRD B1MTHDMA B1MTHDSC B1ELEMCT B1ERLYCT B1SPECED B1ESL"; 
		#delimit cr	
	
			gl controls "$cent $parbeliefs2 $activities $comp $tchars "
	
		//Interactions
			gl r_ints	"BLACKINT HISPINT ASIANINT OTHERINT "
			gl s_ints	"SESQ1INT SESQ2INT SESQ3INT SESQ4INT "	
		
			
		//Parameters
			gl cluster "T1_ID"

		//Sample			
			reg $cognitive [pw=WEIGHT2] 
			gen samp = e(sample) ==1

	
		//Alpha levels/factor analysis of math and literacy variables
		
			alpha T1CMPSEN T1STORY T1LETTER T1PRDCT T1READS T1WRITE T1PRINT
			alpha T1SORTS T1ORDER T1RELAT T1SOLVE T1GRAPH T1MEASU T1STRAT
			
			factor T1CMPSEN T1STORY T1LETTER T1PRDCT T1READS T1WRITE T1PRINT if samp==1
			factor T1SORTS T1ORDER T1RELAT T1SOLVE T1GRAPH T1STRAT T1MEASU if samp ==1

			factor T1CMPSEN T1STORY T1LETTER T1PRDCT T1READS T1WRITE T1PRINT ///
				T1SORTS T1ORDER T1RELAT T1SOLVE T1GRAPH T1MEASU T1STRAT if samp==1
			
			
	//Logit estimations for Table 1
		capture program drop logitmod
		program logitmod
			args outcome sample filename
			estimates clear
			foreach x in `outcome' {		

				mi estimate, post: logit `x' NEW_COHORT $age [pw = WEIGHT2] if `sample' ==1, cl($cluster) or
				estimates store `x'1a

				mi estimate, post: logit `x' NEW_COHORT $age $dems [pw = WEIGHT2] if `sample' ==1, cl($cluster) or
				estimates store `x'2a

				mi estimate, post: logit `x' NEW_COHORT $age $dems $cent [pw = WEIGHT2] if `sample' ==1, cl($cluster) or
				estimates store `x'3a
				
				mi estimate, post: logit `x' NEW_COHORT $age $dems $controls [pw = WEIGHT2] if `sample' ==1, cl($cluster) or
				estimates store `x'6a	
			
			} //close x loop
				
			estout * using "C:\Users\sal3ff\Scott\Kids Today\Tables/`filename' - Logit estimates", ///
				starlevels(+ .1 * .05 ** .01 *** .001) ///
				eform cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) replace  ///
				keep(NEW_COHORT) 
		
		end //ends "fullmod" program

		logitmod "${lo_hi}"			samp		"Table 1 Panel A"
		logitmod "${bad_behav1}"	beh_samp 	"Table 1 Panel B"
	
	
	//Looking at interaction between race and SES
		capture program drop race_ses_ints
		program race_ses_ints
			args outcome sample filename
			estimates clear
			
			preserve
			keep if SESQ1 | SESQ2
				
				foreach x in `outcome' {

					mi estimate, post: reg `x' NEW_COHORT $age $dem_low $r_ints [pw = WEIGHT2] if `sample' ==1 & SESQ<., cl($cluster)
					estimates store `x'_low	

				} //close x loop
			restore
			
			preserve
			keep if SESQ3 | SESQ4 | SESQ5
				foreach x in `outcome' {

					mi estimate, post: reg `x' NEW_COHORT $age $dem_hi $r_ints [pw = WEIGHT2] if `sample' ==1 & SESQ<., cl($cluster)
					estimates store `x'_high	

				} //close x loop
			restore 
			
			estout * using "C:\Users\sal3ff\Scott\Kids Today\Tables/`filename' - Race and SES ints", ///
				starlevels(+ .1 * .05 ** .01 *** .001) ///
				cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) replace  ///
				keep(NEW_COHORT $r_ints) 
		
		end //ends "race_ses_ints" program	
		
		race_ses_ints "$cognitive" samp "Academic"
		race_ses_ints "$bad_behav1" beh_samp "Behavior"
		

	
	//Changes in descriptives over time by SES

			# delimit ;
			gl no_omitted "WHITE BLACK HISP ASIAN MALE AGE_AUGK_MO 
				P1ANYLNG NO_ENG NOUS_BORN NONCITIZEN PUBLIC
				
				FORMAL FORMHRS PUBLIC_PREK P1CSAMEK S2PRKNDR 
				
				HI_LETTER HI_COUNT HI_SHARE HI_PENCIL HI_STILL HI_VERBAL						
				READBO_ED TELLST_ED SINGSO_ED CHORES_ED GAMES_ED NATURE_ED BUILD_ED SPORT_ED
				
				P2HOMECM P2COMPED P2TCHMAT P2NONEDU
		
				B1TMALE B1TAGE B1WHITE B1BLACK B1HISP B1ASIAN  
				B1TBACH B1TGRAD B1YRSKIN B1YRSCH B1ELEMCT B1ERLYCT 
				B1EARLY B1ELEM B1SPECED B1ESL B1DEVLP B1MTHDRD B1MTHDMA B1MTHDSC 
				MATH1 MATH_LO2 MATH_HI2 READ1 READ_LO1 READ_HI2
				CONTRO_LO1 INTERP_LO1 LEARN_LO1 EXTERN_HI1 INTERN_HI1 " ;

		# delimit cr
		
		capture program drop descrip_by_inc	
		program descrip_by_inc	
			args vars format title
		
			tempname desc
			tempfile table
			postfile `desc' str75 (var) m1998_low m2010_low str4(star1) m1998_high m2010_high str4(star0) using `table'	
			
			foreach x in `vars'	{
				
				sum `x' if NEW_COHORT ==0 & LOW_INC ==1 & samp ==1 [aw=WEIGHT2]
				loc `x'1998m_low: di `format' r(mean)

				sum `x' if NEW_COHORT ==1 & LOW_INC ==1 & samp ==1 [aw=WEIGHT2]
				loc `x'2010m_low: di `format' r(mean)
				
				sum `x' if NEW_COHORT ==0 & LOW_INC ==0 & samp ==1 [aw=WEIGHT2]
				loc `x'1998m_high: di `format' r(mean)

				sum `x' if NEW_COHORT ==1 & LOW_INC ==0 & samp ==1 [aw=WEIGHT2]
				loc `x'2010m_high: di `format' r(mean)

				foreach i in 1 0	{
					ttest `x' if samp ==1 & LOW_INC ==`i', by(NEW_COHORT)
					
					loc star`i' = ""
						if `r(p)' <.05		loc star`i' = "*"
						if `r(p)' <.01		loc star`i' = "**"
						if `r(p)' <.001		loc star`i' = "***"			
						
				} //close i loop

				post `desc' ("`x'") (``x'1998m_low') (``x'2010m_low') ("`star1'")  (``x'1998m_high') (``x'2010m_high') ("`star0'")
			
			} // close x loop
			
			postclose `desc'

			preserve
				use `table', clear		
				export excel using "C:\Users\sal3ff\Scott\Kids Today\Tables/`title'.xls", replace
			restore

		end //Ends program "descrip' 
		
		descrip_by_inc 	"$no_omitted"	"%4.2f"		"Descriptives by low SES"


	//Distribution of outcome variables
	
		capture program drop outcome_dist
		program outcome_dist
			args dv bwidth

			foreach x in `dv'	{		
				loc tit: variable label `x' //Save to use as titles
				
				histogram `x', width(`bwidth') kdensity kdenopts(width(`bwidth')) ///
					title(`tit') xtitle("")	
					
				graph export "C:\Users\sal3ff\Scott\Kids Today\Figures/`x'.pdf", replace
				
			}
		end //ends program out_dist
		
		outcome_dist "MATH1 READING1" .3
		outcome_dist "MATH_HI MATH_LO READING_HI READING_LO" .1
		outcome_dist "T1CONTRO T1EXTERN T1INTERN T1INTERP T1LEARN" .25
		outcome_dist "BAS_MATH ADV_MATH BAS_READ ADV_READ" .3
