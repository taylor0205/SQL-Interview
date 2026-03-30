-- 计算出员工的下级数量以及团队的预算

with emp as (
SELECT [employee_id]
      ,[employee_name]
      ,[manager_id]
      ,[salary]
      ,[department]
	  , 1 as lvl
  FROM [WORKING].[dbo].[Employees]
  where manager_id is null

  union all

  SELECT 
       e.[employee_id]
      ,e.[employee_name]
      ,e.[manager_id]
      ,e.[salary]
      ,e.[department]
	   ,emp.lvl+ 1 as lvl
   from emp 
   join Employees e on e.manager_id = emp.[employee_id]
), team_members as 
(
select 
employee_id as manager_id,
employee_id,
salary
from Employees

union all

select 
a.manager_id,
b.employee_id,
b.salary
from team_members a 
join Employees b on b.manager_id = a.employee_id
), agg_data as (
select
	manager_id as employee_id,
	count(1) - 1 as team_size,
	sum(salary) as budget
from team_members
group by manager_id
)select 
a.employee_id,
a.employee_name,
a.lvl as level,
b.team_size,
b.budget
from emp a
join agg_data b on b.employee_id = a.employee_id
