
//Generating a new dataset
//cd "C:\Users\Zeina\Desktop\Management_Practices\Original Dataset"	
//use "ES-Indicators-Database-Global-Methodology_June_26_2023.dta " , clear


//renaming vaiables 
global old_variables t1 t4 t7 t9 t10 tr4 tr5 tr6 tr15 tr16 tr10 tr17 ///
mgmt1 mgmt2 mgmt3 mgmt4 mgmt5 mgmt6 mgmt7 mgmt8 mgmt9 ///
wk8 wk14 car3 car7 perf1 perf3 t3 car1 ///
lform1 lform2 lform3 lform4 lform5 infor1 gend4 gend6 ///
reg4 reg5 bus5 reg7 reg8 crime9 crime8 infor2 fin16 in11 in12 wk9 wk10


global new_variables qual_cert tech_lic new_prod proc_innov r_and_d dom_sales exp_direct exp_indirect exp_1pct exp_10pct exp_total_1pct exp_total_10pct ///
mgmt_indx prob_action perf_indic time_focus achieve knowledge mgr_bonus nonmgr_promo nonmgr_reassign ///
mgr_exp nb_workers foreign_own_pct foreign_own_10pct sales_growth lp_growth cap_util firm_age ///
lf_plo lf_llc lf_sp lf_par lf_lpar infor_comp fem_mngr fem_owner ///
con_trate con_tadmin con_lic con_poli con_land con_court con_crime con_inform con_fin con_trans con_elec con_lreg con_ledu

rename ($old_variables ) ($new_variables )	

//Generate new dummy variables for MSME
gen msme=10
replace msme=1 if nb_workers<=9
replace msme=2 if nb_workers>9 & nb_workers<=49
replace msme=3 if nb_workers>49 & nb_workers<=249
replace msme=4 if nb_workers>249
lab define msme 1 "Micro" 2 "Small" 3 "Medium" 4 "Large", modify
lab val msme "msme"

gen Micro=0
replace Micro=1 if nb_workers<=9
lab define Micro 0 "Not Micro" 1 "Micro", modify
lab val Micro "Micro"

gen Small=0
replace Small=1 if nb_workers>9 & nb_workers<=49
lab define Small 0 "Not Small" 1 "Small", modify
lab val Small "Small"

gen Medium=0
replace Medium=1 if nb_workers>49 & nb_workers<=249
lab define Medium 0 "Not Medium" 1 "Medium", modify
lab val Medium "Medium"

gen Large=0
replace Large=1 if nb_workers>249
lab define Large 0 "Not Large" 1 "Large", modify
lab val Large "Large"

//Generate new Dummy Variables for Sector 

rename (sector_3_v3_1) (sector)

replace sector = . if sector == 40 | sector ==61 | sector == 63 | sector == 64 | sector == 69 | sector == 74
drop if sector==.

gen Manufacturing=0
replace Manufacturing=1 if sector==1
lab define Manufacturing 0 "Not Manufacturing" 1 "Manufacturing", modify
lab val Manufacturing "Manufacturing"

gen Retail=0
replace Retail=1 if sector==2
lab define Retail 0 "Not Retail" 1 "Retail", modify
lab val Retail "Retail"

gen Other_Services=0
replace Other_Services=1 if sector==3
lab define Other_Services 0 "Not Other Services" 1 "Other Services", modify
lab val Other_Services "Other_Services"


//EDIT THIS PART

//labeling Dummy Variables
global dummy_var_list "foreign_own_10pct exp_10pct exp_1pct exp_total_10pct exp_total_1pct r_and_d proc_innov new_prod tech_lic qual_cert exporter ownership lf_plo lf_llc lf_sp lf_par lf_lpar infor_comp fem_mngr fem_owner con_trate con_tadmin con_lic con_poli con_land con_court con_crime con_inform con_fin con_trans con_elec con_lreg con_ledu"

global labels_0 "Foreign_Ownership_<10% Exports_<10% Exports_<1% Total_Exports_<10% Total_Exports_<1% No_R&D_Investment No_Process_Innovation No_New_Product/Service No_Technology_License No_Quality_Certification Non_Exporter Domestic Other Other Other Other Other None No Male_Owner No No No No No No No No No No No No No"

global labels_1 "Foreign_Ownership_>=10% Exports_>=10% Exports_>=1% Total_Exports_>=10% Total_Exports_>=1% R&D_Investment Process_Innovation New_Product/Service Technology_License Quality_Certification Exporter Foreign Publicly_Listed_Company Private_Limited_Liability_Company Sole_Proprietorship Partnership Limited_Partnership Informal_Competition Female_Manager Female_owner Yes Yes Yes Yes Yes Yes Yes Yes Yes Yes Yes Yes Yes"

