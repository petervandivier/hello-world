use <DbName,,>
go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'<schemaName,,dbo>.<procName,,sp>' ) and 
				[type] in ( N'P' ) )
begin
	drop proc <schemaName,,dbo>.<procName,,sp>;
	print 'Dropped proc <schemaName,,dbo>.<procName,,sp> SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 );
end;
go

create proc <schemaName,,dbo>.<procName,,sp>
	<@param1,,> <dataType1,,>
/*
exec <schemaName,,dbo>.<procName,,sp> <@param1,,> = <Param1Default,,>;
*/
as
/* who				when			what
petervandivier		<CreateDate,,>	<Description,,>
*/
begin
	set nocount on;
	set tran isolation level read uncommitted;

	return 0;
end;

go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'<schemaName,,dbo>.<procName,,sp>' ) and 
				[type] in ( N'P' ) )
begin
	print 'Created proc <schemaName,,dbo>.<procName,,sp> SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 );
end;
else
begin
	print 'Create proc <schemaName,,dbo>.<procName,,sp> FAILED! At time ' + convert( varchar, getdate(), 126 );
end; 
go