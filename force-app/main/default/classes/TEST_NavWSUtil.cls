@isTest
public class TEST_NavWSUtil {
	
	static testMethod void separarEnDosStrings()
	{
		String stringLargo = '12345678901234567890123456789012345678901234567890123';
		List<String> listaStrings = NavWSUtil.separarEnDosStrings(stringLargo);
		System.assertEquals(listaStrings[0],'12345678901234567890123456789012345678901234567890');
		System.assertEquals(listaStrings[1],'123');
		
		String stringCorto = '12345678901234567890123456789012345678901234567890';
		listaStrings = NavWSUtil.separarEnDosStrings(stringCorto);
		System.assertEquals(listaStrings[0],'12345678901234567890123456789012345678901234567890');
		System.assertEquals(listaStrings.size(),1);
	}
	
	static testMethod void testPeticionWSConsultarTarifas()
	{
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(null, null));
        
		List<XmlUtil.RespuestaPeticionConsultarTarifas> listaEtTarifas = NavWSUtil.peticionWSConsultarTarifas();
       	Test.stopTest();
       	
       	//Comprobamos que ha devuelto correctamente la lista de etCustomers
       	boolean encontradoTarifa1 = false;
       	boolean encontradoTarifa2 = false;
       	
       	System.debug('listaEtTarifas: '+listaEtTarifas);
       	for(XmlUtil.RespuestaPeticionConsultarTarifas tarifa : listaEtTarifas)
       	{
       		if(tarifa.descripcion == 'Descripcion tarifa 2' && tarifa.idNavisio == '90000013')
				encontradoTarifa2 = true;
			else if(tarifa.descripcion == 'Descripcion tarifa 1' && tarifa.idNavisio == '90000012')
				encontradoTarifa1 = true;
       	}
       	
