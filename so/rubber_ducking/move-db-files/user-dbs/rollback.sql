alter database MyDatabase modify file (
     name = MyDatabase
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MyDatabase.mdf'
);
go
alter database MyDatabase modify file (
     name = MyDatabase_log
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MyDatabase_log.ldf'
);
go
