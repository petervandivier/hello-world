# How many times is this object replicated?

I'm trying to deprecate a piece of tech-debt that's touched by replication. For the step I'm currently tackling, there's a view that exists in a replicated database that has the below publications


	Pub_1				Pub_2			   Pub_3
	  |				   /  |  \			     |
	  |				  /	  |	  \				 |
	Sub_1 	     Sub_1  Sub_2  Sub_3	   Sub_4


`Pub_1`, `Pub_2`, and `Pub_3` are all publications of the same database. I'm working in the `Sub_4` database at the moment and there's a `view` that exists on both publisher and subscriber. There's no `views` in the published articles list so I feel fairly confident saying that the `view` in question was just scripted out and copy-pasted to `Sub_4` at some point. However... 

### Is there a way for me to rigorously audit this? 
Rather than just noting on the issue log "*I checked all the publications that I noticed and didn't see this object in any of them.*", is there a script I can run that would definitively tell me that this object is **not** published by any articles? 

# Try this script 

plagiarized from [sqlwhisperer](https://sqlwhisper.wordpress.com/2013/09/03/list-of-replicated-db-objects/)...


	select
		[name]
	from master.sys.databases
	where is_published = 1;
	go
	with ReplicationObjects as (
		select
			pubid,
			artID,
			dest_object,
			dest_owner,
			[objid],
			[name]
		from sysschemaarticles
		union
		select
			pubid,
			artID,
			dest_table,
			dest_owner,
			[objid],
			[name]
		from sysarticles
	)
	select
		serverproperty('ServerName') as PublisherServer,
		B.[name] as PublisherName,
		db_name() as PublisherDB,
		E.[name]+'.'+A.[name] as PublisherTableName,
		D.[Type_desc],
		A.dest_owner+'.'+A.dest_Object as SubscriberTableName,
		C.dest_db as SubscriberDB,
		C.srvname as SubscriberServer
	from ReplicationObjects A
	inner join syspublications B on A.pubid = B.pubid
	inner join dbo.syssubscriptions C on C.artid = A.artid
	inner join sys.objects D on A.[objid] = D.[Object_id]
	inner join sys.schemas E on E.[Schema_id] = D.[Schema_id]
	where dest_db not in ( 'Virtual' )
	order by
		E.[name],
		A.[name]; 

