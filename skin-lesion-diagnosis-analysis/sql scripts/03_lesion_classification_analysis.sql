/*
-------------------------------------------------------------
SECTION 6: MALIGNANT VS. BENIGN LESION ANALYSIS
-------------------------------------------------------------

Objective:
Analyse the linked patient and lesion data to identify characteristics and patterns that distinguish cancerous from benign lesions.
The analysis builds on the exploratory findings from Section 5 and uses the unified analytical view created during the EDA.
=============================================================
*/

-- 6.0 Create and Validate the Lesion Classification View 

-- Drop the existing view to allow the script to be rerun
DROP VIEW IF EXISTS classified_skin_lesion_data;

CREATE VIEW classified_skin_lesion_data AS
SELECT
    *,
    CASE
        WHEN diagnostic IN ('BCC', 'SCC', 'MEL') THEN 'MALIGNANT'
        WHEN diagnostic = 'ACK' THEN 'PRE-CANCEROUS'
        WHEN diagnostic IN ('NEV', 'SEK') THEN 'BENIGN'
        ELSE 'UNCLASSIFIED'
    END AS diagnosis_category
FROM unified_skin_lesion_data;

-- Validation
SELECT
    diagnostic,
    diagnosis_category,
    COUNT(*) AS total_lesions
FROM classified_skin_lesion_data
GROUP BY diagnostic, diagnosis_category
ORDER BY diagnosis_category, total_lesions DESC;

-- 6.What is the distribution of lesion categories?
SELECT
    diagnosis_category,
    COUNT(*) AS total_lesions,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM classified_skin_lesion_data
GROUP BY diagnosis_category
ORDER BY total_lesions DESC

-- 6.2 What clinical features characterise each lesion category?
SELECT
    diagnosis_category,
    variable_name AS clinical_feature,
    COUNT(*) FILTER (WHERE variable_value = TRUE) AS patients_with_feature,
    COUNT(*) AS total_patients,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE variable_value = TRUE)
        / COUNT(*),
        2
    ) AS percentage_with_feature
FROM classified_skin_lesion_data
CROSS JOIN LATERAL (
    VALUES
        ('itch', itch),
        ('hurt', hurt),
        ('bleed', bleed),
        ('grew', grew),
        ('changed', changed),
        ('elevation', elevation)
) AS clinical_features(variable_name, variable_value)
GROUP BY diagnosis_category, clinical_feature
ORDER BY diagnosis_category, percentage_with_feature DESC;

-- 6.3 How does anatomical location vary across lesion categories?
SELECT
    diagnosis_category,
    region,
    COUNT(*) AS total_cases,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY diagnosis_category),
        2
    ) AS percentage
FROM classified_skin_lesion_data
GROUP BY diagnosis_category, region
ORDER BY diagnosis_category, percentage DESC;

-- 6.4 Patient Characteristics Across Lesion Categories

-- 6.4.1 How do patient demographics vary across lesion categories?
SELECT
    diagnosis_category,
	gender, 
    CASE
        WHEN age < 16 THEN '0-15'
        WHEN age BETWEEN 16 AND 30 THEN '16-30'
        WHEN age BETWEEN 31 AND 45 THEN '31-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        WHEN age BETWEEN 61 AND 75 THEN '61-75'
        ELSE '76+'
    END AS age_group,
    COUNT(*) AS total_patients,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY diagnosis_category),
        2
    ) AS percentage
FROM classified_skin_lesion_data
GROUP BY diagnosis_category, gender, age_group
ORDER BY diagnosis_category, age_group;

-- 6.4.2 How do patient clinical histories vary across lesion categories?
SELECT
    diagnosis_category,
    variable_name AS clinical_history,
    COUNT(*) FILTER (WHERE variable_value = TRUE) AS total_with_history,
    COUNT(*) AS total_patients,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE variable_value = TRUE)
        / COUNT(*),
        2
    ) AS percentage_with_history
FROM classified_skin_lesion_data
CROSS JOIN LATERAL (
    VALUES
        ('cancer_history', cancer_history),
        ('skin_cancer_history', skin_cancer_history)
) AS clinical_history(variable_name, variable_value)
GROUP BY diagnosis_category, clinical_history
ORDER BY diagnosis_category, percentage_with_history DESC;
/*
Only TRUE values are counted because the analytical question measures the prevalence of each characteristic within a diagnosis.
*/

