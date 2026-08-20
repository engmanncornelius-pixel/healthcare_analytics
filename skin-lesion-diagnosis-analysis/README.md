# Exploring Patterns in Lesion Diagnoses from Linked Skin Lesion and Patient Data Using SQL

## Overview
Using SQL, I linked and analysed patient and skin lesion data to explore how patient and lesion characteristics vary across diagnoses and identify patterns that distinguish benign, pre-cancerous and malignant lesions.

## Healthcare Problem
Skin cancer detection is a complex healthcare challenge because both patient characteristics and the manner in which skin lesions present clinically can vary considerably. Recognising clinically relevant lesion characteristics can support the early identification of potentially concerning lesions, which is important because early detection can improve patient outcomes.
The source dataset consisted of two tables: a patient-level table containing demographics, clinical history, lifestyle habits and environmental factors, and a lesion-level table containing diagnoses, anatomical locations and clinical features. Analysing table dataset independently provides only a partial view of the problem. Linking both tables through their common patient identifier enables exploration of how patient and lesion characteristics vary across diagnoses and whether identifiable patterns distinguish malignant, pre-cancerous and benign lesions. Understanding these relationships can provide a foundation for more focused investigation.

## Project Objective
To explore linked patient and lesion characteristics, identify patterns across lesion diagnoses, and examine characteristics that distinguish malignant, pre-cancerous and benign lesions.

## Dataset Overview
Source: The dataset was provided by Derm AI Diagnostics and consisted of two related source tables containing patient and lesion information.
Structure: Each table contained 1,088 records. The patient table contained one record per patient, while the lesion table contained one corresponding lesion record per patient.
Patient table (`table1`): Contains demographic information, clinical history, lifestyle habits and environmental characteristics.
Lesion table (`table2`): Contains lesion diagnoses, anatomical locations, clinical features, lesion measurements, biopsy status and associated image identifiers.
Linkage: The tables were linked using the common `patient_id`, creating a unified analytical view containing both patient and lesion information.
Analytical dataset: The resulting dataset contains 1,088 linked records across six lesion diagnoses: `ACK`, `BCC`, `MEL`, `NEV`, `SCC` and `SEK`. For category-level analysis, these diagnoses were subsequently classified as benign, pre-cancerous or malignant.

## Analytical Approach
1. Data quality assessment and cleaning: The two source tables were inspected for structural and data quality issues, including duplicates, missing values, inconsistent categorical values, unexpected values and questionable numerical observations. Cleaning decisions were applied where the intended correction could be justified, while unresolved data quality issues were retained and documented rather than arbitrarily altered.

2. Independent exploratory analysis:  Patient and lesion tables were initially analysed separately to establish their underlying profiles. Patient analysis covered demographics, clinical history, lifestyle habits and environmental characteristics, while lesion analysis examined diagnoses, anatomical locations, clinical features, measurements and biopsy status.

3. Dataset linkage and relationship analysis: The cleaned tables were linked through the common `patient_id` to create a unified analytical view. This enabled analysis of how patient and lesion characteristics varied across individual lesion diagnoses.

4. Diagnostic classification:  The six individual lesion diagnoses were grouped into three broader categories — benign, pre-cancerous and malignant — to support analysis aligned with the project's central interest in patterns associated with malignant versus benign lesions.

5. Category-level pattern analysis:  The classified dataset was analysed to compare clinical features, anatomical locations, patient demographics, clinical history, lifestyle habits and environmental characteristics across the three lesion categories, with particular attention to characteristics showing notable differences between malignant and benign groups.

## Key findings
- Diagnosis and lesion category composition
Pre-cancerous lesions were the most common lesion category, accounting for 461 (42.37%) of the 1,088 lesions. All pre-cancerous cases were ACK (actinic keratosis), making ACK the most frequently recorded individual diagnosis in the dataset.  Malignant lesions were for 346 (31.80%), while benign lesions were 281 (25.83%).

- Clinical features by lesion category
Malignant lesions showed the broadest clinical feature profile. Elevation (82.66%), itching (75.14%) and growth (74.86%) were common, while bleeding (52.02%) and pain (36.99%) were substantially more prevalent among malignant lesions than benign lesions (1.42% and 1.78%, respectively). Pre-cancerous lesions were predominantly characterised by itching (75.92%), followed by elevation (26.46%) and growth (16.70%).

- Anatomical distribution
The face was a prominent lesion site across all three categories, ranking first among malignant (29.48%) and benign lesions (28.11%) and second among pre-cancerous lesions (21.04%). Pre-cancerous lesions showed a different anatomical pattern, occurring most frequently on the forearm (36.44%), while the back was the second most common site for benign lesions (21.00%) and the chest for malignant lesions (15.03%).

