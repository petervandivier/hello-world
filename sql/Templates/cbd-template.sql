USE [master]
GO

create database <DB,,> 
on primary (
     [name]     = N'<DB,,>'
    ,[filename] = N'<DataDrive,,><DB,,>.mdf'
    ,size       = <DataFileSize,,>
    ,maxsize    = <DataFileMaxSize,,>
    ,filegrowth = <DataFileGrowth,,>
) LOG on (
     [name]     = N'<DB,,>_log'
    ,[filename] = N'<LogDrive,,><DB,,>_log.ldf'
    ,size       = <LogFileSize,,>
    ,maxsize    = <LogFileMaxSize,,>
    ,filegrowth = <LogFileGrowth,,>
);
go
