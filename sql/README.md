# SQL Analysis (Google BigQuery)

Following the initial data modeling and visualization in Power BI, I leveraged **Google BigQuery** to perform end-to-end Exploratory Data Analysis (EDA). The analytical workflow covers data consolidation, data completeness auditing, macro-level metric aggregations, and regional drill-downs.

---

## 🔑 Key Findings & Data Insights

### 1. South Asia Health Expenditure Surge (+286.95%)
* **Finding:** When comparing baseline health expenditure per capita (`chex_pc`) between the early 2000s (2000–2004) and recent years (2019–2023), **South Asia** demonstrated the highest relative growth among all World Bank regions (+286.95%).
* **Country Drill-Down:** Regional breakdown revealed that this surge was uniform across all countries in the region rather than driven by a single outlier:
  * **Nepal:** +565.79%
  * **Bangladesh:** +463.42%
  * **Bhutan:** +291.28%
  * **Maldives:** +275.38%
  * **Sri Lanka:** +262.18%
  * **India:** +248.15%
* **Analytical Note:** Identifying the macroeconomic, policy, or demographic drivers behind this uniform regional trend lies outside the scope of quantitative SQL data alone, requiring qualitative policy research.

### 2. Life Expectancy Gains in Sub-Saharan Africa
* **Finding:** Exploratory queries tracking life expectancy across World Bank regions highlighted **Sub-Saharan Africa** as a standout region, showing significant gains in life expectancy over the 2000–2023 study period.
* **Analytical Note:** While the trend in raw health metrics is strongly positive, investigating the exact underlying factors (e.g., healthcare infrastructure, disease control initiatives, international aid) lies beyond the current quantitative dataset.

---

## 📂 Analytical Framework & Methodology

1. **Data Infrastructure:** Consolidated raw economic (GDP), healthcare expenditure (`chex_pc`, `che_gdp`), inequality (Gini index), demographic, and regional tables into a unified analytical base view.
2. **Data Quality & Completeness Audit:** Evaluated data availability and consistency over time (specifically for market vs. disposable Gini indices) to ensure analytical validity.
3. **5-Year Baseline Comparison:** Utilized 5-year averages (2000–2004 vs. 2019–2023) to eliminate short-term annual volatility when calculating absolute and percentage growth.
4. **Regional & Country Drill-Downs:** Conducted targeted queries to isolate top-performing regions and dissect country-level contributions.

---

## 🛠️ Key SQL Queries & Implementation

### 1. Base View Architecture (Data Consolidation)
*Combines raw relational tables into a single source of truth for downstream analysis.*

```sql
SELECT
  country.country_code,
  country.country_name,
  gdp.year,
  gdp.gdp_usd,
  che_gdp.che_gdp,
  gini.gini_disp,
  gini.gini_mkt,
  dem_div.dd_name,
  income_group.incomegroup_name,
  region.region_name,
  life_expect.life_expect,
  chex_pc.chex_pc
FROM `health-wealth-analysis.raw_data.gdp` AS gdp
LEFT JOIN `health-wealth-analysis.raw_data.che_gdp` AS che_gdp
  ON che_gdp.country_code = gdp.country_code AND che_gdp.year = gdp.year
LEFT JOIN `health-wealth-analysis.raw_data.gini` AS gini
  ON gini.country_code = gdp.country_code AND gini.year = gdp.year
LEFT JOIN `health-wealth-analysis.raw_data.country` AS country
  ON country.country_code = gdp.country_code
LEFT JOIN `health-wealth-analysis.raw_data.dem_div` AS dem_div
  ON dem_div.dd_code = country.dd_code
LEFT JOIN `health-wealth-analysis.raw_data.income_group` AS income_group
  ON income_group.incomegroup_code = country.incomegroup_code
LEFT JOIN `health-wealth-analysis.raw_data.region` AS region
  ON region.region_code = country.region_code
LEFT JOIN `health-wealth-analysis.raw_data.life_expect` AS life_expect
  ON life_expect.country_code = gdp.country_code AND life_expect.year = gdp.year
LEFT JOIN `health-wealth-analysis.raw_data.chex_pc` AS chex_pc
  ON chex_pc.country_code = gdp.country_code AND chex_pc.year = gdp.year;
```

---

### 2. Data Quality & Redistribution Effect Audit
*Assesses annual data availability and evaluates state redistribution efficiency (market Gini − disposable Gini).*

```sql
SELECT
  year,
  AVG(gini_mkt - gini_disp) AS avg_redistribution_effect,
  COUNT(country_code) AS country_count
FROM health-wealth-analysis.raw_data.base_view
WHERE gini_mkt IS NOT NULL AND gini_disp IS NOT NULL
GROUP BY year
ORDER BY year;
```

---

### 3. Health Expenditure Trend by Region
*Calculates 5-year baseline averages (2000–2004 vs. 2019–2023) to measure absolute and relative expenditure growth across global regions.*

