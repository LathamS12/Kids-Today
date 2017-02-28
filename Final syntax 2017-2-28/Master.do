/************************************************************
* Author: Scott Latham
* Purpose: This is the master file for the Kids Today R & R
*			at Educational Researcher
* 
*
* Created: 7/4/2014
* Last modified: 12/5/2016
********************************************************/

	global data "Z:\save here\Scott Latham\ECLS-K data"
	global path "Z:\save here\Scott Latham\Kids Today\Generated Datasets"
	
	cd "Z:\save here\Scott Latham\Kids Today\Syntax"

	do "Variable Selection"
	do "Data Cleaning"
	do "Imputing"
	
	//do "R & R Manuscript Tables"