local k=0
foreach x in $dummy_var_list { 
	local k=`k'+1
	recode `x' (0=0) (100=1)
	lab define `x' 0 "`:word `k' of $labels_0'" 1 "`:word `k' of $labels_1'", modify
	lab val `x' "`x'"
}

// EDIT THIS PART 


//Generate  Domestic Foreign
drop if ownership==.
gen Domestic = 0
gen Foreign = 0
replace Domestic = 1 if ownership==0
replace Foreign = 1 if ownership==1

//Generate female owner dummies
drop if fem_owner==.
gen female_owned = 0
gen male_owned = 0
replace female_owned = 1 if fem_owner==1
replace male_owned = 1 if fem_owner==0 
 
//Generate Exporter Non-Exporter
drop if exporter==.
gen Exporter = 0
gen Non_Exporter = 0
replace Exporter = 1 if exporter==1
replace Non_Exporter = 1 if exporter==0

//Generate Female_Manager Male_Manager
drop if fem_mngr==.
gen Male_Manager = 0
gen Female_Manager = 0
replace Male_Manager = 1 if fem_mngr==0
replace Female_Manager = 1 if fem_mngr==1

// Interaction terms 

// Manager Gender x Exporter 

gen Male_Exporter = Male_Manager * Exporter
gen Female_Exporter = Female_Manager * Exporter  
gen Male_Non_Exporter = Male_Manager * Non_Exporter
gen Female_Non_Exporter = Female_Manager * Non_Exporter

gen mgmt_exporter = mgmt_indx * Exporter
gen mgmt_domestic = mgmt_indx * Domestic
gen mgmt_ownership = mgmt_indx * foreign_own_pct


//Generating Dummy Variables Based on Categorical Variables 
  

// Transforming prob_action into multiple dummy variables 
gen prb_fix = 1
replace prb_fix = 0 if prob_action==0
replace prb_fix = . if prob_action==.

gen pfix_nactn = 0
replace pfix_nactn = 1 if prob_action>33 & prob_action<34
replace pfix_nactn = . if prob_action==.

gen pfix_actn = 0
replace pfix_actn = 1 if prob_action>66 & prob_action<67
replace pfix_actn = . if prob_action==.

gen pfix_imprv = 0
replace pfix_imprv = 1 if prob_action==100
replace pfix_imprv = . if prob_action==.

// Transforming perf_indic into multiple dummy variables 

gen perf_ind_0 = 0
replace perf_ind_0 = 1 if perf_indic==0
replace perf_ind_0 = . if perf_indic==.

gen perf_ind_1r2 = 0
replace perf_ind_1r2 = 1 if perf_indic>33 & perf_indic<34
replace perf_ind_1r2 = . if perf_indic==.

gen perf_ind_3r9 = 0
replace perf_ind_3r9 = 1 if perf_indic>66 & perf_indic<67
replace perf_ind_3r9 = . if perf_indic==.

gen perf_ind_10 = 0
replace perf_ind_10 = 1 if perf_indic==100
replace perf_ind_10 = . if perf_indic==.


// Transforming time_focus into multiple dummy variables 

gen oper_target = 1
replace oper_target = 0 if time_focus==0
replace oper_target = . if time_focus==.

gen shrt_targ = 0
replace shrt_targ = 1 if time_focus>33 & time_focus<34
replace shrt_targ = . if time_focus==.

gen lng_targ = 0
replace lng_targ = 1 if time_focus>66 & time_focus<67
replace lng_targ = . if time_focus==.

gen mix_targ = 0
replace mix_targ = 1 if time_focus==100
replace mix_targ = . if time_focus==.

// Transforming achieve into multiple dummy variables

gen ez_achv = 0
replace ez_achv = 1 if achieve==0 & oper_target==0
replace ez_achv = . if achieve==.

gen no_achv = 0
replace no_achv = 1 if achieve==25
replace no_achv = . if achieve==.

gen sm_eff_achv = 0
replace sm_eff_achv = 1 if achieve==50
replace sm_eff_achv = . if achieve==.

gen nrm_eff_achv = 0
replace nrm_eff_achv = 1 if achieve==75
replace nrm_eff_achv = . if achieve==.

gen anrm_eff_achv = 0
replace anrm_eff_achv = 1 if achieve==100
replace anrm_eff_achv = . if achieve==.


// Transforming knowledge into multiple dummy variables

gen srmngr_know = 0
replace srmngr_know = 1 if knowledge==0 & oper_target==0
replace srmngr_know = . if knowledge==.

