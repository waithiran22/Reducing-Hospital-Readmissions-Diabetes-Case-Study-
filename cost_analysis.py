# analysis/cost_analysis.py
# Generates CSV outputs for dashboarding: brand vs generic savings, regional variance, and price acceleration.
import os
import pandas as pd
from sqlalchemy import create_engine

DB_URL = os.getenv("DATABASE_URL", "sqlite:///data/medicare_partd.db")
OUTDIR = os.getenv("OUTDIR", "outputs")

os.makedirs(OUTDIR, exist_ok=True)
engine = create_engine(DB_URL)

def run_query(sql: str) -> pd.DataFrame:
    with engine.connect() as conn:
        return pd.read_sql(sql, conn)

def main():
    brand_generic_sql = '''
        WITH agg AS (
          SELECT 
            d.generic_name,
            d.brand_name,
            SUM(p.total_cost) AS brand_total_cost,
            SUM(p.claims_count) AS brand_total_claims
          FROM Prescriptions p
          JOIN Drugs d ON p.drug_id = d.drug_id
          GROUP BY d.generic_name, d.brand_name
        ),
        generic_avg AS (
          SELECT 
            generic_name,
            CAST(SUM(total_cost) AS FLOAT) / NULLIF(SUM(claims_count),0) AS generic_avg_cost_per_claim
          FROM Prescriptions p
          JOIN Drugs d ON p.drug_id = d.drug_id
          GROUP BY generic_name
        )
        SELECT 
          a.generic_name,
          a.brand_name,
          a.brand_total_claims,
          a.brand_total_cost,
          g.generic_avg_cost_per_claim,
          (a.brand_total_claims * g.generic_avg_cost_per_claim) AS hypothetical_generic_cost,
          (a.brand_total_cost - (a.brand_total_claims * g.generic_avg_cost_per_claim)) AS potential_savings
        FROM agg a
        JOIN generic_avg g
          ON a.generic_name = g.generic_name
        WHERE a.brand_name IS NOT NULL
        ORDER BY potential_savings DESC;
    '''
    regional_sql = '''
        SELECT 
          pr.state,
          d.generic_name,
          SUM(p.total_cost) AS total_cost,
          SUM(p.claims_count) AS total_claims,
          CAST(SUM(p.total_cost) AS FLOAT) / NULLIF(SUM(p.claims_count),0) AS avg_cost_per_claim
        FROM Prescriptions p
        JOIN Drugs d ON p.drug_id = d.drug_id
        JOIN Providers pr ON pr.provider_id = p.provider_id
        GROUP BY pr.state, d.generic_name
        ORDER BY d.generic_name, pr.state;
    '''
    yoy_sql = '''
        WITH yearly AS (
          SELECT 
            d.generic_name,
            d.brand_name,
            p.year,
            CAST(SUM(p.total_cost) AS FLOAT) / NULLIF(SUM(p.claims_count),0) AS avg_cost_per_claim
          FROM Prescriptions p
          JOIN Drugs d ON p.drug_id = d.drug_id
          GROUP BY d.generic_name, d.brand_name, p.year
        ),
        lagged AS (
          SELECT 
            y.*,
            LAG(y.avg_cost_per_claim) OVER (PARTITION BY y.generic_name, y.brand_name ORDER BY y.year) AS prev_avg_cost_per_claim
          FROM yearly y
        )
        SELECT 
          generic_name,
          brand_name,
          year,
          avg_cost_per_claim,
          prev_avg_cost_per_claim,
          (avg_cost_per_claim - prev_avg_cost_per_claim) / NULLIF(prev_avg_cost_per_claim,0) AS yoy_change
        FROM lagged
        WHERE prev_avg_cost_per_claim IS NOT NULL
        ORDER BY yoy_change DESC;
    '''
    # Run and save
    brand_generic_df = run_query(brand_generic_sql)
    brand_generic_df.to_csv(f"{OUTDIR}/brand_generic_savings.csv", index=False)

    regional_df = run_query(regional_sql)
    regional_df.to_csv(f"{OUTDIR}/regional_variance.csv", index=False)

    yoy_df = run_query(yoy_sql)
    yoy_df.to_csv(f"{OUTDIR}/shortage_trends_yoy.csv", index=False)

    print("Wrote:",
          "outputs/brand_generic_savings.csv,",
          "outputs/regional_variance.csv,",
          "outputs/shortage_trends_yoy.csv")

if __name__ == "__main__":
    main()
