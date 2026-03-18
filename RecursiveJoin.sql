/***
本段代码使用递归添加员工表中的reporting line和对应员工的职级
**/
-- 创建表
CREATE TABLE  Employees (
    employee_id INT,
    employee_name VARCHAR(100),
    manager_id INT,
    salary INT,
    department VARCHAR(50)
)

  -- 插入测试数据
Truncate table Employees
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('1', 'Alice', NULL, '12000', 'Executive')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('2', 'Bob', '1', '10000', 'Sales')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('3', 'Charlie', '1', '10000', 'Engineering')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('4', 'David', '2', '7500', 'Sales')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('5', 'Eva', '2', '7500', 'Sales')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('6', 'Frank', '3', '9000', 'Engineering')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('7', 'Grace', '3', '8500', 'Engineering')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('8', 'Hank', '4', '6000', 'Sales')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('9', 'Ivy', '6', '7000', 'Engineering')
insert into Employees (employee_id, employee_name, manager_id, salary, department) values ('10', 'Judy', '6', '7000', 'Engineering')

-- 使用递归完成reporting line和employee level字段的创建

WITH cte
     AS (SELECT [employee_id],
                [employee_name],
                [manager_id],
                [salary],
                [department],
                1
                AS
                lvl,
                [employee_name]
                AS
                    emp_lvl_1,
                Cast(NULL AS VARCHAR(100))
                AS
                    emp_lvl_2,
                Cast(NULL AS VARCHAR(100))
                AS
                    emp_lvl_3,
                Cast(NULL AS VARCHAR(100))
                AS
                    emp_lvl_4,
                Cast('' + Cast([employee_id] AS VARCHAR) + '|' AS VARCHAR(250))
                    reportting_line
         FROM   [WORKING].[dbo].[employees]
         WHERE  [manager_id] IS NULL
         UNION ALL
         SELECT e.[employee_id],
                e.[employee_name],
                e.[manager_id],
                e.[salary],
                e.[department],
                emp.lvl + 1                                                   AS
                lvl,
                CASE
                  WHEN emp.lvl = 1 THEN emp.[employee_name]
                  ELSE emp_lvl_1
                END                                                           AS
                emp_lvl_1,
                CASE
                  WHEN emp.lvl = 1 THEN e.[employee_name]
                  ELSE emp.emp_lvl_2
                END                                                           AS
                emp_lvl_2,
                CASE
                  WHEN emp.lvl = 2 THEN e.[employee_name]
                  ELSE emp.emp_lvl_3
                END                                                           AS
                emp_lvl_3,
                CASE
                  WHEN emp.lvl = 3 THEN e.[employee_name]
                  ELSE emp.emp_lvl_4
                END                                                           AS
                emp_lvl_4,
                Cast(emp.reportting_line + '|'
                     + Cast(e.[employee_id] AS VARCHAR) + '' AS VARCHAR(250)) AS
                reportting_line
         FROM   cte emp
                JOIN [WORKING].[dbo].[employees] e
                  ON emp.[employee_id] = e.[manager_id])
SELECT *
FROM   cte 


/**
employee_id	employee_name	manager_id	salary	department	lvl	emp_lvl_1	emp_lvl_2	emp_lvl_3	emp_lvl_4	reportting_line
1	Alice	NULL	12000	Executive	1	Alice	NULL	NULL	NULL	1|
2	Bob	1	10000	Sales	2	Alice	Bob	NULL	NULL	1||2
3	Charlie	1	10000	Engineering	2	Alice	Charlie	NULL	NULL	1||3
6	Frank	3	9000	Engineering	3	Alice	Charlie	Frank	NULL	1||3|6
7	Grace	3	8500	Engineering	3	Alice	Charlie	Grace	NULL	1||3|7
9	Ivy	6	7000	Engineering	4	Alice	Charlie	Frank	Ivy	1||3|6|9
10	Judy	6	7000	Engineering	4	Alice	Charlie	Frank	Judy	1||3|6|10
4	David	2	7500	Sales	3	Alice	Bob	David	NULL	1||2|4
5	Eva	2	7500	Sales	3	Alice	Bob	Eva	NULL	1||2|5
8	Hank	4	6000	Sales	4	Alice	Bob	David	Hank	1||2|4|8
*/
