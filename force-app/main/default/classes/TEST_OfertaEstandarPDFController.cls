@isTest
private class TEST_OfertaEstandarPDFController
{
	//Método para dar cobertura
        @isTest
	static void TEST_OfertaEstandarPDFController()
	{
		Account a = new Account();
                a.Name = 'EMPRESA';
                a.ShippingCity = 'Test';
                a.ShippingState = 'Test';
                insert a;

		Opportunity op = new Opportunity();
                op.Name ='OpTest';
                op.StageName = 'Identificada';
                op.CloseDate = Date.today();
                op.AccountId = a.Id;
                insert op;

		Quote qE = new Quote();
                qE.Name = 'OfETest';
                qE.Status = 'Preparando';
                qE.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id;
                qE.OpportunityId = op.Id;
                qE.Fecha_vigencia__c = Date.today().addYears(1);
                qE.Observaciones__c = 'ObservacionesQE';
                qE.Enviar_email__c = true;
                qE.Resolucion_anticipada__c = 1202;
                qE.Prioridades_comodidad__c = true;
                qE.Prioridades_despreocuparse__c = false;
                qE.Prioridades_enterrado__c = true;
                qE.Prioridades_ahorro_anual__c = false;
                qE.Prioridades_precio_regulado__c = true;
                qE.Prioridades_pagar_consumo__c = false;
                qE.Prioridades_precio_fijo__c = true;
                qE.Prioridades_tarifa_plana__c = false;
                qE.Prioridades_impacto__c = 'Impacto bajo';
                qE.Kg__c = 1;
                qE.KWh__c = 2;
                qE.Litros__c = 3;
                qE.KgCO2__c = 4;
                qE.KgCO2_Primagas__c = 5;
                qE.KWh_Primagas__c = 11;
                qE.Diferencia_kgCO2__c = 12;
                qE.Diferencia_kWh__c = 13;
                qE.Interior_estandar__c = 'IntEstandarTest';
                qE.Exterior_estandar__c = 'ExtEstandarTest';
                qE.Servicio_estandar__c = 'ServEstandarTest';
                qE.Tarifa_estandar__c = 'TARIFA_TEST';
                qE.Precio_L__c = 7;
                qE.Precio_Kg__c = 8;
                qE.Valor_del_servicio_estandar__c = 9;
                qE.Importe_total_primagas__c = 14;
                qE.Importe_total__c = 15;
                qE.Diferencia_importes_totales__c = 16;
                qE.Pago_inicial__c = 17;
                qE.Duracion_descuento__c = '18 AÑOS';
                qE.Consumo_contratado_kg__c = 19;
                qE.Consumo_contratado_L__c = 20;
                qE.Duracion_contratado__c = '21 AÑOS';
                qE.Dto_Estandar__c = 22;
                qE.Texto_servicio_estandar__c = 'Texto opción servicio seleccionado';
                qE.Precio_fecha__c = 'Precio SEP';
                insert qE;

                Energia_Actual__c energia = new Energia_Actual__c();
                energia.Consumo__c = 100;
                energia.Consumo_KgCO2__c = 300;
                energia.Consumo_KgCO2_Primagas__c = 400;
                energia.Consumo_Kg_Primagas__c = 100;
                energia.Consumo_KWH__c = 100;
                energia.Consumo_KWH_Primagas__c = 200;
                energia.Consumo_L_Primagas__c = 100;
                energia.Tipo_energia__c = 'Butano';
                energia.Unidad_consumo__c = 'Kg/año';
                energia.Presupuesto__c = qE.Id;
                insert energia;

                EnergiaUnidades__c energiaUnidad = new EnergiaUnidades__c();
                energiaUnidad.Name ='energiaUnidadKgAnio';
                energiaUnidad.UnidadConsumo__c = 'Kg/año';
                energiaUnidad.Abreviatura_unidad_consumo__c = 'kg';
                insert energiaUnidad;



                Test.startTest();

                PageReference pagePDF = Page.OfertaEstandarPDF;
		pagePDF.getParameters().put('idOferta', qE.Id);
		Test.setCurrentPage(pagePDF);

		OfertaEstandarPDFController controller = new OfertaEstandarPDFController();
		system.assertEquals(1, controller.numTotalEnergias);

		Test.stopTest();
	}

