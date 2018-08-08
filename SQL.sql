------------------BASIC FUNCITON --------------
CREATE TABLE emp_data (
	name text not null,
	age integer primary key,
	designation text,
	salary integer DEFAULT 1
);

DROP TABLE IF EXISTS emp_data;

INSERT INTO book (book_id, name, price, date_of_publication) 
VALUES ('HTML01', 'HTML Unleashed', 19.00, '08-07-2010'), 
	    ('JS01', null , 22.00, '01-05-2010');

INSERT INTO id_pid (id, pid)
SELECT id, null as pid 
FROM id_pid_view a
WHERE NOT EXISTS (SELECT id FROM id_pid b WHERE a.id=b.id);

SELECT last_updated_dt INTO ail_update_date FROM table_a;

UPDATE book SET price = 19.49 WHERE price = 25.00;
UPDATE TABLE_A A
SET A.OLD = B.NEW
FROM TABLE_B B
WHERE XXXXXXXXXX;

DELETE FROM book WHERE price < 25.00 
DELETE FROM book;

ALTER TABLE orders ADD COLUMN vendor_name varchar(25);
ALTER TABLE orders DROP COLUMN vendor_name;
ALTER TABLE orders ALTER COLUMN cus_name TYPE varchar(25);
ALTER TABLE orders RENAME COLUMN city TO vendor_city;
ALTER TABLE orders ALTER COLUMN city SET NOT NULL;
ALTER TABLE orders ALTER COLUMN city DROP NOT NULL;
ALTER TABLE orders ADD CONSTRAINT item_vendor_ukey UNIQUE (item_code,vendor_code);

-- If we want to fetch unique designame from the employee table
SELECT DISTINCT designame FROM employee;
-- DISTINCT ON CGMID AND PHONETYPEID
SELECT DISTINCT ON (cgmid, phonetypeid) cgmid, phonetypeid, unformattedphone FROM employee;

-- The NULL value sorts higher than the other value. 
-- When sort order is ascending the NULL value comes at the end 
-- and in the case of descending sort order, it comes at the beginning.
SELECT deptno, AVG(salary)
FROM employee
WHERE designame <>'PRESIDENT'
GROUP BY deptno
HAVING COUNT(*)>3
ORDER BY deptno DESC;



------------------JOIN --------------
INNER JOIN

RIGHT JOIN
LEFT JOIN
FULL JOIN

CROSS JOIN
SELF JOIN

--drop table if exists joins_test;
--create table joins_test  (id_1 int, id_2 int);
--insert into joins_test values (1,10),(1,11),(1,10),(2,10),(2,11);
--select * from joins_test;

-- TEST 0 => 25 = 5*5
--select * from joins_test a, joins_test b;

-- TEST 1 => dups = 13 = 3*3+2*2
-- select * from joins_test a
-- inner join joins_test b
-- on a.id_1 = b.id_1;

-- TEST 2 => dups
-- select * from joins_test a
-- right join (select * from joins_test where id_1 = 1) b
-- on a.id_1 = b.id_1;

-- TEST 3 => if you want to dup then don't merge it with dups
-- select * from joins_test a
-- left join (select distinct(id_1) from joins_test) b
-- on a.id_1 = b.id_1;

------------------WINDOW FUNCTION --------------
-- use of a window function does not cause rows to become grouped into a single output row 
-- the rows retain their separate identities.
ROW_NUMBER() -- NO HOLE AND NO TIE
RANK()       -- HOLE AND TIE [F]
AVG(xxx)
SUM(xxx)

--DROP TABLE IF EXISTS test_case_for_rank;
--CREATE TABLE test_case_for_rank (group_id text, user_id int, score integer);
--INSERT INTO test_case_for_rank VALUES ('a',1,100),('a',2,200),('a',3,200),('a',4,50),('b',5,500),('b',6,500);

-- ROW_NUMBER
SELECT *, ROW_NUMBER() OVER (ORDER BY score DESC) as row_num FROM test_case_for_rank;
SELECT *, ROW_NUMBER() OVER (ORDER BY group_id, score DESC) as row_num FROM test_case_for_rank;

