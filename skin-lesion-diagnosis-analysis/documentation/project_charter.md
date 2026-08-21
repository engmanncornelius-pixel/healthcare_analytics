# PROJECT CHARTER

## Problem statement
Skin cancer detection is a complex healthcare challenge because both patient characteristics and the manner in which skin lesions present clinically can vary considerably. Recognising clinically relevant lesion characteristics can support the early identification of potentially concerning lesions, which is important because early detection can improve patient outcomes.
The source dataset for this project consisted of two related tables: a patient-level table containing demographics, clinical history, lifestyle habits and environmental factors; and a lesion-level table containing diagnoses, anatomical locations and clinical features. Analysing either table independently provides only a limited view of the problem. Linking both tables through their common patient identifier enables exploration of how patient and lesion characteristics vary across diagnoses and whether identifiable patterns distinguish malignant, pre-cancerous and benign lesions. Understanding these relationships can provide data-driven insights to support further clinical investigation, dermatological research and future analytical applications.

## Project Objective
To explore linked patient and lesion characteristics, identify patterns across lesion diagnoses, and examine characteristics that distinguish malignant, pre-cancerous and benign lesions.

## Project Scope
The project involves:
(i) Data quality assessment and cleaning: Inspecting the two source tables, identifying data quality issues, making appropriate cleaning decisions, validating the cleaned data, and creating cleaned tables.
(ii) Patient-lesion linkage: Linking the patient-level and lesion-level tables through the common `patient_id` and creating a unified analytical view.
(iii) Exploratory data analysis: Profiling patient and lesion characteristics independently before examining relationships between them. The linked analysis investigates how lesion diagnoses vary across patient demographics, clinical features, anatomical locations, clinical history, lifestyle habits, and environmental characteristics.
(iv) Lesion category analysis: Classifying lesion diagnoses into benign, pre-cancerous, and malignant categories and examining the characteristics that differentiate these broader groups.

Scope boundary: The project is limited to exploratory and descriptive analysis of the supplied data. Predictive modelling and causal analysis are outside the project scope.

## Key Analytical Questions
1. What are the demographic, clinical, lifestyle, and environmental characteristics of the patient population?
2. What are the diagnostic, anatomical, clinical, and physical characteristics of the recorded skin lesions?
3. How do patient and lesion characteristics vary across individual lesion diagnoses?
4. How do the characteristics of benign, pre-cancerous, and malignant lesions differ?
5. Which patient and lesion characteristics show the clearest descriptive differences between malignant and benign lesions?

## Stakeholder
Derm AI Diagnostics — the commissioning organisation and primary stakeholder. The analysis is intended to provide its analytics, research and data science functions with a structured exploration of linked patient and lesion data, highlighting patterns that may warrant further investigation.

## Deliverables 
1. Cleaned and validated patient-level and lesion-level tables.
2. Unified and classified analytical views.
3. Clean and documented SQL scripts.
4. Data dictionary, including source variable definitions, diagnostic abbreviations and lesion classifications.
5. Full project report containing the methodology, analysis, findings, visualisations, discussion, limitations and recommendations.
6. Supporting visualisation workbook and selected chart outputs.
7. GitHub README
8. Executive-style PDF memo

## Success Criteria
The project will be considered successful if:
- The two source tables are systematically assessed, cleaned and validated to produce analysis-ready data.
- Patient and lesion data are successfully linked through the common `patient_id`, enabling analysis across both tables.
- The major patient and lesion characteristics are systematically explored, both independently and in relation to lesion diagnoses.
- The analysis identifies clear and interpretable descriptive patterns across individual diagnoses and the broader benign, pre-cancerous and malignant categories.
- The findings highlight characteristics and relationships that could warrant more focused subsequent statistical, clinical or predictive investigation.
- The analytical workflow is reproducible and clearly documented, with structured SQL scripts, documented transformations and analytical decisions, a data dictionary, and sufficient supporting documentation for another analyst to understand and reproduce the workflow.

## Project Constraints
- Data availability: The project is limited to the patient and lesion data supplied by the commissioning organisation. Findings therefore reflect the available study population and are not assumed to represent wider patient populations.
- Exploratory analytical scope: The project is designed as a descriptive exploratory analysis. It identifies patterns and differences across lesion diagnoses and categories but does not undertake inferential statistical testing or establish causal relationships.
- No predictive modelling: The project does not develop or validate a model for predicting whether an individual lesion is benign, pre-cancerous or malignant.
- Clinical scope: The analysis is intended to support analytical exploration and further investigation. Its findings are not intended to constitute clinical diagnostic criteria, risk estimates or treatment recommendations.

