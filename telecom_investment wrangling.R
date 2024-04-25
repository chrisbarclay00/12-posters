#Telecom Investment Data Wrangling

library(tidyverse)
library(readr)
library(knitr)
library(kableExtra)
library(haven)
library(readxl)
library(lubridate)
library(patchwork)

#Data taken from the ITU's "DataHub — https://datahub.itu.int/"

#Annual investment in telecommunication services (https://datahub.itu.int/data/?i=372)
#Level of Competition -> International Gateways (https://datahub.itu.int/data/?i=100045&s=2653)


#Datasets & Variables
## telecom_competition: entityID (rename: id), entityName (rename: country), dataValue (rename: competition_level), dataYear (rename: year)
## telecom_investment: id, country, investment_usd, year


#Telecom Competition
telecom_competition <- read_csv('level-of-competition_1713656130636.csv') |>
  rename(id = entityID, code = entityIso, country = entityName, series = seriesName, competition_level = dataValue, year = dataYear) |>
  mutate(
    competition_level = recode(competition_level, "Partial competition (year when competition was introduced)" = "Partial competition"),
    competition_level = recode(competition_level, "Full competition (year when competition was introduced)" = "Full competition"),
    competition_level = na_if(competition_level, "N/A") #replaces "N/A" with NA
  ) |>
  select(id, code, country, series, competition_level, year)

#Telecom Investment
telecom_investment <- read_csv('annual-investment-in-telecommunication-services_1713656379641.csv') |>
  rename(id = entityID, code = entityIso, country = entityName, annual_telecom_invest = dataValue, year = dataYear) |>
  select(id, code, country, annual_telecom_invest, year)

#Telecom Foreign Investment

telecom_foreign_investment <- read_csv('annual-foreign-investment-in-telecommunications_1713840182234.csv') |>
  rename(id = entityID, code = entityIso, country = entityName, annual_telecom_invest = dataValue, year = dataYear) |>
  select(id, code, country, annual_telecom_invest, year)



#Ease of Business

eab = read_dta('Historical-data.dta') |>
  rename(code = cod, country = economy, year = dbyear, permit_time = permittime, 
         permit_cost = permitcostWhV, electricity_cost = electricitycost, 
         electricity_min_outage_time = electricityMinimumOutage, 
         register_time = registertime, register_cost = registercost,
         contracts_time = contractstime, contracts_cost = contractscost,
         taxes_total = taxestotal) |> #renames variables
  select(code, country, incomegroup, year, startbuscapital, 
         investorsdisclosure, investorsliability, permit_time,
         electricity_cost, electricity_min_outage_time, register_time,
         register_cost, contracts_time, contracts_cost, taxes_total
  )

#Economic Strength
    ##data is from the IMF 
      ##https://www.imf.org/external/datamapper/NGDPDPC@WEO/OEMDC/ADVEC/WEOWORLD
      ##https://www.imf.org/external/datamapper/NGDPD@WEO/OEMDC/ADVEC/WEOWORLD

gdp_per_cap <- read_excel('imf-dm-export-20240421.xls') |>
  rename(country = 1) |>
  pivot_longer(
    cols = 2:51,
    names_to = 'year',
    names_transform = list(Year = as.integer),
    values_to = 'gdp_per_cap'
  ) |>
  mutate(
    year = as.integer(year), #IMF tried to sneakily put year as a char. var,
    country = recode(country, "Bahamas, The" = "Bahamas"),
    country = recode(country, "Bolivia (Plurinational State of)" = "Bolivia"),
    country = recode(country, "Central African Rep." = "Central African Republic"),
    country = recode(country, "Dem. Rep. of the Congo" = "Congo, Dem. Rep. of the"),
    country = recode(country, "Congo (Rep. of the)" = "Congo, Republic of"),
    country = recode(country, "Dominican Rep." = "Dominican Republic"),
    country = recode(country, "Equatorial Guinea" = "Guinea"),
    country = recode(country, "Gambia, The" = "Gambia"),
    country = recode(country, "Hong Kong SAR" = "Hong Kong"),
    country = recode(country, "Korea, Republic of" = "South Korea"),
    country = recode(country, "Kyrgyz Republic" = "Kyrgyzstan"),
    country = recode(country, "Macao SAR" = "Macao"),
    country = recode(country, "Micronesia, Fed. States of" = "Micronesia"),
    country = recode(country, "West Bank and Gaza" = "Palestine"),
    country = recode(country, "São Tomé and Príncipe" = "Sao Tome and Principe"),
    country = recode(country, "Slovak Republic" = "Slovakia"),
    country = recode(country, "South Sudan, Republic of" = "South Sudan"),
    country = recode(country, "Taiwan Province of China" = "Taiwan"),
    country = recode(country, "Türkiye, Republic of" = "Turkey")) |>
  filter(year <= 2022,
         country != "Bermuda" & 
         country != "British Virgin Islands" &
         country != "Cayman Islands" &
         country != "Cuba" &
         country != "Africa (Region)" &  
         country != "Asia and Pacific" &                        
         country != "Australia and New Zealand" &              
         country != "Caribbean" &                               
         country != "Central America" &                         
         country != "Central Asia and the Caucasus" &          
         country != "East Asia" &                              
         country != "Eastern Europe" &                 
         country != "Europe" &                                
         country != "Middle East (Region)" &                    
         country != "North Africa" &                            
         country != "North America" &                           
         country != "Pacific Islands" &                         
         country != "South America" &                           
         country != "South Asia" &                             
         country != "Southeast Asia" &                      
         country != "Sub-Saharan Africa (Region)" &          
         country != "Western Europe" &             
         country != "Western Hemisphere (Region)" &          
         country != "ASEAN-5" &                            
         country != "Advanced economies" &                 
         country != "Emerging and Developing Asia" &       
         country != "Emerging and Developing Europe" &    
         country != "Emerging market and developing economies" &
         country != "Euro area" &                        
         country != "European Union" &                     
         country != "Latin America and the Caribbean" &        
         country != "Major advanced economies (G7)" &        
         country != "Middle East and Central Asia" &          
         country != "Other advanced economies" &               
         country != "Sub-Saharan Africa" &                   
         country != "World" &                               
         country != "©IMF, 2024"
        )

