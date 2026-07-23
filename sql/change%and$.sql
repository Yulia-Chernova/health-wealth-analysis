-- Compare average healthcare expenditure per capita (current US$)
-- by income group between the beginning and the end of the study period.
-- Calculate absolute and percentage change using five-year averages.

WITH
  spending_by_income AS (
    SELECT
      incomegroup_name,
      ROUND(
        AVG(
          CASE
            WHEN year BETWEEN 2000 AND 2004
              THEN chex_pc
            END),
        2)
        AS avg_early,
      ROUND(
        AVG(
          CASE
            WHEN year BETWEEN 2019 AND 2023
              THEN chex_pc
            END),
        2)
        AS avg_late
    FROM health-wealth-analysis.raw_data.base_view
    WHERE incomegroup_name IS NOT NULL AND chex_pc IS NOT NULL
    GROUP BY incomegroup_name
  )
SELECT
  incomegroup_name,
  avg_early,
  avg_late,
  ROUND(avg_late - avg_early, 2) AS absolute_change,
  ROUND(SAFE_DIVIDE(avg_late - avg_early, avg_early) * 100, 2)
    AS percentage_change
FROM spending_by_income;