       	System.assertEquals(encontradoTarifa2,true);
       	System.assertEquals(encontradoTarifa1,true);
	}
	
	static testMethod void testPeticionWSConsultarClientes()
	{
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(null, null));
       	List<SchemaCliente.etCustomer> listaEtCustomers = NavWSUtil.peticionWSConsultarClientes();
       	Test.stopTest();
       	
       	//Comprobamos que ha devuelto correctamente la lista de etCustomers
       	boolean encontrado1 = false;
       	boolean encontrado2 = false;
       	
       	System.debug('ListaEtCustomers: '+listaEtCustomers);
       	for(SchemaCliente.etCustomer customer : listaEtCustomers)
       	{
       		if(customer.CustomerNo == '90000002')
       			encontrado1 = true;
       		else if(customer.CustomerNo == '90000000')
       			encontrado2 = true;
       	}
       	
       	System.assertEquals(encontrado1,true);
       	System.assertEquals(encontrado2,true);
	}

	static testMethod void  testPeticionWSCrearClientes()
    {
      Direcci_n_de_entrega__c direccionEntrega = new Direcci_n_de_entrega__c ();
    	
    	Account cuenta = new Account();
    	cuenta.Name = 'Test';
    	insert cuenta;
    	
    	Account cuenta2 = new Account();
    	cuenta2.Name = 'Test 2';
    	insert cuenta2;
    	
    	direccionEntrega.cuenta__c = cuenta.Id;
    	insert direccionEntrega;
    	
        List<SchemaCliente.etCustomer> listaCustomers = new List<SchemaCliente.etCustomer>();
        SchemaCliente.etCustomer etCustomer = new SchemaCliente.etCustomer();
        etCustomer.Addres = 'Crta Nacional N-232 Km. 373';
        etCustomer.Name = 'ALMACENES PROPIOS2';
        etCustomer.CustomerNo = '90000000';
        etCustomer.VatRegistration = 'A61128014';
        etCustomer.email = 'quinto2@primagas.es';
        etCustomer.PostCode = '50770';
        etCustomer.City = 'QUINTO';
        etCustomer.SalesForceId = cuenta.Id;
        listaCustomers.add(etCustomer);
        
        SchemaCliente.etCustomer etCustomer2 = new SchemaCliente.etCustomer();
        etCustomer2.SalesForceId = cuenta2.Id;
        etCustomer2.Addres = 'Crta Nacional N-232 Km. 33';
        etCustomer2.Name = 'ALMACENES PROPIOS2';
        etCustomer2.CustomerNo = '90000003';
        etCustomer2.VatRegistration = 'A61128013';
        etCustomer2.email = 'quinto2@primagas.es';
        etCustomer2.PostCode = '50770';
        etCustomer2.City = 'QUINTO';
        listaCustomers.add(etCustomer2);
        
        List<SchemaCliente.etAddres> listaAddres = new List<SchemaCliente.etAddres>();
        SchemaCliente.etAddres etAddres = new SchemaCliente.etAddres();
        etAddres.ADAddres = 'ADAddres';
        etAddres.ADSalesForceId = direccionEntrega.Id;
        etAddres.ADAddres2 = 'ADAddres2';
        etAddres.ADCode = 'ADCode';
        listaAddres.add(etAddres);
        
        List<SchemaCliente.etDataBank> listaDataBank = new List<SchemaCliente.etDataBank>();
        SchemaCliente.etDataBank etDataBank = new SchemaCliente.etDataBank();
        etDataBank.BankCode = '2';
        etDataBank.BankIBAN = 'BankIBAN';
        etDataBank.BankSWIFT = 'BankSWIFT';
        listaDataBank.add(etDataBank);
        
        etCustomer.etAddres = listaAddres;
        etCustomer.etDataBank = listaDataBank;
		
        SchemaCliente.entitySyncDto entidad = new SchemaCliente.entitySyncDto();
       	entidad.etCustomer = listaCustomers; 
        
		Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(direccionEntrega.Id, cuenta.Id));
       	XmlUtil.RespuestaPeticionSincronizarClientes camposRespuestaPeticion = NavWSUtil.peticionWSSincronizarClientes(entidad);
       	Test.stopTest();
       
       	System.debug('TEST: Campos RespuestaPeticion: ' + camposRespuestaPeticion);
	
		String idDatosBancarios = camposRespuestaPeticion.mapaIdsSalesforceIdNavDatosBancarios.get(cuenta.Id);
		//System.assertEquals(idDatosBancarios,'2');
		
		String idNavisioCuenta = camposRespuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.get(cuenta.Id);
		//System.assertEquals(idNavisioCuenta,'90000000');

		String idNavisioDireccionEntrega = camposRespuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.get(direccionEntrega.Id);
		System.assertEquals(idNavisioDireccionEntrega,'31');
	}
	
	static testMethod void  testPeticionWSCrearContrato()
    {
    	Account cuenta = new Account();
    	cuenta.Name = 'Nombre';
    	insert cuenta;
    	
    	Contract contratoSf = new Contract();
    	contratoSf.AccountId = cuenta.Id;
    	insert contratoSf;
    	
    	List<SchemaContrato.etContract> listaContratos = new List<SchemaContrato.etContract>();
       
        SchemaContrato.etContract contract = new SchemaContrato.etContract();
        contract.ContractDurationTons = 15;
		contract.ContractDurationYears = 15;
		contract.PlannedConsumptionTons = 15;
//		contract.CodePaymentTermsServices = 'CodePaymentTermsServices';
		contract.CodePaymentDay = 'CodePaymentDay';
//		contract.CodePaymentServices = 'CodePaymentServices';
		contract.ReminderTermsCode = 'ReminderTermsCode';
		contract.DateFirstFill = System.today();
		contract.DateCivilWork = System.today();
		contract.CapacityTank = 15;
		contract.TankType = 'TankType';
		contract.AmountDepo = 17;
		contract.AmountINEX = 16;
		contract.AmountININ = 15;
		contract.AmountOC = 14;
		contract.AmountEquipment = 13;
		contract.AmountProyect = 12;
		contract.dpcadmin1 = 15;
		contract.dpcadmin2 = 15;
		contract.dpcadmin3 = 15;
		contract.dpcadmin4 = 15;
		contract.dpcadmin5 = 15;
		contract.dpcadmin6 = 15;
		contract.Dto1 = 15;
		contract.Dto2 = 15;
		contract.Dto3 = 15;
		contract.Dto4 = 15;
		contract.Dto5 = 15;
		contract.Dto6 = 15;
		contract.TPinstallationType = 'TPinstallationType';
		contract.Dto1kg = 15;
		contract.Dto2kg = 15;
		contract.Dto3kg = 15;
		contract.Dto4kg = 15;
		contract.Dto5kg = 15;
		contract.Dto6kg = 15;
		contract.Services = 'Services';
		contract.dcmpropano1 = 15;
		contract.dcmpropano2 = 15;
		contract.dcmpropano3 = 15;
		contract.dcmpropano4 = 15;
		contract.AmountServices = 15;
		contract.Dto1Year = 15;
		contract.Dto2Year = 15;
		contract.Dto3Year = 15;
		contract.Dto4Year = 15;
		contract.AmountContractManagement = 15;
		contract.GasMeterRentAmount = 15; 
		contract.AmountSAU = 15;
		contract.ImporteDerechosAlta = 15;
		contract.ImporteDerechosAcometida = 15;
		contract.AmountFixTerm = 15;
		contract.WaterAvailable = true;
		contract.Promotor = 'Promotor'; 
		contract.Segment1 = 'Segment1';
		contract.Segment2 = 'Segment2';
		contract.Primaconta = true;
		contract.IDSalesForce = contratoSf.Id;
		 
        listaContratos.add(contract);
        
        SchemaContrato.entitySyncDto entidad = new SchemaContrato.entitySyncDto();
       	entidad.etContract = listaContratos; 
       	
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(contratoSf.Id));
		Set<String> setIds = NavWSUtil.peticionWSSincronizarContratos(entidad);
		Test.stopTest();
		
		//System.assert(setIds!=null && setIds.size()>0);
		//System.assert(setIds.contains(contratoSf.Id));
	}
	
	
}