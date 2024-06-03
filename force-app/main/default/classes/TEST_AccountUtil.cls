@isTest
public class TEST_AccountUtil 
{
	private static Integer NUM_ACCOUNTS = 10;
	private static Integer NUM_CONTACTS = 1;

	// Método que prueba la actualización de una cuenta que ya tiene Id de navision
	static testMethod void testProbarMetodosUpdateAccountTriggerIdNavision()
	{	
		System.Debug('## before testProbarMetodosAccountTrigger');
		
		List<RecordType> tiposRegistro = new List<RecordType>([Select Id, DeveloperName from RecordType where DeveloperName = 'Cliente_existente']);

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		cuenta.Id_Navision__c = 'idNav';
		cuenta.RecordTypeID = tiposRegistro[0].Id;
		insert cuenta;
		
		Account cuentaCopia = [select Fecha_ltima_Sync__c from Account where Id=:cuenta.Id][0];
		System.assert(cuentaCopia.Fecha_ltima_Sync__c == null);
		
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl('', cuenta.Id));
		
		cuenta.Name = 'Name2';
		update cuenta;
		Test.stopTest(); 
		
		cuentaCopia = [select Fecha_ltima_Sync__c from Account where Id=:cuenta.Id][0];

		//Comprobamos que se ha sincronizado con Navision
		System.assert(cuentaCopia.Fecha_ltima_Sync__c!=null);

