什么friend request这种经常要两个col换个顺序然后union，
然后sum case when和ifnull注意就行 => other
inner join 和rank over
两个表left join，count一下加上group by
calculate precision
CASE WHEN => SUM
the "/" operator does integer division: 1::float/3
unique pair counting problem，ratio
	
rucliuwenhui
2018-5-2 06:33
-------------------------------------------

products（product_id, product_class_id, brand_name, price） 
sales(product_id, promotion_id, cutomer_id, total_sales)
customer(customer_id, ...)，还有一个忘记了。。

Q1/2:只用一个table group by，order by就能出结果 有一题order by忘了加desc
Q3: 是问买过productA and productB的所有customer。
我这题用了两个join，感觉写的有点长，应该有更好的写法，但一时没想起来。小哥让我想想如果product多于两个，比如五个，应该怎么写。
SELECT distinct(customer_id) FROM sales WHERE product_id = (SELECT product_id FROM products WHERE );

------------------------------------------

DROP TABLE IF EXISTS work_history;
CREATE TABLE work_history (
	member_id int,
   company_name text,
   start_year int
);

INSERT INTO work_history VALUES (1,'Microsoft',2010),(1,'xxx',2011),(1,'Google',2012);
INSERT INTO work_history VALUES (2,'Google',2010),(2,'xxx',2011),(2,'Microsoft',2012);
INSERT INTO work_history VALUES (3,'Microsoft',2010),(3,'xxx',2011);
INSERT INTO work_history VALUES (4,'Google',2012);
INSERT INTO work_history VALUES (5,'Microsoft',2010),(5,'Google',2012);

Q1: count members who ever moved from Microsoft to Google? (如果有人从M跳到L然后调到G也算，只要现在M工作过,然后在G工作就算)

	SELECT count(distinct(a.member_id))
	FROM work_history a, work_history b
	WHERE a.member_id = b.member_id
	  AND a.start_year < b.start_year
	  AND a.company_name = 'Microsoft'
	  AND b.company_name = 'Google';

Q2: count members who directly moved from Microsoft to Google? (Microsoft - Linkedin - Google doesnt count)

	WITH new_table AS (
		SELECT *, ROW_NUMBER() OVER(PARTITION BY member_id ORDER BY start_year) AS new_order FROM work_history)
	SELECT count(distinct(a.member_id))
	FROM new_table a, new_table b 
	WHERE a.member_id = b.member_id
	  AND a.new_order + 1 = b.new_order
	  AND a.company_name = 'Microsoft'
	  AND b.company_name = 'Google';

---------------------------------------------
刚加入的用户会要求填一份调查问卷，但问卷里的问题也可以跳过，每道题只要被用户见到就会生成一条记录（event为saw)
如果被回答或者被跳过会生成另一条数据（即每道题每个用户都会有两条记录），回答则event为answered，跳过即为skip
并且每道题出现在每个用户前的顺序有可能不同，所以有question_order。

DROP TABLE IF EXISTS survey_log;
CREATE TABLE survey_log (
	user_id int,
   question_id int,
   question_order int,
   event varchar(10)
   -- timestamp
);

INSERT INTO survey_log VALUES (1,10,1,'saw');
INSERT INTO survey_log VALUES (1,10,1,'skiped');
INSERT INTO survey_log VALUES (1,11,2,'saw');
INSERT INTO survey_log VALUES (1,11,2,'answered');
INSERT INTO survey_log VALUES (2,10,1,'saw');
INSERT INTO survey_log VALUES (2,10,1,'skiped');
INSERT INTO survey_log VALUES (2,11,2,'saw');
INSERT INTO survey_log VALUES (2,11,2,'skiped');
INSERT INTO survey_log VALUES (3,10,1,'saw');
INSERT INTO survey_log VALUES (3,10,1,'answered');
INSERT INTO survey_log VALUES (4,12,1,'saw');
INSERT INTO survey_log VALUES (4,12,1,'skiped');
INSERT INTO survey_log VALUES (5,10,1,'saw');
INSERT INTO survey_log VALUES (5,10,1,'skiped');
INSERT INTO survey_log VALUES (5,14,2,'saw');
INSERT INTO survey_log VALUES (5,14,2,'answered');


