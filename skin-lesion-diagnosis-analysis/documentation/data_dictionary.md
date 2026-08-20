# DATA DICTIONARY 

## 1. Main Data Dictionary

### Table 1 — Patient-level data
| Column Name | Data Type | Description | Values / Coding | Analytical Notes |
|---|---|---|---|---|
| `patient_id` (PK) | Identifier (`character varying 255`) | Unique identifier for each patient | Unique patient value | Primary linkage field used to connect patient and lesion data |
| `smoke` | Boolean | Whether the patient smokes | `true` / `false` | Lifestyle characteristic |
| `drink` | Boolean | Whether the patient drinks alcohol | `true` / `false` | Lifestyle characteristic |
| `background_father` | Categorical (`character varying 255`) | Patient's paternal background | Country labels | Referred to as paternal background in this analysis because the recorded values include country/national-background labels and do not consistently represent ethnicity. During cleaning, `BRASIL` was standardised to `BRAZIL`; `UNK` was standardised to `UNKNOWN`. |
| `background_mother` | Categorical (`character varying 255`) | Patient's maternal background | Country labels | Referred to as maternal background in this analysis because the recorded values include country/national-background labels and do not consistently represent ethnicity. `UNK` was standardised to `UNKNOWN` during cleaning. |
| `age` | Numerical (`integer`) | Age of patient | Years | Observed range: 6–94 years; used to derive age groups for analysis |
| `pesticide` | Boolean | Exposure to pesticides | `true` / `false` | Environmental exposure characteristic |
| `gender` | Categorical (`character varying 10`) | Gender of patient | `MALE` / `FEMALE` | Used in demographic analysis |
| `skin_cancer_history` | Boolean | Previous skin cancer diagnosis | `true` / `false` | Patient clinical-history characteristic |
| `cancer_history` | Boolean | Family history of cancer | `true` / `false` | Source brief defines this as family history, not previous personal cancer diagnosis |
| `has_piped_water` | Boolean | Access to piped water | `true` / `false` | Household/environmental characteristic |
| `has_sewage_system` | Boolean | Access to sewage system | `true` / `false` | Household/environmental characteristic |

### Table 2 — Lesion-level data
| Column Name | Data Type | Description | Values / Coding | Analytical Notes |
|---|---|---|---|---|
| `lesion_id` (PK) | Identifier (`integer`) | Lesion identifier within the patient-lesion structure | Integer identifier | Not globally unique; 81 lesion identifiers are reused across records belonging to different patients. The combination (`patient_id`, `lesion_id`) uniquely identifies lesion records and forms the composite primary key. |
| `patient_id` (PK) | Identifier (`character varying 255`) | Patient identifier associated with the lesion | Corresponds to `patient_id` in patient table | Part of the composite primary key (`patient_id`, `lesion_id`); also used to link the two source tables |
| `fitspatrick` | Ordinal categorical (`integer`) | Fitzpatrick skin type | Expected: 1–6 | Source brief uses *fitzpatrick*, but imported dataset column is misspelled `fitspatrick`; 0 values were identified despite the documented valid scale being 1–6 |
| `region` | Categorical (`character varying 255`) | Body region of the lesion | 14 anatomical regions | Used in anatomical distribution analysis |
| `diameter_1` | Numerical (`double precision`) | Diameter of lesion | Millimetres | 53.40% of records contained 0 mm; meaning of zeros could not be verified |
| `diameter_2` | Numerical (`double precision`) | Second diameter measurement | Millimetres | 53.40% of records contained 0 mm; meaning of zeros could not be verified |
| `diagnostic` | Categorical (`character varying 255`) | Type of skin lesion | `ACK`, `BCC`, `MEL`, `NEV`, `SCC`, `SEK` | Full names and broader classifications documented separately below |
| `itch` | Boolean | Whether the lesion causes itching | `true` / `false` | Clinical feature |
| `grew` | Boolean | Whether the lesion has grown | `true` / `false` | Clinical feature |
| `hurt` | Boolean | Whether the lesion causes pain | `true` / `false` | Clinical feature |
| `changed` | Boolean | Whether the lesion changed in colour/size | `true` / `false` | Clinical feature |
| `bleed` | Boolean | Whether the lesion bleeds | `true` / `false` | Clinical feature |
| `elevation` | Boolean | Whether the lesion is raised | `true` / `false` | Clinical/morphological feature |
| `img_id` | Identifier (`character varying 255`) | Associated lesion image filename | Image identifier / filename | Treated primarily as an identifier rather than an analytical variable |
| `biopsed` | Boolean | Whether the lesion was biopsy-confirmed | `true` / `false` | Clinical-management characteristic |


## 2. Diagnostic Code, Full Name and Classification
The source dataset records lesion diagnoses using abbreviated diagnostic codes. The project brief did not provide the corresponding full clinical names or broader classifications; these were therefore documented during the analytical stage using established dermatological terminology to support interpretability and category-level analysis. The original diagnostic codes remained unchanged in the data.
| Code | Full Diagnostic Name | Classification |
|---|---|---|
| `ACK` | Actinic Keratosis | Pre-cancerous |
| `BCC` | Basal Cell Carcinoma | Malignant |
| `MEL` | Melanoma | Malignant |
| `NEV` | Melanocytic Naevus | Benign |
| `SCC` | Squamous Cell Carcinoma | Malignant |
| `SEK` | Seborrhoeic Keratosis | Benign |


## 3. Derived Analytical Objects
The following tables, views, and derived fields were created during data preparation and analysis. They were not part of the original source tables but were developed to support data cleaning, dataset linkage, exploratory analysis, and lesion category analysis.
| Analytical Object | Object Type | Derived From | Purpose / Transformation | Analytical Use |
|---|---|---|---|---|
| `cleaned_table1` | Table | Patient-level source table | Creates the cleaned patient table following standardisation of identified categorical inconsistencies | Used as the analysis-ready patient table |
| `cleaned_table2` | Table | Lesion-level source table | Creates the analysis-ready lesion table following data-quality assessment; no source values were transformed because no validated cleaning actions were identified | Used as the analysis-ready lesion table |
| `unified_skin_lesion_data` | View | `cleaned_table1` + `cleaned_table2` | Links patient and lesion records using the common `patient_id` | Enables analysis of relationships between patient characteristics and lesion diagnoses/features |
| `classified_skin_lesion_data` | View | `unified_skin_lesion_data` | Extends the unified analytical data by grouping individual lesion diagnoses into broader diagnostic categories | Used for category-level analysis of benign, pre-cancerous and malignant lesions |
| `diagnosis_category` | Derived categorical field | `diagnostic` | Maps `BCC`, `SCC`, `MEL` → `MALIGNANT`; `ACK` → `PRE-CANCEROUS`; `NEV`, `SEK` → `BENIGN` | Provides the principal grouping variable for lesion-category analysis |
| `age_group` | Derived categorical field | `age` | Groups patient age into 0–15, 16–30, 31–45, 46–60, 61–75 and 76+ | Used to make age distributions more interpretable when examining patient demographics |