gen mngr_swrk_know = 0
replace mngr_swrk_know = 1 if knowledge>33 & knowledge<34
replace mngr_swrk_know = . if knowledge==.

gen mngr_mwrk_know = 0
replace mngr_mwrk_know = 1 if knowledge>66 & knowledge<67
replace mngr_mwrk_know = . if knowledge==.

gen amngr_mwrk_know = 0
replace amngr_mwrk_know = 1 if knowledge==100
replace amngr_mwrk_know = . if knowledge==.

// Transforming mgr_bonus into multiple dummy variables

gen pays_bonus = 1
replace pays_bonus = 0 if mgr_bonus==0 
replace pays_bonus = . if mgr_bonus==.

gen firm_bonus = 0
replace firm_bonus = 1 if mgr_bonus==25
replace firm_bonus = . if mgr_bonus==.

gen estb_bonus = 0
replace estb_bonus = 1 if mgr_bonus==50
replace estb_bonus = . if mgr_bonus==.

gen team_bonus = 0
replace team_bonus = 1 if mgr_bonus==75
replace team_bonus = . if mgr_bonus==.

gen person_bonus = 0
replace person_bonus = 1 if mgr_bonus==100
replace person_bonus = . if mgr_bonus==.

// Transforming nonmgr_promo into multiple dummy variables

gen no_prom = 0
replace no_prom = 1 if nonmgr_promo==0
replace no_prom = . if nonmgr_promo==.

gen factor_prom = 0
replace factor_prom = 1 if nonmgr_promo>33 & knowledge<34
replace factor_prom = . if nonmgr_promo==.

gen par_perf_prom = 0
replace par_perf_prom = 1 if nonmgr_promo>66 & knowledge<67
replace par_perf_prom = . if nonmgr_promo==.

gen perf_prom = 0
replace perf_prom = 1 if nonmgr_promo==100
replace perf_prom = . if nonmgr_promo==.    


// Transforming nonmgr_reassign into multiple dummy variables

gen dismiss = 1
replace dismiss = 0 if nonmgr_reassign==0 
replace dismiss = . if nonmgr_reassign==.

gen dismiss_a6mnth = 0
replace dismiss_a6mnth = 1 if nonmgr_reassign==50
replace dismiss_a6mnth = . if nonmgr_reassign==.

gen dismiss_w6mnth = 0
replace dismiss_w6mnth = 1 if nonmgr_reassign==100
replace dismiss_w6mnth = . if nonmgr_reassign==.

// Regions 

gen AFR = 0
gen EAP = 0
gen ECA = 0
gen LAC = 0
gen MNA = 0
gen SAR = 0


replace AFR = 1 if region == 1
replace EAP = 1 if region == 2
replace ECA = 1 if region == 3
replace LAC = 1 if region == 4
replace MNA = 1 if region == 5
replace SAR = 1 if region == 6


//Labeling Variables for tables
global var_labels "empty" "Quality Certification" "Tech License" "New Product/Service" "Process Innovation" "R&D Investment" "Domestic Sales (%)" "Exported Direct Sales (%)" "Exported Indirect Sales (%)" "Export 1% of Sales" "Export 10% of Sales" "Total Export 1% of Sales" "Total Export 10% of Sales" "Management Index" "Problem Action Score" "Performance Indicators Score" "Time Focus Score" "Achievability Score" "Knowledge Score" "Manager Bonus Score" "Non-Manager Promotions" "Non-Manager Reassignment" "Manager Experience" "Number of Workers" "Foreign Ownership (%)" "Foreign Ownership 10%+ (%)" "Sales Growth (%)" "Labor Productivity Growth (%)" "Capacity Utilization (%)" "Firm Age" ///
"Publicly Listed Company" "Private Limited Liability Company"  "Sole Proprietorship" "Partnership" "Limited Partnership" "Informal Competition" "Female Manager" "Female Owner" ///
"Micro (<=9)" "Small (9-49)" "Medium (49-249)" "Large >249" "Manufacturing" "Retail" "Other Services" "Domestic" "Foreign" "Exporter" "Non Exporter" "Male Manager" "Female Manager" "Male Manager x Exporter" "Female Manager X Exporter" "Male Manager X Non-Exporter" "Female Manager X Non-Exporter" "Exporter X Management Index" "Domestic X Management Index" "Foreign Ownership X Management Index ownership" "AFR" "EAP" "ECA" "LAC" "MNA" "SAR" "Male Ownership Majority" "Female Ownership Majority"


