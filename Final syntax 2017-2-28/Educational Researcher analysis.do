/****************************************************************************
* Author: Scott Latham
* Purpose: This file conducts the final analysis for the manuscript
*	Kids Today: The rise in children's academic skills at kindergarten entry 
*	
*	The results created from this syntax differ very slightly in some places 
*	from those in the manuscript, but are substantively identical
* 
* Created: 8/6/2013
* Last modified: 2/28/2017
****************************************************************************/

	pause on
	use "${path}\Cross-Cohort All Controls", clear //20 imputed datasets
				

	/////////////////////////////////
	//  Setting up macros
	/////////////////////////////////
		
		//Output file path
			gl outpath "Z:\save here\Scott Latham\Kids Today"
			
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
	
			gl controls "$cent $parbeliefs $activities $comp $tchars "
	
		//Interactions
			gl r_ints	"BLACKINT HISPINT ASIANINT OTHERINT "
			gl s_ints	"SESQ1INT SESQ2INT SESQ3INT SESQ4INT "	

		//Parameters
			gl cluster "T1_ID"

		//Sample			
			reg $cognitive [pw = WEIGHT2] 
			gen samp = e(sample) ==1

			reg $bad_behav1 [pw = WEIGHT2]
			gen beh_samp = e(sample) ==1

	*************
	* Tables
	*************
	
	//	Table 1, Appendix E
	************************
		capture program drop OLSmod
		program OLSmod
			args outcome sample filename
			estimates clear
			foreach x in `outcome' {		

				mi estimate, post: reg `x' NEW_COHORT $age [pw = WEIGHT2] if `sample' ==1, cl($cluster)
				estimates store `x'1a

				mi estimate, post: reg `x' NEW_COHORT $age $dems [pw = WEIGHT2] if `sample' ==1, cl($cluster)
				estimates store `x'2a
				
				mi estimate, post: reg `x' NEW_COHORT $age $dems $cent [pw = WEIGHT2] if `sample' ==1, cl($cluster)
				estimates store `x'3a
	
				mi estimate, post: reg `x' NEW_COHORT $age $dems $controls [pw = WEIGHT2] if `sample' ==1, cl($cluster)
				estimates store `x'6a	
			
			} //close x loop
				
			estout * using "${outpath}\Tables/`filename' - OLS estimates", ///
				starlevels(+ .1 * .05 ** .01 *** .001) ///
				cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) replace
				//keep(NEW_COHORT)
		
		end //ends "OLSmod" program
		
		OLSmod "${cognitive}"	samp 		"Table 1 Panel A"		
		OLSmod "${bad_behav1}" 	beh_samp	"Table 1 Panel B"		
		OLSmod "${bounded}" 	samp		"Appendix E" 
	
	

	// Table 2 - Race/SES ints
	***************************
		capture program drop race_ints
		program race_ints
			args outcome sample filename
			estimates clear
				foreach x in `outcome' {

					mi estimate, post: reg `x' NEW_COHORT $age $race $r_ints [pw = WEIGHT2] if `sample' ==1, cl($cluster)
					estimates store `x'6a				
						
						//Testing whether overall effect for black/hisp is different from 0
							*Only relevant for behavior outcomes, where black/hisp coefficients 
							*go in opposite direction of main effects
						test (_b[BLACKINT] + _b[NEW_COHORT]) ==0 
						test (_b[HISPINT] + _b[NEW_COHORT]) ==0  
						
				} //close x loop
				
			estout * using "${outpath}\Tables/`filename' - Race ints (unadjusted)", ///
				starlevels(+ .1 * .05 ** .01 *** .001) ///
				cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) replace  ///
				keep(NEW_COHORT $r_ints) 
		
		end //ends "race_ints2" program
		
		race_ints "${cognitive}"	samp 		"Table 2 - Panel A"		
		*race_ints "${bad_behav1}"	beh_samp	"Table 3 - Panel A" //No longer included in manuscript
				
		capture program drop ses1_int
		program ses1_int
			args outcome sample filename
			estimates clear
				foreach x in `outcome' {

					mi estimate, post: reg `x' NEW_COHORT $age SESQ1 SESQ1INT [pw = WEIGHT2] if `sample' ==1, cl($cluster)
					estimates store `x'6a	

						test (_b[SESQ1INT] + _b[NEW_COHORT]) ==0 //Tests whether overall effect for SES1 differs from 0
						
				} //close x loop
					
			estout * using "${outpath}\Tables/`filename' - SES1 int (unadjusted)", ///
				starlevels(+ .1 * .05 ** .01 *** .001) ///
				cells(b(star fmt(2))  se(par(`"="("' `")""') fmt(2))) stats(r2 N) replace  ///
				keep(NEW_COHORT SESQ1INT) 
		
		end //ends "ses1_int" program	
		
		ses1_int "${cognitive}"	samp		"Table 2 - Panel B"
		*ses1_int "${behavior1}"	beh_samp	"Table 3 - Panel B" //No longer included in manuscript
		
	
	//Appendix A - Correlations between teacher-reported measures and direct assessments
	************************************************************************************	
		*2010
			corr X1MSCAL MATH1 MATH_HI2 MATH_LO2 if samp ==1
			corr X1RSCAL READ1 READ_HI2 READ_LO2  if samp ==1 //These differ slightly from those reported in paper
			
		*1998
			corr C1MSCALE C5R4MSCL C6R4MSCL C7R4MSCL MATH1 MATH_HI2 MATH_LO2 if samp ==1 
			corr C1RSCALE C5R4RSCL C6R4RSCL C7R4RSCL READ1 READ_HI2 READ_LO2 if samp ==1	
					
					
	//Appendix B - Descriptive statistics
	*************************************
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
				CONTRO_LO1 INTERP_LO1 LEARN_LO1 EXTERN_HI1 INTERN_HI1
				
				MATH2 READ2" ;

		# delimit cr
		
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
					if `r(p)' < .1		loc star = "+"
					if `r(p)' <.05		loc star = "*"
					if `r(p)' <.01		loc star = "**"
					if `r(p)' <.001		loc star = "***"

				post `desc' ("`x'") (``x'1998m') (``x'2010m') ("`star'")
			
			} // close x loop
			
			postclose `desc'

			preserve
				use `table', clear		
				export excel using "${outpath}\Tables/`title'.xls", replace
			restore

		end //Ends program "descrip' 
		
		descrip 	"$no_omitted"		"%4.2f"		"Appendix B"
		
	
	************
	* Figures
	************
		
		//Figure 1, Appendix C
		*************************
			capture program drop histcomp
			program histcomp
				args var by filename 
					foreach x in `var' {

						loc title: variable label `x'

						twoway (histogram `x' if NEW_COHORT ==0, discrete color(gray) fintensity(inten50) lcolor(white))  ///
							   (histogram `x' if NEW_COHORT ==1, discrete fcolor(none) lcolor(black)), ///
								xlabel(1 "Not yet" 2 "" 3 "" 4 "" 5 "Consistently", labsize(medium)) ///
								legend(order(1 "1998" 2 "2010")) xtitle("") ytitle("Proportion") `by' 	///
								title(`title') name("`x'`filename'", replace)


					} //close x loop

			end //end "histcomp" program

			
			foreach x in $abilities	{
				histcomp `x'
			}

			graph combine T1LETTER T1READS T1RELAT T1SOLVE
			graph export "${outpath}\Figures\Figure 1.png", replace

			graph combine T1SORTS T1ORDER T1GRAPH T1MEASU T1STRAT, altshrink	
			graph export "${outpath}\Figures\Appendix C - Panel A.png", replace
			
			graph combine T1CMPSEN T1STORY T1PRDCT T1PRINT T1WRITE, altshrink 
			graph export "${outpath}\Figures\Appendix C - Panel B.png", replace


 
		// Figure 2, Appendix D
		*************************
		
		capture program drop barcomp
		program barcomp
			args subj title
			
			tempname name
			tempfile file 
			postfile `name' str10(group) LO_0 LO_1 HI_0 HI_1 using `file'
				
				sum AGE_AUGK_MO
				loc m_age = r(mean)

				sum MONTHS_K
				loc m_month = r(mean)

				foreach x in ALL WHITE BLACK HISP 	{
				
					reg `subj'_LO2 NEW_COHORT AGE_AUGK_MO MONTHS_K [pw=WEIGHT2] if `x'
						loc lo98 = _b[_cons] + `m_age'*_b[AGE_AUGK_MO] + `m_month'*_b[MONTHS_K]
						loc lo10 = _b[_cons] + `m_age'*_b[AGE_AUGK_MO] + `m_month'*_b[MONTHS_K] + _b[NEW_COHORT]
						
					reg `subj'_HI2 NEW_COHORT AGE_AUGK_MO MONTHS_K [pw=WEIGHT2] if `x'
						loc hi98 = _b[_cons] + `m_age'*_b[AGE_AUGK_MO] + `m_month'*_b[MONTHS_K]
						loc hi10 = _b[_cons] + `m_age'*_b[AGE_AUGK_MO] + `m_month'*_b[MONTHS_K] + _b[NEW_COHORT]	
						
					post `name' ("`x'") (`lo98') (`lo10') (`hi98') (`hi10')
					
					}
					
				foreach x in LO_SES HI_SES	{
					loc coef = ""
					if "`x'" == "LO_SES"	 loc coef = "+ _b[SESQ1]"
					
					reg `subj'_LO2 NEW_COHORT AGE_AUGK_MO MONTHS_K $ses [pw=WEIGHT2]
						loc lo98 = _b[_cons] + `m_age'*_b[AGE_AUGK_MO] + `m_month'*_b[MONTHS_K] `coef'
						loc lo10 = _b[_cons] + `m_age'*_b[AGE_AUGK_MO] + `m_month'*_b[MONTHS_K] + _b[NEW_COHORT] `coef'
								
					reg `subj'_HI2 NEW_COHORT AGE_AUGK_MO MONTHS_K $ses [pw=WEIGHT2]
						loc hi98 = _b[_cons] + `m_age'*_b[AGE_AUGK_MO] + `m_month'*_b[MONTHS_K] `coef'
						loc hi10 = _b[_cons] + `m_age'*_b[AGE_AUGK_MO] + `m_month'*_b[MONTHS_K] + _b[NEW_COHORT] `coef'
						
					post `name' ("`x'") (`lo98') (`lo10') (`hi98') (`hi10')
				}	
				postclose `name'
				
				//Create a figure from the new dataset
					preserve
						use `file', clear
						
						gen STUDENT_TYPE = _n
						label define type 1 "All students" 2 "White" 3 "Black" 4 "Hispanic" 5 "Lowest SES quintile" 6 "Top 4 SES quintiles"
						label values STUDENT_TYPE type
					
						reshape long LO_ HI_, i(group) j(NEW_COHORT)
							label define cohort 0 "98" 1 "10"
							label values NEW_COHORT cohort
							
						gen LO_pct = LO_*100
						gen HI_pct = HI_*100
						
						graph bar (mean) LO_pct HI_pct, 								///
							over(NEW_COHORT, label(labsize(vsmall))) 								///
							over(STUDENT_TYPE, label(labsize(vsmall))) 								///
							ytitle("Percent of students") ylab(, nogrid)								///
							legend(order(1 "Low proficiency" 2 "High proficiency"))  	///
							blabel(bar, size(vsmall) format(%5.0f))	bar(1, color(gs2)) bar(2, color(gs10))
							
						graph export "${outpath}\Figures/`title'.png", replace

					restore
					
		end //ends program "barcomp"
	
	barcomp MATH "Figure 2"
	barcomp READ "Appendix D"
	