-- RANK
SELECT *, RANK() OVER (ORDER BY score DESC) as all_rank FROM test_case_for_rank;

-- AVG
SELECT *, avg(score) over() AS all_avg from test_case_for_rank;
SELECT *, avg(score) over(PARTITION BY group_id) AS reg_avg from test_case_for_rank;
SELECT *, avg(score) over(PARTITION BY group_id ORDER BY score DESC) AS reg_avg from test_case_for_rank; -- incremental

-- SUM
SELECT *, SUM(score) over() AS all_sum from test_case_for_rank;
SELECT *, SUM(score) over(PARTITION BY group_id) AS reg_sum from test_case_for_rank;
SELECT *, SUM(score) over(PARTITION BY group_id ORDER BY score DESC) AS reg_sum from test_case_for_rank; -- incremental
-- SAME AS: 
SELECT *, (SELECT SUM(b.score) FROM test_case_for_rank b WHERE a.group_id = b.group_id AND b.score >= a.score) 
FROM test_case_for_rank a ORDER BY a.group_id, a.score DESC;

-- HOLE & TIE
   -- [F]
   SELECT group_id, score, RANK() OVER(PARTITION BY group_id ORDER BY score DESC) AS order 
   FROM test_case_for_rank
   ORDER BY group_id, score DESC;

   SELECT a.group_id, a.score, (SELECT COUNT(b.score) FROM test_case_for_rank b WHERE a.group_id = b.group_id AND b.score > a.score)+1 AS order
   FROM test_case_for_rank a
   ORDER BY a.group_id, a.score DESC;

   -- [B] 
   SELECT a.group_id, a.score, (SELECT COUNT(b.score) FROM test_case_for_rank b WHERE a.group_id = b.group_id AND b.score >= a.score) AS order
   FROM test_case_for_rank a
   ORDER BY a.group_id, a.score DESC;

-- NO HOLE
   -- TIE
   SELECT a.group_id, a.score, (SELECT COUNT(DISTINCT(b.score)) FROM test_case_for_rank b WHERE a.group_id = b.group_id AND b.score > a.score)+1 as order
   FROM test_case_for_rank a
   ORDER BY a.group_id, a.score DESC;

   -- NO TIE
   SELECT group_id, score, ROW_NUMBER() OVER(PARTITION BY group_id ORDER BY score DESC) as order
   FROM test_case_for_rank
   ORDER BY group_id, score DESC;

-- FIRST AND LAST
SELECT a.region_id, a.rest_id
FROM location a
where (SELECT count(distinct(b.rest_id)) FROM location b where a.region_id = b.region_id and b.rest_id > a.rest_id)+1 = 1 OR
      (SELECT count(distinct(b.rest_id)) FROM location b where a.region_id = b.region_id and b.rest_id < a.rest_id)+1 = 1;

-- 5th IF NO HOLE
SELECT * FROM location where (SELECT count(distinct(b.rest_id)) FROM location b where b.rest_id > a.rest_id)+1 = 5;





-----------USEFUL FUNCTIONS ----------
substring(mkey1 from char_length(mkey1) - 4)
substring(phone_home::text from 1 for 3)::int
-- The COALESCE function returns the first of its arguments that is not null
coalesce(max(date_updated),'1990-01-01')
string_agg(zip, ', ')
-- SELECT group_id, string_agg(user_id::TEXT, ',') FROM test_case_for_rank GROUP BY group_id;
SELECT DATE_PART('year', '2012-01-01'::date),EXTRACT(year FROM CURRENT_DATE);





-----------DATE FUNCTIONS ----------
-- FIRST DAY [MONDAY/1st]
-- '2018-08-01 00:00:00-05'
select date_trunc('month', CURRENT_DATE);

