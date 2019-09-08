//	------------------------------------------------------------------------------
//	Title......: MVC ONE
//	Description: Práctica sobre MVC y WDO
//	Date.......: 04/08/2019
//
//	{% LoadHRB( '/lib/mercury/core_lib.hrb' )	%}	//	Loading core
//	{% LoadHRB( '/lib/mercury/mercury.hrb' ) 	%}	//	Loading system MVC Mercury
//	{% LoadHRB( '/lib/wdo/wdo_lib.hrb' ) 		%}	//	Loading system WDO Web Database Objects
//	
//	------------------------------------------------------------------------------


FUNCTION Main()

	LOCAL oApp  := App()

	//	Configuramos nuestra Aplicacion
	
		oApp:cTitle	:= AP_GetEnv( 'APP_TITLE' )
		oApp:lLog	:= .f.

	//	Configuramos las Rutas
		//			     		Method	,  ID							, Mascara							, Controller/View	
							
		//	Basic pages...					
			oApp:oRoute:Map( 'GET'	, 'default'						, '/'								, 'main.view' )
			oApp:oRoute:Map( 'GET'	, 'help'						, '?'								, 'help.prg' )		
				
		//	Modules...					
			oApp:oRoute:Map( 'GET' 	, 'basic'						, 'basic'							, 'default@basic/basic.prg' )				


		//	Customer (ABM)		
			oApp:oRoute:Map( 'GET' 	, 'abm.customer'				, 'abm/customer'					, 'default@abm/customer.prg' )	
			oApp:oRoute:Map( 'POST' 	, 'abm.customer.edit'			, 'abm/customer/edit'				, 'edit@abm/customer.prg' )	
			oApp:oRoute:Map( 'POST' 	, 'abm.customer.save'			, 'abm/customer/save'				, 'save@abm/customer.prg' )	
			oApp:oRoute:Map( 'POST' 	, 'abm.customer.delete'			, 'abm/customer/delete'				, 'delete@abm/customer.prg' )				

			
		//	Customer (CRUD)		
			oApp:oRoute:Map( 'GET' 	, 'tables.customer'				, 'tables/customer'					, 'default@tables/customer.prg' )				
			oApp:oRoute:Map( 'POST' 	, 'tables.customer_page'		, 'tables/customer'					, 'page@tables/customer.prg' )
			oApp:oRoute:Map( 'GET' 	, 'tables.customer.find'		, 'tables/customer/(zip)'			, 'find@tables/customer.prg' )				
			oApp:oRoute:Map( 'GET'	, 'tables.customer.go'			, 'tables/customer/go/(keyno)'		, 'go@tables/customer.prg' )				
			oApp:oRoute:Map( 'GET'	, 'tables.customer.edit'		, 'tables/customer/edit/(recno)'	, 'edit@tables/customer.prg' )				
			oApp:oRoute:Map( 'GET'	, 'tables.customer.add'			, 'tables/customer/add'				, 'add@tables/customer.prg' )				
			oApp:oRoute:Map( 'POST'	, 'tables.customer.update'		, 'tables/customer/update'			, 'update@tables/customer.prg' )				
			oApp:oRoute:Map( 'POST'	, 'tables.customer.delete'		, 'tables/customer/delete'			, 'delete@tables/customer.prg' )							

			
	//	Iniciamos el sistema
		oApp:Init()
		

RETU NIL

{% include( AP_GETENV( 'PATH_APP' ) + "/config_db.prg" ) %}