# SQL E-Commerce Data Analysis
Exploration of simulated ecommerce data from an online electronics store

# Data 
Four Tables (customers: 1200 rows, orders: 5020 rows, order_items: 9423 rows,  products: 200 rows),
dates range from 2023-01-01 to 2024-12-31. Analyzed using SQlite and PostgreSQL.

# Results

## Key Findings
* Top 5 spending customers are: Sophie Leclerc ($80761.94), Maria Rodriguez ($71596.98), John Garcia ($69870.35), Carlos Leclerc ($66673.50), and Sarah Lecler ($46391.92)
* Top 5 spending countries by percent are: USA (10.93%), Canada (9.42%), Germany (8.96%), Spain (8.49%), and United Kingdom (8.47%)
* Based on quarterly earnings, Q1 in both 2023 and 2024 were the lowest quarters in both years (18.64% and 20.90%, respectively)

## Decisions with the data

 * There were several typos in the status column of the orders table. In order to clean the data I updated the values in the column to trim the whitespace and make all the values lowercase.  This allowed for easier filtering on the status column.
 * When determining revenue by country some rows of the customer table had missing country values. In order to include all the data I combined all rows with missing countries under the value 'unknown'. The 'unknown' country value accounted for 3.46% of the total sales revenue.
 * When finding answers relating to customers I used the total_amount column from the orders table.  For finding answers relating to products I calculated the amount made by selling by summing the product of (quantity * unit_price) for each product.
* When calculating revenue I filtered only by orders where the status was complete. Including 'shipped' orders could have also been valid but not chosen in this project.
* If I were to start this project over I may have updated the total_amount from the orders table to use the revenue from calculating product quantity times unit_price. In this case I chose to continue using the original column because I was lacking information on other factors (i.e. order discounts, payment options, etc.)

## Interview Script

## Interview script

**What problem did you work on, and for whom?**

My manager asked me to explore the data of customers and orders between January 2023 to December 2024.  They wanted to know who the best customers are, how the revenue moved month to month, which countries ordered the most and where orders get cancelled.

**What data did you use, and what are its limits?**

The data I used to complete my task was a database with tables for customers, orders, products, and order_items (relational table that linked which products were in each order).  The tables included data from January 2023 to December 2024, two years of sales records.  The data had some issues such as missing rows in the order_total column in the orders table, duplicates rows in the orders table, and different spellings in the status column of orders (i.e. "Completed" vs "completed").  In my queries I ignored rows that had missing values, removed the duplicate rows, and updated the table to standardize the statuses.

**How did you go about it, and why that way?**

In order to parse through the data I had to create several different queries, often joining two or more tables to find the required information. To find the top 5 customers I joined the orders and customers table and grouped by customer id to find the total amount of money spent by each customer then sorted by the totals to find our top customers.  Similar to finding the top customers, finding the top spending countries joined the orders and customer tables then grouping by country and sorting.  Determining change for cancellation rate required grouping orders by month and calculating the number of orders that had been cancelled in each month; cleaning the status column was important for this query because there were different spellings for the same status type.  Month to month revenue was found by grouping orders by month and totaling revenue.

**What did you find? Give the key number.**

I found that the top highest spending customer, Sophie Leclerc, exceeded the average order amount by 4812% per order. The top spending country was the USA, account for 10.93% of the total revenue over the span in the dataset.  Month to month orders seemed overall stable. Breaking down the query into quarters was slightly more insightful: we see that quarter 1 of both years accounted for the least amount of revenue (18.64% in 2023 and 20.9% in 2024).

**How do you know it is right?**

The way I checked the queries was by comparing the row counts. For example, in the query where I broke down the total_amount during each quarter it output a row count included in each quarter. I added those up and found that it was the exact same as the row count for a similar query only asking for distinct, completed orders in the orders table.

**With one more day, what would you do?**

One weak point in the data I found was the discrepancy between the total_amount column in the orders table compared to the amount calculated from the order_items table (grouping by order_id and summing(quantity * unit_price)).  This made calculating total revenue a bit ambiguous.  In most of the queries I used the total_amount from the orders table but with more time I would find who created or updated the database and find out why there was a difference between the two values.

**What did you hand to an AI assistant, and what did you check yourself?**

I prompted an AI assistant for all queries in this project. First, I laid out the design of the database and tables, showing the AI assistant the relationships between the tables. Then I would prompt the AI what queries I would like to see as well as the columns I wanted the queries to output. This part needed to be well communicated because the AI assistant could not see the actual data, so it required me to explain certain aspects of the data, such as the presence of duplicate rows and typos in certain columns.  Finally, I would verify the query that the AI assistant output and made sure that the query was indeed what I wanted.
