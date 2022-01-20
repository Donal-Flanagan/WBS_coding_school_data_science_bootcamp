-- Very simple example of a procedure
DROP PROCEDURE procedure_name;
DELIMITER $$
CREATE PROCEDURE procedure_name ()
BEGIN 
SELECT *
FROM orders;
END$$
DELIMITER ;

-- test simple procedure
CALL procedure_name;

-- Example of Procedure with an input
DROP PROCEDURE products_sold_per_category_for_a_year;
DELIMITER $$
CREATE PROCEDURE products_sold_per_category_for_a_year(
	IN `year` INT
)
BEGIN
SELECT 
    p.product_category_name, COUNT(p.product_category_name)
FROM
    products p
        JOIN
    order_items oi USING (product_id)
        JOIN
    orders o USING (order_id)
WHERE
    YEAR(o.order_purchase_timestamp) = `year`
GROUP BY p.product_category_name
ORDER BY COUNT(p.product_category_name) DESC;
END $$
DELIMITER ;

-- test previous procedure with an input --> 2018 is the input we are giving
CALL products_sold_per_category_for_a_year(2018);

-- Example of a procedure with Case Statement (can also use if/else, while, loop, repeat, leave)
DROP PROCEDURE delivered_late_count;
DELIMITER $$
CREATE PROCEDURE delivered_late_count()
BEGIN
SELECT 
    COUNT(*),
    CASE
        WHEN
            DATEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date) < 0
        THEN
            'OnTime'
        ELSE 'Late'
    END shipment
FROM
    orders
GROUP BY shipment;
END$$
DELIMITER ;

-- test procedure
CALL delivered_late_count;

-- Example of a function converting Brazilian Reals to Euros
DROP FUNCTION reals_to_euros;
DELIMITER $$
CREATE FUNCTION reals_to_euros(
     price FLOAT
)
RETURNS FLOAT
DETERMINISTIC
BEGIN
RETURN price*0.16;
END$$
DELIMITER ;

-- test function
SELECT product_id, 
price as price_in_reals, 
reals_to_euros(price) as price_in_euros
FROM order_items;
