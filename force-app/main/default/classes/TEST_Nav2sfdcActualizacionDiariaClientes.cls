@isTest
private class TEST_Nav2sfdcActualizacionDiariaClientes 
{
	private static final Integer NUM_CUENTAS_EMPRESA		= 1;         // Numero de cuentas a crear
	private static final Integer NUM_CUENTAS_PARTICULARES	= 1;         // Numero de cuentas a crear
	private static final Integer NUM_DIRECCIONES 			= 1;         // Numero de direcciones de entrega 

	@TestSetup 
	static void generateEnvironment()
	{	
		RecordType clienteExistente = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');


		List<Account> cuentasList = Util.generarCuentas(NUM_CUENTAS_PARTICULARES, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
		List<Direcci_n_de_entrega__c> direccionesList = new List<Direcci_n_de_entrega__c>();

		/*CUENTAS EMPRESA*/
		for(Integer i = 0 ; i < cuentasList.size() ; i++)
		{
			cuentasList[i].Id_Navision__c = String.valueOf(NUM_CUENTAS_EMPRESA+i);
		}

		AccountUtil.semaforoUpdate = false;
		insert cuentasList;
		AccountUtil.semaforoUpdate = true;

		/*DIRECCIONES DE ENTREGA*/
		for(Account cuenta : cuentasList)
		{
			Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c(
				Cuenta__c = cuenta.Id,
				Provincia__c = 'Bizkaia/Vizcaya',
				Id_Navision__c	= String.valueOf(NUM_DIRECCIONES)
			);
			direccionesList.add(direccion);
		}
		

		DireccionEnvioUtil.semaforoUpdate = false;
		insert direccionesList;
		DireccionEnvioUtil.semaforoUpdate = true;

	}
	
	//Metodo encargado de comprobar que se ha actualizado correctamente una cuenta y direccion concretas 
	//(las que vienen en el MockUp que se han identificado como la cuenta 1 y direccion 1)
	//En este caso cada cuenta tiene solo una direccion de entrega
	@isTest 
	static void actualizacionCorrecta() 
	{
		Test.startTest();

        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(0));
		Nav2sfdc_ActualizacionDiariaClientes detalleClientes = new Nav2sfdc_ActualizacionDiariaClientes(0);
    	detalleClientes.execute(null);

    	Test.stopTest();
		/*
		Se quita del select de abajo los campos Saldo_vivo__c, Saldo_pendiente__c,Descuento__c, Consumo_promedio_ltimos_3_a_os__c, Consumo_ltimos_12_meses__c,; para poder cambio el tipo de campo.
		 */
    	for(Account cuenta: [SELECT Id, Id_Navision__c,  Alerta_Bloqueo__c, Ultima_sync_detalle_clientes__c,
								(SELECT Id, Id_Navision__c, Consumo_previsto_Kgs__c, 
								Precio_actual__c, Boca_de_carga__c, Estado_boca_de_carga__c, Deposito__c, Estado_deposito__c, Telemedida__c,
								Estado_telemedida__c, Propiedad_del_tanque__c
								 FROM Direcciones_de_entrega__r) 
							FROM Account])
		{  
			if(cuenta.Id_Navision__c.equals('1'))
			{
				//System.assertEquals(cuenta.Saldo_vivo__c, 9.95);
				//System.assertEquals(cuenta.Saldo_pendiente__c, 9.95);
				//System.assertEquals(cuenta.Alerta_Bloqueo__c, 'TestAlertaBloqueo');
				System.assertEquals(Date.newinstance(cuenta.Ultima_sync_detalle_clientes__c.year(), cuenta.Ultima_sync_detalle_clientes__c.month(), cuenta.Ultima_sync_detalle_clientes__c.day()), System.today());
			}else{
				//System.assertEquals(cuenta.Saldo_vivo__c, null);
				//System.assertEquals(cuenta.Saldo_pendiente__c, null);
				//System.assertEquals(cuenta.Alerta_Bloqueo__c, null);
				System.assertEquals(cuenta.Ultima_sync_detalle_clientes__c, null);
			}
			for(Direcci_n_de_entrega__c direccion : cuenta.Direcciones_de_entrega__r)
		    {
		    	if(cuenta.Id_Navision__c.equals('1'))
				{
					System.assertEquals(direccion.Consumo_previsto_Kgs__c, 1000);
					//System.assertEquals(direccion.Consumo_promedio_ltimos_3_a_os__c, 526);
					//System.assertEquals(direccion.Consumo_ltimos_12_meses__c, 526);
					//System.assertEquals(direccion.Precio_actual__c, '1,012');
					//System.assertEquals(direccion.Descuento__c, 0);
					System.assertEquals(direccion.Boca_de_carga__c, 'TestBocaCarga');
					System.assertEquals(direccion.Estado_boca_de_carga__c, 'TestBocaCarga');
					System.assertEquals(direccion.Deposito__c, 'DEP010199--245490729');
					System.assertEquals(direccion.Estado_deposito__c, 'Installed');
					System.assertEquals(direccion.Telemedida__c, 'TELM001058--4962748');
					System.assertEquals(direccion.Estado_telemedida__c, 'Installed');
					System.assertEquals(direccion.Propiedad_del_tanque__c, 'Own');
				}else{
					System.assertEquals(direccion.Consumo_previsto_Kgs__c, null);
					//System.assertEquals(direccion.Consumo_promedio_ltimos_3_a_os__c, null);
					//System.assertEquals(direccion.Consumo_ltimos_12_meses__c, null);
					System.assertEquals(direccion.Precio_actual__c, null);
					//System.assertEquals(direccion.Descuento__c, null);
					System.assertEquals(direccion.Boca_de_carga__c, null);
					System.assertEquals(direccion.Estado_boca_de_carga__c, null);
					System.assertEquals(direccion.Deposito__c, null);
					System.assertEquals(direccion.Estado_deposito__c, null);
					System.assertEquals(direccion.Telemedida__c, null);
					System.assertEquals(direccion.Estado_telemedida__c, null);
					System.assertEquals(direccion.Propiedad_del_tanque__c, null);
				}
		    }
		}
	}