- Demographic Patterns
Malignant and pre-cancerous lesions were concentrated among older patients. Among patients with malignant lesions, 89.88% were aged 46 years or above, compared with 86.11% of patients with pre-cancerous lesions. In contrast, benign lesions were distributed more broadly across every age group, including younger age groups. The combined age and gender analysis also showed substantial male representation across the major age groups, particularly among pre-cancerous lesions.

- Clinical history
Clinical history showed a pronounced difference across lesion categories. Among patients with malignant lesions, 54.05% had a family history of cancer and 45.38% had a previous skin cancer diagnosis. These characteristics were considerably less prevalent among patients with pre-cancerous lesions (14.53% and 11.71%, respectively) and benign lesions (6.41% and 4.63%, respectively).

 ### Overall Synthesis
The lesion categories were not characterised by a single distinguishing factor, but by combinations of clinical, demographic and patient history characteristics. Malignant lesions showed the broadest clinical feature profile, with particularly pronounced differences in bleeding and pain compared with benign lesions, and were concentrated among older patients. Family history of cancer and previous skin cancer diagnosis were also substantially more prevalent among patients with malignant lesions. Pre-cancerous lesions were strongly characterised by itching, older age and a concentration on the forearm, while benign lesions showed a broader age distribution and comparatively low prevalence of bleeding, pain and cancer history characteristics.

These patterns are descriptive associations within the analysed dataset and identify areas for more focused investigation. However, they do not establish clinical predictors or causal relationships.

## Analytical Implications
Linking patient and lesion data provided a more complete analytical view than examining either dataset independently, enabling clinical lesion characteristics to be considered alongside patient demographics and clinical history.
The analysis suggests that the broader lesion categories are characterised by combinations of features rather than any single characteristic in isolation. The pronounced descriptive differences observed in clinical presentation, age distribution and clinical history therefore provide focused areas for subsequent investigation using larger datasets and more rigorous statistical or predictive methods.

## Data Quality & Limitations
Several data quality issues were identified during profiling. Categorical inconsistencies that could be resolved confidently were standardised, while ambiguous values were retained and documented rather than altered without supporting evidence. In particular, `diameter_1` and `diameter_2` contained zero values in 581 records (53.40%), while `fitspatrick` contained 579 observations coded as 0 despite the documented Fitzpatrick scale ranging from 1–6. All records with `fitspatrick` = 0 also contained zero values for both lesion diameter measurements, indicating a systematic data quality issue whose meaning could not be established from the available documentation. These values were therefore remained untouched, and the affected variables were not used in subsequent relationship or lesion category analyses.
Substantial unknown values were also present in `background_father` and `background_mother`, limiting meaningful analysis of parental background associated with lesions.
The analysis is exploratory and descriptive. Observed differences across diagnoses and lesion categories represent patterns within this dataset and should not be interpreted as causal relationships, clinical risk estimates or diagnostic criteria. Diagnostic groups were unevenly represented, with particularly few MEL cases (n = 17), requiring caution when interpreting comparisons across diagnoses. 
The data are also specific to the commissioning organisation, which may limit the generalisability of the findings to wider patient populations. No inferential testing or predictive modelling was undertaken.


## Repository Structure

```tree
skin-lesion-diagnosis-sql-analysis/
│
├── README.md
├── raw dataset
│   └── skin_lesion_dataset.sql
│
├── sql scripts/
│   ├── 01_data_quality_cleaning.sql
│   ├── 02_exploratory_analysis.sql
│   └── 03_lesion_classification_analysis.sql
│
├── visuals/
│   ├── charts/
│   │   ├── 01_diagnosis_distribution.png
│   │   ├── 02_lesion_category_distribution.png
│   │   ├── 03_clinical_features.png
│   │   ├── 04_anatomical_distribution.png
│   │   ├── 05_age_gender_distribution.png
│   │   └── 06_clinical_history.png
│   │
│   └── skin_lesion_visualisations.xlsx
│
├── documentation/
   ├── project charter.md
    ├── data dictionary.md
    ├── full_project_report.pdf
    └── executive memo.pdf
```

## Skills Demonstrated
1. Technical Skills - SQL, Data Manipulation & Management
I used PostgreSQL to clean, transform, aggregate and analyse patient and lesion data.
- Data profiling and validation: I assessed completeness, duplicates, categorical consistency, value ranges and data type suitability across two related datasets.
- Data cleaning and transformation: I standardised identifiable inconsistencies while retaining and documenting ambiguous values where correction could not be justified.
- Relational data integration: I linked patient and lesion-level datasets through patient_id and created reusable analytical views.
- Advanced SQL querying: I used joins, aggregate functions, conditional aggregation,  window functions, CASE expressions, filtered aggregates and CROSS JOIN LATERAL to reshape and analyse the data.
- View creation and diagnostic classification: I developed unified and classified analytical views to support progressively deeper analysis.

