create table #1thru10( i int not null primary key );
create table #1thru7 ( i int not null primary key );
create table #4and5and7 ( i int not null primary key );
create table #4thru10( i int not null primary key );

with cte as (
	select i=1
	union all
	select i+1
	from cte
	where i<10
)
insert #1thru10( i )
select i 
from cte;

insert #1thru7( i )
select i 
from #1thru10
where i <= 7;

insert #4and5and7( i )
select i 
from #1thru10
where i in ( 4,5,7 );

insert #4thru10( i )
select i 
from #1thru10
where i >= 4;


select i from #1thru7 -- expect 1 thru 7 
intersect 
select i from #4thru10 -- expect 4,5,6,7
intersect 
select i from #4and5and7 -- 4,5,7