-- LAST DAY
-- '2018-08-31 00:00:00-05'
select date_trunc('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day';

-- FIRST DAY PREVIOUS MONTH
-- '2018-07-01 00:00:00-05'
select date_trunc('month', CURRENT_DATE) - INTERVAL '1 month';

-- LAST DAY PREVIOUS MONTH
-- '2018-07-31 00:00:00-05'
select date_trunc('month', CURRENT_DATE) - INTERVAL '1 day';





-----------WITH STATMENT ----------

with a as (select * from location)
select * from region
inner join a
on a.region_id = region.region_id;

WITH regional_sales AS (
        SELECT region, SUM(amount) AS total_sales
        FROM orders
        GROUP BY region
     ), 
	  top_regions AS (
        SELECT region
        FROM regional_sales
        WHERE total_sales > (SELECT SUM(total_sales)/10 FROM regional_sales)
     )
SELECT region,
       product,
       SUM(quantity) AS product_units,
       SUM(amount) AS product_sales
FROM orders
WHERE region IN (SELECT region FROM top_regions)
GROUP BY region, product;






----------- SUMMARY ----------

----------- LINKEDIN ----------

-- 1) work_history

--DROP TABLE IF EXISTS work_history;
--CREATE TABLE work_history (
--   member_id int,
--   company_name text,
--   start_year int
--);
--INSERT INTO work_history VALUES (1,'Microsoft',2010),(1,'xxx',2011),(1,'Google',2012);
--INSERT INTO work_history VALUES (2,'Google',2010),(2,'xxx',2011),(2,'Microsoft',2012);
--INSERT INTO work_history VALUES (3,'Microsoft',2010),(3,'xxx',2011);
--INSERT INTO work_history VALUES (4,'Google',2012);
--INSERT INTO work_history VALUES (5,'Microsoft',2010),(5,'Google',2012);

Q1: count members who ever moved from Microsoft to Google?

SELECT COUNT(DISTINCT(a.member_id))
FROM work_history a, work_history b
WHERE a.member_id = b.member_id
  AND a.company_name = 'Microsoft'
  AND b.company_name = 'Google'
  AND a.start_year < b.start_year;

R:

count <- inner_join(table, table, by="member_id")
filter(year_start.x < year_start.y)
filter(company_name.x ="microsoft")
filter(compnay_name.y ="google")
summarise(count =n())
print count


Q2: count members who directly moved from Microsoft to Google? (Microsoft - Linkedin - Google doesnt count)

WITH new_table AS (
   SELECT *, ROW_NUMBER() OVER(PARTITION BY member_id ORDER BY start_year) AS new_order FROM work_history)
SELECT count(distinct(a.member_id))
FROM new_table a, new_table b 
WHERE a.member_id = b.member_id
  AND a.new_order + 1 = b.new_order
  AND a.company_name = 'Microsoft'
  AND b.company_name = 'Google';


-- 2) linkedin_product
-- DROP TABLE IF EXISTS LINKEDIN_PRODUCT;
-- CREATE TABLE LINKEDIN_PRODUCT (customer int, product text, amount int);
-- INSERT INTO LINKEDIN_PRODUCT VALUES (1,'A',5),(1,'B',4),(1,'C',3),(2,'A',2),(2,'B',4),(2,'C',5),(3,'A',6),(3,'B',4),(3,'C',3);

--如何输出table,每行 customer, product.A, poduct.B, product.C
--                    1        x1          x2          x3

SELECT customer
   SUM(CASE product WHEN 'A' THEN amount ELSE 0) as product.A,
   SUM(CASE product WHEN 'B' THEN amount ELSE 0) as product.B,
   SUM(CASE product WHEN 'C' THEN amount ELSE 0) as product.C
FROM LINKEDIN_PRODUCT
GROUP BY customer;










------------------- OTHERS ----------------------------------
-- products（product_id, product_class_id, brand_name, price） 
-- sales(product_id, promotion_id, cutomer_id, total_sales)
-- customer(customer_id, state,...)
-- stores(store_id, ......)

Q1/2:只用一个table group by，order by就能出结果 有一题order by忘了加desc
Q3: 是问买过productA and productB的所有customer。
SELECT DISTINCT(c.customer_name)
FROM sales s
INNER JOIN customer c
ON s.product_id = c.product_id
WHERE s.product_id in ('A','B');
我这题用了两个join，感觉写的有点长，应该有更好的写法，但一时没想起来。小哥让我想想如果product多于两个，比如五个，应该怎么写。

---------------------------------------------------------------
-- sort按照字母规律，不过要求先把S排在最前

