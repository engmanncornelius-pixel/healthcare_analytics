/*
-------------------------------------------------------------
SECTION 4: DATA CLEANING & PREPARATION
-------------------------------------------------------------

Objective
---------
Create reproducible, analysis-ready versions of the source tables while preserving the original raw data.

Business Rationale
------------------
Cleaning should improve consistency and analytical usability without overwriting source data or introducing unsupported assumptions.

Expected Outcome
----------------
Cleaned patient- and lesion-level tables with documented, traceable transformations.

=============================================================
*/

-- 4.1 — Create Cleaned Tables

-- 4.1.1 Create clean patient-level table

-- Drop the existing cleaned table to allow the script to be rerun
DROP TABLE IF EXISTS cleaned_table1;

CREATE TABLE cleaned_table1 AS
SELECT
    patient_id,
    smoke,
    drink,
    CASE
        WHEN background_father = 'BRASIL' THEN 'BRAZIL'
        WHEN background_father = 'UNK' THEN 'UNKNOWN'
        ELSE background_father
    END AS background_father,
	CASE
        WHEN background_mother = 'UNK' THEN 'UNKNOWN'
        ELSE background_mother
    END AS background_mother,
    age,
    pesticide,
    gender,
    skin_cancer_history,
    cancer_history,
    has_piped_water,
    has_sewage_system
FROM table1;

SELECT *
FROM cleaned_table1
LIMIT 10;

-- Validation

-- Compare the row counts of raw and cleaned data
SELECT
    (SELECT COUNT(*) FROM table2) AS raw_rows,
    (SELECT COUNT(*) FROM cleaned_table1) AS cleaned_rows;

-- Confirm the transformation of 'background_father' 
SELECT
    background_father,
    COUNT(*) AS frequency
FROM cleaned_table1
GROUP BY background_father
ORDER BY frequency DESC;


-- Confirm the transformation of 'background_mother'
SELECT
    background_mother,
    COUNT(*) AS frequency
FROM cleaned_table1
GROUP BY background_mother
ORDER BY frequency DESC;

-- 4.1.2 Create Cleaned Lesion-Level Table

-- Drop the existing cleaned table to allow the script to be rerun
DROP TABLE IF EXISTS cleaned_table2;

CREATE TABLE cleaned_table2 AS
SELECT *
FROM table2;
/*
Zero diameter and Fitzpatrick values were retained because their meaning could not be verified from the source documentation.
*/

-- Validation

-- Confirm column count
SELECT *
FROM cleaned_table2
LIMIT 10;

-- Confirm row count
SELECT COUNT(*)
FROM cleaned_table2;

-- Compare the row counts of raw and cleaned data
SELECT
    (SELECT COUNT(*) FROM table2) AS raw_rows,
    (SELECT COUNT(*) FROM cleaned_table2) AS cleaned_rows;
	
/*
=============================================================

-------------------------------------------------------------
SECTION 5: EXPLORATORY DATA ANALYSIS (EDA)
-------------------------------------------------------------

Objective
---------
Explore the demographic, clinical and lesion characteristics of the prepared dataset and identify patterns that warrant further analytical investigation.

Business Rationale
------------------
Following validation and preparation, exploratory analysis provides an initial understanding of the patient population, lesion characteristics and diagnostic patterns represented in the dataset.

Expected Outcome
----------------
A structured descriptive overview of the dataset that informs subsequent stakeholder-focused analysis.

=============================================================
*/

-- 5.1.1 What is the age profile of the patients?
SELECT 
	MIN(age) AS min_age,
	MAX(age) AS max_age,
	MAX(age) - MIN(age) AS age_range,
	ROUND(AVG(age), 2),
	PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY age) AS median_age 
FROM cleaned_table1;

-- 5.1.2 How are patients distributed across age groups?
SELECT
	CASE 
		WHEN age < 16 THEN '0-15' 
		WHEN age BETWEEN 16 AND 30 THEN '16-30' 
		WHEN age BETWEEN 31 AND 45 THEN '31-45'
		WHEN age BETWEEN 46 AND 60 THEN '46-60' 
		WHEN age BETWEEN 61 AND 75 THEN '61-75' 
		ELSE '76+'
	END AS age_group,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table1
GROUP BY age_group
ORDER BY age_group;

-- 5.1.2 What is the gender distribution of the study population?
SELECT 
	gender,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table1
GROUP BY gender
ORDER BY total_patients DESC;

-- 5.1.3 What is the parental ethnicity profile of the patients?

-- Paternal ethnicity
SELECT 
	background_father,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table1
GROUP BY background_father
ORDER BY total_patients DESC;

