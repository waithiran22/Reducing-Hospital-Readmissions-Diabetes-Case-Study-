-- analysis/cost_analysis.sql
-- Core analysis queries for Pharmaceutical Cost Optimization Dashboard
-- Assumes canonical tables (Drugs, Providers, Prescriptions) are populated.
-- Adjust field names as needed for your CMS Part D mapping.

/***********************
  1) Brand vs Generic Summary
***********************/
WITH costs AS (
  SELECT 
    d.generic_name,
    d.brand_name,
    SUM(p.total_cost) AS total_cost,
    SUM(p.claims_count) AS total_claims,
    CAST(SUM(p.total_cost) AS DECIMAL(18,2)) / NULLIF(SUM(p.claims_count),0) AS avg_cost_per_claim
  FROM Prescriptions p
  JOIN Drugs d ON p.drug_id = d.drug_id
  GROUP BY d.generic_name, d.brand_name
)
SELECT *
FROM costs
ORDER BY avg_cost_per_claim DESC;

/***********************
  2) Generic Substitution Savings Opportunity
     - Estimate savings if brand claims are substituted with generic avg cost
***********************/
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
    CAST(SUM(total_cost) AS DECIMAL(18,2)) / NULLIF(SUM(claims_count),0) AS generic_avg_cost_per_claim
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
  CAST(a.brand_total_claims * g.generic_avg_cost_per_claim AS DECIMAL(18,2)) AS hypothetical_generic_cost,
  CAST(a.brand_total_cost - (a.brand_total_claims * g.generic_avg_cost_per_claim) AS DECIMAL(18,2)) AS potential_savings
FROM agg a
JOIN generic_avg g
  ON a.generic_name = g.generic_name
WHERE a.brand_name IS NOT NULL
ORDER BY potential_savings DESC;

/***********************
  3) Regional Variance (State-Level)
***********************/
SELECT 
  pr.state,
  d.generic_name,
  SUM(p.total_cost) AS total_cost,
  SUM(p.claims_count) AS total_claims,
  CAST(SUM(p.total_cost) AS DECIMAL(18,2)) / NULLIF(SUM(p.claims_count),0) AS avg_cost_per_claim
FROM Prescriptions p
JOIN Drugs d ON p.drug_id = d.drug_id
JOIN Providers pr ON pr.provider_id = p.provider_id
GROUP BY pr.state, d.generic_name
ORDER BY d.generic_name, pr.state;

/***********************
  4) Price Acceleration (YoY) – shortage signal proxy
     Requires 'year' to be populated in Prescriptions
***********************/
WITH yearly AS (
  SELECT 
    d.generic_name,
    d.brand_name,
    p.year,
    CAST(SUM(p.total_cost) AS DECIMAL(18,2)) / NULLIF(SUM(p.claims_count),0) AS avg_cost_per_claim
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