-- drop table if exists sort_test;
-- create table sort_test (index text);
-- insert into sort_test VALUES ('a');
-- insert into sort_test VALUES ('b');
-- insert into sort_test VALUES ('s');
-- insert into sort_test VALUES ('S');

SELECT * 
FROM sort_test
ORDER BY CASE WHEN index in ('S','s') THEN 0 ELSE 1, index;

------------------------------------------------------------------
-- 一道返回每个学生的最高分，重复按course id
SELECT student, course_id, MAX(score)
FROM table 
GROUP BY student, course_id;
-- 另一道算running total
SELECT student, SUM(score) OVER(PARTITION BY student ORDER BY course_id) as running_total
FROM table;





------------------- TWITCH -------------------
-- DROP TABLE IF EXISTS twitch;
-- CREATE TABLE twitch ( country varchar(2), duration int);
-- INSERT INTO twitch VALUES ('us', 850),('us',850),('jp',3600),('us',1000);
-- SELECT * FROM twitch;
-- Q1: AVERAGE DURIATION MINUTE FOR EACH SESSION
SELECT AVG(duration/60)::INT FROM twitch;
-- Q2: CHOOSE TOP 5 SESSION
SELECT * FROM twitch ORDER BY duration DESC LIMIT 3; -- ONLY ONE
SELECT country, RANK() OVER(ORDER BY duration DESC) FROM twitch; -- INCLUDE TIE
-- Q3: Histogram
select floor(duration/(60*5)) as bucket_floor, count(*) as count
from twitch
group by 1
order by 1;

select
    bucket_floor,
    CONCAT(bucket_floor, ' to ', bucket_ceiling) as bucket_name,
    count(*) as count
from (select floor(duration/(60*5)) as bucket_floor, floor(duration/(60*5)) + 1 as bucket_ceiling from twitch) a
group by 1, 2
order by 1;
-- Q4

-- Q5: DIFF BETWEEN 1000
-- 'us'|'jp'
-- 'jp'|'us'
WITH new_table AS (SELECT country, SUM(duration) AS tot FROM twitch GROUP BY country)
SELECT a.country, b.country
FROM new_table a, new_table b
WHERE ABS(a.tot-b.tot) <= 1000
AND a.country <> b.country;

WITH new_table AS (SELECT country, SUM(duration) AS tot FROM twitch GROUP BY country)
SELECT a.country, b.country
FROM new_table a, new_table b
WHERE ABS(a.tot-b.tot) <= 1000
AND a.country < b.country;




--------------------------------------------------- OPENTABLE ---------------------------------------------------

-- Q1 2nd highest
WITH rank AS(
select generate_series(1,10) as x)
SELECT a.x FROM rank a WHERE (SELECT COUNT(DISTINCT(b.x)) FROM rank b WHERE b.x < a.x)+1 = 2;

WITH rank AS(
select generate_series(1,10) as x)
SELECT a.x FROM rank a WHERE (SELECT COUNT(DISTINCT(b.x)) FROM rank b WHERE b.x > a.x)+1 = 2;

-- Q2: 365 days, one device, only IOS

create table opentable_sql (user_id int, device varchar(10), booking_date date);
insert into opentable_sql VALUES (1,'IOS','2018-06-01'),(1,'IOS','2018-06-02'),
  (2,'Android','2018-06-01'),(2,'IOS','2018-06-01'),(2,'IOS','2018-06-01');

-- ERROR:  aggregate functions are not allowed in WHERE
-- string_agg(device,',') has duplicates but no delimeter after the last varchar
SELECT user_id, string_agg(distinct device,',')
FROM opentable_sql
WHERE booking_date > current_date - 365
GROUP BY user_id
HAVING string_agg(distinct device,',') = 'IOS';

-- Q3: How to identify users that make a booking once a year for the past 5 years

SELECT user_id
FROM opentable_sql
WHERE booking_date > current_date - 365*5
GROUP BY user_id
HAVING COUNT(DISTINCT(EXTRACT(YEAR FROM booking_date))) = 5;