	//Metodo encargado de comprobar que se no se actualiza ningun registro cuando no recibe nada 
	@isTest 
	static void actualizacionConRespuestaVacia() 
	{
		Test.startTest();

        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(2));
		Nav2sfdc_ActualizacionDiariaClientes detalleClientes = new Nav2sfdc_ActualizacionDiariaClientes(0);
    	detalleClientes.execute(null);

    	Test.stopTest();
		/*
		Se quita del select de abajo los campos Saldo_vivo__c, Saldo_pendiente__c,Descuento__c, Consumo_promedio_ltimos_3_a_os__c, Consumo_ltimos_12_meses__c,; para poder cambio el tipo de campo.
		 */
    	for(Account cuenta: [SELECT Id, Id_Navision__c, Alerta_Bloqueo__c, Ultima_sync_detalle_clientes__c,
								(SELECT Id, Id_Navision__c, Consumo_previsto_Kgs__c,
								Precio_actual__c, Boca_de_carga__c, Estado_boca_de_carga__c, Deposito__c, Estado_deposito__c, Telemedida__c,
								Estado_telemedida__c, Propiedad_del_tanque__c
								 FROM Direcciones_de_entrega__r) 
							FROM Account])
		{  
			//System.assertEquals(cuenta.Saldo_vivo__c, null);
			//System.assertEquals(cuenta.Saldo_pendiente__c, null);
			//System.assertEquals(cuenta.Alerta_Bloqueo__c, null);
			System.assertEquals(cuenta.Ultima_sync_detalle_clientes__c, null);

			for(Direcci_n_de_entrega__c direccion : cuenta.Direcciones_de_entrega__r)
		    {
				System.assertEquals(direccion.Consumo_previsto_Kgs__c, null);
				//System.assertEquals(direccion.Consumo_promedio_ltimos_3_a_os__c, null);
				//System.assertEquals(direccion.Consumo_ltimos_12_meses__c, null);
				System.assertEquals(direccion.Precio_actual__c, null);
				//System.assertEquals(direccion.Descuento__c, null);
				System.assertEquals(direccion.Boca_de_carga__c, null);
				System.assertEquals(direccion.Estado_boca_de_carga__c, null);
				System.assertEquals(direccion.Deposito__c, null);
				System.assertEquals(direccion.Estado_deposito__c, null);
				System.assertEquals(direccion.Telemedida__c, null);
				System.assertEquals(direccion.Estado_telemedida__c, null);
				System.assertEquals(direccion.Propiedad_del_tanque__c, null);
		    }
		}
	}
	
	//Metodo encargado de comprobar que se ha actualizado correctamente una cuenta y sus direcciones
	//(las que vienen en el MockUp que se han identificado como la cuenta 1 y direccion 1)
	//En este caso cada cuenta tiene solo una direccion de entrega
	@isTest 
	static void actualizacionCorrectaVariasDirecciones() 
	{
		List<Account> cuentasInsertadasList = [SELECT Id FROM Account];
		List<Direcci_n_de_entrega__c> nuevasDireccionesList = new List<Direcci_n_de_entrega__c>();

		for(Account cuenta : cuentasInsertadasList)
		{
			Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c(
				Cuenta__c = cuenta.Id,
				Provincia__c = 'Bizkaia/Vizcaya',
				Id_Navision__c	= String.valueOf(NUM_DIRECCIONES+1)
			);
			nuevasDireccionesList.add(direccion);
		}
		DireccionEnvioUtil.semaforoUpdate = false;
		insert nuevasDireccionesList;
		DireccionEnvioUtil.semaforoUpdate = true;

		Test.startTest();

        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(1));
		Nav2sfdc_ActualizacionDiariaClientes detalleClientes = new Nav2sfdc_ActualizacionDiariaClientes(0);
    	detalleClientes.execute(null);

    	Test.stopTest();
		/*
		Se quita del select de abajo los campos Saldo_vivo__c, Saldo_pendiente__c,Descuento__c, Consumo_promedio_ltimos_3_a_os__c, Consumo_ltimos_12_meses__c,; para poder cambio el tipo de campo.
		 */
    	for(Account cuenta: [SELECT Id, Id_Navision__c, Alerta_Bloqueo__c, Ultima_sync_detalle_clientes__c,
								(SELECT Id, Id_Navision__c, Consumo_previsto_Kgs__c,
								Precio_actual__c, Boca_de_carga__c, Estado_boca_de_carga__c, Deposito__c, Estado_deposito__c, Telemedida__c,
								Estado_telemedida__c, Propiedad_del_tanque__c
								 FROM Direcciones_de_entrega__r) 
							FROM Account])
		{  
			if(cuenta.Id_Navision__c.equals('1'))
			{
				//System.assertEquals(cuenta.Saldo_vivo__c, 9.95);
				//System.assertEquals(cuenta.Saldo_pendiente__c, 9.95);
				//System.assertEquals(cuenta.Alerta_Bloqueo__c, 'TestAlertaBloqueo');
				System.assertEquals(Date.newinstance(cuenta.Ultima_sync_detalle_clientes__c.year(), cuenta.Ultima_sync_detalle_clientes__c.month(), cuenta.Ultima_sync_detalle_clientes__c.day()), System.today());
			}else{
				//System.assertEquals(cuenta.Saldo_vivo__c, null);
				//System.assertEquals(cuenta.Saldo_pendiente__c, null);
				//System.assertEquals(cuenta.Alerta_Bloqueo__c, null);
				System.assertEquals(cuenta.Ultima_sync_detalle_clientes__c, null);
			}
			for(Direcci_n_de_entrega__c direccion : cuenta.Direcciones_de_entrega__r)
		    {
		    	if(cuenta.Id_Navision__c.equals('1'))
				{
					System.assertEquals(direccion.Consumo_previsto_Kgs__c, 1000);
					//System.assertEquals(direccion.Consumo_promedio_ltimos_3_a_os__c, 526);
					//System.assertEquals(direccion.Consumo_ltimos_12_meses__c, 526);
					//System.assertEquals(direccion.Precio_actual__c, '1,012');
					//System.assertEquals(direccion.Descuento__c, 0);
					System.assertEquals(direccion.Boca_de_carga__c, 'TestBocaCarga');
					System.assertEquals(direccion.Estado_boca_de_carga__c, 'TestBocaCarga');
					System.assertEquals(direccion.Deposito__c, 'DEP010199--245490729');
					System.assertEquals(direccion.Estado_deposito__c, 'Installed');
					System.assertEquals(direccion.Telemedida__c, 'TELM001058--4962748');
					System.assertEquals(direccion.Estado_telemedida__c, 'Installed');
					System.assertEquals(direccion.Propiedad_del_tanque__c, 'Own');
				}else{
					System.assertEquals(direccion.Consumo_previsto_Kgs__c, null);
					//System.assertEquals(direccion.Consumo_promedio_ltimos_3_a_os__c, null);
					//System.assertEquals(direccion.Consumo_ltimos_12_meses__c, null);
					System.assertEquals(direccion.Precio_actual__c, null);
					//System.assertEquals(direccion.Descuento__c, null);
					System.assertEquals(direccion.Boca_de_carga__c, null);
					System.assertEquals(direccion.Estado_boca_de_carga__c, null);
					System.assertEquals(direccion.Deposito__c, null);
					System.assertEquals(direccion.Estado_deposito__c, null);
					System.assertEquals(direccion.Telemedida__c, null);
					System.assertEquals(direccion.Estado_telemedida__c, null);
					System.assertEquals(direccion.Propiedad_del_tanque__c, null);
				}
		    }
		}
	}

	/*
		Cubre la llamada a la clase programable. Las validaciones se hacen directamente sobre la encolable
		Cubre una llamada al constructor
	*/
	@isTest 
	static void scheduler()
	{
		Test.startTest();

        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(0));
		Nav2sfdc_DetalleClientesScheduler detalleClientesScheduler = new Nav2sfdc_DetalleClientesScheduler(0);
    	detalleClientesScheduler.execute(null);

    	Test.stopTest();
    }

    @isTest 
	static void gestionErrores() 
	{
		Test.startTest();

		Nav2sfdc_ActualizacionDiariaClientes detalleClientes = new Nav2sfdc_ActualizacionDiariaClientes(0);
    	detalleClientes.execute(null);

    	Test.stopTest();

    	List<Log__c> logsList = [SELECT Id FROM Log__c];
    	System.assertEquals(1, logsList.size());
    }
}