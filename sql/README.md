# SQL Analysis (Google BigQuery)

Following the Power BI stage of this project, I used **Google BigQuery** to investigate questions that emerged during the visualization process. While the dashboard revealed overall patterns, SQL enabled deeper analysis through aggregation, drill-down exploration, and window functions.

This represents the second stage of the project workflow. The final stage will use **R (Posit)** for statistical modelling and hypothesis testing.

---

# Research Questions

The SQL analysis focused on answering questions that could not be fully explored through visualizations alone:

- How did healthcare expenditure per capita change across World Bank income groups?
- Which World Bank regions experienced the largest increase in healthcare expenditure?
- Was South Asia's exceptional growth driven by a single country or shared across the region?
- How did the redistribution effect (market Gini − disposable Gini) change over time?
- How did the availability of Gini data change throughout the study period?
- How does each country's life expectancy compare with the average of its region?
- Which countries improved or declined relative to their regional average between 2000 and 2023?

---

# Key Findings

## Healthcare Expenditure

To compare long-term trends rather than individual years, healthcare expenditure per capita was averaged over two five-year periods (2000–2004 and 2019–2023).

Among all World Bank regions, **South Asia** recorded the largest increase in healthcare expenditure per capita (**+286.95%**).

A country-level drill-down showed that the regional trend was shared across all South Asian countries rather than being driven by a single outlier.

| Country | Growth |
|:---------|-------:|
| Nepal | +565.79% |
| Bangladesh | +463.42% |
| Bhutan | +291.28% |
| Maldives | +275.38% |
| Sri Lanka | +262.18% |
| India | +248.15% |

The SQL analysis identified the pattern. Explaining the underlying economic or policy drivers requires additional research beyond the available dataset.

---

## Life Expectancy

Regional aggregation highlighted substantial improvements in life expectancy across **Sub-Saharan Africa** during the study period.

Window functions were then used to compare each country's life expectancy with its regional average, making it possible to measure how countries' relative positions changed between 2000 and 2023.

---

## Redistribution Effect & Data Completeness

The redistribution effect was calculated as the difference between **market Gini** and **disposable Gini**.

Before interpreting the results, data completeness was evaluated by counting the number of countries with both Gini measures available each year. The analysis showed that data coverage declined considerably in recent years, an important consideration when interpreting long-term trends.

---

# Methodology & SQL Implementation

The SQL workflow consisted of four main stages.

## 1. Building a Unified Analytical View

A consolidated analytical view was created by joining economic, healthcare, inequality, demographic, and regional datasets into a single country-year table used throughout the analysis.

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
  ON che_gdp.country_code = gdp.country_code
 AND che_gdp.year = gdp.year

LEFT JOIN `health-wealth-analysis.raw_data.gini` AS gini
  ON gini.country_code = gdp.country_code
 AND gini.year = gdp.year

LEFT JOIN `health-wealth-analysis.raw_data.country` AS country
  ON country.country_code = gdp.country_code

LEFT JOIN `health-wealth-analysis.raw_data.dem_div` AS dem_div
  ON dem_div.dd_code = country.dd_code

LEFT JOIN `health-wealth-analysis.raw_data.income_group` AS income_group
  ON income_group.incomegroup_code = country.incomegroup_code

LEFT JOIN `health-wealth-analysis.raw_data.region` AS region
  ON region.region_code = country.region_code

LEFT JOIN `health-wealth-analysis.raw_data.life_expect` AS life_expect
  ON life_expect.country_code = gdp.country_code
 AND life_expect.year = gdp.year

LEFT JOIN `health-wealth-analysis.raw_data.chex_pc` AS chex_pc
  ON chex_pc.country_code = gdp.country_code
 AND chex_pc.year = gdp.year;
```

---

## 2. Monitoring Data Completeness & Redistribution

The first analytical step was to evaluate annual Gini data coverage before analysing redistribution trends.

```sql
SELECT
  year,
  AVG(gini_mkt - gini_disp) AS avg_redistribution_effect,
  COUNT(country_code) AS country_count
FROM health-wealth-analysis.raw_data.base_view
WHERE
  gini_mkt IS NOT NULL
  AND gini_disp IS NOT NULL
GROUP BY year
ORDER BY year;
```

---

## 3. Regional Healthcare Expenditure Analysis

Five-year averages were used to compare healthcare expenditure per capita across World Bank regions while reducing the influence of year-to-year fluctuations.

```sql
WITH spending_by_region AS (
  SELECT
    region_name,
    ROUND(
      AVG(
        CASE
          WHEN year BETWEEN 2000 AND 2004 THEN chex_pc
        END
      ),
      2
    ) AS avg_early,
    ROUND(
      AVG(
        CASE
          WHEN year BETWEEN 2019 AND 2023 THEN chex_pc
        END
      ),
      2
    ) AS avg_late
  FROM health-wealth-analysis.raw_data.base_view
  WHERE chex_pc IS NOT NULL
  GROUP BY region_name
)

SELECT
  region_name,
  avg_early,
  avg_late,
  ROUND(avg_late - avg_early, 2) AS absolute_change,
  ROUND(
    SAFE_DIVIDE(avg_late - avg_early, avg_early) * 100,
    2
  ) AS percentage_change
FROM spending_by_region
ORDER BY percentage_change DESC;
```

---

## 4. Country vs Regional Life Expectancy

Window functions were used to compare each country's life expectancy with the average of its region and calculate how this gap changed between 2000 and 2023.

```sql
WITH life_expect_by_year AS (
  SELECT
    country_name,
    region_name,
    year,
    life_expect,
    ROUND(
      AVG(life_expect) OVER (PARTITION BY region_name, year),
      2
    ) AS region_avg
  FROM `health-wealth-analysis.raw_data.base_view`
  WHERE
    year IN (2000, 2023)
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
  ROUND(life_expect_2000 - region_avg_2000, 2) AS gap_2000,
  ROUND(life_expect_2023 - region_avg_2023, 2) AS gap_2023,
  ROUND(
    (life_expect_2023 - region_avg_2023)
    - (life_expect_2000 - region_avg_2000),
    2
  ) AS gap_change
FROM pivoted;
```

---

# SQL Concepts Demonstrated

- Multi-table JOINs
- Common Table Expressions (CTEs)
- Window Functions (`OVER`, `PARTITION BY`)
- Conditional Aggregation (`CASE`)
- Aggregate Functions
- `SAFE_DIVIDE`
- NULL handling
- Analytical view construction

---

# Next Stage

The next phase of the project will use **R (Posit)** to perform statistical modelling, correlation analysis, and regression techniques to further investigate relationships between healthcare expenditure, GDP, inequality, and life expectancy.
# Key Techniques Used

- **Advanced SQL:** Window Functions (`OVER`, `PARTITION BY`), CTEs (`WITH` clauses), Conditional Aggregation (`CASE WHEN`).
- **Data Integrity:** Data auditing, `SAFE_DIVIDE` to prevent zero-division errors, Handling `NULL` values.
- **Relational Operations:** Multi-table `LEFT JOIN`s for creating consolidated views.
