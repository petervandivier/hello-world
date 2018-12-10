use msdb
go

CREATE OR ALTER PROCEDURE #sp_enumerate_backuphistory
   @newest_date datetime = null
  ,@oldest_date datetime
AS
/*
declare @od datetime =  dateadd(day,-7,getdate());
exec #sp_enumerate_backuphistory
    @oldest_date = @od;
*/
BEGIN
  SET NOCOUNT ON

  if @newest_date is null 
    set @newest_date = getdate(); -- server time

  DECLARE @backup_set_id TABLE      (backup_set_id INT)
  DECLARE @media_set_id TABLE       (media_set_id INT)
  DECLARE @restore_history_id TABLE (restore_history_id INT)

  INSERT INTO @backup_set_id (backup_set_id)
  SELECT DISTINCT backup_set_id
  FROM msdb.dbo.backupset
  WHERE backup_finish_date < @newest_date
    AND backup_finish_date >= @oldest_date

  INSERT INTO @media_set_id (media_set_id)
  SELECT DISTINCT media_set_id
  FROM msdb.dbo.backupset
  WHERE backup_finish_date < @oldest_date

  INSERT INTO @restore_history_id (restore_history_id)
  SELECT DISTINCT restore_history_id
  FROM msdb.dbo.restorehistory
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM @backup_set_id)

  declare @backup_counts table (
     table_name sysname primary key 
    ,row_count  int not null
    
  );

  insert @backup_counts (row_count, table_name)
  select 
    count(*) as row_count
    ,'backupfile' as table_name 
  from msdb.dbo.backupfile
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM @backup_set_id)
UNION ALL 

  select 
    count(*) as row_count
    ,'backupfilegroup' as table_name 
  from msdb.dbo.backupfilegroup
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM @backup_set_id)
UNION ALL 

  select 
    count(*) as row_count
    ,'restorefile' as table_name 
  from msdb.dbo.restorefile
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM @restore_history_id)
UNION ALL 

  select 
    count(*) as row_count
    ,'restorefilegroup' as table_name from msdb.dbo.restorefilegroup
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM @restore_history_id)
UNION ALL 

  select 
    count(*) as row_count
    ,'restorehistory' as table_name 
  from msdb.dbo.restorehistory
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM @restore_history_id)
UNION ALL 

  select 
    count(*) as row_count
    ,'backupset' as table_name 
  from msdb.dbo.backupset
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM @backup_set_id)
UNION ALL 

  select 
    count(*) as row_count
    ,'backupmediafamily' as table_name
  FROM msdb.dbo.backupmediafamily bmf
  WHERE bmf.media_set_id IN (SELECT media_set_id
                             FROM @media_set_id)
    AND ((SELECT COUNT(*)
          FROM msdb.dbo.backupset
          WHERE media_set_id = bmf.media_set_id) = 0)
UNION ALL 

  select 
    count(*) as row_count
    ,'backupmediaset' as table_name
  FROM msdb.dbo.backupmediaset bms
  WHERE bms.media_set_id IN (SELECT media_set_id
                             FROM @media_set_id)
    AND ((SELECT COUNT(*)
          FROM msdb.dbo.backupset
          WHERE media_set_id = bms.media_set_id) = 0)

    drop table if exists #su;
    create table #su ( 
         name       varchar(100)
        ,rows       bigint
        ,reserved   varchar(100)
        ,data       varchar(100)
        ,index_size varchar(100)
        ,unused     varchar(100)
    );
    
    insert #su exec sp_spaceused 'backupfile';
    insert #su exec sp_spaceused 'backupfilegroup';
    insert #su exec sp_spaceused 'restorefile';
    insert #su exec sp_spaceused 'restorefilegroup';
    insert #su exec sp_spaceused 'restorehistory';
    insert #su exec sp_spaceused 'backupset';
    insert #su exec sp_spaceused 'backupmediafamily';
    insert #su exec sp_spaceused 'backupmediaset';

    /*
    select 
         name       
        ,rows       
        ,reserved   
        ,data       
        ,index_size 
        ,unused      
        ,byes_per_row = convert(decimal(10,1), ( try_cast(replace(su.reserved,' KB','') as float) / su.[rows] ) * 1024. )
    from #su su;
    */

    declare @days float = datediff(hour,@oldest_date,@newest_date) / 24.;

    with bytes_per_row as (
        select 
             su.[name]
            ,byes_per_row    = convert(decimal(10,1), ( try_cast(replace(su.reserved,' KB','') as float) / su.[rows] ) * 1024. )
        from #su su
    )
    select 
         bc.row_count 
        ,bc.table_name
        ,mb_in_timeframe = convert(decimal(10,4),(bc.row_count*(bpr.byes_per_row/power(1024,2))))
        ,mb_per_day      = convert(decimal(10,4),(bc.row_count*(bpr.byes_per_row/power(1024,2)))/@days)
        ,total_rows      = su.[rows]
        ,su.reserved   
        ,su.[data]       
        ,su.index_size 
        ,su.unused      
        ,bpr.byes_per_row    
    from @backup_counts bc
    join #su su on su.[name] = bc.table_name
    join bytes_per_row bpr on bpr.[name] = bc.table_name;

END;
GO
