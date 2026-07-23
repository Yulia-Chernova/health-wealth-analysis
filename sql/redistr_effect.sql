-- Calculate the average redistribution effect
-- (market Gini − disposable Gini) and the number of
-- countries with available data for each year.

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