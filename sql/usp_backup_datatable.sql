USE [DBAdmin]
GO

if exists( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.usp_backup_datatable' ) and 
				[type] in ( N'P', N'PC' ) )
begin
	drop proc dbo.usp_backup_datatable ;
	print 'Dropped procedure dbo.usp_backup_datatable SUCCESSFULLY!' ;
end ;
go

create proc dbo.usp_backup_datatable
	@publisher_database_name nvarchar( 255 ),
	@publisher_schema_name nvarchar( 255 ),
	@publisher_table_name nvarchar( 255 ),
	@subscriber_database_name nvarchar( 255 ),
	@subscriber_schema_name nvarchar( 255 ),
	@subscriber_table_name nvarchar( 255 ),
	@drop_publisher_option nvarchar( 255 )
as
/* who		when			what
peterv		2015-09-11		create proc to backup datatables parameterized for dynamic table publishering & cross-db polination
	meat & potatoes of create_table step plagiarized from SO user @David 
	http://stackoverflow.com/a/317864/4709762
	used snake_case_syntax instead of CamelCaseSyntax ( as is my wont ) to conform to maintenance plan style conventions
peterv		2015-09-15		re-save with utf-8 encoding to test .git version recognition as text file WITH .gitattributs & .gitconf assist
peterv		2015-09-16		ported to DB & 05 from 03 & added commented out debug text at end of proc
*/
begin

	set nocount on ;
	set transaction isolation level read committed ;

	-- courtesy isnull( , 'dbo' ) for publisher schema param
	select @publisher_schema_name = isnull( @publisher_schema_name, 'dbo' ) ;

	declare 
		@proc_name nvarchar( 255 ) = N'usp_backup_datatable',
		@sql nvarchar( max ) = '',
		@exec_datetime_str varchar( 50 ) = replace( replace( replace( convert( varchar, getdate(), 126 ), ':', ''), '-', '' ), '.', '' ),
		@i int = null,
		@create_table nvarchar( max ) = '',
		@line_break nchar( 1 ) = nchar( 10 ),
		@error_count int = 0,
		@error_message nvarchar( max ) = '',
		@success_message nvarchar( max ) = '',
		@debug_message nvarchar( max ) = '',
		@publisher_name_2 nvarchar( max ) = 
			quotename( @publisher_schema_name ) + N'.' + 
			quotename( @publisher_table_name ),
		@publisher_name_3 nvarchar( max ) = 
			quotename( @publisher_database_name ) + N'.' + 
			quotename( @publisher_schema_name ) + N'.' + 
			quotename( @publisher_table_name ),
		@subscriber_name_2 nvarchar( max ),
		@subscriber_name_3 nvarchar( max ) ;

	set @success_message = 'Begin procedure '+ @proc_name + 
		@line_break + 
		@line_break + 'Variables initialized. Beginning parameter validation.' + 
		@line_break + 
		@line_break ;

		/****************************/
		/*	Validate Input Params	*/
		/****************************/
	-- escape proc if publisher object/publisher does not exist
	if object_id( @publisher_name_3 ) is null
	begin
		set @error_message = 'Backup FAILED! ' + isnull( @publisher_name_3, '*@publisher_name_3 not found*' ) + ' does not exist or cannot be found under the current session connection.' ;
		goto quit_with_failure ;
	end ;

	-- if subscribing Db/table name not selected, use publisher
	select 
		@subscriber_database_name = isnull( @subscriber_database_name, @publisher_database_name ),
		@subscriber_table_name = isnull( @subscriber_table_name, @publisher_table_name ) ;

	-- validate subscriber schema
	set @sql = 'select @i = 1 from ' + @subscriber_database_name + '.sys.schemas where name = ''' + @subscriber_schema_name + '''' ;
	exec sp_executesql @sql, N'@i int output', @i output ;
	select @subscriber_schema_name = case @i when 1 then @subscriber_schema_name else 'dbo' end ;

	-- initialize subscriber variables & set values
set_subscriber:
	select
		@subscriber_name_2 =
			quotename( @subscriber_schema_name ) + '.' + 
			quotename( @subscriber_table_name ),
		@subscriber_name_3 = 
			quotename( @subscriber_database_name ) + '.' + 
			quotename( @subscriber_schema_name ) + '.' + 
			quotename( @subscriber_table_name ) ;

	-- then validate, if the dest is same as publisher, rename dest
	set @debug_message = isnull( @subscriber_name_3, 'null_val' ) + ' object_id:=' + isnull( convert( varchar, object_id( @subscriber_name_3 ) ), 'null_val' ) ;
	if object_id( @subscriber_name_3 ) is not null
	begin
		select @subscriber_table_name += '_Backup_' + @exec_datetime_str ;
		select 
			@subscriber_name_2 = 
				quotename( @subscriber_schema_name ) + '.' + 
				quotename( @subscriber_table_name ),
			@subscriber_name_3 = 
				quotename( @subscriber_database_name ) + '.' + 
				quotename( @subscriber_schema_name ) + '.' + 
				quotename( @subscriber_table_name ) ;
		-- goto set_subscriber ;
	end ;


		/************************/
		/*	Get Table Metadata	*/
		/************************/
	-- prep temp tables
	if object_id( N'tempdb..#infoschema_columns_for_usp_backup_datatable' ) is not null drop table #infoschema_columns_for_usp_backup_datatable ;
	if object_id( N'tempdb..#sysobjects_for_usp_backup_datatable' ) is not null drop table #sysobjects_for_usp_backup_datatable ;

	create table #infoschema_columns_for_usp_backup_datatable
	(
		table_name nvarchar( 128 ) not null,
		column_name nvarchar( 128 ) null,
		ordinal_position int null,
		is_nullable varchar( 3 ) null,
		data_type nvarchar( 128 ) null,
		character_maximum_length int null,
		numeric_precision tinyint null,
		numeric_scale int null
	) ;

	create table #sysobjects_for_usp_backup_datatable
	(
		name nvarchar( 128 ) not null,
		id int not null,
		xtype nvarchar( 128 ) not null
	);

	set @sql = 
		'insert #infoschema_columns_for_usp_backup_datatable 
		select 
			table_name, 
			column_name, 
			ordinal_position, 
			is_nullable, 
			data_type, 
			character_maximum_length, 
			numeric_precision, 
			numeric_scale 
		from ' + @publisher_database_name + '.information_schema.columns ;' ;
	exec sp_executesql @sql ;
	set @sql = 
		'insert #sysobjects_for_usp_backup_datatable 
		select 
			name, 
			id, 
			xtype 
		from ' + @publisher_database_name + '.dbo.sysobjects ' ;
	exec sp_executesql @sql ;

		/********************************/
		/*	Define Create Table Syntax	*/
		/********************************/
	select @create_table =
		'create table ' + @subscriber_name_3 + 
		'( ' + o.list + ' ); ' 
	from #sysobjects_for_usp_backup_datatable so
	cross apply
	( 
		select 
			@line_break + '  [' + c.column_name + '] ' + 
			c.data_type + 
			case c.data_type
				when 'sql_variant' then ''
				when 'text' then ''
				when 'ntext' then ''
				when 'xml' then ''
				when 'decimal' then '(' + cast( c.numeric_precision as varchar ) + ', ' + cast( c.numeric_scale as varchar ) + ')'
				else coalesce( '(' + case when c.character_maximum_length = -1 then 'MAX' else cast( c.character_maximum_length as varchar ) end + ')', '' ) end + ' ' +
			case when c.IS_NULLABLE = 'No' then 'NOT ' else '' end + 'NULL ' + 
			case when c.ordinal_position = ( select max( ordinal_position ) from #infoschema_columns_for_usp_backup_datatable where table_name = so.name ) then @line_break else ', ' end
		from #infoschema_columns_for_usp_backup_datatable c where c.table_name = so.name
		order by c.ordinal_position
		FOR XML PATH( '' ) 
	) o ( list )
	where so.xtype = 'U' AND
		so.name = ( @publisher_table_name ) ;

	set @success_message += '@create_table defined SUCCESSFULLY. Begin execution try. ' + @line_break + @line_break ;

		/********************************/
		/*	Begin Backup Execution Try	*/
		/********************************/
	-- create table try
	begin try
		exec sp_executesql @create_table ;
		set @success_message += 'Subscriber table created SUCCESSFULLY. Begin populate try. ' + @line_break + @line_break ;
	end try
	begin catch
		set @error_message += error_message() ;
		goto quit_with_failure ;
	end catch ;

	-- populate subscriber try
	begin try
		set @sql = 'insert ' + @subscriber_name_3 + ' select * from ' + @publisher_name_3 ;
		exec sp_executesql @sql ;
		set @success_message += 'Subscriber table populated SUCCESSFULLY. ' + @line_break + @line_break ;
	end try
	begin catch
		set @error_message += error_message() ;
		goto quit_with_failure ;
	end catch ;

	-- drop publisher try ( if option is selected )
	if @drop_publisher_option = 'DROP_PUBLISHER'
	begin try
		set @success_message += 'DROP_PUBLISHER was specified. Begin drop publisher try. ' + @line_break + @line_break ;
		set @sql = 'drop table ' + @publisher_name_3 ;
		exec sp_executesql @sql ;
		set @success_message += 'DROP_PUBLISHER completed SUCCESSFULLY. ' + @publisher_name_3 + ' has been DELETED. ' + @line_break + @line_break ;
	end try
	begin catch
		set @error_message += error_message() ;
		goto quit_with_failure ;
	end catch ;
	
	-- truncate publisher try ( if option is selected )
	if @drop_publisher_option = 'TRUNCATE_PUBLISHER'
	begin try
		set @success_message += 'TRUNCATE_PUBLISHER was specified. Begin truncate publisher try. ' + @line_break + @line_break ;
		set @sql = 'truncate table ' + @publisher_name_3 ;
		exec sp_executesql @sql ;
		set @success_message += 'TRUNCATE_PUBLISHER completed SUCCESSFULLY. ' + @publisher_name_3 + ' has been TRUNCATED. ' + @line_break + @line_break ;
	end try
	begin catch
		set @error_message += error_message() ;
		goto quit_with_failure ;
	end catch ;

		/********************************/
		/*	Return Results & Cleanup	*/
		/********************************/
	goto quit_with_success ;

quit_with_failure:
	begin 
		print @success_message + @line_break + @line_break ;
		raiserror( @error_message, 11, -1 ) ;
		return -1 ;
		goto cleanup ;
	end ;

quit_with_success:
	-- print @create_table ;
	print @success_message ;
	print @line_break + @line_break + 'select * from ' + @subscriber_name_3 ;
	print @debug_message ;
	return 0 ;

cleanup:
	-- cleanup
	drop table #infoschema_columns_for_usp_backup_datatable ;
	drop table #sysobjects_for_usp_backup_datatable ;

end ;

/*

declare
	@publisher_database_name nvarchar( 255 ) = '',
	@publisher_schema_name nvarchar( 255 ) = '',
	@publisher_table_name nvarchar( 255 ) = '',
	@subscriber_database_name nvarchar( 255 ) = '',
	@subscriber_schema_name nvarchar( 255 ) = '',
	@subscriber_table_name nvarchar( 255 ) = '',
	@drop_publisher_option nvarchar( 255 ) = '' ;

exec DbAdmin.dbo.usp_backup_datatable
	@publisher_database_name,
	@publisher_schema_name,
	@publisher_table_name,
	@subscriber_database_name,
	@subscriber_schema_name,
	@subscriber_table_name,
	@drop_publisher_option ;

*/

go

if exists( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.usp_backup_datatable' ) and 
				[type] in ( N'P', N'PC' ) )
	print 'Create procedure dbo.usp_backup_datatable SUCCESSFULLY!' ;
else
	print 'Create procedure dbo.usp_backup_datatable FAILED!' ;
go