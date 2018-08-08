176,177,569,570,571,574,579,627,
626
1. Rank

2. Consecutively
	WHERE index AND VALUE





(101,'John','A',null),
(102,'Dan','A',101),
(103,'James','A',101),
(104,'Amy','A',101),
(105,'Anne','A',101),
(106,'Ron','B',101);

















-- 175 Combine Two Tables

	SELECT FirstName, LastName, City, State
	FROM Person p
	LEFT JOIN Address A
	ON p.PersonId = A.PersonId

	-- WHAT IF PERSON WITH NO ADDR
	SELECT FirstName, LastName, City, State
	FROM Person p
	LEFT JOIN Address A
	ON p.PersonId = A.PersonId
	WHERE A.PersonId IS NULL;

	-- WHAT IF PERSON WITH ADDR
	SELECT FirstName, LastName, City, State
	FROM Person p
	INNER JOIN Address A
	ON p.PersonId = A.PersonId;

-- 176 Second Highest Salary
	select max(Salary) as 'SecondHighestSalary'
	from Employee
	where salary < (select max(salary) from Employee);
	-- Offset rows-to-skip
	SELECT
	    (SELECT DISTINCT Salary
	     FROM Employee
	     ORDER BY Salary DESC
	     LIMIT 1 OFFSET 1) AS SecondHighestSalary
	;
	-- IFNULL
	SELECT
	    IFNULL(
	      (SELECT DISTINCT Salary
	       FROM Employee
	       ORDER BY Salary DESC
	        LIMIT 1 OFFSET 1),
	    NULL) AS SecondHighestSalary;

-- 177 Nth highest Salary
	-- LIMIT (N-1), 1 不行
	create function getNthHighestSalary(N int) RETURNS INT
	BEGIN 
		SET N = N-1;
		RETURN (
		    SELECT distinct salary
		    from Employee
		    order by salary desc limit N, 1
		);
	END

	CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
	BEGIN
		declare x int;
		set N = N - 1;
		set x = (select distinct Salary from Employee order by Salary desc limit N, 1);
		if isnull(x)
			then
			return null;
		else
			return x;
		end if;
	END

-- 178 Rank Scores
	-- no hole
	select Score, (select count(distinct(Score))+1 from Scores where Score > S.Score) as Rank
	from Scores S
	Order by Score desc;

	select Score, (select count(distinct(Score)) from Scores where Score >= S.Score) as Rank
	from Scores S
	Order by Score desc;

	-- with hole 113446
	select score, (select count(score)+1 from Scores where score > A.score) as rank
	from Scores A
	order by score desc;

	-- with hole 223556
	select score, (select count(score) from Scores where score >= A.score) as rank
	from Scores A
	order by score desc;

-- 180 Consecutive Numbers
	-- Down
	-- a b c
	-- 3 2 1
	select distinct a.Num as "ConsecutiveNums"
	from Logs a, Logs b, Logs c
	where a.Id = b.Id + 1 and b.Id = c.Id + 1
	and a.Num = b.Num and b.Num = c.Num;

-- 181. Employees Earning More Than Their Managers

	SELECT emp.Name AS 'Employee'
	FROM Employee emp, Employee M
	WHERE emp.ManagerId = M.Id
	AND emp.Salary > M.Salary;

	SELECT emp.NAME AS Employee
	FROM Employee AS emp
	JOIN Employee AS M
	ON emp.ManagerId = M.Id
	AND emp.Salary > M.Salary;

-- 182. Duplicate Emails
	SELECT Email
	FROM Person
	GROUP BY Email
	HAVING count(*) > 1;

-- 183. Customers Who Never Order
	SELECT Name AS 'Customers'
	FROM Customers Cust
	LEFT JOIN Orders
	ON Cust.Id = Orders.CustomerId
	WHERE Orders.CustomerId is null;

	SELECT Name as 'Customers' FROM Customers
	WHERE Id NOT IN (SELECT CustomerId from Orders);

-- 184. Department Highest Salary
	SELECT Department.Name as 'Department', Employee.Name as 'Employee', Employee.Salary as 'Salary' 
	FROM Employee
	JOIN Department
	ON Department.Id = Employee.DepartmentId
	WHERE (SELECT count(ID) 
	       FROM Employee as EMP 
	       WHERE EMP.Salary > Employee.Salary AND EMP.DepartmentId = Employee.DepartmentId) = 0;

	SELECT Department.Name as 'Department', emp.Name as 'Employee', emp.Salary as 'Salary' 
	FROM employee emp
	INNER JOIN (select DepartmentId, max(Salary) as max_salary From Employee Group by DepartmentId ) as max
	ON emp.Salary = max.max_salary AND emp.DepartmentId = max.DepartmentId
	JOIN Department
	ON Department.Id = emp.DepartmentId;

	SELECT Department.name AS 'Department', Employee.name AS 'Employee', Salary
	FROM Employee
	JOIN Department ON Employee.DepartmentId = Department.Id
	WHERE (Employee.DepartmentId , Salary) IN (SELECT DepartmentId, MAX(Salary) FROM Employee GROUP BY DepartmentId);

