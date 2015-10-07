
if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.fnGetFriendlyCashName' ) and 
				[type] in ( N'FN' ) )
begin
	drop function fnGetFriendlyCashName ;
	print 'Dropped function dbo.fnGetFriendlyCashName SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go

create function dbo.fnGetFriendlyCashName
(
	@input money,
	@option int = 1
)
Returns varchar(100)
AS
-- =============================================
-- Author:		peter vandivier
-- Create date: 3/30/2015
-- Description:	write UDF to return friendly String names for Cash 
-- =============================================
BEGIN
	declare
		@bigint bigint,
		@len int,
		@comma varchar(100),
		@firstComma int,
		@chunk1 varchar(10),
		@chunk2 varchar(10),
		@suffix varchar(10),
		@return varchar(100)

	set @comma = convert(varchar,@input,1)
	set @bigint = cast(@input as bigint)
	set @len = LEN(@bigint)
	set @firstComma = charindex(',',@comma,1)
	set @chunk1 = substring(@comma,1,case when @firstComma - 1 < 0 then 3 else @firstComma - 1 end)
	set @chunk2 = substring(@comma,@firstComma + 1,isnull(charindex(',',@comma,@firstComma),charindex('.',@comma,@firstComma)))
	
/* if chunk2 has only zero value digits, set to nothing
else set chunk 2 to static as appropriate
1 significant digits in hundreds of X-illions
2 significant digits in ones & tens of X-illions */
	select @chunk2 = case
		when replace(@chunk2,'0','') = '' then ''
		when @len in (7,8,10,11,13,14) then '.' + substring(@chunk2,1,2)
		when @len in (9,12,15) then '.' + substring(@chunk2,1,1)
		else '' end

--re-run chunk 2 set to nothing after first trim
	if replace(replace(@chunk2,'0',''),'.','') = ''
		set @chunk2 = ''

--if an invalid entry is provided for the suffix option, default to Option 2 - fully qualified
	select @option = case when @option in (1,2) then @option else 2 end

	select @suffix = 
		case @option 
			when 1 then case
							when @len between 0 and 4 then ''
							when @len between 5 and 6 then ' K'
							when @len in (7,8,9) then ' MM'
							when @len in (10,11,12) then ' BB'
							when @len in (13,14,15) then ' TT'
							else '' end
			when 2 then case
							when @len between 0 and 4 then ' Dollars'
							when @len between 5 and 6 then ' Thousand'
							when @len in (7,8,9) then ' Million'
							when @len in (10,11,12) then ' Billion'
							when @len in (13,14,15) then ' Trillion'
							else '' end
		end

	if @len between 0 and 4
		set @return = '$' + @comma + @suffix
	else if @len between 5 and 15
		set @return = '$' + @chunk1 + @chunk2 + @suffix
		
	return @return
END

/*

	--else if @len = 4
	--	set @return = '$' + convert(varchar,cast(@bigint as money),1) + @suffix
	--else if @len between 5 and 6
	--	set @return = '$' + @chunk1 + @suffix
	--else if @len between 7 and 8
	--	set @return = '$' + @chunk1 + @chunk2 + @suffix
	--else if @len = 9
	--	set @return = '$' + @chunk1 + @chunk2 + @suffix
	--else if @len between 10 and 11
	--	set @return = '$' + @chunk1 + @chunk2 + @suffix
	--else if @len = 12
	--	set @return = '$' + @chunk1 + @chunk2 + @suffix
	--else if @len between 13 and 14
	--	set @return = '$' + @chunk1 + @chunk2 + @suffix
	--else if @len = 15
	--	set @return = '$' + @chunk1 + @chunk2 + @suffix	

*/



go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.fnGetFriendlyCashName' ) and 
				[type] in ( N'FN' ) )
begin
	print 'Created function dbo.fnGetFriendlyCashName SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go
