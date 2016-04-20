use <DbName,,>
go

if object_id( N'<schemaName,,dbo>.<procName,,sp>' ) is null
	exec sp_executesql N'create proc <schemaName,,dbo>.<procName,,sp> as begin return 0; end;';

go

alter proc <schemaName,,dbo>.<procName,,sp>
	<@param1,,> <dataType1,,> = <Param1Default,,null>
/* who				when			what
<CreatedBy,,petervandivier>		<CreateDate,,>		<Description,,>

-- TESTING FRAMEWORK
exec <schemaName,,dbo>.<procName,,sp> 
	<@param1,,> = <Param1Default,,null>;

*/
as
begin
	set nocount on;
	set tran isolation level read uncommitted;

	declare
		@ProcName sysname = '<schemaName,,dbo>.<procName,,sp>',
		@ProcRunDT datetime = getdate(),
		@ErrMsg nvarchar( 4000 ) = '',
		@Lb char( 1 ) = char( 10 );
	
ReturnResults:

	return 0;
end;

go

