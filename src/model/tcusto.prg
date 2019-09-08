CLASS TCusto FROM TDatatable

	METHOD  New() 						CONSTRUCTOR
	
	METHOD  Config()
	
ENDCLASS

METHOD New() CLASS TCusto

	
	::cPath 			:= hb_GetEnv( "PRGPATH" ) + '/data/'
	::cTable 			:= 'customer.dbf'	
	::cIndex 			:= 'customer.cdx'	
	::cTag 				:= 'first'					//	Tag Name
	::cFieldkey		:= 'first'					//	Key Field

	::AddField( 'zip' )
	::AddField( 'first' )
	::AddField( 'last' )
	::AddField( 'street' )
	::AddField( 'state' )
	::AddField( 'hiredate' )
	::AddField( 'married' )
	::AddField( 'age' )
	::AddField( 'salary' )
	::AddField( 'notes' )
	
	::Config()

	::Open()	

RETU SELF

METHOD Config() CLASS TCusto

	//	Si no existe la tabla, la creamos...
	

	
	//	Si no existe indice lo creamos...
	
		IF ! empty( ::cIndex ) .AND. ! File( ::cPath + ::cIndex ) 
	
			o := WDO():Dbf( ::cTable, nil, .F. )
				o:cPath 		:= ::cPath
				o:lExclusive 	:= .T.
				o:Open()				
			
			IF o:lOpen 
				INDEX ON first TAG FIRST TO ( ::cPath + ::cIndex ) FOR !Deleted() 
				INDEX ON state TAG STATE TO ( ::cPath + ::cIndex ) FOR !Deleted() 
				INDEX ON zip   TAG ZIP   TO ( ::cPath + ::cIndex ) FOR !Deleted() 
			ENDIF
			
			o:Close()

		ENDIF	
	
	
RETU NIL