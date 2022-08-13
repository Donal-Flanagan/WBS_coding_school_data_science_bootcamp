use magist;

-- Select all orders in order_items with a shipping_limit_date before midnight 2016-10-09, and add a 
-- column called total_order_price with a sum of the price of all products belonging to the same order.
select order_id, shipping_limit_date, sum(price) over (partition by order_id) as total_order_price
from order_items
where shipping_limit_date < '2016-10-09 00:00:00'
order by shipping_limit_date;

-- Now let’s go for a challenge that also involves getting information from other tables. 
-- Select purchased items from order_items that meet these conditions:

-- Their order_purchase_timestamp date is 2016-10-09
-- Their order_status is “delivered”
-- Add a column called total_order_payment with the sum of the payment_value for that order.
-- Add a column called avg_category_payment with the average of the payment value for the items belonging to the same category.
select 
	order_id, 
	order_purchase_timestamp, 
	product_category_name_english, 
	sum(payment_value) over (partition by order_id) as total_order_payment,
    avg(payment_value) over (partition by product_category_name) as avg_category_payment
from 
	order_items oi
	join orders o using (order_id)
	join order_payments op using (order_id)
	join products p using(product_id)
	join product_category_name_translation pcnt using (product_category_name)
where order_status = 'delivered' and order_purchase_timestamp like '2016-10-09%'
order by order_purchase_timestamp;




