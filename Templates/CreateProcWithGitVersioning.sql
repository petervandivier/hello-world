use <DbName,,>
go

if object_id( N'<schemaName,,dbo>.<procName,,sp>' ) is null
	exec sp_executesql N'create proc <schemaName,,dbo>.<procName,,sp> as begin; return 0; end;';
go
set ansi_nulls, quoted_identifier on;
go
alter proc <schemaName,,dbo>.<procName,,sp>
	<@param1,,@var> <dataType1,,> <Param1Default,,= null>
/************************************************************************************************
-- Description : <PurposeOfProc,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create proc>
--***********************************************************************************************
-- TESTING FRAMEWORK
exec <schemaName,,dbo>.<procName,,sp> 
	<@param1,,@var> <Param1Default,,= null>;

*/
as
begin
	set nocount on;

	declare
		@ProcName sysname = '<schemaName,,dbo>.<procName,,sp>',
		@ProcRunDT datetime = getdate(),
		@ErrMsg nvarchar( 4000 ) = '',
		@Lb char( 1 ) = char( 10 );
	
ReturnResults:

	return 0;
end;

go
