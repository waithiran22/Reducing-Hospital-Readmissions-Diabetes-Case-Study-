-- Core tables
CREATE TABLE drugs (
  drug_id INTEGER PRIMARY KEY,
  brand_name TEXT,
  generic_name TEXT,
  category TEXT,
  unit_cost DECIMAL(12,4),
  is_brand INTEGER DEFAULT 0  -- 1=brand, 0=generic
);

CREATE TABLE providers (
  provider_id INTEGER PRIMARY KEY,
  specialty TEXT,
  state TEXT,
  region TEXT
);

CREATE TABLE prescriptions (
  prescription_id INTEGER PRIMARY KEY,
  provider_id INTEGER NOT NULL,
  drug_id INTEGER NOT NULL,
  claims_count INTEGER,
  total_cost DECIMAL(14,2),
  year INTEGER,
  FOREIGN KEY(provider_id) REFERENCES providers(provider_id),
  FOREIGN KEY(drug_id) REFERENCES drugs(drug_id)
);

CREATE TABLE geography (
  state TEXT PRIMARY KEY,
  region TEXT,
  population INTEGER
);

-- Helpful indexes
CREATE INDEX idx_rx_year ON prescriptions(year);
CREATE INDEX idx_rx_drug ON prescriptions(drug_id);
CREATE INDEX idx_rx_provider ON prescriptions(provider_id);
CREATE INDEX idx_drugs_generic ON drugs(generic_name);
CREATE INDEX idx_providers_state ON providers(state);

-- Example view: potential savings by generic
CREATE VIEW v_potential_savings AS
SELECT
  d.generic_name,
  SUM(CASE WHEN d.is_brand=1 THEN p.total_cost ELSE 0 END) AS brand_cost,
  SUM(CASE WHEN d.is_brand=0 THEN p.total_cost ELSE 0 END) AS generic_cost,
  SUM(CASE WHEN d.is_brand=1 THEN p.total_cost ELSE 0 END)
    - SUM(CASE WHEN d.is_brand=0 THEN p.total_cost ELSE 0 END) AS potential_savings
FROM prescriptions p
JOIN drugs d ON p.drug_id = d.drug_id
GROUP BY d.generic_name
ORDER BY potential_savings DESC;