-- 185. Department Top Three Salaries
	SELECT Department.Name as 'Department', emp.Name as 'Employee', emp.Salary
	FROM Employee emp
	JOIN Department ON Department.Id = emp.DepartmentId
	WHERE (SELECT count(distinct(Employee.Salary)) -- !!
		    FROM Employee where Employee.Salary > emp.Salary and Employee.DepartmentId=emp.DepartmentId) < 3
	ORDER BY Department.Name, emp.Salary desc;

-- 196. Delete Duplicate Emails
	DELETE p1 
	FROM Person p1, Person p2
	WHERE p1.Email = p2.Email AND p1.Id > p2.Id;

-- 197. Rising Temperature
	SELECT a.Id
	FROM Weather a, Weather b
	WHERE DATEDIFF(a.RecordDate,b.RecordDate) = 1
	AND a.Temperature > b.Temperature;

-- 262. Trips and Users
	SELECT Trips.Request_at AS 'Day', ROUND(SUM(CASE WHEN Status='completed' THEN 0 ELSE 1 END)/count(Id),2) as 'Cancellation Rate'
	from Trips
	left join Users on Users.Users_Id = Trips.Client_Id
	where Users.Banned = 'No' and Trips.Request_at between '2013-10-01' and '2013-10-03'
	group by Trips.Request_at
	order by Trips.Request_at;

-- 569. Median Employee Salary

	-- BUILD IN FUNCTION
		SELECT * FROM (
		SELECT emp1.*, tot_cnt, ROW_NUMBER() OVER(PARTITION BY emp1.Company ORDER BY salary) as rank
		FROM LEETCODE_569 emp1
		LEFT JOIN (SELECT Company, COUNT(Id) AS tot_cnt FROM LEETCODE_569 GROUP BY Company) AS tot
		ON tot.Company = emp1.Company) for_all
		WHERE (mod(tot_cnt,2) = 0 AND rank BETWEEN tot_cnt/2 AND tot_cnt/2 + 1)
		   OR (mod(tot_cnt,2) = 1 AND rank = (tot_cnt+1)/2);

	-- NON-BUILD IN 

-- 570. Managers with at Least 5 Direct Reports
	SELECT M.Name
	FROM Employee emp, Employee M
	WHERE emp.ManagerId = M.Id AND emp.ManagerId is not null
	GROUP BY emp.ManagerId
	HAVING count(emp.Id) >= 5;

-- 574. Winning Candidate
	SELECT Name 
	FROM Candidate
	JOIN (
		SELECT CandidateId
		FROM Vote
		GROUP BY CandidateId
		ORDER BY count(*) DESC LIMIT 1) AS winner
	ON Candidate.id = winner.CandidateId;

-- 577. Employee Bonus
	-- Note: "LEFT OUTER JOIN" could be written as "LEFT JOIN".
	SELECT name, bonus
	FROM Employee
	LEFT JOIN Bonus
	ON Bonus.empId = Employee.empId
	WHERE Bonus.bonus < 1000 OR Bonus.empId IS NULL;

-- 578. Get Highest Answer Rate Question
	SELECT question_id as 'survey_log'
	FROM survey_log
	GROUP BY question_id
	ORDER BY SUM(CASE WHEN action='answer' THEN 1 ELSE 0 END)/SUM(CASE WHEN action='show' THEN 1 ELSE 0 END) DESC
	LIMIT 1;

	SELECT question_id AS 'survey_log'
	FROM survey_log
	GROUP BY question_id
	ORDER BY COUNT(answer_id) / COUNT(IF(action = 'show', 1, 0)) DESC
	LIMIT 1;

-- 579. Find Cumulative Salary of an Employee




-- 580. Count Student Number in Departments
	SELECT dept_name, count(distinct(student_id)) AS 'student_number'
	FROM department d
	LEFT JOIN student s
	ON d.dept_id = s.dept_id
	GROUP BY dept_name
	ORDER BY count(distinct(student_id)) DESC, dept_name;

-- 584. Find Customer Referee
	SELECT name FROM customer 
	WHERE referee_id <> 2 OR referee_id is NULL;

-- 585. Investments in 2016
	SELECT SUM(insurance.TIV_2016) AS TIV_2016
	FROM insurance
	WHERE
	    insurance.TIV_2015 IN
	    (
	      SELECT TIV_2015
	      FROM insurance
	      GROUP BY TIV_2015
	      HAVING COUNT(*) > 1
	    )
	    AND CONCAT(LAT, LON) IN
	    (
	      SELECT CONCAT(LAT, LON)
	      FROM insurance
	      GROUP BY LAT , LON
	      HAVING COUNT(*) = 1
	    );

	SELECT SUM(TIV_2016) as 'TIV_2016'
	FROM insurance a
	WHERE (LAT, LON) IN (SELECT LAT, LON FROM insurance b GROUP BY LAT, LON HAVING count(*) = 1)
	  AND TIV_2015 IN (SELECT TIV_2015 FROM insurance c GROUP BY TIV_2015 HAVING count(*) > 1);

