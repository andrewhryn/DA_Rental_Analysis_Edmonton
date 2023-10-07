## select data for project
SELECT *
FROM `edmonton_crime_2009-2019`
ORDER BY 1,3;

##check if the datatype is correct
describe `edmonton_crime_2009-2019`

## All Occurrences from 2009 to 2019
SELECT `Neighbourhood`, COUNT('# Occurrences') as `Total_for_10_years`
FROM `edmonton_crime_2009-2019`
GROUP BY Neighbourhood;

## list all possible types of crimes
SELECT `Occurrence Violation Type Group`
FROM `edmonton_crime_2009-2019`
GROUP BY `Occurrence Violation Type Group`

## aggregate whole table by total for each violation type in all districts
SELECT `Neighbourhood`, `Occurrence Violation Type Group`, SUM(`# Occurrences`) as TOTAL
FROM `edmonton_crime_2009-2019`
GROUP BY `Neighbourhood`, `Occurrence Violation Type Group`
ORDER BY `Neighbourhood`;

## aggregate whole table by total for each violation type for every year in all districts
SELECT `Neighbourhood`, `Occurrence Reported Year`, `Occurrence Violation Type Group`, SUM(`# Occurrences`) as TOTAL
FROM `edmonton_crime_2009-2019`
GROUP BY `Neighbourhood`, `Occurrence Violation Type Group`, `Occurrence Reported Year`
ORDER BY `Neighbourhood`;


## Joint 2 tables by big zone ID
SELECT `Rent Zone`, `Zone ID`
FROM big_zones
LEFT JOIN rent_summary_new
ON big_zones.`Rent Zone` = rent_summary_new.`Zone ID`

## Joint 2 tables by big zone ID and show all data
SELECT *
FROM big_zones
LEFT JOIN rent_summary_new
ON big_zones.`Rent Zone` = rent_summary_new.`Zone ID`

## Joint crime and zone tables and save table as new
CREATE TABLE New
AS
SELECT *
FROM big_zones
LEFT JOIN `edmonton_crime_2009-2019`
ON big_zones.`UpperName` = `edmonton_crime_2009-2019`.`Neighbourhood`

## Find total crimes by district name
CREATE TABLE total_per_district
AS
SELECT `Rent Zone`, `Name`, SUM(`# Occurrences`) as TOTAL
FROM New
GROUP BY `Rent Zone`, `Name`
ORDER BY `Name`

## Remove all Null values from total column and save as v2
CREATE TABLE total_per_district_v2
AS
SELECT *
FROM total_per_district
DELETE FROM total_per_district
WHERE TOTAL IS NULL;

## Select apartments and order by zone
CREATE TABLE rent_summary_v2
AS
SELECT `Zone ID`, `Zone`, Price
FROM rent_summary_new
WHERE `Property Type` = "Appartment"
ORDER BY `Zone ID`

## Find column type (price is stored as text instead of int)
describe rent_summary_v2

## Convert string price to integer so we can find AVG in next step
CREATE TABLE rent_summary_v3
AS
SELECT `Zone ID`, `Zone`, CAST(REPLACE(Price, ',', '') AS SIGNED ) AS PriceNumber
FROM rent_summary_v2

## Save table with average apartment price per zone ID
CREATE TABLE average_by_zone
AS
SELECT `Zone ID`, AVG(PriceNumber) AS AveragePrice
FROM rent_summary_v3
GROUP BY `Zone ID`;

##Combine total crime sheet and average price sheet by zone key
CREATE Table Districts_Top
    AS
SELECT `Zone ID` as Zone, `Name`, `AveragePrice`, `TOTAL` as Total_crime
FROM average_by_zone
LEFT JOIN total_per_district_v2
ON average_by_zone.`Zone ID` = total_per_district_v2.`Rent Zone`

## find best district by price/crime ratio

SELECT *
FROM Districts_Top
ORDER BY AveragePrice, Total_crime


## Create table per every bedroom type
CREATE TABLE All_types
    AS
SELECT `Zone ID`, `Zone`, Price, Bedrooms
FROM rent_summary_new
WHERE `Property Type` = "Appartment"
ORDER BY `Zone ID`

#Do the same thing but for every bedroom type
CREATE TABLE all_types_v2
AS
SELECT `Zone ID`, `Zone`, `Bedrooms`,  CAST(REPLACE(Price, ',', '') AS SIGNED ) AS PriceNumber
FROM All_types
ORDER BY `Zone ID`, `Bedrooms`

## Joint crime sheet and price sheet
Create table rank_per_district
    AS
SELECT `Zone ID` as Zone, `Name`, `PriceNumber`, `TOTAL` as Total_crime, Bedrooms
FROM all_types_v2
LEFT JOIN total_per_district_v2
ON all_types_v2.`Zone ID` = total_per_district_v2.`Rent Zone`

## Top Districts for Studio rent
SELECT `Name` as `District name`, PriceNumber as `Avarage Price`, Total_crime as `Crimes for 10 years`, Bedrooms
FROM rank_per_district
WHERE Bedrooms = "Studio"
ORDER BY PriceNumber, Total_crime

## Top Districts for 1 Bedroom rent
SELECT `Name` as `District name`, PriceNumber as `Avarage Price`, Total_crime as `Crimes for 10 years`, Bedrooms
FROM rank_per_district
WHERE Bedrooms = "1 Bedroom"
ORDER BY PriceNumber, Total_crime

## Top Districts for 2 Bedroom rent
SELECT `Name` as `District name`, PriceNumber as `Avarage Price`, Total_crime as `Crimes for 10 years`, Bedrooms
FROM rank_per_district
WHERE Bedrooms = "2 Bedroom"
ORDER BY PriceNumber, Total_crime

## Top Districts for 3+ Bedroom rent
SELECT `Name` as `District name`, PriceNumber as `Avarage Price`, Total_crime as `Crimes for 10 years`, Bedrooms
FROM rank_per_district
WHERE Bedrooms = "3 Bedroom +"
ORDER BY PriceNumber, Total_crime