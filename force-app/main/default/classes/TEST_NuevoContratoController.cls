@isTest
public class TEST_NuevoContratoController {
	public TEST_NuevoContratoController() {
		
	}

	// Método de prueba para dar cobertura de código a los métodos del controlador
	static testMethod void testProbarMetodosController(){
		System.Debug('## before testProbarMetodosController');		

		DateTime dT = System.now();
		Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		insert cuenta;

		//Cuenta para probar que al cambiar la cuenta se recalculan las direcciones de entrega (para cubrir esa parte de codigo)
		Account cuenta2 = new Account();
		cuenta2.Name = 'Test2';
		insert cuenta2;

		Direcci_n_de_entrega__c direccionEnvio = new Direcci_n_de_entrega__c();
		direccionEnvio.cuenta__c = cuenta.id;
		insert direccionEnvio;

		Direcci_n_de_entrega__c direccionEnvio2 = new Direcci_n_de_entrega__c();
		direccionEnvio2.cuenta__c = cuenta2.id;
		insert direccionEnvio2;

		Opportunity oportunidad = new Opportunity();
		oportunidad.AccountId = cuenta.Id;
		oportunidad.Name = 'Test';
		oportunidad.CloseDate = myDate;
		oportunidad.StageName = 'Identificada';
		insert oportunidad;

		//////
		//Hace falta que haya alguna función de contacto primaria en la oportunidad
		Contact contacto = new Contact();
		contacto.LastName = 'Prueba contacto';
		contacto.AccountId = cuenta.Id;
		contacto.Email = 'ejemplo@ejemplo.com';
        contacto.Phone = '612345678';
        contacto.MobilePhone = '612345678';
		insert contacto;

		OpportunityContactRole contactoRol = new OpportunityContactRole();
		contactoRol.ContactId = contacto.Id;
		contactoRol.IsPrimary = true;
		contactoRol.OpportunityId = oportunidad.Id;
		contactoRol.Role = 'Prueba rol';
		insert contactoRol;

		// Se generan Maps de los tipos de registros
        Map<String, RecordType> tiposRegistro = Util.objectsRecordTypesMap.get('Contract');
        Map<String,String> mapaTiposRegistroPorNombre = new Map<String, String>();
        

        for ( String nombre : tiposRegistro.keyset() )
        {
            String ID = tiposRegistro.get(nombre).Id;
            mapaTiposRegistroPorNombre.put( nombre, ID.left(15) );
        }

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.RecordTypeId = mapaTiposRegistroPorNombre.get('GLP');
		
		/* Este INSERT no hace falta, ya que en el test se genera el contrato con los datos 
		* pero luego se inserta en el controller.OnSave */
		//insert contrato;
				
		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('retURL', '/' + oportunidad.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);
		//ApexPages.CurrentPage().getparameters().put('id', contrato.Id);
		NuevoContratoController controller = new NuevoContratoController(sc);
		System.debug(controller.esDuplicarTarifa);//Sin esto no pasa por esas lineas de codigo y es un 2% de cobertura
		System.debug(controller.esCambioTitular);
		
		controller.direccionSeleccionada = direccionEnvio.Id;
		//controller.marcarDireccion();

		// Se inicializa el campo de direcciones con la direccionEnvio
		controller.setDir();
		controller.recalcularDirecciones();

		// Se deja vacio el campo de direcciones y probamos que al dejar vacia la cuenta se recalcula las direcciones de entrega
		controller.contract.AccountId = null;
		controller.recalcularDirecciones();

		// Probamos que al cambiar la cuenta se recalculan las direcciones de entrega
		controller.contract.AccountId = cuenta2.Id; 
		controller.recalcularDirecciones();

		// Se guarda el contrato
		controller.onSave();
		
		Test.stopTest();

		List<Contract> contratos = new List<Contract>([Select Id from Contract]);
		System.assertEquals(contratos.size(),1);
		System.Debug('## after testProbarMetodosController');
	}

	// Método de prueba para dar cobertura de código a los métodos del controlador
	static testMethod void testProbarMetodosController2(){
		// WHEN
		System.Debug('## before testProbarMetodosController2');		

		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);

