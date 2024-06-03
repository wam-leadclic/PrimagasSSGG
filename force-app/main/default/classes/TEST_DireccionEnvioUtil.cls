@isTest
public class TEST_DireccionEnvioUtil {
	
	// Método de prueba para probar la actualización de una Dirección de envío
	static testMethod void testProbarMetodosUpdateDireccionEntregaTrigger()
	{
		System.Debug('## before testProbarMetodosUpdateAccountTrigger');
		
		RecordType tiposRegistro = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		cuenta.RecordTypeId = tiposRegistro.Id;
		cuenta.Id_Navision__c = 'idNav';
		insert cuenta;
		
		Direcci_n_de_entrega__c direccionEntrega = new Direcci_n_de_entrega__c();
		direccionEntrega.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccionEntrega.Direccion_2__c = 'C/Tivoli nº28 4ºB';
		direccionEntrega.Codigo_Postal__c = '48007';
		direccionEntrega.Poblacion__c = 'Bilbao';
		direccionEntrega.Provincia__c = 'Vizcaya';
		
		//Hay que mirarlo
		//direccionEntrega.C_digo_tarifa__r.Id_Navision__c = dirNav.ADCodePriceDiscount;
		//direccionEntrega.Id_Navision__c = '900000002'; 
		direccionEntrega.cuenta__c = cuenta.Id;
		insert direccionEntrega;
		
		//Creamos un contacto con estado Activado para que el cliente pase a ser de tipo Cliente Existente
		//Se comprueba que sea cliente existente
		/*Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		insert contrato;
		
		contrato.Status = 'Activado';
		
		//Desactivamos AccountUtil y ContractUtil
		ContractUtil.semaforoUpdate = false;
		AccountUtil.semaforoUpdate = false;
		update contrato;
		AccountUtil.semaforoUpdate = true;
		ContractUtil.semaforoUpdate = true;*/
		
		/*List<Account> listaCuentas = [select Id_Navision__c from Account where Id=:cuenta.Id];
		System.assertEquals(listaCuentas.size(),1);
		System.assert(String.IsEmpty(listaCuentas[0].Id_Navision__c));*/
		
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(direccionEntrega.Id, cuenta.Id));
		direccionEntrega.Poblacion__c = 'Llodio';
		update direccionEntrega;
		Test.stopTest();
		
		List<Account> listaCuentas = [select Fecha_ltima_Sync__c from Account where Id=:cuenta.Id];
		System.assertEquals(listaCuentas.size(),1);
		System.assert(listaCuentas[0].Fecha_ltima_Sync__c!=null);

		System.Debug('## after testProbarMetodosUpdateAccountTrigger');
		
		List<Direcci_n_de_entrega__c> listaDireccionesEntrega = [select Fecha_ultima_Sync__c from Direcci_n_de_entrega__c where Id=:direccionEntrega.Id];
		
		//Comprobamos que se ha actualizado con el Id de Nav
		System.assert(listaDireccionesEntrega[0].Fecha_ultima_Sync__c!=null);
	}

}