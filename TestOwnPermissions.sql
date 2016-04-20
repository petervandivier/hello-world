use DBAdmin
go

create table dbo.PV
(
	id int identity,
	abc char( 3 )
);
go

insert dbo.PV ( abc )
select 'aaa' as abc;

go

select * from dbo.PV;

go

update dbo.PV set abc = 'abc';

go

alter table dbo.PV add def money default 100;
go

select * from dbo.PV;

go

drop table dbo.PV;

