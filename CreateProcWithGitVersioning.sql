USE <DbName,,>
GO

IF object_id( N'<schemaName,,dbo>.<procName,,sp>' ) is null
	EXEC sp_executesql N'CREATE PROC <schemaName,,dbo>.<procName,,sp> AS BEGIN; RETURN 0; END;';
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
ALTER PROC <schemaName,,dbo>.<procName,,sp>
	<@param1,,> <dataType1,,> = <Param1Default,,null>
/* who				when			what
<CREATEdBy,,petervandivier>		<CREATEDate,,>		<Description,,>

-- TESTING FRAMEWORK
EXEC <schemaName,,dbo>.<procName,,sp> 
	<@param1,,> = <Param1Default,,null>;

*/
AS
BEGIN;
	SET nocount ON;
	SET tran isolation level READ UNCOMMITTED;

	DECLARE
		@ProcName sysname = '<schemaName,,dbo>.<procName,,sp>',
		@ProcRunDT datetime = getdate(),
		@ErrMsg nvarchar( 4000 ) = '',
		@Lb char( 1 ) = char( 10 );
	
ReturnResults:

	RETURN 0;
END;

GO
