/***************************************************************
* Author: Scott Latham
* Purpose: This file cleans variables from ECLS-K and
*			ECLS-K 2010 for inclusion in the analysis of 
*			changes across ECLS cohorts
* 
* Creates: "C:\Users\sal3ff\Scott\Change in K knowledge\Generated Datasets\Cross-Cohort Clean"
*
* Created: 8/5/2013
* Last modified: 1/12/2016
*****************************************************************/

pause on
use "C:\Users\sal3ff\Scott\Kids Today\Generated Datasets\Cross-Cohort raw", clear

	//Sample selection 
		keep if P1FIRKDG == 1
	
	//Recode missing values
		order *ID *FIPS* *CCD* leaid
		replace R3FIPSST = "" if R3FIPSST =="-9" | R3FIPSST == "-1"
		replace R4FIPSST = "" if R4FIPSST =="-9" | R4FIPSST == "-1"
		recode CREGION-A1ZBEHVR (-1=.a) (-7=.) (-8=.) (-9=.)

		label define year 0 "1998" 1 "2010"
		label values NEW_COHORT year

	////////////////
	// Demographics
	////////////////
		//Gender
			recode GENDER (2=0)
			rename GENDER MALE
			label variable MALE "Child is male"
				
			label define male 0 "Female" 1 "Male"
			label values MALE male

		//Age	
		
			//Date that teacher answered questionnaire
				gen SURV_MM = T1RSCOMM
				recode SURV_MM (8=0) (9=1) (10=2) (11=3) (12=4) ///
					(1=5) (2=6) (3=7) (4=8) (5=9) (6=10) (7=11)
				
				gen SURV_DD = (T1RSCODD-1)/30

				gen MONTHS_K =  SURV_MM+SURV_DD //Based on teacher report
				replace MONTHS_K =. if T1RSCOMM <8 & (T1RSCOYY == 1998 | T1RSCOYY==2010)
				label var MONTHS_K "Months in kindergarten at assessment"
			
			//Composite age (based on teacher survey dates and birthdate)
				gen MONTH = (DOBMM-1)/12
				gen AGE_AUGK = .
			
				replace AGE_AUGK = 1998.666-(DOBYY+MONTH) if NEW_COHORT==0
				replace AGE_AUGK = 2010.666-(DOBYY+MONTH) if NEW_COHORT==1

				gen AGE_AUGK_MO = AGE_AUGK*12	
				label variable AGE_AUGK_MO "Age on August 1st of kindergarten year (Months)"
					
		//Race 				
			gen ALL = 1
			label variable ALL "All students"

			gen WHITE = RACE==1
			replace WHITE =. if RACE >=.
			label variable WHITE "Child is white"
			
			gen BLACK = RACE == 2
			replace BLACK = . if RACE >=.
			label variable BLACK "Child is black"
			
			gen HISP = RACE == 3 | RACE ==4
			replace HISP = . if RACE >=.
			label variable HISP "Child is Hispanic"	
			
			gen ASIAN = RACE ==5
			replace ASIAN = . if RACE>=.
			label variable ASIAN "Child is Asian"
			
			gen OTHER = RACE >5
			replace OTHER = . if RACE >=.
			label variable OTHER "Child is not white/black/Hispanic"
			
			recode RACE (4=3) (5=4) (6/8 =5)
			label define race 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Other"
			label values RACE race
		
		//SES
			egen SESQ98 = cut(WKSESL), group(5)
			egen SESQ10 = cut(X12SESL), group(5)

			replace SESQ98 = SESQ10 if SESQ98 >=.
			rename SESQ98 SESQ
			recode SESQ (0=1) (1=2) (2=3) (3=4) (4=5)
			
			label define quints 1 "Lowest quintile" 2 "2" 3 "3" 4 "4" 5 "Highest quintile"
			label values SESQ quints
			label variable SESQ "Income quintiles"
			
			tab SESQ, gen(SESQ)

			rename WKPOVRTY POVERTY
			recode POVERTY (2=0) (3=0)
			label var POVERTY "Student was below the poverty line"

			gen LOW_INC = SESQ1 ==1 | SESQ2 ==1
			replace LOW_INC = . if SESQ1 ==.
			
		//Citizenship
			gen NOUS_BORN = P2CHPLAC ==2
			replace NOUS_BORN = . if P2CHPLAC ==.
			label var NOUS_BORN "Student was not born in U.S."

			gen NONCITIZEN = P2CITIZN ==2
			replace NONCITIZEN = . if P2CITIZN ==.
			label var NONCITIZEN "Child is not a U.S. citizen"		


		//Language spoken at home
			recode P1ANYLNG (2=0)
			
			gen NO_ENG = P1ENGLIS ==2
			replace NO_ENG =. if P1ENGLIS ==.
			label var NO_ENG "English not spoken in child's home"

		//Location
			
			//State FIPS code is necessary to merge w/preschool expenditures
				gen FIPS_ST = R3FIPSST //1999 fall (Had to use 1st grade data)
				replace FIPS_ST = R4FIPSST if FIPS_ST == "" //1999 spring
				replace FIPS_ST = F1FIPSST if NEW_COHORT ==1 //2010 fall
				replace FIPS_ST = F2FIPSST if NEW_COHORT == 1 & FIPS_ST == "" //2010 spring 
				label var FIPS_ST "State FIPS code"

			recode KURBAN (2 11 12 13 =1) (3 4 21 22 23 =2) (5 6 31 32 33 =3) (7 41 42 43 = 4)
			label define kurb 1 "City" 2 "Suburb" 3 "Town" 4 "Rural"
			label values KURBAN kurb

			gen CITY = KURBAN ==1
			replace CITY = . if KURBAN ==.
			label var CITY "Child lives in a city"

			gen RURAL = KURBAN ==4
			replace RURAL =. if KURBAN ==.
			label var RURAL "Child lives in a rural area"
			
			tab CREGION, gen(r)
			replace r1 = . if CREGION ==.
			rename r1 NORTHEAST

			replace r2 = . if CREGION ==.
			rename r2 MIDWEST

			replace r3 = . if CREGION ==.
			rename r3 SOUTH

			replace r4 = . if CREGION ==.
			rename r4 WEST


		//Public or private school
			gen PUBLIC = S2KPUPRI ==1
			replace PUBLIC =. if S2KPUPRI ==.
			label var PUBLIC "Student attended a public school"
	

	//////////////////
	//	Outcomes
	////////////////////
		
		* Cognitive outcomes
		*********************
			loc abilities = "CMPSEN STORY LETTER PRDCT READS WRITE PRINT SORTS ORDER RELAT SOLVE GRAPH MEASU STRAT"
			
			//Label and standardize proficiency variables
				foreach x in 1 2	{
					label var T`x'CMPSEN	"Uses complex sentence structures"
					label var T`x'STORY 	"Understands and interprets stories"
					label var T`x'LETTER	"Easily names upper/lowercase letters"
					label var T`x'PRDCT		"Predicts what will happen next in stories"
					label var T`x'READS		"Reads simple books independently"
					label var T`x'WRITE		"Demonstrates early writing behaviors"
					label var T`x'PRINT		"Understands conventions of print"
					label var T`x'SORTS		"Sorts/classifies items by different rules"
					label var T`x'ORDER		"Orders groups of objects"
					label var T`x'RELAT		"Understands relative quantities"
					label var T`x'SOLVE		"Solves problems involving numbers"
					label var T`x'GRAPH		"Demonstrates understanding of graphs"
					label var T`x'MEASU		"Uses measuring instruments accurately"
					label var T`x'STRAT		"Uses multiple strategies to solve math problems"
					
					foreach i in `abilities'	{
						
						//Standardize outcomes
							loc lab: variable label T`x'`i' 
							egen T`x'`i'z = std(T`x'`i')
							label var T`x'`i'z "`lab'"
						
						//Generate bounded variables
							gen T`x'`i'_b = T1`i' 
							recode T`x'`i'_b (6 7 = 1)
							label var T`x'`i'_b "T`x'`i' bounded"

							recode T`x'`i'(6 7 =.) // NA was coded differently across waves	
						
						} //close i loop
				} //close x loop

			//Overall proficiency (reading, math)
			
				//Fall K
					egen READ1 = rowmean(T1CMPSEN T1STORY T1LETTER T1PRDCT T1READS T1WRITE T1PRINT)
					label var READ1 "Average literacy proficiency"
					
					egen READ1_b = rowmean(T1CMPSEN_b T1STORY_b T1LETTER_b T1PRDCT_b T1READS_b T1WRITE_b T1PRINT_b)
					label var READ1_b "Average literacy proficiency (bounded)"

					egen MATH1 = rowmean(T1SORTS T1ORDER T1RELAT T1SOLVE T1GRAPH T1MEASU T1STRAT)
					label var MATH1 "Average math proficiency"
									
					egen MATH1_b = rowmean(T1SORTS_b T1ORDER_b T1RELAT_b T1SOLVE_b T1GRAPH_b T1MEASU_b T1STRAT_b)
					label var MATH1_b "Average math proficiency (bounded)"	

				//Spring K
					egen READ2 = rowmean(T2CMPSEN T2STORY T2LETTER T2PRDCT T2READS T2WRITE T2PRINT)
					label var READ2 "Average literacy proficiency (spring)"

					egen MATH2 = rowmean(T2SORTS T2ORDER T2RELAT T2SOLVE T2GRAPH T2MEASU T2STRAT)
					label var MATH2 "Average math proficiency (spring)"
				
			//Construct individual high and low proficiency indicators (bounded and unbounded)
				foreach x in `abilities'	{
				
					forvalues i = 1/3	{
						//Main results
							gen 	`x'_LO`i' = T1`x' <=`i'
							replace `x'_LO`i' = . if T1`x' >=.
							label variable `x'_LO`i' "Child has low proficiency in  `x'"

							gen 	`x'_HI`i' = T1`x' >=6-`i'
							replace `x'_HI`i' = . if T1`x' >=.
							label variable `x'_HI`i' "Child has high proficiency in `x'"

						//Bounded
							gen 	`x'_LO`i'_b = T1`x'_b  <=`i'
							replace `x'_LO`i'_b = . if T1`x'_b >=.
							label variable `x'_LO`i'_b "Child has low proficiency in  `x' (bounded)"
						
							gen 	`x'_HI`i'_b = T1`x'_b  >=6-`i'
							replace `x'_HI`i'_b = . if T1`x'_b >=.
							label variable `x'_HI`i'_b "Child has high proficiency in `x' (bounded)"
							
					} //closes i loop
				} // closes x loop

				drop T1OBSRV T1EXPLN T1CLSSFY  // These weren't collected in the spring
		

			//Aggregated high/low proficiency variables (bounded and unbounded)

				egen read_num = rownonmiss(CMPSEN_HI2 STORY_HI2 LETTER_HI2 PRDCT_HI2 READS_HI2 WRITE_HI2 PRINT_HI2)
				egen read_num_b = rownonmiss(CMPSEN_HI2_b STORY_HI2_b LETTER_HI2_b PRDCT_HI2_b READS_HI2_b WRITE_HI2_b PRINT_HI2_b)
				
				forvalues i = 1/3	{
				
					egen r_hi`i' = rowtotal(CMPSEN_HI`i' STORY_HI`i' LETTER_HI`i' PRDCT_HI`i' READS_HI`i' WRITE_HI`i' PRINT_HI`i')
						gen READ_HI`i' = r_hi`i'/read_num >= .5 & read_num != 0
						replace READ_HI`i' = . if read_num ==0
						label var READ_HI`i' "Proficient in at least half literacy skills" 
					
					egen r_lo`i' = rowtotal(CMPSEN_LO`i' STORY_LO`i' LETTER_LO`i' PRDCT_LO`i' READS_LO`i' WRITE_LO`i' PRINT_LO`i')
						gen READ_LO`i' = r_lo`i'/read_num >= .5 & read_num != 0
						replace READ_LO`i' = . if read_num ==0
						label var READ_LO`i' "Not proficient in at least half literacy skills" 
						
					egen r_hi`i'_b = rowtotal(CMPSEN_HI`i'_b STORY_HI`i'_b LETTER_HI`i'_b PRDCT_HI`i'_b READS_HI`i'_b WRITE_HI`i'_b PRINT_HI`i'_b)
						gen READ_HI`i'_b = r_hi`i'_b/read_num_b > .5 & read_num_b !=0
						replace READ_HI`i'_b = . if read_num_b ==0
						label var READ_HI`i'_b "Proficient in at least half literacy skills (bounded)" 	
						
					egen r_lo`i'_b = rowtotal(CMPSEN_LO`i'_b STORY_LO`i'_b LETTER_LO`i'_b PRDCT_LO`i'_b READS_LO`i'_b WRITE_LO`i'_b PRINT_LO`i'_b)
						gen READ_LO`i'_b = r_lo`i'_b/read_num_b >= .5 & read_num_b != 0
						replace READ_LO`i'_b = . if read_num_b ==0
						label var READ_LO`i'_b "Not proficient in at least half literacy skills (bounded)" 			
				}
					
				egen math_num = rownonmiss(SORTS_HI2 ORDER_HI2 RELAT_HI2 SOLVE_HI2 GRAPH_HI2 MEASU_HI2 STRAT_HI2)
				egen math_num_b = rownonmiss(SORTS_HI2_b ORDER_HI2_b RELAT_HI2_b SOLVE_HI2_b GRAPH_HI2_b MEASU_HI2_b STRAT_HI2_b)
				
				forvalues i = 1/3	{
			
					egen m_hi`i'= rowtotal(SORTS_HI`i' ORDER_HI`i' RELAT_HI`i' SOLVE_HI`i' GRAPH_HI`i' MEASU_HI`i' STRAT_HI`i')	
						gen MATH_HI`i' = m_hi`i'/math_num >= .5 & math_num != 0
						replace MATH_HI`i' = . if math_num ==0
						label var MATH_HI`i' "Proficient in at least half math skills" 

					egen m_lo`i'= rowtotal(SORTS_LO`i' ORDER_LO`i' RELAT_LO`i' SOLVE_LO`i' GRAPH_LO`i' MEASU_LO`i' STRAT_LO`i')
						gen MATH_LO`i' = m_lo`i'/math_num >= .5 & math_num != 0
						replace MATH_LO`i' = . if math_num ==0
						label var MATH_LO`i' "Not proficient in at least half math skills" 
	
					egen m_hi`i'_b = rowtotal(SORTS_HI`i'_b ORDER_HI`i'_b RELAT_HI`i'_b SOLVE_HI`i'_b GRAPH_HI`i'_b MEASU_HI`i'_b STRAT_HI`i'_b)	
						gen MATH_HI`i'_b = m_hi`i'_b/math_num_b >= .5 & math_num_b != 0
						replace MATH_HI`i'_b = . if math_num_b ==0
						label var MATH_HI`i'_b "Proficient in at least half math skills (bounded)" 

					egen m_lo`i'_b= rowtotal(SORTS_LO`i'_b ORDER_LO`i'_b RELAT_LO`i'_b SOLVE_LO`i'_b GRAPH_LO`i'_b MEASU_LO`i'_b STRAT_LO`i'_b)
						gen MATH_LO`i'_b = m_lo`i'_b/math_num_b >= .5 & math_num_b != 0
						replace MATH_LO`i'_b = . if math_num_b ==0
						label var MATH_LO`i'_b "Not proficient in at least half math skills (bounded)" 

				}
				
			//Basic and advanced skills (Rule was >50% students were rated a 1 or 2 in fall of 1998)

				*Using rule that >50% students were rated a 1 or 2 in fall of 1998)
					egen READ_BAS1 = rowmean(T1CMPSEN T1STORY T1LETTER T1PRDCT) //Unbounded
					label var READ_BAS1 "Easy reading skills (rule based)"

					egen READ_ADV1 = rowmean(T1READS T1WRITE T1PRINT) 
					label var READ_ADV1 "Hard reading skills (rule based)"				
					
					egen READ_BAS1_b = rowmean(T1CMPSEN_b T1STORY_b T1LETTER_b T1PRDCT_b) //Bounded
					label var READ_BAS1_b "Easy reading skills (bounded)"

					egen READ_ADV1_b = rowmean(T1READS_b T1WRITE_b T1PRINT_b)  
					label var READ_ADV1_b "Hard reading skills (bounded)"	
					
					
					egen MATH_BAS1 = rowmean(T1SORTS T1ORDER T1GRAPH) //Unbounded
					label var MATH_BAS1 "Easy math skills (rule based)"
				
					egen MATH_ADV1= rowmean(T1SOLVE T1MEASU T1RELAT T1STRAT)
					label var MATH_ADV1 "Hard math skills (rule based)"	
					
					egen MATH_BAS1_b = rowmean(T1SORTS_b T1ORDER_b T1GRAPH_b)  //Bounded
					label var MATH_BAS1_b "Easy math skills (bounded)"
				
					egen MATH_ADV1_b = rowmean(T1SOLVE_b T1MEASU_b T1RELAT_b T1STRAT_b)
					label var MATH_ADV1_b "Hard math skills (bounded)"

				*As defined by factor analysis	
					egen READ_BAS2 = rowmean(T1CMPSEN T1STORY T1PRDCT) //Unbounded
					label var READ_BAS2 "Easy reading skills (factor analysis)"

					egen READ_ADV2 = rowmean(T1READS T1WRITE T1PRINT) 
					label var READ_ADV2 "Hard reading skills (factor analysis)"		
					
					egen READ_BAS2_b = rowmean(T1CMPSEN_b T1STORY_b T1PRDCT_b) //Bounded
					label var READ_BAS2_b "Easy reading skills (bounded)"

					egen READ_ADV2_b = rowmean(T1READS_b T1WRITE_b T1PRINT_b) 
					label var READ_ADV2_b "Hard reading skills (bounded)"	
										

					egen MATH_BAS2 = rowmean(T1SORTS T1ORDER T1RELAT) //Unbounded
					label var MATH_BAS2 "Easy math skills (factor analysis)"
				
					egen MATH_ADV2 = rowmean(T1SOLVE T1GRAPH T1MEASU T1STRAT)
					label var MATH_ADV2 "Hard math skills (factor analysis)"
					
					egen MATH_BAS2_b = rowmean(T1SORTS_b T1ORDER_b T1RELAT_b)  //Bounded
					label var MATH_BAS2_b "Easy math skills (bounded)"
				
					egen MATH_ADV2_b = rowmean(T1SOLVE_b T1GRAPH_b T1MEASU_b T1STRAT_b)
					label var MATH_ADV2_b "Hard math skills (bounded)"
					

			//Standardize outcomes

				foreach x in READ1 MATH1 READ2 MATH2 READ1_b MATH1_b   {
					loc lab: variable label `x'
					egen `x'z = std(`x')
					label var `x'z "lab"
				}

				foreach x in READ_BAS1 READ_BAS2 READ_ADV1 READ_ADV2 MATH_BAS1 MATH_BAS2 MATH_ADV1 MATH_ADV2 {
					loc lab: variable label `x'
					egen `x'z = std(`x')
					label var `x'z "lab"
				}
				
		* Behavioral outcomes
		***********************
			
			label var T1LEARN  "Approaches to learning"
			label var T1EXTERN "Externalizing behavior"
			label var T1INTERN "Internalizing behavior"
			label var T1INTERP "Interpersonal behavior"
			label var T1CONTRO "Self-control"
				
			//Dichotomize behavioral outcomes
				foreach x in INTERN EXTERN LEARN INTERP CONTRO	{
					
					sum T1`x' if NEW_COHORT ==0 //Get values in 1998
						loc plus1 = r(mean) + r(sd) 
						loc plus1_5 = r(mean) + (1.5 * r(sd))
						loc minus1 = r(mean) - r(sd)
					
					gen `x'_HI1 = T1`x' >= `plus1'
					replace `x'_HI1 = . if T1`x' ==.
					label var `x'_HI1 "1 SD above 1998 mean"
				
					gen `x'_HI2 = T1`x' >= `plus1_5'
					replace `x'_HI2 = . if T1`x' ==.
					label var `x'_HI2 "1.5 SD above 1998 mean"
					
					gen `x'_LO1 = T1`x' <= `minus1'
					replace `x'_LO1 = . if T1`x' ==.
					label var `x'_LO1 "1 SD below 1998 mean" 
					
				}
				
			
	////////////////////////
	// Preschool variables
	/////////////////////////

		recode S2PRKNDR  (2=0)
		recode P1CSAMEK P1CPREK P1CFEEPK P1CTRST P1HSPREK P1HSPKCN (.a = 0) (2=0)
			
		label variable P1CHRSPK "Hours/wk spent in center care in the year before kindergarten"
		
		gen FORMAL = P1CHRSPK <.
		replace FORMAL = 1 if P1HSHRS<.
		replace FORMAL = . if P1CHRSPK ==. & P1HSHRS ==.
		label var FORMAL "Child was in center/HS year before K"
		
		gen FORMHRS = P1CHRSPK if P1CHRSPK <.
		replace FORMHRS = P1HSHRS if FORMHRS ==. & P1HSHRS<.
		replace FORMHRS = 0 if FORMHRS ==. & (P1CHRSPK ==.a | P1HSHRS ==.a)
		label var FORMHRS "Hrs/wk student spent in formal care"
			
		gen PUBLIC_PREK = 0  //Defined slightly differently across cohorts
		replace PUBLIC_PREK = 1 if PUBLIC & P1CSAMEK
		replace PUBLIC_PREK = 1 if NEW_COHORT ==0 & P1HSPREK 
		replace PUBLIC_PREK = 1 if NEW_COHORT ==0 & P1CPREK & P1CFEEPK ==0
		replace PUBLIC_PREK = 1 if NEW_COHORT ==1 & P1CTRST
		replace PUBLIC_PREK = 1 if NEW_COHORT ==1 & P1HSPKCN
		label var PUBLIC_PREK "Publicly funded preschool"

	/////////////////////////
	// Parent variables
	////////////////////////
	
	//Reverse code parent beliefs
		foreach x in COUNT SHARE PENCIL STILL LETTER VERBAL	{
			gen P1`x'r = 6-P1`x'

			gen HI_`x' = P1`x' == 1 | P1`x' ==2
			replace HI_`x' = . if P1`x' ==.
			label var HI_`x' "Parent rated the importance of `x' as very important/essential"
		}
		label var P1COUNTr  "Counting to 20"
		label var P1SHAREr  "Taking turns/sharing"
		label var P1PENCILr "Using a pencil/paintbrush"
		label var P1STILLr  "Sitting still/paying attention"
		label var P1LETTERr "Knowing letters of the alphabet"
		label var P1VERBALr "Communicating needs/wants verbally"

		label define beliefs 1 "Not important" 2 "2" 3 "3" 4 "4" 5 "Essential"
		label values P1COUNTr P1SHAREr P1PENCILr P1STILLr P1LETTERr P1VERBALr beliefs

		
		egen PARBELS = rowmean(P1COUNTr P1SHAREr P1PENCILr P1STILLr P1LETTERr P1VERBALr)
		label var PARBELS "Index of parent beliefs"
		
		foreach x in P1COUNTr P1SHAREr P1PENCILr P1STILLr P1LETTERr P1VERBALr	{
			replace PARBELS =. if `x' ==.
		}
		
			

	//Parental Education
		gen M_NOHS = 1 if WKMOMED < 3
		replace M_NOHS = 0 if WKMOMED > 3 & WKMOMED <.
		label variable M_NOHS "Mother did not complete high school"
		
		gen M_HS = WKMOMED >= 3 & WKMOMED < 6
		replace M_HS = . if WKMOMED>=.
		label variable M_HS "Mother completed high school, no bachelors"
		
		gen M_GRAD = WKMOMED >= 8
		replace M_GRAD = . if WKMOMED >=.
		label variable M_GRAD "Mother received a graduate degree"
		
		gen D_NOHS = 1 if WKDADED < 3
		replace D_NOHS = 0 if WKDADED >3 & WKDADED <.
		label variable D_NOHS "Father did not complete high school"
		
		gen D_HS = WKDADED >= 3 & WKDADED < 6
		replace D_HS = . if WKDADED>=.
		label variable D_HS "Father completed high school, no bachelors"
		
		gen D_GRAD = WKDADED >= 8
		replace D_GRAD = . if WKDADED >=.
		label variable D_GRAD "Father received a graduate degree"	


	//Parent activities

		foreach x in READBO TELLST SINGSO HELPAR CHORES GAMES NATURE BUILD SPORT	{			
			gen `x'_ED = P1`x' ==4
			replace `x'_ED = . if P1`x' ==.
			label var `x'_ED "Child participates in `x' every day"
		}

		label var P1READBO "Read books with child"
		label var P1TELLST "Tell stories to child"
		label var P1SINGSO "Sing songs with child"
		label var P1HELPAR "Help child with art projects"
		label var P1CHORES "Child helps with chores"
		label var P1GAMES  "Play games with child"
		label var P1NATURE "Teach child about nature"
		label var P1BUILD  "Build things with child"
		label var P1SPORT  "Play sports with child"

		label define act 1 "Not at all" 2 "Once or twice/wk" 3 "3-6 times/wk" 4 "Every day"
		label values P1READBO-P1SPORT act


		replace P1CHLBOO = 200 if P1CHLBOO >200 & P1CHLBOO <. //Top code number of books at 200
		label var P1CHLBOO "Number of children's books in home"
		
		label var P1CHLPIC "How often does child look at picture books?"
		gen P1CHLPIC_ED = P1CHLPIC ==4
		replace P1CHLPIC_ED = . if P1CHLPIC ==.
		label var P1CHLPIC_ED "Child looks at picture books every day"
		
		label var P1CHREAD "How often does child read/pretend to read?"
		gen P1CHREAD_ED = P1CHREAD ==4
		replace P1CHREAD_ED = . if P1CHREAD ==.	
		label var P1CHLPIC_ED "Child reads/pretends to read every day"

		label values P1CHLPIC P1CHREAD act

		label var P2LIBRAR 	"Visited the library"
		label var P2CONCRT	"Attended a play/concert/other live show"
		label var P2MUSEUM 	"Visited an art gallery/museum/historical site"
		label var P2ZOO 	"Visited a zoo/aquarium/petting farm"
		label var P2SPORT 	"Attended an athletic/sporting event"

		label var P2DANCE 	"Dance lessons"
		label var P2ATHLET	"Organized athletic activities"
		label var P2CLUB	"Organized clubs (like scouts)"
		label var P2MUSIC	"Music or singing lessons"
		label var P2DRAMA	"Drama classes"
		label var P2ARTCRF	"Art classes or lessons"
		label var P2ORGANZ	"Performing arts programs"
		label var P2CRAFTS	"Crafts classes"
		label var P2NOENGL  "Non-English language instruction"

		recode P2LIBRAR-P2SPORT P2DANCE-P2NOENGL(2=0)
		label define yesno 0 "No" 1 "Yes"
		label values P2LIBRAR-P2SPORT P2DANCE-P2NOENGL yesno
		
		recode P2HOMECM P2TCHMAT P2NONEDU (2=0) (.a=0)
		
		gen P2COMPED = P2COMPWK ==4
		replace P2COMPED = . if P2COMPWK ==. //Only works because it ignores ".a"
		label var P2COMPED "Child uses computer every day"
		
	/////////////////////////////
	// Teacher characteristics
	/////////////////////////////
		
		//Gender
			recode B1TGEND (2=0)
			rename B1TGEND B1TMALE
			label var B1TMALE "Teacher is male"

		//Age
			gen B1TAGE = 1998-B1YRBORN if NEW_COHORT ==0
			replace B1TAGE = 2010-B1YRBORN if NEW_COHORT ==1
			replace B1TAGE = 80 if B1TAGE >80 & B1TAGE <. //Top code at 80 years old
			label var B1TAGE "Teacher age"
		
		//Race		
			rename B1RACE2 B1ASIAN
			rename B1RACE3 B1BLACK
			rename B1RACE5 B1WHITE
			
			recode B1HISP B1ASIAN B1BLACK B1WHITE (2=0)
			
			gen B1OTHER = B1RACE1 ==1 | B1RACE4 ==1
			replace B1OTHER =. if B1RACE1 >=. & B1RACE4 >=.
		
			label var B1HISP 	"Teacher is Hispanic"
			label var B1ASIAN 	"Teacher is Asian"
			label var B1BLACK 	"Teacher is Black (non-Hispanic)"
			label var B1WHITE 	"Teacher is White (non-Hispanic)"
			label var B1OTHER 	"Teacher is not Hisp/Asian/Black/White"
		
		//Education 
			gen B1TGRAD = B1HGHSTD >=5 & B1HGHSTD <.
			replace B1TGRAD = 1 if A1HGHSTD >=6 & A1HGHSTD <.
			replace B1TGRAD =. if B1HGHSTD >=. & A1HGHSTD >=.
			label var B1TGRAD "Teacher had a graduate degree"

			gen B1TBACH = B1HGHSTD ==3 | B1HGHSTD ==4
			replace B1TBACH = 1 if A1HGHSTD ==5
			replace B1TBACH =. if B1HGHSTD >=. & A1HGHSTD >=.
			label var B1TBACH "Teacher had a bachelor's degree"
		
		//Teaching experience
			egen yrtch1998 = rowtotal(B1YRSPRE B1YRSKIN B1YRSFST B1YRS2T5 B1YRS6PL B1YRSSPE)
			egen yrtch2010 = rowtotal(A1YRSPRE A1YRSKIN A1YRSFST A1YRS2T5 A1YRS6PL A1YRSSPE)
		
			gen B1YRSTCH = yrtch1998 if NEW_COHORT ==0
			replace B1YRSTCH = yrtch2010 if NEW_COHORT ==1
			replace B1YRSTCH = 60 if B1YRSTCH > 60 & B1YRSTCH <. //Top code at 60 years of experience 
			label var B1YRSTCH "Total years of teaching experience"

			replace B1YRSTCH = B1YRSCH if B1YRSCH > B1YRSTCH & B1YRSCH <. //Total teaching experience can't be less than exp at current sch
			
			replace B1YRSKIN = A1YRSKIN if NEW_COHORT ==1

		//Coursework and certification
			recode B1EARLY-B1MTHDSC (1/6=1)
			recode A1EARLY-A1MTHDSC (2=0)
			
			foreach x in EARLY ELEM SPECED ESL DEVLP MTHDRD MTHDMA MTHDSC	{
				replace B1`x' = A1`x' if NEW_COHORT ==1
			}
			
			recode B1ELEMCT B1ERLYCT (.a=.) (2=0)

	//////////////////////////////
	//Classroom characteristics
	///////////////////////////////

		*Classroom race
			foreach x in BLACK HISP	{
				if "`x'" == "BLACK"		loc r = "b"
				if "`x'" == "HISP"		loc r = "h"
				
				gen `r'1998 = A1`x'/A1TOTAG
				
				gen `r'2010a = A1A`x'/A1ATOTAG
				gen `r'2010p = A1P`x'/A1PTOTAG
				gen `r'2010d = A1D`x'/A1DTOTAG
				egen `r'2010h = rowmean(`r'2010a `r'2010p) //Average across half day teachers

				gen PCT_`x' = `r'2010d
				replace PCT_`x' = `r'2010h if PCT_`x' >=. & `r'2010h<. 
				replace PCT_`x' = `r'1998 if NEW_COHORT ==0			
				replace PCT_`x' = . if PCT_`x' > 1
				
				label var PCT_`x' "Percent of `x' students in the kindergarten classroom"
				drop `r'*

				gen PRED_`x' = PCT_`x' > .5 & PCT_`x' <.
				replace PRED_`x' = . if PCT_`x' ==.
				label var PRED_`x' "Class is more than 50% `x'"

				gen PRED_`x'_INT = PRED_`x' ==1 & NEW_COHORT ==1
				replace PRED_`x'_INT = . if PRED_`x' ==.
				label var PRED_`x'_INT "Interaction between predominantly `x' students in classrom and new cohort"

			} // close x loop
	
		*Behavior

			egen a1behvr = rowmean(A1ZBEHVR A1PBEHVR)
			replace A1BEHVR = A1DBEHVR if NEW_COHORT ==1
			replace A1BEHVR = a1behvr if NEW_COHORT ==1 & A1BEHVR >=.
			drop a1behvr
	
			gen WELLBEH = A1BEHVR >=4 & A1BEHVR <.
			replace WELLBEH =. if A1BEHVR >=.
			label var WELLBEH "Classroom group behaves well/exceptionally well"

			gen MISBEH = A1BEHVR <=2
			replace MISBEH =. if A1BEHVR >=.
			label var MISBEH "Classroom group misbehaves frequently/very frequently"


		*Literacy
			foreach x in LETT WORD SNTNC	{
				replace A1D`x' = A1A`x' if A1D`x' >=. //Only using AM classes for half day statistics
				
				gen pct_`x' = A1`x'/A1TOTAG
				replace pct_`x' = . if pct_`x' > 1
		
				gen `x'_lt25 = pct_`x' < .25
				replace `x'_lt25 = . if pct_`x' >=.

				gen `x'_mt75 = pct_`x' > .75 & pct_`x' <.
				replace `x'_mt75 = . if pct_`x' >=.
			}
			
			gen A1LETT_25 = LETT_lt25 ==1 | A1DLETT ==1
			replace A1LETT_25 = . if LETT_lt25 >=. & A1DLETT >=.

			gen A1LETT_75 = LETT_mt75 ==1 | A1DLETT ==5
			replace A1LETT_75 = . if LETT_mt75 >=. & A1DLETT >=.
	
			gen A1WORD_25 = WORD_lt25 ==1 | A1DWORD ==1
			replace A1WORD_25 = . if WORD_lt25 >=. & A1DWORD >=.

			gen A1WORD_75 = WORD_mt75 ==1 | A1DWORD ==5
			replace A1WORD_75 = . if WORD_mt75 >=. & A1DWORD >=.

			gen A1SNTNC_25 = SNTNC_lt25 ==1 | A1DSNTNC ==1
			replace A1SNTNC_25 = . if SNTNC_lt25 >=. & A1DSNTNC >=.

			gen A1SNTNC_75 = SNTNC_mt75 ==1 | A1DSNTNC ==5
			replace A1SNTNC_75 = . if SNTNC_mt75 >=. & A1DSNTNC >=.


	//////////////////
	//Interactions		
	//////////////////
	
		gen MALEINT = MALE*NEW_COHORT
		label var MALEINT "Child is male in the 2010 cohort"
			
		foreach i in BLACK HISP ASIAN OTHER	{
			gen `i'INT = `i' ==1 & NEW_COHORT ==1
			replace `i'INT =. if `i' ==.
			label variable `i'INT "Child is `i' and in the 2010 cohort"
		}	

		forvalues i = 1/5	{
			gen SESQ`i'INT = SESQ`i' ==1 & NEW_COHORT ==1
			replace SESQ`i'INT = . if SESQ`i'==.
			label variable SESQ`i'INT "Student was in quintile `i' in 2010 cohort"
		}	
		
		gen FORMINT = FORMAL*NEW_COHORT
		label var FORMINT "Interaction between formal care and 2010"

		foreach x in BLACK HISP ASIAN OTHER	{	
			gen `x'_LOWSES = LOW_INC*`x'
			gen `x'_LOWSES10 = `x'_LOWSES * NEW_COHORT
		} // closes x loop

		gen BLACKFORM = FORMAL*BLACK
		gen HISPFORM  = FORMAL*HISP
		gen ASIANFORM = FORMAL*ASIAN
		gen OTHERFORM = FORMAL*OTHER

		gen BLACKFORMINT = FORMAL*BLACK*NEW_COHORT
		gen HISPFORMINT  = FORMAL*HISP*NEW_COHORT
		gen ASIANFORMINT = FORMAL*ASIAN*NEW_COHORT
		gen OTHERFORMINT = FORMAL*OTHER*NEW_COHORT
			
		
	//Sampling weight
		gen WEIGHT = C1CPTW0 if NEW_COHORT==0
		replace WEIGHT = W1P0 if NEW_COHORT==1

		gen WEIGHT2 = C1CPTW0 if NEW_COHORT==0
		replace WEIGHT2 = W1T0 if NEW_COHORT==1
		
		gen SWEIGHT = C2CPTW0 if NEW_COHORT ==0
		replace SWEIGHT = W12T0 if NEW_COHORT ==1


		
save "C:\Users\sal3ff\Scott\Kids Today\Generated Datasets\Cross-Cohort Clean", replace
