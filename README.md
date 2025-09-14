# Pharmaceutical Cost Optimization Analysis and Dashboard

## Overview
Pharmaceutical costs are a critical challenge in healthcare. With over **$130B in pharmacy spend managed by Vizient**, cost optimization directly impacts provider sustainability and patient access.  

This project analyzes **Medicare Part D data** (publicly available from CMS) to uncover pricing inefficiencies, model generic substitution impact, and forecast potential savings. By applying **data engineering, SQL, Python, and forecasting models**, I built a framework to identify where brand-to-generic substitutions and regional optimization can reduce costs without compromising care.

Due to the large size of the CMS datasets (10GB+), this repository includes a **sample dataset** for demonstration, while the ETL and analysis pipeline are designed for the full prescriber-level data.

---

## Why This Project Matters
Pharmaceutical costs are one of the largest drivers of U.S. healthcare spending.  
- - Medicare Part D spending exceeds **$130B annually**  
- A 2–3% savings translates to **billions of dollars**  
- Reducing costs without lowering quality of care improves **access and sustainability**    

For me personally, this project is about more than just numbers.  
As someone passionate about **data-driven impact**, I wanted to apply my analytics skills to a sector that touches millions of lives. Healthcare is an area where **the right analysis can literally improve access to life-saving treatments** and that motivates me to do my best work.

---

## Project Scope & Structure
This project was built in four phases to simulate a real-world healthcare analytics workflow:  

###  Phase 1: Data Foundation 
- Imported **CMS Medicare Part D Prescriber PUF** (CSV) into **SQL + Python (Pandas)**  
- Standardized drug names, handled missing values, and normalized formats  
- Designed a relational schema:
  - **Drugs** → drug_id, brand_name, generic_name, category, unit_cost  
  - **Prescriptions** → provider_id, drug_id, claims_count, total_cost, year  
  - **Providers** → provider_id, specialty, state, region  
  - **Geography** → state, region, population  

###  Phase 2: Cost Analysis
- **Generic vs Brand analysis** across therapeutic categories  
- **Regional price variance** analysis by state/provider  
- **Shortage impact modeling** using forecasting techniques  
- Outputs: cost optimization opportunities, prescriber trends, formulary efficiency  

###  Phase 3: Dashboard Creation
- Built an **interactive Power BI dashboard** with key  KPIs  
- Features:  
  - Filters by drug category, region, and year  
  - Brand vs Generic cost savings calculator  
  - Regional heatmaps of cost variance  

###  Phase 4: Business Impact
- Projected **$10M+ savings opportunities** in sample scenarios  
- Developed **executive-ready summary visuals** for healthcare decision makers  

---

##  Programs & Tools Used
- **SQL (SQLite, SQLAlchemy)** → schema design, cost aggregation, variance queries  
- **Python (Pandas, NumPy, Matplotlib)** → ETL pipeline, cleaning, forecasting  
- **Power BI** → interactive dashboards, KPI measures, executive-ready visuals  
- **Excel** → quick data validation and cross-checking  
- **GitHub** → version control, reproducibility, collaboration  

---

## Key Snippets

**ETL Pipeline (Python + Pandas)**
```python
# Load raw CMS file in chunks
chunksize = 500000
for chunk in pd.read_csv("Medicare_PartD_Prescriber.csv", chunksize=chunksize):
    chunk.to_sql("prescriptions", con=engine, if_exists="append", index=False)
```
## SQL Cost Savings Query
```sql
SELECT 
    d.generic_name,
    SUM(p.total_cost) AS brand_cost,
    SUM(p_generic.total_cost) AS generic_cost,
    (SUM(p.total_cost) - SUM(p_generic.total_cost)) AS potential_savings
FROM prescriptions p
JOIN drugs d ON p.drug_id = d.drug_id
JOIN prescriptions p_generic ON d.generic_name = p_generic.generic_name
WHERE d.is_brand = 1
GROUP BY d.generic_name
ORDER BY potential_savings DESC;
```
---
## Challenges
-Data size → CMS files are very large, so I used a sample dataset for testing

-Drug name standardization → the same drug can appear under multiple names

-Regional differences → incomplete reporting in some states

-Mapping brand to generic → not always straightforward

## Key Findings 
-Brand drugs = ~12% of claims but ~70% of costs

-Substituting generics in key drug classes (e.g., statins, PPIs) could save millions annually

-Some states consistently paid 20–30% more for the same generics

## Future Work
-Use machine learning to forecast drug shortages

-Add provider-level prescribing analysis to detect waste or fraud

-Expand dashboard with cost-per-beneficiary benchmarks

-Extend analysis to multiple CMS years

---
## Project Structure

```graphql
pharma-cost-optimization/
│── analysis/          # SQL + Python scripts
│── data/              # sample dataset (not full CMS file)
│── docs/              # methodology, data dictionary, references
│── etl/               # ETL pipeline
│── outputs/           # results (CSV)
│── powerbi/           # dashboard measures and visuals
│── README.md          # project documentation
│── requirements.txt   # Python dependencies
│── schema.sql         # database schema
```
## How to ReProduce
1. Clone the Repo:
   ```bash
   git clone https://github.com/yourusername/pharma-cost-optimization.git
   ```
2. Install dependencies:
```bash 
pip install -r requirements.txt
```
3. Run ETL on sample data:
 ```bash 
python etl/load_partd.py data/sample_prescriber.csv
```
4.Run analysis
```bash 
python analysis/cost_analysis.py
```
5. Import results into Power BI:

-Load CSVs from outputs/

-Apply measures from powerbi/MEASURES.md

-Explore the dashboard

## Closing Note

This project reflects my interest in applying analytics to healthcare cost optimization. It’s a space where data can improve both financial sustainability and patient access, and I’m eager to keep building my skills in this area.
