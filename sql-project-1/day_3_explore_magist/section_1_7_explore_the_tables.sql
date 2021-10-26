# Exploring the tables

USE magist;
# ------------------------------------------------------------------------
# 1. How many orders are there in the dataset?

select count(order_id) as orders_count
from orders;

# There are 99441 orders

# ------------------------------------------------------------------------
# 2. Are orders actually delivered? 
select order_status, count(*) as orders
from orders
group by order_status;

# 96478 orders delivered / 99441 orders = 97% delivered

# ------------------------------------------------------------------------
# 3. Is Magist having user growth? 
select year(order_purchase_timestamp) as year_, month(order_purchase_timestamp) as month_, count(customer_id)
from orders
group by year_, month_
order by year_, month_;

# The number of orders steadily increased in 2017 and 2018 but dropped to almost nothing in the last two months of 2018

# ------------------------------------------------------------------------
# 4. How many products are there in the products table? (Make sure that there are no duplicate products.)
select count(*)
from products;  # There are 32951 products

SELECT COUNT(DISTINCT product_id) AS products_count
FROM products;

# Check for duplicates
select *
from products;

select *, count(*) as num_duplicates
from products
group by product_name_length, product_description_length,product_photos_qty,product_weight_g,product_length_cm,product_height_cm,product_width_cm
having count(product_id) > 1
order by num_duplicates desc;

# There are lots of duplicates and I'm not sure how to count the distinct products

# Here I check how many products there are with the distinct values below
select *
from products
where product_category_name='perfumaria' and product_name_length=30 and 
product_description_length=138 and product_photos_qty=1 and 
product_weight_g=100 and product_length_cm=20 and 
product_height_cm=5 and product_width_cm=20;


# ------------------------------------------------------------------------
# 5. Which are the categories with most products?
select product_category_name, count(distinct(product_id)) as num_products
from products
group by product_category_name
order by num_products desc;

# cama_mesa_banho has the most products with 3029

# ------------------------------------------------------------------------
# 6. How many of those products were present in actual transactions? 

select count(distinct(o.product_id)) as num_distinct_products_sold
from products p
inner join order_items o on o.product_id = p.product_id;

# 32951 products have been sold

# or you can do it this way
SELECT 
	count(DISTINCT product_id) AS n_products
FROM
	order_items;
    
# ------------------------------------------------------------------------
# 7. What’s the price for the most expensive and cheapest products?
select product_id, price
from order_items
order by price asc
limit 1;

# cheapest product: '8a3254bee785a526d548a81a9bc3c9be', price: '0.85'

select product_id, price
from order_items
order by price desc
limit 1;

# most expensive product: '489ae2aa008f021502940f251d4cce7f', price: '6735'

# Or to do it in a single query
SELECT 
    MIN(price) AS cheapest, 
    MAX(price) AS most_expensive
FROM 
	order_items;

# ------------------------------------------------------------------------
# 8. What are the highest and lowest payment values? 

select payment_value
from order_payments
order by payment_value asc
limit 1;

# lowest payment: 0

select payment_value
from order_payments
order by payment_value desc
limit 1;

# higest payment: '13664.1'

# Or together
SELECT 
	MAX(payment_value) as highest,
    MIN(payment_value) as lowest
FROM
	order_payments;
