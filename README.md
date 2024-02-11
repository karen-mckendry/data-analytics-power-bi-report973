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

I used a card to display the measure created earlier for Total Customers, and created a further measure `Revenue Per Customer = [Total Revenue] / [Total Customers]` which I displayed on another card. The number of customers in each country was visualised in a donut chart, and the the number of customers for each product category in a bar chart. Next I added a line chart showing the total customers over time, which is displayed by year but can be drilled down to months, and added a forecast for the next 10 months with a 95% confidence interval.

The top 20 customers by revenue were displayed as a table, with conditional formatting bars on the revenue column, and their total orders also included.  For the top customer by revenue, three cards were added displaying their name, number of orders and total revenue. The name card used the Full Name field with a TopN filter set to show the top 1 value by Total Revenue. I copied this card to create the other two, and added the Total Orders and Total Revenue measures. 

Finally a date slicer was added to filter the data by year.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/8b4dd9fc-b1a8-4e52-8cf0-5de65937f836)

## The Executive Summary Page

For the Executive Summary, first I used copies of a card visual from the Customer Detail page to create three new card visuals with the key measures of Total Revenue, Total Orders and Total Profit. Similarly I copied the line graph from the Customer Detail page and amended the y-axis to Total Revenue, removed and readded the Date Hierarchy with Start of Year, Start of Quarter, Start of Month (drill-down did not function without doing this), and added a forecast as above. Two copies of the donut chart from the Customer Detail page were adapted for Total Revenue by country the stores were located in, and Total Revenue by store type. The bar chart was also adapted from the Customer Detail Page, with the chart type changed and showing Total Orders by category instead. 

Three KPI visuals were added for Revenue, Profit and Orders, each showing the most recent quarter's figures, with a target equal to the previous quarter plus 5%. 

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/bbe58d7f-5eb7-4b67-a13c-e71c09efedda)

## The Product Detail Page

This page looks at which products are performing well, with the ability to filter by product category and country. 

Three gauge visuals show the current performance of revenue, profit and orders against target values of 10% greater than the previous quarter. Measures were created for the previous quarter's performance, eg for revenue `Previous Quarter Revenue = CALCULATE(TOTALQTD('Measures Table'[Total Revenue], `PREVIOUSQUARTER(LASTDATE('Dates'[Date]))))` and for the target. Conditional formatting was applied to display the callout value in red if the target had not yet been met, and black otherwise, using measures, eg `Colours Orders Gauge = SWITCH(TRUE(),[Orders QTD] >= [Target 2 Orders for Quarter],"Black","Red")`. 

Two cards were added to display current filters for product category and country. I created an area chart to show revenue for each product category over time. Next a table of the top 10 products in terms of revenue was added, showing total revenue, total customers, orders and profit per order.  

To see which products are both the most profitable and the best selling, I added a scatter graph of products' profit per item against total quantity sold.  

The screenshot below shows the finished page without any filters:  

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/8494ecec-79de-48bf-8d88-5cdd366dcc71)

In order for the user to filter by product category and country, I created a pop-out slicer toolbar, accessible from the filter button on the navigation toolbar on the left. Clicking on the filter icon uses a bookmark to make the toolbar visible, and similarly clicking on the back button uses a bookmark to hide it again.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/d78f925e-7e0f-47ea-8969-6953401e9ba3)

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/c4419339-cd21-4ec1-be09-bcdbf59f7450)

## Creating the Stores Map Page

This page contains a map visual for store location, with bubble size dependent on Profit YTD so that current performance is easily available. I used the Geography hierarchy above to enable drill down to the the store location, and added a tile slicer to filter by country. 

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/0492fcbc-d939-401c-98d3-86d9ad7534fa)

To enable convenient checking on store performance, I added a drillthrough page with a range of visuals. A card was added to display the currently selected store location using a measure `Store Selection = IF(ISFILTERED(Stores[Country Region]),SELECTEDVALUE(Stores[Country Region],"No selection"),"No selection")`. The five products generating the most profit in the current year were displayed in a table along with their YTD profit, orders and revenue. Two gauge visuals were added to measure Revenue YTD against Revenue Goal, and Profit YTD against Profit Goal.  I created two new measures to use as the goal values, which were 20% above the same period in the previous year, eg `Profit Goal = CALCULATE([Profit YTD], SAMEPERIODLASTYEAR(Dates[Date]))*1.2`. The final visual added to the drillthrough page was a bar chart displaying the total orders by category in the store.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/22e9b3b3-da32-44a8-9d58-ad4bd140558e)

I created a tooltip page with a copy of the profit YTD gauge from the drillthrough page, so that by hovering over a store in the Stores Map page, you can immediately see the current profit against the goal. With the tooltip added, the region name no longer displayed when hovering over a bubble. I tried to add this as a card in the visual, but couldn't find a way to left align the text, so instead I added a text box and entered the name of the store selection measure as the value.

![image](https://github.com/karen-mckendry/data-analytics-power-bi-report973/assets/150865532/87ae8675-5b53-4d9a-bf2b-f49014e311a3)
