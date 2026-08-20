
/*
=============================================================
PROJECT:
Exploratory Analysis of a Linked Skin Lesion Dataset

AUTHOR:
Cornelius Engmann

DESCRIPTION:
This project investigates the structure, quality and characteristics of a linked dermatology dataset using SQL.

=============================================================

-------------------------------------------------------------
SECTION 1: DATABASE FAMILIARISATION
-------------------------------------------------------------

Objective
---------
Gain an initial understanding of the supplied database,
its contents and analytical units before assessing data
quality or performing analysis.

Business Rationale
------------------
Before analysing healthcare data, analysts must first
understand what data are available, how they are organised
and the level at which each table is recorded.

Questions Answered
------------------
1. What tables are available?
2. What information does each table contain?
3. What is the grain of each table?
4. How many records exist in each table?

Expected Outcome
----------------
A clear understanding of the dataset's structure and analytical units prior to structural validation.

=============================================================
*/

-- 1.1 Inspect patient records
SELECT *
FROM table1
LIMIT 10; 

-- 1.2 Inspect lesion records
SELECT *
FROM table2
LIMIT 10;

-- 1.3 Confirm count of patient records
SELECT COUNT(*) AS table1_rows
FROM table1; 

-- 1.4 Confirm count of lesion records
SELECT COUNT(*) AS table2_rows
FROM table2; 

/*
=============================================================

-------------------------------------------------------------
SECTION 2: RELATIONAL INTEGRITY & STRUCTURAL VALIDATION
-------------------------------------------------------------

Objective
---------
Validate the relational structure of the database and verify that patient and lesion records can be joined safely for subsequent analysis.

Business Rationale
------------------
Healthcare datasets often consist of multiple linked tables. Before analysing patient outcomes or producing statistics, it is essential to confirm that identifiers are unique,
relationships are valid and referential integrity is maintained.

Failure to validate the relational structure may result in duplicate records, incorrect aggregations and misleading analytical conclusions.

Questions Answered
------------------
1. Is the patient table truly at patient level?
2. Does each patient contribute only one lesion record?
3. Is lesion_id globally unique?
4. Are lesion identifiers reused across patients?
5. Are there patients with multiple lesion records?
6. Are there patients without lesion records?
7. Can the two tables be joined safely?

Expected Outcome
----------------
A validated relational structure suitable for downstream data profiling and exploratory analysis.

=============================================================
*/

-- 2.1 Confirm patient_level grain
SELECT 
	COUNT(DISTINCT  patient_id) AS unique_patients,
	COUNT(*) AS total_rows
FROM table1;

-- 2.2 Confirm patient representation in the lesion table
SELECT 
	COUNT(DISTINCT  patient_id)  AS unique_patients,
	COUNT(*) total_rows
FROM table2;

-- 2.2.1 Verify patient representation
SELECT
    patient_id,
    COUNT(*) AS lesion_count
FROM table2
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- 2.3 Assess uniqueness of lesion identifiers
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT lesion_id) AS unique_lesion_ids
FROM table2;

-- 2.4 Investigate reused lesion identifiers
SELECT
    lesion_id,
    patient_id
FROM table2
WHERE lesion_id IN (
    SELECT lesion_id
    FROM table2
    GROUP BY lesion_id
    HAVING COUNT(*) > 1
)
ORDER BY lesion_id;

SELECT
    lesion_id,
    COUNT(*) AS occurrence_count,
    COUNT(DISTINCT patient_id) AS associated_patients
FROM table2
GROUP BY lesion_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC, lesion_id;

-- 2.5 Verify composite-key uniqueness 
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (lesion_id, patient_id)) AS unique_composite_keys
FROM table2;

-- 2.6 Confirm patient–lesion linkage
SELECT
    p.patient_id
FROM table1 p
LEFT JOIN table2 l
ON p.patient_id = l.patient_id
WHERE l.patient_id IS NULL;

/*
=============================================================

-------------------------------------------------------------
SECTION 3: VARIABLE PROFILING
-------------------------------------------------------------

Objective
---------
Assess the quality and characteristics of each variable by examining completeness, validity, consistency and distribution according to its data type.

Business Rationale
------------------
Reliable healthcare analysis depends on understanding the quality and behaviour of each variable before performing descriptive, inferential or predictive analyses.
Profiling variables helps identify missing values, inconsistencies and potential data quality issues that may affect downstream analysis.

Questions Answered
------------------
1. Are identifier variables complete and unique?
2. Are categorical variables complete and consistently coded?
3. Are boolean variables complete and valid?
4. Are numerical variables complete and within plausible ranges?
5. Are ordinal variables complete and within valid categories?

Expected Outcome
----------------
A comprehensive understanding of the quality and suitability
of every variable for subsequent analysis.

=============================================================
*/

