use magist;

-- Expand the database

alter table brazilian_states rename column State to State_name;
alter table brazilian_states rename column UF to State;
-- Set the primary key
ALTER TABLE brazilian_states MODIFY State VARCHAR(2) NOT NULL UNIQUE PRIMARY KEY;

-- Link to foreign key
ALTER TABLE geo MODIFY state VARCHAR(2);
ALTER TABLE geo ADD FOREIGN KEY (state) REFERENCES brazilian_states(State);

-- I named the columns badly. Renaming 'state' now so the Primary and Foreign key names are the same.
alter table brazilian_states rename column State to state;
-- Renaming 'state_name' for consistency
alter table brazilian_states rename column State_name to state_name;

-- Analyze customer reviews

-- Find the average review score by state of the customer.
select 
	state_name,
	avg(review_score) as avg_customer_review
from 
	customers c
	join orders o using (customer_id)
	join order_reviews ors using (order_id)
	join geo g on g.zip_code_prefix = c.customer_zip_code_prefix
	join brazilian_states b using (state)
group by g.state;

/*
'Acre', '4.1013'
'Alagoas', '3.7567'
'Amazonas', '4.1429'
'Amapá', '4.1765'
'Bahia', '3.8366'
'Ceará', '3.8518'
'Distrito Federal', '4.0657'
'Espírito Santo', '4.0040'
'Goiás', '4.0276'
'Maranhão', '3.7238'
'Minas Gerais', '4.1264'
'Mato Grosso do Sul', '4.0962'
'Mato Grosso', '4.0929'
'Pará', '3.8361'
'Paraíba', '3.9962'
'Pernambuco', '3.9909'
'Piauí', '3.8939'
'Paraná', '4.1772'
'Rio de Janeiro', '3.8645'
'Rio Grande do Norte', '4.0686'
'Rondônia', '4.0675'
'Roraima', '3.6087'
'Rio Grande do Sul', '4.1328'
'Santa Catarina', '4.0638'
'Sergipe', '3.7849'
'São Paulo', '4.1639'
'Tocantins', '4.1159'
*/

-- Do reviews containing positive words have a better score? Some Portuguese positive words are: “bom”, “otimo”, “gostei”, “recomendo” and “excelente”.

-- Below is the stored function I used to accomplish this task
/*
USE `magist`;
DROP function IF EXISTS `check_for_positive_words`;

USE `magist`;
DROP function IF EXISTS `magist`.`check_for_positive_words`;
;

DELIMITER $$
USE `magist`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `check_for_positive_words`(
	review_comment_message TEXT
) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
	DECLARE contains_positive_word BOOL;
    
    IF review_comment_message REGEXP 'bom|otimo|gostei|recomendo|excelente' THEN
		SET contains_positive_word = TRUE;
	ELSEIF NOT review_comment_message REGEXP 'bom|otimo|gostei|recomendo|excelente' THEN
		SET contains_positive_word = FALSE;
    END IF;
		RETURN contains_positive_word;
END$$

DELIMITER ;
;
*/

select avg(review_score) as avg_customer_review
from order_reviews
where check_for_positive_words(review_comment_message) = TRUE;
-- avg_customer_review = '4.4560'

select avg(review_score) as avg_customer_review
from order_reviews
where check_for_positive_words(review_comment_message) = FALSE;
-- avg_customer_review = '3.3261'

-- ANSWER: Reviews containing positive words are better.

-- Considering only states having at least 30 reviews containing these words, what is the state with the highest score?

-- I am assuming here that highest score means the average customer review across all reviews, not just those containing positive words.
-- I am stating this because I found the wording of the question ambiguous and could not determine whether I was supposed to use the 
-- positive words to filter out states or also filter out reviews without positive words.
with pos_word_reviews_per_state as (
	select 
		g.state, 
		count(ors.review_id) as count_reviews_with_pos_words
	from 
		order_reviews ors
		join orders o using (order_id)
		join customers c using (customer_id)
		join geo g on g.zip_code_prefix= c.customer_zip_code_prefix
	where check_for_positive_words(review_comment_message) = TRUE
	group by state
)
select 
	state_name,
	avg(review_score) as avg_customer_review
