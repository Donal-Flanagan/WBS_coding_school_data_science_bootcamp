use magist;

# QUESTIONS TO BE ANSWERED
# Is Magist is a good fit for high-end tech products?
# Are orders delivered on time?

# avg price of ENIACS 663

# ------------------------------------------------------------------------
# PRODUCT QUESTIONS
# ------------------------------------------------------------------------
# What categories of tech products does Magist have?
SELECT * 
from product_category_name_translation;

# TECH CATEGORIES 
# audio, auto, cds_dvds_musicals, cine_photo, consoles_games, dvds_blu_ray,
# electronics, computers_accessories, pc_gamer, computers, tablets_printing_image, telephony fixed_telephony

Drop table tech_product_categories;

# Create a temporary table to reference the tech products
CREATE TEMPORARY TABLE IF NOT EXISTS tech_product_categories(
	SELECT *
	FROM product_category_name_translation
	WHERE product_category_name_english IN ('audio', 'cds_dvds_musicals', 'cine_photo', 'consoles_games', 'dvds_blu_ray', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony', 'fixed_telephony')
);

# Check that the table was created
select *
from tech_product_categories;

# Check that the correct products can be found when using this table as a comparison
select *
from product_category_name_translation
where product_category_name_english IN (
	SELECT product_category_name_english
	FROM tech_product_categories);

# ------------------------------------------------------------------------
# How many products of these tech categories have been sold (within the time window of the database snapshot)? 
# What percentage does that represent from the overall number of products sold?

# num tech products sold
SELECT COUNT(oi.product_id)
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IN (
	SELECT product_category_name 
    FROM tech_product_categories);

# The query also works this way
SELECT COUNT(oi.product_id)
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
INNER JOIN tech_product_categories tpc ON tpc.product_category_name = p.product_category_name;
# 17349 tech products sold

select count(product_id)
from order_items;
# 112650 products have been sold

# Tech products represent 17349/112650 = 15.4% of all products sold

# ------------------------------------------------------------------------
# What’s the average price of the products being sold?
select avg(price) as avg_price
from order_items;
# The average price of all products being sold is 120.65

# FOR PRESENTATION
select avg(price) as avg_price
from order_items
where product_id in (
	select product_id
	from products p
	inner join tech_product_categories tpc on tpc.product_category_name = p.product_category_name
);
# The average price of tech products is 110.05

# get all tech product ids, their prices and their categories
select o.product_id, o.price, tpc.product_category_name_english as product_category
from order_items o
inner join products p on p.product_id = o.product_id
inner join tech_product_categories tpc on tpc.product_category_name = p.product_category_name;

# FOR PRESENTATION
# get the average price per tech product category
select o.product_id, avg(o.price) as avg_price, tpc.product_category_name_english as product_category
from order_items o
inner join products p on p.product_id = o.product_id
inner join tech_product_categories tpc on tpc.product_category_name = p.product_category_name
group by product_category
order by avg_price desc;
# This might make a good visualization for the presentation

# ------------------------------------------------------------------------
# Are expensive tech products popular? *
# HOW DO WE DECIDE THIS? QUESTION FOR GROUP
# DEFINE POPULAR
# DEFINE EXPENSIVE

# PRESENTATION
# PLOT Y=REPETITIONS X=PRICE 

select pcnt.product_category_name_english, oi.product_id, oi.price, count(oi.product_id) as num_orders
from order_items as oi
inner join products as p on oi.product_id = p.product_id
inner join product_category_name_translation as pcnt on pcnt.product_category_name = p.product_category_name 
where pcnt.product_category_name_english in ('audio', 'cds_dvds_musicals', 'cine_photo', 'consoles_games', 'dvds_blu_ray', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony', 'fixed_telephony')
group by oi.product_id
having count(oi.product_id)> 1
order by oi.price desc;

# ------------------------------------------------------------------------
# SELLER QUESTIONS
# ------------------------------------------------------------------------
# How many sellers are there?
select count(distinct(seller_id))
from sellers;
# 3095 sellers

# ------------------------------------------------------------------------
# What’s the average monthly revenue of Magist’s sellers?

# Average monthly revenue per seller
select seller_id, round(avg(monthly_revenue), 2) as avg_monthly_revenue
from (
	SELECT YEAR(shipping_limit_date), MONTH(shipping_limit_date), seller_id, SUM(price) AS monthly_revenue  
	FROM order_items
	GROUP BY YEAR(shipping_limit_date), MONTH(shipping_limit_date), seller_id
	) mr
group by mr.seller_id
ORDER BY avg_monthly_revenue DESC;

# Average monthly revenue of tech sellers
select round(avg(amr.avg_monthly_revenue_per_seller), 2)
from (
	select seller_id, round(avg(monthly_revenue), 2) as avg_monthly_revenue_per_seller
	from (
		SELECT YEAR(oi.shipping_limit_date), MONTH(oi.shipping_limit_date), oi.seller_id, SUM(oi.price) AS monthly_revenue  
		FROM order_items oi
        INNER JOIN products p ON oi.product_id = p.product_id
        WHERE p.product_category_name IN (
			SELECT product_category_name
			FROM tech_product_categories
            )
		GROUP BY YEAR(shipping_limit_date), MONTH(shipping_limit_date), seller_id
		) mr
	group by mr.seller_id) amr;
# The average monthly revenue of sellers is 603.75

SELECT rym.seller_id, AVG(rym.revenue_ym) AS avg_revenue
FROM (
    SELECT YEAR(oi.shipping_limit_date), MONTH(oi.shipping_limit_date), oi.seller_id, SUM(oi.price) AS revenue_ym  
    FROM order_items oi
    LEFT JOIN products p ON oi.product_id = p.product_id
    WHERE p.product_category_name IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
    GROUP BY YEAR(oi.shipping_limit_date), MONTH(oi.shipping_limit_date), oi.seller_id
    ) rym
GROUP BY rym.seller_id
ORDER BY AVG(rym.revenue_ym) DESC;

# ------------------------------------------------------------------------
# What’s the average revenue of sellers that sell tech products?
select avg(mr.monthly_revenue)
from (
	select year(order_purchase_timestamp) as year_, month(order_purchase_timestamp) as month_, oi.seller_id, sum(op.payment_value) AS monthly_revenue
	from order_payments op
	inner join orders o on o.order_id = op.order_id
	inner join order_items oi on oi.order_id = o.order_id
    where oi.product_id in (
		select product_id
		from products p
		inner join tech_product_categories tpc  on tpc.product_category_name = p.product_category_name)
	group by year_, month_, oi.seller_id) mr;
# The average monthly revenue of sellers that sell tech products is 1141.32

# ------------------------------------------------------------------------
# DELIVERY TIME QUESTIONS
# ------------------------------------------------------------------------
# What’s the average time between the order being placed and the product being delivered?
SELECT avg(timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date))
from orders;
# The average time between orders being placed and delivered is 12 days.

# ------------------------------------------------------------------------
# How many orders are delivered on time vs orders delivered with a delay?
select count(*)
from orders;
# There are 99441 orders

select count(*)
from orders
where timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) > 1;
# 5710 orders were delivered a day or more late
# 5710/99441 = 5.7% of orders were late

