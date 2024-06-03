@isTest
 private class TEST_Nav2sfdc_Facturas 
 {
// 	private static final Integer NUM_CUENTAS_EMPRESA		= 1;         // Numero de facturas a borrar
// 	private static final Integer NUM_CUENTAS_PARTICULARES	= 1;         // Numero de facturas para no borrar

// 	@TestSetup 
// 	static void generateEnvironment()
// 	{	
// 		Parametros_generales__c params = new Parametros_generales__c();
// 		params.Name = 'Nav2sfdc_ActualizacionDiariaClientes';
// 		params.Valor__c = '1';
// 		insert params;

// 		Parametros_generales__c params2 = new Parametros_generales__c();
// 		params2.Name = 'Intentos_DetalleClientes';
// 		params2.Valor__c = '3';
// 		insert params2;

// 		Parametros_generales__c params3 = new Parametros_generales__c();
// 		params3.Name = 'Tiempo_intentos_DetalleClientes';
// 		params3.Valor__c = '3';
// 		insert params3;


// 		List<Id> accountRecTypList = new List<Id>();
// 		Map<String, Schema.RecordTypeInfo> rgRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();
// 		accountRecTypList.add(rgRecordTypeInfo.get('Cliente existente - Particular').getRecordTypeId());
// 		accountRecTypList.add(rgRecordTypeInfo.get('Cliente existente - empresa').getRecordTypeId());

// 		List<Account> cuentasList = new List<Account>();
// 		List<Direcci_n_de_entrega__c> direccionesList = new List<Direcci_n_de_entrega__c>();

// 		/*CUENTAS PARTICULARES*/
// 		for(Integer i = 0 ; i < NUM_CUENTAS_EMPRESA ; i++)
// 		{
// 			Account cuenta = new Account(
// 				Name 			= 'Test'+ i,
// 				RecordTypeId 	= accountRecTypList[1],
// 				Id_Navision__c	= String.valueOf(i)
// 			);
// 			cuentasList.add(cuenta);
// 		}

// 		/*CUENTAS EMPRESA*/
// 		for(Integer i = 0 ; i < NUM_CUENTAS_PARTICULARES ; i++)
// 		{
// 			Account cuenta = new Account(
// 				LastName 		= 'Test'+i,
// 				RecordTypeId 	= accountRecTypList[0],
// 				Id_Navision__c	= String.valueOf(NUM_CUENTAS_EMPRESA+i)
// 			);
// 			cuentasList.add(cuenta);
// 		}

// 		AccountUtil.semaforoUpdate = false;
// 		insert cuentasList;
// 		AccountUtil.semaforoUpdate = true;
// 	}
	
// 	/** 
//     * @description: Prueba que se estan insertando las facturas que vienen de Navision
//     **
//     * @Author: rfernandez (16/02/2018)
//     */
// 	@isTest 
// 	static void insercionNuevasFacturas() 
// 	{
// 		Test.startTest();

// 		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(0));
// 		Nav2sfdc_Facturas consultaFacturas = new Nav2sfdc_Facturas();
//     	consultaFacturas.execute(null);

// 		Test.stopTest();
// 	}
	
// 	/** 
//     * @description: Prueba que se estan actualizando las facturas que se encuentran en SF con la informacion de Navision
//     **
//     * @Author: rfernandez (16/02/2018)
//     */
// 	@isTest 
// 	static void actualizacionFacturas() 
// 	{
// 		Test.startTest();

// 		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(1));
// 		Nav2sfdc_Facturas consultaFacturas = new Nav2sfdc_Facturas();
//     	consultaFacturas.execute(null);

// 		Test.stopTest();
// 	}

// 	/** 
//     * @description: Prueba que se genera un log debido a que no existen clientes en SF a los que asociar las facturas que vienen de Navision
//     **
//     * @Author: rfernandez (16/02/2018)
//     */
// 	@isTest 
// 	static void clienteNoExiste() 
// 	{
// 		Test.startTest();

// 		Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(2));
// 		Nav2sfdc_Facturas consultaFacturas = new Nav2sfdc_Facturas();
//     	consultaFacturas.execute(null);

// 		Test.stopTest();
// 	}

// 	/** 
//     * @description:
//     **
//     * @Author: rfernandez (16/02/2018)
//     */
// 	@isTest 
// 	static void coberturaRestante() 
// 	{
		
// 	}
	
 }