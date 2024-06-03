@isTest
private class TEST_BatchBorrarFacturas 
{
	// private static final Integer NUM_FACTURAS_BORRAR		= 1;         // Numero de facturas a borrar
	// private static final Integer NUM_FACTURAS_NO_BORRAR		= 1;         // Numero de facturas para no borrar


	// @TestSetup 
	// static void generateEnvironment()
	// {	
	// 	Parametros_generales__c params = new Parametros_generales__c();
	// 	params.Name = 'BatchBorrarFacturas';
	// 	params.Valor__c = '1440';
	// 	insert params;
	// }

	// /** 
    // * @description: Valida que se borran aquellas facturas con fecha superior o igual a un año y estado Pagado
    // **
    // * @Author: rfernandez (16/02/2018)
    // */
	// @isTest 
	// static void borradoDeFacturas() 
	// {
	// 	List<Factura__c> facturasList = new List<Factura__c>();

	// 	for(Integer i = 0 ; i < NUM_FACTURAS_BORRAR ; i++)
	// 	{
	// 		Factura__c factura = new Factura__c(
	// 			Estado_documento__c = 'Pagado',
	// 			Fecha_registro__c	= System.today().addYears(-2)
	// 		);
	// 		facturasList.add(factura);
	// 	}

	// 	for(Integer i = 0 ; i < NUM_FACTURAS_NO_BORRAR ; i++)
	// 	{
	// 		Factura__c factura = new Factura__c(
	// 			Estado_documento__c = 'Test',
	// 			Fecha_registro__c	= System.today().addMonths(-6)
	// 		);
	// 		facturasList.add(factura);
	// 	}
	// 	insert facturasList;

	// 	List<Factura__c> facturasInsertadasList = [SELECT Id FROM Factura__c];
	// 	System.assertEquals(NUM_FACTURAS_BORRAR+NUM_FACTURAS_NO_BORRAR, facturasInsertadasList.size());

	// 	Test.startTest();

	// 	BatchBorrarFacturas borradoFacturas = new BatchBorrarFacturas(null);
    // 	borradoFacturas.execute(null);

	// 	Test.stopTest();

	// 	List<Factura__c> facturasTrasBorradoList = [SELECT Id FROM Factura__c];
	// 	System.assertEquals(NUM_FACTURAS_NO_BORRAR, facturasTrasBorradoList.size());
	// }
	
	// /** 
    // * @description: Valida que se no se borren aquellas facturas con estado pagado pero cuya fecha sea menor a un año
    // **
    // * @Author: rfernandez (16/02/2018)
    // */
	// @isTest 
	// static void noBorradoDeFacturasEstado() 
	// {
	// 	List<Factura__c> facturasList = new List<Factura__c>();

	// 	for(Integer i = 0 ; i < NUM_FACTURAS_NO_BORRAR ; i++)
	// 	{
	// 		Factura__c factura = new Factura__c(
	// 			Estado_documento__c = 'Pagado',
	// 			Fecha_registro__c	= System.today().addMonths(-6)
	// 		);
	// 		facturasList.add(factura);
	// 	}
	// 	insert facturasList;

	// 	List<Factura__c> facturasInsertadasList = [SELECT Id FROM Factura__c];
	// 	System.assertEquals(NUM_FACTURAS_NO_BORRAR, facturasInsertadasList.size());

	// 	Test.startTest();

	// 	BatchBorrarFacturas borradoFacturas = new BatchBorrarFacturas(null);
    // 	borradoFacturas.execute(null);

	// 	Test.stopTest();

	// 	List<Factura__c> facturasTrasBorradoList = [SELECT Id FROM Factura__c];
	// 	System.assertEquals(NUM_FACTURAS_NO_BORRAR, facturasTrasBorradoList.size());
	// }

	// /** 
    // * @description: Valida que se no se borren aquellas facturas cuya fecha sea superior a un año pero que su estado no sea pagado
    // **
    // * @Author: rfernandez (16/02/2018)
    // */
	// @isTest 
	// static void noBorradoDeFacturasFecha() 
	// {
	// 	List<Factura__c> facturasList = new List<Factura__c>();

	// 	for(Integer i = 0 ; i < NUM_FACTURAS_NO_BORRAR ; i++)
	// 	{
	// 		Factura__c factura = new Factura__c(
	// 			Estado_documento__c = 'Test',
	// 			Fecha_registro__c	= System.today().addYears(-2)
	// 		);
	// 		facturasList.add(factura);
	// 	}
	// 	insert facturasList;

	// 	List<Factura__c> facturasInsertadasList = [SELECT Id FROM Factura__c];
	// 	System.assertEquals(NUM_FACTURAS_NO_BORRAR, facturasInsertadasList.size());

	// 	Test.startTest();

	// 	BatchBorrarFacturas borradoFacturas = new BatchBorrarFacturas(null);
    // 	borradoFacturas.execute(null);

	// 	Test.stopTest();

	// 	List<Factura__c> facturasTrasBorradoList = [SELECT Id FROM Factura__c];
	// 	System.assertEquals(NUM_FACTURAS_NO_BORRAR, facturasTrasBorradoList.size());
	// }

	// /** 
    // * @description: Cubre las partes de codigo que no se van a utilizar normalmente
    // **
    // * @Author: rfernandez (16/02/2018)
    // */
	// @isTest 
	// static void coberturaRestante() 
	// {
	// 	Parametros_generales__c params = [SELECT Id FROM Parametros_generales__c];
	// 	delete params; 
		
	// 	Test.startTest();

    // 	Database.executeBatch(new BatchBorrarFacturas('SELECT Id, Fecha_registro__c, Estado_documento__c FROM Factura__c'));

	// 	Test.stopTest();
	// }
}