		DateTime dT = System.now();
		Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User mockOwner = new User(Alias = 'testUser', Email='mockSystemAdministrator@primagas.pre.com.invalid', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='mockSystemAdministrator@primagas.pre.com');
		insert mockOwner;
        
		Account cuenta = new Account();
		cuenta.Name = 'Test';
        cuenta.OwnerId = mockOwner.Id;
		insert cuenta;

		Account cuenta2 = new Account();
		cuenta2.Name = 'Test2';
		cuenta2.Id_Fiscal__c = '123';
		cuenta2.Mobile_Phone_No__c = '123';
		cuenta2.E_mail__c = 'test@test.com';
		cuenta2.Fax = '123';
		cuenta2.Phone = '123';
        cuenta2.OwnerId = mockOwner.Id;
		insert cuenta2;

		Direcci_n_de_entrega__c direccionEnvio = new Direcci_n_de_entrega__c();
		direccionEnvio.cuenta__c = cuenta.id;
		insert direccionEnvio;

		Opportunity oportunidad = new Opportunity();
		oportunidad.AccountId = cuenta.Id;
		oportunidad.Name = 'Test';
		oportunidad.CloseDate = myDate;
		oportunidad.StageName = 'Identificada';
		insert oportunidad;


        
		// TEST
		Test.startTest();

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
        contrato.CompanySignedId = mockOwner.Id;
		insert contrato;

		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoController controller = new NuevoContratoController(sc);
		System.debug(controller.esDuplicarTarifa);//Sin esto no pasa por esas lineas de codigo y es un 2% de cobertura
		System.debug(controller.esCambioTitular);
		controller.direccionSeleccionada = direccionEnvio.Id;
		//controller.marcarDireccion();
		controller.setDir();
		controller.recalcularDirecciones();
		controller.contract.AccountId = cuenta2.Id;
		controller.recuperarDatosDeCuenta();
		controller.onSave();
		controller.actualizarEstado();

		Test.stopTest();

