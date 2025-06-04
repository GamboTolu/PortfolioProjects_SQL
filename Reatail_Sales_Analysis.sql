-- USE Project3;

-- DROP TABLE IF EXISTS retail_sales;

-- CREATE TABLE retail_sales
			(
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(15),
				age INT,
				category VARCHAR(15),
				quantity INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
			);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM retail_sales 
;

SELECT COUNT(*)
FROM retail_sales 
;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DATA CLEANING

-- HIGHLIGHT NULL VALUES

SELECT *
FROM retail_sales 
WHERE 
	age IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL
;


-- CREATE TEMPORARY TABLE FOR ROWS WITH NULL VALUES

CREATE TEMPORARY TABLE temp_null_rows AS
SELECT *
FROM retail_sales
WHERE 
    age IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL
;

SELECT * FROM temp_null_rows;


-- DELETE ROWS WITH NULL VALUES

DELETE FROM retail_sales
WHERE transactionS_id IN (
    SELECT transactionS_id FROM temp_null_rows
)
;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DATA EXPLORATION

-- HOW MANY SALES
SELECT COUNT(*) AS total_sale
FROM retail_sales
;

-- HOW MANY UNIQUE CUSTOMERS
SELECT COUNT(DISTINCT customer_id) AS total_sale
FROM retail_sales
;

-- LIST UNIQUE CATEGORIES
SELECT DISTINCT category 
FROM retail_sales
;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- retrieve all columns for sales made on particular date e.g (2022-11-05)

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05'
;

-- retrieve all transactions where the category is ('Clothing') and the quantity sold is (> 4) in the month of (Nov-2022)

SELECT  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
    AND
    quantity >= 4
;

-- calculate the total sales (total_sale) for each category

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY category
;

-- find the average age of customers who purchased items from the ('Beauty') category

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'
;

-- find all transactions where the total_sale is greater than 1000

SELECT * 
FROM retail_sales
WHERE total_sale > 1000
;

-- find the total number of transactions (transaction_id) made by each gender in each category

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY category
;

-- calculate the average sale for each month 

 
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    AVG(total_sale) AS avg_sale
FROM retail_sales
GROUP BY year, month
ORDER BY year, month
;


-- Find the best selling month in each year

SELECT 
    year,
    month,
    avg_sale
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale
    FROM retail_sales
    GROUP BY year, month
) AS monthly_avg
WHERE (year, avg_sale) IN (
    SELECT 
        year,
        MAX(avg_sale)
    FROM (
        SELECT 
            EXTRACT(YEAR FROM sale_date) AS year,
            EXTRACT(MONTH FROM sale_date) AS month,
            AVG(total_sale) AS avg_sale
        FROM retail_sales
        GROUP BY year, month
    ) AS inner_avg
    GROUP BY year 
);

-- The subqueries both group by year and month.
-- We safely use only columns selected in each subquery.
-- The outer WHERE (year, avg_sale) clause filters the max average sale per year


-- find the top 5 customers based on the highest total sales 

SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY customer_id 
ORDER BY total_sales  DESC
LIMIT 5
;

-- find the number of unique customers who purchased items from each category

SELECT 
    category,    
    COUNT(DISTINCT customer_id) as unique_customers
FROM retail_sales
GROUP BY category
;

-- create shifts and count number of orders in each shift {shift = (Morning <12, Afternoon Between 12 & 17, Evening >17)}
-- Create shifts

SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
;

-- number of orders per shift

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift
;























