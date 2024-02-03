# Data Analytics Power BI Report

## Aim
This project aims to perform analysis on data from multiple sources and regions to produce a quarterly report in Power BI, with insights into products, territories and customers.

## Obtaining the data
Orders data was imported from an Azure SQL database, with the card number column removed, and the datetime columns split into separate date and time columns. A csv file containing products data was imported next, with duplicates removed to ensure unique product codes. Data on the stores in the company was obtained from Azure blob storage. Finally a folder containing csv files for Customers in the three countries was imported, the files merged into one query.

Unused columns were removed from the imported data, and columns and filenames updated per Power BI conventions. Date columns in all tables were changed to date type and nulls removed. A full name column was created from first and last name columns in the Customers table. Categories in the Product table had dashes replaced by spaces and words given initial capitals. The Availability column had values replaced to fix spelling and remove underscores.

The Weight column in the Products table required a bit of work. Filtering revealed there were different units being used (g, kg, oz, ml), multipacks included eg 6 x 10g, and errors included eg a rug weighing 2.4g. Firstly I dealt with the multipacks issue. After removing spaces from the column I created a conditional column, Pack Quantity, which took the value of the Weight column if the Weight column contained 'x', otherwise it was set to 1. Then I split the Pack Quantity column on 'x' to retain the quantity and move the weight of multipack products to a separate column (Multipack Weight). Another conditional column, Weight revised, was created which equalled Weight if the weight was null in the Multipack Weight column, and Multipack Weight otherwise.  Next I used a conditional column Weight Units, which equalled kg if Weight Revised contained 'kg' and similarly for the other units, then I removed those units from the Weight Revised column using Replace Values.



