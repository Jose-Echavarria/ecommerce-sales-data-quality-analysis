# E-Commerce Sales and Data Quality Analysis

## Project Overview

This project analyzes an online retail dataset using SQL Server and Power BI. The goal was to clean raw transaction data, create reporting-ready SQL views, and build a Power BI dashboard that highlights revenue trends, customer behavior, product performance, country-level sales, key performance indicators, and data quality issues.

## Dashboard PDF

[View Dashboard PDF](./E-Commerce%20Sales%20Dashboard.pdf)

## Tools Used

* SQL Server
* Power BI
* GitHub

## Business Questions

* What is the total revenue generated?
* How does revenue trend over time?
* Which countries generate the most revenue?
* Which customers generate the most revenue?
* Which products sell the most by quantity and revenue?
* What data quality issues exist in the dataset?
* What is the item return rate?

## SQL Work Completed

* Created cleaned fields for price and customer ID.
* Removed invalid sales records from reporting views.
* Excluded non-product records such as test transactions, postage, gift vouchers, bank charges, damaged inventory notes, samples, returns, and adjustments.
* Built SQL views for Power BI reporting, including:

  * Monthly revenue
  * Product revenue
  * Customer sales
  * Country sales
  * KPI summary
  * Data quality summary

## Dashboard Pages

The Power BI dashboard includes:

1. Executive Summary
2. Country Sales Analysis
3. Customer Analysis
4. Product Analysis
5. Data Quality

## Key Insights

* Total revenue was approximately $20.97M.
* The United Kingdom generated the majority of revenue.
* Revenue showed seasonal spikes near the end of the year.
* Some customers generated high revenue even if they were not the highest by order count.
* Missing customer IDs were the largest data quality issue, with over 243K missing customer ID records.
* The item return rate was approximately 4.30%.

## Files Included

* `ecommerce_sales_data_quality_analysis.sql` — SQL cleaning and reporting views
* `E-Commerce Sales Dashboard.pbix` — Power BI dashboard file

## Project Purpose

This project demonstrates skills in SQL data cleaning, data quality analysis, KPI reporting, business intelligence, and dashboard development using SQL Server and Power BI.
