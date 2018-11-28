use [master]
go
exec xp_cmdshell 'powershell.exe Remove-DbaDatabase -ServerInstance "." -Database "fk" -Confirm:0';
go
use [master]
go
create database fk;
alter authorization on database ::fk to sa; 
go
use fk
go
drop table if exists dbo.auth;
go
create table dbo.auth ( 
     id int identity primary key 
    ,[key] uniqueidentifier not null unique default newid()
    ,[user_id] int not null default 0 -- constraint fk_auth_users references [user].id 
    ,eff_dt datetime2(0) not null default dateadd(millisecond,1,getutcdate()) 
    ,is_exp bit not null default 0
    ,check ( dateadd(hour,1,eff_dt) > getutcdate()
            or is_exp = 1 )
);
go
insert dbo.auth default values
go 4
update dbo.auth set is_exp = 1 where id = 1
go
--select * from auth
go
create or alter function dbo.is_auth_id_valid (
    @id int
)
returns bit
as begin
    declare @is_valid bit = 0;

    select @is_valid = iif(is_exp = 0 
                           and dateadd(hour,1,eff_dt) > getutcdate()
                           ,1 
                           ,0 )
    from dbo.auth a
    where a.id = @id;

    return @is_valid;
end;
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
        foreign key references dbo.auth(id)
    ,check (dbo.is_auth_id_valid(auth_id) = 1)
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
insert foo (info, auth_id) values ('ccc',1); -- fails for check
go
insert foo (info, auth_id) values ('ddd',5); -- fails for check AND fk
go
update foo set info = 'eee', auth_id = 1 where id = 1 -- this fails for expired auth
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
