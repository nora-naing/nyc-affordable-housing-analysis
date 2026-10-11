-- Project	: MySQL - NYC's Affordable Housing Production
-- File		: 01_data_validation_and_eda.sql
-- Author	: Nora Thu Thu Htet Naing
-- Purpose	: Validate the dataset structure, check data consistency, understand the grain,
-- 				and establish basic distributions before performing business analysis.


-- DATABASE & TABLE SETUP

DROP DATABASE IF EXISTS affordable_housing;

CREATE DATABASE affordable_housing;

USE affordable_housing;

-- Create final table
CREATE TABLE housing_projects (
    project_id INT,
    project_name VARCHAR(255),
    project_start_date DATE,
    project_completion_date DATE,
    
    building_id INT,
    building_number VARCHAR(50),
    street VARCHAR(255),
    borough VARCHAR(50),
    
    postcode INT,
    bbl BIGINT,
    bin BIGINT,
    
    community_board VARCHAR(50),
    council_district INT,
    census_tract INT,
    nta_neighborhood VARCHAR(255),
    
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    latitude_internal DECIMAL(10,6),
    longitude_internal DECIMAL(10,6),
    
    building_completion_date DATE,
    
    reporting_construction_type VARCHAR(50),
    extended_affordability_only VARCHAR(10),
    prevailing_wage_status VARCHAR(50),
    
    extremely_low_income_units INT,
    very_low_income_units INT,
    low_income_units INT,
    moderate_income_units INT,
    middle_income_units INT,
    other_income_units INT,
    
    studio_units INT,
    one_br_units INT,
    two_br_units INT,
    three_br_units INT,
    four_br_units INT,
    five_br_units INT,
    six_br_plus_units INT,
    unknown_br_units INT,
    
    counted_rental_units INT,
    counted_homeownership_units INT,
    all_counted_units INT,
    total_units INT,
    
    affordable_unit_share DECIMAL(6,2)
);

-- Create staging table
CREATE TABLE housing_projects_staging (
    project_id VARCHAR(50),
    project_name VARCHAR(255),
    project_start_date VARCHAR(50),
    project_completion_date VARCHAR(50),
    
    building_id VARCHAR(50),
    building_number VARCHAR(50),
    street VARCHAR(255),
    borough VARCHAR(50),
    
    postcode VARCHAR(50),
    bbl VARCHAR(50),
    bin VARCHAR(50),
    
    community_board VARCHAR(50),
    council_district VARCHAR(50),
    census_tract VARCHAR(50),
    nta_neighborhood VARCHAR(255),
    
    latitude VARCHAR(50),
    longitude VARCHAR(50),
    latitude_internal VARCHAR(50),
    longitude_internal VARCHAR(50),
    
    building_completion_date VARCHAR(50),
    
    reporting_construction_type VARCHAR(50),
    extended_affordability_only VARCHAR(50),
    prevailing_wage_status VARCHAR(50),
    
    extremely_low_income_units VARCHAR(50),
    very_low_income_units VARCHAR(50),
    low_income_units VARCHAR(50),
    moderate_income_units VARCHAR(50),
    middle_income_units VARCHAR(50),
    other_income_units VARCHAR(50),
    
    studio_units VARCHAR(50),
    one_br_units VARCHAR(50),
    two_br_units VARCHAR(50),
    three_br_units VARCHAR(50),
    four_br_units VARCHAR(50),
    five_br_units VARCHAR(50),
    six_br_plus_units VARCHAR(50),
    unknown_br_units VARCHAR(50),
    
    counted_rental_units VARCHAR(50),
    counted_homeownership_units VARCHAR(50),
    all_counted_units VARCHAR(50),
    total_units VARCHAR(50),
    
    affordable_unit_share VARCHAR(50)
);


-- DATA IMPORT & TRANSFORMATION

-- Validate staging import
SELECT
	COUNT(*) AS total_rows,
	COUNT(project_id) AS non_null_project_ids,
	COUNT(building_id) AS non_null_building_id,
	COUNT(project_completion_date) AS non_null_project_completion_dates,
    COUNT(building_completion_date) AS non_null_building_completion_dates
FROM housing_projects_staging;

SELECT
    COUNT(*) AS total_rows,
    SUM(building_id = '') AS empty_building_ids,
    SUM(project_completion_date = '') AS empty_completion_dates
FROM housing_projects_staging;

