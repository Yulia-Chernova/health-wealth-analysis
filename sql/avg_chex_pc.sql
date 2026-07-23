-- Calculate the average healthcare expenditure per capita by income group.
-- Five-year averages (2000–2004 and 2019–2023) are used to compare
-- the beginning and the end of the study period while reducing
-- the effect of annual fluctuations.

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
GROUP BY incomegroup_name;