@isTest
public class TEST_NuevoContratoCPQController {
	public TEST_NuevoContratoCPQController() {
		
	}

	private static SBQQ__Quote__c insertQuote(Id accountId){
		SBQQ__Quote__c quote = new SBQQ__Quote__c(ClientTank__c = true, EstimatedConsumption__c = 12345, SBQQ__Account__c = accountId);
		insert quote;
		return quote;
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

		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.SBQQ__Quote__c = quote.Id;
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
		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);
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

		// TEST
		Test.startTest();

		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.SBQQ__Quote__c = quote.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		insert contrato;

		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);
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

		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.SBQQ__Quote__c = quote.Id;
		insert contrato;
				
		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTarifa', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);
		//ApexPages.CurrentPage().getparameters().put('id', contrato.Id);
		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);
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

		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.SBQQ__Quote__c = quote.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		contrato.RecordTypeId = fromNavision;
		insert contrato;

		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);
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

		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.SBQQ__Quote__c = quote.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		contrato.RecordTypeId = fromNavision;
		contrato.Tanque_propio__c = true;
		insert contrato;

		System.debug('CREA: '+contrato);

		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);
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

		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.SBQQ__Quote__c = quote.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		contrato.RecordTypeId = fromNavision;
		insert contrato;

		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);
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

		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.SBQQ__Quote__c = quote.Id;
		contrato.Direccion_de_entrega__c = direccionEnvio.Id;
		contrato.RecordTypeId = fromNavision;
		insert contrato;

		Test.startTest();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('duplicarTitular', contrato.Id);
		ApexPages.StandardController sc = new ApexPages.standardController(contrato);

		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);
		System.debug('controller.esDuplicarTarifa '+controller.esDuplicarTarifa);
		System.debug('controller.esCambioTitular '+controller.esCambioTitular);
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

	
	static testMethod void testCreacionGLP(){
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

		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Test.startTest();

		
		Contract contrato = new Contract();
		contrato.SBQQ__Quote__c = quote.Id;
		contrato.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('GLP').getRecordTypeId();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('contract', JSON.serialize(contrato));

		ApexPages.StandardController sc = new ApexPages.standardController(new Contract());

		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);
		controller.direccionSeleccionada = direccionEnvio.Id;

		controller.setDir();

		controller.recalcularDirecciones();

		controller.contract.AccountId = cuenta2.Id;

		controller.recuperarDatosDeCuenta();

		controller.onSave();

		Test.stopTest();
		List<Contract> contratos = new List<Contract>([Select Id, Status, Estado_2__c from Contract]);

		System.assertEquals(1, contratos.size());
	}

	static testMethod void testGetRecordTypesForQuoteContracts(){
		DateTime dT = System.now();

		List<NuevoContratoCPQController.RecordTypeOption> options = NuevoContratoCPQController.getValidRecordTypeOptionsForQuoteContracts();

		System.assertEquals(3, options.size());
		System.assertEquals(Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('GLP').getRecordTypeId(), options[0].value);
		System.assertEquals(Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('GNL').getRecordTypeId(), options[1].value);
		System.assertEquals(Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Deposito_propio').getRecordTypeId(), options[2].value);
		
	}
	
	/**
	 * Check that the fieldsets used by the page are the expected ones for the contract record type.
	 */
	static testMethod void testFieldsets(){
		Account cuenta = new Account();
		cuenta.Name = 'Test';
		cuenta.Segmento1__c = 'Canalizado';
		insert cuenta;
		
		SBQQ__Quote__c quote = insertQuote(cuenta.Id);

		Contract contrato = new Contract();
		contrato.SBQQ__Quote__c = quote.Id;
		contrato.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('GLP').getRecordTypeId();
		
		PageReference pageRef = Page.NuevoContrato;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getparameters().put('contract', JSON.serialize(contrato));

		ApexPages.StandardController sc = new ApexPages.standardController(new Contract());

		NuevoContratoCPQController controller = new NuevoContratoCPQController(sc);

		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Contract');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Informacion_del_sistema_GLP_GNL_DP').getFields(),
						 controller.FieldSet_InformacionDelSistema);
						 
		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Datos_de_captacion_GLP_GNL_DP').getFields(),
						controller.FieldSet_DatosDeCaptacion);
		
		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Primaservicios_GLP').getFields(),
						 controller.FieldSet_Primaservicios);
						 
		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Inversion_en_instalacion_GLP').getFields(),
						 controller.FieldSet_InversionEnInstalacion);
		
		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Datos_de_Instalacion_GLP').getFields(),
						 controller.FieldSet_DatosDeInstalacion);
						 
		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Tarifas_Gas_GLP').getFields(),
						 controller.FieldSet_TarifasGas);
		
		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Suministro_Producto_GLP').getFields(),
						 controller.FieldSet_SuministroProducto);
						 
		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Observaciones_GLP_GNL').getFields(),
						 controller.FieldSet_Observaciones);

		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Datos_de_Contacto_GLP').getFields(),
						 controller.FieldSet_DatosDeContacto);

		compareFieldsets(DescribeSObjectResultObj.FieldSets.getMap().get('Condiciones_de_Pago_GLP').getFields(),
						 controller.FieldSet_CondicionesDePago);
	}

	private static void compareFieldsets(List<Schema.FieldSetMember> expectedFieldSetMembers, List<Schema.FieldSetMember> actualFieldsets){
		Set<String> expectedFieldPath = new Set<String>();
		for(Schema.FieldSetMember fs : expectedFieldSetMembers){
			expectedFieldPath.add(fs.getFieldPath());
		}
		for(Schema.FieldSetMember fs : actualFieldsets){
			System.assert(expectedFieldPath.contains(fs.getFieldPath()), 'Field not found: '+fs.getFieldPath());
		}
		System.assertEquals(expectedFieldPath.size(), actualFieldsets.size());
	}
}