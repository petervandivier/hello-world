use <DbName,,>
go
-- select * from <schemaName,,dbo>.<tableName,,>;
-- drop table <schemaName,,dbo>.<tableName,,>;
-- truncate table <schemaName,,dbo>.<tableName,,>;

-- select * from sys.foreign_keys fk where fk.referenced_object_id = object_id(N'<schemaName,,dbo>.<tableName,,>');
-- script these as DROP-AND-CREATE-TO and copy-pasta here

go


if object_id(N'<schemaName,,dbo>.<tableName,,>','U') is not null
begin
	set nocount on;
	
-- set this to a local table instead of a #temp_table for post-deploy audit
	select * 
	into #dropNpop_<schemaName,,dbo><tableName,,>
	from <schemaName,,dbo>.<tableName,,>;

	drop table <schemaName,,dbo>.<tableName,,>;
-- drop table if exists N'<schemaName,,dbo>.<tableName,,>';
	print 'dropped table <schemaName,,dbo>.<tableName,,> SUCCESSFULLY! At time ' + convert(varchar,getdate(),126);
end;
go

create table <schemaName,,dbo>.<tableName,,> (
	constraint pk_<tableName,,>_Id primary key ( Id ),
	Id int not null identity,
	[Name] varchar( 100 ) not null constraint chk_<tableName,,>_NameIsNotEmpty check (datalength(ltrim(rtrim([Name])))>0),
	
	InsertBy varchar( 100 ) not null constraint df_<tableName,,>_InsertBy default system_user,
	InsertDT datetime not null constraint df_<tableName,,>_InsertDT default getdate(),
	UpdateBy varchar( 100 ) not null constraint df_<tableName,,>_UpdateBy default system_user,
	UpdateDT datetime not null constraint df_<tableName,,>_UpdateDT default getdate(),
	Revision int not null constraint df_<tableName,,>_Revision default 0	
);

go

alter table <schemaName,,dbo>.<tableName,,> 
	add constraint ak_<tableName,,>_Name unique ( [Name] );

go

-- The below may function improperly if column names/datatypes/other metadata is altered
-- It functions best for column addition or deletion from source code
if object_id( N'tempdb..#dropNpop_<schemaName,,dbo><tableName,,>','U' ) is not null
begin
	<HasId,default "no",-- >set identity_insert <schemaName,,dbo>.<tableName,,> on;

	declare @sql nvarchar(max) = ''; 

	select @sql += 
		quotename( c1.[name] ) + ',' 
	from sys.columns c1
	join tempdb.sys.columns c2 on 
		c2.[name] = c1.[name] and
		c2.[object_id] = object_id(N'tempdb..#dropNpop_<schemaName,,dbo><tableName,,>')
	where c1.[object_id] = object_id(N'<schemaName,,dbo>.<tableName,,>') and 
		c1.is_computed = 0;

	set @sql = left( @sql, len( @sql ) - 1 ); -- trim last comma
		
	set @sql = 
	'insert <schemaName,,dbo>.<tableName,,> 
		(' + @sql + ') 
	select 
		' + @sql + '
	from #dropNpop_<schemaName,,dbo><tableName,,>;';

	--print @sql;
	exec sp_executesql @sql;

	print convert(varchar,@@rowcount) + ' row(s) loaded into <schemaName,,dbo><tableName,,>.';

	<HasId,default "no",-- > set identity_insert <schemaName,,dbo>.<tableName,,> off;
end;

go

if object_id(N'<schemaName,,dbo>.<tableName,,>','U') is not null
	print 'created table <schemaName,,dbo>.<tableName,,> SUCCESSFULLY! At time ' + convert(varchar,getdate(),126);
go

