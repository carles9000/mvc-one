#include 'hbclass.ch'

#define TOPSCOPE           0
#define BOTTOMSCOPE        1

//	-----------------------------------------------------------	//


CLASS TDatatable

	DATA oDb 
	DATA cPath 							INIT hb_GetEnv( "PRGPATH" ) 
	DATA cTable 						INIT ''
	DATA cIndex 						INIT ''
	
	DATA cFocus
	
	DATA cTag							INIT ''
	DATA cFieldKey						INIT ''
	DATA lAssoc							INIT .T.


	DATA aFields 						INIT {=>}
	DATA aStruct 						INIT {}
	DATA hRow 							INIT {=>}
	
	DATA hCfg							INIT { 'wdo' => 'DBF' }


	METHOD  New() 						CONSTRUCTOR
	METHOD  Open()

	
	METHOD  ConfigDb( hCfg )	
	METHOD  AddField( cField ) 		INLINE ::aFields[ cField ] := ''	
   
	METHOD  RecCount()
	METHOD  GetRecno( nRecno )
	METHOD  Row()						INLINE ::hRow
	METHOD  Update( hFields )
	METHOD  Delete( nRecno )
	
	METHOD  Load()
	METHOD  Blank()
	METHOD  LoadPageData( nRecs, nRecnoStart )
	METHOD  LoadPage( o )
	METHOD  Go( o )
	METHOD  Find( o )
	METHOD  Seek( uValue, cTag, lSoftSeek )
	
	METHOD  Value2Format( cKey, uValue )
	METHOD  Value2String( cKey, uValue )
   
ENDCLASS

METHOD New() CLASS TDatatable

	Config_Db()

RETU SELF

METHOD Open() CLASS TDatatable
	
	IF ::hCfg[ 'wdo' ] == 'DBF'
	
		IF ValType( ::oDb ) == 'O' .AND. ::oDb:lOpen
			::hRow := ::Load( ::lAssoc )	
			RETU .T.
		ENDIF

		::oDb := WDO():Dbf( ::cTable, ::cIndex, .F. )		
			::oDb:cPath := ::cPath
			::oDb:Open()
			
		
		IF ::oDb:lOpen	
			::oDb:Focus( ::cTag )
			::aStruct := (::oDb:cAlias)->( DbStruct() )			
		ENDIF

		::hRow := ::Load()	
	
	ELSE
	
	ENDIF
	
RETU NIL

//	Pendiente para configurar DBs

METHOD ConfigDb( hCfg ) CLASS TDatatable

	::hCfg := hCfg 

RETU NIL


METHOD RecCount() CLASS TDatatable

	LOCAL nTotal 
	LOCAL n

	IF ::hCfg[ 'wdo' ] == 'DBF'
	
		nRecno  := ::oDb:Recno()
		count to nTotal
		::oDb:Goto( nRecno )
		
	ELSE	

		
	ENDIF
	
RETU nTotal

//	Buscamos por la clave definida en TAG

METHOD getRecno( nRecno, lAssoc ) CLASS TDatatable

	LOCAL hReg 
	LOCAL lFound := .F.
	LOCAL cSql, hRes
	
	__defaultNIL( @lAssoc, ::lAssoc )
	
	IF ::hCfg[ 'wdo' ] == 'DBF'	
	
		::oDb:Focus( ::cTag )
		
		::oDb:Goto( nRecno ) 
		
		lFound := IF( !::oDb:Eof(), .T., .F. ) 
		
		IF lFound		
			::hRow 	:= ::Load( lAssoc )
		ELSE
			::hRow 	:= ::Blank( lAssoc )
			nRecno 	:=  0
		ENDIF
		
		IF lAssoc 			
			::hRow[ '_recno' ] :=  nRecno 
		ELSE
			Aadd( ::hRow , nRecno )
		ENDIF

	ELSE
	
		
	ENDIF
	
RETU lFound

METHOD Load( lAssoc ) CLASS TDatatable

	LOCAL nI, cField 
	LOCAL uReg, uData, nRecno, nKeyNo
	
	__defaultNIL( @lAssoc, ::lAssoc )
	
	IF lAssoc 		
		uReg := {=>}			
	ELSE			
		uReg := {}		
	ENDIF	
	
	IF ::hCfg[ 'wdo' ] == 'DBF'				

		FOR nI := 1 TO Len( ::aFields )
			
			cField := HB_HKeyAt( ::aFields, nI ) 

			uData	:= ::oDb:FieldGet( cField )
			
			uData 	:= ::Value2String( uData )				

			IF lAssoc 
				uReg[ cField ] :=  uData				
			ELSE
				Aadd( uReg, uData )			
			ENDIF
			
		NEXT
		
		//	Añadimos RECNO/KEYNO a los datos 
		
		nRecno := IF( (::oDb:cAlias)->( EOF()) , 0, (::oDb:cAlias)->( Recno() ) )
		nKeyNo := IF( (::oDb:cAlias)->( EOF()) , 0, (::oDb:cAlias)->( OrdKeyNo() ) )
		
		IF lAssoc 			
			uReg[ '_recno' ] :=  nRecno
			uReg[ '_keyno' ] :=  nKeyNo
		ELSE
			Aadd( uReg , nRecno )
			Aadd( uReg , nKeyNo )
		ENDIF
	
	ELSE
	
	
	ENDIF