-- 2 years
WITH AGG AS (
  SELECT user_id, EXTRACT(YEAR FROM booking_date) as _year_
  FROM opentable_sql
  WHERE booking_date > current_date - 365*2
  GROUP BY user_id, EXTRACT(YEAR FROM booking_date))
SELECT A.user_id
FROM AGG A1, AGG A2
WHERE A1.user_id = A2.user_id
  AND A1._year_ - A2._year_ = 1;

-- Q4 How to create a table which lists out all the dates 
select generate_series(1,4);
1
2
3
4
-- 2*4 = 8
SELECT *
FROM opentable_sql 
CROSS JOIN generate_series(1,4) as x
WHERE user_id = 1;

SELECT dd:: date
FROM generate_series ('2007-02-01', '2007-02-28', '1 day'::interval) dd;

-- sample data:
  123, 1, 02/01/2017, 02/28/2017, 0
  123, 2, 02/14/2017, 02/14/2017, 1

-- Expected output:
  123, 1, 02/01/2017, 0
  ...
  123, 2, 02/14/2017, 1
  ...
  123, 1, 02/28/2017, 0

create table opentable_sql_q4 (user_id int, resv_id int, date_1 date, date_2 date, flag int);
insert into opentable_sql_q4 VALUES (123, 1, '02/01/2017', '02/28/2017', 0),
  (123, 1, '02/01/2017', '02/28/2017', 0);

select generate_series(date_1, date_2, '1 day'::interval)::date as calendar
from opentable_sql_q4;




--------------------------------------------------- AMAZON PREP ---------------------------------------------------

-- 1) orders (order_id, customer_id, order_datetime, order_amt):
-- a)select top 10 paying customers for given month  
SELECT customer_id, sum(order_amt) as tot
FROM orders 
WHERE EXTRACT(YEAR FROM order_datetime) = 2018 AND EXTRACT(MONTH FROM order_datetime) = 7 ----? LAST MONTH? 
GROUP BY customer_id
ORDER BY sum(order_amt) DESC
LIMIT 10;

-- b) create daily revenue report between given start_date and end_date
  -- output schema: (order_date, number_of_customers, number_of_orders, daily_total_order_amount, mtd_order_amount)
  -- mtd_order_amount - total order_amt from the beginning of the month till order_date 

--DROP TABLE IF EXISTS amazon_orders;
--create table amazon_orders (order_id int, customer_id int, order_datetime date, order_amt int);
--INSERT INTO amazon_orders VALUES (1,1,'2018-04-01',5),(2,1,'2018-04-02',5),(3,1,'2018-04-02',5),(3,3,'2018-05-01',5),(4,4,'2018-05-02',10);
SELECT a.order_datetime, COUNT(DISTINCT(a.customer_id)) as number_of_customers, 
  COUNT(DISTINCT(a.order_id)) as number_of_orders,
  SUM(a.order_amt) as daily_total_order_amount,
  (SELECT SUM(b.order_amt) FROM amazon_orders b 
   WHERE EXTRACT(YEAR FROM a.order_datetime) = EXTRACT(YEAR FROM b.order_datetime)
     AND EXTRACT(MONTH FROM a.order_datetime) = EXTRACT(MONTH FROM b.order_datetime)
     AND b.order_datetime <= a.order_datetime) as mtd_order_amount
FROM amazon_orders a
GROUP BY a.order_datetime;

-- 2) You have a website and you need to report the traffic insights on this website to the Product Manager. 
-- Write a SQL query to find the top 10 persons who have visited the website in the last month

select customer_id,count(*) 
from table 
where eff_dt between current_date and current_date-30 
group by customer_id 
order by count(*) desc 
fetch first 10 rows only;


-- 3) Select all customers who purchased at least two items on two separate days. 

SELECT customers 
FROM (
  SELECT customers, date
  FROM table
  GROUP BY customers, date
  HAVING COUNT(DISTINCT(item)) >=2 ) A
GROUP BY customers
HAVING COUNT(DISTINCT(date)) = 2;

-- 4) Given a table with a combination of flight paths, how would you identify unique flights if you don't care which city is the destination or arrival location.

