use <DbName,,>
go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'<schemaName,,>.<tableName,,>' ) and 
				[type] in ( N'U' ) )
begin
	drop table <tableName,,> ;
	print 'Dropped table <schemaName,,>.<tableName,,> SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go

create table <schemaName,,>.<tableName,,>
(
	
	InsertedBy varchar( 100 ) not null,
	InsertDatetime datetime not null,
	LastUpdateBy varchar( 100 ) not null,
	LastUpdateDatetime datetime not null,
	Revision int not null,
	constraint pk_<tableName,,>_ primary key (  )
);

go

alter table <schemaName,,>.<tableName,,> add constraint df_<tableName,,>_InsertedBy default replace( user, 'GRCORP\', '' ) for InsertedBy ;
alter table <schemaName,,>.<tableName,,> add constraint df_<tableName,,>_InsertDatetime default getdate() for InsertDatetime ;
alter table <schemaName,,>.<tableName,,> add constraint df_<tableName,,>_LastUpdateBy default replace( user, 'GRCORP\', '' ) for LastUpdateBy ;
alter table <schemaName,,>.<tableName,,> add constraint df_<tableName,,>_LastUpdateDatetime default getdate() for LastUpdateDatetime ;
alter table <schemaName,,>.<tableName,,> add constraint df_<tableName,,>_Revision default 0 for Revision ;

go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'<schemaName,,>.<tableName,,>' ) and 
				[type] in ( N'U' ) )
begin
	print 'Created table <schemaName,,>.<tableName,,> SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go