-- Maternal ethnicity
SELECT 
	background_mother,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table1
GROUP BY background_mother
ORDER BY total_patients DESC;

-- 5.2 Patient Characteristics

-- 5.2.1 What are the lifestyle characteristics of the patient population?
SELECT 
	variable_name, 
	variable_value,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY variable_name), 2) AS percentage
FROM cleaned_table1
CROSS JOIN LATERAL (VALUES
		('smoke', smoke),
		('drink', drink)
		) AS boolean_profile(variable_name, variable_value)
GROUP BY variable_name, variable_value
ORDER BY variable_name, variable_value;

-- 5.2.2 What are the environmental characteristics of the patient population?
SELECT 
	variable_name, 
	variable_value,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY variable_name), 2) AS percentage
FROM cleaned_table1
CROSS JOIN LATERAL (VALUES
		('pesticide', pesticide),
		('has_piped_water', has_piped_water),
		('has_sewage_system', has_sewage_system)
		) AS boolean_profile(variable_name, variable_value)
GROUP BY variable_name, variable_value
ORDER BY variable_name, variable_value;

-- 5.2.3 What is the clinical history of the patient population?
SELECT 
	variable_name, 
	variable_value,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY variable_name), 2) AS percentage
FROM cleaned_table1
CROSS JOIN LATERAL (VALUES
		('cancer_history', cancer_history),
		('skin_cancer_history', skin_cancer_history)
		) AS boolean_profile(variable_name, variable_value)
GROUP BY variable_name, variable_value
ORDER BY variable_name, variable_value;

-- 5.3 Lesion Profile

-- 5.3.1 What is the distribution of lesion diagnoses?
SELECT 
	diagnostic,
	COUNT(*) AS total_lesions,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table2
GROUP BY diagnostic
ORDER BY total_lesions DESC;

-- 5.3.2 What is the anatomical distribution of lesions?
SELECT 
	region,
	COUNT(*) AS total_lesions,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table2
GROUP BY region
ORDER BY total_patients DESC;

-- 5.3.3 What clinical features (symptoms) are associated with the lesions?
SELECT 
	variable_name, 
	variable_value,
	COUNT(*) AS total_lesions,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY variable_name), 2) AS percentage
FROM cleaned_table2
CROSS JOIN LATERAL (VALUES
		('itch', itch),
		('hurt', hurt),
		('bleed', bleed),
		('grew', grew),
		('changed', changed),
		('elevation', elevation)
		) AS boolean_profile(variable_name, variable_value)
GROUP BY variable_name, variable_value
ORDER BY variable_name, variable_value;

-- 5.3.4 What are the physical measurements of the lesions?
SELECT 
	diameter_1,
	COUNT(*) AS total_lesions,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table2
GROUP BY diameter_1
ORDER BY diameter_1 ASC;

SELECT 
	diameter_2,
	COUNT(*) AS total_lesions,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table2
GROUP BY diameter_2
ORDER BY diameter_2 ASC;

-- 5.3.5 What proportion of lesions were biopsied?
SELECT 
	biopsed,
	COUNT(*) AS total_lesions,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cleaned_table2
GROUP BY biopsed
ORDER BY total_patients DESC;

-- 5.4 Exploratory Relationships and Linked Analysis

-- 5.4.0 Create and validate the unified analytical view

-- Drop the existing view to allow the script to be rerun
DROP VIEW IF EXISTS unified_skin_lesion_data;

CREATE VIEW unified_skin_lesion_data AS
SELECT
    p.patient_id,
    p.smoke,
    p.drink,
    p.background_father,
    p.background_mother,
    p.age,
    p.pesticide,
    p.gender,
    p.skin_cancer_history,
    p.cancer_history,
    p.has_piped_water,
    p.has_sewage_system,
    l.lesion_id,
    l.fitspatrick,
    l.region,
    l.diameter_1,
    l.diameter_2,
    l.diagnostic,
    l.itch,
    l.grew,
    l.hurt,
    l.changed,
    l.bleed,
    l.elevation,
    l.img_id,
    l.biopsed
FROM cleaned_table1 p
JOIN cleaned_table2 l
ON p.patient_id = l.patient_id;

-- Validating the view 
SELECT *
FROM unified_skin_lesion_data
LIMIT 10;

SELECT COUNT(*) AS total_rows
FROM unified_skin_lesion_data;

SELECT
    COUNT(DISTINCT patient_id) AS unique_patients,
    COUNT(DISTINCT lesion_id) AS unique_lesions
FROM unified_skin_lesion_data;

