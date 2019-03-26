-- https://dba.stackexchange.com/questions/232969

use [master]
go
drop database if exists burp;
create database burp;
alter authorization on database ::burp to sa;
alter database burp set query_store = on;
go
use burp;
drop table if exists bing;
create table bing (
     id int identity 
        constraint pk_bing primary key clustered
    ,bong uniqueidentifier not null 
        constraint ak_bing_bong unique
        constraint df_bing_bong default newid() 
    ,bork datetime2(0) not null 
        constraint df_bing_bork default getdate() 
);
set nocount on;
go
insert bing default values
go 10000
create or alter proc foo 
    @id int
as
select *
from bing 
where id = @id;
go
create or alter proc bar 
    @id int 
as
select *
-- comment 1
from bing 
where id = @id;
go
exec foo 1;
exec bar 1;
go
dbcc freeproccache
alter database burp set query_store clear;
go
declare @id int = abs(checksum(newid()))%21000;
exec foo @id;
go 1000
declare @id int = abs(checksum(newid()))%21000;
exec bar @id;
go 1000

--select * from sys.query_store_plan
select * from sys.query_store_query
select * from sys.query_context_settings


;with dupes as (
    select query_plan_hash, count(*) cs
    from sys.query_store_plan
    group by query_plan_hash
    having count(*) > 1
)
select 
     d.cs
    ,qsp.query_plan_hash
    --,qsp.query_plan 
    ,qsp.query_id
    ,qt.query_sql_text
    ,obj_name = object_schema_name(qsq.[object_id]) + '.' + object_name(qsq.[object_id])
from sys.query_store_plan qsp
join dupes d on d.query_plan_hash = qsp.query_plan_hash
join sys.query_store_query qsq on qsq.query_id = qsp.query_id
join sys.query_store_query_text qt on qt.query_text_id = qsq.query_text_id
where qsq.[object_id] <> 0;
go
use [master]
go
drop database if exists burp;
go
