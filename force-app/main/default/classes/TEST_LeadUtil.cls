@isTest
public class TEST_LeadUtil
{
    private static Integer NUM_LEADS = 10;

	@isTest
	static void TEST_insertarDatosConversionCuentaYOportunidad()
	{
		//Creo el candidato con un socio de candidato asociado, energía actual //y equipo actual
		Product2 producto = new Product2();
		producto.Name = 'Producto prueba';
		producto.Description = 'Descripción producto prueba';
		producto.Unidad__c = 'KG';
		insert producto;

		Lead candidato = new Lead();
		candidato.LastName = 'Candidato prueba';
		candidato.Status = '1. Candidato';
		candidato.Fecha_deteccion__c = Date.today();
		candidato.Producto__c = producto.Id;
		candidato.Company = 'Compañía test';
		candidato.Contato_alt1__c = 'Contacto alternativo test';
		candidato.Tel_fono_contacto_alt_1__c = '666666666';
		candidato.Contact_Address__c = 'Calle test';
		candidato.Codigo_Postal__c = '12345';
		candidato.Contact_City__c = 'Bilbao';
		candidato.Contact_State__c = 'Vizcaya';
		candidato.PaisContacto__c = 'España';
		candidato.Actividad__c = 'Actividad test';
		candidato.Sub_actividad__c = 'Subactividad test';
        candidato.N_mero_Cliente_Anterior__c = 11112;
		insert candidato;

		Energia_actual__c energia = new Energia_actual__c();
		energia.Tipo_energia__c = 'Fuel';
		energia.Consumo__c = 10;
		energia.Candidato__c = candidato.Id;
		insert energia;

		/*Equipo_actual__c equipo = new Equipo_actual__c();
		equipo.Name = 'Equipo prueba';
		equipo.Candidato__c = candidato.Id;
		equipo.Nueva_oferta__c = nuevaOferta.Id;
		insert equipo;*/

		List<Recordtype> tipoRegistroPartner = [SELECT Id, Name, DeveloperName FROM Recordtype WHERE SobjectType = 'Account' and DeveloperName = 'Partner'];

		Account cuentaSocio = new Account();
		cuentaSocio.Name = 'Socio prueba';
		cuentaSocio.Id_Fiscal__c = '11111111A';
		cuentaSocio.RecordTypeId = tipoRegistroPartner[0].Id;
		insert cuentaSocio;

		Socio_de_candidato__c socioCandidato = new Socio_de_candidato__c();
		socioCandidato.Candidato__c = candidato.Id;
		socioCandidato.Funcion__c = 'Comercial';
		socioCandidato.Socio__c = cuentaSocio.Id;
		insert socioCandidato;

		//Convierto el candidato
		Test.startTest();
		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(candidato.Id);
		lc.setConvertedStatus('Convertido');
		Database.LeadConvertResult lcr = Database.convertLead(lc);
		Test.stopTest();
		System.assert(lcr.isSuccess());	

		Id idCuentaConversion = lcr.getAccountId();
		System.debug('idCuentaConversion: ' + idCuentaConversion);
		Id idOportunidadConversion = lcr.getOpportunityId();
		System.debug('idOportunidadConversion: ' + idOportunidadConversion);

		/*//Compruebo que se ha creado un socio estándar entre la cuenta creada de la conversión y el socio del socio de candidato del candidato origen
		List<Partner> socioConversion = [SELECT Id, AccountFromId, AccountToId, Role FROM Partner WHERE AccountFromId=: idCuentaConversion];
		System.assertEquals(socioConversion.size(),1);
		System.assertEquals(socioConversion[0].AccountToId,cuentaSocio.Id);
		System.assertEquals(socioConversion[0].Role,'Comercial');*/

		//Compruebo que se ha creado el contacto alternativo asociado a la cuenta creada de la conversión
		List<Contact> listaContactos = [SELECT Id, Name, Phone FROM Contact WHERE AccountId =: idCuentaConversion];
		System.assertEquals(2, listaContactos.size());
		System.assert( (listaContactos[0].Name == candidato.Contato_alt1__c && listaContactos[0].Phone == candidato.Tel_fono_contacto_alt_1__c) || 
						(listaContactos[1].Name == candidato.Contato_alt1__c  && listaContactos[1].Phone == candidato.Tel_fono_contacto_alt_1__c) );

		//Compruebo que se ha creado la dirección de entrega asociada a la cuenta creada de la conversión
		List<Direcci_n_de_entrega__c> direccion = [SELECT Direccion__c, Codigo_Postal__c, Poblacion__c, Provincia__c, Pais__c, Actividad_1__c, 
															Actividad_2__c FROM Direcci_n_de_entrega__c WHERE Cuenta__c =: idCuentaConversion];
		System.assertEquals(1, direccion.size());
		System.assert(direccion[0].Direccion__c == candidato.Contact_Address__c && direccion[0].Codigo_Postal__c == candidato.Codigo_Postal__c && 
						direccion[0].Poblacion__c == candidato.Contact_City__c  && direccion[0].Provincia__c == candidato.Contact_State__c && 
						direccion[0].Pais__c == candidato.PaisContacto__c  && direccion[0].Actividad_1__c == candidato.Actividad__c && 
						direccion[0].Actividad_2__c == candidato.Sub_actividad__c);

		//Compruebo que el campo oportunidad de la energía actual del candidato origen se ha rellenado con la oportunidad creada de la conversión
		energia = [SELECT Id, Name, Oportunidad__c FROM Energia_actual__c WHERE Id=: energia.Id];
		System.assertEquals(energia.Oportunidad__c, idOportunidadConversion);

		/*//Compruebo que el campo oportunidad del equipo actual del candidato origen se ha rellenado con la oportunidad creada de la conversión
		equipo = [SELECT Id, Name, Oportunidad__c FROM Equipo_actual__c WHERE Id=: equipo.Id];
		System.assertEquals(equipo.Oportunidad__c, idOportunidadConversion);*/

		//Compruebo que se ha creado un socio estándar entre la oportunidad creada de la conversión y el socio del socio de candidato del candidato origen
		List<Partner> socioConversion = [SELECT Id, OpportunityId, AccountToId, Role FROM Partner WHERE OpportunityId=: idOportunidadConversion];
		System.assertEquals(socioConversion.size(),1);
		System.assertEquals(socioConversion[0].AccountToId,cuentaSocio.Id);
		System.assertEquals(socioConversion[0].Role,'Comercial');
	}