select order_id, timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) as diff_estimation_and_delivery
from orders;

# Num orders vs difference between estimation and delivery
select count(*) as num_orders, time_diff.diff_estimation_and_delivery
from (
	select order_id, timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) as diff_estimation_and_delivery
	from orders
) time_diff
group by time_diff.diff_estimation_and_delivery;

# Num orders vs difference between purchase and delivery
select count(*) as num_orders, time_diff.diff_order_and_delivery
from (
	select order_id, timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date) as diff_order_and_delivery
	from orders
) time_diff
group by time_diff.diff_order_and_delivery;

# Num orders vs difference between purchase and delivery
select count(*) as num_orders, time_diff.diff_order_and_estimation
from (
	select order_id, timestampdiff(day, order_purchase_timestamp, order_estimated_delivery_date) as diff_order_and_estimation
	from orders
) time_diff
group by time_diff.diff_order_and_estimation;

# ------------------------------------------------------------------------
# Is there any pattern for delayed orders, e.g. big products being delayed more often?
# DEFINE BIG
# WHAT OTHER PARAMETERS COULD WE USE?

order_id, num_products, order_mass, same_city, same_state, tech, delay
# Create a temporary tablepayment_sequential
CREATE TEMPORARY TABLE IF NOT EXISTS tech_product_categories(
	SELECT *
	FROM product_category_name_translation
	WHERE product_category_name_english IN ('audio', 'cds_dvds_musicals', 'cine_photo', 'consoles_games', 'dvds_blu_ray', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony', 'fixed_telephony')
);

# ADDITIONAL QUESTIONS
# Review scores
select review_score, count(review_score)
from order_reviews
group by review_score
order by review_score;

select p.product_id, pcnt.product_category_name_english, 
p.product_weight_g/1000 as product_weight, 
(p.product_length_cm*p.product_height_cm*p.product_width_cm)/1000000 as product_dimension_m³, 
((p.product_length_cm*p.product_height_cm*p.product_width_cm)/1000000 )/(p.product_weight_g/1000) as product_mass,
datediff(o.order_estimated_delivery_date, o.order_delivered_customer_date) as delay_in_days
from products as p
inner join order_items as oi on p.product_id = oi.product_id
inner join orders as o on oi.order_id = o.order_id
inner join product_category_name_translation as pcnt on p.product_category_name = pcnt.product_category_name
order by delay_in_days;


select p.product_id, pcnt.product_category_name_english, 
p.product_weight_g/1000 as product_weight, 
(p.product_length_cm*p.product_height_cm*p.product_width_cm)/1000000 as product_dimension_m³, 
((p.product_length_cm*p.product_height_cm*p.product_width_cm)/1000000 )/(p.product_weight_g/1000) as product_mass,
avg(datediff(o.order_estimated_delivery_date, o.order_delivered_customer_date)) as avg_delay_in_days
from products as p
inner join order_items as oi on p.product_id = oi.product_id
inner join orders as o on oi.order_id = o.order_id
inner join product_category_name_translation as pcnt on p.product_category_name = pcnt.product_category_name
group by oi.product_id
order by product_mass desc;

# Only 15.4% of their products are tech - NEG
# The average price of tech products they sell is €110. Ours is €663. They don't sell tech products in our price range. - NEG
# The average monthly revenue for sellers is €603. These are small time sellers - NEG
# Net promoter score: Promoters = 57.5 % - NEG
# Only 5.7% of their deliverys are late. - POS
# The average time for deliverys is 12 days. - NEG
# There are a lot of duplicated products in their database - NEG - NEEDS TO BE AGGREGATED
# DELAYS - needs to be aggregated