--select * from sys.databases where [database_id] > 4

declare @curBase sysname = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\';

;with new_loc as(
    select dir_path = 
        'D:\MSSQL\'
            + iif(mf.[type]=0,'Data','Logs') + '\'
            --+ mf.[name] + iif(mf.[type]=0,'.mdf','.ldf') 
            + replace(mf.physical_name,@curBase,'')
        ,mf.[database_id]
        ,mf.[file_id]
    from sys.master_files mf
) 
select 
    sql_cmd_1 = 'alter database ' 
    + db_name(mf.[database_id]) 
    + ' modify file (
     name = ' + mf.[name] + '
    ,filename = ''' + nl.dir_path +
    + '''
);
go'
    ,rollback_cmd = 'alter database ' 
    + db_name(mf.[database_id]) 
    + ' modify file (
     name = ' + mf.[name] + '
    ,filename = ''' + mf.physical_name +
    + '''
);
go'
    ,ps_cmd = 'Move-Item -Path "'+mf.physical_name+'" -Destination "'+nl.dir_path+'"'
from sys.master_files mf
join new_loc nl 
    on nl.[database_id] = mf.[database_id]
    and nl.[file_id] = mf.[file_id]
where mf.[database_id] <= 4

