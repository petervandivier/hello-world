set nocount on

declare @table table
	(Number int not null,
	Letter char(1) not null,
	SpecChar char(1) not null);

insert @table values
	(1,'a','!'),
	(2,'b','@'),
	(3,'c','#'),
	(4,'d','$'),
	(5,'e','%'),
	(6,'f','^'),
	(7,'g','&'),
	(8,'h','*'),
	(9,'i','('),
	(10,'j',')');

--select * from @table

declare @num int, @letter char(1), @spec char(1), @concat varchar(10);

declare cursor_number cursor for
	select Number from @table where Number < 3
open cursor_number
fetch next from cursor_number into @num
while @@FETCH_STATUS = 0
begin

	declare cursor_letter cursor for
		select Letter from @table where Number < 3

	open cursor_letter
	fetch next from cursor_letter into @letter
	while @@FETCH_STATUS = 0
	begin
		print cast(@num as char) + @letter
		fetch next from cursor_letter into @letter
	end
	
	close cursor_letter
	deallocate cursor_letter
	
	fetch next from cursor_number into @num
end

close cursor_number
deallocate cursor_number

set nocount off