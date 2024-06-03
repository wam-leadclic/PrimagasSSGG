@isTest
private class TEST_PedidosDeGasPageController {
	
	//Se comprueba que se han obtenido 2 pedidos de gas al hacer la peticion
	//Los semaforos se utilizan para que no salte el trigger de cuenta y direccion de entrega para sincronizar el cliente
	@isTest 
	static void obtenerPedidosDeGas() 
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
		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
			
		direccion.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccion.Direccion_2__c = 'C/Tivoli nº28 5ºB';
		direccion.Codigo_Postal__c = '48007';
		direccion.Poblacion__c = 'Bilbao';
		direccion.Provincia__c = 'Vizcaya';
		direccion.cuenta__c = cuenta.Id;
		direccion.Id_Navision__c = '1';

		DireccionEnvioUtil.semaforoUpdate = false;
		insert direccion;
		DireccionEnvioUtil.semaforoUpdate = true;

		//Establecemos la respuesta falsa de donde se van a recoger los pedidos de gas como si se enviaran desde Navision
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl());

		//Establecemos la página
		Test.startTest();

        PageReference pagePedidosGas = Page.PedidosDeGasPage;
		pagePedidosGas.getParameters().put('id', direccion.Id);
		Test.setCurrentPage(pagePedidosGas);

		PedidosDeGasPageController controller = new PedidosDeGasPageController();

		Test.stopTest();

		System.assertEquals(2, controller.pedidosDeGas.size());
	}

	@isTest
	public static void obtenerPedidosDeGasLWC() {
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
		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
			
		direccion.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccion.Direccion_2__c = 'C/Tivoli nº28 5ºB';
		direccion.Codigo_Postal__c = '48007';
		direccion.Poblacion__c = 'Bilbao';
		direccion.Provincia__c = 'Vizcaya';
		direccion.cuenta__c = cuenta.Id;
		direccion.Id_Navision__c = '1';

		DireccionEnvioUtil.semaforoUpdate = false;
		insert direccion;
		DireccionEnvioUtil.semaforoUpdate = true;

		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl());

		Test.startTest();
		ActionResult result = PedidosDeGasPageController.getOrders(direccion.Id);
		List<Pedido_de_gas__c> ordersGas = (List<Pedido_de_gas__c>) JSON.deserialize(result.data.toString(), List<Pedido_de_gas__c>.class);
		Test.stopTest();

		System.assertEquals(false, result.hasError);
		System.assertEquals(2, ordersGas.size());
	}

}