        @isTest
        static void TEST_OfertaEstandarPDFController2()
        {
                Account a = new Account();
                a.Name = 'EMPRESA';
                insert a;

                Opportunity op = new Opportunity();
                op.Name ='OpTest';
                op.StageName = 'Identificada';
                op.CloseDate = Date.today();
                op.AccountId = a.Id;
                insert op;

                Quote qE = new Quote();
                qE.Name = 'OfETest';
                qE.Status = 'Preparando';
                qE.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id;
                qE.OpportunityId = op.Id;
                qE.Fecha_vigencia__c = Date.today().addYears(1);
                qE.Observaciones__c = '';
                qE.Enviar_email__c = true;
                qE.Resolucion_anticipada__c = 1202;
                qE.Prioridades_comodidad__c = true;
                qE.Prioridades_despreocuparse__c = false;
                qE.Prioridades_enterrado__c = true;
                qE.Prioridades_ahorro_anual__c = false;
                qE.Prioridades_precio_regulado__c = true;
                qE.Prioridades_pagar_consumo__c = false;
                qE.Prioridades_precio_fijo__c = true;
                qE.Prioridades_tarifa_plana__c = false;
                qE.Prioridades_impacto__c = 'Impacto bajo';
                qE.Kg__c = 1;
                qE.KWh__c = 2;
                qE.Litros__c = 3;
                qE.KgCO2__c = 4;
                qE.KgCO2_Primagas__c = 5;
                qE.KWh_Primagas__c = 11;
                qE.Diferencia_kgCO2__c = 12;
                qE.Diferencia_kWh__c = 13;
                qE.Interior_estandar__c = 'IntEstandarTest';
                qE.Exterior_estandar__c = 'ExtEstandarTest';
                qE.Servicio_estandar__c = 'ServEstandarTest';
                qE.Tarifa_estandar__c = 'TARIFA_TEST';
                qE.Precio_L__c = 7;
                qE.Precio_Kg__c = 8;
                qE.Valor_del_servicio_estandar__c = 9;
                qE.Importe_total_primagas__c = 14;
                qE.Importe_total__c = 15;
                qE.Diferencia_importes_totales__c = 16;
                qE.Pago_inicial__c = 17;
                qE.Duracion_descuento__c = '18 AÑOS';
                qE.Consumo_contratado_kg__c = 19;
                qE.Consumo_contratado_L__c = 20;
                qE.Duracion_contratado__c = '21 AÑOS';
                qE.Dto_Estandar__c = 22;
                qE.Texto_servicio_estandar__c = 'Texto opción servicio seleccionado';
                qE.Precio_fecha__c = 'Precio SEP';
                insert qE;

                Energia_Actual__c energia = new Energia_Actual__c();
                energia.Consumo__c = 100;
                energia.Consumo_KgCO2__c = 100;
                energia.Consumo_KgCO2_Primagas__c = 100;
                energia.Consumo_Kg_Primagas__c = 100;
                energia.Consumo_KWH__c = 100;
                energia.Consumo_KWH_Primagas__c = 100;
                energia.Consumo_L_Primagas__c = 100;
                energia.Tipo_energia__c = 'Butano';
                energia.Unidad_consumo__c = 'Kg/año';
                energia.Presupuesto__c = qE.Id;
                insert energia;

                EnergiaUnidades__c energiaUnidad = new EnergiaUnidades__c();
                energiaUnidad.Name ='energiaUnidadKgAnio';
                energiaUnidad.UnidadConsumo__c = 'Kg/año';
                energiaUnidad.Abreviatura_unidad_consumo__c = 'kg';
                insert energiaUnidad;

                

                Test.startTest();

                PageReference pagePDF = Page.OfertaEstandarPDF;
                pagePDF.getParameters().put('idOferta', qE.Id);
                Test.setCurrentPage(pagePDF);

                OfertaEstandarPDFController controller = new OfertaEstandarPDFController();
                system.assertEquals(1, controller.numTotalEnergias);

                Test.stopTest();
        }