--DROP TABLE IF EXISTS amazon_flight;
--CREATE TABLE amazon_flight (departure text, arrival text);
--INSERT INTO amazon_flight VALUES ('A','B'),('A','B'),
--                         ('B','A'),
--                         ('C','D'),
--                         ('C','A');
--  SELECT DISTINCT departure, arrival FROM amazon_flight; BOTH DISTINCT
SELECT DISTINCT a.arrival, a.departure
FROM amazon_flight a
LEFT JOIN amazon_flight b
ON a.departure = b.arrival AND a.arrival = b.departure
-- UNIQUE
WHERE b.arrival IS NULL 
-- DUPLICATES
   OR a.departure < a.arrival ;

-- 5) order history+ 每个customer在各个产品品类下面place过的首个和最后一个order的记录，
CREATE TABLE amazon_order_history (customer int, product int, order_date date);
INSERT INTO amazon_order_history (1,1,'2018-08-01'),(1,1,'2018-08-05'),(1,1,'2018-08-06'),
                       (2,1,'2018-08-01'),(2,1,'2018-08-05'),(2,1,'2018-08-06'),
                       (3,1,'2018-08-01'),(3,1,'2018-08-05'),(3,2,'2018-08-06');

SELECT a.*
FROM amazon_order_history a
WHERE (SELECT COUNT(*) FROM amazon_order_history b 
     WHERE a.customer = b.customer AND a.product = b.product AND b.order_date > a.order_date)+ 1 = 1
  OR (SELECT COUNT(*) FROM amazon_order_history b 
     WHERE a.customer = b.customer AND a.product = b.product AND b.order_date < a.order_date)+ 1 = 1;

-- 1).每天各产品类下的order中，是某顾客在该品类首个order的比例????????


-- 2).每天所有order中，是某顾客首个order的比例



Product:
在在线广告行业，分析问题时会考虑哪些metrics；还有如果已知CTR=5%，怎么判断这个CTR是好是坏



previous project:
Tell us about your work experience that is relevant to the position you applied.
Tell us about the skills you have acquired that are relevant to the position you applied.

BQ:
Tell me a time when you used the wrong dataset to do data analysis.  
How do you motivate people?  
A time where you had a team conflict  
Why are you applying for this job?

Other Tech:
R: Data loading from a text file , sub setting , and transforming
BI, Dimensional Modelling, Statistics
Very basic Python coding
confidence intervals...(they work in NLP ,so term counts are important)
30 min about statistics
Describe a join to a non-technical person.
Data warehousing concepts, ETL fundamentals  
How is variance calculated in a PCA
Stats questions : what is ttest, forecasting and  optimization techniques.
R: visualization, data frames, matrices. 
Math: Probability and forecasting examples.  


--------------------------------------------------- GOOGLE Product Analyst ---------------------------------------------------

-- 就是求一个group里面最近日期对应的行，用partition by就可以解决了 ---------------?

SELECT ROW_NUMBER() OVER(PARTITION BY USER ORDER BY date )
FROM table;

-- 从一个group里面random选十行出来

SELECT * 
FROM (
  SELECT *, row_number() OVER (PARTITION BY category ORDER BY random()) as rn
  FROM table ) sub
WHERE rn < 11;

-- 1 line
SELECT DISTINCT ON (category) *
FROM table 
ORDER BY category, random();

Product:
怎么样决定google express该用多少promotion？promotion该持续多长时间？怎样evaluate这个promotion有没有效？

--------------------------------------------------- FACEBOOK ---------------------------------------------------

-- 1) Content 
-- content_actions {user_id|content_id|conent_type|target_id} content_type = {"comment", "post", "photo"} #story: post or photo
--DROP TABLE IF EXISTS content_actions;
--CREATE TABLE content_actions (
--   user_id int,
--   content_id int,
--   content_type char(20),
--   target_id int);
--insert into content_actions VALUES (1,5,'post',null),
--                                   (17,6,'photo',null),
--                                   (16,20,'comment',5),
--                                   (2,10,'post',null);
-- a) 求问distribution of the comments



-- b) 每个content 的comment的distribution



-- c) 每个content type 的content 的comment的distribution

