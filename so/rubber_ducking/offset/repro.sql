use [master]
drop database if exists dbase;
create database dbase; 
alter authorization on database ::dbase to sa;
go
use dbase
drop table if exists foo;
go
create table dbo.foo (
     id bigint not null
    ,xx int 
        index cx clustered
    ,a  uniqueidentifier not null
    ,b  bigint 
    ,c  varchar(50) 
    ,d  bigint 
    ,e  nvarchar(25) 
    ,index nci (d, xx)
);
go
bulk insert foo
from 'c:\temp\bcp.csv'
with(firstrow       = 2
    ,rowterminator  = '\n'
    ,fieldterminator= ','
);
go
create or alter proc dbo.bar 
     @d      bigint 
    ,@xx1    int 
    ,@xx2    int
    ,@offset int
    ,@next   int
    ,@e      nvarchar(50) 
with recompile 
as 
set transaction isolation level read uncommitted;
set nocount on;
-- declare @d bigint = 0 , @xx1 int = 40664, @xx2 int = 41308, @offset int=0, @next int=100, @e nvarchar(50) = N'abcdef012';
with cte as (
	select
        cl.id,
        cl.xx
    from foo cl
    where cl.xx >= @xx1 
		and cl.xx < @xx2
		and cl.d = @d 
		and cl.e = @e
    order by cl.xx desc
    offset @offset rows fetch next @next rows only
)
select * 
from cte
option (use hint('enable_parallel_plan_preference'));
go
declare @d bigint = 0 , @xx1 int = 40664, @xx2 int = 41308, @offset int=0, @next int=100, @e nvarchar(50) = N'abcdef012';
exec bar @d, @xx1, @xx2, @offset, @next, @e;
go
