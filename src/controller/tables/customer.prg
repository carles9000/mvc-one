#include 'hbclass.ch'
CLASS Customer

	METHOD New() 	CONSTRUCTOR

	
	METHOD Default()
	METHOD Page()

	METHOD Edit( o, lNew )
	METHOD Insert( o )		INLINE ::Edit( o, .T. )
	METHOD Add( o )			INLINE ::Edit( o, .T. )
	
	METHOD Update()
	METHOD Delete()
	METHOD Find()
	METHOD Go()

	
ENDCLASS

METHOD New( o ) CLASS Customer	


RETU SELF


METHOD Default( o ) CLASS Customer

	LOCAL nRecno 	:= o:oRequest:Get( 'recno' )

	o:View( 'tables/customer.view', nRecno )

RETU NIL

METHOD Go( o ) CLASS Customer

	LOCAL nRecno 	:= o:oRequest:Get( 'keyno' )

	o:View( 'tables/customer.view', nRecno )

RETU NIL

METHOD Find( o ) CLASS Customer

	LOCAL cZip		:= o:oRequest:Get( 'zip' )
	LOCAL oCusto 	:= TCusto():New()
	LOCAL nRecno	:= oCusto:Find( cZip, 'ZIP' )

	IF nRecno > 0 
		nRecno := ltrim(str( nRecno))
	ELSE
		nRecno := ''
	ENDIF

	o:View( 'tables/customer.view', nRecno )

RETU NIL

METHOD Page( o ) CLASS Customer

	LOCAL oCusto 				:= TCusto():New()
	LOCAL hData 				:= oCusto:LoadPage( o )
	
	o:oResponse:SendJson( hData )	

RETU NIL 


METHOD Edit( o, lNew ) CLASS Customer

	LOCAL oCusto 			:= TCusto():New()
	LOCAL nRecno			:= o:oRequest:Get( 'recno', 0, 'N')			
	LOCAL lFound			:= .F.
	LOCAL aReg 
	
	__defaultNIL( @lNew,  .F. )

	IF lNew
		aReg 	:= oCusto:Blank()
		lFound 	:= .F.
	ELSE		
		lFound  := oCusto:getRecno( nRecno )	
		aReg 	:= oCusto:Row()	
	ENDIF	

	o:View( 'tables/customer_edit.view', aReg, lNew )	

RETU NIL



METHOD Update( o ) CLASS Customer

	LOCAL oCusto 			:= TCusto():New()
	LOCAL oValidator 		:= TValidator():New()	
	LOCAL hRoles 			:= { 'zip' => 'required', 'first' => 'string' }
	LOCAL hData			:= {=>}	
	LOCAL lSuccess 		:= .F.
	LOCAL nRecno			:= o:oRequest:post( '_recno' , 0, 'N' )
	LOCAL nDisplayStart 	:= 0
		
	//	Recuperacion de datos

		hData[ 'zip' ]		:= o:oRequest:post( 'zip' )
		hData[ 'first' ]	:= o:oRequest:post( 'first' )
		hData[ 'last' ]	:= o:oRequest:post( 'last' )
		hData[ 'city' ]	:= o:oRequest:post( 'city' )
		hData[ 'street' ]	:= o:oRequest:post( 'street' )
		hData[ 'state' ]	:= o:oRequest:post( 'state' )
		hData[ 'hiredate' ]:= o:oRequest:post( 'hiredate' )
		hData[ 'age' ]		:= o:oRequest:post( 'age' )
		hData[ 'salary' ]	:= o:oRequest:post( 'salary' )
		hData[ 'notes' ]	:= o:oRequest:post( 'notes' )
		
		
	//	Validacion de datos
	
		IF ! oValidator:Run( hRoles )
			//o:oResponse:SendJson( { 'success' => .F., 'msg' => oValidator:ErrorMessages() } )
			o:View( 'tables/customer_edit.view', hData, .F., oValidator:ErrorMessages() )			
			RETU NIL
		ENDIF		

	
	
	//	Tratamiento de datos...

		
	//	Save datas...

		lSuccess 	:= oCusto:Update( @nRecno, hData )

		IF lSuccess
		
			cUrl := Route( 'tables.customer.go' ) 
			cUrl += '/' + ltrim(str(nRecno))

			o:oResponse:Redirect( cUrl )
		ELSE
			? 'Error'
		ENDIF

	//	Respuesta solicitada...

//		o:oResponse:SendJson( { 'success' => .T., 'found' => lFound, 'row' => hRow } )	

RETU NIL

METHOD Delete( o ) CLASS Customer

	LOCAL oCusto 			:= TCusto():New()
	LOCAL oValidator 		:= TValidator():New()	
	LOCAL hRoles 			:= { 'recno' => 'required|numeric' }
	LOCAL nRecno
	LOCAL lSuccess 		:= .F.

	//	Recuperacion de datos
	
		nRecno		:= o:oRequest:post( 'recno', 0, 'N' )
		
		lDelete	:= oCusto:Delete( nRecno )								
		
	o:oResponse:SendJson( { 'success' => .T., 'delete' => lDelete } )	

	
RETU NIL


{% include( AP_GETENV( 'PATH_APP' ) + "/src/controller/common/tdatatable.prg" ) %}
{% include( AP_GETENV( 'PATH_APP' ) + "/src/model/tcusto.prg" ) %}