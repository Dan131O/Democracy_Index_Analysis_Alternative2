-- Author: Daniel Ourinson
-- Date: 09/02/2025

-- "POSTGRESQL PART" OF THE SECOND VERSION OF THE DATA ANALYSIS OF THE DEMOCRACY INDEX


--
-- STEP 1: CLEAN DATASETS 
--


-- CLEAN THE DEMOCRACY INDEX TABLE

-- Drop the table 'democracy_index_cleaned' if it already exists to avoid conflicts 
DROP TABLE IF EXISTS democracy_index_cleaned;

-- Create a cleaned version of the democracy index table, starting with just mimicing the democracy index table
CREATE TABLE democracy_index_cleaned AS
SELECT * FROM democracy_index;

-- Remove the "Code" column from the "democracy_index_cleaned" table 
ALTER TABLE democracy_index_cleaned
DROP COLUMN "Code";

-- Rename the "Entity" column to "Country" 
ALTER TABLE democracy_index_cleaned
RENAME COLUMN "Entity" TO "Country";

-- Rename the "Democracyscore" column to "Democracy_Index"
ALTER TABLE democracy_index_cleaned
RENAME COLUMN "Democracyscore" TO "Democracy_Index";

-- Delete the rows of the table 'democracy_index_cleaned' where column "country" has the entries 'North America' and 'World' since they do not represent countries
DELETE FROM democracy_index_cleaned
WHERE "Country" = 'North America';
DELETE FROM democracy_index_cleaned
WHERE "Country" = 'World';

-- Add a new column "Type" to the table 'democracy_index_cleaned' in string format to classify countries into regime types based on their democracy index
ALTER TABLE democracy_index_cleaned 
ADD COLUMN "Type" VARCHAR(50);

-- Update the "Type" column with regime type classifications based on the range of "Democracy_Index" values
UPDATE democracy_index_cleaned
SET "Type" = 
  CASE
    WHEN "Democracy_Index" >= 0 AND "Democracy_Index" < 4 THEN 'Authoritarian Regime' 	-- Scores 0-4: Authoritarian Regime
    WHEN "Democracy_Index" >= 4 AND "Democracy_Index" < 6 THEN 'Hybrid Regime'			-- Scores 4-6: Hybrid Regime
	WHEN "Democracy_Index" >= 6 AND "Democracy_Index" < 8 THEN 'Flawed Democracy'		-- Scores 6-8: Flawed Democracy
    WHEN "Democracy_Index" >= 8 AND "Democracy_Index" <= 10 THEN 'Full Democracy'		-- Scores 8-10: Full Democracy
  END;


-- CLEAN THE POPULATIONS TABLE

-- Drop the 'population_2023_cleaned' table if it already exists to avoid conflicts
DROP TABLE IF EXISTS population_2023_cleaned;

-- Create a cleaned version of the population table with only relevant columns by using a temporary processing table to clean and extract relevant data
CREATE TABLE population_2023_cleaned AS
WITH population_temp AS (													-- Step 1: Create a temporary table to extract the "Country" column
    SELECT *, 
			SPLIT_PART("CountryNameCountryCode", ',', 1) AS "Country"		-- Extract the country name, which is before the comma of the "CountryNameCountryCode" column in the 'population' table
    FROM population
),
population_temp2 AS (														-- Step 2: Create another temporary table with the "Country" and "2023" population
    SELECT "Country", "2023"												-- Select only the "Country" and "2023" columns for cleaning
    FROM population_temp
)
SELECT * 																	-- Step 3: Finalize the table with cleaned data
FROM population_temp2;


-- Rename the "2023" column to "Population"
ALTER TABLE population_2023_cleaned
RENAME COLUMN "2023" TO "Population";

-- Remove any double quotes in the "Country" and "Population" columns
UPDATE population_2023_cleaned
SET "Country" = REPLACE("Country", '"', '');
UPDATE population_2023_cleaned
SET "Population" = REPLACE("Population", '"', '');