-- 586. Customer Placing the Largest Number of Orders
	SELECT customer_number
	FROM orders
	GROUP BY customer_number
	ORDER BY count(*) desc
	lIMIT 1;

-- 595. Big Countries
	SELECT name, population, area
	FROM World
	WHERE area > 3000000 OR population > 25000000;

-- 596. Classes More Than 5 Students
	SELECT class FROM courses
	GROUP BY class
	HAVING count(distinct(student)) >=5;

-- 597. Friend Requests I: Overall Acceptance Rate
	SELECT ROUND(IFNULL(count(distinct requester_id,accepter_id)/count(distinct sender_id,send_to_id),0),2) AS 'accept_rate'
	from friend_request, request_accepted;
	Follow-up:
	Can you write a query to return the accept rate but for every month?
	How about the cumulative accept rate for every day?

-- 601. Human Traffic of Stadium
	SELECT distinct c.* FROM (
	SELECT a.*
	FROM stadium a, stadium b, stadium c
	WHERE a.id = b.id + 1 and b.id = c.id + 1
	AND a.people >= 100 AND b.people >= 100 AND c.people >= 100
	union
	SELECT a.*
	FROM stadium a, stadium b, stadium c
	WHERE a.id = b.id - 1 and b.id = c.id - 1
	AND a.people >= 100 AND b.people >= 100 AND c.people >= 100
	union
	SELECT a.*
	FROM stadium a, stadium b, stadium c
	WHERE a.id = b.id - 1 and c.id = a.id - 1
	AND a.people >= 100 AND b.people >= 100 AND c.people >= 100) as c
	ORDER BY c.id;

	select distinct a.*
	from stadium a, stadium b, stadium c
	where a.people >= 100 and b.people >= 100 and c.people >=100
	and ((a.id -1 = b.id and b.id - 1 = c.id) 
	  or (a.id +1 = b.id and b.id + 1 = c.id)
	  or (a.id +1 = b.id and b.id - 2 = c.id)) ----- when counts is not enough
	order by a.id;

-- 603. Consecutive Available Seats
	SELECT distinct(a.seat_id) AS 'seat_id'
	FROM cinema a, cinema b
	WHERE ((a.seat_id = b.seat_id + 1) OR (a.seat_id = b.seat_id - 1))
	AND a.free = 1 and b.free = 1
	ORDER BY a.seat_id;

	select distinct a.seat_id
	from cinema a join cinema b
	  on abs(a.seat_id - b.seat_id) = 1
	  and a.free = true and b.free = true
	order by a.seat_id;

-- 607. Sales Person



-- 620. Not Boring Movies
	SELECT * FROM cinema
	WHERE description <> 'boring' and mod(id,2) = 1
	ORDER BY rating;

-- 626. Exchange Seats
	SELECT a.id, IFNULL((SELECT student FROM seat b WHERE b.id = a.id + 
	             (CASE WHEN mod(a.id,2) = 1 THEN 1 ELSE -1 END)),a.student) as 'student'
	FROM seat a;

	SELECT
	    (CASE
	        WHEN MOD(id, 2) != 0 AND counts != id THEN id + 1
	        WHEN MOD(id, 2) != 0 AND counts = id THEN id
	        ELSE id - 1
	    END) AS id,
	    student
	FROM seat,
	    (SELECT COUNT(*) AS counts
	     FROM seat) AS seat_counts
	ORDER BY id ASC;

	-- Return the first non-null expression in a list
	SELECT s1.id, COALESCE(s2.student, s1.student) AS student
	FROM seat s1
	LEFT JOIN seat s2 ON ((s1.id + 1) ^ 1) - 1 = s2.id
	ORDER BY s1.id;

-- 627. Swap Salary
	update salary
	set sex = (CASE WHEN sex = 'm' THEN 'f' ELSE 'm' END);





SELECT * FROM table LIMIT 5,10; // 检索记录行 6-15  
SELECT * FROM table LIMIT 5 OFFSET 10; ??


with agg as (
select DepartmentId, Name, Salary, dense_rank() over (partition by DepartmentId order by Salary desc) as rank
from Employee)

select d.Name as "Department", a.Name as "Employee", a.Salary as "Salary"
from agg a 
join Department d on a.DepartmentId = d.Id
where a.rank < 4







In MySQL, you can't modify the same table which you use in the SELECT part.
WINDOW FUNCTION XXX WHERE
Pandas, Numpy，Matplotlib, SciKit-Learn