	/*Prueba que al crear un candidato se crean registros persona con los mismos datos y que los candidatos referencian estos registros*/
	@isTest
	static void test_crearPersona()
	{
		List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);

		Test.startTest();
		insert candidatosList;
		Test.stopTest();

		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c, Hash__c FROM Individual]);
		System.assert(!personasMap.isEmpty());

		for(Lead candidato : [SELECT Id, IndividualId, FirstName, LastName, Email FROM Lead])
		{
			if(candidato.IndividualId != null && personasMap.containsKey(candidato.IndividualId))
			{
				System.assertEquals(personasMap.get(candidato.IndividualId).FirstName 	, candidato.FirstName);
				System.assertEquals(personasMap.get(candidato.IndividualId).LastName 	, candidato.LastName);
				System.assertEquals(personasMap.get(candidato.IndividualId).Email__c	, candidato.Email);
				System.assert(String.isNotBlank(personasMap.get(candidato.IndividualId).Hash__c));
			}else
			{
				System.assert(false, 'El candidato debería tener el lookup relleno');
			}
		}
	}

	/*Prueba que si se actualizan los datos del candidato se actualizan los de la persona a la que referencia*/
	@isTest
	static void test_actualizarPersona()
	{
		List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);
		insert candidatosList;

		for(Integer i = 0 ; i < NUM_LEADS ; i++)
		{
			candidatosList[i].FirstName = 'UpdateFirstName'+i;
			candidatosList[i].LastName  = 'UpdateLastName'+i;
			candidatosList[i].Email 	= 'Update'+i+'@test.com';
		}

		Test.startTest();
		update candidatosList;
		Test.stopTest();

		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c FROM Individual]);
		System.assert(!personasMap.isEmpty());

		for(Lead candidato : [SELECT Id, IndividualId, FirstName, LastName, Email FROM Lead])
		{
			if(candidato.IndividualId != null && personasMap.containsKey(candidato.IndividualId))
			{
				System.assertEquals(personasMap.get(candidato.IndividualId).FirstName 	, candidato.FirstName);
				System.assertEquals(personasMap.get(candidato.IndividualId).LastName 	, candidato.LastName);
				System.assertEquals(personasMap.get(candidato.IndividualId).Email__c	, candidato.Email);
			}else
			{
				System.assert(false, 'El candidato debería tener el lookup relleno');
			}
		}
	}

	/*Prueba que si se borra un candidato se borra la persona a la que esta relacionada*/
	@isTest
	static void test_borrarPersona()
	{
		List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);
		insert candidatosList;

		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c FROM Individual]);
		System.assert(!personasMap.isEmpty());
		System.assertEquals(NUM_LEADS, personasMap.size());

		Test.startTest();
		delete candidatosList;
		Test.stopTest();

		Map<Id, Individual> personasAfterDeleteMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c FROM Individual]);
		System.assert(personasAfterDeleteMap.isEmpty());
	}
}