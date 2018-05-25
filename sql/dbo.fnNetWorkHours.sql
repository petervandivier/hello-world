
if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.fnNetWorkHours' ) and 
				[type] in ( N'FN' ) )
begin
	drop function dbo.fnNetWorkHours ;
	print 'Dropped function dbo.fnNetWorkHours SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go

create FUNCTION dbo.fnNetWorkHours
(
	@startDateTime datetime,
	@endDateTime datetime,
	@WorkDayStart time,
	@WorkDayEnd time
)
RETURNS decimal(18,5)
AS
/* who				when			what
petervandivier		2015-03-09		get working hours between input and ouput datetimes with variable workday hours
									referencing a static calender table
*/
BEGIN
--set nocount on

declare
	--@startDateTime datetime,
	--@endDateTime datetime,
	@startDate datetime,
	@endDate datetime,	
	--@WorkDayStart time,
	--@WorkDayEnd time,

	@fullWorkDaysLessCaps int = 0,
	@fullWorkDayNumberOfMilliseconds int,
	@midDaysTotalMillisecondsToAdd bigint = 0,

	@isStartAndEndSameDay bit = 0,
	@isAdjacentDayInput bit = 0,
	@isNonAdjacentMultipleDaysInput bit = 0,
	@isFirstDayWorkDay bit = 0,
	@isLastDayWorkDay bit = 0,

	@startDayTimeInMilliseconds int = 0,
	@endDayTimeInMilliseconds int = 0,
	@resultInMilliseconds bigint = 0,
	@resultInHours decimal(18,5),
	
	@auditMaxDate datetime,
	@auditMinDate datetime;

--select
--	@startDateTime = '2015-03-05 08:00:000.000', --to be input from function
--	@endDateTime = '2015-03-06 11:00:00.000', --to be input from function
--	@WorkDayStart = '09:00:00.000', --to be input from function
--	@WorkDayEnd = '17:00:00.000'; --to be input from function

select
	@startDate = cast(@startDateTime as date),
	@endDate = cast(@endDateTime as date);

select
	@auditMaxDate = max([DateName]),
	@auditMinDate = min([DateName])
from dimDate;

select
	@isFirstDayWorkDay = case ( select 1 
							from dimDate 
							where [DateName] = @startDate
							  and HolidayIndicator = 'Non-Holiday'
							  and WeekdayIndicator = 'WeekDay')
						when 1 then 1 else 0 end,
	@isLastDayWorkDay = case ( select 1 
							from dimDate  
							where [DateName] = @endDate
							  and HolidayIndicator = 'Non-Holiday'
							  and WeekdayIndicator = 'WeekDay')
						when 1 then 1 else 0 end,
	@fullWorkDayNumberOfMilliseconds = datediff(millisecond,@WorkDayStart,@WorkDayEnd);

select 
	@isStartAndEndSameDay = case when @startDate = @endDate then 1 else 0 end,
	@isAdjacentDayInput = case when @startDate = dateadd(day,-1,@endDate) then 1 else 0 end,
	@isNonAdjacentMultipleDaysInput = case when @startDate < dateadd(day,-1,@endDate) then 1 else 0 end;

/*--get the time worked on the first day of the period*/
set @startDayTimeInMilliseconds = 
	case 
/*--if start time is after the work day ends or the first day is NOT a work day, then zero*/
	when ( @startDateTime > (@startDate + @WorkDayEnd) ) 
	  or @isFirstDayWorkDay = 0 then 0
/*--if start time is before the work day start on a work day, then a full day
--if the endDT is same day prior to EOD, then the "select min()" case will choose the last day calc instead for same-day*/
	when  @startDateTime < (@startDate + @WorkDayStart) and @isFirstDayWorkDay = 1 then @fullWorkDayNumberOfMilliseconds
/*--otherwise, simple time difference from the start time to the lesser of end of the day or end time*/
	else datediff(millisecond,@startDateTime,
		case when @endDateTime > (@startDate + @WorkDayEnd) then (@startDate + @WorkDayEnd) else @endDateTime end)
	end;

/*--get the time worked in the middle of the period
--start with total # of workdays*/
select @fullWorkDaysLessCaps =
	COUNT(*)
from dimDate
where [DateName] between @startDate and @endDate
  and HolidayIndicator = 'Non-Holiday'
  and WeekdayIndicator = 'WeekDay'; 

/*--subtract working days as appropriate for first and last day which are calculated separately*/
set @fullWorkDaysLessCaps = @fullWorkDaysLessCaps - cast(@isFirstDayWorkDay as int) - cast(@isLastDayWorkDay as int);

if @fullWorkDaysLessCaps < 0
	set @fullWorkDaysLessCaps = 0

set @midDaysTotalMillisecondsToAdd = cast(@fullWorkDayNumberOfMilliseconds as bigint) * cast(@fullWorkDaysLessCaps as bigint);

/*--get the time worked on the last day of the period*/
set @endDayTimeInMilliseconds = 
	case 
/*--if end time is after before the workday starts or the last day is NOT a work day, then zero*/
	when ( @endDateTime < (@endDate + @WorkDayStart) ) 
	  or @isLastDayWorkDay = 0 then 0
/*--if end time is after the work day ends on a work day, then a full day
--if the startDT is same day after openning, then the "select min()" case will choose the first day calc instead for same-day*/
	when  @endDateTime > (@endDate + @WorkDayEnd) and @isLastDayWorkDay = 1 then @fullWorkDayNumberOfMilliseconds
