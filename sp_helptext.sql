--sp_helptext 'sp_rename'

create procedure sys.sp_rename
	@objname	nvarchar(1035),		-- up to 4-part "old" name
		@newname	sysname,			-- one-part new name
		@objtype	varchar(13) = null	-- identifying the name
		as
	/* DOCUMENTATION:
   [1]  To rename a table, the @objname (meaning OldName) parm can be
   passed in totally unqualified or fully qualified.
   [2]  The SA or DBO can rename objects owned by lesser users,
   without the need for SetUser.
   [3]  The Owner portion of a qualified name can usually be
   passed in in the omitted form (as in MyDb..MyTab or MyTab).  The
   typical exception is when the SA/DBO is trying to rename a table
where the @objname is present twice in sysobjects as a table
owned only by two different lesser users; requiring an explicit
owner qualifier in @objname.
   [4]  An unspecified Owner qualifier will default to the
   current user if doing so will either resolve what would
   otherwise be an ambiguity within @objtype, or will result
in exactly one match.
   [5]  If Database is part of the qualified @objname,
   then it must match the current database.  The @newname parm can
   never be qualified.
   [6]  Here are the valid @objtype values.  They correspond to
   system tables which track each type:
      'column'  'database'  'index'  'object'  'userdatatype'
      The @objtype parm is sometimes required.  It is always required
      for databases.  It is required whenever ambiguities would
otherwise exist.  Explicit use of @objtype is always encouraged.
   [7]  Parms can use quoted_identifiers.  For example:
      Execute sp_rename 'amy."his table"','"her table"','object'
      */
	set nocount      on
		set ansi_padding on
		declare @objtypeIN		varchar(13),
					@CurrentDb		sysname,
						@CountNumNodes	int,
						@UnqualOldName	sysname,
						@QualName1		sysname,
						@QualName2		sysname,
						@QualName3		sysname,
						@OwnAndObjName	nvarchar(517),	-- "[owner].[object]"
						@SchemaAndTypeName	nvarchar(517),	-- "[schema].[type]"
						@objid			int,
						@xtype			nchar(2),
						@indid			int,
						@colid			int,
						@cnstid			int,
						@xusertype		int,
						@schid			int,
						@objid_tmp		int,
						@xtype_tmp		nchar(2),
						@retcode		int,
						@published		bit		-- Indicates table is used in replication			
				-- initial (non-null) settings
					select	@CurrentDb		= db_name(),
				@objtypeIN		= @objtype
				-- make type case insensitive
					select @objtype = lower(@objtypeIN collate Latin1_General_CI_AS)
		------------------------------------------------------------------------
			-------------------  PHASE 10:  Simple parm edits  ---------------------
		------------------------------------------------------------------------
		-- Valid rename-type param?
			if (@objtype is not null AND
			@objtype not in ('column', 'database', 'index', 'object', 'userdatatype'))
			begin
			raiserror(15249,-1,-1,@objtypeIN)
				return 1
			end
		-- null names?
		if (@newname IS null)
		begin
			raiserror(15223,-1,11,'NewName')
				return 1
			end
		if (@objname IS null)
		begin
			raiserror(15223,-1,-1,'OldName')
				return 1
			end
		--	Is NewName minimally valid?
			exec @retcode = sp_validname @newname
		if @retcode <> 0
		begin
			raiserror(15224,-1,15,@newname)
				return 1
			end
		--	Parse apart the perhaps dots-qualified old name.
			select @UnqualOldName = parsename(@objname, 1),
				@QualName1 = parsename(@objname, 2),
						@QualName2 = parsename(@objname, 3),
						@QualName3 = parsename(@objname, 4)
				if (@UnqualOldName IS Null)
		begin
			raiserror(15253,-1,-1,@objname)
				return 1
			end
		-- count name parts --
			select @CountNumNodes = (case
					when @QualName3 is not null then 4
								when @QualName2 is not null then 3
								when @QualName1 is not null then 2
								else 1
							end)
				if (@objtype  = 'database' AND @CountNumNodes > 1)
		begin
			raiserror(15395,-1,20,@objtypeIN)
				return 1
			end
		if (@objtype in ('object','userdatatype') AND @CountNumNodes > 3)
		begin
			raiserror(15225,-1,-1,@objname, @CurrentDb, @objtypeIN)
				return 1
			end
		---------------------------------------------------------------------------
			----------------------  PHASE 20:  Settle Parm1ItemType  ------------------
		---------------------------------------------------------------------------
		------------- database?
			if (@objtype  = 'database')
		begin
			execute @retcode = sys.sp_renamedb @UnqualOldName ,@newname -- de-docu old sproc
				if @retcode <> 0
					return 1
					return 0
			end
		BEGIN TRANSACTION
		------------ type?
			if (@objtype = 'userdatatype' or @objtypeIN is null)
		begin
			select @xusertype = user_type_id, @schid = schema_id
					from sys.types where user_type_id = type_id(@objname)
					
				-- Lock scalar type exclusively and check permissions
				if not (@xusertype is null)
				begin
							
							-- cannot pass @objname	as it is nvarchar(1035) and Invoke fails %%ScalarType does not compile with four part name.
				-- cross db type resolution is not allowed (already taken care of by type_id) so only two part name is required.
				if (@QualName1 is not null)
					select @SchemaAndTypeName = QuoteName(@QualName1) + '.' + QuoteName(@UnqualOldName)
					else
					select @SchemaAndTypeName = QuoteName(@UnqualOldName)
						
						EXEC %%ScalarType(MultiName = @SchemaAndTypeName).LockMatchID(ID = @xusertype, Exclusive = 1)
						if (@@error <> 0)
							select @xusertype = null
						end
			
			-- check for wrong param
				if ((@xusertype is not null AND @objtype <> 'userdatatype') OR
					(@xusertype is null AND @objtype = 'userdatatype'))
					begin
					COMMIT TRANSACTION
						raiserror(15248,-1,-1,@objtypeIN)
						return 1
					end
				if not (@xusertype is null)
							select	@objtype = 'userdatatype'
				end
		-- assuming column/index-name, obtain object/column id's
			if (@objtype in ('column', 'index') or @objtypeIN is null)
		begin
			if @QualName2 is not null
					select @objid = object_id(QuoteName(@QualName2) +'.'+ QuoteName(@QualName1))
					else
					select @objid = object_id(QuoteName(@QualName1))
					if not (@objid is null)	-- nice try?
							begin
					-- obtain owner-qual object name
								select @schid = ObjectProperty(@objid, 'schemaid')
						select @OwnAndObjName = QuoteName(schema_name(@schid))+'.'+QuoteName(object_name(@objid))
						EXEC %%Object(MultiName = @OwnAndObjName).LockMatchID(ID = @objid, Exclusive = 1, BindInternal = 0)
									if @@error <> 0
							select @objid = null
							else
							select @xtype = type from sys.objects where object_id = @objid
						end
							end
		------------ column?
			if (@objtype = 'column' or @objtypeIN is null)
		begin
			-- find column
				if (@xtype in ('U','V'))
					select @colid = column_id from sys.columns
								where object_id = @objid and name = @UnqualOldName
							-- check for wrong param
									if ((@colid is not null AND @objtype <> 'column') OR
					(@colid is null AND @objtype = 'column'))
					begin
					COMMIT TRANSACTION
						raiserror(15248,-1,-1,@objtypeIN)
						return 1
					end
				-- remember if we've found a column
						if not (@colid is null)
				begin
					select @published = is_published from sys.objects where object_id = @objid
						if @published = 0
							select @published = is_merge_published from sys.tables where object_id = @objid
							if (@published <> 0)
											begin
									COMMIT TRANSACTION
										raiserror(15051,-1,-1)
										return (0)
									end
							select @objtype = 'column'
					end
			end
		------------ index?
			if (@objtype = 'index' or @objtypeIN is null)
		begin
			-- find index
				if (@xtype in ('U','V'))
					select @indid = stats_id from sys.stats
								where object_id = @objid and name = @UnqualOldName
							-- if we could not find a regular index, try finding an xml index
									if (@indid is null )
					select @indid = object_id from sys.xml_indexes
							where object_id = @objid and name = @UnqualOldName
						-- check for wrong param
								if ((@indid is not null AND @objtype <> 'index') OR
					(@indid is null AND @objtype = 'index'))
					begin
					COMMIT TRANSACTION
						raiserror(15248,-1,-1,@objtypeIN)
						return 1
					end
				if not (@indid is null)
						begin
					select @objtype = 'index'
						select @cnstid = object_id, @xtype = type from sys.objects
							where name = @UnqualOldName and parent_object_id = @objid and type in ('PK','UQ')
						end
			end
		------------ object?
			if (@objtype = 'object' or @objtypeIN is null)
		begin
			-- get object id, type
				select @objid_tmp = object_id(@objname)
				
				if not (@objid_tmp is null)
				begin
					-- obtain owner-qual object name
						select @schid = ObjectProperty(@objid_tmp, 'schemaid')
						select @OwnAndObjName = QuoteName(schema_name(@schid))+'.'+QuoteName(object_name(@objid_tmp))
						EXEC %%Object(MultiName = @OwnAndObjName).LockMatchID(ID = @objid_tmp, Exclusive = 1, BindInternal = 0)
									if @@error <> 0
							select @objid_tmp = null
						end
				select @xtype_tmp = type
							from sys.objects where object_id = @objid_tmp
					-- if object is a system table, a Scalar function, or a table valued function, skip it.
				-- Cannot rename system table
						if @xtype_tmp = 'S'
					select @objid_tmp = NULL
					-- Locks parent object and increments schema_ver
							if not (@objid_tmp is null)
				begin
					if (@xtype_tmp in ('U'))
								begin
							select @published = is_merge_published | is_published from sys.tables where object_id = @objid_tmp
											if (@published <> 0)
								begin
									COMMIT TRANSACTION
										raiserror(15051,-1,-1)
										return (0)
									end
							end
						-- parent already locked via locking object
					end
				-- check for wrong param
						if ((@objid_tmp is not null AND @objtype <> 'object') OR
					(@objid_tmp is null AND @objtype = 'object'))
					begin
					COMMIT TRANSACTION
						raiserror(15248,-1,-1,@objtypeIN)
						return 1
					end
				if not (@objid_tmp is null)
							select @objtype = 'object', @objid = @objid_tmp, @xtype = @xtype_tmp
				end
		---------------------------------------------------------------------
			-------------------  PHASE 30:  More parm edits  --------------------
		---------------------------------------------------------------------
		-- item type determined?
			if (@objtype is null)
		begin
			COMMIT TRANSACTION
				raiserror(15225,-1,-1,@objname, @CurrentDb, @objtypeIN)
				return 1
			end
		-- was the original name valid given this type?
			if (@objtype in ('object','userdatatype') AND @CountNumNodes > 3)
		begin
			COMMIT TRANSACTION
				raiserror(15225,-1,-1,@objname, @CurrentDb, @objtypeIN)
				return 1
			end
		-- verify db qualifier is current db
			if (@objtype in ('object','userdatatype'))
			select @QualName3 = @QualName2
			if (isnull(@QualName3, @CurrentDb) <> @CurrentDb)
		begin
			COMMIT TRANSACTION
				raiserror(15333,-1,-1,@QualName3)
				return 1
			end
		if (@objtype <> 'userdatatype')
			begin
			-- check if system object
				select @schid = ObjectProperty(@objid, 'schemaid')
				if (ObjectProperty(@objid, 'IsMSShipped') = 1 OR
					ObjectProperty(@objid, 'IsSystemTable') = 1)
					begin
					COMMIT TRANSACTION
						raiserror(15001,-1,-1, @objname)
						return 1
					end
			end
		
		-- System created Date Correlation view and its columns/indexes cannot be renamed.
		if (@objid is not null
			AND @xtype = 'V '
				AND 1 = Isnull((select is_date_correlation_view from sys.views where object_id = @objid), 0)
				)
			begin
			COMMIT TRANSACTION
				raiserror(15168,-1,-1, @objname)
				return 1
			end
		-- make sure orig no longer shows null
			if @objtypeIN is null
			select @objtypeIN = @objtype
			-- Check for name clashing with existing name(s)
				if (@newname <> @UnqualOldName)
		begin
			-- column name clash?
				if (@objtype = 'column')
					if (ColumnProperty(@objid, @newname, 'isidentity') is not null)
							select @UnqualOldName = NULL
						-- index name clash?
				if ( (@objtype = 'object' AND @xtype in ('PK','UQ'))
						OR @objtype = 'index')
							if exists (select * from sys.stats where object_id = @objid and name = @newname)
							select @UnqualOldName = NULL
						-- cnst name clash?
				if (@objtype = 'object' OR @cnstid IS NOT null)
					if (object_id(QuoteName(schema_name(@schid)) +'.'+ QuoteName(@newname), 'local') is not null)
							select @UnqualOldName = NULL
						-- stop on clash
				if (@UnqualOldName is null)
				begin
					COMMIT TRANSACTION
						raiserror(15335,-1,-1,@newname,@objtypeIN)
						return 1
					end
			end
		--------------------------------------------------------------------------
			--------------------  PHASE 32:  Temporay Table Isssue -------------------
		--------------------------------------------------------------------------
		-- Disallow renaming object to or from a temp name (starts with #)
		if (@objtype = 'object' AND
			(substring(@newname,1,1) = N'#' OR
				substring(object_name(@objid),1,1) = N'#'))
			begin
			COMMIT TRANSACTION
				raiserror(15600,-1,-1, 'sys.sp_rename')
				return 1
			end
		--------------------------------------------------------------------------
			--------------------  PHASE 34:  Cautionary messages  --------------------
		--------------------------------------------------------------------------
		if @objtype = 'column'
			begin
			-- Check for Dependencies: No column rename if enforced dependency on column
				if exists (select * from sys.sql_dependencies d where
					d.referenced_major_id = @objid
						AND d.referenced_minor_id = @colid
						AND d.class = 1
						-- filter dependencies where the dependent object d.object_id is a date correlation view.
						-- Date correlation view owner is the same as of any of the tables they are dependent upon so user having alter access
						-- to any of the participating tables will have catalog view access to the MPIV for the following query to succeed.
						AND 0 = Isnull((select is_date_correlation_view from sys.views o where o.object_id =  d.object_id), 0)
						)
					begin
					COMMIT TRANSACTION
						raiserror(15336,-1,-1, @objname)
						return 1
					end
			end
		else if @objtype = 'object'
		begin
			-- Check for Dependencies: No RENAME or CHANGEOWNER of OBJECT when exists:
				if exists (select * from sys.sql_dependencies d where
					d.referenced_major_id = @objid		-- A dependency on this object
						AND d.class > 0		-- that is enforced
						AND @objid <> d.object_id		-- that isn't a self-reference (self-references don't use object name)
						-- filter dependencies where the dependent object d.object_id is a date correlation view.
						AND 0 = Isnull((select is_date_correlation_view from sys.views o where o.object_id =  d.object_id), 0)
						-- And isn't a reference from a child object (also don't use object name)			
						-- As we might not have permission on the dependent object, we list all the child
						-- objects of the object to be renamed and make sure that child object id is not the depending object here.
						AND 0 = (select count(*) from sys.objects o where o.parent_object_id = @objid and o.object_id = d.object_id)
						)
					begin
					COMMIT TRANSACTION
						raiserror(15336,-1,-1, @objname)
						return 1
					end
			end
		-- WITH DEFERRED RESOLUTION, sql_dependencies  IS NOT VERY ACCURATE, SO WE ALSO
			--	RAISE THIS WARNING **UNCONDITIONALLY**, EVEN FOR NON-OBJECT RENAMES
		raiserror(15477,-1,-1)
		-- warn about dependencies...
			if (@objtype = 'objects'
			and exists (select * from sys.sql_dependencies d where 
								d.referenced_major_id = @objid
												-- filter dependencies where the dependent object d.object_id is a date correlation view.
												AND 0 = Isnull((select is_date_correlation_view from sys.views o where o.object_id =  d.object_id), 0)
												))
								raiserror(15337,-1,-1)
			--------------------------------------------------------------------------
				---------------------  PHASE 40:  Update system tables  ------------------
		--------------------------------------------------------------------------
		-- DO THE UPDATES --
			if (@objtype = 'userdatatype')						-------- change type name
		begin
			EXEC %%ScalarType(ID = @xusertype).SetName(Name = @newname)
					if @@error <> 0
				begin
					COMMIT TRANSACTION
						raiserror(15335,-1,-1,@newname,@objtypeIN)
						return 1
					end
			end
		else if (@objtype = 'object')						-------- change object name
		begin
			-- update the object name
					EXEC %%Object(ID = @objid).SetName(Name = @newname)
				if @@error <> 0
				begin
					COMMIT TRANSACTION
						raiserror(15335,-1,-1,@newname,@objtypeIN)
						return 1
					end
			end
		else if (@objtype = 'index')						-------- change index name
		begin
			-- update the index name, and change object name if cnst
					EXEC %%IndexOrStats(ObjectID = @objid, Name = @UnqualOldName).SetName(Name = @newname)
				if @@error <> 0
				begin
					COMMIT TRANSACTION
						raiserror(15335,-1,-1,@newname,@objtypeIN)
						return 1
					end
			end
		else if (@objtype = 'column')						-------- change column name
		begin
			-- Use DBCC to check for column in use by check-constraint, computed-column, etc
				-- THIS IS NOT A DOCUMENTED DBCC: DO NOT USE DIRECTLY!
				DBCC RENAMECOLUMN ( @OwnAndObjName, @UnqualOldName, @newname )
			end
		COMMIT TRANSACTION
		-- Success --
			return 0 -- sp_rename