RETU uReg

METHOD Blank( lAssoc ) CLASS TDatatable

	LOCAL nI, cField 
	LOCAL uReg 
	
	__defaultNIL( @lAssoc, ::lAssoc )	
	
	::oDb:Last()
	::oDb:next()		//	EOF() + 1 

	uReg := ::Load( lAssoc )

RETU uReg

METHOD Go( o ) CLASS TDatatable

	LOCAL hData := {=>}
	
		//	Key Class
		
			hData['method'] 				:= o:oRequest:Method() 
			hData['myget'] 				:= o:oRequest:GetAll() 
					
		//	Key Datatable
			hData['draw'] 					:= 1
			hData['start'] 				:= o:oRequest:Get( 'recno', 1, 'N' )			//	hData['hPost']['start']
			hData['recordsTotal'] 			:= o:oRequest:Get( 'length', 10, 'N' )	//	10
			hData['recordsFiltered'] 		:= ::RecCount()			
			hData['data'] 					:= ::LoadPageData( hData )
			
RETU hData 

METHOD LoadPage( o ) CLASS TDatatable

	LOCAL aRows	:= {}
	LOCAL hData := {=>}
	
	IF valtype( o ) == 'O' .AND. o:ClassName() == 'TCONTROLLER'	//	Objeto oController
	
		//	Key Class
		
			hData['method'] 				:= o:oRequest:Method() 
			hData['hPost'] 				:= AP_PostPairs()
			hData['mypost'] 				:= o:oRequest:PostAll() 
			hData['search'] 				:= o:oRequest:Post( 'search[value]' ) 
			hData['recno'] 				:= o:oRequest:Post( 'recno', 0, 'N' ) 
		
		//	Key Datatable
			hData['draw'] 					:= o:oRequest:Post( 'draw' )			
			hData['start'] 				:= o:oRequest:Post( 'start', 1, 'N' )		
			hData['pageLength'] 			:= o:oRequest:Post( 'pageLength', 5, 'N' )
			hData['recordsTotal'] 			:= o:oRequest:Post( 'length', 5, 'N' )	
			hData['recordsFiltered'] 		:= ::RecCount()			
			
			hData['data'] 					:= ::LoadPageData( hData )
	
	ENDIF
	
RETU hData

METHOD LoadPageData( hData ) CLASS TDatatable

	LOCAL nI		:= 0
	LOCAL aRows	:= {}
	LOCAL n
	
	IF ::hCfg[ 'wdo' ] == 'DBF'		
			
		::oDb:Focus( ::cTag )
		
		nPage := Int( hData['recno'] / hData['recordsTotal'] ) 						
		
			IF hData['search'] == '' 
			
				IF hData['start'] == 0 			

				ELSE
				
					(::oDb:cAlias)->( OrdKeyGoTo( (hData['start'] + 1 ) ) )

				ENDIF
				
			ELSE			
			
				(::oDb:calias)->( ordScope( TOPSCOPE 	, hData['search'] ) )
				(::oDb:calias)->( ordScope( BOTTOMSCOPE	, hData['search'] ) )
					
				COUNT TO n 
					
				hData[ 'recordsFiltered' ] := n
				
				IF hData['start'] > 0 		
					
					(::oDb:cAlias)->( OrdKeyGoTo( (hData['start'] + 1 ) ) )				
					
				ELSE 
					
					::oDb:First()

					hData[ 'start' ] := 1
					
				ENDIF
				
			ENDIF
		
		
	
		
		//WHILE !::oDb:Eof() .AND. nI < hData['pageLength']
		WHILE !::oDb:Eof() .AND. nI < hData['recordsTotal']
	
			Aadd( aRows, ::Load() )
			
			::oDb:Next()
			
			nI++
		
		END				

	ELSE

	
	ENDIF

RETU aRows