		System.Debug('## after testProbarMetodosAccountTrigger');
	}
	
	//Método que prueba cuando se pasa a Activo un contrato (Se prueba el trigger de la cuenta y del contrato)
	static testMethod void testProbarTodoContratoActivo()
	{
    	List<RecordType> clienteExistenteRecordType = new List<RecordType>([Select Id, DeveloperName from RecordType where DeveloperName = 'Cliente_existente' and SObjectType = 'Account']);
		
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
		
		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		insert contrato;
		
		NTLMHttpCalloutMockImpl mock = new NTLMHttpCalloutMockImpl();
		mock.idSalesforceEtCustomer = cuenta.Id;
		mock.idSalesforceAddress = direccion.Id;
		mock.idSalesforceContract = contrato.Id;
		
		
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, mock);
		
		//Se actualiza a activo el contrato y se desencadenan los triggers de cuenta y contrato
		contrato.Status = 'Activado';
		update contrato;
		Test.stopTest();
		
		
		//Sincronización de la cuenta

		//CUENTA
		List<Account> listaCuentas = [select Id, Id_Navision__c, Id_banco_navisio__c from Account where Id=:cuenta.Id];
		System.assertEquals(listaCuentas.size(),1);
		
		//Se comprueba si el Id_Navision__c recibido del servidor está actualizado en SF
		//System.assertEquals(listaCuentas[0].Id_Navision__c,'90000000');
		
		//DIRECCIONES DE ENTREGA
		List<Direcci_n_de_entrega__c> listaDirecciones = [select Id, Id_Navision__c from Direcci_n_de_entrega__c where Id=:direccion.Id];
		System.assertEquals(listaDirecciones.size(),1);
		
		//Se comprueba si el Id_Navision__c recibido del servidor está actualizado en SF
		//System.assertEquals(listaDirecciones[0].Id_Navision__c,'31');
		
		//DATOS BANCARIOS
		//Se comprueba si el Id_banco_navisio__c recibido del servidor está actualizado en SF
		//System.assertEquals(listaCuentas[0].Id_banco_navisio__c,'2');
		
		
		//Sincronización del contrato 
		
		Contract contrato2 = [select Fecha_ltima_Sync__c, Id_Navision__c from Contract where AccountId =: listaCuentas[0].Id][0];
		//System.assert(contrato2.Fecha_ltima_Sync__c != null);
    }

    /**
	* Metodo encargado de comprobar que se cambia el checkbox de cuenta a false cuando procede de una conversion de lead y 
	*que se marca la variable de clase de account util
	* @author rfernandez (17/02/2017)
	* @changes rcastanos (06/06/2019) Modificaciones para adecuarse a la eliminación de cuentas personales
	*/
    static testMethod void testDesmarcarProcedeDeConversion()
	{
		List<Account> cuenta = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);

		cuenta[0].Procede_de_conversion__c = true; 

		System.assertEquals(true, OpportunityUtil.semaforoCreacionFuncionesDeContacto);
		System.assertEquals(true, cuenta[0].Procede_de_conversion__c);

		Test.startTest();

		insert cuenta;

		Test.stopTest();

		List<Account> cuentaInsertada = [SELECT Id, Procede_de_conversion__c FROM Account Where Id =: cuenta[0].Id];
		System.assertEquals(false, OpportunityUtil.semaforoCreacionFuncionesDeContacto);
		System.assertEquals(false, cuentaInsertada[0].Procede_de_conversion__c);

	}


	 /**
	* Metodo encargado de comprobar que se ctualiza el campo Usuario_Web_Clientes__c con el valor del campo Id_Fiscal__c
	* @author rfernandez (17/02/2017)
	* @changes rcastanos (07/06/2019) Modificaciones para adecuarse a la eliminación de cuentas personales
	*/
    static testMethod void testActualizarUsuarioWebClientes()
	{
		List<Account> cuentas = Util.generarCuentas(1, 100, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);

		insert cuentas;

		for(Account cuentaInsert: cuentas)
		{
			cuentaInsert.Id_Fiscal__c = '987654321';
		}
		Test.startTest();

		update cuentas;

		Test.stopTest();

		List<Account> cuentasInsertadas = [SELECT Id, Id_Fiscal__c, Usuario_Web_Clientes__c FROM Account WHERE Id IN: cuentas];
		for(Account cuentaInsertada : cuentasInsertadas)
		{
			System.assertEquals(cuentaInsertada.Id_Fiscal__c, cuentaInsertada.Usuario_Web_Clientes__c);
		}
	}

	//@changes rcastanos (07/06/2019) Modificaciones para adecuarse a la eliminación de cuentas personales
	static testMethod void testInsertarUsuarioWebClientes()
	{
		List<Account> cuentas =Util.generarCuentas(1, 100, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);

		Test.startTest();

		insert cuentas;

		Test.stopTest();
		List<Account> cuentasInsertadas = [SELECT Id, Id_Fiscal__c, Usuario_Web_Clientes__c FROM Account WHERE Id IN: cuentas];
		for(Account cuentaInsertada : cuentasInsertadas)
		{
			System.assertEquals(cuentaInsertada.Id_Fiscal__c, cuentaInsertada.Usuario_Web_Clientes__c);
		}
	}

	/*Prueba que al crear una cuenta de empresa NO se crean registros persona*/
	//@changes rcastanos (07/06/2019) Modificaciones para adecuarse a la recogida del tipo de registro por propiedad
	@isTest
	static void test_crearPersona_cuentaEmpresa()
	{
		List<Account> accountsList = Util.generarCuentas(NUM_ACCOUNTS, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);

		Test.startTest();
		insert accountsList;
		Test.stopTest();

		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c FROM Individual]);
		System.assert(personasMap.isEmpty());
	}


	/*Prueba que si se cambia el tipo de registro de una cuenta empresa, se marcan las preferencias de los individual a los que estan asociados sus contactos*/
	@isTest
	static void test_aceptarPreferencias_empresa()
	{
		List<Account> accountsList = Util.generarCuentas(NUM_ACCOUNTS, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente').Id);
		insert accountsList;

		List<Contact> contactsList = Util.generarContactos(NUM_CONTACTS, 0, accountsList);
		insert contactsList;

		List<Individual> personasList = [SELECT Id, Promociones__c, Encuestas_satisfaccion__c FROM Individual];
		System.assert(!personasList.isEmpty());
		System.assertEquals(NUM_ACCOUNTS*NUM_CONTACTS , personasList.size());

		for(Individual persona : personasList)
		{
			System.assertEquals(false, persona.Promociones__c);
			System.assertEquals(false, persona.Encuestas_satisfaccion__c);
		}

		for(Account cuenta : accountsList)
		{
			cuenta.RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id;
		}

		Test.startTest();
		update accountsList;
		Test.stopTest();

		List<Individual> personasList2 = [SELECT Id, Promociones__c, Encuestas_satisfaccion__c FROM Individual];
		System.assert(!personasList2.isEmpty());
		System.assertEquals(NUM_ACCOUNTS*NUM_CONTACTS, personasList2.size());

		for(Individual persona : personasList2)
		{
			System.assertEquals(true, persona.Promociones__c);
			System.assertEquals(true, persona.Encuestas_satisfaccion__c);
		}
	}
}