-- Convert the "Population" column from string to integer type, handling empty strings as NULL during the conversion
ALTER TABLE population_2023_cleaned
ALTER COLUMN "Population" TYPE BIGINT USING NULLIF("Population", '')::bigint;

 
-- CLEAN THE PRESS FREEDOM TABLE

DROP TABLE IF EXISTS press_freedom_2023_cleaned;

-- Create a cleaned version of the press freedom table with only relevant columns 
CREATE TABLE press_freedom_2023_cleaned AS
SELECT "Country_EN","Score"
FROM press_freedom;

-- Rename columns 
ALTER TABLE press_freedom_2023_cleaned
RENAME COLUMN "Country_EN" TO "Country";
ALTER TABLE press_freedom_2023_cleaned
RENAME COLUMN "Score" TO "Press_Freedom_Score";

-- Replace commas with dots to ensure numeric consistency
UPDATE press_freedom_2023_cleaned
SET "Press_Freedom_Score" = REPLACE("Press_Freedom_Score", ',', '.');

-- Convert the press freedom scores from text to float type, handling empty strings as NULL during the conversion
ALTER TABLE press_freedom_2023_cleaned
ALTER COLUMN "Press_Freedom_Score" TYPE FLOAT USING NULLIF("Press_Freedom_Score", '')::float;


-- CLEAN THE LIFE EXPECTANCY TABLE 

DROP TABLE IF EXISTS life_expectancy_2022_cleaned;

-- Create a cleaned version of the life expectancy table with only relevant columns by using a temporary processing table to clean and extract relevant data
CREATE TABLE life_expectancy_2022_cleaned AS
WITH life_expectancy_temp AS (												-- Step 1: Create a temporary table to extract the countries
    SELECT *, SPLIT_PART("CountryNameCountryCode", ',', 1) AS "Country"		-- Extract the country name, which is before the comma of the "CountryNameCountryCode" column in the 'life_expectancy' table
    FROM life_expectancy
),
life_expectancy_temp2 AS (													-- Step 2: Create another temporary table with the columns for countries and life expectancies of 2022
    SELECT "Country", "2022"												-- Select only the above mentioned columns 
    FROM life_expectancy_temp
)
SELECT * FROM life_expectancy_temp2;										-- Step 3: Finalize the table with cleaned data

-- Rename colummns 
ALTER TABLE life_expectancy_2022_cleaned
RENAME COLUMN "2022" TO "Life_Exp";

-- Remove any double quotes 
UPDATE life_expectancy_2022_cleaned
SET "Country" = REPLACE("Country", '"', '');
UPDATE life_expectancy_2022_cleaned
SET "Life_Exp" = REPLACE("Life_Exp", '"', '');

-- Convert life expectancy data from string to float type, handling empty strings as NULL during the conversion 
ALTER TABLE life_expectancy_2022_cleaned
ALTER COLUMN "Life_Exp" TYPE FLOAT USING NULLIF("Life_Exp", '')::float;


-- CLEAN THE EDUCATION SPENDING TABLE 

DROP TABLE IF EXISTS education_2014_cleaned;

-- Create a cleaned version of the education table with only relevant data for the year 2014
CREATE TABLE education_2014_cleaned AS
SELECT "CountryName","2014YR2014"
FROM education
WHERE "Series" = 'Government expenditure on education as % of GDP (%)'; -- Here, education spending is classified as percentage of GDP spent on education

-- Rename columns
ALTER TABLE education_2014_cleaned
RENAME COLUMN "CountryName" TO "Country";
ALTER TABLE education_2014_cleaned
RENAME COLUMN "2014YR2014" TO "EDI";

-- Convert education spending data from string to float type, handling ".." as NULL during the conversion
ALTER TABLE education_2014_cleaned
ALTER COLUMN "EDI" TYPE FLOAT USING NULLIF("EDI", '..')::float;


--
-- STEP 2: JOIN TABLES
--

-- JOIN THE DEMOCRACY INDEX AND POPULATION TABLES

DROP TABLE IF EXISTS dem_pop_joined;

