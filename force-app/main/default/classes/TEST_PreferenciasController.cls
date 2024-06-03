@isTest
private class TEST_PreferenciasController 
{
	private static Integer NUM_LEADS = 1;

	@isTest 
	static void test_Preferencias_info() 
	{
		List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);
		insert candidatosList;

		List<Individual> personasList = new List<Individual>([SELECT Id, FirstName, LastName, Email__c, Hash__c FROM Individual]);
		System.assert(!personasList.isEmpty());

		Test.startTest();

		PageReference preferenciasPage = Page.Preferencias;
		Test.setCurrentPage(preferenciasPage);

		PreferenciasController controller = new PreferenciasController();

		controller.showInfo1();
		controller.showInfo2();

		Test.stopTest();

		System.assertEquals(true, controller.info1);
		System.assertEquals(true, controller.info2);
	}

	@isTest 
	static void test_Preferencias_sinHash() 
	{
		List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);
		insert candidatosList;

		List<Individual> personasList = new List<Individual>([SELECT Id, FirstName, LastName, Email__c, Hash__c FROM Individual]);
		System.assert(!personasList.isEmpty());

		Test.startTest();

		PageReference preferenciasPage = Page.Preferencias;
		Test.setCurrentPage(preferenciasPage);

		PreferenciasController controller = new PreferenciasController();

		Test.stopTest();

		System.assertEquals(null, controller.persona);
	}

	@isTest 
	static void test_Preferencias_hashIncorrecto() 
	{
		List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);
		insert candidatosList;

		List<Individual> personasList = new List<Individual>([SELECT Id, FirstName, LastName, Email__c, Hash__c FROM Individual]);
		System.assert(!personasList.isEmpty());

		Test.startTest();

		PageReference preferenciasPage = Page.Preferencias;
		Test.setCurrentPage(preferenciasPage);

		//Indicamos el hash de la persona
		ApexPages.currentPage().getParameters().put('HashId','123456789');

		PreferenciasController controller = new PreferenciasController();

		Test.stopTest();

		System.assertEquals(null, controller.persona);
	}

	@isTest 
	static void test_Preferencias_actualizacion() 
	{
		List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);
		insert candidatosList;

		List<Individual> personasList = new List<Individual>([SELECT Id, FirstName, LastName, Email__c, Hash__c, Modificado__c, Modificado_desde__c, Encuestas_satisfaccion__c, Promociones__c, Fecha_encuestas__c, Fecha_promociones__c  FROM Individual]);
		System.assert(!personasList.isEmpty());
		System.debug('Personas List '+personasList);
		Test.startTest();

		PageReference preferenciasPage = Page.Preferencias;
		Test.setCurrentPage(preferenciasPage);

		Individual persona = personasList[0];
		//Indicamos el hash de la persona
		ApexPages.currentPage().getParameters().put('HashId', persona.Hash__c);

		PreferenciasController controller = new PreferenciasController();

		controller.promocionesDespues	= true;
		controller.encuestasDespues		= true;

		controller.actualizarDatosCliente();

		Test.stopTest();

		Individual personaActualizada = [SELECT Id, Email__c, Hash__c, Modificado__c, Modificado_desde__c, Encuestas_satisfaccion__c, Promociones__c, Fecha_encuestas__c, Fecha_promociones__c  
																FROM Individual 
																WHERE Id =: persona.Id LIMIT 1];

		System.assert(String.isBlank(personaActualizada.Hash__c));
		System.assertEquals(true, personaActualizada.Modificado__c);
		System.assertEquals('Site', personaActualizada.Modificado_desde__c);
		System.assertEquals(true, personaActualizada.Encuestas_satisfaccion__c);
		System.assertEquals(true, personaActualizada.Promociones__c);
		System.assertEquals(Date.today(), Date.newinstance(personaActualizada.Fecha_encuestas__c.year(), personaActualizada.Fecha_encuestas__c.month(), personaActualizada.Fecha_encuestas__c.day()));
		System.assertEquals(Date.today(), Date.newinstance(personaActualizada.Fecha_promociones__c.year(), personaActualizada.Fecha_promociones__c.month(), personaActualizada.Fecha_promociones__c.day()));
	}
}