alter database Integration modify file (
     name = Integration
    ,filename = 'D:\MSSQL\Data\MyDatabase.mdf'
);
go
alter database MyDatabase modify file (
     name = MyDatabase_log
    ,filename = 'D:\MSSQL\Logs\MyDatabase_log.ldf'
);
go