select n_comments, count(content_id) as n_posts from
(select a1.content_id, count(a2.content_id) as n_comments from content_action as a1
left join content action as a2 on a.content_id = a2.target_id and a2.target_id is not null
where a1.content_type = "post"
group by a1.content_id) as s
group by s.n_comments


2） 每个content type 的content 的comment的distribution

Q1: Generate a distribution for the #comments per story ( what is the distribution of comments?) !!!!!! DISTRIBUTION
SELECT a.content_id, CASE WHEN tot_comment IS NULL THEN 0 ELSE tot_comment END AS tot_com
FROM content_actions a
LEFT JOIN (
   SELECT target_id, COUNT(*) as tot_comment
   FROM content_actions b
   WHERE content_type = 'comment'
   GROUP BY target_id) c
ON c.target_id = a.content_id
WHERE a.content_type in ('post','photo');

SELECT tot_com, count(distinct(content_id)) as tot_post
FROM (
SELECT a.content_id, CASE WHEN tot_comment IS NULL THEN 0 ELSE tot_comment END AS tot_com
FROM content_actions a
LEFT JOIN (
   SELECT target_id, COUNT(*) as tot_comment
   FROM content_actions b
   WHERE content_type = 'comment'
   GROUP BY target_id) c
ON c.target_id = a.content_id
WHERE a.content_type in ('post','photo')) AS final
GROUP BY tot_com
ORDER BY tot_com;

Q2: Does this account for stories with 0 comments?
yes

Q1: What is the total number of comments and total number of posts?
   SELECT content_type, COUNT(*)
   FROM content_actions
   WHERE content_type <> 'photo'
   GROUP BY content_type;

Product:
How to get the nick name of each facebook user suach david - dave , and if we already have the data how can we use it?

table: 
content_actions 
{user_id|content_id|content_type|target_id} 
content_type = {"comment", "post"}

drop table if exists content_actions;
create table content_actions(
user_id int,
  content_id int,
  content_type varchar(20),
  target_id int 
);

insert into content_actions Values(1,1,'Post',null);
insert into content_actions Values(1,2,'Comment',1);
insert into content_actions Values(2,3,'Comment',1);
insert into content_actions Values(3,4,'Comment',1);
insert into content_actions Values(4,5,'Post',null);
insert into content_actions Values(5,6,'Comment',5);
insert into content_actions Values(6,7,'Comment',5);
insert into content_actions Values(7,8,'Post',null);

1. What is the total number of comments and total number of posts?
SELECT content_type, COUNT(*) FROM content_actions GROUP BY content_type;

2. what is the distribution of comments? 
如果content-type是post 那么便没有target-id. 然后comment的distribution就是说，比如这个post A 有6个comment，post B有六个comment，那么comment为6的post就有两个。
output应该是两列column{num_comment| num_post} 我们要算出每个数量的comment有几个这样的post，也就是说有多少个post有一样多数量的comment。


-- 2) 有个什么留言功能，有start-cancel和start post两种流程，用一个status variable记录状态（start，cancel，post三选一），还有什么user_id, session_id，date等等
-- 每一个动作对应一个状态，user_id是唯一的，状态可以有很多种
-- a) 要你算每一天的ave post rate/user
SELECT date, SUM(CASE WHEN status = 'POST' THEN 1 ELSE 0 END)/SUM(CASE WHEN status ='START' THEN 1 ELSE 0 END)
FROM TABLE 
GROUP BY date;
-- last week
SELECT SUM(CASE WHEN status = 'POST' THEN 1 ELSE 0 END)/SUM(CASE WHEN status ='START' THEN 1 ELSE 0 END)
FROM TABLE 
WHERE date between ;

-- b) 然后给了第二个table，是user的具体信息，什么location啥的，还有一个是否active，一共就是user_id,date,active(1/0),location
-- 要你算有多少user用了这个function并且成功post per location per date
SELECT location, date, COUNT(DISTINCT(user_id))
FROM TABLE
INNER JOIN user
ON TABLE.user_id = user.user_id
WHERE status = 'POST'
GROUP BY location, date;

-- c)然后加一个filter要求是当天active的人


