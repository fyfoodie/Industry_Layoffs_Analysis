# Industry_Layoffs_Analysis

# Project Overview

**Project Title:** Industry Layoffs Analysis   
**Database:** layoffs.csv   


This project explores global layoffs data from 2020 to 2023, focusing on identifying patterns across industries, companies, and years. Using MySQL for data cleaning and transformation, and Python (Jupyter Notebook) for visualization, the goal is to uncover insights into which sectors and companies were most impacted, when major spikes happened, and how funding or company stage influenced workforce cuts.


<img width="989" height="590" alt="download" src="https://github.com/user-attachments/assets/e9fea274-37ce-45ab-a935-072ffcac430b" />


## Tech Stack

- SQL (MySQL) → Data cleaning, transformation, and exploratory querie
- Python (Jupyter Notebook) → Visualization and deeper trend analysis (Matplotlib, Pandas)
- Dataset → Layoffs dataset covering multiple industries worldwide

## Data Cleaning (MySQL)

Key steps taken to prepare the data:

- Remove duplicates → Used ROW_NUMBER() to detect and delete duplicate rows.
- Standardize fields → Trimmed company names, merged inconsistent industry names (e.g., “Crypto” vs “Crypto Currency”), standardized countries, and formatted date column to DATE.
- Handle missing values → Filled missing industries where possible by joining with duplicate company entries; removed rows with insufficient information (both total_laid_off and percentage_laid_off NULL).
- Drop unnecessary columns → Removed helper columns like row_num after cleaning.

## Exploratory Analysis (MySQL)

Some key SQL analyses performed:

- Companies with 100% layoffs (entire workforce cut).
- Industries and countries with the highest layoffs.
- Yearly and monthly trends, including rolling totals to track spikes.
- Top 5 companies per year ranked by total layoffs.

## Visualization & Insights (Jupyter Notebook)

The cleaned dataset was further explored in an IPython Notebook to generate visuals and highlight trends.

## Summary of Findings:

- Layoffs peaked in May 2023, following a steady trend from 2020 through mid-2022.
- The “Other” sector dominated layoffs every year. In 2020, Transportation and Finance were hit hard, while 2021 was relatively quiet.
- 2022–2023 saw the biggest wave, spreading across multiple industries, but still led by “Other.”
- Amazon recorded the highest layoffs across 2022–2023 combined.
- Google had the largest single-year layoffs in 2023, while Meta led in 2022.
- Startups in transport, food, crypto, and healthcare—despite heavy funding—collapsed or cut staff, showing that funding alone doesn’t guarantee resilience.

## Reports

- Industry Summary → Layoffs by sector and year, showing dominance of the “Other” group.
- Company Analysis → Year-over-year layoffs by major companies, with rankings of the top 5 per year.
- Funding vs Stability → Comparison of companies with high funding but still high layoffs.
- Trend Overview → Rolling totals and monthly breakdowns showing when spikes occurred.

📂 Project Structure
├── data/                 # Raw dataset    
├── sql/                  # MySQL cleaning and analysis scripts   
│   ├── data_cleaning.sql   
│   ├── exploratory.sql   
├── notebooks/            # Jupyter Notebooks for visualization   
│   ├── layoffs_analysis.ipynb    
├── README.md             # Project documentation   

## Conclusion

This project shows how combining SQL for structured cleaning/analysis with Python visualization gives a powerful way to understand workforce dynamics. The layoffs spike in 2022–2023 reveals industry-wide corrections, highlighting how even large, well-funded companies are not immune to market realities.
