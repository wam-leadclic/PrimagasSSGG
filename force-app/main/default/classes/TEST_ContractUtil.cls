@isTest 
public class TEST_ContractUtil {
	
    @testVisible
	//Método que prueba los métodos de ContractUtil que se invocan con triggers.
	static testMethod void testProbarMetodosRenovarContratoTarifasRenovarTitular()
	{
		Profile prof = [Select  Id, Name from Profile where Name like '%Admin%' limit 1];
        User usr = [Select ID, ProfileID From User where profileId =: prof.ID limit 1];
		System.Debug('## before testProbarMetodosContractTrigger');

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		insert cuenta;

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		insert contrato;

		Contract contrato2 = new Contract();
		contrato2.AccountId = cuenta.Id;
		insert contrato2;

		Contract contratoDelete = new Contract();
		contratoDelete.AccountId = cuenta.Id;
		insert contratoDelete;

		Contract contratoPruebas = new Contract();
		Contract contratoPruebas2 = new Contract();	
		 
		contratoPruebas.Motivo_de_renovacion__c = 'Cambio tarifa';
		contratoPruebas.Contrato_anterior__c = contrato.Id;
		contratoPruebas.AccountId = cuenta.Id;
        contratoPruebas.OwnerId = usr.ID;
        contratoPruebas.CompanySignedId = usr.id;
		insert contratoPruebas;

		contratoPruebas2.Motivo_de_renovacion__c = 'Cambio titular';
		contratoPruebas2.Contrato_anterior__c = contrato2.Id;
		contratoPruebas2.AccountId = cuenta.Id;
		insert contratoPruebas2;

		contratoPruebas.Status = 'Activado';
		
		Test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(contratoPruebas.Id));
		
		update contratoPruebas;
		
		cuenta = [Select Id, Name, RecordTypeId from Account where Id = :cuenta.Id][0];
		RecordType tipoRegistro = [Select Id, DeveloperName from RecordType where Id = :cuenta.RecordTypeId][0];
		System.assertEquals('Cliente_existente', tipoRegistro.DeveloperName);

		delete contratoDelete;

		Test.stopTest();

		contrato = [Select Id, Status from Contract where Id = :contrato.Id][0];
		System.assertEquals('Anulado', contrato.Status);

		contrato2 = [Select Id, Status from Contract where Id = :contrato2.Id][0];
		System.assertEquals('Anulado', contrato2.Status);

		cuenta = [Select Id, Name, RecordTypeId from Account where Id = :cuenta.Id][0];
		tipoRegistro = [Select Id, DeveloperName from RecordType where Id = :cuenta.RecordTypeId][0];
		System.assertEquals('Cliente_existente', tipoRegistro.DeveloperName);
		
