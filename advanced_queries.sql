-- A1. What are the 3 best-selling products in each category?

-- Revenue here means the value of the order lines (quantity * unit_price) of completed orders.
-- Normalise status. Rank products inside their category by that revenue and keep the top 3 of each.

-- Expected columns: category, product_name, revenue, rank_in_category

-- The following query calculates revenue as (quantity * unit_price)

-- category  |    product_name     |  revenue   | rank_in_category
------------+---------------------+------------+------------------
 -- Cases      | Case Model 185      |  172032.59 |                1
 -- Cases      | Case Model 176      |  141591.31 |                2
 -- Cases      | Case Model 165      |   63784.85 |                3
 -- Chairs     | Chair Model 62      |  152842.56 |                1
 -- Chairs     | Chair Model 110     |  109805.13 |                2
 -- Chairs     | Chair Model 135     |   40362.24 |                3
 -- Chargers   | Charger Model 180   |  647519.78 |                1
 -- Chargers   | Charger Model 17    |   83543.17 |                2
 -- Chargers   | Charger Model 34    |   43521.72 |                3
 -- Desks      | Desk Model 85       | 1483423.39 |                1
 -- Desks      | Desk Model 123      |  137086.62 |                2
 -- Desks      | Desk Model 40       |  117217.42 |                3
 -- Headphones | Headphone Model 197 |  200278.52 |                1
 -- Headphones | Headphone Model 136 |  122571.57 |                2
 -- Headphones | Headphone Model 22  |   86495.68 |                3
 -- Laptops    | Laptop Model 56     |  593253.65 |                1
 -- Laptops    | Laptop Model 1      |  446030.66 |                2
 -- Laptops    | Laptop Model 138    |  218054.81 |                3
 -- Monitors   | Monitor Model 48    |   95141.93 |                1
 -- Monitors   | Monitor Model 37    |   41968.61 |                2
 -- Monitors   | Monitor Model 146   |   33664.28 |                3
 -- Phones     | Phone Model 187     |  215386.82 |                1
 -- Phones     | Phone Model 18      |   68655.79 |                2
 -- Phones     | Phone Model 157     |   42183.64 |                3
 -- Software   | Software Model 81   |  119505.12 |                1
 -- Software   | Software Model 179  |   75542.33 |                2
 -- Software   | Software Model 141  |   50696.65 |                3
 -- Tablets    | Tablet Model 111    |  286868.70 |                1
 -- Tablets    | Tablet Model 152    |  137540.17 |                2
 -- Tablets    | Tablet Model 96     |   62987.42 |                3

WITH distinct_orders AS (
    SELECT DISTINCT * FROM orders
),
product_revenue AS (
    SELECT
        p.id                            AS product_id,
        p.category                      AS category,
        p.name                          AS product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM distinct_orders o
    JOIN order_items oi ON oi.order_id = o.id
    JOIN products p     ON p.id = oi.product_id
    WHERE o.status = 'completed'
      AND oi.quantity IS NOT NULL
      AND oi.unit_price IS NOT NULL
    GROUP BY p.id, p.category, p.name
),
ranked AS (
    SELECT
        category,
        product_name,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY revenue DESC, product_name
        ) AS rank_in_category
    FROM product_revenue
)
SELECT
    category,
    product_name,
    ROUND(revenue, 2) AS revenue,
    rank_in_category
FROM ranked
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;


-- A2. How does revenue change from one month to the next?

-- For every month in the data: completed revenue from orders.total_amount, 
-- the previous month's revenue, and the change in percent. Normalise status. 
-- The first month has no previous month: leave it empty.

-- Expected columns: month, total_revenue, prev_month_revenue, mom_growth_pct

-- Going back to using total_amount from orders as the data for revenue
-- Some wild swings in revenue month to month. Some months revenue increasing by over 100% compared to the previous month
 -- month  | total_revenue | prev_month_revenue | mom_growth_pct
-------+---------------+--------------------+----------------
 -- 2023-01 |      92062.34 |                    |
 -- 2023-02 |      82749.52 |           92062.34 |         -10.12
 -- 2023-03 |      69864.50 |           82749.52 |         -15.57
 -- 2023-04 |      76291.52 |           69864.50 |           9.20
 -- 2023-05 |      88555.56 |           76291.52 |          16.08
 -- 2023-06 |     186364.24 |           88555.56 |         110.45
 -- 2023-07 |     145277.36 |          186364.24 |         -22.05
 -- 2023-08 |      95112.19 |          145277.36 |         -34.53
 -- 2023-09 |      74481.48 |           95112.19 |         -21.69
 -- 2023-10 |     156309.94 |           74481.48 |         109.86
 -- 2023-11 |     154058.94 |          156309.94 |          -1.44
 -- 2023-12 |      91347.86 |          154058.94 |         -40.71
 -- 2024-01 |      96099.96 |           91347.86 |           5.20
 -- 2024-02 |      79757.90 |           96099.96 |         -17.01
 -- 2024-03 |      72807.69 |           79757.90 |          -8.71
 -- 2024-04 |      66147.79 |           72807.69 |          -9.15
 -- 2024-05 |     105730.61 |           66147.79 |          59.84
 -- 2024-06 |      84984.76 |          105730.61 |         -19.62
 -- 2024-07 |     103953.82 |           84984.76 |          22.32
 -- 2024-08 |      95932.75 |          103953.82 |          -7.72
 -- 2024-09 |     156716.84 |           95932.75 |          63.36
 -- 2024-10 |      92892.13 |          156716.84 |         -40.73
 -- 2024-11 |     112832.12 |           92892.13 |          21.47
 -- 2024-12 |     122017.50 |          112832.12 |           8.14

WITH distinct_orders AS (
    SELECT DISTINCT * FROM orders
),
monthly AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM')  AS month,
        SUM(total_amount)               AS total_revenue
    FROM distinct_orders
    WHERE status = 'completed'
      AND total_amount IS NOT NULL
      AND order_date IS NOT NULL
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    month,
    ROUND(total_revenue, 2)                              AS total_revenue,
    ROUND(LAG(total_revenue) OVER (ORDER BY month), 2)   AS prev_month_revenue,
    ROUND(
        100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY month))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY month), 0),
        2
    )                                                    AS mom_growth_pct
FROM monthly
ORDER BY month;
