@isTest
private class TEST_LecturaContadorUtil 
{
	public static Direcci_n_de_entrega__c direccion;	
	//Este metodo comprueba que se ha creado correctamente la lectura de contador. La llamada se probara en SyncNav y NavWSUtil
	//Los semaforos se utilizan para que no salte el trigger de cuenta y direccion de entrega para sincronizar el cliente
	@isTest 
	static void creacionDeLecturasCorrecta() 
	{
		prepararEntorno();

		//Creación/Insercion de lectura de contador (Solo se va a enviar 1 cada vez. No se va a hacer una insercion de varios pedidos de golpe)
		List<Lectura_contador__c> lecturasContadorList = new List<Lectura_contador__c>();
		Lectura_contador__c lecturaContador;
		for(Integer i = 0; i < 1 ; i++)
		{
			lecturaContador = new Lectura_contador__c(
				Direccion_de_entrega__c = direccion.Id,
				Lectura__c 	= 50
				);
			lecturasContadorList.add(lecturaContador);
		}

		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(0));
		
		//Al hacer la insercion se envia el pedido de gas directamente a navision
		Test.startTest();
		insert lecturasContadorList;
		Test.stopTest();

		List<Lectura_contador__c> lecturasList = [SELECT Id FROM Lectura_contador__c];

		System.assertEquals(0, lecturasList.size());

		List<Log__c> logList = [SELECT Id FROM Log__c];

		System.assertEquals(0, logList.size());
	}

	//Este metodo comprueba que ha habido algun error de login
	@isTest 
	static void creacionDeLecturasErrorLogin() 
	{
		prepararEntorno();

		//Creación/Insercion de lectura de contador (Solo se va a enviar 1 cada vez. No se va a hacer una insercion de varios pedidos de golpe)
		List<Lectura_contador__c> lecturasContadorList = new List<Lectura_contador__c>();
		Lectura_contador__c lecturaContador;
		for(Integer i = 0; i < 1 ; i++)
		{
			lecturaContador = new Lectura_contador__c(
				Direccion_de_entrega__c = direccion.Id,
				Lectura__c 	= 50
				);
			lecturasContadorList.add(lecturaContador);
		}

		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(1));
		
		//Al hacer la insercion se envia el pedido de gas directamente a navision
		Test.startTest();
		insert lecturasContadorList;
		Test.stopTest();

		List<Lectura_contador__c> lecturasList = [SELECT Id FROM Lectura_contador__c];

		System.assertEquals(0, lecturasList.size());

		List<Log__c> logList = [SELECT Id FROM Log__c];

		System.assertEquals(1, logList.size());
	}

	//Este metodo comprueba que ha habido algun error al enviar la lectura
	@isTest 
	static void creacionDeLecturasIncorrecta() 
	{
		prepararEntorno();

		//Creación/Insercion de lectura de contador (Solo se va a enviar 1 cada vez. No se va a hacer una insercion de varios pedidos de golpe)
		List<Lectura_contador__c> lecturasContadorList = new List<Lectura_contador__c>();
		Lectura_contador__c lecturaContador;
		for(Integer i = 0; i < 1 ; i++)
		{
			lecturaContador = new Lectura_contador__c(
				Direccion_de_entrega__c = direccion.Id,
				Lectura__c 	= 50
				);
			lecturasContadorList.add(lecturaContador);
		}

		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(2));
		
		//Al hacer la insercion se envia el pedido de gas directamente a navision
		Test.startTest();
		insert lecturasContadorList;
		Test.stopTest();

		List<Lectura_contador__c> lecturasList = [SELECT Id FROM Lectura_contador__c];

		System.assertEquals(0, lecturasList.size());

		List<Log__c> logList = [SELECT Id FROM Log__c];

		System.assertEquals(1, logList.size());
	}


	public static void prepararEntorno()
	{

		RecordType tiposRegistro = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
		
		//Creación/Insercion de cuenta
		Account cuenta = new Account();
		cuenta.Name = 'Test';
		cuenta.Id_Navision__c = 'idNav';
		cuenta.RecordTypeID = tiposRegistro.Id;
		
		AccountUtil.semaforoUpdate = false;
		insert cuenta;
		AccountUtil.semaforoUpdate = true;
		
		//Creación/Insercion de direccion de entrega
		direccion = new Direcci_n_de_entrega__c();
			
		direccion.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccion.Direccion_2__c = 'C/Tivoli nº28 5ºB';
		direccion.Codigo_Postal__c = '48007';
		direccion.Poblacion__c = 'Bilbao';
		direccion.Provincia__c = 'Vizcaya';
		direccion.cuenta__c = cuenta.Id;
		direccion.Id_Navision__c = 'idNavisio';
		
		DireccionEnvioUtil.semaforoUpdate = false;
		insert direccion;
		DireccionEnvioUtil.semaforoUpdate = true;
	}
}