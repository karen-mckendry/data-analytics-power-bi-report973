# Data Analytics Power BI Report

## Table of Contents

1. [Aim](#aim)
2. [Importing and Transforming the Data](#importing-and-transforming-the-data)
3. [The Data Model](#the-data-model)
4. [The Customer Detail Page](#the-customer-detail-page)
5. [The Executive Summary Page](#the-executive-summary-page)
6. [The Product Detail Page](#the-product-detail-page)
7. [The Stores Map Page](#the-stores-map-page)
8. [Cross-Filtering and Navigation](#cross-filtering-and-navigation)
9. [Metrics Using SQL](#metrics-using-sql)
10. [Installation and Usage instructions](#installation-and-usage-instructions)
11. [License](#license)

## Aim

This project aimed to provide actionable insights into products, territories and customers for a medium sized international retailer, using a large quantity of sales data accumulated over several years. This involved extracting and transforming data from multiple sources, designing a data model with a star-based schema and producing a comprehensive Power BI report.

## Importing and Transforming the Data

The following data was used in this project:

- Orders table, imported from an Azure SQL database
- Products table, imported from a csv file
- Stores table, imported from Azure blob storage
- Customers table, formed by importing a folder containing three csv files for three countries and merging them

The imported data was transformed in order to:

- create a full name column in the Customers table using Columns From Examples
- correct spelling errors in data and replace other values eg dashes
- remove unused columns, nulls and duplicates
- remove card details to protect privacy
- change columns to the correct datatype
- split datetime columns into date and time columns
- update columns headings to conform to Power BI naming conventions

## The Data Model

The model consists of a main fact table (Orders), dimension tables (Products, Stores and Customers already imported, plus a Dates table) and a Measures table.

The Dates table uses the `CALENDAR` function, with the date range defined using `STARTOFYEAR(Orders[Order Date]` and `ENDOFYEAR(Orders[Shipping Date])`, and has the following additional columns:
- `Day of Week = WEEKDAY(Dates[Date])`
- `Month = Dates[Date].[MonthNo]`
- `Month Name = Dates[Date].[Month]`
- `Quarter = Dates[Date].[Quarter]`
- `Year = Dates[Date].[Year]`
- `Start of Year = STARTOFYEAR(Dates[Date])`
- `Start of Quarter = STARTOFQUARTER(Dates[Date])`
- `Start of Month = STARTOFMONTH((Dates[Date]))`
- `Start of Week = Dates[Date] - WEEKDAY(Dates[Date]) + 1`

Relationships between the following tables create the star schema below. Dates[Date] to Orders[Date] is the active relationship between the Dates and Orders tables, with a second relationship between Dates[Date] and Orders[Shipping Date]. Products and Orders tables are linked on Product Code, Stores and Orders on Store Code and Customers and Orders on a user ID.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/488e7987-78cf-4c5c-9a8d-f120b94d7622)

The Measures table includes the following key measures:
- `Total Orders = COUNT(Orders[Order ID])`
- `Total Revenue = SUMX(Orders, Orders[Product Quantity] * RELATED(Products[Sale Price]))`
- `Total Profit = SUMX(Orders, Orders[Product Quantity] * (RELATED(Products[Sale Price]) - RELATED(Products[Cost Price])))`
- `Total Customers = DISTINCTCOUNT(Orders[User ID])`
- `Total Quantity = SUM(Orders[Product Quantity])`
- `Profit YTD = TOTALYTD([Total Profit], Dates[Date].[Date])`
- `Revenue YTD = TOTALYTD([Total Revenue], Dates[Date].[Date])`

The Stores table contains two calculated columns, one for country names using `Country = SWITCH(Stores[Country Code],"GB", "United Kingdom", "US","United States", "DE", "Germany")`, and another `Geography = Stores[Country Region] & ", " & Stores[Country]` to ensure accurate plotting on map visuals.

The Dates table contains a Dates Hierarchy (Start of Year, Start of Quarter, Start of Month, Start of Week, Date) and the Stores table contains a Geography Hierarchy (Region, Country, Country Region), to allow drilling down in visualisations. 

## The Customer Detail Page

This page of the report focuses on visualisations of customer related metrics.

**Visualisations**
1. Unique Customers - a card showing total distinct customers using the measure Total Customers above
2. Revenue per Customer - a card using a new measure `Revenue Per Customer = [Total Revenue] / [Total Customers]`
3. Total Customers by Country - a donut chart showing total customers by their country of residence
4. Total Customers by Product Category - a bar chart displaying total distinct customers by product category
5. Total Customers - a line chart showing the total customers over time, displayed by year but drillable down to quarters and months using the Dates hierarchy, and including a 10-month forecast with a 95% confidence interval.

**Top Customer Insights**
1. Top 20 Customers - a table showing the names, revenue and orders of the top 20 customers by total revenue, utilising conditional formatting bars on the revenue column to easily visualise the comparative spend
2. Individual top customer view - a set of 3 cards for the top customer by revenue, detailing their name, total orders and total revenue, using a TopN filter to show the top 1 by Total Revenue.

**Filtering**  
  
A date slicer, allowing users to filter by year, applied to all visualisations.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/6c90b317-aebf-4c58-9376-2728bdd73545)

## The Executive Summary Page

The executive summary provides a concise overview of key performance metrics.

**Key Metrics Visualisations**
1. Overview - three cards for Total Revenue, Total Orders and Total Profit
2. Total Revenue - a line chart showing the total revenue trend over time, displayed by year but drillable down to quarters and months using the Dates hierarchy, and including a 10-month forecast with a 95% confidence interval
3. Total Revenue by Store Location - a donut chart visualising the proportion of revenue by country of store location
4. Total Revenue by Store Type - a donut chart visualising the proportion of revenue by store type
5. Total Orders by Category - a bar chart of total orders for each product category

**Key Performance Indicators (KPIs)**  
  
Total Revenue, Profit and Orders against targets - three KPI visuals showing the most recent quarter's figures, with the target equal to the previous quarter's total revenue plus 5%. The display on these is green if the target is met and red otherwise.

**Filtering**  
  
A date slicer, allowing users to filter by year, applied to all visualisations.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/2397f40d-0ab4-4eb3-bcb9-40554c1613e3)

## The Product Detail Page

This page looks at which products are performing well, with the ability to filter by product category and country. 

**Key Metrics**
- Three gauge visuals displaying the quarter to date performance in Revenue, Profit and Orders against target values of 10% greater than the previous quarter.
- Targets are calculated using measures for the previous quarter's performance, eg for revenue `Previous Quarter Revenue = CALCULATE(TOTALQTD('Measures Table'[Total Revenue]`, `PREVIOUSQUARTER(LASTDATE('Dates'[Date]))))` and another for the target. 
- Conditional formatting was applied to display the callout value in red if the target had not yet been met, and black otherwise, using measures, eg `Colours Orders Gauge = SWITCH(TRUE(),[Orders QTD] >= [Target 2 Orders for Quarter],"Black","Red")`. 

**Product Insights**
1. Total Revenue by Quarter and Category - an area chart to show revenue for each product category over time
2. Top 10 Products -  a table of the top 10 products by revenue, showing total revenue, total customers, orders and profit per order. The Total Revenue column utilises formatting bars for easy visualisation of comparative revenue generated.
3. Scatter graph of sales vs profit - a scatter graph of products' profit per item against total quantity sold, to highlight which products are both the most profitable and the best selling.

**Filtering**
1. Category and country selection - two cards to display current filters for product category and country of store location.
2. Pop-out slicer toolbar - enables the user to filter by product category and country. The toolbar is accessible from the filter button on the navigation toolbar. Clicking on the filter icon uses a bookmark to make the toolbar visible, and similarly clicking on the back button uses a bookmark to hide it again.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/d78f925e-7e0f-47ea-8969-6953401e9ba3)

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/59afc909-9418-4c6c-99a2-5c6a61a2df44)

The screenshot below shows the page without any filters:  

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/839d147b-ae39-402b-a47d-b29f24fc7179)

## The Stores Map Page

The stores map page contains a map visual displaying store locations, with bubble size dependent on Profit YTD so that current performance is easily available. The drill-down to the the store location uses the Geography hierarchy above, and a tile slicer enables filtering by country. 

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/0492fcbc-d939-401c-98d3-86d9ad7534fa)

**Drillthrough Page**

The drillthrough page provides a range of visuals to enable convenient checking on store performance.

1. Store Selection - a card to display the currently selected store location. Uses a measure `Store Selection = IF(ISFILTERED(Stores[Country Region]),SELECTEDVALUE(Stores[Country Region],"No selection"),"No selection")`. 
2. Revenue and Profit Gauges - two gauge visuals to measure YTD revenue and profit against their goals. Utilises two new measures for the goal values, which are 20% above the same period in the previous year, eg `Profit Goal = CALCULATE([Profit YTD], SAMEPERIODLASTYEAR(Dates[Date]))*1.2`. 
3. Top 5 Products - a table showing the YTD profit, orders and revenue for the five products generating the most profit in the current year
4. Total Orders by Category - a bar chart displaying the total orders by product category in the store

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/cb7bc816-5a4e-41c1-8189-be5a21666bc6)

**Tooltip Page**  
  
Hovering over any of the bubbles in the Stores Map page causes the tooltip page to appear, containing:
- Profit YTD - a copy of the gauge from the drillthrough page, so that the current profit against the goal can be immediately seen
- Store location - the region in which the store is located is displayed in a text box which uses the Store Selection measure

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/165853ec-573e-4f2d-aac9-93ea89040b6b)

## Cross-Filtering and Navigation

Cross-filtering has been edited to adjust the way selections in some visuals filter others, as follows.

**Executive Summary**
- Selecting a bar in the Total Orders by Category bar chart does not filter the cards or KPI visuals.

**Customer Detail Page**
- A selection within the top 20 customers table does not affect the other visuals.
- The Total Customers by Country donut chart now filters the Total Customers by Product Category bar chart below it, so you can view Total Customers by Product Category for that country.
- The Total Customers by Product Category bar chart no longer filters the line graph for Total Customers.

**Product Detail Page**
- The scatter graph and the Top 10 Products table do not filter any other visuals.

**Navigation Panel**

A navigation panel containing four custom buttons on the left of each page allows users to easily move between the pages. The buttons' On Hover property is set to display the same icon in a different colour when a user hovers over it. The buttons' Action is set to Page navigation with the Destination set to the relevant page (or none if it is the icon for the current page).

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/bbdc2507-f722-445c-97a6-6dbd035e19c0)

## Metrics Using SQL

The final part of this project was to use SQL to extract information to share with others who are not using a visualisation tool like Power BI. Initially this involved:
- connecting to a Postgres database hosted on Microsoft Azure from VSCode using the SQLTools extension
- extracting the names of all the tables in the database using a query `SELECT * FROM pg_catalog.pg_tables WHERE schemaname='public';` and saving as a csv file
- for each table, listing the columns, eg `SELECT * FROM information_schema.columns where table_name = 'orders';` and saving each as a csv file

The following five questions on this data are answered using SQL queries, which are linked below together with their outputs:

1. the total number of staff in UK stores  
   Query: [question_1.sql](question_1.sql),  Output: [question_1.csv](question_1.csv)
   
2. the month in 2022 with the highest revenue  
   Query: [question_2.sql](question_2.sql), Output: [question_2.csv](question_2.csv)
   
3. the store type with the highest revenue in Germany  
   Query: [question_3.sql](question_3.sql), Output: [question_3.csv](question_3.csv)
   
4. for each store type, the total sales, percentage of overall sales and total orders  
   Query: [question_4.sql](question_4.sql), Output: [question_4.csv](question_4.csv)
   
5. the product category with the most profit in Wiltshire, UK in 2021  
   Query: [question_5.sql](question_5.sql), Output: [question_5.csv](question_5.csv)

## Installation and Usage Instructions

1. Clone the repo in your local environment by inputting `git clone https://github.com/karen-mckendry/data-analytics-power-bi-report973.git` in your terminal.
2. Open the Power BI file (Power-BI-Project.pbix) using Power BI Desktop.
3. Explore the various visualisations and insights.
4. Filter using sliders
5. Monitor the KPIs against targets to assess performance.
6. Use the drill-down functionality to delve deeper into specific time periods or categories.

## License

GNU GENERAL PUBLIC LICENSE Version 3
