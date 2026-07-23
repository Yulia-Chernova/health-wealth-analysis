-- Calculate the average life expectancy for each World Bank region
-- across all available years in the dataset.

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