Q1: 假设该表里已经存了1M用户的数据，在一个新用户进来时，如何安排题目尽可能多地得到新用户的答案，减少skip？ 求了个每道题的回答率，注意不能只求回答次数，要除以总的看见此题的次数 
	SELECT question_id, ROUND(CAST(SUM(CASE WHEN event = 'answered' THEN 1 ELSE 0 END)::float/SUM(CASE WHEN event = 'saw' THEN 1 ELSE 0 END) AS NUMERIC),2) AS rate
	FROM survey_log
	GROUP BY question_id
	ORDER BY rate DESC;

Q2: 即使按照回答率对题目进行排序，如果新来的用户已经skip掉了回答率最高和次高的题，如何动态调整题目顺序，获得此用户尽可能多的回答？ 
	 条件概率，要看用户之间的相似度，即已有数据中跳过了这两道题的用户回答率最高的是哪道……
	 
	 这个题目估计用python会好一些。其实就是条件概率，比如一个user回答了某个问题，那么接下来他回答后面问题的概率分别都是多少，我觉得用sql，只能用一个具体例子，比如回答了问题1以后，跟他一样回答了问题1的用户，回答后面那些问题的概率都是多少
--------------------------------------------
邮件注册以后会选择短信验证，只有短信验证了才能使用，这样有两个table：

email table: time, user_id, email_id;
text table: time, user_id, text_id, action(验证or没有验证）

DROP TABLE IF EXISTS email_yz;
CREATE TABLE email_yz (
	time TIMESTAMP,
    user_id int,
    email_id int
);
DROP TABLE IF EXISTS text_yz;
CREATE TABLE text_yz (
	time TIMESTAMP,
    user_id int,
    text_id int,
    action varchar(5)
);

INSERT INTO email_yz VALUES ('2004-10-19 10:23:54',1,10);
INSERT INTO email_yz VALUES ('2004-10-19 10:23:54',2,11);
INSERT INTO email_yz VALUES ('2004-10-19 11:23:54',3,12);
INSERT INTO email_yz VALUES ('2004-10-19 11:23:54',4,13);
INSERT INTO email_yz VALUES ('2004-11-19 11:23:54',5,14);
INSERT INTO email_yz VALUES ('2004-11-19 11:23:54',6,15);
INSERT INTO email_yz VALUES ('2004-11-19 11:23:54',7,16);
INSERT INTO email_yz VALUES ('2004-11-19 11:23:54',8,17);
INSERT INTO text_yz VALUES ('2004-10-19 11:23:54',1,21,'YZ');
INSERT INTO text_yz VALUES ('2004-10-19 11:23:54',2,22,'NYZ');
INSERT INTO text_yz VALUES ('2004-10-19 12:23:54',3,23,'YZ');
INSERT INTO text_yz VALUES ('2004-10-19 12:23:54',4,24,'NYZ');
INSERT INTO text_yz VALUES ('2004-11-19 12:23:54',5,25,'NYZ');
INSERT INTO text_yz VALUES ('2004-11-19 12:23:54',6,26,'YZ');
INSERT INTO text_yz VALUES ('2004-11-20 12:23:54',7,27,'YZ');
INSERT INTO text_yz VALUES ('2004-11-20 12:23:54',8,28,'NYZ');

Q1: 每天大概有多少注册邮件
	SELECT COUNT(*)/COUNT(DISTINCT(CAST(time AS DATE))) FROM email_yz;

Q2: 注册的人大概有多少通过了短信验证
	SELECT COUNT(distinct(user_id)) FROM text_yz WHERE action = 'YZ';

Q3: 有多少人注册当天没有验证成功，第二天才验证成功
	SELECT COUNT(distinct(em.user_id))
	FROM email_yz em, text_yz sms
	WHERE em.user_id = sms.user_id
	AND sms.action = 'YZ'
	AND CAST(sms.time AS DATE) - 1 = CAST(em.time AS DATE);

Q4: 可能还有一问是平均注册到验证大概有多少时间
	SELECT AVG(sms.time - em.time)
	FROM email_yz em, text_yz sms
	WHERE sms.action = 'YZ'
	AND   em.user_id = sms.user_id;

-------------------------------------------------------------------
有两张的table(一个月一张)，key是account_num，变量account_type(check or save or save+check三类), date（by day）
Q1-x: 简单的groupby orderby算一下三类account有多少
SELECT account_type, COUNT(account_num) 
FROM table
GROUP BY account_type
ORDER BY account_type;

Qx+1: 要join变成一个table，如果前一个月有 后一个月cancel了account就显示null；
      如果前一个月没有，后一个月有, 则无法track 不能显示null。我好像用case when和full outer join解决了。
SELECT CASE WHEN a.account_num IS NOT NULL THEN b.account_num ELSE '' END) AS account_num, a.account_type
FROM table_last a
FULL JOIN table_current b
ON a.account_num = b.account_num;
------------------------------------------------------------------
三个instagram table, 体育明星和体育项目，然后求每个体育项目的follower
t1(user_name, sports_category)------------ t1中只有celebrity运动员。pk=user_name
t2(user_id, user_name, registration_date)----------t2中是所有人的用户信息，包括celebrity和普通人，且不会出现celebrity和普通人重名的情况（重要假设）。pk=user_id
t3(user_id, user_id_following, follow_date)----用户follow信息，注意user_id_following中包括celebrity和普通人 
Q1: 计算每个category有多少人follow
(这里要注意第三个table 是followees 是id; followers是id_following
也就是join这table 2 和3 应该是用B.id = C.id_following
还要考虑是否用left join还是inner join)