-- 3.1 Identifier Variables Profiling
This subsection only focuses one img_id because structural integrity of patient_id and lesion_id have been already assessed in Section 2. 


-- 3.1.1 Assess identifier completeness
SELECT img_id AS missing_img_ids
FROM table2
WHERE img_id IS NULL;

-- 3.1.2 Assess image identifier uniqueness
SELECT img_id
FROM table2
GROUP BY img_id
HAVING COUNT(*) > 1

-- 3.2 Categorical Variable Profiling

-- 3.2.1 Assess gender categories
SELECT 
	gender,
	COUNT(*) AS total_patients
FROM table1
GROUP BY gender
ORDER BY total_patients DESC;

-- 3.2.2 Assess paternal ethnicity categories
SELECT 
	background_father,
	COUNT(*) AS total_patients
FROM table1
GROUP BY background_father
ORDER BY total_patients DESC;

-- 3.2.2 Assess maternal ethnicity categories
SELECT 
	background_mother, 
	COUNT(*) AS total_patients
FROM table1
GROUP BY background_mother
ORDER BY total_patients DESC;

-- 3.2.4 Assess lesion region categories
SELECT 
	region,
	COUNT(*) AS total_patients
FROM table2
GROUP BY region
ORDER BY total_patients DESC;

-- 3.2.5 Assess diagnostic categories
SELECT 
	diagnostic,
	COUNT(*) AS total_patients
FROM table2
GROUP BY diagnostic;

-- 3.3 Boolean Variable Profiling

-- 3.3.1 Assess patient-level boolean variables
SELECT
    variable_name,
    variable_value,
    COUNT(*) AS frequency,
	ROUND(
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY variable_name),
    1
) AS percentage
FROM table1
CROSS JOIN LATERAL (
    VALUES
        ('smoke', smoke),
        ('drink', drink),
		('pesticide', pesticide),
        ('cancer_history', cancer_history),
		('skin_cancer_history', skin_cancer_history),
		('has_sewage_system', has_sewage_system),
		('has_piped_water', has_piped_water)
) AS boolean_profile(variable_name, variable_value)
GROUP BY
    variable_name,
    variable_value
ORDER BY
    variable_name,
    variable_value;

-- 3.3.1 Assess lesion-level boolean variables
SELECT
    variable_name,
    variable_value,
    COUNT(*) AS frequency,
	ROUND(
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY variable_name),
    1
) AS percentage
FROM table2
CROSS JOIN LATERAL (
	VALUES
        ('itch', itch),
        ('grew', grew),
        ('hurt', hurt),
		('changed', changed),
		('bleed', bleed),
		('elevation', elevation),
		('biopsed', biopsed)
) AS boolean_profile(variable_name, variable_value)
GROUP BY variable_name, variable_value
ORDER BY variable_name, variable_value;

-- 3.4 Numerical Variable Profiling

-- 3.4.1 Assess age variable 
SELECT
    COUNT(*) AS total_patients,
    COUNT(age) AS total_age_records,
    COUNT(*) - COUNT(age) AS missing_age_records,
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(age), 2) AS avg_age,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY age) AS median_age
FROM table1;

-- 3.4.2 Assess diameter_1 variable
SELECT
    COUNT(*) AS total_records,
    COUNT(diameter_1) AS non_null_records,
    COUNT(*) - COUNT(diameter_1) AS missing_records,
    MIN(diameter_1) AS min_diameter,
    MAX(diameter_1) AS max_diameter,
    ROUND(AVG(diameter_1)::numeric, 2) AS avg_diameter,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY diameter_1) AS median_diameter
FROM table2;

SELECT
    diameter_1,
    COUNT(*) AS frequency,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM table2
GROUP BY diameter_1
ORDER BY diameter_1;

-- 3.4.3 Assess diameter_2 variable
SELECT
    COUNT(*) AS total_records,
    COUNT(diameter_2) AS non_null_records,
    COUNT(*) - COUNT(diameter_2) AS missing_records,
    MIN(diameter_2) AS min_diameter,
    MAX(diameter_2) AS max_diameter,
    ROUND(AVG(diameter_2)::numeric, 2) AS avg_diameter,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY diameter_2) AS median_diameter
FROM table2;

SELECT 
	 diameter_2,
	COUNT(diameter_2),
	ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM table2
GROUP BY diameter_2
ORDER BY diameter_2 ASC;

-- 3.5 Ordinal Variable Profiling

-- 3.5.1 Assess Fitzpatrick skin type
SELECT
    fitspatrick,
    COUNT(*) AS frequency,
	ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM table2
GROUP BY fitspatrick
ORDER BY fitspatrick;

SELECT *
FROM table2
WHERE fitspatrick NOT BETWEEN 1 AND 6;