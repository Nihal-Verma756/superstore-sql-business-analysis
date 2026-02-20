-- =====================================================
-- SUPERSTORE BUSINESS ANALYSIS PROJECT
-- Author: Your Name
-- Tool: MySQL
-- =====================================================

-- =====================================================
-- LEVEL 1 – BASIC ANALYSIS
-- =====================================================

-- 1. Total Sales
SELECT ROUND(SUM(sales),2) AS total_sales 
FROM superstore;

-- 2. Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders 
FROM superstore;

-- 3. Total Unique Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers 
FROM superstore;

-- 4. Category-wise Total Sales
SELECT category, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY category;

-- 5. Region-wise Sales & Orders
SELECT 
region,
ROUND(SUM(sales),2) AS total_sales,
COUNT(DISTINCT order_id) AS total_orders
FROM superstore
GROUP BY region;

-- 6. State-wise Total Profit
SELECT state, ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY state;

-- 7. Segment-wise Sales
SELECT segment, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY segment;

-- 8. Top 10 Highest Sales Orders
SELECT order_id, ROUND(SUM(sales),2) AS order_total
FROM superstore
GROUP BY order_id
ORDER BY order_total DESC
LIMIT 10;

-- 9. Bottom 10 Loss-Making Orders
SELECT order_id, ROUND(SUM(profit),2) AS order_profit
FROM superstore
GROUP BY order_id
ORDER BY order_profit ASC
LIMIT 10;


-- =====================================================
-- LEVEL 2 – DATE BASED ANALYSIS
-- =====================================================

-- 10. Year-wise Total Sales
SELECT 
YEAR(order_date) AS year,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY YEAR(order_date);

-- 11. Month-wise Total Sales
SELECT 
MONTH(order_date) AS month,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY MONTH(order_date);

-- 12. Year-wise Profit Comparison
SELECT 
YEAR(order_date) AS year,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY YEAR(order_date);

-- 13. Quarter-wise Sales
SELECT 
YEAR(order_date) AS year,
QUARTER(order_date) AS quarter,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY YEAR(order_date), QUARTER(order_date);

-- 14. Month-over-Month Growth
SELECT 
year,
month,
total_sales,
ROUND(
((total_sales - LAG(total_sales) OVER (ORDER BY year,month))
/ LAG(total_sales) OVER (ORDER BY year,month)) * 100
,2) AS growth_percentage
FROM (
SELECT 
YEAR(order_date) AS year,
MONTH(order_date) AS month,
SUM(sales) AS total_sales
FROM superstore
GROUP BY YEAR(order_date), MONTH(order_date)
) t;

-- 15. Year-over-Year Growth
SELECT 
year,
total_sales,
LAG(total_sales) OVER (ORDER BY year) AS prev_sales,
ROUND((total_sales - LAG(total_sales) OVER (ORDER BY year)) 
/ LAG(total_sales) OVER (ORDER BY year) * 100,2) AS growth_percentage
FROM (
SELECT YEAR(order_date) AS year,
SUM(sales) AS total_sales
FROM superstore
GROUP BY YEAR(order_date)
) t;

-- 16. Running Total Sales (Year-wise)
SELECT 
year,
total_sales,
SUM(total_sales) OVER (ORDER BY year) AS running_total
FROM (
SELECT YEAR(order_date) AS year,
SUM(sales) AS total_sales
FROM superstore
GROUP BY YEAR(order_date)
) t;


-- =====================================================
-- LEVEL 3 – BUSINESS INSIGHTS
-- =====================================================

-- 17. Most Profitable Region
SELECT region, SUM(profit) AS total_profit
FROM superstore
GROUP BY region
ORDER BY total_profit DESC
LIMIT 1;

-- 18. Average Order Value
SELECT ROUND(AVG(order_total),2) AS average_order_value
FROM (
SELECT order_id, SUM(sales) AS order_total
FROM superstore
GROUP BY order_id
) t;

-- 19. Profit Margin by Category
SELECT 
category,
ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin
FROM superstore
GROUP BY category;

-- 20. Repeat Customers (2+ Orders)
SELECT 
customer_name,
COUNT(DISTINCT order_id) AS total_orders
FROM superstore
GROUP BY customer_name
HAVING COUNT(DISTINCT order_id) >= 2;

-- 21. Most Frequently Ordered Products
SELECT 
product_name,
COUNT(DISTINCT order_id) AS order_count
FROM superstore
GROUP BY product_name
ORDER BY order_count DESC;


-- =====================================================
-- LEVEL 4 – ADVANCED ANALYSIS
-- =====================================================

-- 22. Top 3 Products per Category
SELECT *
FROM (
SELECT 
category,
product_name,
SUM(sales) AS total_sales,
DENSE_RANK() OVER (
PARTITION BY category 
ORDER BY SUM(sales) DESC
) AS rnk
FROM superstore
GROUP BY category, product_name
) t
WHERE rnk <= 3;

-- 23. Sales Ranking by State
SELECT 
state,
SUM(sales) AS total_sales,
RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM superstore
GROUP BY state;

-- 24. Pareto Analysis (80/20 Rule)
SELECT *
FROM (
SELECT 
state,
total_sales,
SUM(total_sales) OVER (ORDER BY total_sales DESC) AS running_total,
SUM(total_sales) OVER () AS overall_total,
ROUND(
(SUM(total_sales) OVER (ORDER BY total_sales DESC)
/ SUM(total_sales) OVER ()) * 100,2
) AS cumulative_percentage
FROM (
SELECT state, SUM(sales) AS total_sales
FROM superstore
GROUP BY state
) t
) x
WHERE cumulative_percentage <= 80;

-- =====================================================
-- END OF PROJECT
-- =====================================================