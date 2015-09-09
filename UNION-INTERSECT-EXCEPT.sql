declare @num1 int = 1;
declare @num2 int = 2;
declare @num3 int = 3;
declare @num4 int = 4;
declare @num5 int = 5;

declare @table1 table (numbers int);
declare @table2 table (numbers int);
declare @table3 table (numbers int);

insert into @table1 values
	(@num1),(@num2),(@num2),(@num3),(@num3);


insert into @table2 values
	(@num3),(@num4),(@num4),(@num3),(@num5);
	
--insert into @table3 values
--	(@num3),(@num5),(@num1),(@num1),(@num1);

--select * from @table1
--intersect
--select * from @table2
--intersect
--select * from @table3

select * from @table1
except
select * from @table2

select * from @table1
intersect
select * from @table2

select * from @table2
except
select * from @table1

select * from @table1
union
select * from @table2