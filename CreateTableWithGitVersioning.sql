use <DbName,,>
go
-- select * from <schemaName,,dbo>.<tableName,,>;

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'<schemaName,,dbo>.<tableName,,>' ) and 
				[type] in ( N'U' ) )
begin
	set nocount on;
	
	select * 
	into #DropNpop_<schemaName,,dbo><tableName,,>
	from <schemaName,,dbo>.<tableName,,>;

	drop table <schemaName,,dbo>.<tableName,,>;
	print 'Dropped table <schemaName,,dbo>.<tableName,,> SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 );
end;
go

create table <schemaName,,dbo>.<tableName,,>
(
	
	InsertedBy varchar( 100 ) not null,
	InsertDatetime datetime not null,
	LastUpdateBy varchar( 100 ) not null,
	LastUpdateDatetime datetime not null,
	Revision int not null,
	constraint pk_<tableName,,>_ primary key (  )
);

go

alter table <schemaName,,dbo>.<tableName,,> add constraint df_<tableName,,>_InsertedBy default replace( system_user, 'GRCORP\', '' ) for InsertedBy;
alter table <schemaName,,dbo>.<tableName,,> add constraint df_<tableName,,>_InsertDatetime default getdate() for InsertDatetime;
alter table <schemaName,,dbo>.<tableName,,> add constraint df_<tableName,,>_LastUpdateBy default replace( system_user, 'GRCORP\', '' ) for LastUpdateBy;
alter table <schemaName,,dbo>.<tableName,,> add constraint df_<tableName,,>_LastUpdateDatetime default getdate() for LastUpdateDatetime;
alter table <schemaName,,dbo>.<tableName,,> add constraint df_<tableName,,>_Revision default 0 for Revision;

go

if object_id( N'tempdb..#DropNpop_<schemaName,,dbo><tableName,,>' ) is not null
begin

	-- set identity_insert <schemaName,,dbo>.<tableName,,> on;

	declare @sql nvarchar( max ) = ''; 

	select @sql += 
		quotename( c1.name ) + ',' 
	from sys.columns c1
	join tempdb.sys.columns c2 on 
		c2.name = c1.name and
		c2.[object_id] = object_id( N'tempdb..#DropNpop_<schemaName,,dbo><tableName,,>' )
	where c1.[object_id] = object_id( N'<schemaName,,dbo>.<tableName,,>' ) and 
		c1.is_computed = 0;

	set @sql = left( @sql, len( @sql ) - 1 );
		
	set @sql = 
	'insert <schemaName,,dbo>.<tableName,,> 
		(' + @sql + ') 
	select 
		' + @sql + '
	from #DropNpop_<schemaName,,dbo><tableName,,>;';

	exec sp_executesql @sql;

	-- set identity_insert <schemaName,,dbo>.<tableName,,> off;

end;
	
go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'<schemaName,,dbo>.<tableName,,>' ) and 
				[type] in ( N'U' ) )
begin
	print 'Created table <schemaName,,dbo>.<tableName,,> SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 );
end;

go

create trigger tr_<tableName,,>_LogLastUpdate 
on <schemaName,,dbo>.<tableName,,>
<TriggerWhen,,after> <TriggerWhat,,update>
as
/* who				when			what
<Creator,,petervandivier>		<CreateDate,,>	<Description,,TRIGGER to log update revisions>
*/
begin
	set nocount on;
	
	update <schemaName,,dbo>.<tableName,,> set 
		LastUpdateBy = replace( system_user, 'GRCORP\', '' ),
		LastUpdateDatetime = getdate(),
		Revision += 1
	from <schemaName,,dbo>.<tableName,,> a
	join inserted b on a.<PK,,> = b.<PK,,>;
end;
go
