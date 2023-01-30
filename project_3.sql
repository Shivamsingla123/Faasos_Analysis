CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'2021-01-01'),
(2,'2021-01-03'),
(3,'2021-01-08'),
(4,'2021-01-15');

drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'2021-01-01 18:15:34','20km','32 minutes',''),
(2,1,'2021-01-01 19:10:54','20km','27 minutes',''),
(3,1,'2021-01-03 00:12:37','13.4km','20 mins','NaN'),
(4,2,'2021-01-04 13:53:03','23.4','40','NaN'),
(5,3,'2021-01-08 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'2021-01-08 21:30:45','25km','25mins',null),
(8,2,'2021-01-10 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'2021-01-11 18:50:20','10km','10minutes',null);

drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','2021-01-01  18:05:02'),
(2,101,1,'','','2021-01-01 19:00:52'),
(3,102,1,'','','2021-01-02 23:51:23'),
(3,102,2,'','NaN','2021-01-02 23:51:23'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,2,'4','','2021-01-04 13:23:46'),
(5,104,1,null,'1','2021-01-08 21:00:29'),
(6,101,2,null,null,'2021-01-08 21:03:13'),
(7,105,2,null,'1','2021-01-08 21:20:29'),
(8,102,1,null,null,'2021-01-09 23:54:33'),
(9,103,1,'4','1,5','2021-01-10 11:22:59'),
(10,104,1,null,null,'2021-01-11 18:34:49'),
(10,104,1,'2,6','1,4','2021-01-11 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

---------------------------------------------------------------------------------------------------------------------------------------------------
-- How many total orders received and give the result according to items?

select roll_id,count(roll_id) as total_orders
from customer_orders
group by roll_id

--InSights-- As roll_id 1 is Non-Veg Where as roll_id 2 is Veg So Total Non-Veg Rolls ordered are 10 where as Total Veg Roll Orders were 4

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--How many unique customers orders were made?
select count(distinct customer_id) as total_unique_customers from customer_orders

--InSights-- Total 5 customers who ordered the roll rest of are the repeat orders

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--How many successful orders were delivered by each driver?
select driver_id,count(order_id) as orders_delivered from
(select *,case 
when  cancellation is NULL then 'Delivered'
when cancellation ='Nan' then 'Delivered' 
when cancellation ='' then 'Delivered'
else cancellation 
end as Status
from driver_order) as a
where status='Delivered'
group by a.driver_id

--Insights--As the table was not clean so we cleaned the table by adding DELIVERED word 
--in the column where the values were like NULL,Nan and space('')

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
 
--How many each type of rolls were delivered?
select roll_id,count(roll_id) total_delivered from(select customer_orders.order_id as orders_id,roll_id,case 
when  cancellation is NULL then 'Delivered'
when cancellation ='Nan' then 'Delivered' 
when cancellation ='' then 'Delivered'
else cancellation 
end as Status
from customer_orders  join driver_order
on customer_orders.order_id = driver_order.order_id)a
where status='Delivered'
group by roll_id

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--How many veg and non-veg rolls were ordered and successfully delivered by each customer?
select customer_id,roll_name,total_delivered
from
(select customer_id,roll_id,count(roll_id) total_delivered from(select customer_orders.order_id as orders_id,customer_id,roll_id,case 
when  cancellation is NULL then 'Delivered'
when cancellation ='Nan' then 'Delivered' 
when cancellation ='' then 'Delivered'
else cancellation 
end as Status
from customer_orders  join driver_order
on customer_orders.order_id = driver_order.order_id)a
where status='Delivered'
group by roll_id,customer_id) as a 
join rolls as b
on a.roll_id = b.roll_id
order by customer_id

--Insights-- It is very clear to say that Customers preferred Non-Veg role over Veg role

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--Find how many customers ordered the same item and customers ordered the different items?
with cte as(
select customer_id,roll_id,dense_rank() over(partition by customer_id order by roll_id) as rnnk
from
(select customer_id,roll_id,case 
when  cancellation is NULL then 'Delivered'
when cancellation ='Nan' then 'Delivered' 
when cancellation ='' then 'Delivered'
else cancellation 
end as Status
from customer_orders  join driver_order
on customer_orders.order_id = driver_order.order_id) as a
group by customer_id,roll_id)
 
select customer_id,case when max(rnnk)>=2 then 'Multiple order' else 'Single_order' end as count_order
from cte
group by customer_id

-- Insights-- Here I am finding the customers ID who orders the same roll all time and vice-Versa

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--For each customer,how many delivered rolls  had atleast 1 change and how many had no changes?
with temp_customer_orders as(
select order_id,customer_id,roll_id,order_date,
case
when not_include_items is null or not_include_items in('','Nan') then '0' else not_include_items end as New_not_include_items,
case
when extra_items_included is null or extra_items_included in('Nan','') then '0' else  extra_items_included end as New_extra_items_included
from customer_orders
)
select distinct customer_id,case when new_not_include_items='0' and New_extra_items_included='0' then 'No change' else 'change' end as status
from temp_customer_orders 
order by status
 
--Insights-- Here we use the concept of case statement and with clause with that we clean and organise the data and
--get the output of those customers who did some changes in their order and who didn't do

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

-- How many rolls were delivered that had both exclusion and extras?
with temp_customer_orders as(
select order_id,customer_id,roll_id,
case
when not_include_items is null or not_include_items in('','Nan') then '0' else not_include_items end as New_not_include_items,
case
when extra_items_included is null or extra_items_included in('Nan','') then '0' else  extra_items_included end as New_extra_items_included
from customer_orders
)
select order_id from temp_customer_orders 
where New_not_include_items>'0'
and New_extra_items_included>'0'

--Insights-- We are finding here the Order ID in which some extra ingredients added and some ingredients removed.
--With the help of this it is easy for the outlet to calculate the amount according to Order ID

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--What was the total number of rolls ordered for each hour of the day?
select Date,Hour_interval,count(order_id) No_of_order_received from
(select order_id,roll_id,cast(order_date as date) date,concat(datepart(hour,order_date) ,'-', datepart(hour,order_date)+1) as Hour_interval 
from customer_orders) as z
group by date,hour_interval
order by No_of_order_received desc

--Insights-- We are finding here the Peak timing of each day at what time Maximum orders were received.

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--What was the total number of orders received for each day of the week?
select Day,count(order_id) No_of_orders from
(select order_id,datename(Dw,order_date) Day from customer_orders) as z
group by day

--Insights-- Through this we can find the Day name on which maximum orders received. 
--This is the best way for a business to analyse the maximum sale day

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--What was the average time in minutes it took for each driver to arrive at the FASOOS HQ to pickup the order?
select driver_id,avg(time_diff)
from
(select driver_id,a.order_id,datediff(minute,order_date,pickup_time) as time_diff
,row_number() over(partition by a.order_id order by datediff(minute,order_date,pickup_time)) as r_num
from customer_orders as a inner join driver_order as b
on a.order_id = b.order_id
where b.pickup_time is not null) as z
where r_num=1
group by driver_id

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--Is there any relationship between the no.of rolls and how long the order takes to prepare?

with cte as(
select order_id,count(roll_id) as Total_order,sum(Actual_time)/count(roll_id) as Actual_time from
(select c.order_id,roll_id,datediff(minute,order_date,pickup_time) Actual_time
from customer_orders as c join driver_order as d
on c.order_id=d.order_id
where pickup_time is not null) as a
group by order_id
)
select *, (10*total_order) as Ideal_time
from cte

--Insights-- As we can see that to prepare 1 roll the ideal time is 10 min but as we can see that for order ID 8 chef takes 21 Minutes
--this is because of the customization of the roll as per customer requirements 

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--What was the average distance travelled for each customer by the driver?
select customer_id,avg(new_d) as for_each_customer from
(select a.customer_id,a.order_id,b.driver_id,a.roll_id,cast(trim(replace(lower(b.distance),'km','')) as decimal(4,2))as new_d ,DATEDIFF(minute,a.order_date,b.pickup_time) as diff,b.distance
from customer_orders as a join driver_order as b on a.order_id=b.order_id
where b.pickup_time is not null)h
group by customer_id

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--What was the difference between the longest and shortest delivery times for all orders?
select (max(new_duration)-min(new_duration))as diff from
(select cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration end as integer) as New_Duration 
 from driver_order
where duration is not null)as z

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--What was the average speed for each driver for each delivery and do you notice any trend for these values?
select driver_id,order_id,(1.00*sum(vip)/sum(l_duration)) as avg_Speed from
(select driver_id,order_id,cast(trim(replace(lower(distance),'km','')) as decimal(4,2)) as vip,cast(case when duration like '%min%' then left(duration,CHARINDEX('m',duration)-1) else duration end as integer) as l_duration 
from driver_order
where duration is not null) as z
group by driver_id,order_id
order by driver_id

----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------
----------------------------------------------------$$$$$$$$$$$$$$$$--------------------------------------------------------------------------

--What is the successful delivery percentage for each driver?
select driver_id,s*1.0/t cancelled_percentage from 
(select driver_id,sum(can_per)s,count(driver_id)t from
(select driver_id,case when lower(cancellation) like '%cancel%' then 0 else 1 end as can_per from  driver_order)a
group by driver_id)b;

--Insights-- Through this query we can get the driverID whose cancellation percentage is low
--and if we can reward the Driver to motivate him to stay in the company 
 
  



--------------------------------------------------------------PROECT-ENDED------------------------------------------------------------------------------------------

















-------------------------------------------------
