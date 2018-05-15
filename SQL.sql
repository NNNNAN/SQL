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
SELECT id, null as pid FROM id_pid_view a
WHERE NOT EXISTS (SELECT id FROM id_pid b WHERE a.id=b.id);

SELECT last_updated_dt INTO ail_update_date FROM gsat.ais_national_counts;

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
SELECT DISTINCT on (cgmid, phonetypeid) cgmid, phonetypeid, unformattedphone

-- The NULL value sorts higher than the other value. 
-- When sort order is ascending the NULL value comes at the end 
-- and in the case of descending sort order, it comes at the beginning.
SELECT deptno, AVG(salary)
FROM employee
WHERE designame <>'PRESIDENT'
GROUP BY deptno
HAVING COUNT(*)>3
ORDER BY deptno DESC;

INNER JOIN
RIGHT JOIN
LEFT JOIN = LEFT OUTER JOIN
FULL JOIN

------------------WINDOW FUNCTION --------------
-- use of a window function does not cause rows to become grouped into a single output row — the rows retain their separate identities.
-- RANK
SELECT rest_id, RANK() OVER (ORDER BY rest_id) as all_rank FROM location;
SELECT rest_id, RANK() OVER (ORDER BY parent_region_id) as region_rank FROM location; --- !!!! bie jia rest_id

-- AVG
SELECT rest_id, (avg(parent_region_id) over())::INT AS all_avg from location;
SELECT rest_id, (avg(parent_region_id) over(PARTITION BY parent_region_id))::INT AS reg_avg from location;

-- SUM
SELECT rest_id, (SUM(parent_region_id) over())::INT AS all_sum from location;
SELECT rest_id, (SUM(parent_region_id) over(PARTITION BY parent_region_id))::INT AS reg_sum from location;
SELECT rest_id, (SUM(parent_region_id) over(PARTITION BY parent_region_id ORDER BY rest_id))::INT AS reg_sum from location; -- incremental

-----------USEFUL FUNCTIONS ----------
substring(mkey1 from char_length(mkey1) - 4)
substring(phone_home::text from 1 for 3)::int

SELECT DATE_PART('year', '2012-01-01'::date) - DATE_PART('year', '2011-10-02'::date);
SELECT '2018-01-01'::date - '2011-10-02';
-- The COALESCE function returns the first of its arguments that is not null
coalesce(max(date_updated),'1990-01-01')
string_agg(zip, ', ')


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