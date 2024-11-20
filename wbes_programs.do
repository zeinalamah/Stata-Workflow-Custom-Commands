
**# Descriptive Statistics Program

capture program drop descrstat
program define descrstat
 
local nb=0
collect create summary_statistics
foreach sv in `0' {
collect: sum `sv'

local N_`sv' = round(r(N))
local mean_`sv' = round(r(mean),0.01) 
local sd_`sv' = round(r(sd),0.01)
local min_`sv' = round(r(min),0.01)
local max_`sv' = round(r(max),0.01) 

*local skewness_`sv' = r(skewness) 


local nb=`nb'+1
local svl: variable label `sv'
collect label levels cmdset `nb' "`svl'"

if `nb'==1{
//    local sentence_vars `:var label `sv''
}
if `nb'>1{
//local sentence_vars `sentence_vars', `:var label `sv''
}
//local sum_sentence1 The study sample consisted of `N_`sv'' individuals and included the variables `sentence_vars'

//local sum_sentence_`sv' `:var label `sv'' had a mean of `mean_`sv'' suggesting that the majority of the sample fell around this value with a degree of dispersion of `sd_`sv''. Moreover, `:var label `sv'' ranged between `min_`sv'' and `max_`sv''. 

//local sum_sentence2 `sum_sentence2' `sum_sentence_`sv''

}

collect layout (cmdset) (result[N mean sd min max skewness])
collect style cell result[N mean sd min max skewness], nformat(%8.3f)  
collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
*collect style row stack, spacer delimiter(" x ")
//collect style cell cell_type[column-header], halign(center) valign(center)

local T=`T'+1
collect style putdocx, layout(autofitcontents) title("Table `T': Summary Statistics")
putdocx collect

putdocx paragraph
putdocx text ("Descriptive Statistics")
putdocx paragraph
putdocx text ("`sum_sentence1'. `sum_sentence2'")


collect drop summary_statistics
end 

/*
Guide for using the command
putdocx begin, font( New Times Roman, 12 ,black) footer(foot1) // Must have an active word document 

descrstat avggaspriceusd avggaspriceusd avggaspriceusd // Select the variables

putdocx save test_text.docx, replace // Close the document 
*/

*****************************************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************************************

//Contains a Bug must figure out how to fix it 

capture program drop Collin_test
program define Collin_test

local j=0

local j=`j'+1
//Generating text for Collinearity Test 

collect create Collinearity_Test_`y'_`j'

*collin $collin_vars
*local mean_vif = round(r(m_vif),0.01)

local T=`T'+1  // Accounting for the Collinearity Table 

reg `1' $`2'  

estat vif
local vc=0
*set trace on
foreach collin_var in $`2' {
    
local vc= `vc' + 1 //counter for varaibles 
    
if `vc'==1{
   
local vif_list r(vif_`vc') 

local tol_list 1/r(vif_`vc')   

local table_list r(vif_`vc'),1/r(vif_`vc')  

local sum_vif = r(vif_`vc')
local sum_tol = 1/r(vif_`vc')
    
}
	
if `vc'>1{    
local vif_list `vif_list' \ r(vif_`vc') 

local tol_list `tol_list' \ 1/r(vif_`vc') 

local table_list `table_list' \ r(vif_`vc'),1/r(vif_`vc')  

local sum_vif = `sum_vif' + r(vif_`vc')
local sum_tol =`sum_tol' + 1/r(vif_`vc')

}

local collin_val `collin_val' "`:var label `collin_var''"

}

mat normal_vif=(`vif_list')
mat tolerance=(`tol_list')

local mean_vif = round(`sum_vif'/`vc',0.01)  
*local mean_tol = `tol_vif'/`vc'

mat table_m = (`table_list' \ `sum_vif'/`vc', `sum_tol'/`vc' )
matrix rownames table_m = $`2' Mean
matrix colnames table_m = VIF Tolerance

putdocx table tb2=matrix(table_m) , nformat(%8.3f) rownames colnames
*set trace off
if `mean_vif'<10 {
    
	local vif_text The VIF's mean value in Table 2 is `mean_vif', suggesting no multicollinearity issue amongst our independent variables.
}

if `mean_vif'>10 {
    
	local vif_text The VIF's mean value in Table 2 is `mean_vif', suggesting a multicollinearity issue amongst our independent variables.
}

putdocx paragraph
putdocx text ("Collinearity Test")
putdocx paragraph
putdocx text ("It is essential to check for correlation between the explanatory variables because this would increase the variance of the regression coefficients and make it difficult to determine the statistical significance of our findings. When we suspect our explanatory variables are correlated, we use a widely used diagnostic test called the Variance Inflator Factor (VIF). A concerning VIF value consists of 10 or above (Hair et al. 1995). `vif_text'")


end

*****************************************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************************************

capture program drop cmexport
program define cmexport

