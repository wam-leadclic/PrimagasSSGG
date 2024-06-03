@isTest
private class TEST_WSPreferencias
{
	private static Integer NUM_LEADS 	= 10;
	private static Integer NUM_ACCOUNTS = 10;

	@isTest 
	static void sinEmail() 
	{
		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = '';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('400', r.resultado.codigo);
		System.assertEquals('El email no es correcto', r.resultado.texto);
	}

	@isTest 
	static void emailIncorrecto() 
	{
		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = 'test0@test';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('400', r.resultado.codigo);
		System.assertEquals('El email no es correcto', r.resultado.texto);
	}

	@isTest 
	static void noExisteLeadNiContacto() 
	{
		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = 'test0@test.com';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('404', r.resultado.codigo);
		System.assertEquals('No se ha encontrado ningun registro con ese email.', r.resultado.texto);
	}

	@isTest 
	static void noExisteLeadNiContacto_LimpiezaDeEmail() 
	{
		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = 'test0@test-test.com';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('404', r.resultado.codigo);
		System.assertEquals('No se ha encontrado ningun registro con ese email.', r.resultado.texto);
	}

	@isTest 
	static void existenLeads() 
	{
		List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);
		insert candidatosList;

		List<Id> fixedSearchResults = new List<Id>();
	 	for(Lead candidato : candidatosList)
	 	{
	 		fixedSearchResults.add(candidato.Id);
	 	}
       	Test.setFixedSearchResults(fixedSearchResults);

		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = 'test0@test.com';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('300', r.resultado.codigo);
		System.assertEquals('Se han encontrado varios registros con el mismo email', r.resultado.texto);
	}

	@isTest 
	static void existenContactos() 
	{
		List<Account> accountsList = Util.generarCuentas(NUM_ACCOUNTS, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		List<Contact> contactsList = Util.generarContactos(1, 0, accountsList);
		insert contactsList;

	 	List<Id> fixedSearchResults = new List<Id>();
	 	for(Contact contacto : contactsList)
	 	{
	 		fixedSearchResults.add(contacto.Id);
	 	}
       	Test.setFixedSearchResults(fixedSearchResults);

		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = 'test0@test.com';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('300', r.resultado.codigo);
		System.assertEquals('Se han encontrado varios registros con el mismo email', r.resultado.texto);
	}

	@isTest 
	static void existe1LeadY1Contacto() 
	{
		List<Lead> candidatosList = Util.generarCandidatos(1, 0);
		insert candidatosList;

		List<Account> accountsList = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		List<Contact> contactsList = Util.generarContactos(1, 0, accountsList);
		insert contactsList;

	 	List<Id> fixedSearchResults = new List<Id>();
	 	for(Contact contacto : contactsList)
	 	{
	 		fixedSearchResults.add(contacto.Id);
	 	}
	 	for(Lead candidato : candidatosList)
	 	{
	 		fixedSearchResults.add(candidato.Id);
	 	}
       	Test.setFixedSearchResults(fixedSearchResults);

		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = 'test0@test.com';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('300', r.resultado.codigo);
		System.assertEquals('Se han encontrado varios registros con el mismo email', r.resultado.texto);
	}

	@isTest 
	static void existe1Lead() 
	{
		List<Lead> candidatosList = Util.generarCandidatos(1, 0);
		insert candidatosList;

		List<Id> fixedSearchResults = new List<Id>();
	 	for(Lead candidato : candidatosList)
	 	{
	 		fixedSearchResults.add(candidato.Id);
	 	}
       	Test.setFixedSearchResults(fixedSearchResults);

		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = 'test0@test.com';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('200', r.resultado.codigo);
		System.assertEquals('Email enviado', r.resultado.texto);
	}

	@isTest 
	static void existe1Contacto() 
	{
		List<Account> accountsList = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		List<Contact> contactsList = Util.generarContactos(1, 0, accountsList);
		insert contactsList;

	 	List<Id> fixedSearchResults = new List<Id>();
	 	for(Contact contacto : contactsList)
	 	{
	 		fixedSearchResults.add(contacto.Id);
	 	}
       	Test.setFixedSearchResults(fixedSearchResults);

		WSPreferencias.Cliente c = new WSPreferencias.Cliente();
		c.email = 'test0@test.com';

		Test.startTest();

		String jDatos = WSPreferencias.getCliente(c);
		
		Test.stopTest();

		WSPreferencias.Respuesta r = (WSPreferencias.Respuesta) JSON.deserialize(jDatos, WSPreferencias.Respuesta.class);

		System.assertEquals('200', r.resultado.codigo);
		System.assertEquals('Email enviado', r.resultado.texto);
	}
}