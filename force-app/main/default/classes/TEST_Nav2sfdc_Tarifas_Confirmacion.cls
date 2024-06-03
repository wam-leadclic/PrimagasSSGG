@isTest
public class TEST_Nav2sfdc_Tarifas_Confirmacion {
	
	static testMethod void testPeticionWSConfirmarClientes()
	{
		Pricebook2 pb1 = new Pricebook2();
		pb1.Name = 'Desc1';
		pb1.Id_Navision__c = 'IdNav1';
		pb1.Description = 'Desc1';
		pb1.Pendiente_de_confirmar__c = true;
		insert pb1;
		
		Test.startTest();
		//En esta ocasión le pasamos los Ids de salesforce tanto de las direcciones como de las cuentas - Actualicación
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl());
		Nav2sfdc_Tarifas_Confirmacion batchTarifas = new Nav2sfdc_Tarifas_Confirmacion();
    	batchTarifas.execute(null);
    	Test.stopTest();  
    	
    	//Comprobamos que se ha puesto el campo a false
    	List<Pricebook2> listaTarifas = [select Pendiente_de_confirmar__c from Pricebook2 where Id =: pb1.Id];
		for(Pricebook2 tarifa : listaTarifas)
		{
			System.assertEquals(tarifa.Pendiente_de_confirmar__c,false);
		}
		
		System.assertEquals(listaTarifas.size(),1);
	}


}