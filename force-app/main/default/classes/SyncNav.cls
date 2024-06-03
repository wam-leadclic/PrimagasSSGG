/**
 * @description       : 
 * @author            : ivan.contreras@blackbirdcrew.com
 * @group             : 
 * @last modified on  : 04-21-2022
 * @last modified by  : ivan.contreras@blackbirdcrew.com
**/
public with sharing class SyncNav 
{

	public static XmlUtil.RespuestaPeticionSincronizarClientes respuestaPeticion;
	public static Map<Id,Contract> mapaContratosDatosBancarios = new Map<Id,Contract>();

	//Propiedad para recuperar el endpoint correcto a EnvioPedidoLectura en función de si estamos en Sandbox o no
    //@rcastanos (06/06/2019)
    public static String endpointEnvioPedidoLectura
    {
        get
        {
            if(endpointEnvioPedidoLectura == null)
            {
                if(Util.runningInASandbox)
				{
					endpointEnvioPedidoLectura = Util.valoresIntegracionNavision.get('Endpoint_Test_General');
				}
				else
				{
					endpointEnvioPedidoLectura = Util.valoresIntegracionNavision.get('Enpoint_Pro_Envio_Pedido_Lectura');
				}
            }
            return endpointEnvioPedidoLectura;
        }
        set;
    }

	//Propiedad para recuperar el endpoint correcto a endpointGetPedidosl en función de si estamos en Sandbox o no
    //@rcastanos (06/06/2019)
    public static String endpointGetPedidosl
    {
        get
        {
            if(endpointGetPedidosl == null)
            {
                if(Util.runningInASandbox)
				{
					endpointGetPedidosl = Util.valoresIntegracionNavision.get('Endpoint_Test_General');
				}
				else
				{
					endpointGetPedidosl = Util.valoresIntegracionNavision.get('Enpoint_Pro_Get_Pedidosl');
				}
            }
            return endpointGetPedidosl;
        }
        set;
    }

	//Propiedad para recuperar el endpoint correcto a endpointGetLecturas en función de si estamos en Sandbox o no
    //@rcastanos (06/06/2019)
    public static String endpointGetLecturas
    {
        get
        {
            if(endpointGetLecturas == null)
            {
                if(Util.runningInASandbox)
				{
					endpointGetLecturas = Util.valoresIntegracionNavision.get('Endpoint_Test_General');
				}
				else
				{
					endpointGetLecturas = Util.valoresIntegracionNavision.get('Enpoint_Pro_Get_Lecturas');
				}
            }
            return endpointGetLecturas;
        }
        set;
    }
	
	@future(callout=true)
	public static void SincronizarClientesFuture(list<String> clientesSyncIDs)
	{
		LogUtil.crearLog('SincronizarClientesFuture. Clientes: '+clientesSyncIDs, 'SincronizarClientesFuture', '', 'Sync', false);
		SyncNav.SincronizarClientes(clientesSyncIDs, true);
		LogUtil.guardarLog();
	}
	
	// Método para enviar a Navision los clientes actualizados para sincronizarlos
	// @change rcastanos (06/06/2019) Modificación del código para adecuarse a la eliminación de cuentas personales
	public static void SincronizarClientes(list<String> clientesSyncIDs, boolean persistirModificacionesCuentas)
	{
		System.Debug('## before SincronizarCliente');
		System.Debug('clientesSyncIDs: ' + clientesSyncIDs);
		try    
		{
			// Lo primero que se hará será asignar un valor a la variable semáforo del trigger para evitar que se
			// traten de sincronizar de nuevo los registros que se editen en este método.
			AccountUtil.semaforoUpdate = false;
			DireccionEnvioUtil.semaforoUpdate = false;

			List<Account> clientesSync 								= new List<Account>([Select Calle_2__c, Recibir_factura_por_mail__c, OwnerId, Email2__c, E_mail__c, Id_Fiscal__c, Provincia__c, 
																								Cod_periodo_no_pago__c, D_as_pago__c, Pais__c, Cod_forma_pago__c, Cod_terminos_pago__c, Email3__c, 
																								Calle_Facturacion__c, Poblacion_Facturacion__c, FirstName, LastName, City__c, Codigo_Postal__c, Phone, 
																								Mobile_Phone_No__c, Fax, Id_Navision__c, Id, Name, CreatedBy.Cod_Navision__c, IBAN__c
																								from Account where Id in :clientesSyncIDs]);

			List<Direcci_n_de_entrega__c> direccionesSync 			= new List<Direcci_n_de_entrega__c>([Select Id_Navision__c, Provincia__c, C_digo_tarifa__r.Id_Navision__c, Direccion__c, 
																								Direccion_2__c, Codigo_Postal__c, Poblacion__c, Pais__c, Actividad_1__c, Actividad_2__c, 
																								Id, Name, cuenta__c, Temperatura_fija__c
																								from Direcci_n_de_entrega__c where cuenta__c in :clientesSyncIDs]);

			List<Contract> contratosSync 							= new List<Contract>([Select AccountId, Id, Name, IBAN__c, SWI__c 
																								from Contract where AccountId in :clientesSyncIDs and Status = 'Activado']);

			Set<Id> gestores = new Set<Id>();
			for(Account acc : clientesSync)
			{
				gestores.add(acc.OwnerId);
			}

			Map<Id, String> gestoresConAlias = new Map<Id, String>();
			for(User usuario: [SELECT Id, Alias, Name, IsActive FROM User WHERE IsActive = true And Id  in:gestores])
            {
            	gestoresConAlias.put(usuario.Id, usuario.Alias);
            }

			for(Contract contrato : contratosSync)
			{
				mapaContratosDatosBancarios.put(contrato.AccountId,contrato);
			}
			
			SchemaCliente.entitySyncDto listaEntidades 	= new SchemaCliente.entitySyncDto();
			listaEntidades.etCustomer 					= new List<SchemaCliente.etCustomer>();
			
			SchemaCliente.etCustomer clienteNav;
			
			//Preparamos las direcciones de envio de los clientes
			Map<Id,List<SchemaCliente.etAddres>> mapaDireccionesCliente = new Map<Id,List<SchemaCliente.etAddres>>();
			
			for (Direcci_n_de_entrega__c direccion : direccionesSync)
			{ 
				List<SchemaCliente.etAddres> listaDireccionesCliente = null;
				
				if(mapaDireccionesCliente.get(direccion.cuenta__c) == null)
				{
					listaDireccionesCliente = new List<SchemaCliente.etAddres>();
				}
				else
				{
					listaDireccionesCliente = mapaDireccionesCliente.get(direccion.cuenta__c);
				}
				
				SchemaCliente.etAddres direccionNav = new SchemaCliente.etAddres();
				
				direccionNav.ADAddres 		= direccion.Direccion__c;
				direccionNav.ADAddres2 		= direccion.Direccion_2__c;
				direccionNav.ADPostCode 	= direccion.Codigo_Postal__c;
				direccionNav.ADCity 		= direccion.Poblacion__c;
				direccionNav.ADCountry 		= direccion.Pais__c;
				direccionNav.Activity1 		= direccion.Actividad_1__c;
				direccionNav.Activity2 		= direccion.Actividad_2__c;
				direccionNav.FixTemperature = Integer.valueOf(direccion.Temperatura_fija__c);
				direccionNav.ADCode 		= direccion.Id_Navision__c;
				direccionNav.ADSalesForceId = direccion.Id;

				if(String.isNotEmpty(direccion.Provincia__c))
				{
					direccionNav.ADCounty = direccion.Provincia__c;
				}
					
				if(!String.isEmpty(direccion.C_digo_tarifa__c) && !String.isEmpty(direccion.C_digo_tarifa__r.Id_Navision__c))
				{
					direccionNav.ADCodePriceDiscount = direccion.C_digo_tarifa__r.Id_Navision__c;
				}

				listaDireccionesCliente.add(direccionNav);
				
				mapaDireccionesCliente.put(direccion.cuenta__c,listaDireccionesCliente);
			}
			
			for (Account cliente : clientesSync)
			{   
				System.debug('Cliente SF a pasar a Cliente Nav: ' + cliente);
				clienteNav 							= new SchemaCliente.etCustomer();
							
				clienteNav.CustomerNo 				= cliente.Id_Navision__c;
	   			clienteNav.Addres 					= cliente.Calle_Facturacion__c;
		        clienteNav.Addres2 					= cliente.Calle_2__c;
		        clienteNav.eMailInvoice 			= cliente.Recibir_factura_por_mail__c;
		        clienteNav.City 					= cliente.Poblacion_Facturacion__c;
		        clienteNav.PostCode 				= cliente.Codigo_Postal__c;
		        clienteNav.County 					= cliente.Provincia__c;
		        clienteNav.Country 					= cliente.Pais__c;
		        clienteNav.Phone 					= cliente.Phone;
		        clienteNav.Mobile 					= cliente.Mobile_Phone_No__c;
		        clienteNav.Fax 						= cliente.Fax;
		        clienteNav.VatRegistration 			= cliente.Id_Fiscal__c;

				//gserrano 28/01/2019 se dejan de sincronizar estos campos a petición de Sandra
		        /*clienteNav.PaymentTerms 			= cliente.Cod_terminos_pago__c;
		        clienteNav.PaymentMethod 			= cliente.Cod_forma_pago__c;
		        clienteNav.PaymentTermsStdOrd 		= cliente.Cod_terminos_pago__c;
		        clienteNav.PaymentTermsFuelOrd 		= cliente.Cod_terminos_pago__c;
		        clienteNav.PaymentTermsCrdCardOrd 	= cliente.Cod_terminos_pago__c;*/

		        clienteNav.Surname_SF 				= cliente.Name;
				
				//pmartin 01/04/2020 se añade el campo IBAN__c
				clienteNav.IBAN					= cliente.IBAN__c;
				
		        List<String> listaEmails = new List<String>();
		        	
		        if(!String.IsEmpty(cliente.E_mail__c))
		        	listaEmails.add(cliente.E_mail__c);
		        	
		        if(!String.IsEmpty(cliente.Email2__c))
		        	listaEmails.add(cliente.Email2__c);
		        	
		        if(!String.IsEmpty(cliente.Email3__c))
		        	listaEmails.add(cliente.Email3__c);
		        	
		       	String emailsConcatenados = '';
		        for(Integer cont = 0; cont < listaEmails.size(); cont++)
		        {
		        	emailsConcatenados = emailsConcatenados + listaEmails.get(cont);
		        	
		        	if(cont >= 0 && cont < listaEmails.size()-1)
		        	{
		        		emailsConcatenados = emailsConcatenados + ';';
		        	}
		        }
		        
		        if(!String.IsEmpty(emailsConcatenados))
		        	clienteNav.email = emailsConcatenados;
		        
		        
				//gserrano 28/01/2019 se dejan de sincronizar estos campos a petición de Sandra
		        /*if(cliente.D_as_pago__c!=null)
		        	clienteNav.PaymentDays = cliente.D_as_pago__c;
		        	
		        clienteNav.NoPaymentDays = cliente.Cod_periodo_no_pago__c;*/

		        if(gestoresConAlias.containsKey(cliente.OwnerId))
		        {
		        	clienteNav.Comercial = gestoresConAlias.get(cliente.OwnerId);
		        }


		        
		        clienteNav.DOM_PROF = 'PROF';
		        

		        clienteNav.SalesForceId = cliente.Id;
		        
		        
		        if(mapaDireccionesCliente.get(cliente.Id)!=null && mapaDireccionesCliente.get(cliente.Id).size()>0)
		        {
		        	clienteNav.etAddres = mapaDireccionesCliente.get(cliente.Id);
		        }
		                  
				listaEntidades.etCustomer.add(clienteNav);
			}
						  
			respuestaPeticion = NavWSUtil.peticionWSSincronizarClientes(listaEntidades);  
			
			//Actualizamos las cuentas en SF solo en el caso en el que el Id de Nav no es vacio
			if(persistirModificacionesCuentas == true)
			{
				if(respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas != null)
				{ 
					if(respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.keySet().size() > 0)
					{
						List<Account> listaClientesActualizarSF = new List<Account>();
						//Lista de clientes a actualizar en SF (Da igual que se hayan insertado o que se hayan editado)
						Account clienteSF;
						for ( Id idSF : respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.keySet() )
						{
						    System.debug('Id SF: ' + idSF + ' - Id Nav:' + respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.get(idSF));
						    clienteSF = new Account();
						    clienteSF.Id = idSF;
							clienteSF.Id_Navision__c = respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.get(idSF);
							clienteSF.Fecha_ltima_Sync__c = System.now();
							
							listaClientesActualizarSF.add(clienteSF);
						}
						
						// Se actualizan los clientes con la nueva fecha de última sincronización
						update listaClientesActualizarSF;
					}
				}
				else
				{
					System.debug('No se ha encontrado el Id de Navisio y/o Id de SF en la respuesta del servidor');
				}
				
				//Actualizamos las direcciones de entrega en SF
				if(respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega!=null)
				{
					if(respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.keySet().size() > 0)
					{
						List<Direcci_n_de_entrega__c> listaDireccionesEntregaActualizarSF = new List<Direcci_n_de_entrega__c>();
						//Lista de direcciones de entrega a actualizar en SF (Da igual que se hayan insertado o que se hayan editado)
						Direcci_n_de_entrega__c direccionEntregaSF;
						for ( ID idSF : respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.keySet() )
						{
						    System.debug('Id SF: ' + idSF + ' - Id Nav:' + respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.get(idSF));
						    direccionEntregaSF = new Direcci_n_de_entrega__c();
						    direccionEntregaSF.Id = idSF;
							direccionEntregaSF.Id_Navision__c = respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.get(idSF);
							direccionEntregaSF.Fecha_ultima_Sync__c = System.now();
							listaDireccionesEntregaActualizarSF.add(direccionEntregaSF);
						}
						
						// Se actualizan las direcciones de entrega con la nueva fecha de última sincronización
						update listaDireccionesEntregaActualizarSF;
					}
				}

			}
		} 
		catch (Exception e)
		{
			LogUtil.crearLog('Error -' + e.getMessage(), 'SincronizarClientes', 'Cliente', 'Error', true);
			LogUtil.guardarLog();
		}
		System.Debug('## after SincronizarCliente');
	}
	
	@future(callout=true)
	public static void SincronizarClientesyContratos(List<String> contratosSyncIDs, List<String> clientesSyncIDs)
	{
		LogUtil.crearLog('SincronizarClientesyContratos. Clientes: '+clientesSyncIDs+' Contratos: '+contratosSyncIDs, 'SincronizarClientesyContratos', '', 'Sync', false);
		SyncNav.SincronizarClientes(clientesSyncIDs,false); 
		SyncNav.SincronizarContratos(contratosSyncIDs);
		LogUtil.guardarLog();
	}

	// Método para enviar a Navision los contratos actualizados para sincronizarlos
	// @change rcastanos (06/06/2019) Modificación para recuperar los tipos de registro mediante la nueva propiedad
	public static void SincronizarContratos(List<String> contratosSyncIDs)
	{
		System.Debug('## before SincronizarContratos');
		// Lo primero que se hará será asignar un valor a la variable semáforo del trigger para evitar que se
		// traten de sincronizar de nuevo los registros que se editen en este método.
		ContractUtil.semaforoUpdate = false;
		try
		{
			List<Contract> contratosSync = new List<Contract>([Select Canalizado_promotor__c, Carburante__c, Toma_agua_15_m__c, Importe_dep_sito__c, Importe_instalaci_n_exterior__c,
			 Importe_instalaci_n_interior__c, Importe_obra_Civil__c, Importe_equipos__c, Importe_proyectos__c, Producto_contratado__c, Direccion_de_entrega__c, /*Subcontratista__c*/Instalador__c, Promotor__c, 
			 Tarifa__c, RecordTypeId, AccountId, Id_Navision__c, Duracion_contrato_en_toneladas__c, Duraci_n_del_contrato_a_os__c, Consumo_previsto_tons__c, Cod_terminos_pago_servicios__c, 
			 Cod_dia_de_pago__c, Cod_forma_pago_servicios__c, Cod_terminos_de_pago__c, Cod_forma_de_pago__c, Reminder_terms_code__c, Fecha_prevista_1er_llenado__c, Fecha_prevista_obra_civil__c, 
			 Capacidad_tanque__c, Tipo_de_tanque__c, dp_cad_min1__c, dp_cad_min2__c, dp_cad_min3__c, dp_cad_min4__c, dp_cad_min5__c, dp_cad_min6__c, dto_1__c, dto_2__c, dto_3__c, dto_4__c, dto_5__c, 
			 dto_6__c, TP_tipo_instalacion__c, dto_Kg_1__c, dto_Kg_2__c, dto_Kg_3__c, dto_Kg_4__c, dto_Kg_5__c, dto_Kg_6__c, Servicios__c, dcm_propano1__c, dcm_propano2__c, dcm_propano3__c, 
			 dcm_propano4__c, Importe_servicios__c, dto_a_o_1__c, dto_a_o_2__c, dto_a_o_3__c, dto_a_o_4__c, Importe_gesti_n_contrato__c, Importe_alquiler_contador__c, Importe_SAU__c, 
			 Importe_derechos_de_alta__c, Importe_derechos_acometida__c, Importe_t_rmino_fijo__c, Perfil_de_consumo__c, Segmento_1__c, Segmento_2__c, Primaconta__c, Telemedida__c, Entrega_de_producto__c, Id, IBAN__c, SWI__c,
			 Modalidad_de_instalaci_n__c, Ultima_lectura_de_contador__c, OldCustomerNavCode__c, OldShiptoCode__c, Fraccionar_pago_1er_llenado_en_3__c, Importe_forfait__c, Importe_prima__c
			 from Contract where Id in :contratosSyncIDs]);
			System.debug(contratosSync);
			//Sacamos el tipo de camión de la dirección de entrega del contrato
			Map<Id,Id> mapaDireccionesIdsContratosIds = new Map<Id,Id>();
			for(Contract c: contratosSync)
			{
				mapaDireccionesIdsContratosIds.put(c.Direccion_de_entrega__c, c.Id);				
			}
			System.debug(mapaDireccionesIdsContratosIds);
			List<Direcci_n_de_entrega__c> direccionesContrato = new List<Direcci_n_de_entrega__c>([Select Id, Tipo_de_camion__c from Direcci_n_de_entrega__c where Id in :mapaDireccionesIdsContratosIds.keySet()]);
			System.debug(direccionesContrato);
			Map<Id,String> mapaContratosIdsTipoCamion = new Map<Id,String>();
			for(Id direccionId: mapaDireccionesIdsContratosIds.keySet())
			{
				for(Direcci_n_de_entrega__c direccion: direccionesContrato)
				{
					if(direccion.Id == direccionId)
					{
						mapaContratosIdsTipoCamion.put(mapaDireccionesIdsContratosIds.get(direccionId),direccion.Tipo_de_camion__c);
					}
				}
			}
				System.debug(mapaContratosIdsTipoCamion);

			SchemaContrato.entitySyncDto listaEntidades = new SchemaContrato.entitySyncDto();
			listaEntidades.etContract = new List<SchemaContrato.etContract>();
			SchemaContrato.etContract contratoNav;
			
			//Sacamos la relación entre Id de contrato e Id de Navision de la cuenta relacionada
			Map<String,String> mapaIdCuentaIdContrato = new Map<String,String>();
			for(Contract c : contratosSync)
			{
				mapaIdCuentaIdContrato.put(c.AccountId,c.Id);
			}
			System.debug(mapaIdCuentaIdContrato);

			Map<String,String> mapaIdContratoIdCuentaNavision = new Map<String,String>();
			
			if(mapaIdCuentaIdContrato.keySet().size() > 0)
			{
				System.debug('389 '+mapaIdCuentaIdContrato);
				for(String idSfCuenta : mapaIdCuentaIdContrato.keySet())
				{
					/*Cambios rfernandez (11/05/2018) Se ha añadido una validacion para saber si el registro existe en el mapa, si no lanzamos un error*/
					if(respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.containsKey(idSfCuenta))
					{
						mapaIdContratoIdCuentaNavision.put(mapaIdCuentaIdContrato.get(idSfCuenta),respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.get(idSfCuenta));
										System.debug('395 '+mapaIdContratoIdCuentaNavision);

					}else
					{
                   		throw new Util.customException('El id de Salesforce de la cuenta ' + idSfCuenta + ' no existe en el mapa: '+respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas); 
					}
				}
			}
			
			//Sacamos la relación entre Id de contrato y tipo de contrato
			Map<String,String> mapaIdRecordTypeIdContrato = new Map<String,String>();
			for(Contract c : contratosSync)
			{
				mapaIdRecordTypeIdContrato.put(c.RecordTypeId,c.Id);
			}
			System.debug('408 '+mapaIdRecordTypeIdContrato);

			Map<String,String> mapaIdContratoNombreTipoContrato = new Map<String,String>();
			
			if(mapaIdRecordTypeIdContrato.keySet().size() > 0)
			{
				List<RecordType> listaRecordType = [Select Name,Id from RecordType where Id in :mapaIdRecordTypeIdContrato.keySet()];
				for(RecordType r : listaRecordType)
				{
					mapaIdContratoNombreTipoContrato.put(mapaIdRecordTypeIdContrato.get(r.Id),r.Name);
				}
			}
												System.debug(mapaIdContratoNombreTipoContrato);

			//Sacamos la relación entre Id de contrato e Id de Navision de la tarifa relacionada
			Map<String,String> mapaIdTarifaIdContrato = new Map<String,String>();
			for(Contract c : contratosSync)
			{
				mapaIdTarifaIdContrato.put(c.Tarifa__c,c.Id);
			}
			
			Map<String,String> mapaIdContratoIdNavisionTarifa = new Map<String,String>();
			
			if(mapaIdTarifaIdContrato.keySet().size() > 0)
			{
				List<Pricebook2> listaTarifas = [Select Id_Navision__c,Id from Pricebook2 where Id in :mapaIdTarifaIdContrato.keySet()];
				for(Pricebook2 t : listaTarifas)
				{
					mapaIdContratoIdNavisionTarifa.put(mapaIdTarifaIdContrato.get(t.Id),t.Id_Navision__c);
				}
			}
			
			Map<String,String> mapaIdInstaladorIdContrato = new Map<String,String>();
			for(Contract c : contratosSync)
			{
				mapaIdInstaladorIdContrato.put(c.Instalador__c,c.Id);
			}
			
			Map<String,String> mapaIdContratoIdNavisionInstalador = new Map<String,String>();
			
			if(mapaIdInstaladorIdContrato.keySet().size() > 0)
			{
				List<Account> listaInstaladores = [Select Id, Codigo_proveedor__c from Account where Id in: mapaIdInstaladorIdContrato.keySet() 
													and RecordTypeId =: Util.objectsRecordTypesMap.get('Account').get('Partner').Id];
				for(Account i : listaInstaladores)
				{
					//El código del instalador va con una R
					if(!String.IsEmpty(i.Codigo_proveedor__c))
						mapaIdContratoIdNavisionInstalador.put(mapaIdInstaladorIdContrato.get(i.Id), 'R' + i.Codigo_proveedor__c);
				}
			}
			
			//Sacamos la relación entre Id de contrato e Id de Navision del promotor
			Map<String,String> mapaIdPromotorIdContrato = new Map<String,String>();
			for(Contract c : contratosSync)
			{
				mapaIdPromotorIdContrato.put(c.Promotor__c,c.Id);
			}
			
			Map<String,String> mapaIdContratoIdNavisionPromotor = new Map<String,String>();
			
			if(mapaIdPromotorIdContrato.keySet().size() > 0)
			{
				List<Account> listaCuentas = [Select Id_Navision__c,Id from Account where Id in:mapaIdPromotorIdContrato.keySet()];
				for(Account a : listaCuentas)
				{
					mapaIdContratoIdNavisionPromotor.put(mapaIdPromotorIdContrato.get(a.Id),a.Id_Navision__c);
				}
			}
			
			//Sacamos la relación entre Id de contrato y nombre de producto
			Map<String,String> mapaIdProductoIdContrato = new Map<String,String>();
			for(Contract c : contratosSync)
			{
				mapaIdProductoIdContrato.put(c.Producto_contratado__c,c.Id);
			}
			
			Map<String,String> mapaIdContratoNombreProducto = new Map<String,String>();
			
			if(mapaIdProductoIdContrato.keySet().size() > 0)
			{
				List<Product2> listaProductos = [Select Id, Name from Product2 where Id in:mapaIdProductoIdContrato.keySet()];
				for(Product2 p : listaProductos)
				{
					mapaIdContratoNombreProducto.put(mapaIdProductoIdContrato.get(p.Id),p.Name);
				}
			}
			
			//Sacamos la relación entre Id de contrato y direccion de entrega
			Map<String,String> mapaIdDireccionEntregaIdContrato = new Map<String,String>();
			for(Contract c : contratosSync)
			{
				mapaIdDireccionEntregaIdContrato.put(c.Direccion_de_entrega__c,c.Id);
			}
			
			Map<String,String> mapaIdContratoDireccionEntregaIdNavision = new Map<String,String>();
			
			if(mapaIdDireccionEntregaIdContrato.keySet().size() > 0)
			{
				for(String idSfDirEntrega : mapaIdDireccionEntregaIdContrato.keySet())
				{
					mapaIdContratoDireccionEntregaIdNavision.put(mapaIdDireccionEntregaIdContrato.get(idSfDirEntrega),respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.get(idSfDirEntrega));
				}
			}
			
			//Sacamos la relación entre Id de contrato y Id de Navision de CanalizadoPromotor
			Map<String,String> mapaIdCanalizadoPromotorIdContrato = new Map<String,String>();
			for(Contract c : contratosSync)
			{
				mapaIdCanalizadoPromotorIdContrato.put(c.Canalizado_promotor__c,c.Id);
			}
			
			Map<String,String> mapaIdContratoIdNavCanalizadoPromotor = new Map<String,String>();
			
			if(mapaIdProductoIdContrato.keySet().size() > 0)
			{
				List<Canalizado_promotor__c> listaCanalizadosPromotor = [Select Id, Id_Navision__c from Canalizado_promotor__c where Id in:mapaIdCanalizadoPromotorIdContrato.keySet()];
				for(Canalizado_promotor__c cp : listaCanalizadosPromotor)
				{
					mapaIdContratoIdNavCanalizadoPromotor.put(mapaIdCanalizadoPromotorIdContrato.get(cp.Id),cp.Id_Navision__c);
				}
			}
			
			for (Contract contrato:contratosSync)
			{   
				System.debug('Contrato SF a pasar a Contrato Nav: ' + contrato);
				contratoNav = new SchemaContrato.etContract();
				contratoNav.CustomerNavCode = mapaIdContratoIdCuentaNavision.get(contrato.Id);
				//Cambios rfernandez (14/07/2017)
				//Comprobamos si es un cambio de titular, en cuyo caso no hay que enviar el id de la direccion de entrega
				if(contrato.OldCustomerNavCode__c != null && contrato.OldShiptoCode__c != null)
				{
					contratoNav.ShiptoCode = '';
				}else{
					contratoNav.ShiptoCode = mapaIdContratoDireccionEntregaIdNavision.get(contrato.Id);
				}
				//Fin cambios rfernandez
				contratoNav.ContractType = mapaIdContratoNombreTipoContrato.get(contrato.Id);
				contratoNav.ContractDurationTons = contrato.Duracion_contrato_en_toneladas__c;
				
				if(contrato.Duraci_n_del_contrato_a_os__c != null)
				{
					contratoNav.ContractDurationYears = Integer.valueOf(contrato.Duraci_n_del_contrato_a_os__c);
				}
				
				contratoNav.PlannedConsumptionTons 		= contrato.Consumo_previsto_tons__c;
				contratoNav.CodePaymentDay 				= contrato.Cod_dia_de_pago__c;
				contratoNav.PaymentTermsServices 		= contrato.Cod_terminos_pago_servicios__c;
				contratoNav.PaymentMetodServices 		= contrato.Cod_forma_pago_servicios__c;
				contratoNav.PaymentTermsFuel 			= contrato.Cod_terminos_de_pago__c;
				contratoNav.PaymentMethodFuel 			= contrato.Cod_forma_de_pago__c;
				contratoNav.ReminderTermsCode 			= contrato.Reminder_terms_code__c;
				contratoNav.DateFirstFill 				= contrato.Fecha_prevista_1er_llenado__c;
				contratoNav.DateCivilWork 				= contrato.Fecha_prevista_obra_civil__c;
				contratoNav.Subcontractor 				= mapaIdContratoIdNavisionInstalador.get(contrato.Id);
				contratoNav.CapacityTank 				= contrato.Capacidad_tanque__c;
				contratoNav.Carburante 					= contrato.Carburante__c;
				contratoNav.TankType 					= contrato.Tipo_de_tanque__c;
				contratoNav.AmountDepo 					= contrato.Importe_dep_sito__c;
				contratoNav.AmountINEX 					= contrato.Importe_instalaci_n_exterior__c;
				contratoNav.AmountININ 					= contrato.Importe_instalaci_n_interior__c;
				contratoNav.AmountOC 					= contrato.Importe_obra_Civil__c;
				contratoNav.AmountEquipment 			= contrato.Importe_equipos__c;
				contratoNav.AmountProyect 				= contrato.Importe_proyectos__c;
				contratoNav.dpcadmin1 					= contrato.dp_cad_min1__c;
				contratoNav.dpcadmin2 					= contrato.dp_cad_min2__c;
				contratoNav.dpcadmin3 					= contrato.dp_cad_min3__c;
				contratoNav.dpcadmin4 					= contrato.dp_cad_min4__c;
				contratoNav.dpcadmin5 					= contrato.dp_cad_min5__c;
				contratoNav.dpcadmin6 					= contrato.dp_cad_min6__c;
				contratoNav.Tariff 						= mapaIdContratoIdNavisionTarifa.get(contrato.Id); 
				contratoNav.Dto1 						= contrato.dto_1__c;
				contratoNav.Dto2 						= contrato.dto_2__c;  
				contratoNav.Dto3 						= contrato.dto_3__c;
				contratoNav.Dto4 						= contrato.dto_4__c;
				contratoNav.Dto5 						= contrato.dto_5__c;
				contratoNav.Dto6 						= contrato.dto_6__c;
				contratoNav.TPinstallationType 			= contrato.TP_tipo_instalacion__c;
				contratoNav.Dto1kg 						= contrato.dto_Kg_1__c;
				contratoNav.Dto2kg 						= contrato.dto_Kg_2__c;
				contratoNav.Dto3kg 						= contrato.dto_Kg_3__c;
				contratoNav.Dto4kg 						= contrato.dto_Kg_4__c;
				contratoNav.Dto5kg 						= contrato.dto_Kg_5__c;
				contratoNav.Dto6kg 						= contrato.dto_Kg_6__c;
				contratoNav.Services 					= contrato.Servicios__c;
				contratoNav.dcmpropano1 				= contrato.dcm_propano1__c;
				contratoNav.dcmpropano2 				= contrato.dcm_propano2__c;
				contratoNav.dcmpropano3 				= contrato.dcm_propano3__c;
				contratoNav.dcmpropano4 				= contrato.dcm_propano4__c;
				contratoNav.AmountServices 				= contrato.Importe_servicios__c;
				contratoNav.Dto1Year 					= contrato.dto_a_o_1__c;
				contratoNav.Dto2Year 					= contrato.dto_a_o_2__c;
				contratoNav.Dto3Year 					= contrato.dto_a_o_3__c;
				contratoNav.Dto4Year 					= contrato.dto_a_o_4__c;
				contratoNav.AmountContractManagement 	= contrato.Importe_gesti_n_contrato__c;
				contratoNav.GasMeterRentAmount 			= contrato.Importe_alquiler_contador__c;
				contratoNav.AmountSAU 					= contrato.Importe_SAU__c;
				contratoNav.ImporteDerechosAlta 		= contrato.Importe_derechos_de_alta__c;
				contratoNav.ImporteDerechosAcometida 	= contrato.Importe_derechos_acometida__c;
				contratoNav.AmountFixTerm 				= contrato.Importe_t_rmino_fijo__c;
				contratoNav.AmountForfait 				= contrato.Importe_forfait__c;
				contratoNav.AmountPrima					= contrato.Importe_prima__c;				
				contratoNav.WaterAvailable 				= contrato.Toma_agua_15_m__c;
				contratoNav.Promotor 					= mapaIdContratoIdNavisionPromotor.get(contrato.Id);
				contratoNav.ConsumptionProfile 			= contrato.Perfil_de_consumo__c;
				contratoNav.ContractedProduct 			= mapaIdContratoNombreProducto.get(contrato.Id);
				contratoNav.Segment1 					= contrato.Segmento_1__c;
				contratoNav.Segment2 					= contrato.Segmento_2__c;
				contratoNav.Primaconta 					= contrato.Primaconta__c;
				contratoNav.Telemedida 					= contrato.Telemedida__c;
				contratoNav.CanalizadoPromotor 			= mapaIdContratoIdNavCanalizadoPromotor.get(contrato.Id);
				contratoNav.TruckType					= mapaContratosIdsTipoCamion.get(contrato.Id);
				contratoNav.DeliveryItem 				= contrato.Entrega_de_producto__c;
				contratoNav.IDSalesForce 				= contrato.Id;
				contratoNav.BankIBAN 					= contrato.IBAN__c; 
				contratoNav.BankSWIFT 					= contrato.SWI__c;
				contratoNav.ModalidadInstalacion 		= contrato.Modalidad_de_instalaci_n__c;
				contratoNav.OldCustomerNavCode 			= contrato.OldCustomerNavCode__c;
				contratoNav.OldShiptoCode 				= contrato.OldShiptoCode__c;
				contratoNav.SplitFirstPaymentIn3        = contrato.Fraccionar_pago_1er_llenado_en_3__c;


				if( (mapaIdContratoNombreTipoContrato.get(contrato.Id) == 'Póliza') || (mapaIdContratoNombreTipoContrato.get(contrato.Id) == 'GNL' && contrato.Primaconta__c == true) )
				{
					contratoNav.LastMeterReading = Integer.valueOf(contrato.Ultima_lectura_de_contador__c); //Recupero decimal pero en el schema es Integer
				}
				listaEntidades.etContract.add(contratoNav);
			}
			
			Set<String> idsSfContrato = NavWSUtil.peticionWSSincronizarContratos(listaEntidades);  
			
			if(idsSfContrato!=null)
			{  
				//Si no recibimos correctamente los Ids de SF de los contratos no se persiste nada en SF
				if(idsSfContrato.size() > 0)
				{
					List<Contract> listaContratosActualizarSF = new List<Contract>();
					//Lista de contratos a actualizar en SF (Da igual que se hayan insertado o que se hayan editado)
					Contract contratoSF;
					for (ID idSF : idsSfContrato)
					{
						system.debug('Id SF: ' + idSF );
					    contratoSF = new Contract();
					    contratoSF.Id = idSF;
						contratoSF.Fecha_ltima_Sync__c = System.now();
						listaContratosActualizarSF.add(contratoSF);
					} 
					
					// Se actualizan los contratos con la nueva fecha de última sincronización
					update listaContratosActualizarSF;
					
					//Se actualizan las cuentas con la información de la respuesta
					if(respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas!=null)
					{ 
						if(respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.keySet().size() > 0)
						{
							List<Account> listaClientesActualizarSF = new List<Account>();
							//Lista de clientes a actualizar en SF (Da igual que se hayan insertado o que se hayan editado)
							Account clienteSF;
							for ( ID idSF : respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.keySet() )
							{
							    system.debug('Id SF: ' + idSF + ' - Id Nav:' + respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.get(idSF));
							    clienteSF = new Account();
							    clienteSF.Id = idSF;
								clienteSF.Id_Navision__c = respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.get(idSF);
								clienteSF.Fecha_ltima_Sync__c = System.now();
								
								listaClientesActualizarSF.add(clienteSF);
							}
							
							// Se actualizan los clientes con la nueva fecha de última sincronización
							update listaClientesActualizarSF;
						}
					}
					else
					{
						System.debug('No se ha encontrado el Id de Navision y/o Id de SF del cliente en la respuesta del servidor');
					}
					
					//Se actualizan las direcciones de entrega con la información de la respuesta
					if(respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega!=null)
					{
						if(respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.keySet().size() > 0)
						{
							List<Direcci_n_de_entrega__c> listaDireccionesEntregaActualizarSF = new List<Direcci_n_de_entrega__c>();
							//Lista de direcciones de entrega a actualizar en SF (Da igual que se hayan insertado o que se hayan editado)
							Direcci_n_de_entrega__c direccionEntregaSF;
							for ( ID idSF : respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.keySet() )
							{
							    system.debug('Id SF: ' + idSF + ' - Id Nav:' + respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.get(idSF));
							    direccionEntregaSF = new Direcci_n_de_entrega__c();
							    direccionEntregaSF.Id = idSF;
								direccionEntregaSF.Id_Navision__c = respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.get(idSF);
								direccionEntregaSF.Fecha_ultima_Sync__c = System.now();
								listaDireccionesEntregaActualizarSF.add(direccionEntregaSF);
							}
							
							// Se actualizan las direcciones de entrega con la nueva fecha de última sincronización
							update listaDireccionesEntregaActualizarSF;
						}
					}
					else
					{
						System.debug('No se ha encontrado el Id de Navision y/o Id de SF de la dirección de entrega en la respuesta del servidor');
					}
				}
			}
			else								
			{
				System.debug('No se ha encontrado el Id de Navision y/o Id de SF del contrato en la respuesta del servidor');
			}
		}
		catch (Exception e)
		{
			LogUtil.crearLog('Error -' + e.getLineNumber() + ' ' + e.getMessage(), 'SincronizarContratos', 'Contrato', 'Sync', true);
			LogUtil.guardarLog();
		}
		System.Debug('## after SincronizarContratos');
	}

	//Metodo encargado de sincronizar los pedidos de gas que se creen en SF
	@future(callout=true)
	public static void SincronizarPedidosDeGasFuture(list<String> pedidosGasSyncIDs)
	{
		SyncNav.SincronizarPedidosDeGas(pedidosGasSyncIDs);
	}
	
	//Metodo encargado de sincronizar los pedidos de gas que se creen en SF
	public static void SincronizarPedidosDeGas(list<String> pedidosGasSyncIDs)
	{
		List<Pedido_de_gas__c> pedidosGasSync = new List<Pedido_de_gas__c>([SELECT Id, Direccion_de_entrega__r.Id_navision__c, Direccion_de_entrega__r.cuenta__r.Id_navision__c, Fecha__c,
																				 Nivel_del_deposito__c, Status__c, Comentarios__c 
																			FROM Pedido_de_gas__c  WHERE Id IN :pedidosGasSyncIDs]);

		System.debug('pedidosGasSync: ' + pedidosGasSync);
		Pedido_de_gas__c pedidoGas = pedidosGasSync[0];
		if(pedidoGas != null)
		{
			System.debug('@@@@ pedidoGas:' + pedidoGas);
			String body = XmlUtil.generarXmlEnviarPedidosGas(pedidoGas);
			System.debug('@@@@@ cuerpo ' + body);
			HttpResponse res = NavWSUtil.peticionesWSNavision(endpointEnvioPedidoLectura, 'Url_crear_pedidos_gas', body); 
			System.debug('@@@@ res ' + res);
			System.debug('@@@@@ endpointEnvioPedidoLectura ' + endpointEnvioPedidoLectura);
			System.debug('@@@@@ url crear pedido gas ' +  Util.valoresIntegracionNavision.get('Url_crear_pedidos_gas'));

			if(res.getStatusCode() != 401)//Puede dar si el usuario utilizado para la peticion esta bloqueado
			{
				if(!XmlUtil.parsearRespuestaEnviarPedidosGas(res))
				{
					System.debug('Ha habido algun error creando pedidos');
					LogUtil.crearLog('Ha habido un error al crear el pedido de gas en la cuenta '+pedidosGasSync[0].Direccion_de_entrega__r.cuenta__r.Id_navision__c+' para la direccion de entrega con id Nav: '+pedidosGasSync[0].Direccion_de_entrega__r.Id_navision__c+' Registro: '+pedidoGas, 'SincronizarPedidosDeGas', 'SincronizarPedidosDeGas', 'Error', true);
				}
			}else{
				LogUtil.crearLog('Error de autenticación', 'SincronizarPedidosDeGas', 'SincronizarPedidosDeGas', 'Error', true);
			}
			
			delete pedidosGasSync;
		}else{
			LogUtil.crearLog('No se ha encontrado ningun pedido de gas: '+pedidosGasSyncIDs, 'SincronizarPedidosDeGas', 'SincronizarPedidosDeGas', 'Error', true);
		}
		LogUtil.guardarLog();
	}


    /*
    ===========================================================================================================================================================================
    * -- SINCRONIZACION DE LECTURAS CONTADOR  ---------------------------------------------------------------------------------------------------------------------------------
    ===========================================================================================================================================================================
    */

	//Metodo encargado de sincronizar las lecturas de contador que se creen en SF
	@future(callout=true)
	public static void SincronizarLecturasContadorFuture(list<String> lecturasContadorSyncIDs)
	{
		SyncNav.SincronizarLecturasContador(lecturasContadorSyncIDs);
	}
	
	//Metodo encargado de sincronizar las lecturas de contador que se creen en SF
	public static void SincronizarLecturasContador(list<String> lecturasContadorSyncIDs)
	{
		List<Lectura_contador__c> lecturasContadorSync = new List<Lectura_contador__c>([SELECT Id, Direccion_de_entrega__r.Id_navision__c, Direccion_de_entrega__r.cuenta__r.Id_navision__c, 
																						 Lectura__c
																			FROM Lectura_contador__c  WHERE Id IN :lecturasContadorSyncIDs]);

		Lectura_contador__c lecturaContador = lecturasContadorSync[0];
		String body = XmlUtil.generarXmlEnviarLecturasContador(lecturaContador);
		HttpResponse res = NavWSUtil.peticionesWSNavision(endpointEnvioPedidoLectura, 'Url_crear_lecturas_contador', body); 
		//System.debug(res);
		if(lecturaContador != null)
		{
			if(res.getStatusCode() != 401)//Puede dar si el usuario utilizado para la peticion esta bloqueado
			{
				if(!XmlUtil.parsearRespuestaEnviarLecturasContador(res))
				{
					System.debug('Ha habido algun error creando lecturas');
					LogUtil.crearLog('Ha habido un error al crear la lectura en la cuenta '+lecturasContadorSync[0].Direccion_de_entrega__r.cuenta__r.Id_navision__c+' para la direccion de entrega con id Nav: '+lecturasContadorSync[0].Direccion_de_entrega__r.Id_navision__c +' Registro: '+lecturaContador, 'SincronizarLecturasContador', 'SincronizarLecturasContador', 'Error', true);
				}
			}else{
				LogUtil.crearLog('Error de autenticación', 'SincronizarLecturasContador', 'SincronizarLecturasContador', 'Error', true);
			}
			delete lecturasContadorSync;
		}else{
			LogUtil.crearLog('No se ha encontrado ninguna lectura de contador: '+lecturasContadorSyncIDs, 'SincronizarLecturasContador', 'SincronizarLecturasContador', 'Error', true);
		}
		LogUtil.guardarLog();	
	}

  	/*
    ===========================================================================================================================================================================
    * -- CONSULTA DE LECTURAS CONTADOR Y PEDIDOS DE GAS -----------------------------------------------------------------------------------------------------------------------
    ===========================================================================================================================================================================
    */
	public static List<Pedido_de_gas__c> ConsultarPedidosDeGas(String idNavCliente)
	{
		String body = XmlUtil.generarXmlConsultarPedidosGas(idNavCliente);
		HttpResponse res = NavWSUtil.peticionesWSNavision(endpointGetPedidosl, 'Url_consultar_pedidos_gas', body); 
		System.debug(res);

		//Parsear respuesta para enviarla al controllador		
		List<Pedido_de_gas__c> pedidosDeGas = new List<Pedido_de_gas__c>();

		if(res.getStatusCode() != 401)//Puede dar si el usuario utilizado para la peticion esta bloqueado
		{
			pedidosDeGas = XmlUtil.parsearRespuestaConsultarPedidosGas(res);
		}else{
			pedidosDeGas = null;
		} 

		return pedidosDeGas;
	}

	public static List<Lectura_contador__c> ConsultarLecturasContador(String idNavCliente)
	{
		String body = XmlUtil.generarXmlConsultarLecturasContador(idNavCliente);
		HttpResponse res = NavWSUtil.peticionesWSNavision(endpointGetLecturas, 'Url_consultar_lecturas_contador', body); 

		//Parsear respuesta para enviarla al controllador	
		List<Lectura_contador__c> lecturasContador = new List<Lectura_contador__c>();

		if(res.getStatusCode() != 401)//Puede dar si el usuario utilizado para la peticion esta bloqueado
		{
			lecturasContador = XmlUtil.parsearRespuestaConsultarLecturasContador(res);
		}else{
			lecturasContador = null;
		}

		return 	lecturasContador;
	}

}