-- Create a new table by joining the cleaned tables for democracy index and population for the year 2023
CREATE TABLE dem_pop_joined AS
SELECT *
FROM democracy_index_cleaned
INNER JOIN population_2023_cleaned USING ("Country")	-- Join tables on the column "Country"
WHERE democracy_index_cleaned."Year" = 2023;			-- Filter for the year 2023

-- Drop unnecessary columns 
ALTER TABLE dem_pop_joined 
DROP COLUMN "Year";


-- JOIN THE DEMOCRACY INDEX AND PRESS FREEDOM SCORE TABLES

DROP TABLE IF EXISTS dem_press_joined;

-- Create a new table by joining the cleaned tables for democracy index and press freedom score for the year 2023
CREATE TABLE dem_press_joined AS
SELECT *
FROM democracy_index_cleaned
INNER JOIN press_freedom_2023_cleaned USING ("Country")	-- Join tables on the column "Country"
WHERE democracy_index_cleaned."Year" = 2023;			-- Filter for the year 2023

-- Drop unnecessary columns
ALTER TABLE dem_press_joined 
DROP COLUMN "Year";


-- JOIN THE DEMOCRACY INDEX AND LIFE EXPECTANCY TABLES
 
DROP TABLE IF EXISTS dem_le_joined;

-- Create a new table by joining the cleaned tables for democracy index and life expectancy for the year 2022
CREATE TABLE dem_le_joined AS
SELECT *
FROM democracy_index_cleaned
INNER JOIN life_expectancy_2022_cleaned USING ("Country") -- Join tables on the column "Country"
WHERE democracy_index_cleaned."Year" = 2022;			  -- Filter for the year 2022

-- Drop unnecessary columns
ALTER TABLE dem_le_joined 
DROP COLUMN "Year";

-- JOIN THE DEMOCRACY INDEX AND EDUCATION SPENDING TABLES

DROP TABLE IF EXISTS dem_edu_joined;

-- Create a new table by joining the cleaned tables for democracy index and education spending for the year 2014
CREATE TABLE dem_edu_joined AS
SELECT *
FROM democracy_index_cleaned
INNER JOIN education_2014_cleaned USING ("Country") -- Join tables on the column "Country"
WHERE democracy_index_cleaned."Year" = 2014;		-- Filter for the year 2014

-- Drop unnecessary columns
ALTER TABLE dem_edu_joined 
DROP COLUMN "Year";


--
-- STEP 3: COUNT THE NUMBER OF COUNTRIES AND POPULATIONS BY REGIME TYPES
--

-- Drop the following table if it already exists
DROP TABLE IF EXISTS countries_by_regime_types_2023;

-- Create a new table summarizing the count of countries in each regime type for the year 2023
CREATE TABLE countries_by_regime_types_2023 AS
SELECT "Type", COUNT(DISTINCT "Country") AS "Count"		-- Count the unique countries under each regime type
FROM democracy_index_cleaned
WHERE "Year" = 2023										-- Filter data for the year 2023
GROUP BY "Type";										-- Group results by democracy regime type


DROP TABLE IF EXISTS countries_by_regime_types_2006_to_2023;

-- Create a new table summarazing the count of countries in each regime type over multiple years (2006 to 2023)
CREATE TABLE countries_by_regime_types_2006_to_2023 AS
SELECT "Year",
		-- Count the countries for each regime type (separate columns) for each year. 
       COUNT(CASE WHEN "Type" = 'Authoritarian Regime' THEN "Country" END) AS "Authoritarian Regime", 
       COUNT(CASE WHEN "Type" = 'Hybrid Regime' THEN "Country" END) AS "Hybrid Regime",
       COUNT(CASE WHEN "Type" = 'Flawed Democracy' THEN "Country" END) AS "Flawed Democracy",
       COUNT(CASE WHEN "Type" = 'Full Democracy' THEN "Country" END) AS "Full Democracy"
FROM democracy_index_cleaned
GROUP BY "Year" 	-- Group results by year
ORDER BY "Year"; 	-- Order results chronologically 


DROP TABLE IF EXISTS population_by_regime_types_2023;