-- Transform staging data into final table
-- Notes: Convert empty strings to NULL and transform date strings into DATE values when loading the final analytical table.
INSERT INTO housing_projects (
    project_id,
    project_name,
    project_start_date,
    project_completion_date,
    
    building_id,
    building_number,
    street,
    borough,
    
    postcode,
    bbl,
    bin,
    
    community_board,
    council_district,
    census_tract,
    nta_neighborhood,
    
    latitude,
    longitude,
    latitude_internal,
    longitude_internal,
    
    building_completion_date,
    
    reporting_construction_type,
    extended_affordability_only,
    prevailing_wage_status,
    
    extremely_low_income_units,
    very_low_income_units,
    low_income_units,
    moderate_income_units,
    middle_income_units,
    other_income_units,
    
    studio_units,
    one_br_units,
    two_br_units,
    three_br_units,
    four_br_units,
    five_br_units,
    six_br_plus_units,
    unknown_br_units,
    
    counted_rental_units,
    counted_homeownership_units,
    all_counted_units,
    total_units,
    
    affordable_unit_share
)
SELECT
    NULLIF(project_id, ''),
    NULLIF(project_name, ''),
    STR_TO_DATE(NULLIF(project_start_date, ''), '%Y-%m-%d'),
    STR_TO_DATE(NULLIF(project_completion_date, ''), '%Y-%m-%d'),
    
    NULLIF(building_id, ''),
    NULLIF(building_number, ''),
    NULLIF(street, ''),
    NULLIF(borough, ''),
    
    NULLIF(postcode, ''),
    NULLIF(bbl, ''),
    NULLIF(bin, ''),
    
    NULLIF(community_board, ''),
    NULLIF(council_district, ''),
    NULLIF(census_tract, ''),
    NULLIF(nta_neighborhood, ''),
    
    NULLIF(latitude, ''),
    NULLIF(longitude, ''),
    NULLIF(latitude_internal, ''),
    NULLIF(longitude_internal, ''),
    
    STR_TO_DATE(NULLIF(building_completion_date, ''), '%Y-%m-%d'),
    
    NULLIF(reporting_construction_type, ''),
    NULLIF(extended_affordability_only, ''),
    NULLIF(prevailing_wage_status, ''),
    
    NULLIF(extremely_low_income_units, ''),
    NULLIF(very_low_income_units, ''),
    NULLIF(low_income_units, ''),
    NULLIF(moderate_income_units, ''),
    NULLIF(middle_income_units, ''),
    NULLIF(other_income_units, ''),
    
    NULLIF(studio_units, ''),
    NULLIF(one_br_units, ''),
    NULLIF(two_br_units, ''),
    NULLIF(three_br_units, ''),
    NULLIF(four_br_units, ''),
    NULLIF(five_br_units, ''),
    NULLIF(six_br_plus_units, ''),
    NULLIF(unknown_br_units, ''),
    
    NULLIF(counted_rental_units, ''),
    NULLIF(counted_homeownership_units, ''),
    NULLIF(all_counted_units, ''),
    NULLIF(total_units, ''),
    
    NULLIF(affordable_unit_share, '')
FROM housing_projects_staging;

-- Validate final table import
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT project_id) AS unique_projects,
    COUNT(DISTINCT building_id) AS unique_buildings
FROM housing_projects;


-- 01. Dataset Overview

-- 1.1 Overall dataset summary
SELECT
    COUNT(*) AS total_records,
    COUNT(project_id) AS not_null_projects,
    COUNT(DISTINCT project_id) AS unique_projects,
    COUNT(building_id) AS not_null_buildings,
    COUNT(DISTINCT building_id) AS unique_buildings,
    SUM(all_counted_units) AS total_affordable_units,
    SUM(total_units) AS total_units,
    MIN(project_start_date) AS earliest_project_start,
    MAX(project_start_date) AS latest_project_start
FROM housing_projects;


-- 02. Data Quality

-- 2.1 Missing Building IDs
SELECT
    project_name,
    COUNT(*) AS missing_building_records
FROM housing_projects
WHERE building_id IS NULL
GROUP BY project_name
ORDER BY missing_building_records DESC;

-- 2.2 Duplicate Project + Building combinations
SELECT
    project_id,
    building_id,
    COUNT(*) AS total_records
FROM housing_projects
GROUP BY project_id, building_id
HAVING COUNT(*) > 1
ORDER BY total_records DESC;

-- 2.3 Negative unit values
SELECT
    COUNT(*) AS rows_with_negative_units
FROM housing_projects
WHERE extremely_low_income_units < 0
    OR very_low_income_units < 0
    OR low_income_units < 0
    OR moderate_income_units < 0
    OR middle_income_units < 0
    OR other_income_units < 0
    OR studio_units < 0
    OR one_br_units < 0
    OR two_br_units < 0
    OR three_br_units < 0
    OR four_br_units < 0
    OR five_br_units < 0
    OR six_br_plus_units < 0
    OR unknown_br_units < 0
    OR counted_rental_units < 0
    OR counted_homeownership_units < 0
    OR all_counted_units < 0
    OR total_units < 0
;

-- 2.4 Affordable units should not exceed total units
SELECT
    COUNT(*) AS invalid_unit_relationships
