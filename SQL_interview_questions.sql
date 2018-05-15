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



AFFIRM 有两张的table(一个月一张)，key是account num，变量account type(check or save or save+check三类), date（by day）
有几问，前面都是简单的groupby orderby算一下三类account有多少人，只记得最后的一问是 要join变成一个table，如果前一个月有 后一个月cancel了account就显示null；如果前一个月没有，后一个月有, 则无法track 不能显示null。我好像用case when和full outer join解决了。

FB 三个instagram table, 体育明星和体育项目，然后求每个体育项目的followe
t1(user_name, sports_category)------------ t1中只有celebrity运动员。pk=user_name
t2(user_id, user_name, registration_date)----------t2中是所有人的用户信息，包括celebrity和普通人，且不会出现celebrity和普通人重名的情况（重要假设）。pk=user_id-google 1point3acres
t3(user_id, user_id_following, follow_date)----用户follow信息，注意user_id_following中包括celebrity和普通人
计算每个category有多少人follow

sql 是那道instagram的题

Table A stars category
user_name, star category

Table B instagram users
id, user_name

Table C followee/followers
id, id_following

Q: how many people are following each star category?. 1point3acres.com/bbs
这里要注意第三个table 是followees 是id; followers是id_following
也就是join这table 2 和3 应该是用B.id = C.id_following
还要考虑是否用left join还是inner join
楼主是很久没面试 然后刚准备跳槽 第一次面就当是有些慌张. 鍥

FB sql + stats，sql大概是给了userid1, userid2, friend/unfriend, time_stamp，问目前为止还是friend的userid, stats有考 p-value definition, confidence interval, conditional probability


sql, 见过的题目，表格如下：
|user_id|question_id|question_order||action|timestamp|
action: saw, answered, skip
1) get the highest answer rate question . 
2) how to dynamically change the order of the questions showing to the users: 也就是用户如果回答或者跳过了一个问题，那么下一个问题应该如何分配给user，来优化用户回答问题的概率


sql四张表
product: pruduct_id, brand_id, class_id, .... . Waral 鍗氬鏈夋洿澶氭枃绔�,
customers: customer_id, state, ... 
sales: product_id, customer_id, product_id, sales_amount, price....
stores: store_id, .....

问题和地理之前的有差别，但是核心内容是一样的GROUP BY, INNER JOIN, OUTER JOIN, Condition Statements. 建议先把地里已出现的题目刷一遍，绝对够bar了


----------
给了4个table：
products（product_id, product_class_id, brand_name, price)
sales(product_id, promotion_id, cutomer_id, total_sales)
customer(customer_id, ...)
还有一个忘记了。。
好像问了3个问题（失忆了）：
前两个问题只用一个table group by，order by就能出结果
第三题是问买过productA and productB的所有customer。我这题用了两个join，感觉写的有点长，应该有更好的写法，但一时没想起来。
小哥让我想想如果product多于两个，比如五个，应该怎么写。

----------
就是一个customer table, 一个viewtable,  然后join 啊。 问多少account id viewing大于3个小时。 
又是草泥马。 就是有个tricky  地方， join 的时候有些accountid, 虽然signup 了但是没有view,所以没有在customertable 出现。 
是null 的。 这个被问了， 当时还不知道出什么问题了 。 不过后来也是解决了。


----------
sql两道，中间一个tiny错误，提前十分钟写完，地里的题目想透就行，什么friend request这种经常要两个col换个顺序然后union，然后sum case when和ifnull注意就行
---------
SQL两道，一道返回每个学生的最高分，重复按course id。。另一道算running total

-----------
date | user_num,
注意date 是每天的date。 问如何找到top 100 week over week increaser/dropper.
他提示我先找到每周的人数，然后再找diff。 
然而我不知道如何在sql中从date==>week, 他就让我assume 有一个方程可以得到week number。 
于是我写了一个类似group by 的。 在sql中我不知道怎么求diff。于是我果断问他能不能用r，基本用dplyr， magritte里的语句轻松解了。 



-----------
sql: 给了个table:，明星 id, 明星 category (baseball start, basket ball star)，follower_id 求哪个明星category有多少follower 
-----------
表名：survey_log 
列名：user_id, question_id, question_order, event = {imp, answered, skipped}, timestamp，

Q1: 找conversion rate (answer rate) 最高的question

SELECT question_id, COUNT(CASE WHEN event = 'answered' THEN 1 ELSE 0 END)/COUNT(question_id) as conversion_rate
FROM survey_log
GROUP BY question_id
ORDER BY COUNT(CASE WHEN event = 'answered' THEN 1 ELSE 0 END)/COUNT(question_id) DESC
LIMIT 1;

Q2: 在用户已经回答了某一问题的情况下，如何安排下一问题使conversion rate最高，我这里就按地里讨论的一样说在已经回答了这一问题的用户中，选他们回答的其余问题里回答率最高的一个





--------------
sort按照字母规律，不过要求先把S排在最前

drop table if exists sort_test;
create table sort_test (index text);
insert into sort_test VALUES ('a');
insert into sort_test VALUES ('b');
insert into sort_test VALUES ('s');
insert into sort_test VALUES ('S');


SELECT *
FROM sort_test
ORDER BY CASE WHEN index in ('S','s') THEN 0 ELSE 1 END, index;

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