-- Create a new table summarizing the total population for each regime type in 2023
CREATE TABLE population_by_regime_types_2023 AS
SELECT "Type", 								-- Include the regime type
		SUM("Population") AS "Population"	-- Calculate the world population for each regime type 
FROM dem_pop_joined
GROUP BY "Type";							-- Group results by regime type



--
-- STEP 4: EXPLORING MINIMA AND MAXIMA OF PARAMETERS PER REGIME TYPE 
-- 

-- CREATE A TABLE WITH MINIMUM AND MAXIMUM PRESS FREEDOM SCORES FOR EACH REGIME TYPE

DROP TABLE IF EXISTS dem_press_minmax;

-- Create a new table to store the minimum and maximum press freedom scores for each regime type and insert the values later 
CREATE TABLE dem_press_minmax (
    "Regime Type" VARCHAR,               -- Regime type as string type
    "Min/Max" VARCHAR,                   -- Minimum or maximum value as string type
    "Press Freedom Score (%)" FLOAT,     -- Press freedom score as float type 
    "Country" VARCHAR,                   -- Country as string type
    "Democracy Index" FLOAT              -- Democracy index as float type 
);

-- Calculate the minimum and maximum press freedom scores for each regime type and insert them into the new table
WITH MinMaxPress AS (
	
	-- Subquery to calculate the minimum press freedom scores 
    SELECT 
        "Type" AS "Regime Type",                            										-- Regime Type
        'Min' AS "Min/Max",                                 										-- Tag for minimum values
        ROUND(CAST("Press_Freedom_Score" AS NUMERIC), 1) AS "Press Freedom Score (%)",  			-- Press freedom score rounded to one decimal
        "Country",                                          										-- Country
        ROUND(CAST("Democracy_Index" AS NUMERIC), 1) AS "Democracy Index"  							-- Democracy index rounded to one decimal
    FROM (																							-- Initiating a subquery here
        SELECT *,																					-- First, select all columns from 'dem_press_joined'
               ROW_NUMBER() OVER (PARTITION BY "Type" ORDER BY "Press_Freedom_Score" ASC) AS rn		-- Add a column with row numbers ordered by ascending press freedom scores for each regime type (by partioning by regime type)
        FROM dem_press_joined
    ) t																								-- t is the alias for the subquery above
    WHERE rn = 1																					-- Take only the row where the row number is 1, i.e. with the lowest press freedom score per regime type

    UNION ALL  -- Combine the results for minimum and maximum values
	
	-- Subquery to calculate the maximum press freedom scores: analogous calculation to the mimimum values
    SELECT 
        "Type" AS "Regime Type",                            
        'Max' AS "Min/Max",                                 										-- Tag for maximum values 
        ROUND(CAST("Press_Freedom_Score" AS NUMERIC), 1) AS "Press Freedom Score (%)",
        "Country",                                          
        ROUND(CAST("Democracy_Index" AS NUMERIC), 1) AS "Democracy Index"
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY "Type" ORDER BY "Press_Freedom_Score" DESC) AS rn	-- Descending order to obtain maximum values (in contrast to descending order to obtain minimum values)
        FROM dem_press_joined
		WHERE "Press_Freedom_Score" IS NOT NULL  -- Exclude rows where the press freedom score is NULL
    ) t
    WHERE rn = 1
)

-- Insert the results from the CTE into the 'dem_press_minmax' table
INSERT INTO dem_press_minmax
SELECT * FROM MinMaxPress  -- Select all the columns from the CTE

ORDER BY 
    CASE
        -- Define the order for the regime types
        WHEN "Regime Type" = 'Authoritarian Regime' THEN 1  -- Order authoritarian regimes firsrt
        WHEN "Regime Type" = 'Hybrid Regime' THEN 2         -- Then hybrid regimes
        WHEN "Regime Type" = 'Flawed Democracy' THEN 3      -- Then flawed democracies
        WHEN "Regime Type" = 'Full Democracy' THEN 4        -- Finally, full democracies
    END,
    "Min/Max" DESC; -- Ordering "Min/Max" in a descending way puts the minimum values before the maximum values because alphabetically the second letter of min (i) comes after the second letter of max (a)


