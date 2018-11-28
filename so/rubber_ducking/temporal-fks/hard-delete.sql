use [master]
go
exec xp_cmdshell 'powershell.exe Remove-DbaDatabase -ServerInstance "." -Database "fk" -Confirm:0';
go
create database fk;
alter authorization on database ::fk to sa; 
go
use fk
go
drop table if exists dbo.auth, dbo.auth_hist;
go
create table dbo.auth_now ( 
     id int not null identity primary key nonclustered
    ,[key] uniqueidentifier not null unique default newid()
    ,[user_id] int not null default 0 -- constraint fk_auth_users references [user].id 
    ,start_dt datetime2(0) not null
    ,end_dt datetime2(0) not null
        check (end_dt = convert(datetime2(0),'9999-12-31 23:59:59'))
);
go
create table dbo.auth_hist ( 
     id int not null 
    ,[key] uniqueidentifier not null unique 
    ,[user_id] int not null default 0 -- constraint fk_auth_users references [user].id 
    ,start_dt datetime2(0) not null
    ,end_dt datetime2(0) not null
);
go
alter table dbo.auth_now
    add period for system_time (start_dt, end_dt);
go
alter table dbo.auth_now
    set (system_versioning = on (history_table = dbo.a_history));
go
create or alter view dbo.auth_all
with schemabinding
as
select 
     id
    ,[key]
    ,[user_id]
    ,start_dt
    ,end_dt
from dbo.auth_now 
    -- for system_time all;
union all
select 
     id
    ,[key]
    ,[user_id]
    ,start_dt
    ,end_dt
from dbo.auth_hist 
go
create unique clustered index pk_auth_all_key
    on dbo.auth_all ([key]);
go
create view dbo.auth
as 
select * 
from dbo.auth_now
go
insert auth default values
go 4
delete dbo.auth where id = 1
go
--select * from auth
go
if object_id('dbo.foo','U') is not null
    alter table dbo.foo set (system_versioning = off);
go
drop table if exists dbo.foo_hist,dbo.foo;
go
create table dbo.foo ( 
     id int identity primary key 
    ,info varchar(100)
    ,auth_id int not null 
        foreign key references dbo.auth_now(id)
    ,start_dt datetime2(0) generated always as row start hidden
    ,end_dt   datetime2(0) generated always as row end hidden
    ,period for system_time (start_dt, end_dt)
) with (system_versioning = on (history_table = dbo.foo_hist));
go
insert foo (info, auth_id)
values 
 ('aaa',2)
,('bbb',3)
go
/*
insert foo (info, auth_id) values ('ccc',1); -- fails for fk
go
delete auth where id = 2 -- fails for fk
go
*/
go
update foo set info = 'fff', auth_id = 4 where id = 1 
go
update auth set is_exp = 1 where id = 3;
go
update foo set info = 'ggg' where id = 2 -- SHOULD fail for expired auth, sadly does not... :'(
go
select dbo.is_auth_id_valid(auth_id), * from foo
go
select * from foo 
select * from auth
go
