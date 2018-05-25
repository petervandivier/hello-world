if object_id( N'tempdb..#tbl_a' ) is not null drop table #tbl_a ;
if object_id( N'tempdb..#tbl_b' ) is not null drop table #tbl_b ;

create table #tbl_a ( col1 int ) ;
create table #tbl_b ( col1 int ) ;

declare 
	@sql_a nvarchar( 255 ),
	@sql_b nvarchar( 255 ),
	@errmsg nvarchar( 255 ) ;

set @sql_a = N'create clustered index idx_1 on #tbl_a ( col1 );';
set @sql_b = N'create clustered index idx_1 on #tbl_b ( col1 );';

begin try
	exec sp_executesql @sql_a ;
	exec sp_executesql @sql_b ;

	print 'Homonym indeces created SUCCESSFULLY' ;
end try
begin catch
	set @errmsg = error_message() ;
	raiserror( @errmsg, 11, -1 ) ;
end catch ;