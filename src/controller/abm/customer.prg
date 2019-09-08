CLASS Customer

	METHOD New() 	CONSTRUCTOR

	
	METHOD Default()
	
	METHOD Edit()
	METHOD Save()
	METHOD Delete()


ENDCLASS

METHOD New( o ) CLASS Customer	


RETU SELF


METHOD Default( o ) CLASS Customer

	o:View( 'abm/customer.view' )

RETU NIL


METHOD Edit( o ) CLASS Customer

	LOCAL oCusto 			:= TCusto():New()
	LOCAL oValidator 		:= TValidator():New()	
	LOCAL hRoles 			:= { 'zip' => 'required' }
	LOCAL lFound, cId				
	

	//	Validacion de datos
	
		IF ! oValidator:Run( hRoles )
			o:oResponse:SendJson( { 'success' => .F., 'msg' => oValidator:ErrorMessages() } )					
			RETU NIL
		ENDIF		
	
	//	Recuperacion de datos
	
		cZip	:= o:oRequest:post( 'zip' )
		
		
	//	Tratamiento de datos	
	    		
		lFound			:= oCusto:Seek( cZip, 'ZIP' )
	
		hRow 			:= oCusto:Row()
		hRow[ 'zip' ]	:= cZip
	

	//	Respuesta solicitada...
	
		o:oResponse:SendJson( { 'success' => .T., 'found' => lFound, 'row' => hRow } )

RETU NIL 


METHOD Save( o ) CLASS Customer

	LOCAL oCusto 			:= TCusto():New()
	LOCAL oValidator 		:= TValidator():New()	
	LOCAL hRoles 			:= { 'id' => 'required|numeric', 'age' => 'numeric|len:2' }
	LOCAL hData				:= {=>}
	LOCAL lSuccess 			:= .F.	

		
	//	Validacion de datos
	
		IF ! oValidator:Run( hRoles )
			o:oResponse:SendJson( { 'success' => .F., 'msg' => oValidator:ErrorMessages() } )					
			RETU NIL
		ENDIF	

	//	Recuperacion de datos
	
		cId					:= o:oRequest:post( 'id', 0, 'N' )	
		hData[ 'zip' ]		:= o:oRequest:post( 'zip' )
		hData[ 'first' ]	:= o:oRequest:post( 'first' )
		hData[ 'last' ]	:= o:oRequest:post( 'last' )
		hData[ 'age' ]		:= o:oRequest:post( 'age' )
		hData[ 'hiredate' ]:= o:oRequest:post( 'hiredate' )
		hData[ 'notes' ] 	:= o:oRequest:post( 'notes' )		

		
	//	Save datas...

		lSuccess 	:= oCusto:Update( @cId, hData )					
		
	//	Respuesta solicitada...

		o:oResponse:SendJson( { 'success' => lSuccess } )										

RETU NIL

METHOD Delete( o ) CLASS Customer

	LOCAL oCusto 			:= TCusto():New()
	LOCAL oValidator 		:= TValidator():New()	
	LOCAL hRoles 			:= { 'id' => 'required|numeric' }
	LOCAL lSuccess 		:= .F.

	//	Validacion de datos

		IF ! oValidator:Run( hRoles )
			o:oResponse:SendJson( { 'success' => .F., 'msg' => oValidator:ErrorMessages() } )					
			RETU NIL
		ENDIF	
		
	//	Procesar peticion...

		cId 		:= o:oRequest:post( 'id', 0, 'N' )	

		lSuccess 	:= oCusto:Delete( cId )
		
	//	Respuesta solicitada...

		o:oResponse:SendJson( { 'success' => lSuccess } )			

RETU NIL

{% include( AP_GETENV( 'PATH_APP' ) + "/src/controller/common/tdatatable.prg" ) %}
{% include( AP_GETENV( 'PATH_APP' ) + "/src/model/tcusto.prg" ) %}