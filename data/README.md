# Dataset Documentation

## Dataset Name

**Affordable Housing Production by Building**

## Data Source

This project uses the *Affordable Housing Production by Building* dataset published by the New York City Department of Housing Preservation and Development (HPD).

**Official Dataset Page:**  
https://data.cityofnewyork.us/Housing-Development/Affordable-Housing-Production-by-Building/hg8x-zxpr/about_data

## Dataset Overview

The dataset contains building-level records associated with affordable housing projects in New York City.

The version used in this project contained **9,250 records and 41 original columns** before data cleaning and feature engineering.

The analysis explores affordable housing production across boroughs, construction strategies, income groups, bedroom types, project sizes, and completion patterns.

## Data Access

The raw CSV file is not included in this repository. Users can obtain the dataset from the official NYC Open Data source linked above.

To reproduce the analysis:

1. Open the official dataset page.
2. Download the dataset in CSV format.
3. Place the downloaded CSV file in this directory.
4. Follow the workflow documented in the main project `README.md` and Python notebook.

**Access Note for Users in Myanmar:**  
Access to the NYC Open Data website may require a VPN when connecting from Myanmar. If the dataset page does not load, try connecting to a VPN and opening the link again.

**Reproducibility Note:**  
NYC Open Data may update the dataset over time. Downloading it later may result in different row counts or analytical findings from those reported in this project.

## Important Data Considerations

### Dataset Grain
Each record represents a building-level record associated with an affordable housing project. The dataset is not necessarily one row per project, so project-level metrics must be calculated using distinct project identifiers and appropriate aggregations.

### Project and Building Identifiers
- `Project ID` identifies projects but is not unique at the record level.
- `Building ID` may appear across multiple records.
- Some records have missing Building IDs, including records associated with confidential projects.
- Multiple Project IDs may share the same project name. Project names should therefore not be treated as unique identifiers.

### Unit Definitions
- **All Counted Units:** Affordable or regulated units counted toward the city's housing plan.
- **Total Units:** The total number of housing units, including affordable and market-rate units.

### Missing Values
Missing identifiers and unavailable information should not automatically be interpreted as zero. In this project, blank unit-count fields were treated as zero where appropriate, while missing identifiers and other unavailable information were preserved as missing values.

### Time Coverage
The dataset includes records for 2026. Because 2026 represents a partial year in this analysis, it should not be directly compared with complete historical years without accounting for the difference in time coverage.

## Data Preparation and Analysis

The project follows an end-to-end workflow:

**Python → MySQL → Power BI**

- **Python:** Data cleaning, data quality validation, feature engineering, and exploratory data analysis.
- **MySQL:** Data validation and business-focused SQL analysis.
- **Power BI:** Interactive dashboard development and visualization of key findings.

Refer to the `python/`, `sql/`, and `powerbi/` directories for the corresponding project files.

## Disclaimer

This project is an independent analytical study using publicly available NYC Open Data. The analysis is intended for educational and portfolio purposes and does not represent an official assessment by the New York City government or HPD.