gdp_total <- read_excel('gdptotal.xls') |>
  rename(country = 1) |>
  pivot_longer(
    cols = 2:51,
    names_to = 'year',
    names_transform = list(year = as.integer),
    values_to = 'gdp_total_bil'
  ) |>
  mutate(
    year = as.integer(year), #IMF tried to sneakily put year as a char. var,
    country = recode(country, "Bahamas, The" = "Bahamas"),
    country = recode(country, "Bolivia (Plurinational State of)" = "Bolivia"),
    country = recode(country, "Central African Rep." = "Central African Republic"),
    country = recode(country, "Dem. Rep. of the Congo" = "Congo, Dem. Rep. of the"),
    country = recode(country, "Congo (Rep. of the)" = "Congo, Republic of"),
    country = recode(country, "Dominican Rep." = "Dominican Republic"),
    country = recode(country, "Equatorial Guinea" = "Guinea"),
    country = recode(country, "Gambia, The" = "Gambia"),
    country = recode(country, "Hong Kong SAR" = "Hong Kong"),
    country = recode(country, "Korea, Republic of" = "South Korea"),
    country = recode(country, "Kyrgyz Republic" = "Kyrgyzstan"),
    country = recode(country, "Macao SAR" = "Macao"),
    country = recode(country, "Micronesia, Fed. States of" = "Micronesia"),
    country = recode(country, "West Bank and Gaza" = "Palestine"),
    country = recode(country, "São Tomé and Príncipe" = "Sao Tome and Principe"),
    country = recode(country, "Slovak Republic" = "Slovakia"),
    country = recode(country, "South Sudan, Republic of" = "South Sudan"),
    country = recode(country, "Taiwan Province of China" = "Taiwan"),
    country = recode(country, "Türkiye, Republic of" = "Turkey")) |>
  filter(year <= 2022,
         country != "Bermuda" & 
           country != "British Virgin Islands" &
           country != "Cayman Islands" &
           country != "Cuba" &
           country != "Africa (Region)" &  
           country != "Asia and Pacific" &                        
           country != "Australia and New Zealand" &              
           country != "Caribbean" &                               
           country != "Central America" &                         
           country != "Central Asia and the Caucasus" &          
           country != "East Asia" &                              
           country != "Eastern Europe" &                 
           country != "Europe" &                                
           country != "Middle East (Region)" &                    
           country != "North Africa" &                            
           country != "North America" &                           
           country != "Pacific Islands" &                         
           country != "South America" &                           
           country != "South Asia" &                             
           country != "Southeast Asia" &                      
           country != "Sub-Saharan Africa (Region)" &          
           country != "Western Europe" &             
           country != "Western Hemisphere (Region)" &          
           country != "ASEAN-5" &                            
           country != "Advanced economies" &                 
           country != "Emerging and Developing Asia" &       
           country != "Emerging and Developing Europe" &    
           country != "Emerging market and developing economies" &
           country != "Euro area" &                        
           country != "European Union" &                     
           country != "Latin America and the Caribbean" &        
           country != "Major advanced economies (G7)" &        
           country != "Middle East and Central Asia" &          
           country != "Other advanced economies" &               
           country != "Sub-Saharan Africa" &                   
           country != "World" &                               
           country != "©IMF, 2024"
  )

#Institutional Fortitude

#gov_effective <- read_excel('wgidataset.xlsx')
#Unfortunately ran out of time to add in the Institutional Fortitude bit -- may add in later


#Merging & Adding Variables

## telecom_investment + telecom_competition
df = 
  left_join(
    telecom_investment, 
    telecom_competition,
    by = join_by(id, code, country, year)
    ) |>
  mutate(
    annual_telecom_invest_mil = annual_telecom_invest/1e+6,
    annual_telecom_invest_bil = annual_telecom_invest/1e+9
         ) |>
  select(-annual_telecom_invest)