		//Comprobamos que se ha actualizado el id de nav del contrato
		List<Contract> listaContratos = [select Fecha_ltima_Sync__c from Contract where Id = :contratoPruebas.Id];
		//System.assert(listaContratos[0].Fecha_ltima_Sync__c!=null);
		System.Debug('## after testProbarMetodosContractTrigger');
	}
	
    @TestVisible
	// Se prueba que el tipo de cliente se cambia a cliente existente cuando el contrato pasa a activado
	static testMethod void testProbarMetodosContratoActivadoTrigger()
	{
    	Profile prof = [Select  Id, Name from Profile where Name like '%Admin%' limit 1];
        User usr = [Select ID, ProfileID From User where profileId =: prof.ID limit 1];
        
		System.Debug('## before testProbarMetodosAccountTrigger');
		
		RecordType tiposRegistro = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		insert cuenta;
		
		//Creamos un contacto con estado Activado para que el cliente pase a ser de tipo Cliente Existente
		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
        contrato.OwnerId = usr.ID;
        contrato.CompanySignedId = usr.id;
		insert contrato;
		
		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
		direccion.cuenta__c = cuenta.Id;
		
		insert direccion;
		
		contrato.Status = 'Pendiente de registrar';
		update contrato;
		
		List<Account> listaCuentas = [select Id_Navision__c from Account where Id=:cuenta.Id];
		System.assertEquals(listaCuentas.size(),1);
		System.assert(String.IsEmpty(listaCuentas[0].Id_Navision__c));
		
		Test.startTest();
		
		//Salta el trigger del contrato y cambia el tipo de cuenta a Cliente Existente
		contrato.Status = 'Activado';
		
		NTLMHttpCalloutMockImpl mock = new NTLMHttpCalloutMockImpl();
		mock.idSalesforceEtCustomer = cuenta.Id;
		mock.idSalesforceContract = contrato.Id;
		mock.idSalesforceAddress = direccion.Id;
		Test.setMock(HttpCalloutMock.class, mock);  
		
		update contrato;
		Test.stopTest(); 
		
		listaCuentas = [select Name, Id_Navision__c, RecordTypeId from Account where Id=:cuenta.Id];
		
		System.assertEquals(listaCuentas.size(),1);
		System.assertEquals(listaCuentas[0].RecordTypeId,tiposRegistro.Id);
		//System.assert(!String.IsEmpty(listaCuentas[0].Id_Navision__c));
		
		System.Debug('## after testProbarMetodosAccountTrigger');
	}


	static testMethod void TEST_cambiarEstadoOportunidadCerradaGanada()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		Contract contrato = new Contract();
		contrato.Status = 'Borrador';
		contrato.AccountId = cuenta.Id;
		contrato.CIF__c = '11111111A';
		contrato.N_telefono_movil__c = '666666666';
		contrato.CustomerSignedDate = Date.today();
		contrato.StartDate = Date.today();
		contrato.Duraci_n_del_contrato_a_os__c = '1';
		contrato.Consumo_previsto_tons__c = 1;
		contrato.Cod_forma_de_pago__c = 'CHEQUE';
		contrato.Cod_terminos_de_pago__c = '005';
		contrato.Cod_forma_pago_servicios__c = 'CHEQUE';
		contrato.Cod_terminos_pago_servicios__c = '005';
		contrato.Modalidad_de_instalaci_n__c = 'Modular';
		contrato.Fecha_prevista_obra_civil__c = Date.today();
		contrato.Fecha_prevista_1er_llenado__c = Date.today();
		contrato.Capacidad_tanque__c = 1;
		contrato.Tipo_de_tanque__c = 'Aereo';
		contrato.Origen__c = 'Web';
		contrato.Origen_tipo_de_cliente__c = 'Cambio Botellas';
		insert contrato;

		Opportunity oportunidad = new Opportunity();
		oportunidad.Name = 'Oportunidad prueba';
		oportunidad.AccountId = cuenta.Id;
		oportunidad.CloseDate = Date.today();
		oportunidad.StageName = 'Identificada';
		oportunidad.Estimaci_n_consumo_en_kilos__c = 10;
		oportunidad.ContractId = contrato.Id;
		insert oportunidad;

		oportunidad = [SELECT Id, StageName FROM Opportunity WHERE Id=:oportunidad.Id];
		System.assertEquals('Identificada', oportunidad.StageName);

		Contact contacto = new Contact();
		contacto.LastName = 'Prueba contacto';
		contacto.AccountId = cuenta.Id;
        contacto.Phone='612589639';
        contacto.MobilePhone='612589639';
		contacto.Email = 'ejemplo@ejemplo.com';
		insert contacto;

		contrato.CustomerSignedId = contacto.Id;
		update contrato;

		oportunidad = [SELECT Id, StageName FROM Opportunity WHERE Id=:oportunidad.Id];
		System.assertEquals('Cerrada ganada', oportunidad.StageName);
	}

	//gserrano 28/01/2019 se comentan los siguientes métodos de Test ya que 
	//los campos de forma de pago ya no se actualizan cuando el contrato pasa a activo aunque estén vacios
	/*static testMethod void testactualizarDatosClienteYDireccionEntrega()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Test';
		//cuenta.Cod_forma_pago__c = 'Forma pago cuenta test';
		//cuenta.Cod_terminos_pago__c = 'Terminos pago cuenta test';
		insert cuenta;

		Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
		direccion.Cuenta__c = cuenta.Id;
		insert direccion;

		Pricebook2 tarifa = new Pricebook2();
		tarifa.Name = 'Tarifa test';
		insert tarifa;

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.Cod_forma_de_pago__c = 'Forma pago contrato test';
		contrato.Cod_terminos_de_pago__c = 'Terminos pago contrato test';
		contrato.Direccion_de_entrega__c = direccion.Id;
		contrato.Tarifa__c = tarifa.Id;
		insert contrato;

		contrato.Status = 'Activado';
		update contrato;

		cuenta = [SELECT Id, Name, Cod_forma_pago__c, Cod_terminos_pago__c FROM Account WHERE Id=:cuenta.Id];
		System.assertEquals(contrato.Cod_forma_de_pago__c, cuenta.Cod_forma_pago__c);
		System.assertEquals(contrato.Cod_terminos_de_pago__c, cuenta.Cod_terminos_pago__c);

		direccion = [SELECT Id, C_digo_tarifa__c FROM Direcci_n_de_entrega__c WHERE Cuenta__c=:cuenta.Id];
		System.assertEquals(contrato.Tarifa__c, direccion.C_digo_tarifa__c);
	}*/

	/*static testMethod void testActualizarDatosDelContratoEnCuenta()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Test';
		insert cuenta;

		Pricebook2 tarifa = new Pricebook2();
		tarifa.Name = 'Tarifa test';
		insert tarifa;

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.Cod_forma_de_pago__c = 'Forma pago contrato test';
		contrato.Cod_terminos_de_pago__c = 'Terminos pago contrato test';
		contrato.Cod_dia_de_pago__c = 'Dias pago contrato test';
		insert contrato;

		contrato.Status = 'Activado';
		update contrato;

		cuenta = [SELECT Id, Cod_Dias_Pago_Contrato_Activo__c, Cod_Forma_Pago_Contrato_Activo__c, Cod_Terminos_Pago_Contrato_Activo__c FROM Account WHERE Id=:cuenta.Id];
		//System.assertEquals(cuenta.Cod_Dias_Pago_Contrato_Activo__c, contrato.Cod_dia_de_pago__c);
		//System.assertEquals(cuenta.Cod_Forma_Pago_Contrato_Activo__c, contrato.Cod_forma_de_pago__c);
		//System.assertEquals(cuenta.Cod_Terminos_Pago_Contrato_Activo__c, contrato.Cod_terminos_de_pago__c);
	}*/


    /**
    *   Prueba que si cuando se inserta un contrato este no está informado a nivel de su oportunidad, esta se actualiza con el id del contrato
    **
    *  @author rfernandez
    *  @date 09/05/2018    
    *  @where andFinally
    */
    @isTest 
    static void testActualizarOppConContrato() 
    {
    	List<Opportunity> oppsList = [SELECT Id, ContractId, AccountId FROM Opportunity];
    	for(Opportunity opp : oppsList)
    	{
    		System.assertEquals(null , opp.ContractId);
    	}

    	List<Contract> contratosList = new List<Contract>();
    	for(Opportunity opp : oppsList)
    	{
    		contratosList.add(new Contract(
    							Oportunidad__c 			= opp.Id,
								AccountId 				= opp.AccountId,
								Cod_forma_de_pago__c 	= 'Forma pago contrato test',
								Cod_terminos_de_pago__c = 'Terminos pago contrato test',
								Cod_dia_de_pago__c 		= 'Dias pago contrato test'
    						)
    		);
    	}

		Test.startTest();
		insert contratosList;
		Test.stopTest();

		List<Contract> contratosInsertadosList = [SELECT Id, Oportunidad__c FROM Contract];
		Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([SELECT Id, ContractId FROM Opportunity]);
    	for(Contract cont : contratosInsertadosList)
    	{
    		if(oppsMap.containsKey(cont.Oportunidad__c))
    		{
    			System.assertEquals(cont.Id , oppsMap.get(cont.Oportunidad__c).ContractId);
    		}else
    		{
    			System.assert(false, 'La oportunidad debería estar en el mapa');
    		}
    	}
    }

    @TestSetup 
    static void generateEnvironment()
    {
    	List<Account> cuentasList = new List<Account>();
    	for(Integer i = 0 ; i < 10 ; i++)
    	{
    		cuentasList.add(new Account(
    							Name = 'Test'+i
    						)
    		);
    	}
    	insert cuentasList;

    	List<Opportunity> oppsList = new List<Opportunity>();
    	for(Account cuenta : cuentasList)
    	{
    		oppsList.add(new Opportunity(
    							Name 							= 'Test Opp',
								AccountId 						= cuenta.Id,
								CloseDate 						= Date.today(),
								StageName 						= 'Identificada',
								Estimaci_n_consumo_en_kilos__c 	= 10
    						)
    		);
    	}
    	insert oppsList;
    }
	
    @TestVisible
	static testMethod void TEST_activarDireccionEntrega()
	{

		
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		Direcci_n_de_entrega__c dir1 = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c='Dir1Test', Direccion_2__c='Dir2Test', Provincia__c='Bizkaia', Codigo_Postal__c= '23455', Poblacion__c='PoblTest');
        insert dir1;

		String lDireccion = [SELECT Name FROM Direcci_n_de_entrega__c LIMIT 1][0].Name;

		Direcci_n_de_entrega__c dir2 = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c='Dir1Test', Direccion_2__c='Dir2Test', Provincia__c='Bizkaia', Codigo_Postal__c= '23455', Poblacion__c='PoblTest', OldId__c = lDireccion);
        insert dir2;



        Profile prof = [Select  Id, Name from Profile where Name like '%Admin%' limit 1];
        User usr = [Select ID, ProfileID From User where profileId =: prof.ID limit 1];
        
        /*User usr = new User(LastName = 'TEST',
                           FirstName='TEST',
                           Alias = 'TEST',
                           Email = 'TEST.TEST@TEST.com',
                           Username = 'TEST.TEST@leadclic.br',
                           ProfileID = prof.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;*/
        
		Contract contrato = new Contract();
		contrato.Status = 'Borrador';
		contrato.AccountId = cuenta.Id;
		contrato.CIF__c = '11111111A';
		contrato.N_telefono_movil__c = '666666666';
		contrato.CustomerSignedDate = Date.today();
		contrato.StartDate = Date.today();
		contrato.Duraci_n_del_contrato_a_os__c = '1';
		contrato.Consumo_previsto_tons__c = 1;
		contrato.Cod_forma_de_pago__c = 'CHEQUE';
		contrato.Cod_terminos_de_pago__c = '005';
		contrato.Cod_forma_pago_servicios__c = 'CHEQUE';
		contrato.Cod_terminos_pago_servicios__c = '005';
		contrato.Modalidad_de_instalaci_n__c = 'Modular';
		contrato.Fecha_prevista_obra_civil__c = Date.today();
		contrato.Fecha_prevista_1er_llenado__c = Date.today();
		contrato.Capacidad_tanque__c = 1;
		contrato.Tipo_de_tanque__c = 'Aereo';
		contrato.Origen__c = 'Web';
		contrato.Origen_tipo_de_cliente__c = 'Cambio Botellas';
		contrato.Direccion_de_entrega__c = dir2.Id;
        contrato.OwnerId = usr.ID;
        contrato.CompanySignedId = usr.id;
		insert contrato;
        
		//contrato.OwnerId = usr.ID;
		contrato.Status = 'Activado';
		update contrato;

	}
}