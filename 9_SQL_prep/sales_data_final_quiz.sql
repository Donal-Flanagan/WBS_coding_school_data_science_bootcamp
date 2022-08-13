-- store: the store code
-- dept: the department code
-- date: the date of the first day of the week
-- weekly_sales: profit of the week for the store and dept, in USA dollars

use sales_db;

-- Let’s consider store 20. What was the total (rounded) profit of this store?
select round(sum(Weekly_Sales))
from sales_exercise
where Store = 20;

-- What was the total profit for department 51 (store 20)?
select sum(Weekly_Sales)
from sales_exercise
where Dept = 51 and Store = 20;

-- In which week did store 20 achieve a profit record (for the whole store)? How much profit did they make?
select `Date`, Weekly_Sales
from sales_exercise
where Store = 20 and Weekly_Sales = (
	select max(Weekly_Sales)
	from sales_exercise
	where Store = 20
);

-- Which was the worst week for store 20 (for the whole store)? How much was the profit?
select `Date`, Weekly_Sales
from sales_exercise
where Store = 20 and Weekly_Sales = (
	select min(Weekly_Sales)
	from sales_exercise
	where Store = 20
);

-- What is the (rounded) average of the weekly sales for store 20 (the whole store)?
select round(avg(Weekly_Sales))
from sales_exercise
where Store = 20;

-- What are the 3 stores that have the best historical average of weekly sales?
with avg_weekly_sales_per_store as (
	select rank() over (
		order by avg_weekly_sales desc
    ) ranking, Store, avg_weekly_sales
    from (
		select avg(Weekly_Sales) as avg_weekly_sales, Store
		from sales_exercise
		group by Store
    ) as sub
)
select *
from avg_weekly_sales_per_store
where ranking <=3;

-- Which departments from store 20 were the best and the worst in terms of overall sales?
with ranked_total_weekly_sales_per_dept as (
	select rank() over (order by total_weekly_sales desc)
    ranking, Dept, total_weekly_sales
    from (
		select Dept, sum(Weekly_Sales) as total_weekly_sales
		from sales_exercise
		where Store = 20
		group by Dept
    ) sub
)
select Dept, total_weekly_sales
from ranked_total_weekly_sales_per_dept
where ranking = (
	select max(ranking)
    from ranked_total_weekly_sales_per_dept
) or ranking = (
	select min(ranking)
    from ranked_total_weekly_sales_per_dept
);

-- How much profit does the average department make in store 20?
with total_weekly_sales_per_dept as (
	select Dept, sum(Weekly_Sales) as total_weekly_sales
	from sales_exercise
	where Store = 20
	group by Dept
)
select round(avg(total_weekly_sales)) as avg_weekly_sales_per_dept
from total_weekly_sales_per_dept;


-- Consider store 20. Calculate the difference between the total profit 
-- of each department and the total profit of the average department. 
-- This will be the departments’ “performance metric”. 
-- Which department is the worst performer and what’s its performance?
with total_weekly_sales_per_dept as (
	select Dept, sum(Weekly_Sales) as total_weekly_sales
	from sales_exercise
	where Store = 20
	group by Dept
)
select Dept, round(total_weekly_sales - (
	select avg(total_weekly_sales) as avg_weekly_sales_per_dept
	from total_weekly_sales_per_dept
)) as diff_to_avg
from total_weekly_sales_per_dept
order by diff_to_avg;

-- Which department-store combination is the overall best performer (and what’s its performance?)? 
-- Consider the performance metric from the previous question, that is, the difference between a 
-- department’s sales and the sales of the average department of the corresponding store.
with total_sales as (
	select Dept, Store, sum(Weekly_Sales) as total_weekly_sales
	from sales_exercise
	group by Store, Dept
),
avg_sales as (
	select Store, avg(total_weekly_sales) as avg_weekly_sales
	from total_sales
    group by Store
)
select Dept, Store, round(total_weekly_sales - avg_weekly_sales) as diff_to_avg
from (
	select total_sales.Dept, total_sales.Store, total_sales.total_weekly_sales, avg_sales.avg_weekly_sales
	from total_sales
	join avg_sales
	on total_sales.Store = avg_sales.Store
) sub
order by diff_to_avg desc
limit 10;