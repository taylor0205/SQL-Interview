/**
题目1：基础查询与聚合
表结构：

orders 订单表：order_id (订单ID), user_id (用户ID), order_date (订单日期), amount (订单金额)

users 用户表：user_id (用户ID), name (用户名), reg_date (注册日期)

Q1：计算2023年每个月的总订单金额和每月新注册用户的首月总消费金额。
Q2: 找出每个用户消费金额排名前三的订单，并显示该订单的金额以及该用户的总消费金额。
**/







/**
题目2:
Q: 求用户连续到店购买天数以及与上次到店购买间隔天数
transactions: user_id, order_date
**/



/**
题目3:
Q1: 有一个学生成绩表（scores），包含以下字段：学生姓名（name）、课程（course）、成绩（score）。
请写出SQL语句，将每个学生的每门课程成绩转换为一行，即每个学生一行，每门课程作为一列。
*/



/**
题目4：
-- trade: country, tdate, ,amount, tstatus
Q1: 计算过去30天内，每个国家每日的支付成功率和平均交易金额
Q2: 连续3天都有交易的用户 

*/








/**
题目5：
给定两张表：sellers(seller_id, signup_date, country) 和 orders(order_id, seller_id, order_date, amount)

Q1: 计算“过去 30 天内首次下单的 seller 数量按国家分组”。
Q2: 计算卖家首单到第二单的平均时间间隔（天）
Q3: 统计每个国家过去 30 天订单总金额和环比增长
Q4: 找出销量排名前 3 的卖家（按最近 90 天订单金额）
Q5: 找出每天订单金额大幅波动的卖家（超过过去 7 天平均 ±50%）
Q6: 统计每个国家卖家数、活跃卖家比例（活跃定义：30 天内至少有 1 单）

*/

-- A1:

with first_orders as (
    select
    seller_id,
    min(order_date) as first_order_date
from orders
group by seller_id
)
select country,
       count(1) as seller_count
from sellers s 
join first_orders f on f.seller_id = s.seller_id
where first_order_date>= dateadd(day,-30,current())
group by country;

-- A2: 计算卖家首单到第二单的平均时间间隔（天）

with first_order as (
    select seller_id,
           order_date,
           min(order_date)over(partition by seller_id order by order_date) as first_order_date
    from orders
), second_orders as (
    select
    seller_id
    first_order_date,
    min(order_date) as second_order_date
from first_orders
where order_date > first_order_date

) select seller_id,
         avg(datediff(first_order_date,second_order_date)) as days_intv
        from second_orders
        group by seller_id;


with ranked as (
    select seller_id,
            order_date,
            row_number()over(partition by seller_id order by order_date) as rn
    from orders
)select r1.seller_id,
        avg(datediff(r2.order_date,r1.order_date)) as days_intv
from ranked r1
join rnaked r2 on r1.seller_id = r2.seller_id and r1.rk = 2 and r2.rk = 1
group by r1.seller_id


-- A3: 统计每个国家过去 30 天订单总金额和环比增长

with last_30_days_order as (
    select s.country,
           sum(amount) as total_amount
        from orders o 
    join sellers s s.seller_id = o.seller_id
    where order_date>= dateadd(day,30,current())
    group by s.country
), last_60_days_order as (
        select s.country,
           sum(amount) as total_amount
        from orders o 
        join sellers s s.seller_id = o.seller_id
    where order_date>= dateadd(day,60,current()) and order_date< dateadd(day,30,current()) 
        group by s.country
)
    select 
        country,
        sum(l1.total_amount) as last_30_amount,
        sum(l2.total_amount) as last_60_amount,
        (sum(l1.total_amount) - sum(l2.total_amount))/sum(l2.total_amount) as MoM
    from last_30_days_order l1
    left join last_60_days_order l2 on l1.country = l2.country
    
group by s.country
;

-- A4: 找出销量排名前 3 的卖家（按最近 90 天订单金额）
with salse_amount as (
    select seller_id,
    sum(amount) as total_amount
    from orders
    where order_date>=dateadd(day,-90,current())
    group by seller_id
), salse_rank as (
    select seller_id,
    dense_rank(total_amount)over(order by total_amount desc) as rk
    from salse_amount
)select
    seller_id
from salse_rank
where rn<=3
;


-- A5: 找出每天订单金额大幅波动的卖家（超过过去 7 天平均 ±50%）

with daily_amount as (
    select
    seller_id,
    order_date,
    sum(amount) as amount
from orders
group by seller_id, order_date
), avg_7_amount as (
    select seller_id,
            avg(amount) as amount
    from daily_amount
    where order_date>= dateadd(day,-7,current())
) select seller_id
from daily_amount d 
join avg_7_amount a on a.seller_id = d.seller_id and ( d.amount>= (a.amount*1.5) or d.amount<=(a.amount*0.5))
;

-- A6: 统计每个国家卖家数、活跃卖家比例（活跃定义：30 天内至少有 1 单）

with active_seller as (
    select distinct seller_id from orders
    where order_date>= dateadd(day,-30,current())
), result as (
    select
    s.country,
    count(1) as total_sellers,
    sum(case when a.seller_id is not null then 1 else 0 end ) as active_count
from sellers s 
left join active_seller a on a.seller_id = s.seller_id
group by s.country
) select country,
        total_sellers,
        round(active_count/total_sellers,2) as active_rate
    from result
