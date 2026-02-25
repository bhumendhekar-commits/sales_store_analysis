create table sales_stores(
transaction_id varchar(15),
customer_id varchar(15),
customer_name varchar(30),
customer_age int,
gender varchar(15),
product_id varchar(15),
product_name varchar(15),
product_category varchar(15),
quantiy int,
prce float,
payment_mode varchar(15),
purchase_date date,
time_of_purchase time,
status varchar(15)
);
select * from sales_stores
set dateformat dmy
bulk insert sales_stores
from 'C:\Users\hp\Downloads\sales stores\sales_store_updated_allign_with_video.csv'
	with(
	firstrow=2,
	fieldterminator=',',
	rowterminator='\n'
	);

	SELECT * INTO sales FROM sales_stores;
    SELECT * FROM sales;
	--Data cleaning

	--step 1: To check duplicate

	Select transaction_id,count(*)
	from sales
	group by transaction_id
	having count(transaction_id)>1

	WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS rn
    FROM sales
)
DELETE FROM cte
WHERE rn > 1;

--step 2:- correction of headers
exec sp_rename'sales.quantiy','quantity','column'
exec sp_rename'sales.prce','price','column'

--step 3:- To check Datatype

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';


--step :- To check null count
DECLARE @table_name NVARCHAR(128) = 'sales';  -- your table name
DECLARE @sql NVARCHAR(MAX) = '';

-- Build dynamic SQL to count NULLs for each column
SELECT @sql = @sql + 
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, COUNT(*) AS NullCount ' +
    'FROM ' + @table_name + ' WHERE [' + COLUMN_NAME + '] IS NULL ' +
    'UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name;

-- Remove last UNION ALL
SET @sql = LEFT(@sql, LEN(@sql) - 10);

-- Execute the dynamic SQL
EXEC sp_executesql @sql;

--treating null values

select * from sales
where transaction_id is null
or
customer_id is null
or
customer_name is null
or
customer_age is null
or 
gender is null
or
product_id is null
or
product_name is null
or
product_category is null
or
quantity is null
or
price is null
or 
payment_mode is null
or
purchase_date is null
or
time_of_purchase is null
or
status is null

delete from sales
where transaction_id is null

select * from sales
where customer_name ='ehsaan ram'

update sales
set customer_id='CUST9494'
where transaction_id='TXN977900'

select * from sales
where customer_name ='damini raju'

update sales
set customer_id='CUST1401'
where transaction_id='TXN985663'

select * from sales
where customer_id ='CUST1003'

update sales
set customer_name='Mahika Saini',customer_age=35, gender='male'
where transaction_id='TXN432798'
update sales
set gender ='F'
where gender ='Female'

update sales
set gender ='M'
where gender ='Male'

select * from sales

select distinct gender
from sales

select distinct payment_mode
from sales

update sales
set payment_mode ='Credit Card'
where payment_mode ='cc'


--Data Analysis--
--1. what are the top 5 most selling products by quantity?

select top 5 product_name, sum(quantity) as total_quantity_sold
from sales
where status='delivered'
group by product_name
order  by total_quantity_sold desc

--Buisness Problem : We dont know which product are most in demand

--Buisness Impact: Helps Prioritize stock and boost sales through targated promotions.

----------------------------------------------------------------------------------------------------------------------------


--2. Which product are most Frequently canceled?

select top 5 product_name, count(*) as total_canceled
from sales
where status= 'cancelled'
group by product_name
order by total_canceled desc

--Buisiness Problem: Frequently cancellations affect revenue and customer trust.

--Buisiness Impact :Identify poor-performance products to improve quality or remove from catalog.

---------------------------------------------------------------------------------------------------------


--3. What time of the day has the highest number of purchase?
select * from sales

select 
		case 
			when datepart(hour,time_of_purchase) between  0 and 5 then 'night'
			when datepart(hour,time_of_purchase) between  6 and 11 then 'Morning'
			when datepart(hour,time_of_purchase) between  12 and 17 then 'Afternoon'
			when datepart(hour,time_of_purchase) between  18 and 23 then 'Evening'
		End as time_of_day,
		count(*) as total_order
		from sales
		group by case 
			when datepart(hour,time_of_purchase) between  0 and 5 then 'night'
			when datepart(hour,time_of_purchase) between  6 and 11 then 'Morning'
			when datepart(hour,time_of_purchase) between  12 and 17 then 'Afternoon'
			when datepart(hour,time_of_purchase) between  18 and 23 then 'Evening'
		End
		order by total_order desc

--Buisiness Problem Solves:- find peak sales times.

-- Buisiness Impact: optimize staffing, promotions and server loads.


--4. Who are the top 5 highest spending customers?

select * from sales

select top 5 customer_name, 
       format(sum(price*quantity),'C0','en-IN') as total_spend
from sales
group by customer_name
order by sum(price*quantity) desc;

--Buisiness Prolem Solved :Identify VIP customers.

--Buisiness Impact: Personalized offers,loyalty rewards and retention.


--5. Which product categories genreate the highest revenue?

select * from sales
select product_category,
       format(sum(price*quantity),'C0','en-IN') as revenue
from sales
group by product_category
order by sum(price*quantity) desc

--Buisiness problem solved: Identity top-performance product categories.

--Buisiness Impact: Refine product strategy, supply chain, and promotion.
--allowing the buisiness to invest more in high-margin or high-demand categories.

--------------------------------------------------------------------------------------------------------------------------------------------

--6.what is the return/cancellation rate per product category?


select * from sales
 --cancellation

 select product_category,
	count(case when status='cancelled' then 1 end) *100.0/count(*) as cancelled_percent
	from sales
	group by product_category
	order by cancelled_percent desc

--Return
 select product_category,
	count(case when status='returned' then 1 end) *100.0/count(*) as returned_percent
	from sales
	group by product_category
	order by returned_percent desc

--Buisiness Peoblem solved :Monitor dissatisfaction rends per categories.

--Buisiness Impact:Reduce returns , improve product description/expections
--helps identify and fix product or logistics issues.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--7. what is the most preferred payment mode?
select * from sales

select payment_mode, count(payment_mode) as total_count
 from sales
 group by payment_mode
 order by total_count desc

 --Buisiness Problem solved:- know which payment options customers prefer.

 --Buisiness Impact:- streamline payment processing,prioritize popular modes.


 ----------------------------------------------------------------------------------------------------------------------

 --8.How does the age group affect purchasing behaviour?

 select * from sales
 SELECT
    CASE 
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS age_group,
    
    SUM(price * quantity) AS total_purchase

FROM sales

GROUP BY 
    CASE 
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END

ORDER BY total_purchase DESC;

--Buisiness problem solved: understand customer demographics.

--Buisiness Impact: Targeted marketing and product recommendation by age group


----------------------------------------------------------------------------------------------------------------------

--9. What is the monthly sales trend?

select *from sales


select 
format(purchase_date,'yyyy-MM') as month_year,
sum(price*quantity) as total_sales,
sum(quantity)as total_quantity
from sales
group by format(purchase_date,'yyyy-MM')

--Buisiness problem: sales sluctuations go unnoticed.

--Buisiness Impact: plan iventory and marketing accordngly to seasonal trends.



----------------------------------------------------------------------------------------------------------------------

--10.Are certain genders buying more specific product categories?

select* from sales

select gender, product_category,count(product_category) as total_purchase
from sales
group by  gender,product_category
order by gender desc

--Buisiness problem solved: gender-based product preference.

--Buisiness Impact: Personalized ads, gender-focused compaign.


--------------------------------------------------------------------------------------------------------------------------------------


