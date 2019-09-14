CLASS Customer

	METHOD New() 	CONSTRUCTOR

	
	METHOD Default()
	METHOD Control()
	
	
	METHOD Edit()
	METHOD Save()
	METHOD Delete()
	


ENDCLASS

METHOD New( o ) CLASS Customer	


RETU SELF


METHOD Default( o ) CLASS Customer

	App():Set( 'event', 'default' )

	o:View( 'form/customer.view' )

RETU NIL


METHOD Control( o ) CLASS Customer

	LOCAL cAction := o:oRequest:Post( 'action' )

	DO CASE
	
		CASE cAction == 'back' 		;	::Default( o )			
		CASE cAction == 'search' 	;	::Edit( o )		
		CASE cAction == 'save' 		;	::Save( o )			
		CASE cAction == 'delete' 	;	::Delete( o )			
	
	ENDCASE 	

RETU NIL

METHOD Edit( o ) CLASS Customer

	LOCAL oCusto 			:= TCusto():New()
	LOCAL oValidator 		:= TValidator():New()	
	LOCAL hRoles 			:= { 'zip' => 'required' }
	LOCAL lFound, cId				
	

	//	Validacion de datos
	
		IF ! oValidator:Run( hRoles )
			App():Set( 'event'		, 'default' )
			App():Set( 'validator' 	, oValidator:ErrorMessages() )
			o:View( 'form/customer.view' )					
			RETU NIL
		ENDIF		
	
	//	Recuperacion de datos
	
		cZip	:= o:oRequest:post( 'zip' )
		
		
	//	Tratamiento de datos	
	    		
		lFound			:= oCusto:Seek( cZip, 'ZIP' )
	
		hRow 			:= oCusto:Row()
		hRow[ 'zip' ]	:= cZip
	
	
	//	Respuesta solicitada...
	
		IF lFound	
			App():Set( 'event'	, 'edit' )
		ELSE
			App():Set( 'event'	, 'edit_new' )
		ENDIF
		
		App():Set( 'found'	, lFound )
		App():Set( 'row'		, hRow   )

		o:View( 'form/customer.view' )			


RETU NIL 


METHOD Save( o ) CLASS Customer

	LOCAL oCusto 			:= TCusto():New()
	LOCAL oValidator 		:= TValidator():New()	
	LOCAL hRoles 			:= { 'id' => 'required|numeric', 'age' => 'numeric|len:2' }
	LOCAL hData				:= {=>}
	LOCAL lSuccess 			:= .F.	

		
	//	Validacion de datos
	
		IF ! oValidator:Run( hRoles )
			App():Set( 'event'		, 'default' )
			App():Set( 'validator' 	, oValidator:ErrorMessages() )
			o:View( 'form/customer.view' )					
			RETU NIL
		ENDIF	

	//	Recuperacion de datos
	
		cId					:= o:oRequest:post( 'id', 0, 'N' )	
		hData[ '_recno' ]	:= cId
		hData[ 'zip' ]		:= o:oRequest:post( 'zip' )
		hData[ 'first' ]	:= o:oRequest:post( 'first' )
		hData[ 'last' ]		:= o:oRequest:post( 'last' )
		hData[ 'age' ]		:= o:oRequest:post( 'age' )
		hData[ 'hiredate' ]	:= o:oRequest:post( 'hiredate' )
		hData[ 'notes' ] 	:= o:oRequest:post( 'notes' )		

		
	//	Save datas...

		lSuccess 	:= oCusto:Update( @cId, hData )	

		IF lSuccess		
			App():Set( 'event'	, 'updated' )
		ELSE
			App():Set( 'event'	, 'error_update' )
		ENDIF

		App():Set( 'row'		, hData   )		
		
	//	Respuesta solicitada...

		o:View( 'form/customer.view' )										

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
		
		IF lSuccess		
			App():Set( 'event'	, 'deleted' )
		ELSE
			App():Set( 'event'	, 'error_delete' )
		ENDIF			
		
	//	Respuesta solicitada...

		o:View( 'form/customer.view' )			

RETU NIL

{% include( AP_GETENV( 'PATH_APP' ) + "/src/controller/common/tdatatable.prg" ) %}
{% include( AP_GETENV( 'PATH_APP' ) + "/src/model/tcusto.prg" ) %}