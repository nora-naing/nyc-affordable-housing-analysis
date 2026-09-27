# NYC Affordable Housing Analysis

An end-to-end data analytics project analyzing affordable housing production in New York City using **Python, MySQL, and Power BI**.

The project examines housing production across boroughs, construction strategies, affordability levels, project sizes, housing tenure, bedroom composition, and project completion patterns.

---

## Project Overview

Affordable housing development involves multiple dimensions including location, construction strategy, affordability level, project scale, and housing composition.

This project analyzes NYC's **Affordable Housing Production by Building** dataset to answer business-oriented questions such as:

* Where is affordable housing production concentrated?
* How do preservation and new construction contribute to affordable housing supply?
* How much housing is targeted toward extremely low- and very low-income households?
* How concentrated is affordable housing production among large projects?
* What types of housing units are being produced?
* How do project completion patterns differ across construction strategies?
* How has affordable housing production changed over time?

The analysis follows an end-to-end workflow:

**Python → MySQL → Power BI**

Python was used for data cleaning, validation, feature engineering, and exploratory analysis.
MySQL was used for data validation and business-focused analysis.
Power BI was used to build an interactive executive dashboard.

---

## Dataset

**Source:** NYC Open Data — Affordable Housing Production by Building

The dataset contains building-level records associated with affordable housing projects administered through NYC's housing programs.

**Dataset size used in this project:**

* 9,250 records
* 5,772 distinct projects
* 7,257 distinct buildings with non-null Building IDs
* 41 original columns
* 42 columns after Python feature engineering

Official dataset:

https://data.cityofnewyork.us/Housing-Development/Affordable-Housing-Production-by-Building/hg8x-zxpr/about_data

> The raw dataset is not included in this repository. Please refer to the official NYC Open Data source for the original data.

---

## Data Grain

Each record represents a **building-level record associated with an affordable housing project**.

A project may contain multiple records, and a building may also appear across multiple project records.

Therefore:

* `Project ID` is not a row-level primary key.
* `Building ID` is not unique across all records.
* The `(Project ID, Building ID)` combination was unique in the analyzed dataset.
* Some records have missing Building IDs because certain projects are confidential.
* Project names should not be treated as unique identifiers because multiple Project IDs can share the same project name.

This grain analysis was important when calculating project-level metrics such as project size and project concentration.

---

# Business Questions

### Geographic Distribution

* Which boroughs contribute the most affordable housing units?
* How is affordable housing production distributed across NYC?

### Construction Strategy

* How much affordable housing comes from preservation versus new construction?
* How does project scale differ between construction strategies?
* How do construction strategies vary across boroughs?

### Affordability

* How much housing is targeted toward extremely low- and very low-income households?
* Which boroughs and construction strategies contribute the most deeply affordable units?
* How are projects distributed by affordability level?

### Project Scale & Concentration

* How many affordable housing projects are very large?
* What proportion of affordable units comes from very large projects?
* Are affordable housing units concentrated among a relatively small number of projects?

### Housing Composition

* How are affordable units divided between rental and homeownership?
* What bedroom types represent the largest share of affordable units?
* What proportion of total housing units is affordable versus market-rate?

### Project Performance

* What proportion of projects are completed?
* How does completion status vary by construction strategy?
* How has project completion changed across project start years?

---

# Tools & Technologies

| Tool                | Purpose                                                              |
| ------------------- | -------------------------------------------------------------------- |
| **Python / Pandas** | Data cleaning, validation, feature engineering, exploratory analysis |
| **MySQL 8.0**       | Data validation and business analysis                                |
| **Power BI**        | Interactive dashboard and business visualization                     |
| **GitHub**          | Portfolio documentation and project version control                  |

---

# Analytical Workflow

## 1. Python — Data Preparation & Exploration

Python was used as the first stage of the workflow.

### Data Cleaning

The cleaning process included:

* Converting project and building dates into proper datetime values
* Converting identifier and numeric fields into appropriate numeric types
* Handling placeholder values such as `'----`
* Treating blank unit-count fields as zero where appropriate
* Preserving missing identifiers as missing rather than replacing them with artificial values
* Validating numeric fields and unit relationships

### Feature Engineering

A key derived metric was:

**Affordable Unit Share**

> Affordable Unit Share = All Counted Units / Total Units

This measures the proportion of total housing units represented by affordable/regulated units in each record.

### Exploratory Analysis

Python EDA examined:

