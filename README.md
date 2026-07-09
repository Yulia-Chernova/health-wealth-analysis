# Health, Wealth & Longevity

## Project Overview

This project explores the relationship between healthcare expenditure, economic development, income inequality, and life expectancy across the world.

The analysis covers **216 economies**, following the World Bank terminology, where the term *economy* includes any territory for which authorities report separate social or economic statistics.

Multiple public datasets from different sources were integrated into a unified analytical model and visualized in an interactive Power BI dashboard.

---

## Dashboard Preview

![Dashboard overview](images/dashboard_overview.png)

---

## Objectives

- Investigate whether higher healthcare spending is associated with longer life expectancy.
- Examine the relationship between GDP, healthcare expenditure, and life expectancy.
- Explore the impact of income inequality on health outcomes.
- Build a clean analytical data model suitable for further SQL and Power BI analysis.

---

## Data Sources

| Indicator | Source |
|------------|--------|
| Current health expenditure (% of GDP) | Our World in Data |
| Current health expenditure per capita (current US$) | World Bank |
| GDP (current US$) | World Bank |
| GDP per capita (current US$) | World Bank |
| Life expectancy | Our World in Data |
| Gini Index | Harvard Dataverse |
| Country metadata, income groups and lending groups | World Bank |

### Original datasets

- Healthcare expenditure (% of GDP): https://ourworldindata.org/search?q=healthcare+expenditure&resultType=all
- Current health expenditure per capita (current US$): https://data.worldbank.org/indicator/SH.XPD.CHEX.PC.CD
- GDP (current US$): https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
- GDP per capita (current US$): https://data.worldbank.org/indicator/NY.GDP.PCAP.CD
- Life expectancy: https://ourworldindata.org/search?q=life+expectancy&resultType=all
- Gini Index: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/LM4OWF
- Country metadata: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups

---

## Data Preparation

The raw datasets required significant preprocessing before analysis.

### Data cleaning

- Harmonized country/economy names across datasets from different sources.
- Renamed columns using consistent naming conventions.
- Removed duplicate records.
- Converted wide-format tables into long-format tables where necessary.
- Standardized data types.

### Data integration

- Created a separate Country dimension table.
- Added additional fields required for building relationships.
- Established a star schema data model in Power BI.

---

## Tools

- Power BI
- Power Query
- Microsoft Excel

(SQL scripts will be added in the next stage of the project.)

---

## Repository Structure

```
data/
    processed/

powerbi/

images/

README.md
```

## Key Findings

- Healthcare expenditure generally shows a positive relationship with life expectancy.
- GDP alone does not fully explain differences in life expectancy.
- Countries with similar healthcare spending may achieve substantially different outcomes.
- Income inequality appears to influence health outcomes beyond economic wealth alone.
---

## Dashboard

Additional dashboard screenshots are available in the [images folder](images/)

---

## Future Improvements

- Rebuild the complete data preparation workflow in SQL (BigQuery).
- Add analytical SQL queries.
- Extend the analysis with additional statistical indicators.