        @isTest
        static void TEST_OfertaEstandarPDFController3()
        {
                Account a = new Account();
                a.Name = 'EMPRESA';
                insert a;

                Opportunity op = new Opportunity();
                op.Name ='OpTest';
                op.StageName = 'Identificada';
                op.CloseDate = Date.today();
                op.AccountId = a.Id;
                insert op;

                Quote qE = new Quote();
                qE.Name = 'OfETest';
                qE.Status = 'Preparando';
                qE.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id;
                qE.OpportunityId = op.Id;
                qE.Fecha_vigencia__c = Date.today().addYears(1);
                qE.Observaciones__c = '';
                qE.Enviar_email__c = true;
                qE.Resolucion_anticipada__c = 1202;
                qE.Prioridades_comodidad__c = true;
                qE.Prioridades_despreocuparse__c = false;
                qE.Prioridades_enterrado__c = true;
                qE.Prioridades_ahorro_anual__c = false;
                qE.Prioridades_precio_regulado__c = true;
                qE.Prioridades_pagar_consumo__c = false;
                qE.Prioridades_precio_fijo__c = true;
                qE.Prioridades_tarifa_plana__c = false;
                qE.Prioridades_impacto__c = 'Impacto bajo';
                qE.Kg__c = 1;
                qE.KWh__c = 2;
                qE.Litros__c = 3;
                qE.KgCO2__c = 4;
                qE.KgCO2_Primagas__c = 5;
                qE.KWh_Primagas__c = 11;
                qE.Diferencia_kgCO2__c = 12;
                qE.Diferencia_kWh__c = 13;
                qE.Interior_estandar__c = 'IntEstandarTest';
                qE.Exterior_estandar__c = 'ExtEstandarTest';
                qE.Servicio_estandar__c = 'ServEstandarTest';
                qE.Tarifa_estandar__c = 'TARIFA_TEST';
                qE.Precio_L__c = 7;
                qE.Precio_Kg__c = 8;
                qE.Valor_del_servicio_estandar__c = 9;
                qE.Importe_total_primagas__c = 14;
                qE.Importe_total__c = 15;
                qE.Diferencia_importes_totales__c = 16;
                qE.Pago_inicial__c = 17;
                qE.Duracion_descuento__c = '18 AÑOS';
                qE.Consumo_contratado_kg__c = 19;
                qE.Consumo_contratado_L__c = 20;
                qE.Duracion_contratado__c = '21 AÑOS';
                qE.Dto_Estandar__c = 22;
                qE.Texto_servicio_estandar__c = 'Texto opción servicio seleccionado';
                qE.Precio_fecha__c = 'Precio SEP';
                insert qE;

                insert new OpcionesOfertaSTD__c(Name = 'OfertaSTD112', Oferta__c = 'OfertaSTD112',OpcInterior__c = 'No incluido', OpcExterior__c = 'Depósito Aéreo', OpcServicio__c = 'Telemedida');


                Test.startTest();

                PageReference pagePDF = Page.OfertaEstandarPDF;
                pagePDF.getParameters().put('idOferta', qE.Id);
                Test.setCurrentPage(pagePDF);

                OfertaEstandarPDFController controller = new OfertaEstandarPDFController();
                system.assertEquals(0, controller.numTotalEnergias);

                Test.stopTest();
        }

        @isTest
        static void TEST_OfertaEstandarPDFController4()
        {
                Account a = new Account();
                a.Name = 'EMPRESA';
                insert a;

                Opportunity op = new Opportunity();
                op.Name ='OpTest';
                op.StageName = 'Identificada';
                op.CloseDate = Date.today();
                op.AccountId = a.Id;
                insert op;

                Quote qE = new Quote();
                qE.Name = 'OfETest';
                qE.Status = 'Preparando';
                qE.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id;
                qE.OpportunityId = op.Id;
                qE.Fecha_vigencia__c = Date.today().addYears(1);
                qE.Observaciones__c = '';
                qE.Enviar_email__c = true;
                qE.Resolucion_anticipada__c = 1202;
                qE.Prioridades_comodidad__c = true;
                qE.Prioridades_despreocuparse__c = false;
                qE.Prioridades_enterrado__c = true;
                qE.Prioridades_ahorro_anual__c = false;
                qE.Prioridades_precio_regulado__c = true;
                qE.Prioridades_pagar_consumo__c = false;
                qE.Prioridades_precio_fijo__c = true;
                qE.Prioridades_tarifa_plana__c = false;
                qE.Prioridades_impacto__c = 'Impacto bajo';
                qE.Kg__c = 1;
                qE.KWh__c = 2;
                qE.Litros__c = 3;
                qE.KgCO2__c = 4;
                qE.KgCO2_Primagas__c = 5;
                qE.KWh_Primagas__c = 11;
                qE.Diferencia_kgCO2__c = 12;
                qE.Diferencia_kWh__c = 13;
                qE.Interior_estandar__c = 'IntEstandarTest';
                qE.Exterior_estandar__c = 'ExtEstandarTest';
                qE.Servicio_estandar__c = 'ServEstandarTest';
                qE.Tarifa_estandar__c = 'TARIFA_TEST';
                qE.Precio_L__c = 7;
                qE.Precio_Kg__c = 8;
                qE.Valor_del_servicio_estandar__c = 9;
                qE.Importe_total_primagas__c = 0;
                qE.Importe_total__c = 0;
                qE.Diferencia_importes_totales__c = 16;
                qE.Pago_inicial__c = 0;
                qE.Duracion_descuento__c = '18 AÑOS';
                qE.Consumo_contratado_kg__c = 19;
                qE.Consumo_contratado_L__c = 20;
                qE.Duracion_contratado__c = '21 AÑOS';
                qE.Dto_Estandar__c = 22;
                qE.Texto_servicio_estandar__c = 'Texto opción servicio seleccionado';
                qE.Precio_fecha__c = 'Precio SEP';
                insert qE;

                insert new OpcionesOfertaSTD__c(Name = 'OfertaSTD112', Oferta__c = 'OfertaSTD112',OpcInterior__c = 'No incluido', OpcExterior__c = 'Depósito Aéreo', OpcServicio__c = 'Telemedida');


                Test.startTest();

                PageReference pagePDF = Page.OfertaEstandarPDF;
                pagePDF.getParameters().put('idOferta', qE.Id);
                Test.setCurrentPage(pagePDF);

                OfertaEstandarPDFController controller = new OfertaEstandarPDFController();
                system.assertEquals(0, controller.numTotalEnergias);

                Test.stopTest();
        }
}