@isTest
public class TEST_SyncNav {
	
	static testMethod void  testSincronizarClientes()
    {
    	RecordType clienteExistenteRecordType = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
		
    	Account cuenta = new Account();
    	cuenta.Name = 'Test 1';
		//cuenta.FirstName = 'ALMACENES PROPIOS';
		//cuenta.LastName = 'ALMACENES PROPIOS 2';
		cuenta.BillingStreet = 'Crta Nacional N-232 Km. 373';
		cuenta.City__c = 'QUINTO';
		cuenta.Codigo_Postal__c = '50770';
		cuenta.Provincia__c = 'Vizcaya';
		cuenta.Pais__c = 'ES';
		cuenta.Phone = '695724132';
		cuenta.Fax = '944422342';
		cuenta.E_mail__c = 'quinto2@primagas.es';
		cuenta.Id_Fiscal__c = 'A61128014';
		cuenta.Cod_terminos_pago__c = '01';
		cuenta.Cod_forma_pago__c = '03';
		//clienteNav.PaymentTermsStdOrd;
		//clienteNav.PaymentTermsFuelOrd;
		//clienteNav.PaymentTermsCrdCardOrd; 
		cuenta.D_as_pago__c = '12';
		cuenta.Cod_periodo_no_pago__c = '13';
		cuenta.RecordTypeId = clienteExistenteRecordType.Id;
		cuenta.IBAN__c = 'ES9520802926515599673627';
		//Datos bancarios
		cuenta.Swift__c = 'SWIFT';
		
		insert cuenta;
		
		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
			
		direccion.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccion.Direccion_2__c = 'C/Tivoli nº28 5ºB';
		direccion.Codigo_Postal__c = '48007';
		direccion.Poblacion__c = 'Bilbao';
		direccion.Provincia__c = 'Vizcaya';
		direccion.cuenta__c = cuenta.Id;
		//direccion.C_digo_tarifa__r.Id_Navision__c;
		direccion.Id_Navision__c = 'idNavisio';
		
		insert direccion;
		
		List<String> idsCuentas = new List<String>();
		idsCuentas.add(cuenta.Id);
		
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(direccion.Id, cuenta.Id));
		
		Test.startTest();
		SyncNav.SincronizarClientesFuture(idsCuentas);
		Test.stopTest();

		//CUENTA
		List<Account> listaCuentas = [select Id, Id_Navision__c, Id_banco_navisio__c from Account where Id=:cuenta.Id];
		System.assertEquals(listaCuentas.size(),1);
		
		//Se comprueba si el Id_Navision__c recibido del servidor está actualizado en SF
		//System.assertEquals(listaCuentas[0].Id_Navision__c,'90000000');
		
		//DIRECCIONES DE ENTREGA
		List<Direcci_n_de_entrega__c> listaDirecciones = [select Id, Id_Navision__c from Direcci_n_de_entrega__c where Id=:direccion.Id];
		System.assertEquals(listaDirecciones.size(),1);
		
		//Se comprueba si el Id_Navision__c recibido del servidor está actualizado en SF
		System.assertEquals(listaDirecciones[0].Id_Navision__c,'31');
		