-- 5.4.1 How are patients within each lesion diagnosis distributed across age groups?
SELECT
	diagnostic,
	CASE 
		WHEN age < 16 THEN '0-15' 
		WHEN age BETWEEN 16 AND 30 THEN '16-30' 
		WHEN age BETWEEN 31 AND 45 THEN '31-45'
		WHEN age BETWEEN 46 AND 60 THEN '46-60' 
		WHEN age BETWEEN 61 AND 75 THEN '61-75' 
		ELSE '76+'
	END AS age_group,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY diagnostic),
		2) AS percentage
FROM unified_skin_lesion_data 
GROUP BY diagnostic, age_group
ORDER BY diagnostic, age_group;

-- 5.4.2 How are patients within each lesion diagnosis distributed by gender?
SELECT
	diagnostic,
	gender,
	COUNT(*) AS total_patients,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY diagnostic),
		2) AS percentage
FROM unified_skin_lesion_data
GROUP BY diagnostic, gender
ORDER BY diagnostic, gender;

-- 5.4.3 How are lesions within each diagnosis distributed across anatomical regions?
SELECT
	diagnostic,
	region,
	COUNT(*) AS total_cases,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY diagnostic),
		2) AS percentage
FROM unified_skin_lesion_data
GROUP BY diagnostic, region
ORDER BY diagnostic, region;

-- 5.4.4 How do clinical features vary across lesion diagnoses?
SELECT
    diagnostic,
    variable_name,
    COUNT(*) FILTER (WHERE variable_value = TRUE) AS total_with_characteristic,
    COUNT(*) AS total_cases,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE variable_value = TRUE)
        / COUNT(*),
        2
    ) AS percentage_with_feature
FROM unified_skin_lesion_data
CROSS JOIN LATERAL (VALUES
		('itch', itch),
		('hurt', hurt),
		('bleed', bleed),
		('grew', grew),
		('changed', changed),
		('elevation', elevation)
		) AS lesion_symptom(variable_name, variable_value)
GROUP BY diagnostic, variable_name
ORDER BY diagnostic, percentage_with_feature DESC;

-- 5.4.5 How does biopsy status vary across lesion diagnoses?
SELECT
	diagnostic,
	biopsed,
	COUNT(*) AS total_lesions,
	ROUND(100.0 * COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY diagnostic),
		2) AS percentage
FROM unified_skin_lesion_data
GROUP BY diagnostic, biopsed
ORDER BY diagnostic, biopsed;

-- 5.4.6 How do patient clinical histories vary across lesion diagnoses?
SELECT
    diagnostic,
    variable_name,
    COUNT(*) FILTER (WHERE variable_value = TRUE) AS total_with_history,
    COUNT(*) AS total_patients,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE variable_value = TRUE)/
        COUNT(*),
    2) AS percentage_with_history
FROM unified_skin_lesion_data
CROSS JOIN LATERAL (
    VALUES
        ('cancer_history', cancer_history),
        ('skin_cancer_history', skin_cancer_history)
) AS clinical_history(variable_name, variable_value)
GROUP BY diagnostic, variable_name
ORDER BY diagnostic, percentage_with_history DESC;

-- 5.4.7 How do patient lifestyle characteristics vary across lesion diagnoses?
SELECT
    diagnostic,
    variable_name,
    COUNT(*) FILTER (WHERE variable_value = TRUE) AS total_with_habit,
    COUNT(*) AS total_patients,
	ROUND(
        100.0 * COUNT(*) FILTER (WHERE variable_value = TRUE)/
        COUNT(*),
    2) AS percentage_with_habit
FROM unified_skin_lesion_data
CROSS JOIN LATERAL (
    VALUES
        ('smoke', smoke),
        ('drink', drink)
) AS lifestyle_profile(variable_name, variable_value)
GROUP BY diagnostic, variable_name
ORDER BY diagnostic, percentage_with_habit DESC;

-- 5.4.8 How do patient environmental characteristics vary across lesion diagnoses?
SELECT
    diagnostic,
    variable_name,
    COUNT(*) FILTER (WHERE variable_value = TRUE) AS total_with_characteristic,
    COUNT(*) AS total_patients,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE variable_value = TRUE)/
        COUNT(*),
    2) AS percentage_with_characteristic
FROM unified_skin_lesion_data
CROSS JOIN LATERAL (
    VALUES
        ('pesticide', pesticide),
        ('has_piped_water', has_piped_water),
		('has_sewage_system', has_sewage_system)
) AS environmental_profile(variable_name, variable_value)
GROUP BY diagnostic, variable_name
ORDER BY diagnostic, percentage_with_characteristic DESC;