SELECT sports_category ,COUNT(*) FROM (
	SELECT user_id_following, COUNT(user_id_following)
	FROM t2
	GROUP BY user_id_following) AS a
RIGHT JOIN t2
ON t2.user_id = a.user_id_following
RIGHT JOIN t1
ON t1.user_name = t2.user_name
GROUP BY sports_category;

Q2: 求有多少个NBA category follow NFL
-----------------------------------------------------------------
user questionare那个题目的类似版本， 根据user有没有send 一个sticker， 如何给他推荐新的sticker

------------------------------------------------------------------
userid1, userid2, friend/unfriend, time_stamp，问目前为止还是friend的userid
SELECT distinct(a.userid1)
FROM table a, table b
WHERE a.userid1 = b.userid2
  AND a.userid2 = b.userid1
  AND a.xxxxxxx = 'friend'
  AND b.xxxxxxx = 'friend';
-----------------------------------------------------------------
product: pruduct_id, brand_id, class_id, ....
customers: customer_id, state, ... 
sales: product_id, customer_id, product_id, sales_amount, price..... 
stores: store_id, ...... 

问题和地理之前的有差别，但是核心内容是一样的GROUP BY, INNER JOIN, OUTER JOIN, Condition Statements. 
??????????????????????????
------------------------------------------------------------------
就是一个customer table, 一个viewtable,  然后join 啊。 
问多少account id viewing大于3个小时。 就是有个tricky地方， join 的时候有些accountid, 虽然signup 了但是没有view,所以没有在customertable 出现。 是null 的。 
这个被问了， 当时还不知道出什么问题了 。 不过后来也是解决了。
------------------------------------------------------------------
一道返回每个学生的最高分，重复按course id。。另一道算running total. 
SELECT STUDENT_ID, MAX(score) 
FROM table
GROUP BY STUDENT_ID
ORDER BY STUDENT_ID;
------------------------------------------------------------------
date | u1 | u2 | n_msg
每行是一对unique user pair之间在某天发的消息数量, 注意，小明和小红分别出现在user_a和user_b的话，就不会出现另一对小红和小明分别在user_a和user_b
Q1: 从这个表我们可以知道些什么信息

Q2: 写个query得到某一天用户发消息朋友数量的distribution，就是output出两列，
X: number of unique contacts for each user; Y: number of user with this many contacts。
问你觉得这个distribution会长什么样子，为什么。

