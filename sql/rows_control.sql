-- Assess data completeness by counting the number of countries
-- with both market and disposable Gini coefficients available
-- for each year.

SELECT
  year,
  COUNT(gini_mkt - gini_disp) AS country_count
FROM `health-wealth-analysis.raw_data.base_view`
WHERE
  gini_mkt IS NOT NULL
  AND gini_disp IS NOT NULL
GROUP BY year
ORDER BY year;