-- CREATE A TABLE WITH MINIMUM AND MAXIMUM LIFE EXPECTANCIES FOR EACH REGIME TYPE
-- Analogous calculation to press freedom score 

DROP TABLE IF EXISTS dem_le_minmax;

CREATE TABLE dem_le_minmax (		 
    "Regime Type" VARCHAR,						
    "Min/Max" VARCHAR,
    "Life Expectancy (Years)" FLOAT, -- Life expectancy
    "Country" VARCHAR,
    "Democracy Index" FLOAT     
);

WITH MinMaxLE AS (

    SELECT 
        "Type" AS "Regime Type",
        'Min' AS "Min/Max",
		ROUND(CAST("Life_Exp" AS NUMERIC), 1) AS "Life Expectancy (Years)",
        "Country",
		ROUND(CAST("Democracy_Index" AS NUMERIC), 1) AS "Democracy Index"
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY "Type" ORDER BY "Life_Exp" ASC) AS rn
        FROM dem_le_joined
    ) t
    WHERE rn = 1

    UNION ALL

    SELECT 
        "Type" AS "Regime Type",
        'Max' AS "Min/Max",
        ROUND(CAST("Life_Exp" AS NUMERIC), 1) AS "Life Expectancy (Years)",
		"Country",
		ROUND(CAST("Democracy_Index" AS NUMERIC), 1) AS "Democracy Index"
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY "Type" ORDER BY "Life_Exp" DESC) AS rn
        FROM dem_le_joined
		WHERE "Life_Exp" IS NOT NULL
    ) t
    WHERE rn = 1
)

INSERT INTO dem_le_minmax
SELECT * FROM MinMaxLe
ORDER BY 
    CASE
        WHEN "Regime Type" = 'Authoritarian Regime' THEN 1
        WHEN "Regime Type" = 'Hybrid Regime' THEN 2
        WHEN "Regime Type" = 'Flawed Democracy' THEN 3
        WHEN "Regime Type" = 'Full Democracy' THEN 4
    END,
    "Min/Max" DESC;



-- CREATE A TABLE WITH MINIMUM AND MAXIMUM EDUCATION SPENDING FOR EACH REGIME TYPE
-- Analogous calculation to press freedom score 

DROP TABLE IF EXISTS dem_edu_minmax;

CREATE TABLE dem_edu_minmax (
    "Regime Type" VARCHAR,
    "Min/Max" VARCHAR,
    "gdp_edu (%)" FLOAT, 		-- Education spending (percentage of GDP spent)
    "Country" VARCHAR,
    "Democracy Index" FLOAT     
);

WITH MinMaxEdu AS (

    SELECT 
        "Type" AS "Regime Type",
        'Min' AS "Min/Max",
		ROUND(CAST("EDI" AS NUMERIC), 1) AS "gdp_edu (%)",
        "Country",
		ROUND(CAST("Democracy_Index" AS NUMERIC), 1) AS "Democracy Index"
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY "Type" ORDER BY "EDI" ASC) AS rn
        FROM dem_edu_joined
    ) t
    WHERE rn = 1

    UNION ALL

    SELECT 
        "Type" AS "Regime Type",
        'Max' AS "Min/Max",
		ROUND(CAST("EDI" AS NUMERIC), 1) AS "gdp_edu (%)",
        "Country",
		ROUND(CAST("Democracy_Index" AS NUMERIC), 1) AS "Democracy Index"
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY "Type" ORDER BY "EDI" DESC) AS rn
        FROM dem_edu_joined
		WHERE "EDI" IS NOT NULL
    ) t
    WHERE rn = 1
)

INSERT INTO dem_edu_minmax

SELECT * FROM MinMaxEdu
ORDER BY 
    CASE
        WHEN "Regime Type" = 'Authoritarian Regime' THEN 1
        WHEN "Regime Type" = 'Hybrid Regime' THEN 2
        WHEN "Regime Type" = 'Flawed Democracy' THEN 3
        WHEN "Regime Type" = 'Full Democracy' THEN 4
    END,
    "Min/Max" DESC;