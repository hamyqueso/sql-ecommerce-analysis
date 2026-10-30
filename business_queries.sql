-- Q1. Who are our 5 best customers? 
-- Who are the 5 customers who spent the most on completed orders? 

WITH distinct_orders AS (
    SELECT DISTINCT * FROM orders
)
SELECT
    c.id                  AS customer_id,
    c.name                AS customer_name,
    COUNT(o.id)           AS order_count,
    SUM(o.total_amount)   AS total_revenue,
    ROUND(SUM(o.total_amount) / COUNT(o.id), 2) AS amount_per_order
FROM customers c
JOIN distinct_orders o ON o.customer_id = c.id
WHERE o.status LIKE '%ompleted'
  AND o.total_amount IS NOT NULL
GROUP BY c.id, c.name
ORDER BY total_revenue DESC
LIMIT 5;

-- The 5 customers with the most spent on completed orders are Sophie Leclerc, Maria Rodriguez,
-- John Garica, Carlos Leclerc, and Sarah Leclerc

-- Q2. How did revenue move month by month in 2024?
-- Normalize the order statuses and return month (format 2024-01), order_count, total_revenue, avg_order_value
-- for completed orders in the timeframe

-- Check the different statuses in the order table
-- SELECT
--    status                       AS original_status,
--    LOWER(TRIM(status))          AS normalized_status,
--    COUNT(*)                     AS row_count
--FROM orders
--GROUP BY status, LOWER(TRIM(status))
--ORDER BY normalized_status, row_count DESC;

-- Update the orders table
-- UPDATE orders
-- SET status = LOWER(TRIM(status))
-- WHERE status IS NOT NULL
-- AND status <> LOWER(TRIM(status));


-- Desired Query
WITH distinct_orders AS (
    SELECT DISTINCT * FROM orders
)
SELECT
    TO_CHAR(order_date, 'YYYY-MM')   AS month,
    COUNT(*)                         AS order_count,
    SUM(total_amount)                AS total_revenue,
    ROUND(AVG(total_amount), 2)      AS avg_order_value
FROM distinct_orders
WHERE status = 'completed'
  AND total_amount IS NOT NULL
  AND order_date >= '2024-01-01'
  AND order_date <  '2025-01-01'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- Q3. Which countries bring the revenue?
--For each customer country: completed revenue and its share of total completed revenue, in percent. 
--Normalise status.
--Keep customers with a blank country as a group called Unknown, so the shares add up to 100.


-- Based on this query we see that the customers are from around the world
-- The top 5 countries in order of highest revenue gained from are USA, Canada, Germany, Spain and the UK
WITH distinct_orders AS (
    SELECT DISTINCT * FROM orders
)
SELECT
    COALESCE(NULLIF(TRIM(c.country), ''), 'unknown')   AS country,
    SUM(o.total_amount)                                AS total_revenue,
    ROUND(
        100.0 * SUM(o.total_amount) / SUM(SUM(o.total_amount)) OVER (),
        2
    )                                                  AS pct_of_total
FROM distinct_orders o
LEFT JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'completed'
  AND o.total_amount IS NOT NULL
GROUP BY COALESCE(NULLIF(TRIM(c.country), ''), 'unknown')
ORDER BY total_revenue DESC;



-- Q4. Are cancellations getting worse?

-- For every month in the data: total orders, 
-- cancelled orders, and the cancellation rate in percent. 
-- Normalise status before you count.
-- A refund is not a cancellation here: count only cancelled orders.

-- Expected columns: month, total_orders, cancelled_orders, cancellation_rate

-- Based on the data it doesn't seem like cancellations are increasing
WITH distinct_orders AS (
    SELECT DISTINCT * FROM orders
)
SELECT
    TO_CHAR(order_date, 'YYYY-MM')                                        AS month,
    COUNT(*)                                                              AS total_orders,
    COUNT(*) FILTER (WHERE status = 'cancelled')                          AS cancelled_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'cancelled') / COUNT(*),
        2
    )                                                                     AS cancellation_rate
FROM distinct_orders
WHERE order_date IS NOT NULL
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;



-- Q5. Do enterprise customers buy differently?

-- Sales believes enterprise accounts are worth more per order. 
-- Compare enterprise customers with all other segments on completed orders: 
-- how many customers bought, how many orders, revenue, and average order value.
-- Normalise status.
-- Expected columns: customer_group (enterprise or other), 
-- customer_count, order_count, total_revenue, avg_order_value

-- Based on the data enterprise accounts do not spend more per order compared to all other customer accounts 
-- ($862.89/order other vs $690.69/order enterprise)

WITH distinct_orders AS (
    SELECT DISTINCT * FROM orders
)
SELECT
    CASE
        WHEN LOWER(TRIM(c.segment)) = 'enterprise' THEN 'enterprise'
        ELSE 'other'
    END                                AS customer_group,
    COUNT(DISTINCT o.customer_id)      AS customer_count,
    COUNT(o.id)                        AS order_count,
    SUM(o.total_amount)                AS total_revenue,
    ROUND(AVG(o.total_amount), 2)      AS avg_order_value
FROM distinct_orders o
LEFT JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'completed'
  AND o.total_amount IS NOT NULL
GROUP BY
    CASE
        WHEN LOWER(TRIM(c.segment)) = 'enterprise' THEN 'enterprise'
        ELSE 'other'
    END
ORDER BY total_revenue DESC;


-- Q6. Which customers have gone quiet?

-- Marketing wants to win back customers who 
-- bought before but have not bought since 1 July 2024. 
-- A purchase here means an order whose normalised status is completed or shipped. 
-- List those customers with the date of their last purchase and 
-- the number of days between it and 31 December 2024, the end of the data. 
-- Customers who never bought are out of scope.
--
-- Expected columns: customer_id, customer_name, last_order_date, days_inactive
--There are many customers who have not reordered anything in the last six months. The longest inactivty is 724 days.


WITH distinct_orders AS (
    SELECT DISTINCT * FROM orders
)
SELECT
    c.id                                            AS customer_id,
    c.name                                          AS customer_name,
    MAX(o.order_date)::date                         AS last_order_date,
    DATE '2024-12-31' - MAX(o.order_date)::date     AS days_inactive
FROM customers c
JOIN distinct_orders o ON o.customer_id = c.id
WHERE o.status IN ('completed', 'shipped')
GROUP BY c.id, c.name
HAVING MAX(o.order_date) < '2024-07-01'
ORDER BY days_inactive DESC;