Product:
说以前都是打字留言，现在想搞一个视频留言功能，你觉得怎么样
我：吹了一下，优点。。。，缺点。。。
追加：如果要你测试新功能，你怎么测试
追加：详细说说ab test
追加：有其他的办法吗
追加：更详细说说你的这个办法怎么做
最后：如果ab test结果很好，你觉得这个功能可以上架了吗



-- 3) friending
date         action   send_id  receiver_id 
2018-01-01   request  1        2
2018-01-02   accept   2        1

--DROP TABLE IF EXISTS FB_friending;
--CREATE TABLE FB_friending (action_date date, action text, send_id int, receiver_id int);
--INSERT INTO FB_friending VALUES ('2018-01-01','request',1,2),('2018-01-02','accept',2,1),
--                                ('2018-01-01','request',3,4),('2018-01-02','reject',4,3);

-- a) 就是问某一天send出去的request的acceptance rate
SELECT COALESCE(COUNT(b.action_date)::float/COUNT(a.action_date),0) as acceptance_rate
FROM FB_friending a
LEFT JOIN FB_friending b
ON a.send_id = b.receiver_id AND b.receiver_id = a.send_id AND b.action = 'accept' -- LIMITED B ACCEPT
WHERE a.action_date = '2018-01-01' AND a.action ='request';
-- OR
SELECT COALESCE(SUM(CASE WHEN b.action = 'accept' THEN 1 ELSE 0 END)::float/COUNT(a.action_date),0) as acceptance_rate
FROM FB_friending a
LEFT JOIN FB_friending b
ON a.send_id = b.receiver_id AND b.receiver_id = a.send_id
WHERE a.action_date = '2018-01-01' AND a.action ='request';

-- b) 求谁的朋友最多
SELECT C.fb_user
FROM 
(
SELECT send_id as fb_user, action FROM FB_friending 
UNION ALL 
SELECT receiver_id as fb_user, action FROM FB_friending
) C
WHERE C.action = 'accept'
GROUP BY C.fb_user
ORDER BY COUNT(*) DESC
LIMIT 1;

Product:
就是问Acceptance rate降了咋办。月末比月初低。这个应该答的问题不大。

我的回答是首先排除数据出问题，是不是data loading issue
然后是不是有seasonality影响，可以看看year over year是不是也是这个trend，是不是有holiday啊event啊什么的。
排除这些个因素以后，因为是rate，可以分开看到底是numerator和denominator哪个变化的厉害。是send的人突然变多了，还是accept的人变少了。分析各自可能的原因。
然后还要看各个segment来isolate问题出在哪里

如果你新开发的feature，实现了20%的CTR，你如何评价这个feature是好的，也就是说你怎么评价这个20%是好还是坏？
在newfeed里加“friend you may know”这个feature好不好。用哪些metrics？

--------------------------------------------------- LEETCODE ---------------------------------------------------
-- CASE WHEN:

UPDATE salary SET sex = (CASE WHEN sex = 'f' THEN 'm' WHEN sex = 'm' THEN 'f' ELSE '' END);
UPDATE salary SET sex = CASE sex WHEN 'm' THEN 'f' ELSE 'm' END;

SELECT CASE WHEN mod(id,2) = 0 THEN id-1 WHEN mod(id,2)=1 AND id <> (SELECT MAX(id) FROM seat) THEN id+1 ELSE id END AS new_id, student
FROM seat
ORDER BY new_id;

-- SELF JOIN:

  -- A. Consecutive
  -- select * from amazon_flight a, amazon_flight b; THIS SELF JOIN => CROSS JOIN

SELECT DISTINCT a.*
FROM stadium a, stadium b, stadium c
WHERE a.people >= 100 AND b.people >= 100 AND c.people >= 100
-- a in the beginning
AND ((a.id = b.id + 1 AND b.id = c.id + 1)
-- a in the middle
  OR (b.id = a.id + 1 AND a.id = c.id + 1)
-- a at the end
  OR (b.id = c.id + 1 AND c.id = a.id + 1))
ORDER BY a.id;


-- HAVING:
-- ERROR:  aggregate functions are not allowed in WHERE
SELECT class
FROM courses
GROUP BY class
HAVING COUNT(DISTINCT(student)) >= 5;


-- EMPTY THEN NULL