from 
	customers c
	join orders o using (customer_id)
	join order_reviews ors using (order_id)
	join geo g on g.zip_code_prefix = c.customer_zip_code_prefix
	join brazilian_states b using (state)
where g.state in (
	select state
	from pos_word_reviews_per_state as pwrs
	where pwrs.count_reviews_with_pos_words > 30
)
group by g.state;
/*
'Alagoas', '3.7567'
'Bahia', '3.8366'
'Ceará', '3.8518'
'Distrito Federal', '4.0657'
'Espírito Santo', '4.0040'
'Goiás', '4.0276'
'Maranhão', '3.7238'
'Minas Gerais', '4.1264'
'Mato Grosso do Sul', '4.0962'
'Mato Grosso', '4.0929'
'Pará', '3.8361'
'Paraíba', '3.9962'
'Pernambuco', '3.9909'
'Piauí', '3.8939'
'Paraná', '4.1772'
'Rio de Janeiro', '3.8645'
'Rio Grande do Norte', '4.0686'
'Rondônia', '4.0675'
'Rio Grande do Sul', '4.1328'
'Santa Catarina', '4.0638'
'Sergipe', '3.7849'
'São Paulo', '4.1639'
'Tocantins', '4.1159'
*/

-- What is the state where there is a greater score change between all reviews and reviews containing positive words?
with avg_review_score as (
	select 
		state_name,
		avg(review_score) as avg_customer_review
	from 
		customers c
		join orders o using (customer_id)
		join order_reviews ors using (order_id)
		join geo g on g.zip_code_prefix = c.customer_zip_code_prefix
		join brazilian_states b using (state)
	group by g.state
),
avg_review_score_pos_words as (
	select 
		state_name, 
		avg(review_score) as avg_customer_review_pos
	from 
		customers c
		join orders o using (customer_id)
		join order_reviews ors using (order_id)
		join geo g on g.zip_code_prefix = c.customer_zip_code_prefix
		join brazilian_states b using (state)
	where check_for_positive_words(review_comment_message) = TRUE
	group by state
)
select 
	state_name, 
	abs(avg_customer_review_pos-avg_customer_review) as difference
from 
	avg_review_score ars
    join avg_review_score_pos_words arspw using (state_name)
order by difference desc
limit 1;
-- 'Roraima', '1.0580'


-- Automatize a KPI
-- Create a stored procedure that gets as input:

-- The name of a state (the full name from the table you imported).
-- The name of a product category (in English).
-- A year
-- And outputs the average score for reviews left by customers from the given state for orders with the 
-- status “delivered, containing at least a product in the given category, and placed on the given year.

/*
USE `magist`;
DROP procedure IF EXISTS `get_avg_review_score`;

USE `magist`;
DROP procedure IF EXISTS `magist`.`get_avg_review_score`;
;

DELIMITER $$
USE `magist`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_avg_review_score`(
	IN order_state text,
	IN category_name text,
    IN order_year int,
    OUT avg_review_score int
)
BEGIN
	select 
		avg(review_score) as avg_customer_review
	from 
		orders o 
		join customers c using (customer_id)
		join order_reviews ors using (order_id)
		join geo g on g.zip_code_prefix = c.customer_zip_code_prefix
		join brazilian_states b using (state)
	where order_id in (
		select order_id 
		from order_items oi
		join products p using (product_id)
		join product_category_name_translation using (product_category_name)
		where product_category_name_english = category_name
	)
	and b.state_name = order_state and o.order_status = 'delivered' and o.order_purchase_timestamp like concat(convert(order_year, char), '%');
END$$

DELIMITER ;
;
*/
call get_avg_review_score('Roraima', 'health_beauty', 2017, @avg_review_score);
-- avg_review_score = 2
