@isTest
public class TEST_ContactUtil
{
	private static Integer NUM_ACCOUNTS 	= 10;
	private static Integer NUM_CONTACTOS 	= 1; //Por cuenta

	/*Prueba que al crear un contacto se crean registros persona con los mismos datos y que los contactos referencian estos registros*/
	@isTest
	static void test_crearPersona()
	{
		List<Contact> contactsList = creacionDeContactos();
		
		Test.startTest();
		insert contactsList;
		Test.stopTest();

		validacion(0);	
	}

	/*Prueba que al crear un contacto se crean registros persona con los mismos datos y que los contactos referencian estos registros*/
	@isTest
	static void test_crearPersona_SegundoMail()
	{
		List<Contact> contactsList = creacionDeContactos();
		
		for(Contact contacto : contactsList)
		{
			contacto.Otra_direcci_n_de_correo_electr_nico__c = contacto.Email;
			contacto.Email = '';
		}

		Test.startTest();
		insert contactsList;
		Test.stopTest();

		validacion(1);	
	}

	/*Prueba que al crear un contacto se crean registros persona con los mismos datos y que los contactos referencian estos registros*/
	@isTest
	static void test_crearPersona_TercerMail()
	{
		List<Contact> contactsList = creacionDeContactos();
		
		for(Contact contacto : contactsList)
		{
			contacto.Otra_direcci_n_de_correo_electr_nico_2__c = contacto.Email;
			contacto.Email = '';
		}

		Test.startTest();
		insert contactsList;
		Test.stopTest();

		validacion(2);		
	}

	private static List<Contact> creacionDeContactos()
	{
		List<Account> accountsList = Util.generarCuentas(NUM_ACCOUNTS, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		return Util.generarContactos(NUM_CONTACTOS, 0, accountsList);
	}

	private static void validacion(Integer caso)
	{
		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c, Hash__c FROM Individual]);
		System.assert(!personasMap.isEmpty());

		for(Contact contacto : [SELECT Id, IndividualId, FirstName, LastName, Email, Otra_direcci_n_de_correo_electr_nico__c, Otra_direcci_n_de_correo_electr_nico_2__c FROM Contact])
		{
			if(contacto.IndividualId != null && personasMap.containsKey(contacto.IndividualId))
			{
				System.assertEquals(personasMap.get(contacto.IndividualId).FirstName 	, contacto.FirstName);
				System.assertEquals(personasMap.get(contacto.IndividualId).LastName 	, contacto.LastName);
				if(caso == 0)
				{
					System.assertEquals(personasMap.get(contacto.IndividualId).Email__c		, contacto.Email);
				}else if(caso == 1)
				{
					System.assertEquals(personasMap.get(contacto.IndividualId).Email__c		, contacto.Otra_direcci_n_de_correo_electr_nico__c);
				}else
				{
					System.assertEquals(personasMap.get(contacto.IndividualId).Email__c		, contacto.Otra_direcci_n_de_correo_electr_nico_2__c);
				}
				System.assert(String.isNotBlank(personasMap.get(contacto.IndividualId).Hash__c));
				
			}else
			{
				System.assert(false, 'El contacto debería tener el lookup relleno');
			}
		}
	}

	/*Prueba que si se actualizan los datos del contacto se actualizan los de la persona a la que referencia*/
	@isTest
	static void test_actualizarPersona()
	{
		List<Account> accountsList = Util.generarCuentas(NUM_ACCOUNTS, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		List<Contact> contactsList = Util.generarContactos(NUM_CONTACTOS, 0, accountsList);
		insert contactsList;

		for(Integer i = 0 ; i < NUM_CONTACTOS*NUM_ACCOUNTS ; i++)
		{
			contactsList[i].FirstName 	= 'UpdateFirstName'+i;
			contactsList[i].LastName  	= 'UpdateLastName'+i;
			contactsList[i].Email 		= 'Update'+i+'@test.com';
		}

		Test.startTest();
		update contactsList;
		Test.stopTest();

		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c FROM Individual]);
		System.assert(!personasMap.isEmpty());

		for(Contact contacto : [SELECT Id, IndividualId, FirstName, LastName, Email FROM Contact])
		{
			if(contacto.IndividualId != null && personasMap.containsKey(contacto.IndividualId))
			{
				System.assertEquals(personasMap.get(contacto.IndividualId).FirstName 	, contacto.FirstName);
				System.assertEquals(personasMap.get(contacto.IndividualId).LastName 	, contacto.LastName);
				System.assertEquals(personasMap.get(contacto.IndividualId).Email__c		, contacto.Email);
			}else
			{
				System.assert(false, 'El contacto debería tener el lookup relleno');
			}
		}
	}

	/*Prueba que si se borra un contacto se borra la persona a la que esta relacionada*/
	@isTest
	static void test_borrarPersona()
	{
		List<Account> accountsList = Util.generarCuentas(NUM_ACCOUNTS, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		List<Contact> contactsList = Util.generarContactos(NUM_CONTACTOS, 0, accountsList);
		insert contactsList;

		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c FROM Individual]);
		System.assert(!personasMap.isEmpty());
		System.assertEquals(NUM_CONTACTOS*NUM_ACCOUNTS, personasMap.size());

		Test.startTest();
		delete contactsList;
		Test.stopTest();

		Map<Id, Individual> personasAfterDeleteMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c FROM Individual]);
		System.assert(personasAfterDeleteMap.isEmpty());
	}

	/*Prueba que si se crea un contacto para una cuenta de empresa existente, el individual con el que está relacionado se crea con las preferencias marcadas*/
	@isTest
	static void test_aceptarPreferencias()
	{
		List<Account> accountsList = Util.generarCuentas(NUM_ACCOUNTS, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		List<Contact> contactsList = Util.generarContactos(NUM_CONTACTOS, 0, accountsList);
		insert contactsList;

		List<Individual> personasList = [SELECT Id, Promociones__c, Encuestas_satisfaccion__c FROM Individual];
		System.assert(!personasList.isEmpty());
		System.assertEquals(NUM_ACCOUNTS*NUM_CONTACTOS , personasList.size());

		for(Individual persona : personasList)
		{
			System.assertEquals(false, persona.Promociones__c);
			System.assertEquals(false, persona.Encuestas_satisfaccion__c);
		}

		for(Account cuenta : accountsList)
		{
			cuenta.RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id;
		}
		update accountsList;

		List<Contact> newContactsList = Util.generarContactos(NUM_CONTACTOS, NUM_CONTACTOS, accountsList);

		Test.startTest();
		insert newContactsList;
		Test.stopTest();

		List<Individual> personasList2 = [SELECT Id, Promociones__c, Encuestas_satisfaccion__c FROM Individual];
		System.assert(!personasList2.isEmpty());
		System.assertEquals(NUM_ACCOUNTS*NUM_CONTACTOS*2 , personasList2.size());

		Integer personasTrue 	= 0;
		Integer personasFalse 	= 0;
		
		for(Individual persona : personasList2)
		{
			if(persona.Promociones__c && persona.Encuestas_satisfaccion__c)
			{
				personasTrue++;
			}else if(!persona.Promociones__c && !persona.Encuestas_satisfaccion__c)
			{
				personasFalse++;
			}
		}
		//Al convertir la cuenta los existentes ya estarán a true. 
		System.assertEquals(NUM_ACCOUNTS*NUM_CONTACTOS*2, personasTrue);
		System.assertEquals(0, personasFalse);
	}
}