2. Analytical Skills
- Exploratory data analysis: I progressed from independent patient and lesion profiling to linked diagnosis-level and broader lesion category analysis.
- Analytical question design: I structured SQL queries around clearly defined questions and selected appropriate denominators for categorical and Boolean variables.
- Comparative analysis: I examined how demographics, clinical features, anatomical location, clinical history, lifestyle and environmental characteristics varied across diagnoses and lesion categories.
- Critical interpretation: I distinguished descriptive association from causation or prediction and avoided drawing conclusions unsupported by the dataset.
- Data quality judgement: I differentiated correctable quality issues from ambiguous observations requiring documentation rather than arbitrary modification.

3. Documentation & Reproducibility
- Reproducible analytical workflow: I organised SQL scripts sequentially from cleaning through EDA to category-level analysis.
- Technical documentation: I documented source variables, transformations, diagnostic classifications, analytical objects and data quality decisions.
- Communication of findings: I translated detailed SQL outputs into concise findings appropriate for technical and executive audiences.

## Reproducing the Analysis
1. Set up a PostgreSQL database and import the raw source dataset.
2. Run the SQL scripts sequentially:
- [**01_data_quality_assessment.sql**](https://github.com/engmanncornelius-pixel/healthcare_analytics/blob/58eaddebd3d92175c76b82517aea1f8624b9bccc/skin-lesion-diagnosis-analysis/sql_scripts/01_data_quality_assessment.sql) (Data Quality Assessment): It profiles the raw data and assesses data quality, including completeness, duplicates, categorical consistency, value ranges and other potential issues.
- [**02_exploratory_analysis.sql**](https://github.com/engmanncornelius-pixel/healthcare_analytics/blob/58eaddebd3d92175c76b82517aea1f8624b9bccc/skin-lesion-diagnosis-analysis/sql_scripts/02_exploratory_analysis.sql) (Data Cleaning, Transformation & Exploratory Analysis): It applies justified cleaning and transformation decisions, creates and validates the cleaned tables, conducts the exploratory analysis, and creates the unified analytical view for diagnosis-level analysis.
- [**03_lesion_category_analysis.sql**](https://github.com/engmanncornelius-pixel/healthcare_analytics/blob/58eaddebd3d92175c76b82517aea1f8624b9bccc/skin-lesion-diagnosis-analysis/sql_scripts/03_lesion_classification_analysis.sql) (Lesion Classification Analysis): It creates the classified analytical view and examines patterns across benign, pre-cancerous and malignant lesion categories.
3. Review the Data Dictionary for source variable definitions, data types and coding, diagnostic code mappings, analytical notes and derived analytical objects.
4. Refer to the full project report for the complete analytical methodology, findings, interpretations, visualisations, data quality decisions and limitations.

## Supporting Documentation
| Document | Purpose |
|---|---|
| [**Project Charter**](https://github.com/engmanncornelius-pixel/healthcare_analytics/blob/main/skin-lesion-diagnosis-analysis/documentation/project_charter.md) | Defines the healthcare problem, project objective, scope, analytical questions, stakeholder, deliverables, success criteria and limitations. |
| [**Data Dictionary**](https://github.com/engmanncornelius-pixel/healthcare_analytics/blob/58eaddebd3d92175c76b82517aea1f8624b9bccc/skin-lesion-diagnosis-analysis/documentation/data_dictionary.md) | Documents source variables, data types, coding, analytical notes, diagnostic code mappings and derived analytical objects. |
| [**Full Project Report**](documentation/full_project_report.pdf) | Provides the complete methodology, analysis, findings, discussion, visualisations, limitations and recommendations. |
| [**Executive Memo**](https://github.com/engmanncornelius-pixel/healthcare_analytics/blob/58eaddebd3d92175c76b82517aea1f8624b9bccc/skin-lesion-diagnosis-analysis/documentation/executive_memo.pdf) | Summarises the business problem, method, key findings, recommendations, limitations and next steps for a non-technical audience. |
| [**Visualisation Workbook**](https://github.com/engmanncornelius-pixel/healthcare_analytics/blob/58eaddebd3d92175c76b82517aea1f8624b9bccc/skin-lesion-diagnosis-analysis/visuals/skin_lesion_visualisations.xlsx) | Contains the supporting analytical outputs, chart-preparation tables and final project visualisations. |

