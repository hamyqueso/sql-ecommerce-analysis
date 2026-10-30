Tables in d8a_ecommerce database

customers                 orders                     order_items               products
-----------------         --------------------       ----------------------    ---------------
id            (PK) <----  customer_id   (FK)         id            (PK)      >  id        (PK)
name                      id            (PK) <-----  order_id      (FK)      |  name
country                   order_date                 product_id    (FK) -----| category
segment                   status                     quantity                  price
signup_date               total_amount               unit_price                cost
email
phone


# We want the number of rows from each table in the database
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers UNION ALL
SELECT 'orders', COUNT(*) FROM orders UNION ALL
SELECT 'products', COUNT(*) FROM products UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;


# Looking to compare the amount of distinct order ids with number of rows in the orders table

SELECT COUNT(*) AS total_rows, COUNT(DISTINCT id) AS distinct_ids FROM orders;


# want to find the order ids that appear more than once

SELECT id, COUNT(id) AS copies FROM orders
GROUP BY id 
HAVING copies > 1;


SELECT * FROM orders
WHERE id in 
(SELECT id AS copies FROM orders
GROUP BY id 
HAVING COUNT(id) > 1)
ORDER BY id
;

## first query identifies which ids are repeating. Second query shows that each duplicate is the same row loaded twice
## I want to remove each of the duplicates so that it does not affect any queries I may use from the orders table

# want to see how many of each type of order status is in the orders table

SELECT status, count(status) AS order_count FROM orders
GROUP BY status;

## we see that there are different spellings/capitalizations for the same order status


# Looking at the number of missing total amount values in the orders table

SELECT COUNT(*) orders_missing_amount FROM orders WHERE total_amount IS NULL;


# Looking at the number of missing countries in the customers table

SELECT COUNT(*) AS customers_missing_country FROM customers 
WHERE country IS NULL OR TRIM(country) = '';


# first and last order by date

SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order 
FROM orders;

# Error when looking at total amount in orders table and order_items

The amounts in orders does not match the amount that you would get if you
multiply the (quantity * unit_price) found in the order_items table.  In this case so far we have been only using the total_amount column from the order table to calculate values such as total_revenue.

# comparing order count and total_amount sum in orders before data cleaning

SELECT COUNT(*), SUM(total_amount) FROM orders WHERE status = 'completed';

 count |    sum
-------+------------
  2864 | 2314828.67

SELECT COUNT(*), SUM(total_amount) FROM orders WHERE LOWER(TRIM(status)) LIKE 'completed';

 count |    sum
-------+------------
  3121 | 2511443.81

We can see that if we were to just filter by status = 'completed' we would miss out on valuable data and it could alter our decisions in the future.  By trimming and lowering the case of the status columns we found 257 additional rows and $196,615.14 dollars in additional revenue that was missed by the original query.
