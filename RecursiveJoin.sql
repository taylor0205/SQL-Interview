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

with emp as (	
	SELECT 
	   [employee_id]
      ,[employee_name]
      ,[manager_id]
      ,[salary]
      ,[department]
	  , 1 as lvl
	  , employee_name as lvl_1
	  , CAST(null as varchar(100)) as lvl_2
	  , CAST(null as varchar(100)) as lvl_3
	  , CAST(null as varchar(100)) as lvl_4
	  , CAST('' + cast([employee_name] as varchar)  as varchar(250)) as mgr_path
  FROM [WORKING].[dbo].[Employees]
  where manager_id is null

  union all

  	SELECT 
	   e.[employee_id]
      ,e.[employee_name]
      ,e.[manager_id]
      ,e.[salary]
      ,e.[department]
	  ,emp.lvl + 1 as lvl
	  , case when emp.lvl = 1 then emp.employee_name else emp.lvl_1 end as lvl_1
	  , case when emp.lvl = 1 then e.employee_name else emp.lvl_2 end as lv1_2
	  , case when emp.lvl = 2 then e.employee_name else emp.lvl_3 end as lvl_3
	  , case when emp.lvl = 3 then e.employee_name else emp.lvl_4 end as lvl_4
	  , CAST( emp.mgr_path + ' < ' + CAST( e.employee_name as varchar) + '' as varchar(250)) as mgr_path
	  from emp
	  join [WORKING].[dbo].[Employees] e on emp.employee_id = e.manager_id
)
select * from emp


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
