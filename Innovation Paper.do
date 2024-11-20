/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////			SETUP			/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Initialization 
{
version 17			// set stata version 
clear all			// clears all previous work		 
macro drop _all		// clears all macros
set linesize 80		// max character per output line 
set more off		// Prevents Stata from pausing and displaying the ---more---message
putdocx clear       //close document if open
}

//Defining Directory, Logging, and importing dataset
global Dataset_Path "C:\Users\Zeina\Desktop\Research In Progress\Innovattion Paper - MA Project\Dataset"	// Define Path to required files
global Final_Path "C:\Users\Zeina\Desktop\Research In Progress\Innovattion Paper - MA Project"

cd "$Dataset_Path"
use "WBES_Dataset_Macro.dta " , clear // 30 Dec 2023

cd "$Final_Path"
///Logging 
capture log close										//closes log file if open and ignores error if already closed
log using "logfile" , text replace


run wbes_programs.do // loading customized stata commands 

**# setting up word document and variables

putdocx begin, font( New Times Roman, 12 ,black) footer(foot1)
 
**# Data Processing 

run Process_Dataset.do  //running the do file responsible for processing the original dataset and generating the new dataset

save WBES_processed_dataset.dta

global full_model mgmt_indx firm_age nb_workers mgr_exp fem_mngr infor_comp foreign_own_pct Domestic Exporter mgmt_ownership new_prod proc_innov r_and_d qual_cert tech_lic fem_owner

