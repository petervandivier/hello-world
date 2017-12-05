use [master] 
go 
 
create or alter proc dbo.sp_OutputMultilineTextToFileSystemObject 
	@MultiLineText varchar( max ), 
	@DirectoryLocation sysname, 
	@FsoName sysname, 
	@EscapeAfterMinutes tinyint = 1 
/************************************************************************************************ 
-- Description : save Multi Line Text from user input to a flat file 
-- initial purpose is to build XML docs for Selenium IDE, also useful for CSV output when you're lazy 
-- init code plagiarized largely from the below locations. 
-- http://www.sqlservercentral.com/blogs/querying-microsoft-sql-server/2013/09/19/how-to-split-a-string-by-delimited-char-in-sql-server/ 
-- https://msdn.microsoft.com/en-us/library/ms175046.aspx?f=255&MSPPError=-2147217396#Anchor_6 
-- Date 		Developer 		Issue# 		Description 
--------------- ------------------- ------------------------------------------------------------ 
-- 2016-01-05	petervandivier	DAT-2925	create proc 
-- 2016-03-19	petervandivier	DAT-3516	rtrim() & escape " in @SingleLineText. 
--*********************************************************************************************** 
-- TESTING FRAMEWORK 
exec dbo.sp_OutputMultilineTextToFileSystemObject 
	@MultiLineText = 
'<tr> 
<td>open</td> 
<td>/home.do</td> 
<td></td> 
</tr> 
<tr>', 
	@DirectoryLocation = 'c:\', 
	@FsoName = 'var_out.txt'; 
 
exec dbo.sp_OutputMultilineTextToFileSystemObject 
	@MultiLineText = 
'Lorem ipsum dolor sit amet, 
consectetur adipiscing elit. 
Phasellus fermentum libero vitae tincidunt malesuada. 
Aenean id mi in diam luctus molestie. 
Quisque elementum porta arcu, 
nec dapibus purus ornare eu. 
Donec vitae mauris purus. 
Fusce sagittis tempor sem, 
dignissim venenatis ante hendrerit non. ', 
	@DirectoryLocation = 'c:\', 
	@FsoName = 'var_out.txt'; 
 
*/ 
as 
begin 
	set nocount on; 
	set tran isolation level read uncommitted; 
 
-- declare vars 
	declare 
		@Start int, 
		@End int, 
		@Delimiter char( 1 ), 
		@CrLf char( 2 ), 
		@Cr char( 1 ), 
		@Lf char( 1 ), 
		@Cmd varchar( 8000 ), 
		@SingleLineText varchar( 8000 ), 
		@i int, 
		@StartTime datetime; 
 
-- init vars 
	select 
		@Start = 1, 
		@Delimiter = char( 10 ), 
		@CrLf = char( 13 ) + char( 10 ), 
		@Cr = char( 13 ), 
		@Lf = char( 10 ), 
		@i = 1, 
		@StartTime = getdate(); 
 
-- standardize line feeds for all line breaks 
	select @MultiLineText = replace( @MultiLineText, @CrLf, @Delimiter ); 
	select @MultiLineText = replace( @MultiLineText, @Cr, @Delimiter ); 
 
-- trim doublequotes (invalid char) from FSO targets so we can... 
	select 
		@DirectoryLocation = replace( @DirectoryLocation, '"', '' ), 
		@FsoName = replace( @FsoName, '"', '' ); 
-- escape spaces in FSO targets 
	select 
		@DirectoryLocation = replace( @DirectoryLocation, ' ', '" "' ), 
		@FsoName = replace( @FsoName, ' ', '" "' ); 
 
-- validate filepath 
	if right( @DirectoryLocation, 1 ) <> '\' 
		set @DirectoryLocation += '\'; 
 
	select @End = charindex( @Delimiter, @MultiLineText ); 
 
-- escape if text is single line 
	if @End = 0 
		return -1; 
 
	select @SingleLineText = substring( @MultiLineText, @Start, @End - @Start ); 
	select @SingleLineText = rtrim( @SingleLineText ); 
 
		/****************************/ 
		/*	Write Output to File	*/ 
		/****************************/ 
	while @Start < len( @MultiLineText ) + 1 
	begin 
		if @End = 0 
			set @End = len( @MultiLineText ) + 1; 
 
		if datediff( minute, @StartTime, getdate() ) > @EscapeAfterMinutes goto FailForTime; 
 
		set @SingleLineText = substring( @MultiLineText, @Start, @End - @Start ); 
		select @SingleLineText = rtrim( @SingleLineText ); 
 
-- escape spec chars 
		set @SingleLineText = replace( @SingleLineText, '^', '^^' ); 
		set @SingleLineText = replace( @SingleLineText, '<', '^<' ); 
		set @SingleLineText = replace( @SingleLineText, '>', '^>' ); 
		set @SingleLineText = replace( @SingleLineText, '&', '^&' ); 
		set @SingleLineText = replace( @SingleLineText, '\', '^\' ); 
		set @SingleLineText = replace( @SingleLineText, '|', '^|' ); 
		set @SingleLineText = replace( @SingleLineText, '"', '^"' ); 
 
-- initialize the file with the first line 
		if @i = 1 
			set @Cmd = 'echo ' + @SingleLineText + ' > ' + @DirectoryLocation + @FsoName 
-- append all subsequent lines 
		else 
			set @Cmd = 'echo ' + @SingleLineText + ' >> ' + @DirectoryLocation + @FsoName; 
 
-- measure whitespace + horizontal-tab 
		if datalength( ltrim( rtrim( replace( @SingleLineText, char( 9 ), '' ) ) ) ) = 0 
		begin 
			if @i = 1 
				set @Cmd = 'echo( > ' + @DirectoryLocation + @FsoName 
			else 
				set @Cmd = 'echo( >> ' + @DirectoryLocation + @FsoName; 
		end; 
 
		exec [master].dbo.xp_cmdshell @Cmd, no_output; 
		--print 'exec [master].dbo.xp_cmdshell ''' + @Cmd + ''';'; 
 
		set @Start = @End + 1; 
 
		set @End = charindex( @Delimiter, @MultiLineText, @Start ); 
 
		set @i += 1; 
 
	end; 
 
	return 0; 
 
FailForTime: 
	begin 
		declare @FailMsg varchar( 1000 ) = 'Proc execution exceeded ' + convert( varchar, @EscapeAfterMinutes ) + ' minute(s) and was escaped. ' + convert( varchar( 10 ), isnull( @i, -1 ) ) + ' line(s) written.'; 
 
		raiserror( @FailMsg, 11, -1 ); 
 
		return -1; 
	end; 
 
end; 
 
go 
 
