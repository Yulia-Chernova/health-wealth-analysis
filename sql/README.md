## 🔍 SQL Analysis (Google BigQuery)

Following the initial data modeling in Power BI, I leveraged **Google BigQuery** to perform end-to-end Exploratory Data Analysis (EDA). The analytical workflow covers data consolidation, data completeness auditing, macro-level metric aggregations, and regional drill-downs.

---

### 📂 Analytical Framework & Logical Steps

1. **Data Infrastructure & Base View Creation**
   * Built a unified analytical dataset (`base_view`) merging economic (GDP), healthcare expenditure (`chex_pc`, `che_gdp`), inequality (`gini`), demographic, and geographical dimensions across years.

2. **Data Completeness & Quality Audits**
   * Evaluated coverage and density for key indicators, such as Gini coefficients (market vs. disposable), to ensure metric validity over time before executing deep dives.

3. **Healthcare Expenditure & Regional Anomalies**
   * Analyzed 5-year baseline (2000–2004) vs. recent (2019–2023) averages across income groups and regions to smooth out short-term fluctuations.
   * **Key Finding:** Identified **South Asia** as the top growth region (+286.95% relative growth). Performed a targeted drill-down revealing that all South Asian countries experienced substantial surges (led by Nepal at +565.79% and Bangladesh at +463.42%). **Life Expectancy Gains in Sub-Saharan Africa** Further exploratory queries highlighted Sub-Saharan Africa as a standout region for significant growth in overall life expectancy over the two-decade span.
   * *Analytical Note:* While the raw metric trend is strongly positive, underlying drivers (e.g., healthcare infrastructure, disease control programs, international aid) go beyond the available metric variables in the current dataset.

4. **Life Expectancy & Convergence Trends**
   * Calculated long-term life expectancy regional averages and tracked the evolution of country-level performance relative to regional baselines between 2000 and 2023.

---

### 🛠️ Key SQL Queries

#### 1. Consolidation: Base View Architecture
*Combines raw relational tables into a single source of truth for downstream analytical queries.*

```sql
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
  ON che_gdp.country_code = gdp.country_code AND che_gdp.year = gdp.year
LEFT JOIN `health-wealth-analysis.raw_data.gini` AS gini
  ON gini.country_code = gdp.country_code AND gini.year = gdp.year
LEFT JOIN `health-wealth-analysis.raw_data.country` AS country
  ON country.country_code = gdp.country_code
LEFT JOIN `health-wealth-analysis.raw_data.dem_div` AS dem_div
  ON dem_div.dd_code = country.dd_code
LEFT JOIN `health-wealth-analysis.raw_data.income_group` AS income_group
  ON income_group.incomegroup_code = country.incomegroup_code
LEFT JOIN `health-wealth-analysis.raw_data.region` AS region
  ON region.region_code = country.region_code
LEFT JOIN `health-wealth-analysis.raw_data.life_expect` AS life_expect
  ON life_expect.country_code = gdp.country_code AND life_expect.year = gdp.year
LEFT JOIN `health-wealth-analysis.raw_data.chex_pc` AS chex_pc
  ON chex_pc.country_code = gdp.country_code AND chex_pc.year = gdp.year;