		// THEN
		List<Contract> contratos = new List<Contract>([SELECT Id FROM Contract]);			
		System.assertEquals(2, contratos.size()); //Ponia 2
		System.Debug('## after testProbarMetodosController2');
	}

	// Método de prueba para dar cobertura de código a los métodos del controlador
	static testMethod void testProbarMetodosController3(){
		System.Debug('## before testProbarMetodosController3');

		DateTime dT = System.now();
		Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());		

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		insert cuenta;


		Direcci_n_de_entrega__c direccionEnvio = new Direcci_n_de_entrega__c();
		direccionEnvio.cuenta__c = cuenta.id;
		insert direccionEnvio;


		Opportunity oportunidad = new Opportunity();
		oportunidad.AccountId = cuenta.Id;
		oportunidad.Name = 'Test';
		oportunidad.CloseDate = myDate;
		oportunidad.StageName = 'Identificada';
		insert oportunidad;

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		insert contrato;
				
		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTarifa', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);
		//ApexPages.CurrentPage().getparameters().put('id', contrato.Id);
		NuevoContratoController controller = new NuevoContratoController(sc);
		System.debug(controller.esDuplicarTarifa);//Sin esto no pasa por esas lineas de codigo y es un 2% de cobertura
		System.debug(controller.esCambioTitular);
		//Cambio el estado del contratoDuplicado
		controller.contract.Status = 'Activado';
		controller.contract.Estado_2__c = 'Renovado-ampliación';

		controller.direccionSeleccionada = direccionEnvio.Id;
		//controller.marcarDireccion();

		controller.setDir();

		controller.recalcularDirecciones();

		controller.onSave();

		controller.actualizarEstado();
		
		Test.stopTest();
		
		System.Debug('## after testProbarMetodosController3');

		Set<Id> idContratos = new set<Id>();
		idContratos.add(controller.contract.Id);
		idContratos.add(controller.contratoAnterior.Id);

		List<Contract> contratos = [Select Id, Status, Estado_2__c FROM Contract WHERE Id IN :idContratos];
		for(Contract cont: contratos)
		{
			if(cont.Id == controller.contract.Id)
			{
				System.assertEquals('Activado', cont.Status);
				System.assertEquals('Renovado-ampliación', cont.Estado_2__c);
			}
			else if(cont.Id == controller.contratoAnterior.Id)
			{
				System.assertEquals('Anulado', cont.Status);
				System.assertEquals(null, cont.Estado_2__c);
			}
		}
	}


	// Cambio de titular
	static testMethod void testProbarMetodosController5(){
		System.Debug('## before testProbarMetodosController5');		

		DateTime dT = System.now();
		Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		cuenta.Segmento1__c = 'Depósito';
		insert cuenta;

		Account cuenta2 = new Account();
		cuenta2.Name = 'Test2';
		cuenta2.Id_Fiscal__c = '123';
		cuenta2.Mobile_Phone_No__c = '123';
		cuenta2.E_mail__c = 'test@test.com';
		cuenta2.Fax = '123';
		cuenta2.Phone = '123';
		insert cuenta2;

		Direcci_n_de_entrega__c direccionEnvio = new Direcci_n_de_entrega__c();
		direccionEnvio.cuenta__c = cuenta.id;
		insert direccionEnvio;

		Opportunity oportunidad = new Opportunity();
		oportunidad.AccountId = cuenta.Id;
		oportunidad.Name = 'Test';
		oportunidad.CloseDate = myDate;
		oportunidad.StageName = 'Identificada';
		insert oportunidad;

		Id fromNavision = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('From Navision').getRecordTypeId();

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		contrato.RecordTypeId = fromNavision;
		insert contrato;

		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoController controller = new NuevoContratoController(sc);
		System.debug(controller.esDuplicarTarifa);
		System.debug(controller.esCambioTitular);
		controller.direccionSeleccionada = direccionEnvio.Id;

		controller.setDir();
		controller.recalcularDirecciones();
		controller.contract.AccountId = cuenta2.Id;
		controller.recuperarDatosDeCuenta();
		controller.onSave();
		controller.actualizarEstado();
		
		Test.stopTest();
		List<Contract> contratos = new List<Contract>([Select Id from Contract]);			
		System.assertEquals(2, contratos.size()); 
		System.Debug('## after testProbarMetodosController5');
	}

	// Cambio de titular
	static testMethod void testProbarMetodosController6(){
		System.Debug('## before testProbarMetodosController6');		

		DateTime dT = System.now();
		Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		insert cuenta;

		Account cuenta2 = new Account();
		cuenta2.Name = 'Test2';
		cuenta2.Id_Fiscal__c = '123';
		cuenta2.Mobile_Phone_No__c = '123';
		cuenta2.E_mail__c = 'test@test.com';
		cuenta2.Fax = '123';
		cuenta2.Phone = '123';
		insert cuenta2;

		Direcci_n_de_entrega__c direccionEnvio = new Direcci_n_de_entrega__c();
		direccionEnvio.cuenta__c = cuenta.id;
		insert direccionEnvio;

		Opportunity oportunidad = new Opportunity();
		oportunidad.AccountId = cuenta.Id;
		oportunidad.Name = 'Test';
		oportunidad.CloseDate = myDate;
		oportunidad.StageName = 'Identificada';
		insert oportunidad;

		Id fromNavision = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('From Navision').getRecordTypeId();

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		contrato.RecordTypeId = fromNavision;
		contrato.Tanque_propio__c = true;
		insert contrato;

		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoController controller = new NuevoContratoController(sc);
		System.debug(controller.esDuplicarTarifa);
		System.debug(controller.esCambioTitular);
		controller.direccionSeleccionada = direccionEnvio.Id;

		controller.setDir();
		controller.recalcularDirecciones();
		controller.contract.AccountId = cuenta2.Id;
		controller.recuperarDatosDeCuenta();
		controller.onSave();
		controller.actualizarEstado();
		
		Test.stopTest();
		List<Contract> contratos = new List<Contract>([Select Id from Contract]);			
		System.assertEquals(2, contratos.size()); 
		System.Debug('## after testProbarMetodosController6');
	}

	// Cambio de titular
	static testMethod void testProbarMetodosController7(){
		System.Debug('## before testProbarMetodosController7');		

		DateTime dT = System.now();
		Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		cuenta.Segmento1__c = 'Canalizado';
		insert cuenta;

		Account cuenta2 = new Account();
		cuenta2.Name = 'Test2';
		cuenta2.Id_Fiscal__c = '123';
		cuenta2.Mobile_Phone_No__c = '123';
		cuenta2.E_mail__c = 'test@test.com';
		cuenta2.Fax = '123';
		cuenta2.Phone = '123';
		insert cuenta2;

		Direcci_n_de_entrega__c direccionEnvio = new Direcci_n_de_entrega__c();
		direccionEnvio.cuenta__c = cuenta.id;
		insert direccionEnvio;

		Opportunity oportunidad = new Opportunity();
		oportunidad.AccountId = cuenta.Id;
		oportunidad.Name = 'Test';
		oportunidad.CloseDate = myDate;
		oportunidad.StageName = 'Identificada';
		insert oportunidad;

		Id fromNavision = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('From Navision').getRecordTypeId();

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		contrato.RecordTypeId = fromNavision;
		insert contrato;

		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoController controller = new NuevoContratoController(sc);
		System.debug(controller.esDuplicarTarifa);
		System.debug(controller.esCambioTitular);
		controller.direccionSeleccionada = direccionEnvio.Id;

		controller.setDir();
		controller.recalcularDirecciones();
		controller.contract.AccountId = cuenta2.Id;
		controller.recuperarDatosDeCuenta();
		controller.onSave();
		controller.actualizarEstado();
		
		Test.stopTest();
		List<Contract> contratos = new List<Contract>([Select Id from Contract]);			
		System.assertEquals(2, contratos.size()); 
		System.Debug('## after testProbarMetodosController7');
	}

	// Cambio de titular Cuenta anterior
	static testMethod void testProbarMetodosController8(){
		System.Debug('## before testProbarMetodosController8');		

		DateTime dT = System.now();
		Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		cuenta.Segmento1__c = 'Canalizado';
		insert cuenta;

		Account cuenta2 = new Account();
		cuenta2.Name = 'Test2';
		cuenta2.Id_Fiscal__c = '123';
		cuenta2.Mobile_Phone_No__c = '123';
		cuenta2.E_mail__c = 'test@test.com';
		cuenta2.Fax = '123';
		cuenta2.Phone = '123';
		insert cuenta2;

		Direcci_n_de_entrega__c direccionEnvio = new Direcci_n_de_entrega__c();
		direccionEnvio.cuenta__c = cuenta.id;
		insert direccionEnvio;

		Opportunity oportunidad = new Opportunity();
		oportunidad.AccountId = cuenta.Id;
		oportunidad.Name = 'Test';
		oportunidad.CloseDate = myDate;
		oportunidad.StageName = 'Identificada';
		insert oportunidad;

		Id fromNavision = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('From Navision').getRecordTypeId();

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		contrato.RecordTypeId = fromNavision;
		insert contrato;

		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoController controller = new NuevoContratoController(sc);
		System.debug(controller.esDuplicarTarifa);
		System.debug(controller.esCambioTitular);
		controller.direccionSeleccionada = direccionEnvio.Id;

		controller.setDir();

		controller.recalcularDirecciones();

		controller.contract.AccountId = cuenta2.Id;

		controller.recuperarDatosDeCuenta();

		controller.onSave();

		controller.actualizarEstado();
		
		Test.stopTest();
		List<Contract> contratos = new List<Contract>([Select Id, Status, Estado_2__c from Contract]);
		Account cuentaAnterior = [SELECT Id, Status_baja__c, Motivo_baja__c, Estado_baja__c, Fecha_baja__c, Fecha_cierre_baja__c FROM Account Where Id =: cuenta.Id Limit 1];
			System.debug('Test contratos: '+contratos);
			System.debug('Test cuentaAnterior: '+cuentaAnterior);

		System.assertEquals(2, contratos.size());

		for(Contract c: contratos)
		{
			if(c.Id == contrato.Id)
			{
                System.assertEquals(c.Status, 'Anulado');
			}
		}
        System.assertEquals(cuentaAnterior.Status_baja__c, 'Anulado');
        System.assertEquals(cuentaAnterior.Motivo_baja__c, 'Cambio titular');
        System.assertEquals(cuentaAnterior.Estado_baja__c, 'Cerrado');
        System.assertEquals(cuentaAnterior.Fecha_baja__c,  System.today());
        System.assertEquals(cuentaAnterior.Fecha_cierre_baja__c, System.today());



		System.Debug('## after testProbarMetodosController8');
	}
}