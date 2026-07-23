-- Investigate which South Asian countries contributed to the region's
-- high growth in healthcare expenditure per capita.
-- Compare five-year averages for 2000–2004 and 2019–2023
-- and calculate absolute and percentage change by country.


with spending_by_country as (
  SELECT
  country_name,
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
  AND region_name = 'South Asia'
  GROUP BY country_name)

SELECT
  country_name,
  avg_early,
  avg_late,
  ROUND(avg_late - avg_early, 2) AS absolute_change,
  ROUND(SAFE_DIVIDE(avg_late - avg_early, avg_early) * 100, 2) AS percentage_change
FROM spending_by_country;