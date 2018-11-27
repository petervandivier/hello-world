# Non-determinisitic Sort & repeatable behavior in parallel plans
$sql-server $parallelism $internals

## Summary

Using `OFFSET ... NEXT` over a non-unique sort column results in predictable & repeatable variance under different execution context in the presence of of parallelism. Why does this behavior occur and is there a productive inference that can be made about the optimizer based on this behavior?

## Background

I received a support ticket of the form...

> Hi! I'm regenerating some financial statements for `$time_period` and getting inconsistent results. When I execute `$stored_procedure`, I get $100; but when I run the `$ad-hoc-code` found _inside_ the SP with the same parameters, I get $200. What gives? 

Reviewing the underlying proc, I observed that it was paginating results by sorting on a non-unique column. In reproducing & minifying the behavior, I found the following attributes consistently induce a `ScanDirection="BACKWARD"` for a **STORED-PROC EXECUTION** and a `ScanDirection="FORWARD"` for an **AD-HOC F5**. 
* Non-unique clustered index
* With a non-clustered index
* In a parallel plan
* With sufficient padding data

## [Reproduction][gist-repro]

<sup>[Also available as a `.bak` file][dot-bak-file]</sup>

```sql
use [master]
drop database if exists offset_repro;
create database offset_repro; 
alter authorization on database ::offset_repro to sa;
go
use offset_repro
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
with(firstrow=2
    ,rowterminator='\n'
    ,fieldterminator=',');
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
		and cl.xx < 1
		and cl.d = @d 
		and cl.e = @e
    order by cl.xx desc
    offset @offset rows fetch next @next rows only
)
select * 
from cte
option (use hint('enable_parallel_plan_preference'));
go
```

## Other Trivia

1. "_In the wild_", column `[xx]` was a `datetime2(7)` column (presumably some enterprising dev thought clustering in this was was equivalent to uniqueness). I modified it to `int` for readability while minifying the repro
2. 

[ptp-STORED_PROC]: www.foo.bar
[ptp-AD_HOC_F5]: www.foo.bar
[gist-repro]: www.foo.bar 
[dot-bak-file]: www.foo.bar



