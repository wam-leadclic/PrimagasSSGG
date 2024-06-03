@isTest
public class TEST_Nav2sfdc_Clientes_Confirmacion {
	
	static testMethod void testPeticionWSConfirmarClientes()
	{
		RecordType clienteExistenteRecordType = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');

		System.debug('Tipo cuenta personal: '+clienteExistenteRecordType.Id);
		
		List<String> listaIdsCuentas = new List<String>();
		
		Account cuenta1 = new Account();
		cuenta1.Name = 'NombreEmpresa1';
		cuenta1.RecordTypeId = clienteExistenteRecordType.Id;
		cuenta1.Id_Navision__c = 'NTS-01';
		cuenta1.Pendiente_de_confirmar__c = true;
		
		AccountUtil.semaforoUpdate = false;
		insert cuenta1;
		
		listaIdsCuentas.add(cuenta1.Id);
		
		Account cuenta2 = new Account();
		cuenta2.Name = 'NombreEmpresa2';
		cuenta2.RecordTypeId = clienteExistenteRecordType.Id;
		cuenta2.Id_Navision__c = 'NTS-02';
		cuenta2.Pendiente_de_confirmar__c = true;
		insert cuenta2;
		AccountUtil.semaforoUpdate = true;
		
		listaIdsCuentas.add(cuenta2.Id);
		
		Test.startTest();
		//En esta ocasión le pasamos los Ids de salesforce tanto de las direcciones como de las cuentas - Actualicación
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl());
		Nav2sfdc_Clientes_Confirmacion batchClientes = new Nav2sfdc_Clientes_Confirmacion();
    	batchClientes.execute(null);
    	Test.stopTest();  
    	 
    	//Comprobamos que se ha puesto el campo a false
    	List<Account> listaCuentas = [select Pendiente_de_confirmar__c from Account where Id in: listaIdsCuentas];
		for(Account cuenta : listaCuentas)
		{
			System.assertEquals(cuenta.Pendiente_de_confirmar__c,false);
		}
		
		System.assertEquals(listaCuentas.size(),2);
	}


}