#!/bin/bash

# Create project directories
mkdir -p COVID19_Analysis
mkdir -p Housing_Data_Analysis
mkdir -p Retail_Sales_Analysis

# Move COVID-19 project files
git mv "COVID Portfolio Project.sql" COVID19_Analysis/
git mv CovidDeaths.csv COVID19_Analysis/
git mv CovidVaccinations.csv COVID19_Analysis/

# Move Housing data files
git mv "Housing Data EDA.sql" Housing_Data_Analysis/
git mv Housing_Data_change_date_format.ipynb Housing_Data_Analysis/
git mv "Nashville Housing Data for Data Cleaning.csv" Housing_Data_Analysis/

# Move Retail Sales files
git mv Retail_Sales_Analysis.sql Retail_Sales_Analysis/
git mv Retail_Sales_Analysis.csv Retail_Sales_Analysis/

# Done
echo "✅ Repository files reorganized into folders."
