/* ============================================================
   E-Commerce Sales and Data Quality Analysis
   Tool: SQL Server
   Purpose:
   - Clean online retail transaction data
   - Create reporting-ready SQL views
   - Connect the views to Power BI for dashboard visuals
   ============================================================ */


-- ============================================================
-- 1. Preview Original Dataset
-- ============================================================

SELECT TOP 1000 * 
FROM [Online Retail].[dbo].[online_retail_II];


-- ============================================================
-- 2. Add Cleaned Columns
-- Price_Clean converts Price into a decimal format.
-- Customer_ID_Clean removes the .0 from Customer_ID values.
-- These columns are used for analysis and Power BI reporting.
-- ============================================================

IF COL_LENGTH('[Online Retail].[dbo].[online_retail_II]', 'Price_Clean') IS NULL
BEGIN
    ALTER TABLE [Online Retail].[dbo].[online_retail_II]
    ADD Price_Clean decimal(10,2);
END;

IF COL_LENGTH('[Online Retail].[dbo].[online_retail_II]', 'Customer_ID_Clean') IS NULL
BEGIN
    ALTER TABLE [Online Retail].[dbo].[online_retail_II]
    ADD Customer_ID_Clean nvarchar(50);
END;


-- ============================================================
-- 3. Populate Cleaned Columns
-- Price is converted to decimal.
-- Customer_ID is converted from decimal format into clean text.
-- NULL customer IDs remain NULL.
-- ============================================================

UPDATE [Online Retail].[dbo].[online_retail_II]
SET 
    Price_Clean = CAST(Price AS decimal(10,2)),
    Customer_ID_Clean =
        CASE
            WHEN Customer_ID IS NULL THEN NULL
            ELSE CAST(CAST(CAST(Customer_ID AS decimal(18,1)) AS int) AS nvarchar(50))
        END;


-- ============================================================
-- 4. Preview Updated Table
-- ============================================================

SELECT TOP 20 *
FROM [Online Retail].[dbo].[online_retail_II];


-- ============================================================
-- 5. Power BI Reporting Views
-- These views make the SQL work reusable.
-- Power BI can connect directly to these views instead of the raw table.
-- ============================================================

GO

-- ============================================================
-- Main Clean Sales View
-- Used as the main clean transaction dataset in Power BI.
-- Includes positive sales only, valid prices, and valid descriptions.
-- Adds a Revenue column for reporting.
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_sales_clean AS
SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price_Clean,
    Customer_ID_Clean,
    Country,
    Quantity * Price_Clean AS Revenue
FROM [Online Retail].[dbo].[online_retail_II]
WHERE Quantity > 0
  AND Price_Clean > 0
  AND Description IS NOT NULL;

GO


-- ============================================================
-- Monthly Revenue View
-- Used for revenue trend visuals in Power BI.
-- Shows monthly revenue using positive sales only.
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_monthly_revenue AS
SELECT 
    YEAR(InvoiceDate) AS Sales_Year,
    MONTH(InvoiceDate) AS Sales_Month,
    SUM(Quantity * Price_Clean) AS Revenue
FROM [Online Retail].[dbo].[online_retail_II]
WHERE Price_Clean > 0
  AND Quantity > 0
GROUP BY 
    YEAR(InvoiceDate), 
    MONTH(InvoiceDate);

GO


-- ============================================================
-- Product Revenue View
-- Used for top product visuals in Power BI.
-- Excludes non-product records such as test codes, postage,
-- gift vouchers, bank fees, damaged inventory notes, returns,
-- samples, adjustments, and other non-sale records.
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_product_revenue AS
WITH Cleaned AS (
    SELECT
        StockCode,
        UPPER(LTRIM(RTRIM(StockCode))) AS StockCode_Clean,
        Description,
        UPPER(LTRIM(RTRIM(Description))) AS Description_Clean,
        Quantity,
        Price_Clean
    FROM [Online Retail].[dbo].[online_retail_II]
)
SELECT 
    StockCode,
    MAX(Description) AS Product_Description,
    SUM(Quantity) AS Total_Quantity_Sold,
    SUM(Quantity * Price_Clean) AS Revenue
FROM Cleaned
WHERE StockCode_Clean NOT LIKE 'TEST%'
  AND StockCode_Clean NOT LIKE 'GIFT_%'
  AND StockCode_Clean NOT LIKE 'DCGS%'
  AND StockCode_Clean NOT LIKE 'ADJUST%'
  AND StockCode_Clean NOT IN (
      'S', 'POST', 'SP1002', 'DOT', 'C2', 'PADS',
      'M', 'D', 'B', 'CRUK', 'AMAZONFEE',
      'BANK CHARGES', 'C3', 'GIFT'
  )
  AND Description IS NOT NULL
  AND Quantity > 0
  AND Price_Clean > 0
  AND Description_Clean NOT LIKE '%BROKEN%'
  AND Description_Clean NOT LIKE '%SMASHED%'
  AND Description_Clean NOT LIKE '%DAMAGED%'
  AND Description_Clean NOT LIKE '%DAMAGE%'
  AND Description_Clean NOT LIKE '%MOULDY%'
  AND Description_Clean NOT LIKE '%WET%'
  AND Description_Clean NOT LIKE '%RUSTY%'
  AND Description_Clean NOT LIKE '%DESTROYED%'
  AND Description_Clean NOT LIKE '%UNSALEABLE%'
  AND Description_Clean NOT LIKE '%THROWN%'
  AND Description_Clean NOT LIKE '%WRONGLY%'
  AND Description_Clean NOT LIKE '%WRONG%'
  AND Description_Clean NOT LIKE '%INCORRECTLY%'
  AND Description_Clean NOT LIKE '%ADJUST%'
  AND Description_Clean NOT LIKE '%MISSING%'
  AND Description_Clean NOT LIKE '%LOST%'
  AND Description_Clean NOT LIKE '%MIX UP%'
  AND Description_Clean NOT LIKE '%PUT ASIDE%'
  AND Description_Clean NOT LIKE '%GIVEN AWAY%'
  AND Description_Clean NOT LIKE '%FOUND%'
  AND Description_Clean NOT LIKE '%WEBSITE FIXED%'
  AND Description_Clean NOT LIKE '%TEMP%'
  AND Description_Clean NOT LIKE '%SAMPLE%'
  AND Description_Clean NOT LIKE '%MAILOUT%'
  AND Description_Clean NOT LIKE '%DISPLAY%'
  AND Description_Clean NOT LIKE '%DOTCOM%'
  AND Description_Clean NOT LIKE '%CARRIAGE%'
  AND Description_Clean NOT LIKE '%RETURN%'
  AND Description_Clean NOT IN (
      'MIA', 'CHECK', 'TEMP', 'COUNTED',
      'SHOW', 'RETURNED', 'ADJUSTMENT', 'GONE'
  )