* Production trends over time
* Borough distribution
* Construction strategy
* Income-group composition
* Bedroom composition
* Project size
* Project completion
* Project duration

Five records contained negative project durations. These were confirmed as data-quality issues and were excluded **only from duration analysis**, rather than being removed from the main dataset.

---

# 2. MySQL — Data Validation & Business Analysis

The cleaned dataset was loaded into MySQL and analyzed using SQL.

The SQL workflow was divided into two main files:

```text
sql/
├── 01_data_validation_and_eda.sql
└── 02_business_analysis.sql
```

### Data Validation & EDA

The first SQL analysis focused on:

* Dataset structure
* Missing Building IDs
* Duplicate Project + Building combinations
* Negative unit values
* Affordable units versus total units
* Project date validation
* Project and building structure
* Income-group validation
* Bedroom-unit validation
* Rental and homeownership validation
* Borough distribution
* Construction strategy distribution

### Business Analysis

The second SQL analysis focused on:

* Geographic contribution
* Construction strategy contribution
* Deep affordability
* Project size and concentration
* Rental versus homeownership
* Affordable versus market-rate composition
* Project completion
* Year-over-year production trends
* Construction strategy mix over time
* Large-scale projects with strong deep affordability
* Strategic project segmentation

The SQL analysis uses CTEs, aggregations, window functions, ranking, segmentation, and contribution analysis where appropriate.

---

# 3. Power BI — Interactive Dashboard

The cleaned MySQL dataset was connected to Power BI to create an interactive three-page dashboard.

## Page 1 — Executive Overview

The executive page provides a high-level view of NYC affordable housing production.

### KPIs

* **312,876** Affordable Units
* **435,872** Total Units
* **71.78%** Affordable Unit Share
* **5,772** Projects
* **7,257** Buildings
* **140,230** Deeply Affordable Units

### Visuals

* Affordable Units by Borough
* Affordable Units by Construction Strategy
* Affordable vs Market-Rate Units
* Affordable Housing Production Over Time

---

## Page 2 — Housing Strategy & Affordability

This page focuses on affordability and housing composition.

### KPIs

* **252,473** Rental Units
* **60,403** Homeownership Units
* **44.82%** Deep Affordability Share

Deeply affordable units are defined in this analysis as:

**Extremely Low Income Units + Very Low Income Units**

### Visuals

* Deep Affordability Share by Construction Strategy
* Deeply Affordable Units by Borough
* Affordable Units by Borough and Construction Strategy
* Affordable Housing Tenure by Construction Strategy
* Affordable Units by Bedroom Type

---

## Page 3 — Project Performance & Concentration

This page focuses on project scale and completion.

### KPIs

* **5,772** Total Projects
* **340** Very Large Projects
* **174,263** Affordable Units from Very Large Projects
* **55.70%** of affordable units from Very Large Projects

For this analysis, a very large project is defined as a project with:

**More than 200 affordable units**

### Visuals

* Top 10 Projects by Affordable Units
* Top 10 Projects by Deeply Affordable Units
* Projects by Affordable Unit Size
* Project Completion Status by Construction Strategy

---

# Key Findings

## 1. Affordable Housing Production Is Concentrated in Several Boroughs

The Bronx accounts for the largest share of affordable housing units in the analyzed dataset, followed by Brooklyn and Manhattan.

| Borough       | Affordable Units |  Share |
| ------------- | ---------------: | -----: |
| Bronx         |          102,592 | 32.79% |
| Brooklyn      |           89,105 | 28.48% |
| Manhattan     |           72,504 | 23.17% |
| Queens        |           42,480 | 13.58% |
| Staten Island |            6,195 |  1.98% |

The distribution shows that affordable housing production is not evenly distributed across the five boroughs.

---

## 2. Preservation Represents a Large Share of Affordable Housing Production

Preservation projects account for approximately **59.12%** of affordable units in the analyzed records, while new construction accounts for approximately **40.88%**.

Preservation records also have a substantially larger average affordable-unit contribution per record than new construction records.

This indicates that preservation plays an important role in maintaining or expanding affordable housing supply within existing housing stock.

---

## 3. Deep Affordability Represents a Significant Portion of Affordable Units

The project contains **140,230 deeply affordable units**, representing approximately **44.82%** of affordable units.

Deep affordability is defined in this project as the combination of:

* Extremely Low Income Units
* Very Low Income Units

The income-group analysis shows that low- and very-low-income categories account for substantial portions of affordable housing production.

---

## 4. Affordable Housing Production Is Concentrated Among Large Projects