/*--otherwise, simple time difference from the start of the day to the end time*/
	else datediff(millisecond,
		case when @endDate + @WorkDayStart > @startDateTime then @endDate + @WorkDayStart else @startDateTime end,
		@endDateTime)
	end;

				/*--debug text*/
				--print '@startDateTime = ' +isnull(cast(@startDateTime as varchar),'null')
				--print '@endDateTime = ' +isnull(cast(@endDateTime as varchar),'null')
				--print '@startDate = ' +isnull(cast(@startDate as varchar),'null')
				----print 'datediff(day,-1,@endDate) = ' + isnull(cast(datediff(day,-1,@endDate) as varchar),'null')
				--print '@endDate = ' +isnull(cast(@endDate as varchar),'null')
				--print '@WorkDayStart = ' +isnull(cast(@WorkDayStart as varchar),'null')
				--print '@WorkDayEnd = ' +isnull(cast(@WorkDayEnd as varchar),'null')
				--print ''
				--print '@fullWorkDaysLessCaps = ' +isnull(cast(@fullWorkDaysLessCaps as varchar),'null')
				--print '@fullWorkDayNumberOfMilliseconds = ' +isnull(cast(@fullWorkDayNumberOfMilliseconds as varchar),'null') + ' (' +
				--	cast(cast(cast(@fullWorkDayNumberOfMilliseconds as decimal(18,5)) /1000 /60 /60 as decimal(18,5)) as varchar) + ' hours)'
				--print '@midDaysTotalMillisecondsToAdd = ' +isnull(cast(@midDaysTotalMillisecondsToAdd as varchar),'null') + ' (' +
				--	cast(cast(cast(@midDaysTotalMillisecondsToAdd as decimal(18,5)) /1000 /60 /60 as decimal(18,5)) as varchar) + ' hours)'
				--print ''
				--print '@isStartAndEndSameDay = ' +isnull(cast(@isStartAndEndSameDay as varchar),'null')
				--print '@isAdjacentDayInput = ' +isnull(cast(@isAdjacentDayInput as varchar),'null')
				--print '@isNonAdjacentMultipleDaysInput = ' +isnull(cast(@isNonAdjacentMultipleDaysInput as varchar),'null')
				--print '@isFirstDayWorkDay = ' +isnull(cast(@isFirstDayWorkDay as varchar),'null')
				--print '@isLastDayWorkDay = ' +isnull(cast(@isLastDayWorkDay as varchar),'null')
				--print ''
				--print '@startDayTimeInMilliseconds = ' +isnull(cast(@startDayTimeInMilliseconds as varchar),'null') + ' (' +
				--	cast(cast(cast(@startDayTimeInMilliseconds as decimal(18,5)) /1000 /60 /60 as decimal(18,5)) as varchar) + ' hours)'
				--print '@endDayTimeInMilliseconds = ' +isnull(cast(@endDayTimeInMilliseconds as varchar),'null') + ' (' +
				--	cast(cast(cast(@endDayTimeInMilliseconds as decimal(18,5)) /1000 /60 /60 as decimal(18,5)) as varchar) + ' hours)'
				--print ''

if @auditMaxDate < @startDateTime
or @auditMaxDate < @endDateTime
or @auditMinDate > @startDateTime
or @auditMinDate > @endDateTime
begin
	--raiserror ('invalid input',11,-1)
	return 'because this function returns a numeric, I am not aware at this time of a good raiserror hack.
			this is the error handle block to throwe out b/s inputs rather than return NULL. we need NULL
			to be a distinct output for debugging.'
end

if @isStartAndEndSameDay = 1
begin
/*--"select min()" case for same day. if start or end time is outside work hours, one of these
--variables will be a full work day. if the other is also outside of work hours, a full day
--is correct. if not, however, using the lesser value will be correct*/
	set @resultInMilliseconds = 
		case 
		when @startDayTimeInMilliseconds > @endDayTimeInMilliseconds 
		then @endDayTimeInMilliseconds
		else @startDayTimeInMilliseconds
		end;
	set @resultInHours = cast(cast(@resultInMilliseconds as decimal(18,5)) /1000 /60 /60 as decimal(18,5));
	/*--print cast(cast(cast(@resultInMilliseconds as decimal(18,5)) /1000 /60 /60 as decimal(18,5)) as varchar) + ' hours'; 
	--print 'case 1 - @isStartAndEndSameDay'*/
end
else if @isAdjacentDayInput = 1
begin
	set @resultInMilliseconds = @startDayTimeInMilliseconds + @endDayTimeInMilliseconds;
	set @resultInHours = cast(cast(@resultInMilliseconds as decimal(18,5)) /1000 /60 /60 as decimal(18,5));
	/*--print cast(cast(cast(@resultInMilliseconds as decimal(18,5)) /1000 /60 /60 as decimal(18,5)) as varchar) + ' hours'; 
	--print 'case 2 - @isAdjacentDayInput'*/
end
else if @isNonAdjacentMultipleDaysInput = 1
begin
	set @resultInMilliseconds = @startDayTimeInMilliseconds + @endDayTimeInMilliseconds + @midDaysTotalMillisecondsToAdd;
	set @resultInHours = cast(cast(@resultInMilliseconds as decimal(18,5)) /1000 /60 /60 as decimal(18,5));
	/*--print cast(cast(cast(@resultInMilliseconds as decimal(18,5)) /1000 /60 /60  as decimal(18,5)) as varchar) + ' hours'; 
	--print 'case 3 - @isNonAdjacentMultipleDaysInput';*/
end

return @resultInHours;
END

/*
declare 
	@  = ;

exec dbo.fnNetWorkHours 
	@ ;
*/

go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.fnNetWorkHours' ) and 
				[type] in ( N'FN' ) )
begin
	print 'Created function dbo.fnNetWorkHours SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go