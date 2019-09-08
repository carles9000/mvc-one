FUNCTION Config_Db()

	LOCAL hCfg := {=>}

	
	/*	
	
	//	Config for MYSQL 
	
		hCfg[ 'wdo' ] 		:= 'MYSQL'
		hCfg[ 'server' ] 	:= 'localhost'
		hCfg[ 'user'] 		:= 'harbour'
		hCfg[ 'password' ] 	:= 'password'
		hCfg[ 'database' ] 	:= 'dbHarbour'
		hCfg[ 'port' ] 		:= 3306	
	
	*/
	
	//	Config Dbf
	
		hCfg[ 'wdo' ] 		:= 'DBF'
		
		rddSetDefault( "DBFCDX" )
		
		SET AUTOPEN OFF
		SET EXACT ON
		SET OPTIMIZE ON
		SET DELETED ON                
		SET EPOCH TO 1950                
		SET DATE FORMAT TO "dd-mm-yyyy"
		Set( _SET_SOFTSEEK, .T. )	

RETU hCfg