local i=0
local j=0


	local j= `j' + 1
	//Running the relevant regressions 

	collect create regression_`2'_`j'_`1'

	collect create marginal_`2'_`j'_`1'

	foreach x in $`3' { 

		local i= 1 + `i'

		collect set regression_`2'_`j'_`1'
		collect: $`5' `1' `2' $`x' $`4' //,robust //Run and collect the Regression Based on the Variables defined in the master do_file 

		//collect set marginal_`2'_`j'_`1'				//compute and collect marginal effects
		//collect: margins, dydx(*)
	}
		collect set regression_`2'_`j'_`1'
		collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
		collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
		collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
		collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
		collect label values colname _cons "Constant", modify
		collect style header result[_r_se _r_b], level(hide)
		collect style cell result[_r_se], sformat("(%s)")
		collect style showbase off
		*collect style row stack, spacer delimiter(" x ")
		collect style cell cell_type[column-header], halign(center) valign(center)

		local T=`T'+1
		collect style putdocx, layout(autofitcontents)               ///
		title("Table `T': `1' Regression Model for `2'")
		putdocx collect

/*
//Marginal
		collect set marginal_`2'_`j'_`1'
		collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
		collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
		collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
		collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
		collect label values colname _cons "Constant", modify
		collect style header result[_r_se _r_b], level(hide)
		collect style cell result[_r_se], sformat("(%s)")
		collect style showbase off
		*collect style row stack, spacer delimiter(" x ")
		collect style cell cell_type[column-header], halign(center) valign(center)

		local T= `T' + 1
		collect style putdocx, layout(autofitcontents)               ///
		title("Table `T': `1' Marginal effect for `2'")
		putdocx collect


//Generating the Combined Marginal table

		collect combine combined_`2'_`j'_`1' = regression_`2'_`j'_`1' marginal_`2'_`j'_`1'
		collect set combined_`2'_`j'_`1'
		collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
		collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
		collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
		collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
		collect label values colname _cons "Constant", modify
		collect style header result[_r_se _r_b], level(hide)
		collect style cell result[_r_se], sformat("(%s)")
		collect style showbase off
		*collect style row stack, spacer delimiter(" x ")
		collect style cell cell_type[column-header], halign(center) valign(center)

		local T= `T' + 1
		collect style putdocx, layout(autofitcontents)               ///
		title("Table `T': `1' Combined Marginal effect for `2'")
		putdocx collect


collect drop combined_`2'_`j'_`1' marginal_`2'_`j'_`1'
*/

collect drop regression_`2'_`j'_`1'

end

*****************************************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************************************

capture program drop sub_cmexport
program define sub_cmexport

local i=0
local j=0
 

local j=`j'+1

**# Subsample 1
collect create reg_`2'_`j'_`1'_`4'
collect create mar_`2'_`j'_`1'_`4'

foreach c in $`4' { 

collect set reg_`2'_`j'_`1'_`4'
collect: $`7' `1' `2' $`3' if `c' == 1 $`6'


//collect set mar_`2'_`j'_`1'_`4'				//compute and collect marginal effects
//collect: margins, dydx(*)

local i=`i'+ 1
} 
// end of loop over the subsamples

**# layout for supsample tables

collect set reg_`2'_`j'_`1'_`4'
collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
collect label values colname _cons "Constant", modify
collect style header result[_r_se _r_b], level(hide)
collect style cell result[_r_se], sformat("(%s)")
collect style showbase off
*collect style row stack, spacer delimiter(" x ")
collect style cell cell_type[column-header], halign(center) valign(center)

collect label drop cmdset	
collect label levels cmdset $`5'

local T=`T'+1
collect style putdocx, layout(autofitcontents)               ///
title("Table `T': `1' Regression Model for `2'")
putdocx collect

/*
//Marginal
collect set mar_`2'_`j'_`1'_`4'
collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
collect label values colname _cons "Constant", modify
collect style header result[_r_se _r_b], level(hide)
collect style cell result[_r_se], sformat("(%s)")
collect style showbase off
*collect style row stack, spacer delimiter(" x ")
collect style cell cell_type[column-header], halign(center) valign(center)

collect label drop cmdset	
collect label levels cmdset $`5'

local T=`T'+1
collect style putdocx, layout(autofitcontents)               ///
title("Table `T': `1' Marginal effect for `2'")
putdocx collect


//Generating the Combined Marginal table

collect combine comb_`2'_`j'_`1'_`4' = reg_`2'_`j'_`1'_`4' mar_`2'_`j'_`1'_`4'
collect set comb_`2'_`j'_`1'_`4'
collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
collect label values colname _cons "Constant", modify
collect style header result[_r_se _r_b], level(hide)
collect style cell result[_r_se], sformat("(%s)")
collect style showbase off
*collect style row stack, spacer delimiter(" x ")
collect style cell cell_type[column-header], halign(center) valign(center)

collect label drop cmdset	
collect label levels cmdset $`5'

local T=`T'+1
collect style putdocx, layout(autofitcontents)               ///
title("Table `T': `1' Combined Marginal effect for `2'")
putdocx collect

collect drop comb_`2'_`j'_`1'_`4' mar_`2'_`j'_`1'_`4'
*/

