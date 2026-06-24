--Create Database--  
SELECT COUNT(*)
FROM telecom_customers;

-- Import Dataset-- 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/telecom_sql_dataset.csv'
INTO TABLE telecom_sql_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Verify Data Loaded-- 
SELECT COUNT(*) FROM telecom_sql_dataset;

-- DATA CLEANING--
CREATE TABLE telecom_customers_cleaned AS
SELECT *
FROM telecom_sql_dataset;
DELETE FROM telecom_customers_cleaned
WHERE mobile_number IS NULL;
CREATE TABLE telecom_customers_final AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY mobile_number ORDER BY mobile_number) AS rn
    FROM telecom_customers_cleaned
) t
WHERE rn = 1;

-- 1. Check dataset size--
SELECT COUNT(*) AS total_rows
FROM telecom_customers_final;

-- 2. Check duplicate confirmation--
SELECT mobile_number, COUNT(*) AS cnt
FROM telecom_customers_final
GROUP BY mobile_number
HAVING cnt > 1; 

-- 3. Check NULL values--
SELECT 
    COUNT(*) AS total_rows,
    COUNT(mobile_number) AS mobile_not_null,
    COUNT(arpu_6) AS arpu6_not_null,
    COUNT(total_rech_amt_6) AS recharge_not_null
FROM telecom_customers_final; 

-- 4. Standardize categorical columns--
UPDATE telecom_customers_final
SET `Recharge_Category (8)` = UPPER(`Recharge_Category (8)`),
    `Recharge_Segment (8)` = UPPER(`Recharge_Segment (8)`); 
    
-- 5. Trim spaces--
UPDATE telecom_customers_final
SET `Recharge_Category (8)` = TRIM(`Recharge_Category (8)`),
    `Recharge_Segment (8)` = TRIM(`Recharge_Segment (8)`); 
    
    -- KPI QUERIES--
   --  1: Total Customers --
   SELECT COUNT(*) AS total_customers
FROM telecom_customers_final;
-- 2: Total Revenue --
SELECT 
    SUM(arpu_6 + arpu_7 + arpu_8) AS total_revenue
FROM telecom_customers_final;
 -- 3: Recharge Category Distribution -- 
 SELECT 
    `Recharge_Category (8)`,
    COUNT(*) AS customers
FROM telecom_customers_final
GROUP BY `Recharge_Category (8)`;
-- 4: Recharge Segment Distribution --  
SELECT 
    `Recharge_Segment (8)`,
    COUNT(*) AS customers
FROM telecom_customers_final
GROUP BY `Recharge_Segment (8)`;
-- 5: Monthly Recharge Trend --
SELECT 
    SUM(total_rech_amt_6) AS June,
    SUM(total_rech_amt_7) AS July,
    SUM(total_rech_amt_8) AS August
FROM telecom_customers_final; 
-- 6: Data Usage Trend --
SELECT 
    SUM(vol_2g_mb_6 + vol_3g_mb_6) AS June_Data,
    SUM(vol_2g_mb_7 + vol_3g_mb_7) AS July_Data,
    SUM(vol_2g_mb_8 + vol_3g_mb_8) AS August_Data
FROM telecom_customers_final; 
-- 7: High Value Customers --
SELECT COUNT(*) AS high_value_customers
FROM telecom_customers_final
WHERE (arpu_6 + arpu_7 + arpu_8)/3 > 500;  
-- 8. Average ARPU KPI --
SELECT ROUND(AVG(arpu_8),2) AS Avg_ARPU
FROM telecom_customers_final;  
-- 9. Average Recharge Amount KPI --
SELECT ROUND(AVG(total_rech_amt_8),2) AS Avg_Recharge_Amount
FROM telecom_customers_final;  
-- 10. Average Recharge Count KPI --
SELECT ROUND(AVG(total_rech_num_8),2) AS Avg_Recharge_Count
FROM telecom_customers_final; 
-- 11. Customer Distribution by ARPU Segment --
SELECT
`ARPU Segment(8) (new created)` AS ARPU_Segment,
COUNT(*) AS Customers
FROM telecom_customers_final
GROUP BY `ARPU Segment(8) (new created)`
ORDER BY Customers DESC;
-- 12. Revenue by ARPU Segment --
SELECT
`ARPU Segment(8) (new created)` AS ARPU_Segment,
ROUND(AVG(arpu_8),2) AS Avg_ARPU
FROM telecom_customers_final
GROUP BY `ARPU Segment(8) (new created)`
ORDER BY Avg_ARPU DESC;
-- 13. Revenue by Recharge Segment --
SELECT
`Recharge_Segment (8)`,
ROUND(AVG(arpu_8),2) AS Avg_ARPU
FROM telecom_customers_final
GROUP BY `Recharge_Segment (8)`
ORDER BY Avg_ARPU DESC;
-- 15. Top 10 Revenue Customers --
SELECT
mobile_number,
arpu_8
FROM telecom_customers_final
ORDER BY arpu_8 DESC
LIMIT 10;  
-- 16. Top 10 Recharge Customers --
SELECT
mobile_number,
total_rech_amt_8
FROM telecom_customers_final
ORDER BY total_rech_amt_8 DESC
LIMIT 10;  
-- 17. Top 10 Data Users --
SELECT
mobile_number,
Total_Data_Usage
FROM telecom_customers_final
ORDER BY Total_Data_Usage DESC
LIMIT 10;  
-- 18. ARPU Trend Analysis --
SELECT
ROUND(AVG(arpu_6),2) AS Month6_ARPU,
ROUND(AVG(arpu_7),2) AS Month7_ARPU,
ROUND(AVG(arpu_8),2) AS Month8_ARPU
FROM telecom_customers_final;  
-- 19. Recharge Trend Analysis --
SELECT
ROUND(AVG(total_rech_amt_6),2) AS Month6_Recharge,
ROUND(AVG(total_rech_amt_7),2) AS Month7_Recharge,
ROUND(AVG(total_rech_amt_8),2) AS Month8_Recharge
FROM telecom_customers_final;  
-- 20. Combined Summary --
SELECT
COUNT(*) AS Total_Customers,
ROUND(AVG(arpu_8),2) AS Avg_ARPU,
ROUND(AVG(total_rech_amt_8),2) AS Avg_Recharge,
ROUND(AVG(total_rech_num_8),2) AS Avg_Recharge_Count,
SUM(arpu_8) AS Total_Revenue
FROM telecom_customers_final; 




 