cd "/Users/jaromyoung/Library/CloudStorage/Box-Box/ECON 388/Data Assignment 3"
*cd "C:\Users\jaromsy\Box\ECON 388\Data Assignment 3"
*log using data3.log, replace

***RENAMING COUNTRIES***
use chat, clear
tab country
use pwt1001, clear
tab country
replace country = "South Korea" if country == "Republic of Korea"
replace country = "Iran" if country == "Iran (Islamic Republic of)"
replace country = "Venezuela" if country == "Venezuela (Bolivarian Republic of)"
replace country = "Tanzania" if country == "U.R. of Tanzania: Mainland"
replace country = "Palestine" if country == "State of Palestine"
replace country = "Sint Maarten" if country == "Sint Maarten (Dutch part)"
replace country = "Russia" if country == "Russian Federation"
replace country = "Moldova" if country == "Republic of Moldova"
replace country = "Laos" if country == "Lao People's DR"
replace country = "Bolivia" if country == "Bolivia (Plurinational State of)"
replace country = "Hong Kong" if country == "China, Hong Kong SAR"
replace country = "Macao" if country == "China, Macao SAR"
replace country = "Syria" if country == "Syrian Arab Republic"
replace country = "Vietnam" if country == "Viet Nam"
*gen gdpcapita = rgdpna/pop
save pwt1001, replace

use chat, clear
tab country
*rename country_name country
replace country = "D.R. of the Congo" if country == "Democratic Republic of the Congo"
replace country = "Slovakia" if country == "Slovak Republic"
replace country = "Bosnia and Herzegovina" if country == "Bosnia-Herzegovina"
replace country = "Côte d'Ivoire" if country == "Ivory Coast"
replace country = "Eswatini" if country == "Swaziland"
replace country = "Myanmar" if country == "Burma"
destring railline, replace ignore(",") force
save chat, replace

***RESHAPE WIDE***
use pwt1001, clear
collapse (mean) gdpcapita pop, by (country year)
reshape wide gdpcapita pop, i(country) j(year)
save gdpcollapse, replace

use chat, clear
collapse (mean) computer vehicle_car telephone ag_tractor railline, by (country year)
reshape wide computer vehicle_car telephone ag_tractor railline, i(country) j(year)
save techcollapse, replace

***GROWTH VARS***
use gdpcollapse, clear
forvalues i=1970/1999{
	local j= `i'+1
	gen gdp_growth`i' = ((gdpcapita`j' / gdpcapita`i') - 1)*100
}
save gdpcollapse, replace

use techcollapse, clear
forvalues i=1970/1999{
	local j= `i'+1
	gen computer_growth`i' = ((computer`j' / computer`i') - 1)*100
}
forvalues i=1970/1999{
	local j= `i'+1
	gen car_growth`i' = ((vehicle_car`j' / vehicle_car`i') - 1)*100
}
forvalues i=1970/1999{
	local j= `i'+1
	gen phone_growth`i' = ((telephone`j' / telephone`i') - 1)*100
}
forvalues i=1970/1999{
	local j= `i'+1
	gen tractor_growth`i' = ((ag_tractor`j' / ag_tractor`i') - 1)*100
}
forvalues i=1970/1999{
	local j= `i'+1
	gen rail_growth`i' = ((railline`j' / railline`i') - 1)*100
}
save techcollapse, replace

***RESHAPE LONG***
use gdpcollapse, clear
reshape long gdpcapita gdp_growth pop, i(country) j(year)
save gdplong, replace

use techcollapse, clear
reshape long computer computer_growth vehicle_car car_growth telephone phone_growth ag_tractor tractor_growth railline rail_growth, i(country) j(year)
save techlong, replace

***MERGE***
use gdplong, clear
merge 1:1 country year using techlong
tab _merge
keep if _merge == 3
drop _merge
*rename vehicle_car car
*rename rgdpna gdp
save devmerge, replace

***COLLAPSING GROWTH***
gen developed = 0
replace developed = 1 if inlist(country, "France", "Germany", "Italy", "Japan", "United Kingdom", "United States")

collapse (mean) gdp_growth computer_growth car_growth phone_growth tractor_growth rail_growth pop [weight=pop], by(developed year)
drop if year < 1970 | year > 1999

***VISUALIZATION***
*TABLE
sum gdp_growth car_growth computer_growth phone_growth tractor_growth rail_growth 

*CAR GROWTH IF DEVELOPED
twoway ///
    scatter gdp_growth car_growth if developed == 1, msymbol(circle) mcolor(blue) ///
    || lfit gdp_growth car_growth if developed == 1, lcolor(blue) ///
	legend(off) ///
    title("GDP Growth vs. Car Growth (Developed Nations)") ///
    xtitle("Car Growth Rate") ///
    ytitle("GDP Growth Rate")

*CAR GROWTH IF UNDEVELOPED
twoway ///
    scatter gdp_growth car_growth if developed == 0, msymbol(circle) mcolor(blue) ///
    || lfit gdp_growth car_growth if developed == 0, lcolor(blue) ///
	legend(off) ///
    title("GDP Growth vs. Car Growth (Undeveloped Nations)") ///
    xtitle("Car Growth Rate") ///
    ytitle("GDP Growth Rate")
	
***ANALYSIS***

reg gdp_growth computer_growth car_growth phone_growth tractor_growth rail_growth 

reg gdp_growth computer_growth car_growth phone_growth tractor_growth rail_growth if developed == 1

reg gdp_growth computer_growth car_growth phone_growth tractor_growth rail_growth if developed == 0

save development, replace