global Table_Var $new_variables Micro Small Medium Large Manufacturing Retail Other_Services Domestic Foreign Exporter Non_Exporter Male_Manager Female_Manager Male_Exporter Female_Exporter Male_Non_Exporter Female_Non_Exporter mgmt_exporter mgmt_domestic mgmt_ownership AFR EAP ECA LAC MNA SAR male_owned female_owned
 
local vn=1
foreach v in $Table_Var {
local vn=`vn'+ 1
label var `v' "`:word `vn' of $var_labels'"

//drop if `v'==.
}


*drop if region != 5 //restricting sample to specific region

gen main_sample = 1  // Generating a dummy variable to control for main and subsamples 

///////////////////////////////////////////////////////////////////////////////////////////////// Handling Additional Macro Variables /////////////////////////////////////////////////



global Table_macro_Var GDP_capita RD_expenditure_GDP Hi_tech_exp_manu patent_app_res patent_app_nres journal_articles net_users cell_subs gross_fcapital_Form_GDP edu_expend_GDP tax_profits edb_index labor_part unemp_rate electric_acc energy_use FDI_inflow_GDP GDP_growth inflation trade_GDP personal_trans_rec remit_GDP Charges_IP legal_rights_index time_start_bus_days broadband_subs tert_education H_cap_index Researchers_RD

global macro_var_labels "empty" "GDP per Capita (current US$)" "R&D Expenditure (% of GDP)" "High-technology Exports (% of Manufactured Exports)" "Patent Applications (Residents)"	"Patent Applications (Non-Residents)" "Scientific and Technical Journal Articles" "Internet Users (% of Population)" "Mobile Cellular Subscriptions (per 100 People)" "Gross Fixed Capital Formation (% of GDP)" "Education Expenditure (% of GDP)"	"Total Tax Rate (% of Commercial Profits)" "Ease of Doing Business Index" "Labor Force Participation Rate (% of Adult Population)"	"Unemployment Rate (% of Total Labor Force)" "Electricity Access (% of Population)"	"Energy Use (kg of Oil Equivalent per Capita)"	"Foreign Direct Investment, Net Inflows (% of GDP)"	"Annual GDP Growth (%)"	"Inflation, Consumer Prices (Annual %)"	"Trade (% of GDP)" "Personal Transfers, Receipts (BoP, Current US$)" "Personal Remittances, Received (% of GDP)" "Charges for the Use of Intellectual Property, Receipts (BoP, Current US$)" "Strength of legal rights index" "Time required to start a business (days)" "Fixed broadband subscriptions (per 100 people)" "Tertiary education enrollment rate" "Human Capital Index" "Researchers in R&D (per million people)"


 
local vn=1
foreach v in $Table_macro_Var {
local vn=`vn'+ 1
label var `v' "`:word `vn' of $var_labels'"

//drop if `v'==.
}
//legal_rights_index time_start_bus_days H_cap_index

global ln_vars GDP_capita patent_app_res journal_articles patent_app_nres energy_use personal_trans_rec Charges_IP 

global pct_vars RD_expenditure_GDP Hi_tech_exp_manu net_users cell_subs gross_fcapital_Form_GDP edu_expend_GDP tax_profits labor_part unemp_rate electric_acc FDI_inflow_GDP GDP_growth inflation trade_GDP remit_GDP broadband_subs tert_education 

local vn=1
foreach v in $pct_vars {
local vn=`vn'+ 1

replace `v' = `v'/100 

//drop if `v'==.
}

local vn=1
foreach v in $ln_vars {
local vn=`vn'+ 1

gen ln_`v' = ln(`v')

//drop if `v'==.
}


//keeping relevant variables
//keep wbcode country_official year countryx sector_MS sector_3_v3_1 stra_sector obs region idstd ownership exporter size Country Year $new_variables $Table_macro_Var


//gen cons_inten = (reg4 +reg5+ bus5+ reg7 +reg8 +crime9 +crime8 +infor2 +fin16 +in11 +in12 +wk9+ wk10)/100

gen cons_inten = con_trate + con_tadmin + con_lic + con_poli + con_land + con_court + con_crime + con_inform + con_fin + con_trans + con_elec + con_lreg + con_ledu
//gen ln_GDP_capita = ln(GDP_capita)
//gen ln_Charges_IP = ln(Charges_IP)

//Researchers_RD
//logit proc_innov knowledge cons_inten exporter ownership tax_profits qual_cert r_and_d mgr_exp nb_workers firm_age foreign_own_pct infor_comp fem_mngr  ln_GDP_capita ln_Charges_IP broadband_subs edb_index trade_GDP remit_GDP legal_rights_index Researchers_RD


// Controling for unusual and illogical outliers

drop if tax_profits > 100 