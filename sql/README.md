# SQL Analysis (Google BigQuery)

Following the initial exploratory analysis and dashboard development in Power BI, I used **Google BigQuery** to extend the research with SQL. While the dashboard revealed overall patterns, SQL enabled deeper investigation of specific questions that required aggregation, drill-down analysis, and window functions.

This SQL phase forms the second stage of the project workflow. The final stage will use **R (Posit)** for statistical analysis and hypothesis testing.

---

# Research Objectives

The SQL analysis focused on answering questions that could not be fully explored through visualizations alone:

- How did healthcare expenditure per capita change across World Bank income groups?
- Which regions experienced the largest increase in healthcare expenditure?
- Was South Asia's exceptional growth driven by one country or shared across the region?
- How did the redistribution effect (market Gini − disposable Gini) evolve over time?
- How complete is the available Gini dataset across the study period?
- How does each country's life expectancy compare with the average of its region?
- Which countries improved or declined relative to their regional average between 2000 and 2023?

---

# Key Findings

## Healthcare Expenditure

Using five-year averages (2000–2004 vs. 2019–2023) reduced the influence of annual fluctuations and allowed long-term comparisons.

- South Asia recorded the largest increase in healthcare expenditure per capita (+286.95%) among all World Bank regions.
- Country-level analysis showed that this growth was not driven by a single outlier. All countries in the region experienced substantial increases, although the magnitude varied considerably:

| Country | Growth |
|:---|---:|
| Nepal | +565.79% |
| Bangladesh | +463.42% |
| Bhutan | +291.28% |
| Maldives | +275.38% |
| Sri Lanka | +262.18% |
| India | +248.15% |

*The SQL analysis identified the pattern, while explaining its underlying causes requires additional economic and policy research.*

---

## Life Expectancy

Regional aggregation highlighted substantial improvements in life expectancy across Sub-Saharan Africa during the study period.

Window functions were then used to compare each country's life expectancy with its regional average, allowing changes in relative performance between 2000 and 2023 to be measured.

---

## Redistribution Effect & Data Quality

The redistribution effect was calculated as the difference between market and disposable Gini coefficients.

Before interpreting the results, data completeness was assessed by counting countries with both Gini measures available each year. The analysis showed that data coverage declined substantially in the most recent years, an important consideration when interpreting long-term trends.

---

# Methodology & SQL Implementation

The SQL workflow consisted of four stages. Below are key code snippets illustrating the analytical logic:

### 1. 5-Year Baseline Spending Comparison (CTEs & Aggregations)
*Used CTEs and conditional aggregation to calculate baseline growth while smoothing out annual volatility.*

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

### 2. Country vs. Regional Life Expectancy Gap (Window Functions & Pivoting)
*Used `AVG() OVER (PARTITION BY ...)` to benchmark country performance against regional averages over time.*

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

# Key Techniques Used

- **Advanced SQL:** Window Functions (`OVER`, `PARTITION BY`), CTEs (`WITH` clauses), Conditional Aggregation (`CASE WHEN`).
- **Data Integrity:** Data auditing, `SAFE_DIVIDE` to prevent zero-division errors, Handling `NULL` values.
- **Relational Operations:** Multi-table `LEFT JOIN`s for creating consolidated views.
