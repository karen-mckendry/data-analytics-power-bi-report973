# Data Analytics Power BI Report

## Aim
This project aims to perform analysis on data from multiple sources and regions to produce a quarterly report in Power BI, with insights into products, territories and customers.

## Obtaining the data
Orders data was imported from an Azure SQL database, with the card number column removed, and the datetime columns split into separate date and time columns. A csv file containing products data was imported next, with duplicates removed to ensure unique product codes. Data on the stores in the company was obtained from Azure blob storage. Finally a folder containing csv files for three countries was imported, the files merged into one query, and a full name column created from first and last name columns. Unused columns were removed from the imported data, and columns and filenames updated per Power BI conventions.
