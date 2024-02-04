# Data Analytics Power BI Report

## Aim

This project aims to perform analysis on data from multiple sources and regions to produce a quarterly report in Power BI, with insights into products, territories and customers.

## Obtaining the data

Orders data was imported from an Azure SQL database, with the card number column removed, and the datetime columns split into separate date and time columns. A csv file containing products data was imported next, with duplicates removed. Data on the stores in the company was obtained from Azure blob storage. Finally a folder containing csv files for Customers in the three countries was imported, the files merged into one query.

Unused columns were removed from the imported data, and columns and filenames updated per Power BI conventions. Date columns in all tables were changed to date type and nulls removed. A full name column was created from first and last name columns in the Customers table. Categories in the Product table had dashes replaced by spaces and words given initial capitals. The Availability column had values replaced to fix spelling and remove underscores.

The Weight column in the Products table required a bit of work. Filtering revealed there were different units being used (g, kg, oz, ml), multipacks included eg 6 x 10g, and errors included eg a rug weighing 2.4g. Firstly I dealt with the multipacks issue. After removing spaces from the column I created a conditional column, Pack Quantity, which took the value of the Weight column if the Weight column contained 'x', otherwise it was set to 1. Then I split the Pack Quantity column on 'x' to retain the quantity and move the weight of multipack products to a separate column (Multipack Weight). Another conditional column, Weight revised, was created which equalled Weight if the weight was null in the Multipack Weight column, and Multipack Weight otherwise.  Next I used a conditional column Weight Units, which equalled kg if Weight Revised contained 'kg' and similarly for the other units, then I removed those units from the Weight Revised column using Replace Values.

## Creating the Data Model

A Dates table was created using the `CALENDAR` function, with the date range defined using `STARTOFYEAR(Orders[Order Date]` and `ENDOFYEAR(Orders[Shipping Date])`, and the following columns added:
- `Day of Week = WEEKDAY(Dates[Date])`
- `Month = Dates[Date].[MonthNo]`
- `Month Name = Dates[Date].[Month]`
- `Quarter = Dates[Date].[Quarter]`
- `Year = Dates[Date].[Year]`
- `Start of Year = STARTOFYEAR(Dates[Date])`
- `Start of Quarter = STARTOFQUARTER(Dates[Date])`
- `Start of Month`
- `Start of Week`

Relationships were created between the tables to create the star schema below. `Dates[Date]` to `Orders[Date]` is the active relationship between the Dates and Orders tables, with a second relationship between `Dates[Date]` and `Orders[Shipping Date]`. Products and Orders tables are linked on Product Code, Stores and Orders on Store Code and Customers and Orders on a user ID.    

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/488e7987-78cf-4c5c-9a8d-f120b94d7622)

A Measures table was created with the following key measures:
- `Total Orders = COUNT(Orders[Order ID])`
- `Total Revenue = SUMX(Orders, Orders[Product Quantity] * RELATED(Products[Sale Price]))`
- `Total Profit = SUMX(Orders, Orders[Product Quantity] * (RELATED(Products[Sale Price]) - RELATED(Products[Cost Price])))`
- `Total Customers = DISTINCTCOUNT(Orders[User ID])`
- `Total Quantity = SUM(Orders[Product Quantity])`
- `Profit YTD = TOTALYTD([Total Profit], Dates[Date].[Date])`
- `Revenue YTD = TOTALYTD([Total Revenue], Dates[Date].[Date])`

A couple of calculated columns were added to the Stores table, one for country names using `Country = SWITCH(Stores[Country Code],"GB", "United Kingdom", "US","United States", "DE", "Germany")`, and another `Geography = Stores[Country Region] & ", " & Stores[Country]` to ensure accurate plotting on map visuals.

A Dates Hierarchy (Start of Year, Start of Quarter, Start of Month, Start of Week, Date) was added to the Dates table and a Geography Hierarchy (Region, Country, Country Region) was added to the Stores table to allow drilling down in visualisations. 

## Building the Customer Detail Page

I chose the 'high contrast' theme and selected darker colours from the theme for my visualisations. 

I used a card to display the measure created earlier for Total Customers, and created a further measure for Revenue per Customer which I displayed on another card. The number of customers in each country was visualised in a donut chart, and the the number of customers for each product category in a bar chart. Next I added a line chart showing the total customers over time, which is displayed by year but can be drilled down to months, and added a forecast for the next 10 months with a 95% confidence interval.

The top 20 customers by revenue were displayed as a table, with conditional formatting bars on the revenue column, and their total orders also included.  For the top customer by revenue, three cards were added displaying their name, number of orders and total revenue. The name card used the Full Name field with a TopN filter set to show the top 1 value by Total Revenue. I copied this card to create the other two, and added the Total Orders and Total Revenue measures. 

Finally a date slicer was added to filter the data by year.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/8b4dd9fc-b1a8-4e52-8cf0-5de65937f836)