		//DATOS BANCARIOS
		//Se comprueba si el Id_banco_navisio__c recibido del servidor está actualizado en SF
		//System.assertEquals(listaCuentas[0].Id_banco_navisio__c,'2');
		
    }
    
    /*static testMethod void testSincronizarContratos()
    {  
    	Account cuenta = new Account();
    	cuenta.Name = 'nombreCuenta';
    	insert cuenta;
		
		Contract contrato = new Contract();
		contrato.Name = 'nombreContrato';
		contrato.AccountId = cuenta.Id;
		insert contrato; 
		
		List<String> idsContratos = new List<String>();
		idsContratos.add(contrato.Id);
		
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(contrato.Id));
		
		Test.startTest();
		SyncNav.SincronizarContratosFuture(idsContratos);
		Test.stopTest();

		Contract contrato2 = [select Fecha_ltima_Sync__c from Contract where Id =: contrato.Id][0];
		System.assert(contrato2.Fecha_ltima_Sync__c!=null);
    }*/

    //////
    static testMethod void  testSincronizarClientesSinIdNavEnRespuesta()
    {
    	RecordType clienteExistenteRecordType = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');

    	Account cuenta = new Account();
    	cuenta.Name = 'Test 1';
		//cuenta.FirstName = 'ALMACENES PROPIOS';
		//cuenta.LastName = 'ALMACENES PROPIOS 2';
		cuenta.BillingStreet = 'Crta Nacional N-232 Km. 373';
		cuenta.City__c = 'QUINTO';
		cuenta.Codigo_Postal__c = '50770';
		cuenta.Provincia__c = 'Vizcaya';
		cuenta.Pais__c = 'ES';
		cuenta.Phone = '695724132';
		cuenta.Fax = '944422342';
		cuenta.E_mail__c = 'quinto2@primagas.es';
		cuenta.Id_Fiscal__c = 'A61128014';
		cuenta.Cod_terminos_pago__c = '01';
		cuenta.Cod_forma_pago__c = '03';
		//clienteNav.PaymentTermsStdOrd;
		//clienteNav.PaymentTermsFuelOrd;
		//clienteNav.PaymentTermsCrdCardOrd; 
		cuenta.D_as_pago__c = '12';
		cuenta.Cod_periodo_no_pago__c = '13';
		cuenta.RecordTypeId = clienteExistenteRecordType.Id;
		cuenta.IBAN__c = 'ES9520802926515599673627';
		
		insert cuenta;

		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
			
		direccion.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccion.Direccion_2__c = 'C/Tivoli nº28 5ºB';
		direccion.Codigo_Postal__c = '48007';
		direccion.Poblacion__c = 'Bilbao';
		direccion.Provincia__c = 'Vizcaya';
		direccion.cuenta__c = cuenta.Id;
		//direccion.C_digo_tarifa__r.Id_Navision__c;
		direccion.Id_Navision__c = 'idNavisio';
		
		insert direccion;
		
		List<String> idsCuentas = new List<String>();
		idsCuentas.add(cuenta.Id);
		
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(direccion.Id, ''));
		
		Test.startTest();
		SyncNav.SincronizarClientesFuture(idsCuentas);
		Test.stopTest();

		//CUENTA
		List<Account> listaCuentas = [select Id, Id_Navision__c, Id_banco_navisio__c from Account where Id=:cuenta.Id];
		System.assertEquals(listaCuentas.size(),1);
		
		//Se comprueba que el Id_Navision__c recibido del servidor no está actualizado en SF
		System.assertEquals(null, listaCuentas[0].Id_Navision__c);
		
		List<Log__c> listaLogs = [SELECT Id, Descripcion__c FROM Log__c WHERE Error__c=true];
		System.debug('##Logs: ' + listaLogs);
		System.assertEquals(1, listaLogs.size());
		System.assertEquals(listaLogs[0].Descripcion__c, 'Falta el id de Navision en la respuesta al sincronizar el cliente. Id Salesforce:');
    }

    static testMethod void  testSincronizarClientesSinRespuesta()
    {
    	RecordType clienteExistenteRecordType = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
		
    	Account cuenta = new Account();
    	cuenta.Name = 'Test 1';
		//cuenta.FirstName = 'ALMACENES PROPIOS';
		//cuenta.LastName = 'ALMACENES PROPIOS 2';
		cuenta.BillingStreet = 'Crta Nacional N-232 Km. 373';
		cuenta.City__c = 'QUINTO';
		cuenta.Codigo_Postal__c = '50770';
		cuenta.Provincia__c = 'Vizcaya';
		cuenta.Pais__c = 'ES';
		cuenta.Phone = '695724132';
		cuenta.Fax = '944422342';
		cuenta.E_mail__c = 'quinto2@primagas.es';
		cuenta.Id_Fiscal__c = 'A61128014';
		cuenta.Cod_terminos_pago__c = '01';
		cuenta.Cod_forma_pago__c = '03';
		//clienteNav.PaymentTermsStdOrd;
		//clienteNav.PaymentTermsFuelOrd;
		//clienteNav.PaymentTermsCrdCardOrd; 
		cuenta.D_as_pago__c = '12';
		cuenta.Cod_periodo_no_pago__c = '13';
		cuenta.RecordTypeId = clienteExistenteRecordType.Id;
		cuenta.IBAN__c = 'ES9520802926515599673627';
		
		insert cuenta;

		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
			
		direccion.Direccion__c = 'C/Tivoli nº28 4ºB';
		direccion.Direccion_2__c = 'C/Tivoli nº28 5ºB';
		direccion.Codigo_Postal__c = '48007';
		direccion.Poblacion__c = 'Bilbao';
		direccion.Provincia__c = 'Vizcaya';
		direccion.cuenta__c = cuenta.Id;
		//direccion.C_digo_tarifa__r.Id_Navision__c;
		direccion.Id_Navision__c = 'idNavisio';
		
		insert direccion;
		
		List<String> idsCuentas = new List<String>();
		idsCuentas.add(cuenta.Id);
		
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl('', ''));
		
		Test.startTest();
		SyncNav.SincronizarClientesFuture(idsCuentas);
		Test.stopTest();

		//CUENTA
		List<Account> listaCuentas = [select Id, Id_Navision__c, Id_banco_navisio__c from Account where Id=:cuenta.Id];
		System.assertEquals(listaCuentas.size(),1);
		
		List<Log__c> listaLogs = [SELECT Id, Descripcion__c FROM Log__c WHERE Error__c=true];
		System.debug('##Logs: ' + listaLogs);
		System.assertEquals(1, listaLogs.size());
		System.assertEquals(listaLogs[0].Descripcion__c, 'No se ha recibido respuesta al sincronizar el cliente');
    }
    //////
}