```sql
WITH spending_by_region AS (
  SELECT
    region_name,
    ROUND(AVG(CASE WHEN year BETWEEN 2000 AND 2004 THEN chex_pc END), 2) AS avg_early,
    ROUND(AVG(CASE WHEN year BETWEEN 2019 AND 2023 THEN chex_pc END), 2) AS avg_late
  FROM health-wealth-analysis.raw_data.base_view
  WHERE chex_pc IS NOT NULL
  GROUP BY region_name
)
SELECT
  region_name,
  avg_early,
  avg_late,
  ROUND(avg_late - avg_early, 2) AS absolute_change,
  ROUND(SAFE_DIVIDE(avg_late - avg_early, avg_early) * 100, 2) AS percentage_change
FROM spending_by_region
ORDER BY percentage_change DESC;
```

---

### 4. Health Expenditure Trend by Income Group
*Compares healthcare expenditure per capita across World Bank income brackets.*

```sql
WITH spending_by_income AS (
  SELECT
    incomegroup_name,
    ROUND(AVG(CASE WHEN year BETWEEN 2000 AND 2004 THEN chex_pc END), 2) AS avg_early,
    ROUND(AVG(CASE WHEN year BETWEEN 2019 AND 2023 THEN chex_pc END), 2) AS avg_late
  FROM health-wealth-analysis.raw_data.base_view
  WHERE incomegroup_name IS NOT NULL AND chex_pc IS NOT NULL
  GROUP BY incomegroup_name
)
SELECT
  incomegroup_name,
  avg_early,
  avg_late,
  ROUND(avg_late - avg_early, 2) AS absolute_change,
  ROUND(SAFE_DIVIDE(avg_late - avg_early, avg_early) * 100, 2) AS percentage_change
FROM spending_by_income
ORDER BY percentage_change DESC;
```

---

### 5. Country Drill-Down: South Asian Healthcare Growth
*Investigates country-level dynamics driving South Asia's regional growth surge.*

```sql
WITH spending_by_country AS (
  SELECT
    country_name,
    ROUND(AVG(CASE WHEN year BETWEEN 2000 AND 2004 THEN chex_pc END), 2) AS avg_early,
    ROUND(AVG(CASE WHEN year BETWEEN 2019 AND 2023 THEN chex_pc END), 2) AS avg_late
  FROM health-wealth-analysis.raw_data.base_view
  WHERE chex_pc IS NOT NULL AND region_name = 'South Asia'
  GROUP BY country_name
)
SELECT
  country_name,
  avg_early,
  avg_late,
  ROUND(avg_late - avg_early, 2) AS absolute_change,
  ROUND(SAFE_DIVIDE(avg_late - avg_early, avg_early) * 100, 2) AS percentage_change
FROM spending_by_country
ORDER BY percentage_change DESC;
```

---

### 6. Overall Regional Life Expectancy
*Calculates long-term average life expectancy across World Bank regions.*

```sql
SELECT
  r.region_name,
  ROUND(AVG(l.life_expect), 1) AS avg_life_expectancy
FROM `health-wealth-analysis.raw_data.life_expect` AS l
LEFT JOIN `health-wealth-analysis.raw_data.country` AS c
  ON l.country_code = c.country_code
LEFT JOIN `health-wealth-analysis.raw_data.region` AS r
  ON c.region_code = r.region_code
WHERE r.region_name IS NOT NULL
GROUP BY r.region_name
ORDER BY avg_life_expectancy DESC;
```

---

### 7. Country vs. Regional Life Expectancy Gap Evolution
*Measures how individual countries perform relative to their regional average between 2000 and 2023 using window functions and pivoting.*

```sql
WITH life_expect_by_year AS (
  SELECT
    country_name,
    region_name,
    year,
    life_expect,
    ROUND(AVG(life_expect) OVER (PARTITION BY region_name, year), 2) AS region_avg
  FROM `health-wealth-analysis.raw_data.base_view`
  WHERE year IN (2000, 2023)
    AND life_expect IS NOT NULL
    AND region_name IS NOT NULL
),
pivoted AS (
  SELECT
    country_name,
    region_name,
    MAX(CASE WHEN year = 2000 THEN life_expect END) AS life_expect_2000,
    MAX(CASE WHEN year = 2000 THEN region_avg END) AS region_avg_2000,
    MAX(CASE WHEN year = 2023 THEN life_expect END) AS life_expect_2023,
    MAX(CASE WHEN year = 2023 THEN region_avg END) AS region_avg_2023
  FROM life_expect_by_year
  GROUP BY country_name, region_name
)
SELECT
  country_name,
  region_name,
  ROUND((life_expect_2000 - region_avg_2000), 2) AS gap_2000,
  ROUND((life_expect_2023 - region_avg_2023), 2) AS gap_2023,
  ROUND((life_expect_2023 - region_avg_2023) - (life_expect_2000 - region_avg_2000), 2) AS gap_change
FROM pivoted;
```

---

## 🚀 Next Steps
* Transitioning to **R** for statistical modeling, correlation analysis, and regression testing to evaluate relationships between GDP, healthcare investment, and life expectancy metrics.
