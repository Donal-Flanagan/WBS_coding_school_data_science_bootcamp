USE publications;

SELECT * 
FROM sales 
ORDER BY ord_date;

-- Total quantity per order
SELECT
    ord_num, 
    sum(qty) AS total_qty
FROM
    sales 
GROUP BY
    ord_num;

-- Total quantity of all orders on each date
SELECT *, SUM(qty) OVER (PARTITION BY ord_date) AS order_sales
FROM sales;

-- Total quantity of each order
SELECT *, SUM(qty) OVER (PARTITION BY ord_num) AS order_sales
FROM sales
order by ord_date;

-- Cumulative quantity counting from first date to last
SELECT *, SUM(qty) OVER (ORDER BY ord_date) AS cum_sales
FROM sales;

-- Cumulative quantity by date, per year
SELECT
    *,
    YEAR(ord_date),
    SUM(qty) OVER (PARTITION BY YEAR(ord_date) ORDER BY ord_date) AS year_sales
FROM
    sales;
    
-- All of the above by date
SELECT
    ord_num, 
    ord_date, 
    qty,
    SUM(qty) OVER (PARTITION BY ord_date) AS order_sales,
    SUM(qty) OVER (ORDER BY ord_date) AS cum_sales,
    SUM(qty) OVER (PARTITION BY YEAR(ord_date) ORDER BY ord_date) AS cum_year_sales
FROM sales;

-- count of different titles sold per order
SELECT
    ord_num, 
    title_id,
    qty,
    COUNT(title_id) OVER (PARTITION BY ord_num) AS titles_in_order
FROM sales
ORDER BY ord_date;

-- average quantity of titles purchased by order
SELECT
    ord_num, 
    title_id,
    qty,
    AVG(qty) OVER (PARTITION BY ord_num) AS avg_qty_by_order
FROM sales
ORDER BY ord_date;

-- Window functions allow us to display something extremely simple: the row number.
SELECT
    ord_num, 
    ord_date,
    ROW_NUMBER() OVER (ORDER BY ord_date) AS row_num
FROM sales;

-- Make orders with an identical date share a value with ‘rank’
SELECT
    ord_num, 
    ord_date,
    RANK() OVER (PARTITION BY YEAR(ord_date) ORDER BY ord_date) AS row_rank_year
FROM sales;

-- Group the orders by date and order number
SELECT
    ord_num, 
    ord_date,
    RANK() OVER (PARTITION BY YEAR(ord_date) ORDER BY ord_date, ord_num) AS row_rank_year
FROM sales;

-- If we remove the partition by year, you will notice something about RANK()’s behaviour: 
-- the first three rows share the same rank (1), so the next row gets rank number 4 (so, counting from the start)
SELECT
    ord_num, 
    ord_date,
    RANK() OVER (ORDER BY ord_date, ord_num) AS row_rank_year
FROM sales;

-- If we don’t want these jumps, we can use DENSE_RANK():
SELECT
    ord_num, 
    ord_date,
    DENSE_RANK() OVER (ORDER BY ord_date, ord_num) AS row_rank_year
FROM sales;




