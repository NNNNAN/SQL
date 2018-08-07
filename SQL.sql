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

-- 5th if no hole
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

count <- inner_join(table, table, by="member_id") %>%
filter(year_start.x < year_start.y) %>%
filter(company_name.x ="microsoft") %>%
filter(compnay_name.y ="google") %>%
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





