@isTest
private class TEST_BatchCrearIndividualDesdeContacto 
{ 
	private static Integer NUM_CONTACTS 			= 10;
	private static Integer NUM_CONTACTS_PER_ACCOUNT = 1;
	private static Integer NUM_ACCOUNTS 			= 10;
	
	/*Prueba que se generan los registros persona*/
    @isTest 
    static void test_generarPersonas_Contactos()
    {   
    	List<Account> accountsList = Util.generarCuentas(NUM_ACCOUNTS, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		List<Contact> contactsList = Util.generarContactos(NUM_CONTACTS_PER_ACCOUNT, 0, accountsList);
		insert contactsList;
    	
    	for(Contact contacto : contactsList)
    	{
    		contacto.Individualid = null;
    	}

       	update contactsList;

    	List<Individual> personasList = [SELECT Id FROM Individual];
    	delete personasList;

    	Test.startTest();
        Database.executeBatch(new BatchCrearIndividualDesdeContacto(), 200);
        
        Test.stopTest();

		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c, Hash__c FROM Individual]);
		System.assert(!personasMap.isEmpty());

		for(Contact contacto : [SELECT Id, IndividualId, FirstName, LastName, Email, Otra_direcci_n_de_correo_electr_nico__c, Otra_direcci_n_de_correo_electr_nico_2__c FROM Contact])
		{
			if(contacto.IndividualId != null && personasMap.containsKey(contacto.IndividualId))
			{
				System.assertEquals(personasMap.get(contacto.IndividualId).FirstName 	, contacto.FirstName);
				System.assertEquals(personasMap.get(contacto.IndividualId).LastName 	, contacto.LastName);				
				System.assertEquals(personasMap.get(contacto.IndividualId).Email__c		, contacto.Email);				
				System.assert(String.isNotBlank(personasMap.get(contacto.IndividualId).Hash__c));
				
			}else
			{
				System.assert(false, 'El contacto debería tener el lookup relleno');
			}
		}
    }
}