-- reading through this a few months later, 
-- I'm not sure where I plagiarized it from
-- but I'm sure it needs attribution

declare @DefaultData nvarchar(512);
exec master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'DefaultData',
    @DefaultData output;

declare @DefaultLog nvarchar(512);
exec master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'DefaultLog',
    @DefaultLog output;

declare @DefaultBackup nvarchar(512);
exec master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'BackupDirectory',
    @DefaultBackup output;

declare @MasterData nvarchar(512);
exec master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer\Parameters',
    N'SqlArg0',
    @MasterData output;
select @MasterData=substring(@MasterData,3,255);
select @MasterData=substring(@MasterData,1,len(@MasterData)-charindex('\',reverse(@MasterData)));

declare @MasterLog nvarchar(512);
exec master.dbo.xp_instance_regread
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer\Parameters',
    N'SqlArg2',
    @MasterLog output;
select @MasterLog=substring(@MasterLog,3,255);
select @MasterLog=substring(@MasterLog,1,len(@MasterLog)-charindex('\',reverse(@MasterLog)));

select
    isnull(@DefaultData,@MasterData) DefaultData,
    isnull(@DefaultLog,@MasterLog) DefaultLog,
    isnull(@DefaultBackup,@MasterLog) DefaultBackup;