collect drop reg_`2'_`j'_`1'_`4'

end

////////////////////////////// Incomplete command has certain problems needs a better table layout 

capture program drop coll_exp
program define coll_exp

local i=0
local j=0

foreach y in $dep_var_list { 

local j=`j'+1
//Generating text for Collinearity Test 

collect create Collinearity_Test_`y'_`j'

local T=`T'+1  // Accounting for the Collinearity Table 

reg `y' $collin_vars  

collect: estat vif
local vc=0

foreach collin_var in $collin_vars {
    
local vc= `vc' + 1 //counter for varaibles 


collect recode result vif_`vc'  = "`:var label `collin_var''"
global vif_values_list $vif_values_list "`:var label `collin_var''"


}


}

collect layout (result[ $vif_values_list ]) (cmdset)  
collect style cell result[ $vif_values_list ], nformat(%8.3f)  
collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
//collect label values colname $collin_val_list , modify
*collect style header result[_r_se _r_b], level(hide)
*collect style cell result[_r_se], sformat("(%s)")
*collect style showbase off
**collect style row stack, spacer delimiter(" x ")
collect style cell cell_type[column-header], halign(center) valign(center)
collect label levels cmdset 1 "VIF" 2 "Tolerance"

local T=`T'+1
collect style putdocx, layout(autofitcontents)               ///
title("Table `T': Collinearity Test")
putdocx collect

end



////////////////////////////////////////////////////////////

capture program drop msub_cmexport
program define msub_cmexport

local i=0
local j=0
 

local j=`j'+1

**# Subsample 1
collect create reg_`2'_`j'_`1'_m`4'
collect create mar_`2'_`j'_`1'_m`4'

local vp=1 
foreach c in $`4' { 

collect set reg_`2'_`j'_`1'_m`4'
collect: $`7' `1' `2' $`:word `vp' of $`3'' if `c' == 1 $`6'


//collect set mar_`2'_`j'_`1'_m`4'				//compute and collect marginal effects
//collect: margins, dydx(*)

local i=`i'+ 1
local vp=`vp'+1 
}
// end of loop over the subsamples

**# layout for supsample tables

collect set reg_`2'_`j'_`1'_m`4'
collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
collect label values colname _cons "Constant", modify
collect style header result[_r_se _r_b], level(hide)
collect style cell result[_r_se], sformat("(%s)")
collect style showbase off
*collect style row stack, spacer delimiter(" x ")
collect style cell cell_type[column-header], halign(center) valign(center)

collect label drop cmdset	
collect label levels cmdset $`5'

local T=`T'+1
collect style putdocx, layout(autofitcontents)               ///
title("Table `T': `1' Regression Model for `2'")
putdocx collect

/*
//Marginal
collect set mar_`2'_`j'_`1'_`4'
collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
collect label values colname _cons "Constant", modify
collect style header result[_r_se _r_b], level(hide)
collect style cell result[_r_se], sformat("(%s)")
collect style showbase off
*collect style row stack, spacer delimiter(" x ")
collect style cell cell_type[column-header], halign(center) valign(center)

collect label drop cmdset	
collect label levels cmdset $`5'

local T=`T'+1
collect style putdocx, layout(autofitcontents)               ///
title("Table `T': `1' Marginal effect for `2'")
putdocx collect


//Generating the Combined Marginal table

collect combine comb_`2'_`j'_`1'_`4' = reg_`2'_`j'_`1'_`4' mar_`2'_`j'_`1'_`4'
collect set comb_`2'_`j'_`1'_`4'
collect layout (colname#result[_r_b _r_se] result[N r2_a r2_p ll]) (cmdset)  
collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach (_r_b)  
collect style cell result[_r_se _r_b r2_a], nformat(%8.3f)  
collect style cell, font(Arial,size(9)) border(right, pattern(nil)) halign(left) valign(center)
collect label values colname _cons "Constant", modify
collect style header result[_r_se _r_b], level(hide)
collect style cell result[_r_se], sformat("(%s)")
collect style showbase off
*collect style row stack, spacer delimiter(" x ")
collect style cell cell_type[column-header], halign(center) valign(center)

collect label drop cmdset	
collect label levels cmdset $`5'

local T=`T'+1
collect style putdocx, layout(autofitcontents)               ///
title("Table `T': `1' Combined Marginal effect for `2'")
putdocx collect

collect drop comb_`2'_`j'_`1'_`4' mar_`2'_`j'_`1'_`4'
*/

collect drop reg_`2'_`j'_`1'_m`4'

end

//////////////////////////////