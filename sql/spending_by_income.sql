-- Compare average healthcare expenditure per capita (current US$)
-- across World Bank regions between 2000–2004 and 2019–2023.
-- Five-year averages reduce the effect of annual fluctuations.
-- Calculate both absolute and percentage change between the periods.


with spending_by_region as (
  SELECT
  region_name,
  ROUND(AVG(
    CASE
      WHEN year BETWEEN 2000 AND 2004
        THEN chex_pc
      END),2)
    AS avg_early,
  ROUND(AVG(
    CASE 
    WHEN year BETWEEN 2019 AND 2023 
      THEN chex_pc
     END), 2)
    AS avg_late
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
FROM spending_by_region;