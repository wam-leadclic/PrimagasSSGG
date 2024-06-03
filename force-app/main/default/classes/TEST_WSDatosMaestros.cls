@isTest
private class TEST_WSDatosMaestros
{
	@isTest static void peticionSinDatos() 
	{
		WSDatosMaestros.PeticionDatosMaestros peticion = null;

		Test.startTest();
		String jDatos = WSDatosMaestros.getDatosMaestros(peticion);
		Test.stopTest();

		WSDatosMaestros.Respuesta r = (WSDatosMaestros.Respuesta) JSON.deserialize(jDatos, WSDatosMaestros.Respuesta.class);

		System.debug('Respuesta: ' + r);

		System.assertEquals('400', r.resultado.codigo);
	}

	@isTest static void peticionSinProvincia()
	{
		// preparar datos
		ConfiguracionBase_NewSales__c configuracion = new ConfiguracionBase_NewSales__c();
		configuracion.Valor__c = '10';
		configuracion.Name = 'CONFIG_TEST';
		insert configuracion;

		Listas_de_seleccion__c listaSeleccion = new Listas_de_seleccion__c();
		listaSeleccion.Identificador__c = 'TipoTest';
		listaSeleccion.Valor__c = 'ValorTest';
		listaSeleccion.Idioma__c = 'ES';
		listaSeleccion.Activo__c = true;
		listaSeleccion.Name = 'TipoTestCastellanoValorTest';
		insert listaSeleccion;

		PreciosKE__c precioKE = new PreciosKE__c();
		precioKE.Precio__c = 'PrecioKETest';
		precioKE.K__c = 'KTest';
		precioKE.Activo__c = true;
		precioKE.Name = 'PrecioKETest';
		insert precioKE;

		TarifasModulares__c tarifaMod = new TarifasModulares__c();
		tarifaMod.K1__c = 1;
		tarifaMod.K2__c = 2;
		tarifaMod.K3__c = 3;
		tarifaMod.K4__c = 4;
		tarifaMod.TR__c = 5;
		tarifaMod.Provincia__c = 'Bizkaia';
		tarifaMod.Activo__c = true;
		tarifaMod.Name = 'TarifModTest';
		insert tarifaMod;

		NivelesPB__c nivel = new NivelesPB__c();
		nivel.Valor__c = 80;
		nivel.Activo__c = true;
		nivel.Name = 'NivelPBTest';
		insert nivel;

		NivelesPbModular__c nivelPBModular = new NivelesPbModular__c();
		nivelPBModular.Origen__c = 'OrigenTest';
		nivelPBModular.Actividad__c = 'ActividadTest';
		nivelPBModular.NombreTarifa__c = 'NombreTarifaTest';
		nivelPBModular.Precio_E_Kg__c = 6;
		nivelPBModular.Precio_E_l__c = 7;
		nivelPBModular.Activo__c = true;
		nivelPBModular.Name = 'NivelPBModularTest';
		insert nivelPBModular;

		ServiciosActividad__c servAct = new ServiciosActividad__c();
		servAct.Actividad__c = 'ActividadTest';
		servAct.MOSTRAR1__c = 'Pack1Test';
		servAct.MOSTRAR2__c = 'Pack2Test';
		servAct.MOSTRAR3__c = 'Pack3Test';
		servAct.Activo__c = true;
		servAct.Name = 'ServActTest';
		insert servAct;

		Pack__c pack = new Pack__c();
		pack.Name = 'Pack1Test';
		pack.ConsumoMax__c = 70;
		pack.ImporteMensual__c = 71;
		pack.Nombre__c = 'NombreTest';
		pack.Numero_de_pack__c = 1;
		pack.Activo__c = true;
		insert pack;

		ServiciosPacks__c servPack = new ServiciosPacks__c();
		servPack.Name = 'ServPack1Test';
		servPack.Importe_mensual__c = 72;
		servPack.Incluido__c = true;
		servpack.Numero_de_pack__c = 1;
		servpack.Nombre__c = 'NombreServ1Test';
		insert servPack;

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

		DepositosRecomendados__c depoRec = new DepositosRecomendados__c();
		depoRec.Capacidad_minima__c = '2000 L';
		depoRec.Capacidad_maxima__c = '4000 L';
		depoRec.Potencia_minima__c = '200 KW';
		depoRec.Potencia_maxima__c = '300 KW';
		depoRec.Deposito__c = 'XTest';
		depoRec.Activo__c = true;
		depoRec.Name = 'DepoRecTest';
		insert depoRec;

		CambioRendimientoAsociado__c cambio = new CambioRendimientoAsociado__c();
		cambio.Energia__c = 'EnergiaCambioTest';
		cambio.Cambio__c = 'CambioTest';
		cambio.Rendimiento__c = 20;
		cambio.Antiguedad_desde__c = 21;
		cambio.Antiguedad_hasta__c = 22;
		cambio.Activo__c = true;
		cambio.Name = 'CambioTest';
		insert cambio;

		EnergiaUnidades__c energiaUnidad = new EnergiaUnidades__c();
		energiaUnidad.Energia__c = 'EnergiaTest';
		energiaUnidad.UnidadConsumo__c = 'UConsumoTest';
		energiaUnidad.Unidad_PCI__c = 'UPCITest';
		energiaUnidad.UnidadPrecio__c = 'UPrecioTest';
		energiaUnidad.Unidad_CO2__c = 'UCO2Test';
		energiaUnidad.PCI__c = 30;
		energiaUnidad.CO2__c = 31;
		energiaUnidad.C__c = 'CTest';
		energiaUnidad.Codigo_tarifa__c = 'Botellas';
		energiaUnidad.Activo__c = true;
		energiaUnidad.Name = 'EnergiaUnidadTest';
		insert energiaUnidad;

		EquiposUsos__c equipoUsos = new EquiposUsos__c();
		equipoUsos.Equipos__c = 'EquipoTest';
		equipoUsos.Usos__c = 'UsoTest1;UsoTest2';
		equipoUsos.Activo__c = true;
		equipoUsos.Name = 'EquipoUsoTest';
		insert equipoUsos;

		OpcionesFinanciacion__c opcionF = new OpcionesFinanciacion__c();
		opcionF.Cuotas__c = 40;
		opcionF.InteresAnual__c = 41;
		opcionF.Activo__c = true;
		opcionF.Name = 'OpcionFinancTest';
		insert opcionF;

		ImagenesOferta__c imgOferta = new ImagenesOferta__c();
		imgOferta.Oferta__c = 'OfertaTest';
		imgOferta.ImagenBase64__c = 'Base64Test';
		imgOferta.Activo__c = true;
		imgOferta.Name = 'ImgOfertaTest';
		insert imgOferta;

		OpcionesOfertaSTD__c opcionO = new OpcionesOfertaSTD__c();
		opcionO.CuotaMensual__c = 50;
		opcionO.Desde__c = 'DesdeTest';
		opcionO.Dto_E_Kg__c = 51;
		opcionO.Deposito__c = 'DepoTest';
		opcionO.DuracionDto__c = 53;
		opcionO.Oferta__c = 'OfertaTest';
		opcionO.OpcExterior__c = 'ExtTest';
		opcionO.OpcInterior__c = 'IntTest';
		opcionO.OpcServicio__c = 'ServTest';
		opcionO.Tarifa__c = 'TarifaTest';
		opcionO.Activo__c = true;
		opcionO.Name = 'OpcionOTest';
		insert opcionO;

		TextoOfertasEstandar__c txtOf = new TextoOfertasEstandar__c();
		txtOf.Oferta__c = 'OfertaTest';
		txtOf.Tipo__c = 'TipoTest';
		txtOf.TextoOferta__c = 'TxtOfertaTest';
		txtOf.Activo__c = true;
		txtOf.Name = 'TxtOfEstandarTest';
		insert txtOf;

		Account pr = new Account();
		pr.Name = 'ProveedorTest';
		pr.Colaborador_activo__c = true;
		pr.RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Partner').Id;
		insert pr;

		CostesOtrosEquipos__c coe = new CostesOtrosEquipos__c();
		coe.Descripcion__c = 'Contador';
		coe.Equipos_exterior__c = 70;
		coe.Equipos_interior__c = 71;
		coe.Instalacion_exterior__c = 72;
		coe.Instalacion_interior__c = 73;
		coe.Name = 'CosteOtrosEqTest';
		coe.Activo__c = true;
		insert coe;

		// preparar petición
		WSDatosMaestros.PeticionDatosMaestros peticion = new WSDatosMaestros.PeticionDatosMaestros();
		peticion.datosMaestros = new WSDatosMaestros.DatosMaestros();
		peticion.datosMaestros.idioma = 'ES';

		// ejecutar test
		Test.startTest();
		String jDatos = WSDatosMaestros.getDatosMaestros(peticion);
		Test.stopTest();

		// comprobar resultado
		WSDatosMaestros.Respuesta r = (WSDatosMaestros.Respuesta) JSON.deserialize(jDatos, WSDatosMaestros.Respuesta.class);

		System.debug('Respuesta: ' + r);

		System.assertEquals('400', r.resultado.codigo);
		System.assertNotEquals(null, r.configuracionBase);
		System.assertEquals(1, r.configuracionBase.size());
		System.assertNotEquals(null, r.desplegables);
		System.assertEquals(1, r.desplegables.size());
		System.assertNotEquals(null, r.preciosKE);
		System.assertEquals(1, r.preciosKE.size());
		System.assertNotEquals(null, r.tarifasModulares);
		System.assertEquals(1, r.tarifasModulares.size());
		System.assertNotEquals(null, r.nivelesPB);
		System.assertEquals(1, r.nivelesPB.size());
		System.assertNotEquals(null, r.nivelesPBModular);
		System.assertEquals(1, r.nivelesPBModular.size());
		System.assertNotEquals(null, r.packsActividad);
		System.assertEquals(1, r.packsActividad.size());
		System.assertNotEquals(null, r.packsServicio);
		System.assertEquals(1, r.packsServicio.size());
		System.assertEquals(1, r.packsServicio.get(0).servicios.size());
		System.assertNotEquals(null, r.depositos);
		System.assertEquals(1, r.depositos.size());
		System.assertNotEquals(null, r.depositoRecomendado);
		System.assertEquals(1, r.depositoRecomendado.size());
		System.assertNotEquals(null, r.cambioRendimientoAsociado);
		System.assertEquals(1, r.cambioRendimientoAsociado.size());
		System.assertNotEquals(null, r.energiaUnidades);
		System.assertEquals(1, r.energiaUnidades.size());
		System.assertNotEquals(null, r.equiposUsos);
		System.assertEquals(1, r.equiposUsos.size());
		System.assertNotEquals(null, r.equiposUsos.get(0).usos);
		System.assertEquals(2, r.equiposUsos.get(0).usos.size());
		System.assertNotEquals(null, r.opcionesFinanciacion);
		System.assertEquals(1, r.opcionesFinanciacion.size());
		System.assertNotEquals(null, r.imagenesOferta);
		System.assertEquals(1, r.imagenesOferta.size());
		System.assertNotEquals(null, r.opcionesOfertaSTD);
		System.assertEquals(1, r.opcionesOfertaSTD.size());
		System.assertNotEquals(null, r.textosOfertaEstandar);
		System.assertEquals(1, r.textosOfertaEstandar.size());
		System.assertNotEquals(null, r.colaboradores);
		System.assertEquals(1, r.colaboradores.size());
		System.assertNotEquals(null, r.costesOtrosEquipos);
		System.assertEquals(1, r.costesOtrosEquipos.size());
	}

