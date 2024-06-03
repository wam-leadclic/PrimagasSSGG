@isTest
private class TEST_LecturasContadorPageController 
{
	//Se comprueba que se han obtenido 2 lecturas de contador al hacer la peticion
	//Los semaforos se utilizan para que no salte el trigger de cuenta y direccion de entrega para sincronizar el cliente
	@isTest 
	static void obtenerLecturasContador() 
	{
		RecordType tiposRegistro = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
		
		//Creación/Insercion de cuenta
		List<Account> cuenta = Util.generarCuentas(1, 0, tiposRegistro.Id);

		cuenta[0].Id_Navision__c = 'idNav';


		AccountUtil.semaforoUpdate = false;
		insert cuenta;
		AccountUtil.semaforoUpdate = true;
		
		//Creación/Insercion de direccion de entrega
		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
			
		direccion.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccion.Direccion_2__c = 'C/Tivoli nº28 5ºB';
		direccion.Codigo_Postal__c = '48007';
		direccion.Poblacion__c = 'Bilbao';
		direccion.Provincia__c = 'Vizcaya';
		direccion.cuenta__c = cuenta[0].Id;
		direccion.Id_Navision__c = '1';

		DireccionEnvioUtil.semaforoUpdate = false;
		insert direccion;
		DireccionEnvioUtil.semaforoUpdate = true;

		//Establecemos la respuesta falsa de donde se van a recoger las lecturas de contador como si se enviaran desde Navision
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl());

		//Establecemos la página
		Test.startTest();

        PageReference pageLecturasContador = Page.LecturasContadorPage;
		pageLecturasContador.getParameters().put('id', direccion.Id);
		Test.setCurrentPage(pageLecturasContador);

		LecturasContadorPageController controller = new LecturasContadorPageController();

		Test.stopTest();

		System.assertEquals(2, controller.lecturasContador.size());
	}
	
	@isTest 
	static void obtenerLecturasContadorLWC() 
	{
		RecordType tiposRegistro = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
		
		//Creación/Insercion de cuenta
		List<Account> cuenta = Util.generarCuentas(1, 0, tiposRegistro.Id);

		cuenta[0].Id_Navision__c = 'idNav';


		AccountUtil.semaforoUpdate = false;
		insert cuenta;
		AccountUtil.semaforoUpdate = true;
		
		//Creación/Insercion de direccion de entrega
		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
			
		direccion.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccion.Direccion_2__c = 'C/Tivoli nº28 5ºB';
		direccion.Codigo_Postal__c = '48007';
		direccion.Poblacion__c = 'Bilbao';
		direccion.Provincia__c = 'Vizcaya';
		direccion.cuenta__c = cuenta[0].Id;
		direccion.Id_Navision__c = '1';

		DireccionEnvioUtil.semaforoUpdate = false;
		insert direccion;
		DireccionEnvioUtil.semaforoUpdate = true;

		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl());
		List<Lectura_contador__c> lecturas;
		Test.startTest();
		ActionResult result = LecturasContadorPageController.getReads(direccion.Id);
		lecturas = (List<Lectura_contador__c>) JSON.deserialize(result.data.toString(), List<Lectura_contador__c>.class);
		Test.stopTest();

		System.assertEquals(2, lecturas.size());
	}
}