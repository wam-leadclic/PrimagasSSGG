@isTest
private class TEST_OfertaModularPDFController
{
	//Método para dar cobertura
	@isTest
	static void TEST_OfertaModularPDFController()
	{
                //Cambios rfernandez (23/02/2017)
                DepositosMaestros__c deposito = new DepositosMaestros__c();
                deposito.Deposito__c = 'DescripciónDepoTest';
                deposito.Capacidad__c = 10;
                deposito.Vallado__c = 11;
                deposito.Obra_civil__c = 12;
                deposito.D__c = 13;
                deposito.Memoria__c = 14;
                deposito.Proyecto__c = 15;
                deposito.Instalacion_exterior__c = 16;
                deposito.Resolucion_anticipada__c = 17;
                deposito.Desmantelamiento__c = 'Desmant. Test';
                deposito.EsAereo__c = true;
                deposito.Activo__c =true;
                deposito.Name = 'DepositoTest';
                insert deposito;
                //Fin cambios rfernandez

		Account a = new Account();
                a.Name = 'EMPRESA';
                a.Actividad__c = 'Agricultura';
                insert a;

		Opportunity op = new Opportunity();
                op.Name ='OpTest';
                op.StageName = 'Identificada';
                op.CloseDate = Date.today();
                op.AccountId = a.Id;
                insert op;

		Quote qM = new Quote();
                qM.Name = 'OfMTest';
                qM.Status = 'Preparando';
                qM.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id;
                qM.OpportunityId = op.Id;
                qM.Fecha_vigencia__c = Date.today().addYears(1);
                qM.Observaciones__c = 'ObservacionesQM';
                qM.Enviar_email__c = false;
                qM.Resolucion_anticipada__c = 1201;
                qM.Prioridades_comodidad__c = true;
                qM.Prioridades_despreocuparse__c = false;
                qM.Prioridades_enterrado__c = true;
                qM.Prioridades_ahorro_anual__c = false;
                qM.Prioridades_precio_regulado__c = true;
                qM.Prioridades_pagar_consumo__c = false;
                qM.Prioridades_precio_fijo__c = true;
                qM.Prioridades_tarifa_plana__c = false;
                qM.Prioridades_impacto__c = 'Impacto alto';
                qM.Importe_total_primagas__c = 14;
                qM.Importe_total__c = 15;
                qM.Diferencia_importes_totales__c = 16;
                qM.Kg__c = 11;
                qM.KWh__c = 12;
                qM.Litros__c = 13;
                qM.KgCO2__c = 14;
                qM.KgCO2_Primagas__c = 15;
                qM.KWh_Primagas__c = 10;
                qM.Diferencia_kgCO2__c = 9;
                qM.Diferencia_kWh__c = 8;
                qM.Equipo_interior__c = 'EquipoIntMod';
                qM.Coste_equipo_interior__c = 21;
                qM.Interior__c = true;
                qM.Exterior__c = false;
                qM.Coste_instalacion_interior__c = 16;
                qM.Coste_instalacion_exterior__c = 17;
                qM.Coste_deposito__c = 19;
                qM.Deposito_nombre__c = 'DescripciónDepoTest';
                qM.Vallado__c = true;
                qM.Coste_vallado__c = 10;
                qM.Obra_civil__c = false;
                qM.Coste_obra_civil__c = 11;
                qM.Total_inversion__c = 12;
                qM.Total_financiable__c = 13;
                qM.Pago_inicial__c = 14;
                qM.Tipo_de_interes__c = 15;
                qM.Instalacion_interior__c = 'InstIntMod';
                qM.Coste_proyectos__c = 22;
                qM.Proyectos__c = 'Proyecto';
                qM.Financiacion_seleccionada__c = 'FinanciaGas';
                qM.Numero_de_cuotas__c = 16;
                qM.Importe_de_cuotas__c = 17;
                qM.Importe_12_cuotas__c = 18;
                qM.Importe_en_gas_en_E_L__c = 19;
                qM.Importe_en_gas_en_E_Kg__c = 20;
                qM.Precio_mensual_L__c = 23;
                qM.Precio_fijo_anual_L__c = 24;
                qM.Contador_L__c = 25;
                qM.Tarifa_plana_L__c = 26;
                qM.Precio_mensual_Kg__c = 27;
                qM.Precio_fijo_anual_Kg__c = 28;
                qM.Contador_Kg__c = 29;
                qM.Tarifa_plana_Kg__c = 30;
                qM.Nivel_PB__c = 'NivelPBQM';
                qM.Tipo_de_tarifa__c = 'TipoTarifaQM';
                qM.Pago_inicial_inversion__c = 41;
                qM.Cuota_inversion__c = 34;
                qM.Duracion_cuota_inversion__c = 35;
                qM.Dto_1_Llenado_inversion__c = 36;
                qM.Importe_ahorro_instalacion__c = 37;
                qM.Opcion_seleccionada_producto__c = 'Fijo';
                qM.Importe_ahorro_gas__c = 38;
                qM.Texto_fecha_producto__c = 'Precio JUL';
                qM.Tipo_de_pago_inversion__c = 'Pagotest';
                qM.Tipo_producto_gas__c = 'ProdGasTest';
                qM.Duracion_descuento__c = '50 AÑOS';
                qM.Dto_Producto_gas__c = 51;
                qM.Precio_producto_gas__c = 52;
                qM.Tipo_Primaservicios__c = 'PrimaservTest';
                qM.Mantenimiento_primaservicios__c = true;
                qM.Inspeccion_interior_primaservicios__c = false;
                qM.Revision_interior_primaservicios__c = true;
                qM.Precio_Primaservicios__c = 60;
                qM.Obra_civil__c = true;
                insert qM;

                Deposito__c d1M = new Deposito__c();
                d1M.Name = 'DepoTestM1';
                d1M.Cantidad__c = 100;
                d1M.Equipos_exterior__c = 101;
                d1M.Instalacion_exterior__c = 105;
                d1M.Proyectos__c = 103;
                d1M.Obra_civil_vallado__c = 104;
                d1M.Presupuesto__c = qM.Id;
                insert d1M;

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
                ps.Numero_de_pack__c =1;
                ps.Name_Pack_maestros__c = p.Name;
                ps.Presupuesto__c = qM.Id;
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
                energia.Presupuesto__c = qM.Id;
                insert energia;

                EnergiaUnidades__c energiaUnidad = new EnergiaUnidades__c();
                energiaUnidad.Name ='energiaUnidadKgAnio';
                energiaUnidad.UnidadConsumo__c = 'Kg/año';
                energiaUnidad.Abreviatura_unidad_consumo__c = 'kg';
                insert energiaUnidad;

                ServiciosActividad__c servicioActividad = new ServiciosActividad__c();
                servicioActividad.Name = 'servicioActividadAgricultura';
                servicioActividad.Actividad__c = 'Agricultura';
                servicioActividad.Activo__c = true;
                servicioActividad.MOSTRAR1__c = p.Name;
                servicioActividad.MOSTRAR2__c = p.Name;
                servicioActividad.MOSTRAR3__c = p.Name;
                insert servicioActividad;



                Test.startTest();

                PageReference pagePDF = Page.OfertaModularPage;
		pagePDF.getParameters().put('idOferta', qM.Id);
		Test.setCurrentPage(pagePDF);

		OfertaModularController controller = new OfertaModularController();
		system.assertEquals(1, controller.numTotalEnergias);

		OfertaModularController.EntidadServicio es1 = new OfertaModularController.EntidadServicio();
		es1.nombre = 'servicio1';
		es1.incluidoCol1 = true;
		es1.incluidoCol2 = true;
		es1.incluidoCol3 = true;
		OfertaModularController.EntidadServicio es2 = new OfertaModularController.EntidadServicio();
		es2.nombre = 'servicio2';
		es2.incluidoCol1 = true;
		es2.incluidoCol2 = true;
		es2.incluidoCol3 = true;
		OfertaModularController.EntidadServicio es3 = new OfertaModularController.EntidadServicio();
		es3.nombre = 'servicio3';
		es3.incluidoCol1 = true;
		es3.importeCol2 = '100';
		es3.incluidoCol3 = true;
		OfertaModularController.EntidadServicio es4 = new OfertaModularController.EntidadServicio();
		es4.nombre = 'servicio4';
		es4.incluidoCol1 = true;
		es4.incluidoCol2 = true;
		es4.importeCol3 = '100';
		OfertaModularController.EntidadServicio es5 = new OfertaModularController.EntidadServicio();
		es5.nombre = 'servicio5';
		es5.importeCol1 = '100';
		es5.importeCol2 = '200';
		es5.importeCol3 = '300';

		es1.compareTo(es2);
		es1.compareTo(es3);
		es1.compareTo(es4);
		es1.compareTo(es5);

		Test.stopTest();
	}
}