FROM housing_projects
WHERE all_counted_units > total_units;

-- 2.5 Invalid project dates
SELECT
    project_id,
    project_name,
    building_id,
    project_start_date,
    project_completion_date
FROM housing_projects
WHERE project_completion_date IS NOT NULL
  AND project_start_date IS NOT NULL
  AND project_completion_date < project_start_date
ORDER BY project_start_date;


-- 03. Project & Building Structure

-- 3.1 Average building records per project
SELECT
	ROUND(AVG(building_count), 2) AS avg_records_per_project
FROM (
	SELECT
		project_id,
		COUNT(*) AS building_count
	FROM housing_projects
	GROUP BY project_id
) AS project_summary;

-- 3.2 Largest projects by affordable units
SELECT
	project_id,
    MAX(project_name) AS project_name,
    SUM(all_counted_units) AS affordable_units,
    SUM(total_units) AS total_units
FROM housing_projects
GROUP BY project_id
ORDER BY affordable_units DESC
LIMIT 10;

-- 3.3 Projects with the most building records
SELECT
    project_id,
    MAX(project_name) AS project_name,
    COUNT(*) AS building_records
FROM housing_projects
GROUP BY project_id
ORDER BY building_records DESC
LIMIT 10;


-- 04. Date & Unit Validation

-- 4.1 Income-group units vs affordable units
SELECT
    COUNT(*) AS mismatched_income_totals
FROM housing_projects
WHERE extremely_low_income_units
    + very_low_income_units
    + low_income_units
    + moderate_income_units
    + middle_income_units
    + other_income_units
    != all_counted_units
;

-- 4.2 Bedroom units vs affordable units
SELECT
    COUNT(*) AS mismatched_bedroom_totals
FROM housing_projects
WHERE studio_units
    + one_br_units
    + two_br_units
    + three_br_units
    + four_br_units
    + five_br_units
    + six_br_plus_units
    + unknown_br_units
    != all_counted_units
;

-- 4.3 Rental + Homeownership units vs affordable units
SELECT
    COUNT(*) AS mismatched_tenure_totals
FROM housing_projects
WHERE counted_rental_units
	+ counted_homeownership_units
    != all_counted_units
;

-- 4.4 Completion date validation
-- This checks whether a building is recorded as completing after the overall project completion date.
SELECT
    COUNT(*) AS invalid_completion_dates
FROM housing_projects
WHERE building_completion_date IS NOT NULL
    AND project_completion_date IS NOT NULL
    AND building_completion_date > project_completion_date;


-- 05. Basic Distribution

-- 5.1 Borough Contribution
SELECT
    borough,
    COUNT(*) AS records,
    SUM(all_counted_units) AS affordable_units,
    ROUND(AVG(all_counted_units), 2) AS avg_affordable_units
FROM housing_projects
GROUP BY borough
ORDER BY affordable_units DESC;

-- 5.2 Construction Type Contribution
SELECT
    reporting_construction_type,
    COUNT(*) AS records,
    SUM(all_counted_units) AS affordable_units,
    ROUND(AVG(all_counted_units), 2) AS avg_affordable_units
FROM housing_projects
GROUP BY reporting_construction_type
ORDER BY affordable_units DESC;

-- 5.3 Affordable units by income group
SELECT
    'Extremely Low Income' AS income_group,
    SUM(extremely_low_income_units) AS affordable_units
FROM housing_projects
UNION ALL
SELECT 'Very Low Income', SUM(very_low_income_units)
FROM housing_projects
UNION ALL
SELECT 'Low Income', SUM(low_income_units)
FROM housing_projects
UNION ALL
SELECT 'Moderate Income', SUM(moderate_income_units)
FROM housing_projects
UNION ALL
SELECT 'Middle Income', SUM(middle_income_units)
FROM housing_projects
UNION ALL
SELECT 'Other Income', SUM(other_income_units)
FROM housing_projects
ORDER BY affordable_units DESC;

-- 5.4 Affordable units by bedroom type
SELECT
    'Studio' AS bedroom_type,
    SUM(studio_units) AS affordable_units
FROM housing_projects
UNION ALL
SELECT '1-BR', SUM(one_br_units)
FROM housing_projects
UNION ALL
SELECT '2-BR', SUM(two_br_units)
FROM housing_projects
UNION ALL
SELECT '3-BR', SUM(three_br_units)
FROM housing_projects
UNION ALL
SELECT '4-BR', SUM(four_br_units)
FROM housing_projects
UNION ALL
SELECT '5-BR', SUM(five_br_units)
FROM housing_projects
UNION ALL
SELECT '6-BR+', SUM(six_br_plus_units)
FROM housing_projects
UNION ALL
SELECT 'Unknown', SUM(unknown_br_units)
FROM housing_projects
ORDER BY affordable_units DESC;