SELECT CASE WHEN a1.u1 IS NULL THEN b1.u2 ELSE a1.u1 END AS user, a1.a+b1.b AS tot_friend, a1.c+b1.d AS tot_msg FROM ( =>>>>>>>>CONVERT null to 0
SELECT u1, COUNT(*) as a, SUM(n_msg) as c
FROM Table a 
GROUP BY u1) AS a1
FULL JOIN
(
SELECT u2, COUNT(*) as b, SUM(n_msg) as d
FROM Table b
GROUP BY u2) AS b1
ON a1.u1 = b1.u2

Q3: 写个query找到每个user发信息最多的top partner，然后再加一个简单的outer query计算SUM(n_msg_with_top_partner)/SUM(all_messages_with_all_contacts），sum over all users
=> UNION ALL

---------------------------------------------------------------
date | user_num,
注意date 是每天的date。 问如何找到top 100 week over week increaser/dropper.
他提示我先找到每周的人数，然后再找diff。 然而我不知道如何在sql中从date==>week, 他就让我assume 有一个方程可以得到week number。 于是我写了一个类似group by 的
SELECT week, COUNT(*)
FROM table
GROUP BY week;
---------------------------------------------------------------
明星 id, 明星 category (baseball start, basket ball star)，follower_id 求哪个明星category有多少follower 
SELECT id, category, COUNT(DISTINCT(follower_id))
FROM table
WHERE id = 'xxxxxx' AND category = 'xxxxxxx';
---------------------------------------------------------------
sort按照字母规律，不过要求先把S排在最前

drop table if exists sort_test;
create table sort_test (index text);
insert into sort_test VALUES ('a');
insert into sort_test VALUES ('b');
insert into sort_test VALUES ('s');
insert into sort_test VALUES ('S');

SELECT * 
FROM sort_test
ORDER BY CASE WHEN index in ('S','s') THEN 0 ELSE 1, index;
----------------------------------------------------------------
给我一个用户记录的表。 日期， 用户名， 活动(登录)  设计一个发日/周月积极用户的表。  
我开始用三个sql 来做。 但即使 扫30 天的数据也很多 。   
我使用 一个sql 把3个梳子算出来。 但也需要30 天的书据。 最后他提示设计一个每天用户最后哪天登陆。   最后突然来个里口起吧。
----------------------------------------------------------------
#Table name: content_actions
user_id
content_id
content_type ('post', 'photo', 'comment') #story: post or photo
target_id

DROP TABLE IF EXISTS content_actions;
CREATE TABLE content_actions (
	user_id int,
	content_id int,
	content_type char(20),
	target_id int);
insert into content_actions VALUES (1,5,'post',null),
	                                (17,6,'photo',null),
	                                (16,20,'comment',5),
	                                (2,10,'post',null);
1）每个content 的comment的distribution
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

Q2: How to get the nick name of each facebook user suach david - dave , and if we already have the data how can we use it?
------------------------------------------------------------------
cummulative clients table 和 今天所有clients table，更新今天的clients信息到cummulative table里。update flag （new clients，ressurrecting clients，churn，。。。）

UPDATE cummulative_clients cum
SET update_flag = 1
FROM client c 
WHERE c.client_id = 

--------------------------------------------------------------------
Table1: Advertisement_info 广告商的信息
advtiser_id 广告商的名称
ad_id 广告id
spend 广告商花费

Table2: ad_info 广告的信息
ad_id    广告id
user_id  用户id
price    用户花费

Q1: 求每个广告的平均花费 (问平均每个广告商在fb花了多少钱)
SELECT advtiser_id, AVG(spend) as avg_spend
FROM Advertisement_info
GROUP BY advtiser_id;

Q2: 问有多少广告商至少有一次conversion
SELECT advtiser_id
FROM Advertisement_info adv
INNER JOIN ad_info
ON adv.ad_id = ad_info.ad_id
WHERE price > 0
GROUP BY advtiser_id
HAVING COUNT(user_id) > 0;

Q3: 如果FB想要了解目前的广告能否让用户满意， 可以如何设计Metrics ；先解释 请写SQL表达出
	 (讨论metrics来衡量广告这个产品的表现，然后选了一个问code怎么写)



--------------------------------------------------------------------
1和2都是同样4组数据：
transaction master data
wire transfer master data
branch master data
第四个忘记了，用不着

Q1: 是算destiny country是canada，固定时间的，所有transaction总和 （第一，第二组inner join一下，加上条件，算个sum）
SELECT COUNT(*), SUM(XXX)
FROM transaction
FULL JOIN wire
--------------------->??? inner join
Q2: 是算固定时间下，ATM only的branch，列出branch id和transcation amount （要去branch master data里去look up一下，对应“ATM only”的编号）
SELECT branch_id, SUM(COALESCE(amount,0))
FROM branch
LEFT JOIN transaction
ON branch.trans_id = transaction.trans_id
WHERE branch.xxx = 'ATM' and transaction.date BETWEEN xxxx AND xxxx
GROUP BY branch_id;
----------------------------------------------------------------------
studentID eventID date

Q1: 参与学生大于50 的event
SELECT event
FROM table
GROUP BY eventID
HAVING COUNT(distinct(studentID)) > 50;

Q2: 然后要列出这个event和所有参与的学生
SELECT event, studentID -------------------- distinct?
FROM table
WHERE event IN (
	SELECT event
	FROM table
	GROUP BY eventID
	HAVING COUNT(distinct(studentID)) > 50);
----------------------------------------------------------------------
purchase table
里面有id，purchase_date，price
Q1: year-to-date 的revenue 按purchase_date 划分
SELECT EXTRACT(YEAR FROM purchase_date), SUM(price)
FROM table
GROUP BY EXTRACT(YEAR FROM purchase_date);

flight的table，有depature city和 arrival city，求unique的不论顺序的 组合

比如 depature, arrival.
        A             B. 
        B             A
结果只出现 A B。


WITH NEW AS (SELECT depature, arrival FROM TABLE GROUP BY depature, arrival)
SELECT 


----------------------------------------------------------------------
from table a  (member_id, email_address)  to generate table b (member_id, email_1,email_2)
(第一题就是自己join自己 on member id 相等 email不等)

for example: 
table a
1,a
1,b
1,c. 
table b
1,a,b
1,a,c
1,b,c

SELECT B.member_id, A.email, B.email
FROM table A, table B
WHERE A.member_id = B.member_id
  AND A.email <> B.email;
------------------------------------------------------------------------
两道sql题，给了三个table，一个empt, 一个dept,一个empt_dept，然后让找出一个特定id的employee的部门名字.
SELECT dept.name 
FROM dept
INNER JOIN empt_dept
ON dept.dept_id = empt_dept.dept_id
INNER JOIN empt
ON empt.empt_id = empt_dept.empt_id
WHERE empt.empt_id = 1;

然后计算在这个部门有多少个active employee

SELECT COUNT(DISTINCT(empt_id)) 
FROM empt
INNER JOIN empt_dept
ON empt.empt_id = empt_dept.empt_id
WHERE empt_dept.dept_id = xxxxx;
--------------------------------------------------------------------------
第一道的table：
sales : product_id, quantity
products : product_id, name

Q1: output：name ，quantity
	SELECT name, CASE WHEN quantity IS NULL THEN 0 END AS final_quantity
	FROM sales
	RIGHT JOIN products
	ON sales.product_id = products.product_id;

第2道其他面经也出现了，不赘述了：
article_views: view_date, viewer_id, article_id, author_id



member_id, email_address
一个member 可能有2个email address
output：memeber id，email1，email2
WITH new_table AS (SELECT member_id, email_address, ROW_NUMBER() OVER(PARTITION BY member_id ORDER BY email_address))
SELECT member_id, a.email_address, b.email_address
FROM new_table a
LEFT JOIN (SELECT * FROM new_table WHERE ROW_NUMBER = 2) b 
ON a.member_id = b.member_id
WHERE a.ROW_NUMBER;
----------------------------------------------------------------
求具体某一天的friend request acceptance rate 
time | date | action | actor_uid | target_uid

----------------------------------------------------------------

Given table for purchase activity and signup event
Questions: for Weekly new users, whats:
Q1: The activation rate in the 1st week within signup time
Q2: Retention rate in the 1st 
Answers: left join, group by user and week, de-duplicat

SELECT SUM(CASE WHEN p.user_id IS NOT NULL THEN 1 ELSE 0)::float/COUNT(DISTINCT(s.user_id))
FROM signup s 
LEFT JOIN purchase p 
ON p.user_id = s.user_id 
WHERE purchase_date - s.date <=7
GROUP BY p.user_id s.user_id; 
--------------------------------------------------------------

两个table users and reviews，每个user为是否为禁止状态，是支付方还是接收方，每个review有支付方 接收方 日期 是否cancel。
输出：按日期分组，未被禁止的接收方的review的取消率
--------------------------------------------------------------

table 1
id, first_name, last_name,gender,D.O.B,hiring_time

table 2.
id, 2012_salary, 2013_salary,2014_salary (有nulls)

Q1: list the salary information for the male employees who were hired in 2014 in ascending order by employee last name
SELECT *
FROM table_2
INNER JOIN table_1
ON table_1.id = table_2.id
WHERE EXTRACT(YEAR FROM table_1.hiring_time) = 2014
  AND table_1.gender = 'MALE'
ORDER BY table_1.last_name;

Q2: point out one potential issue in the result of the query above?
--------------------------------------------------------------

一个广告table，每行primary key是时间和广告ID，列是timestamp，adsID，publisherID，还有广告价格
另一个table是该广告有多少人看见，多少人点击。列是timestamp，adsID，#views，#clicks 吧，
反正就是很基本的求某天某广告商的convertion rate------------------------------------->>>>>>>>>>????????????

SELECT CASE WHEN view IS NULL THEN 0 ELSE COUNT(clicks)::float/COUNT(views) END AS conversion_rate
FROM table_1 
LEFT JOIN table2
ON table_1.adsID = table_2.adsID 
AND EXTRACT(DATE FROM table_1.timestamp) = EXTRACT(DATE FROM table_2.timestamp)
WHERE EXTRACT(DATE FROM table_1.timestamp) = current_date
GROUP BY publisherID;

--------------------------------------------------------------------
id,  name
1,mike
2,mike
3,mike
4,peter
5,lily
返回所有可能的相同名字的id的组合（2个一组），output ： id_1,id_2,name

DROP TABLE IF EXISTS id_2;
CREATE TABLE id_2 (
	id int,
	name char(10)
);

INSERT INTO id_2 VALUES (1,'mike'),(2,'mike'),(3,'mike'),(4,'peter'),(5,'lily');

SELECT a.id, b.id, a.name
FROM id_2 a, id_2 b 
WHERE a.name = b.name
AND a.id <> b.id
AND a.id < b.id;

SELECT a.id, b.id, a.name
FROM id_2 a, id_2 b 
WHERE a.name = b.name
AND a.id <> b.id;

-- WHAT IF IT'S A B C

SELECT a.id, b.id, a.name
FROM id_2 a, id_2 b 
WHERE a.name = b.name
AND a.id <> b.id;

这个用到out join






/***************************************************************/


/*************** LINKEDIN 1 **************/ 
table1: campaigns
Account_id (AID) |Campaign_id (CID)
1 123
1 234
1 235

table2: Spend
Campaign_id(CID) | Date |Spend_amount|Currency
123 2017-08-01 200 USD

table3: Exchange_rate
Currency|Rate (to USD)
CAD 0.79
USD 1.00

Q1: CID, Total spend in USD
	SELECT spend.CID, sum(Spend.currency*Exchange_rate.Rate) 
	FROM Spend 
	JOIN Exchange_rate
	ON Spend.Currency = Exchange_rate.Currency
	GROUP BY spend.CID;

Q2 (need to work on the answer): 
AID, number of days from first spend date to highest spend date
	SELECT C.CID, DATEDIFF(S.max_spend_date, MIN())
	FROM campaigns C left join 
		(
		SELECT CID, max_spend_date FROM Spend
			WHERE Spend_amount  IN (
				SELECT MAX(Spend_amount) OVER (partition by CID) max_spend_date FROM Spend
				)
		) S AND campaings JOIN Spend
		ON C.CID =S.CID;

Q3: Given a daily login table showing when users logged in each day, figure out the number of customers that logged in two days in a row.

login_table: date|user_id|


SELECT count(distinct l1.user_id)
FROM login_table l1  JOIN login_table l2 on l1.date(date)-1 = l2.date(date)
	WHERE l1.user_id = l2.user_id;


/*************** LINKEDIN 2 **************/ 
table name: article_views
date|viewer_id|article_id|author_id
2017-08-01 123 345 789
2017-08-02 432 543 654


Q1: how many articles authors have never viewed their own article?

SELECT count(distinct author_id)
FROM article_views
	WHERE author_id not IN ( 
		SELECT a.author_id
		FROM article_views a WHERE a.author_id = a.viewer_id); 

R code:
library(dplyr)

data_selected <- data[which (data$author_id == data$viewer_id),]
author_id_to_delete <- unique(data_selected$author_id). 1point3acres.com/bbs
result <- data$author_id[which (data$author_id not in author_id_to_delete),]
print result



Q1: how many members viewed more than one article on 2017-08-01?
SELECT COUNT(distinct viewer_id)
FROM article_views
	WHERE date = "2017-08-01"
	GROUP BY viewer_id
	HAVING count(distinct article_id) >1;


/*************** LINKEDIN 3 **************/ 
3. userid|timestamp|product_group

Q1: how to analyze product diversity


/*************** LINKEDIN 4 **************/ 
4. world: continent|country|population
Q1 find the country with largest population in each continent, with strictly output: continent, country, population. and sort by population in descending order. Consider corner case that two country have same largest population in the same continent. write SQL

a. use window function
SELECT continent, country, max(population) over (partition by coninent) FROM table

b. 

SELECT x.continent, x.country, x.population
FROM world x
WHERE x.population > all (
				SELECT y.population FROM world y
				WHERE y.continent = x.continent
				AND population >0)

c. 

SELECT w.continent, w.country, w.population
FROM world w
	INNER JOIN 
	(
		SELECT continent, max(population) max_pop
		FROM world
		GROUP BY continent
	) m
	WHERE w.continent = m.continent AND w.population = m.max_pop
ORDER BY population DESC;


R code:
1. largest_country <- world %>%
group_by(continent) %>%
mutate(max_pop = max(population)) %>%
inner_join (world, by = c("max_pop", "population")) %>%
select(continent, country, max_pop)





Q2. now for each continent, find the country with largest % of populaiton in given continent. write SQL, then write Python.

SELECT w.continent, w.country, m.max_pop, concat((m.max_pop/m.total_pop)*100, %)
FROM world w
	INNER JOIN 
	(
		SELECT continent, max(population) max_pop, sum(population) total_pop 
		FROM world
		GROUP BY continent
	) m
	WHERE w.continent = m.continent AND w.population = m.max_pop


/*************** LINKEDIN 1 **************/ 
6. table member_id|company_name|year_start
Q1: count members who ever moved from Microsoft to Google?

SELECT count(distinct t1.member_id)
FROM table t1  join table t2 on t1.member_id = t2.member_id
WHERE t1.year_start < t2.year_start
AND t1.company_name = "microsoft" AND t2.company_name ="google"; 

R:

count <- inner_join(table, table, by="member_id") %>%
filter(year_start.x < year_start.y) %>%
filter(company_name.x ="microsoft") %>%
filter(compnay_name.y ="google") %>%
summarise(count =n())

print count


Q2:  count members who directly moved from Microsoft to Google? (Microsoft -- Linkedin -- Google doesn't count)

SQL: 

SELECT COUNT(DISTINCT member_id)
FROM 
	(SELECT t1.member_id member_id, t1.company, company1, t1.start_year startyear1, t2.company company2, t2.start_year startyear2
	FROM table t1 join table t2 
	GROUP BY t1.member_id
	HAVING count(t1.member_id) = 4) l
	WHERE l1.startyear1 <l1.startyear2
	AND t1.company_name = "microsoft" AND t2.company_name ="google"; 

/*************** LINKEDIN 1 **************/ 
7. table
customer | product | amount 
1         A          x1
1         B          x2
1         C          x3
2         A          y1
2         B          y2
2         C          y3
3         A          z1
3         B          z2
3         C          z3

如何输出table,每行 customer, product.A, poduct.B, product.C
                    1        x1          x2          x3

SELECT customer
	SUM(CASE product WHEN 'A' THEN amount ELSE 0) as product.A,
	SUM(CASE product WHEN 'B' THEN amount ELSE 0) as product.B,
	SUM(CASE product WHEN 'C' THEN amount ELSE 0) as product.C
FROM table
GROUP BY customer; 


---------------
给我一个用户记录的表。 
日期， 用户名， 活动 （登录）  
设计一个日/周/月积极用户的表。  
但即使 扫30 天的数据也很多 。   
我使用 一个sql 把3个梳子算出来。 
但也需要30 天的书据。 
最后他提示设计一个每天用户最后哪天登陆。   最后突然来个里口起吧。






---------------
问题是FB在某邮件注册以后会选择短信验证，只有短信验证了才能使用，这样有两个table：

email table: time, user_id, email_id; 
text  table: time, user_id, text_id, action(验证or没有验证）

Q1: 每天大概有多少注册邮件
SELECT COUNT(*)/COUNT(DISTINCT(EXTRACT(DATE FROM TIME))) as daily_em_cnt FROM email;

Q2: 注册的人大概有多少通过了短信验证
SELECT COUNT(DISTINCT(user_id)) as passed FROM text WHERE action = 'YZ';

Q3: 有多少人注册当天没有验证成功，第二天才验证成功
SELECT COUNT(distinct(email.user_id)) as next_day_pass
FROM email
INNER JOIN text 
ON email.user_id = text.user_id
WHERE DATEDIFF(email.time,text.time) = 1
AND action = 'YZ';


Q4: 可能还有一问是平均注册到验证大概有多少时间。






-----------------

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

-- NL
-- based on LZ's answer => multiple comments have same target_id = original content_ids
-- don't forget 0 comment

SELECT CASE WHEN num_comment IS NULL THEN 0 ELSE num_comment END AS num_comm, COUNT(*) as num_post
FROM
(
	SELECT distinct(content_id), num_comment
	FROM content_actions as act
	LEFT JOIN
		(SELECT target_id, COUNT(*) as num_comment FROM content_actions WHERE target_id IS NOT NULL GROUP BY target_id) AS A
	ON act.content_id = A.target_id
	WHERE act.target_id IS NULL
	) AS B
GROUP BY num_comment;

3. How to get the nick name of each facebook user suach david - dave , and if we already have the data how can we use it?
	1). post/comment the first word that friends typed other than "hi", "hello", "okay", "yes" etc. Check the frequency of those words, and the one with high frequency could be user's nick name
	2). user profile:
	   a.about you: I'm, I am, my name is, call me xx  if that one is not the same as the user name,
	   b.other names
	3). name and frequent nick names mapping



drop table if exists joins_test;
create table joins_test  (id_1 int, id_2 int);
insert into joins_test values (1,10),(1,11),(1,10),(2,10),(2,11);

select * from joins_test;
-- TEST 1 => dups = 13 = 9+2
select * from joins_test a
inner join joins_test b
on a.id_1 = b.id_1;

select COUNT(a.id_1) from joins_test a
right join joins_test b
on a.id_1 = b.id_1;

-- TEST 2 => dups
select * from joins_test a
right join (select * from joins_test where id_1 = 1) b
on a.id_1 = b.id_1;

-- TEST 3 => if you want to dup then don't merge dups with dups
select * from joins_test a
left join (select distinct(id_1) from joins_test) b
on a.id_1 = b.id_1;







country | duration(s)






