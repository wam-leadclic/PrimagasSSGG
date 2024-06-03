@isTest
private class TEST_OfertaPersonalizadaPDFController
{
	//Método para dar cobertura
        @isTest
	static void TEST_OfertaPersonalizadaPDFController()
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

        	Quote qP = new Quote();
                qP.Name = 'OfPTest';
                qP.Status = 'Preparando';
                qP.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id;
                qP.OpportunityId = op.Id;
                qP.Fecha_vigencia__c = Date.today().addYears(1);
                qP.Observaciones__c = 'ObservacionesQP';
                qP.Enviar_email__c = false;
                qP.Resolucion_anticipada__c = 1200;
                qP.Prioridades_comodidad__c = true;
                qP.Prioridades_despreocuparse__c = false;
                qP.Prioridades_enterrado__c = true;
                qP.Prioridades_ahorro_anual__c = false;
                qP.Prioridades_precio_regulado__c = true;
                qP.Prioridades_pagar_consumo__c = false;
                qP.Prioridades_precio_fijo__c = true;
                qP.Prioridades_tarifa_plana__c = false;
                qP.Prioridades_impacto__c = 'Impacto medio';
                qP.Kg__c = 21;
                qP.KWh__c = 22;
                qP.Litros__c = 23;
                qP.KgCO2__c = 24;
                qP.KgCO2_Primagas__c = 25;
                qP.KWh_Primagas__c = 20;
                qP.Diferencia_kgCO2__c = 19;
                qP.Diferencia_kWh__c = 18;
                qP.Tipo_de_tarifa__c = 'TipoTarifaQP';
                qP.Pago_inicial_inversion__c = 41;
                qP.Cuota_inversion__c = 34;
                qP.Duracion_cuota_inversion__c = 35;
                qP.Dto_1_Llenado_inversion__c = 36;
                qP.Importe_total_primagas__c = 14;
                qP.Importe_total__c = 15;
                qP.Diferencia_importes_totales__c = 16;
                qP.Tipo_de_pago_inversion__c = 'Pagotest';
                qP.Tipo_producto_gas__c = 'ProdGasTest';
                qP.Duracion_descuento__c = '50 AÑOS';
                qP.Dto_Producto_gas__c = 51;
                qP.Precio_producto_gas__c = 52;
                qP.Tipo_Primaservicios__c = 'PrimaservTest';
                qP.Mantenimiento_primaservicios__c = true;
                qP.Inspeccion_interior_primaservicios__c = false;
                qP.Revision_interior_primaservicios__c = true;
                qP.Precio_Primaservicios__c = 60;
                insert qP;

                Deposito__c d1P = new Deposito__c();
                d1P.Name = 'DepoTestP1';
                d1P.Cantidad__c = 110;
                d1P.Equipos_exterior__c = 111;
                d1P.Instalacion_exterior__c = 115;
                d1P.Proyectos__c = 113;
                d1P.Obra_civil_vallado__c = 114;
                d1P.Presupuesto__c = qP.Id;
                insert d1P;

                Equipo_ajuste__c eA1P = new Equipo_ajuste__c();
                eA1P.Name = 'EATestP1';
                ea1P.Cantidad__c = 9;
                eA1P.Equipos_interior__c = 11;
                eA1P.Equipos_exterior__c = 12;
                eA1P.Instalacion_exterior__c = 14;
                eA1P.Instalacion_interior__c = 13;
                eA1P.Presupuesto__c = qP.Id;
                insert eA1P;

                Pack__c p = new Pack__c();
                p.Name = 'PackTest1';
                p.Numero_de_pack__c = 1;
                p.Nombre__c = 'Pack test 1';
                p.ConsumoMax__c = 10;
                p.Activo__c = true;
                p.ImporteMensual__c = 11;
                insert p;

                ServiciosPacks__c sp = new ServiciosPacks__c();
                sp.Name = 'ServPackTest1';
                sp.Incluido__c = true;
                sp.Nombre__c = 'Servicio Test 1';
                sp.Numero_de_pack__c = 1;
                insert sp;

                Pack_de_servicio__c ps = new Pack_de_servicio__c();
                ps.Consumo_maximo__c = 10;
                ps.Importe_mensual__c = 11;
                ps.Numero_de_pack__c = 1;
                ps.Name_Pack_maestros__c = p.Name;
                ps.Presupuesto__c = qP.Id;
                ps.Total_importe__c = 12;
                insert ps;

                Servicio__c s = new Servicio__c();
                s.Incluido__c = true;
                s.Name_Servicio_pack_maestro__c = sp.Name;
                s.Pack_de_servicio__c = ps.Id;
                insert s;

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
                energia.Presupuesto__c = qP.Id;
                insert energia;

                EnergiaUnidades__c energiaUnidad = new EnergiaUnidades__c();
                energiaUnidad.Name ='energiaUnidadKgAnio';
                energiaUnidad.UnidadConsumo__c = 'Kg/año';
                energiaUnidad.Abreviatura_unidad_consumo__c = 'kg';
                insert energiaUnidad;

                Test.startTest();

                PageReference pagePDF = Page.OfertaPersonalizadaPDF;
		pagePDF.getParameters().put('idOferta', qP.Id);
		Test.setCurrentPage(pagePDF);

		OfertaPersonalizadaPDFController controller = new OfertaPersonalizadaPDFController();
		system.assertEquals(1, controller.numTotalEnergias);

		Test.stopTest();
	}
}