METHOD Update( nRecno, hFields ) CLASS TDatatable

	LOCAL cSql, oRs, hRes, o
	LOCAL nTotal 
	LOCAL nI
	LOCAL lUpdate := .F.
	LOCAL lLock
	LOCAL aPair
	LOCAL uKey, uValue
	
	IF ::hCfg[ 'wdo' ] == 'DBF' 			

		IF nRecno > 0
		
			::oDb:GoTo( nRecno ) 

			lLock := ::oDb:Rlock()
		
		ELSE

			lLock 	:= ::oDb:Append()	

			nRecno 	:= (::oDb:cAlias)->( Recno() )
		
		ENDIF		

	
		IF lLock

			FOR nI := 1 TO len( hFields )			

				aPair := HB_HPairAt( hFields, nI )				

				uValue := ::Value2Format( aPair[1], aPair[2] )				
			
				::oDb:FieldPut( aPair[1], uValue )				 				
				
			NEXT
	
			::oDb:Unlock()		
		
			lUpdate := .T.
			
			//	Si se ha salvado vamos a calcular el displaynStart que es la página desde 
			//	donde va a cargar el TDtatable. Se ha de buscar el ultimo registro de la
			//	página anterior a la pagina del registro actualizado.
			//	Para eso:
			//				
			//		Go to recno acutalizado y recuperamos el registro logico
			//		Dividir rl registro logico / num rows por pagina y cojer parte entera
			//		Multiplicar parte entera por num rows por pagina
			//	-------------------------------------------------------------------------
			
			nRecno := (::oDb:cAlias)->( OrdKeyNo() )
			
			
		ENDIF
	
	ELSE
	
	
	
	ENDIF
	
	
RETU lUpdate

METHOD Delete( cId ) CLASS TDatatable

	LOCAL lDelete := .F.


	IF ::hCfg[ 'wdo' ] == 'DBF'	
		
		::oDb:Goto( cId ) 
		
		IF ::oDb:Rlock()
		
			::oDb:Delete()
			::oDb:Unlock()
			
			lDelete := .T.
		ENDIF	

	ELSE
	
	
	
	ENDIF
	
	
RETU lDelete

METHOD Find( uValue, cTag ) CLASS TDatatable

	LOCAL nKeyNo := 0
	
	IF ::hCfg[ 'wdo' ] == 'DBF'		
			
		::oDb:Focus( cTag  )
	
		IF ( ::oDb:Seek( uValue, .F.  ) )
		
			::oDb:Focus( ::cTag  )
			
			nKeyNo := (::oDb:cAlias)->( OrdKeyNo() )
			
		ENDIF
		
	ELSE
	
	
	ENDIF
					
RETU nKeyNo


METHOD Seek( uValue, cTag, lSoftSeek ) CLASS TDatatable

	LOCAL nKeyNo := 0
	LOCAL nRecno := 0
	LOCAL lFound := .F.
	
	__defaultNIL( @lSoftSeek, .F. )
	
	IF ::hCfg[ 'wdo' ] == 'DBF'		
			
		::oDb:Focus( cTag  )		

		//n := Set( _SET_SOFTSEEK, .T. )
		//Set( _SET_SOFTSEEK, n )

		lFound := ::oDb:Seek( uValue, .T.  ) 													
		
		IF lFound		
			::hRow 	:= ::Load()
		ELSE
			::hRow 	:= ::Blank()			
		ENDIF
		
	ELSE
	
	
	ENDIF
					
RETU lFound
					
					
METHOD Value2Format( cKey, uValue ) CLASS TDatatable

	LOCAL nPos, cType
	LOCAL xValue := ''	
	LOCAL n 

	cKey := Upper( cKey )
	
	nPos := Ascan( ::aStruct, {|x| x[1] == cKey } )	

	
	IF nPos > 0
		
		cType := ::aStruct[ nPos ][2]

		
		DO CASE 
			CASE cType == 'C' ;  xValue := alltrim(uValue)
			CASE cType == 'N' ;  xValue := Val( uValue )
			CASE cType == 'D' 
				n := Set( _SET_DATEFORMAT, "yyyy-mm-dd" )
				xValue := If( valtype(uValue) == 'D', uValue, CToD( uValue ) )
				Set( _SET_DATEFORMAT, n )
			CASE cType == 'L' ;  xValue := If( valtype(uValue) == 'L', uValue, if( uValue == 'true', .T., .F. ) )
			CASE cType == '+' ;  xValue := If( valtype(uValue) == 'N', uValue, Val( uValue ) )
			OTHERWISE
				xValue := alltrim(valtochar( uValue ))
		ENDCASE	

	ELSE
	
	ENDIF	


RETU xValue


//	Para editar en la web todo es String.

METHOD Value2String( uValue ) CLASS TDatatable

	LOCAL cType		:= valtype( uValue )
	LOCAL xValue    := ''
		
		DO CASE 
			CASE cType == 'C' ;  xValue := alltrim(uValue)
			CASE cType == 'N' ;  xValue := ltrim(str( uValue ))
			CASE cType == 'D' 
				Set( _SET_DATEFORMAT, "yyyy-mm-dd" )
				xValue := DToC( uValue ) 
			CASE cType == 'L' ;  xValue := if( uValue == .T., 'true', 'false' )
			
			OTHERWISE
				xValue := alltrim(valtochar( uValue ))
		ENDCASE	


RETU xValue