	@isTest static void peticionConProvincia()
	{
		// preparar datos
		Listas_de_seleccion__c listProv = new Listas_de_seleccion__c();
		listProv.Name = 'NAME_PROV_TEST';
		listProv.Valor__c = 'Bizkaia';
		listProv.Identificador__c = 'Provincia';
		listProv.Activo__c = true;
		listprov.Idioma__c = 'ES';
		insert listProv;

		ServiciosPacks__c servPack = new ServiciosPacks__c();
		servPack.Name = 'ServPack1Test';
		servPack.Importe_mensual__c = 72;
		servPack.Incluido__c = true;
		servpack.Numero_de_pack__c = 1;
		servpack.Nombre__c = 'NombreServ1Test';
		insert servPack;

		TarifasModulares__c tarifaMod = new TarifasModulares__c();
		tarifaMod.K1__c = 1;
		tarifaMod.K2__c = 2;
		tarifaMod.K3__c = 3;
		tarifaMod.K4__c = 4;
		tarifaMod.TR__c = 5;
		tarifaMod.Provincia__c = 'Bizkaia';
		tarifaMod.Activo__c = true;
		tarifaMod.Name = 'TarifModTest';
		insert tarifaMod;

		OpcionesPbiTramosC__c opcion = new OpcionesPbiTramosC__c();
		opcion.Provincia__c = 'Bizkaia';
		opcion.Usuarios__c = 'userTest';
		opcion.Actividad__c = 'ActividadTest';
		opcion.DuracionContrato__c = 10;
		opcion.PBI__c = 11;
		opcion.T1__c = 12;
		opcion.T2__c = 13;
		opcion.T3__c = 14;
		opcion.C__c = 15;
		opcion.Activo__c = true;
		opcion.Name = 'OpcionTest';
		insert opcion;

		LimiteInversionPb__c limite  = new LimiteInversionPb__c();
		limite.Usuario__c = 'usuarioTest';
		limite.LimitePB__c = 40;
		limite.LimiteIR__c = 41;
		limite.Email__c = 'aaaa@test.com';
		limite.Mensaje__c = 'MensajeTest';
		limite.Activo__c = true;
		limite.Name = 'LimiteTest';
		insert limite;

		CostesLegalizacionProvincia__c costeLeg = new CostesLegalizacionProvincia__c();
		costeLeg.Provincia__c = 'Bizkaia';
		costeLeg.Deposito__c ='DepoLegTest';
		costeLeg.Coste__c = 17;
		costeLeg.Activo__c = true;
		costeLeg.Name = 'DepoLegTest';
		insert costeLeg;

		CostesMantenimientoProvincia__c costeMto = new CostesMantenimientoProvincia__c();
		costeMto.Provincia__c = 'Bizkaia';
		costeMto.Deposito__c ='DepoMtoTest';
		costeMto.Coste__c = 18;
		costeMto.Activo__c = true;
		costeMto.Name = 'DepoMtoTest';
		insert costeMto;

		ServicioCosteExtra__c sce = new ServicioCosteExtra__c();
		sce.Name='ServCE test';
		sce.Name_provincia__c = 'NAME_PROV_TEST';
		sce.Tipo__c = 0;
		sce.Coste__c = 10;
		sce.Descripcion__c = 'Desctest';
		sce.Activo__c = true;
		insert sce;

		// preparar petición
		WSDatosMaestros.PeticionDatosMaestros peticion = new WSDatosMaestros.PeticionDatosMaestros();
		peticion.datosMaestros = new WSDatosMaestros.DatosMaestros();
		peticion.datosMaestros.idioma = 'ES';
		peticion.datosMaestros.provincia = 'Bizkaia';
		peticion.datosMaestros.usuarioLogueado = 'userTest';

		// ejecutar test
		Test.startTest();
		String jDatos = WSDatosMaestros.getDatosMaestros(peticion);
		Test.stopTest();

		// comprobar resultado
		WSDatosMaestros.Respuesta r = (WSDatosMaestros.Respuesta) JSON.deserialize(jDatos, WSDatosMaestros.Respuesta.class);

		System.debug('Respuesta: ' + r);

		System.assertEquals('400', r.resultado.codigo);
		System.assertNotEquals(null, r.tarifasModulares);
		System.assertEquals(1, r.tarifasModulares.size());
		System.assertNotEquals(null, r.opcionesPBiTramosC);
		System.assertEquals(1, r.opcionesPBiTramosC.size());
		System.assertNotEquals(null, r.costesLegalizacionProvincia);
		System.assertEquals(1, r.costesLegalizacionProvincia.size());
		System.assertNotEquals(null, r.costesMantenimientoProvincia);
		System.assertEquals(1, r.costesMantenimientoProvincia.size());
	}	
}