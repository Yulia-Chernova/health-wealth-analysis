-- Build a consolidated analytical dataset by joining economic,
-- healthcare, demographic, and country dimension tables.
-- The resulting dataset provides one record per country and year
-- and is used as the primary source for subsequent SQL analysis.

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