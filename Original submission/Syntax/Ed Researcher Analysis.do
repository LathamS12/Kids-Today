/***************************************************************
* Author: Scott Latham
* Purpose: This file analyzes variables from ECLS-K and
*			ECLS-K 2010 to determine whether kindergarten knowledge
*			has changed across cohorts
* 
* Creates: 
*
* Created: 8/6/2013
* Last modified: 11/19/2015
********************************************************/

	pause on
	*use "C:\Users\sal3ff\Scott\Kids Today\Generated Datasets\Cross-Cohort Demographics", clear //Only imputed using demographics
	use "C:\Users\sal3ff\Scott\Kids Today\Generated Datasets\Cross-Cohort All Controls", clear //Imputed using all control variables


	/////////////////////////////////
	//  Setting up macros
	/////////////////////////////////
		
		//Outcomes
			gl cognitive		"MATH1z MATH_LO MATH_HI READING1z READING_LO READING_HI "

			gl tch_behavior 	"T1CONTROz T1INTERPz T1EXTERNrz T1INTERNrz T1LEARNz "
			gl par_behavior 	"P1CONTROz P1SOCIALz P1IMPULSrz P1SADLONrz P1LEARNz"

			gl bounded 			"READING_b READING_LO_b READING_HI_b MATH_b MATH_LO_b MATH_HI_b "

			gl likeschool		"P1COMPL P1UPSET P1PRETEN P1GOOD P1LIKET P1LOOKFO "
			gl abilities    	"T1CMPSEN T1STORY T1LETTER T1PRDCT T1READS T1WRITE T1PRINT T1SORTS T1ORDER T1RELAT T1SOLVE T1GRAPH T1MEASU T1STRAT"
			gl bas_adv			"BAS_READ ADV_READ BAS_MATH ADV_MATH"

		//Controls
			gl age		"AGE_SEPTK SURV_DATE " 
			gl race	 	"BLACK HISP ASIAN OTHER "
			gl ses		"SESQ1 SESQ2 SESQ3 SESQ4 "
			gl lang 	"P1ANYLNG NO_ENG NOUS_BORN NONCITIZEN" 
			gl region 	"CITY RURAL MIDWEST SOUTH WEST"

			gl dems		"MALE $race $ses $lang $region PUBLIC "

			gl cent 		"FORMAL FORMHRS P1CSAMEK S2PRKNDR" 
			gl parbeliefs	"P1COUNTr P1SHAREr P1PENCILr P1STILLr P1LETTERr P1VERBALr "
			gl activities	"P1READBO P1TELLST P1SINGSO P1CHORES P1GAMES P1NATURE P1BUILD P1SPORT "
			
		#delimit ;
			gl tchars "B1TMALE B1TAGE B1HISP B1ASIAN B1BLACK B1OTHER B1TGRAD B1YRSKIN B1YRSCH 
				B1EARLY B1ELEM B1DEVLP B1MTHDRD B1MTHDMA B1MTHDSC B1ELEMCT B1ERLYCT B1SPECED B1ESL"; 
				
				
			gl no_omitted "WHITE BLACK HISP ASIAN MALE AGE_MONTHS CITY RURAL 
							P1ANYLNG NO_ENG NOUS_BORN NONCITIZEN PUBLIC
							
							FORMAL FORMHRS P1CSAMEK S2PRKNDR 
							
							HI_LETTER HI_COUNT HI_SHARE HI_PENCIL HI_STILL HI_VERBAL						
							READBO_ED TELLST_ED SINGSO_ED CHORES_ED GAMES_ED NATURE_ED BUILD_ED SPORT_ED
					
							B1TMALE B1TAGE B1WHITE B1BLACK B1HISP B1ASIAN  
							B1TBACH B1TGRAD B1YRSKIN B1YRSCH B1ELEMCT B1ERLYCT 
							B1EARLY B1ELEM B1SPECED B1ESL B1DEVLP B1MTHDRD B1MTHDMA B1MTHDSC 
							PCT_BLACK PRED_BLACK PCT_HISP PRED_HISP" ;
							
					
		#delimit cr	
	
			gl controls "$cent $parbeliefs $activities $tchars "
	
		//Interactions
			gl r_ints	"BLACKINT HISPINT ASIANINT OTHERINT "
			gl s_ints	"SESQ1INT SESQ2INT SESQ3INT SESQ4INT "	
		
			gl whiteints "WHITESES1 WHITESES2 WHITESES3 WHITESES4 WHITESES1new WHITESES2new WHITESES3new WHITESES4new" 
			gl blackints "BLACKSES1 BLACKSES2 BLACKSES3 BLACKSES4 BLACKSES1new BLACKSES2new BLACKSES3new BLACKSES4new" 
			gl hispints "HISPSES1 HISPSES2 HISPSES3 HISPSES4 HISPSES1new HISPSES2new HISPSES3new HISPSES4new" 

		//Parameters
			gl cluster "T1_ID"

		//Sample	
		
			reg $cognitive [pw=WEIGHT] 
			gen samp2 = e(sample) ==1

			reg $cognitive [pw=WEIGHT2] 
			gen samp = e(sample) ==1


	/////////////
	//	Tables
	////////////

		//Table 1 & 3/Appendix F
		*****************************
			capture program drop fullmod
			program fullmod
				args outcome filename
				estimates clear
				foreach x in `outcome' {		

					mi estimate, post: reg `x' NEW_COHORT $age [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'1a

					mi estimate, post: reg `x' NEW_COHORT $age $dems [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'2a

					mi estimate, post: reg `x' NEW_COHORT $age $dems $controls [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'6a	
				
				} //close x loop
					
				estout * using "C:\Users\sal3ff\Scott\Kids Today\Tables/`filename'", ///
							cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) replace  ///
							keep(NEW_COHORT) 
			
			end //ends "fullmod" program

			fullmod "${cognitive}"			"Table 1"
	
			fullmod "${tch_behavior}"		"Table 3a"
			fullmod "${par_behavior}"		"Table 3b"
			
			fullmod "${bounded}"			"Appendix F"
			
		//Table 2a/Appendix Ea
		****************************************
			capture program drop fullmod_r
			program fullmod_r
				args outcome filename
				estimates clear
				foreach x in `outcome' {

					mi estimate, post: reg `x' NEW_COHORT $age $race $r_ints [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'1a

					mi estimate, post: reg `x' NEW_COHORT $age $dems $r_ints [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'2a

					mi estimate, post: reg `x' NEW_COHORT $age $dems $r_ints $controls [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'6a	

				} //close x loop
					
				estout * using "C:\Users\sal3ff\Scott\Kids Today\Tables/`filename'", ///
							cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) replace  ///
							keep(NEW_COHORT $r_ints) 
			
			end //ends "fullmod_r" program

			fullmod_r "MATH1z MATH_LO MATH_HI"				"Table 2a"
			fullmod_r "READING1z READING_LO READING_HI"		"Appendix Ea"
	
	
		//Table 2b/Appendix Eb
		***************************************
			capture program drop fullmod_s
			program fullmod_s
				args outcome filename
				estimates clear
				foreach x in `outcome' {

					mi estimate, post: reg `x' NEW_COHORT $age $ses $s_ints [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'1a

					mi estimate, post: reg `x' NEW_COHORT $age $dems $s_ints [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'2a

					mi estimate, post: reg `x' NEW_COHORT $age $dems $s_ints $controls [pw = WEIGHT2] if samp ==1, cl($cluster)
					estimates store `x'6a	

				} //close x loop
					
				estout * using "C:\Users\sal3ff\Scott\Kids Today\Tables/`filename'", ///
							cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) replace  ///
							keep(NEW_COHORT $s_ints) 
			
			end //ends "fullmod_s" program

			fullmod_s "MATH1z MATH_LO MATH_HI"				"Table 2b"
			fullmod_s "READING1z READING_LO READING_HI" 	"Appendix Eb"
	
	
	//Appendix A
		
		*2010
			corr X1MSCAL MATH1 MATH_HI MATH_LO if samp ==1
			corr X1RSCAL READING1 READING_HI READING_LO  if samp ==1
			
		*1998
			corr C1MSCALE C5R4MSCL C6R4MSCL C7R4MSCL MATH1 MATH_HI MATH_LO if samp ==1 
			corr C1RSCALE C5R4RSCL C6R4RSCL C7R4RSCL READING1 READING_HI READING_LO if samp ==1

	
	
	//Appendix B - Descriptive statistics
	
		capture program drop descrip	
		program descrip	
			args vars format title
		
			tempname desc
			tempfile table
			postfile `desc' str75 (var) m1998 m2010 str4(star) using `table'	
			
			foreach x in `vars'	{
				
				sum `x' if NEW_COHORT ==0 & samp ==1 [aw=WEIGHT2]
				loc `x'1998m: di `format' r(mean)

				sum `x' if NEW_COHORT ==1 & samp ==1 [aw=WEIGHT2]
				loc `x'2010m: di `format' r(mean)

				ttest `x' if samp ==1, by(NEW_COHORT)

				loc star ""
				if `r(p)' <.05		loc star = "*"
				if `r(p)' <.01		loc star = "**"
				if `r(p)' <.001		loc star = "***"

				post `desc' ("`x'") (``x'1998m') (``x'2010m') ("`star'")
			
			} // close x loop
			
			postclose `desc'

			preserve
				use `table', clear		
				export excel using "C:\Users\sal3ff\Scott\Kids Today\Tables/`title'.xls", replace
			restore

		end //Ends program "descrip' 
		
		descrip 	"$no_omitted"		"%4.2f"		"Appendix B"
		

	********************************
	* Figures
	********************************
		
		cd "C:\Users\sal3ff\Scott\Kids Today\Figures"		

		//Figure 1/Appendix C
		*************************
			capture program drop histcomp
			program histcomp
				args var by filename 
					foreach x in `var' {

						loc title: variable label `x'

						twoway (histogram `x' if NEW_COHORT ==0, discrete color(gray) fintensity(inten50) lcolor(white))  ///
							   (histogram `x' if NEW_COHORT ==1, discrete fcolor(none) lcolor(black)), ///
								xlabel(1 "Not yet" 2 "" 3 "" 4 "" 5 "Consistently", labsize(medium)) ///
								legend(order(1 "1998" 2 "2010")) xtitle("")  `by' 						///
								title(`title') name("`x'`filename'", replace)


					} //close x loop

			end //end "histcomp" program
		
			foreach x in $abilities	{
				histcomp `x'
			}


			graph combine T1LETTER T1READS T1RELAT T1SOLVE
			graph export "Figure 1.png", replace

			graph combine T1CMPSEN T1STORY T1PRDCT T1PRINT T1WRITE, altshrink 
			graph export "Appendix Ca.png", replace

			graph combine T1SORTS T1ORDER T1GRAPH T1MEASU T1STRAT, altshrink	
			graph export "Appendix Cb.png", replace

	 
		//Figure 2/Appendix D
		***********************
			capture program drop barcomp_2
			program barcomp_2
				args var title

					preserve
						//Create 3 copies of the data
							expand 2, gen(copy)
							expand 2 if copy ==1, gen(copy2)
							replace copy = 2 if copy2 ==1

						//Create a student type variable
							gen STUDENT_TYPE 	 = 1 if copy ==0
							replace STUDENT_TYPE = 2 if copy ==1 & WHITE ==1
							replace STUDENT_TYPE = 3 if copy ==1 & BLACK ==1
							replace STUDENT_TYPE = 4 if copy ==1 & HISP ==1
							replace STUDENT_TYPE = 5 if copy ==2 & SESQ1 ==1
							replace STUDENT_TYPE = 6 if copy ==2 & SESQ5 ==1
						
							gen `var'_LO_pct = `var'_LO*100
							gen `var'_HI_pct = `var'_HI*100

							label define type 1 "All students" 2 "White" 3 "Black" 4 "Hispanic" 5 "Low income" 6 "High income"
							label values STUDENT_TYPE type
						
						//Graph separately by student type and by year
					
							capture graph drop _all

							graph bar (mean) `var'_LO_pct `var'_HI_pct, 								///
								over(NEW_COHORT, label(labsize(vsmall))) 								///
								over(STUDENT_TYPE, label(labsize(small))) 								///
								ytitle("Mean percentage") ylab(, nogrid)												///
								legend(order(1 "Not yet demonstrated" 2 "Demonstrated consistently"))  			///
								blabel(bar, size(vsmall) format(%5.0f))																														
																							
								graph export "`title'.png", replace
					
					restore

			end //end "barcomp_2" program

			barcomp_2 	MATH		"Figure 2"
			barcomp_2 	READING 	"Appendix D"

