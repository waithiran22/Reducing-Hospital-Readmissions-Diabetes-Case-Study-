# Reducing Hospital Readmissions Diabetes Case Study.
Hospital readmissions are costly for healthcare systems and challenging for patients. This project analyzes 25,000 hospital records to identify the strongest predictors of readmission, with a focus on diabetes-related factors and prior healthcare utilization.

---
# Overview

### Key questions:

-Is diabetes itself predictive of readmission?

-How do medication prescriptions and changes affect readmission risk?

-Which patient groups should hospitals target for follow-up interventions?

---
## Methodology
### Data Cleaning & Feature Engineering
-Encoded categorical values (diagnosis, labs, medications).

-Created indicators for diabetes diagnosis, medication prescription, and medication changes.

-Converted age brackets to midpoints for analysis.

---

### Exploratory Data Analysis (EDA)
-Diagnosis trends across age groups.

-Readmission rates by diabetes status and utilization history.

-Bucketing of lab tests, medications, and hospital visits to reveal nonlinear effects.

---

#### Statistical Analysis
-Logistic regression with odds ratios.

-Hypothesis testing to confirm significant differences in readmission rates.

---

### Modeling
-Logistic Regression (baseline, interpretable).

-Random Forest & Lasso Regression for feature importance.

-Performance evaluated with AUROC, PR-AUC, F1 score, and calibration.

-SHAP values to explain top predictors at the patient and population level.

---

### Key Findings
-Diabetes diagnosis alone is not a strong predictor of readmission.

-Medication changes and prescriptions for diabetes are highly predictive of readmission across all age groups.

-History of high hospital utilization (inpatient and emergency visits) is one of the strongest predictors.

### -Patients at highest risk combine:
1.Recent diabetes med changes,

2.Prescription of diabetes medication and

3.Multiple prior hospital/ER visits.

---

### Impact on Healthcare Industry.
Hospitals should: 
-Prioritize follow-up calls and monitoring for patients with new or changed diabetes medications.
-Track patients with frequent ER or inpatient visits as high-risk cohorts.
-Implement risk stratification dashboards to allocate resources effectively.

---

### Tech Stack
-Python: pandas, numpy, scikit-learn, statsmodels

-Visualization: seaborn, matplotlib, SHAP

-Modeling: Logistic Regression, Random Forest, Lasso

