/* We create a Table because pandas dataframe generate tables with the highest
datatypes which in turns consumes much memories */

CREATE TABLE df_orders (
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code int,
region varchar(20),
category varchar(20),
sub_category varchar(20),
product_id varchar(50),
quantity int,
discount_price decimal(7,2),
sale_price decimal(7,2),
profit decimal(7,2)
);


/* Find the top 10 products with the highest sales */

select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc;

/* Find the top 5 selling products across the different regions. */

with cte as(
select region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id)
select * from(
select *, row_number() over(partition by region order by sales desc) as row_no
from cte) A
where row_no <= 5

/* Find the month over month growth comparison for 2022 and 2023 sales */
with cte as (
select year(order_date) as order_year, month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date), month(order_date)
)

select order_month, sum(case when order_year= 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

/* For each category which month had highest sales*/
with cte as (

select category, format(order_date, 'yyyyMM') as order_year_month, sum(sale_price) as sales
from df_orders
group by category, format(order_date, 'yyyyMM')
)
select * from (
select *, row_number() over (partition by category order by sales desc) as rn
from cte
) a
where rn = 1






/* Which sub category had the highest growth by profit in 2023 compare to 2022 */


with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
),
cte2 as (
select sub_category, sum(case when order_year= 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category)
select top 1 *, 
(sales_2023- sales_2022)*100/sales_2022 as profit_increase
from cte2
order by profit_increase desc