-- 6.4.3 How do patient lifestyle habits vary across lesion categories?
SELECT
    diagnosis_category,
    variable_name AS lifestyle_habit,
    COUNT(*) FILTER (WHERE variable_value = TRUE) AS total_with_habit,
    COUNT(*) AS total_patients,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE variable_value = TRUE)
        / COUNT(*),
        2
    ) AS percentage_with_habit
FROM classified_skin_lesion_data
CROSS JOIN LATERAL (
    VALUES
        ('smoke', smoke),
        ('drink', drink)
) AS lifestyle_profile(variable_name, variable_value)
GROUP BY diagnosis_category, lifestyle_habit
ORDER BY diagnosis_category, percentage_with_habit DESC;
/* 
Only TRUE values are counted because the analytical question measures the prevalence of each characteristic within a diagnosis.
*/

-- 6.4.4 How do patient environmental characteristics vary across lesion categories?
SELECT
    diagnosis_category,
    variable_name AS environmental_characteristic,
    COUNT(*) FILTER (WHERE variable_value = TRUE) AS total_with_characteristic,
    COUNT(*) AS total_patients,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE variable_value = TRUE)
        / COUNT(*),
        2
    ) AS percentage_with_characteristic
FROM classified_skin_lesion_data
CROSS JOIN LATERAL (
    VALUES
        ('pesticide', pesticide),
        ('has_piped_water', has_piped_water),
        ('has_sewage_system', has_sewage_system)
) AS environmental_profile(variable_name, variable_value)
GROUP BY diagnosis_category, environmental_characteristic
ORDER BY diagnosis_category, percentage_with_characteristic DESC;
/*
Only TRUE values are counted because the analytical question measures the prevalence of each characteristic within a diagnosis.
*/

-- 6.5 What characteristics distinguish malignant from benign lesions?
/*
Synthesis:
The analysis identified several characteristics that differed substantially between malignant and benign lesions.

Clinical Features:
• Malignant lesions showed substantially higher prevalence of bleeding (52.02% vs. 1.42%) and pain (36.99% vs. 1.78%) than benign lesions.
• Itching was also considerably more prevalent among malignant lesions (75.14%) than benign lesions (21.35%).
• Elevation (82.66% vs. 72.24%) and growth (74.86% vs. 61.92%) were common in both malignant and benign lesions, 
  making the differences between the two categories less pronounced for these features.
• Change was more prevalent among malignant lesions (18.21%) than benign lesions (6.76%), although it was less frequently recorded than several other clinical features.

Anatomical Location:
• The face was the most common anatomical location for both malignant (29.48%) and benign (28.11%) lesions.
• Beyond the face, the anatomical distributions differed. Malignant lesions were more commonly recorded on the chest (15.03%) and nose (13.58%), 
  while benign lesions were more commonly recorded on the back (21.00%) and chest (13.17%).

Patient Demographics:
• Malignant lesions were concentrated among middle-aged and older patients, with very little representation among patients aged 30 years or younger.
• Benign lesions occurred across all age groups and showed greater representation among younger patients, 
  although most benign lesions were still recorded among patients aged 31-75.

Clinical History:
• Of patients with malignant lesions, 54.05% had a previous cancer history and 45.38% had a previous skin cancer history.
• Among patients with benign lesions, the corresponding proportions were substantially lower at 6.41% and 4.63%, respectively.

Lifestyle Habits:
• Alcohol consumption was more prevalent among patients with malignant lesions (28.32%) than those with benign lesions (2.49%).
• Smoking showed a similar difference, occurring among 13.58% of patients with malignant lesions compared with 0.71% of those with benign lesions.

Environmental Characteristics:
• Patients with malignant lesions had substantially higher prevalence of pesticide exposure (45.09% vs. 1.78%),
  piped water access (56.36% vs. 7.47%) and sewage system access (49.42% vs. 6.76%) than patients with benign lesions.

Overall:
• The clearest descriptive differences between malignant and benign lesions were observed across multiple dimensions rather than through a single characteristic.
• Malignant lesions showed particularly higher prevalence of bleeding, pain and itching, while patients with malignant lesions showed substantially higher prevalence of previous
  cancer history, previous skin cancer history, smoking, alcohol consumption and the measured environmental characteristics.

• These characteristics should not be interpreted independently as causes or predictors of malignancy. 
  The analysis is descriptive and identifies patterns within this dataset that distinguish the lesion categories.
*/