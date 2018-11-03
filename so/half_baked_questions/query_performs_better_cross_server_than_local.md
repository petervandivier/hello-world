#Query performs better cross-server than locally

nope... after a testing framework was run, the time variance shrank. still weird, but no longer reproducible. :'(

----------


##TL;DR:
Two identical legacy stored procs are running. `sProc_1` runs on `Server_1` and does a 4-part linked-server call to a big ol' view on `Server_2` with a gross `WHERE` clause. `sProc_2` does the same thing but it lives on `Server_2` ( albeit in a different DB ). All other things being equal, I'd expect the local copy to perform marginally. Nope! Given identical inputs, `sProc_1` executes in ~30 *seconds* and `sProc_2` takes ~30 *minutes*. What gives?


##The gory details
>**Disclaimer:**
>I did not design this code; just doing maintenance on some inherited tech-debt & trying to learn. <u>This is not a question about how to tune legacy code</u>. Been there, done that, got the t-shirt; what I want to know is: **Why did the remote query consistently perform better?**

###Pseudo-code 
Obfuscated sample of the stored procs & target view follow. The `WHERE` clause is a little bit longer & uglier in person than I've expressed below, but you should get the gist of it from the example. 

    CREATE PROC dbo.sProc_1
    	@date1 date,
    	@date2 date,
    	@char varchar(2) = '',
    	@int int = 0,
    	@bit bit = 0
    AS
    BEGIN
    	SELECT 
    		cl.Col1,
    		cl.Col2,
    		cl.Col3
    	-- ... Lots More Columns
    	FROM Server_1.DB.dbo.vwColumnList cl
    	WHERE cl.Col1 LIKE '%'+@char+'%' 
    		AND ( @bit = 0 OR cl.Col2 IS NULL )
    		AND ( CASE @int 
    				WHEN 1 THEN cl.Col3
    				WHEN 2 THEN cl.Col4
    				ELSE getdate()
    				END 
    			BETWEEN @date1 AND @date2 );
    END;

`sProc_2` is copy-paste the same but without the linked server `Server_1`. There's no real **reason** to have both of them, but it looks like `sProc_2` was deployed because a proactive dev heard that... 
> Linked Servers Are Bad

...and seemingly failed to follow up and performance test the new proc against the old. `vwColumnList` is something like the below but the full `SELECT` is ~200 columns long across ~40 tables in a big ol' flat schema data model<sup> 1</sup> 

    CREATE VIEW dbo.vwColumnList 
    AS
    SELECT 
    	t1.some_col_0 AS Col1,
    	t2.some_col_1 AS Col2,
    	t3.some_col_A AS Col3,
    	t4.some_col_Z AS Col4
    -- ... Lots More Columns
    FROM dbo.Table1 t1 
    JOIN dbo.Table2 t2 ON t2.primary_key = t1.primary_key 
    JOIN dbo.Table3 t3 ON t3.primary_key = t1.primary_key 
    -- ... Lots More Tables
    JOIN dbo.Table30 t30 ON t30.primary_key = t1.primary_key; 

###Execution Plans




----------
<sup> 1</sup> All the joined tables have the same `PRIMARY KEY`. Aside question - is there a standard name or common way to refer to this sort of data model ( other than "bad practice"... )