There are **340 very large projects**, defined as projects containing more than 200 affordable units.

Together, these projects account for:

* **174,263 affordable units**
* **55.70% of all affordable units**

This demonstrates that a relatively small group of large projects contributes a substantial portion of the overall affordable housing supply.

---

## 5. One- and Two-Bedroom Units Dominate the Bedroom Mix

One-bedroom and two-bedroom units together account for approximately **69.35%** of affordable units.

The bedroom distribution is approximately:

* 1-BR: 36.29%
* 2-BR: 33.06%
* Studio: 17.40%
* 3-BR: 11.09%
* Other / Unknown: remaining share

This provides a useful view of the unit-size composition of affordable housing production.

---

## 6. Project Completion Varies by Construction Strategy

At the project level:

* 4,856 projects are classified as completed.
* 916 projects are not completed/ongoing.

Completion rates by construction strategy were approximately:

* New Construction: **83.58%**
* Preservation: **85.53%**

These figures should be interpreted in the context of the dataset's project/building grain and the fact that two projects contain multiple construction types.

---

# Data Quality & Validation

Several validation checks were performed throughout the project.

### Identifier Validation

* Project IDs were checked for uniqueness assumptions.
* Building IDs were examined for duplicates and missing values.
* Project + Building combinations were validated.

### Unit Validation

The analysis checked relationships between:

* Income-group units
* Bedroom units
* Rental units
* Homeownership units
* Affordable units
* Total units

### Date Validation

Project and building dates were converted to proper date formats and checked for inconsistencies.

Five negative project durations were identified and excluded from duration-specific analysis.

### Missing Data

There are **1,868 records with missing Building IDs**. These are associated with confidential projects and were retained in the dataset.

Missing values were not automatically replaced with zero or `"Unknown"` because the distinction between a true zero and an unavailable value is analytically important.

---

# Important Data Limitations

### 2026 Is a Partial Year

The dataset includes 2026 records, but 2026 should not be directly compared with complete historical years because it represents a partial/YTD period.

### Project-Level Grain

The dataset is not one row per project.

A project may have multiple building-level records, so project-level metrics must be calculated at project grain rather than simply counting rows.

### Confidential Projects

Some records have missing Building IDs and other identifying/location information because the underlying projects are confidential.

### Project Names Are Not Unique

Multiple Project IDs may share the same project name.

Therefore, `Project ID` is used as the technical identifier when performing project-level analysis.

### Multiple Construction Types

Two projects contain two construction types.

As a result, construction-strategy project counts can sum to **5,774**, while the distinct project count is **5,772**.

This is an expected consequence of the dataset structure rather than a data-quality error.

### Observational Analysis

This project describes patterns in the available data. It does not establish causal relationships between factors such as construction strategy, location, affordability, or project completion.

---

# Repository Structure

```text
nyc-affordable-housing-analysis/
│
├── README.md
│
├── data/
│   └── README.md
│
├── python/
│   └── housing_project.ipynb
│
├── sql/
│   ├── 01_data_validation_and_eda.sql
│   └── 02_business_analysis.sql
│
├── powerbi/
│   └── NYC_Affordable_Housing.pbix
│
└── screenshots/
    ├── executive_overview.png
    ├── housing_strategy.png
    └── project_performance.png
```

> The raw NYC Open Data dataset is not included in the repository. The `data/README.md` file can provide the official source link and instructions for obtaining the data.

---

# Dashboard Preview

## Executive Overview

*Add screenshot here.*

## Housing Strategy & Affordability

*Add screenshot here.*

## Project Performance & Concentration

*Add screenshot here.*

---

# Project Takeaways

This project demonstrates an end-to-end analytical workflow:

**Python**

→ Data cleaning
→ Data quality assessment
→ Feature engineering
→ Exploratory analysis

**MySQL**

→ Data validation
→ Business-focused SQL analysis
→ Aggregation
→ Ranking
→ Segmentation
→ Contribution analysis

**Power BI**

→ Data modeling
→ DAX measures
→ Interactive filtering
→ KPI design
→ Business dashboarding

The project emphasizes not only technical implementation, but also **data grain, validation, business questions, and decision-oriented analysis**.

---

# Author

**Nora**

Aspiring Data Analyst / Business Analyst

Skills demonstrated:

* Python
* Pandas
* SQL
* MySQL
* Power BI
* DAX
* Data Cleaning
* Exploratory Data Analysis
* Business Analysis
* Data Visualization
* Data Quality Validation
