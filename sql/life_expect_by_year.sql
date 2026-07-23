-- Calculate life expectancy for each country and the corresponding
-- regional average in 2000 and 2023, then pivot the two years
-- into separate columns for comparison.

WITH
  life_expect_by_year AS (
    SELECT
      country_name,
      region_name,
      year,
      life_expect,
      round(avg(life_expect) OVER (PARTITION BY region_name, year), 2)
        AS region_avg
    FROM `health-wealth-analysis.raw_data.base_view`
    WHERE
      year IN (2000, 2023)
      AND life_expect IS NOT NULL
      AND region_name IS NOT NULL
  )
SELECT
  country_name,
  region_name,
  MAX(
    CASE
      WHEN year = 2000 THEN life_expect
      END) AS life_expect_2000,
  MAX(
    CASE
      WHEN year = 2000 THEN region_avg
      END) AS region_avg_2000,
  MAX(
    CASE
      WHEN year = 2023 THEN life_expect
      END) AS life_expect_2023,
  MAX(
    CASE
      WHEN year = 2023 THEN region_avg
      END) AS region_avg_2023
FROM life_expect_by_year
GROUP BY country_name, region_name
ORDER BY country_name, region_name;