df <- df[order(df$country),] #this made it easier for me to compare IMF data and homogenize/rename country names etc.

df = df |>
  mutate(country = recode(country, "China, People's Republic of" = "China"),
         country = recode(country, "Hong Kong, China" = "Hong Kong"),
         country = recode(country, "Iran (Islamic Republic of)" = "Iran"),
         country = recode(country, "Korea (Rep. of)" = "South Korea"),
         country = recode(country, "Nepal (Republic of)" = "Nepal"),
         country = recode(country, "Macao, China" = "Macao"),
         country = recode(country, "Taiwan, Province of China" = "Taiwan"),
         country = recode(country, "Russian Federation" = "Russia"),
         country = recode(country, "State of Palestine" = "Palestine"),
         country = recode(country, "Syrian Arab Republic" = "Syria"),
         country = recode(country, "Türkiye" = "Turkey"),
         country = recode(country, "Viet Nam" = "Vietnam")) #having to rename some country names ad hoc after merging... sorry for messy R code :/
  

## +eab data

df2 =
  left_join(
    df, 
    eab,
    by = join_by(code, country, year)
  )

## merging gdp_per_cap and gdp_total into 'gdp'

gdp = 
  left_join(
    gdp_per_cap, 
    gdp_total,
    by = join_by(country, year)
  )

## merging 'gdp' and df2 together --> final dataset

telecom =
  left_join(
    df2, 
    gdp,
    by = join_by(country, year)
  ) |> 
  mutate(
    permit_time = as.character(permit_time),
    electricity_cost = as.character(electricity_cost),
    electricity_min_outage_time = as.character(electricity_min_outage_time), #have to change to character in order for the next steps (changing NA's) to work
    gdp_total_bil = na_if(gdp_total_bil, "no data"), #replaces "no data" with NA
    gdp_per_cap = na_if(gdp_per_cap, "no data"),
    permit_time = na_if(permit_time, "-9999"),
    permit_time = na_if(permit_time, "-333"),
    permit_time = na_if(permit_time, "-222"),
    permit_time = na_if(permit_time, "-111"),
    permit_time = na_if(permit_time, "-4"),
    permit_time = na_if(permit_time, "-3"),
    permit_time = na_if(permit_time, "-2"), # this is bad practice (getting rid of the codes), but I must finish the assignment
    electricity_cost = na_if(electricity_cost, "-9999"),
    electricity_cost = na_if(electricity_cost, "-333"),
    electricity_cost = na_if(electricity_cost, "-222"),
    electricity_cost = na_if(electricity_cost, "-111"),
    electricity_cost = na_if(electricity_cost, "-4"),
    electricity_cost = na_if(electricity_cost, "-3"),
    electricity_cost = na_if(electricity_cost, "-2"),
    electricity_min_outage_time = na_if(electricity_min_outage_time, "-9999"),
    electricity_min_outage_time = na_if(electricity_min_outage_time, "-333"),
    electricity_min_outage_time = na_if(electricity_min_outage_time, "-222"),
    electricity_min_outage_time = na_if(electricity_min_outage_time, "-111"),
    electricity_min_outage_time = na_if(electricity_min_outage_time, "-4"),
    electricity_min_outage_time = na_if(electricity_min_outage_time, "-3"),
    electricity_min_outage_time = na_if(electricity_min_outage_time, "-2"),
    permit_time = as.numeric(permit_time),
    electricity_cost = as.numeric(electricity_cost),
    electricity_min_outage_time = as.numeric(electricity_min_outage_time),
  ) |> #a little bit of last-minute cleaning..
  relocate(id, country, year, gdp_total_bil, gdp_per_cap, annual_telecom_invest_mil, annual_telecom_invest_bil, series, competition_level)

#Final telecom.csv Data

write_csv(telecom, 'telecom.csv')




#Adding Foreign Direct Investment Data:

telecom_fdi =
  left_join(
    telecom, 
    telecom_foreign_investment,
    by = join_by(country, year)
  )
write_csv(telecom_fdi, 'telecomfdi.csv')





#Summary Stats (looking at the data)

summary(telecom)
hist(telecom$year)

table(telecom$country, exclude = NULL) |>
  as.data.frame() |>
  arrange(desc(Freq))
table(telecom$series) |>
  as.data.frame() |>
  arrange(desc(Freq))


# Graphs:

## Data

summary(telecom)
hist(telecom$year)

table(telecom$country, exclude = NULL) |>
  as.data.frame() |>
  arrange(desc(Freq))

series_freq =
  table(telecom$series) |>
  as.data.frame() |>
  na.omit() |>
  mutate(percent = Freq/sum(Freq) * 100) |>
  arrange(desc(Freq))
kable(series_freq)


freq_country_top10 = df |>
  count(year) |>
  na.omit() |>
  mutate(percent = n/sum(n) * 100) |>
  select(year, percent)

## Main Findings