GROUP BY StockCode;

GO


-- ============================================================
-- Customer Sales View
-- Used to identify highest-value customers.
-- Includes only positive sales and valid customer IDs.
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_customer_sales AS
SELECT 
    Customer_ID_Clean,
    COUNT(DISTINCT Invoice) AS total_orders,
    SUM(Quantity) AS total_items_purchased,
    SUM(Price_Clean * Quantity) AS total_revenue
FROM [Online Retail].[dbo].[online_retail_II]
WHERE Quantity > 0
  AND Price_Clean > 0
  AND Customer_ID_Clean IS NOT NULL
GROUP BY Customer_ID_Clean;

GO


-- ============================================================
-- Country Sales View
-- Used for country-level sales visuals.
-- Excludes unspecified countries and invalid sales values.
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_country_sales AS
SELECT 
    Country, 
    COUNT(DISTINCT Invoice) AS total_orders,
    SUM(Quantity) AS total_items_purchased,
    SUM(Quantity * Price_Clean) AS Total_Revenue
FROM [Online Retail].[dbo].[online_retail_II]
WHERE Country <> 'Unspecified'
  AND Country IS NOT NULL
  AND Quantity > 0
  AND Price_Clean > 0
GROUP BY Country;

GO


-- ============================================================
-- KPI Summary View
-- Used for Power BI KPI cards.
-- Calculates sales KPIs and return rate.
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_kpi_summary AS
WITH KPI_summary AS (
    SELECT
        COUNT(DISTINCT Customer_ID_Clean) AS total_customers,
        COUNT(DISTINCT Invoice) AS total_orders,
        SUM(Quantity) AS total_items_purchased,
        SUM(Quantity * Price_Clean) AS Total_Revenue
    FROM [Online Retail].[dbo].[online_retail_II]
    WHERE Price_Clean > 0
      AND Quantity > 0
),
Return_KPI AS (
    SELECT
        ABS(SUM(Quantity)) AS returned_items
    FROM [Online Retail].[dbo].[online_retail_II]
    WHERE Price_Clean > 0
      AND Quantity < 0
)
SELECT 
    s.total_customers, 
    s.total_orders, 
    s.total_items_purchased, 
    s.Total_Revenue,
    r.returned_items,
    CAST(ROUND(s.Total_Revenue / s.total_orders, 2) AS decimal(10,2)) AS Average_Order_Value,
    CAST(ROUND((r.returned_items * 1.0 / s.total_items_purchased) * 100, 2) AS decimal(10,2)) AS item_return_rate_percent
FROM KPI_summary AS s
CROSS JOIN Return_KPI AS r;

GO


-- ============================================================
-- Data Quality Summary View
-- Used to document missing values, invalid prices,
-- negative quantities, and unspecified countries.
-- This supports the data quality section of the project.
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_data_quality_summary AS
SELECT
    COUNT(*) AS total_records,

    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS missing_customer_ids,

    SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS missing_descriptions,

    SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END) AS negative_quantity_records,

    SUM(CASE WHEN Quantity = 0 THEN 1 ELSE 0 END) AS zero_quantity_records,

    SUM(CASE WHEN Price_Clean <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_price_records,

    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS missing_country_records,

    SUM(CASE WHEN Country = 'Unspecified' THEN 1 ELSE 0 END) AS unspecified_country_records
FROM [Online Retail].[dbo].[online_retail_II];

GO


-- ============================================================
-- 6. Test Views
-- Run these to confirm the Power BI views work correctly.
-- ============================================================

SELECT TOP 100 *
FROM dbo.vw_sales_clean;

SELECT TOP 100 *
FROM dbo.vw_monthly_revenue
ORDER BY Sales_Year, Sales_Month;

SELECT TOP 100 *
FROM dbo.vw_product_revenue
ORDER BY Revenue DESC;

SELECT TOP 100 *
FROM dbo.vw_customer_sales
ORDER BY total_revenue DESC;

SELECT TOP 100 *
FROM dbo.vw_country_sales
ORDER BY Total_Revenue DESC;

SELECT *
FROM dbo.vw_kpi_summary;

SELECT *
FROM dbo.vw_data_quality_summary;