foreach v in $full_model {


drop if `v'==.
}

drop if Manufacturing != 1 //restricting sample to the manufacturing sector as only 8 observations are left in other sectors when we drop all missing observations 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////			Master Setup	   		///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

gen innovation = proc_innov + new_prod
replace innovation = 1 if innovation == 2

//Allocating Control Variables in Categories 
global Firm_Characteristics firm_age nb_workers mgr_exp fem_mngr fem_owner 
global Firm_Nature infor_comp foreign_own_pct
global Firm_Innovation r_and_d qual_cert tech_lic

//mgmt_exporter  
//Defining the regression variables


//sales_growth lp_growth cap_util

global dep_var_list sales_growth lp_growth cap_util		    //Defining the Dependent Variables


global indep_set1 mgmt_indx  
global indep_set2 $indep_set1 $Firm_Characteristics
global indep_set3 $indep_set2 $Firm_Nature 
global indep_set4 $indep_set3 Domestic Exporter     
global indep_set5 $indep_set4 $Firm_Innovation
global indep_set6 $indep_set5 
    

global ind_var_list indep_set1 indep_set2 indep_set3 indep_set4 indep_set5 //indep_set6 //Subsets of Independent variables to be used in the regression 


// Defining Descriptive statistics variables
global Sum_stat_Vars innovation $indep_set5 Micro Small Medium Large Domestic Foreign Exporter Non_Exporter 

global full_model mgmt_indx firm_age nb_workers mgr_exp fem_mngr fem_owner infor_comp foreign_own_pct Domestic Exporter r_and_d qual_cert tech_lic 

////// Same model subsamples 

//Defining Variables for subsampling regressions 
global sub1 main_sample Small Medium Large //should take dummy variables only  // Note micro was removed reconsider the categories size
global subsample_table1 1 "Main" 2 "Small" 3 "Medium" 4 "Large"

//Subsample by region
global sub2 main_sample AFR EAP ECA LAC MNA SAR
global subsample_table2 1 "Main" 2 "AFR" 3 "EAP" 4 "ECA" 5 "LAC" 6 "MNA" 7 "SAR"

//Subsample by legal form
global sub3 main_sample lf_plo lf_llc lf_sp lf_par lf_lpar
global subsample_table3 1 "Main" 2 "Publicly Listed Company" 3 "Private Limited Liability Company" 4 "Sole Proprietorship" 5 "Partnership" 6 "Limited Partnership"

///// Multiple models subsamples

//Subsample by Domestic, Exporter, Female Manager
global Domestic_sample mgmt_indx firm_age nb_workers mgr_exp fem_mngr fem_owner infor_comp foreign_own_pct Exporter r_and_d qual_cert tech_lic 
global Exporter_sample mgmt_indx firm_age nb_workers mgr_exp fem_mngr fem_owner infor_comp foreign_own_pct Domestic r_and_d qual_cert tech_lic 
global Mng_sample mgmt_indx firm_age nb_workers mgr_exp fem_owner infor_comp foreign_own_pct Domestic Exporter r_and_d qual_cert tech_lic 



//Subsampling 

global vlist_msub1 full_model Domestic_sample Domestic_sample Exporter_sample Exporter_sample Mng_sample Mng_sample
global msub1 main_sample Domestic Foreign Exporter Non_Exporter Male_Manager Female_Manager //should take dummy variables only  //
global msubsample_table1 1 "Main" 2 "Domestic" 3 "Foreign" 4 "Exporter" 5 "Non-Exporter" 6 "Male Manager" 7 "Female Manager"

//Subsample by interaction between Manager gender and Exporter
global ME_sample mgmt_indx firm_age nb_workers mgr_exp fem_owner infor_comp foreign_own_pct Domestic r_and_d qual_cert tech_lic
global FE_sample mgmt_indx firm_age nb_workers mgr_exp fem_owner infor_comp foreign_own_pct Domestic r_and_d qual_cert tech_lic 

global vlist_msub2 full_model ME_sample FE_sample ME_sample FE_sample
global msub2 main_sample Male_Exporter Female_Exporter Male_Non_Exporter Female_Non_Exporter
global msubsample_table2 1 "Main" 2 "Male Manager x Exporter" 3 "Female Manager x Exporter" 4 "Male Manager x Non-Exporter" 5 "Female Manager x Non-Exporter"

//Subsampling by female majority ownership
global Own_sample mgmt_indx firm_age nb_workers mgr_exp fem_mngr infor_comp foreign_own_pct Domestic Exporter r_and_d qual_cert tech_lic 

global vlist_msub3 full_model Own_sample Own_sample Mng_sample Mng_sample
global msub3 main_sample male_owned female_owned Male_Manager Female_Manager //should take dummy variables only  //
global msubsample_table3 1 "Main" 2 "Male Ownership Majority" 3 "Female Ownership Majority" 4 "Male Manager" 5 "Female Manager"

//Defining macros for otpions
global c_options , fe
global c_prefix //bootstrap, rep(500):

//Setting fixed effects by country
encode wbcode, gen(country)
xtset country

// NAtural resources as a deterence for firm innovation ?
local T=0		//Tables Number Counter

descrstat $Sum_stat_Vars 

Collin_test proc_innov indep_set6  


cmexport xtlogit proc_innov ind_var_list c_options c_prefix

//Subsample regresion same model

sub_cmexport xtlogit proc_innov full_model sub1 subsample_table1 c_options c_prefix

sub_cmexport xtlogit proc_innov full_model sub2 subsample_table2 c_options c_prefix

sub_cmexport xtlogit proc_innov full_model sub3 subsample_table3 c_options c_prefix

//Subsample regresion multiple models
msub_cmexport xtlogit proc_innov vlist_msub1 msub1 msubsample_table1 c_options c_prefix
msub_cmexport xtlogit proc_innov vlist_msub2 msub2 msubsample_table2 c_options c_prefix
msub_cmexport xtlogit proc_innov vlist_msub3 msub3 msubsample_table3 c_options c_prefix


**# Saving relevant files
putdocx save Innovation_Paper2.docx, replace


cd "$Dataset_Path"
save "Innovation_WBES_Data.dta " , replace

/*
global xxx 1 2 3
global yyy 1 2 3

local j=1
foreach x in $xxx {


    display "`:word `j' of $xxx' and `:word `j' of $yyy'"


local j=`j'+1
}
/*