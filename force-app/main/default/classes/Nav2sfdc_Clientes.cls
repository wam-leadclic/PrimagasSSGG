/** 
* Clase Nav2sfdc_Clientes
**
* @Funcionalidad: Clase Schedulable encargada de solicitar a Navision información acerca de nuevos clientes
* @Autor: Aritz Uriarte de Alayo (28/07/2015)
**
**/
global class Nav2sfdc_Clientes implements Schedulable 
{	
	global void execute(SchedulableContext SC) 
    {
    	cargarClientesNavEnSf();
    }    
    
	//@change rcastanos (06/06/2019) Modificaciones relativas a la limpieza de código y la eliminación de las cuentas personales
   	@future(callout=true)
    public static void cargarClientesNavEnSf()
    {   
    	//Lo sacamos fuera del try para meterlos en los de errores  
    	List<SchemaCliente.etCustomer> listaClientes;
    	List<Direcci_n_de_entrega__c> direccionesEntregaUpsert;
    	try
	    {
	    	//Devuelve una lista de clientes parseados del XML
	     	listaClientes = NavWSUtil.peticionWSConsultarClientes();
	     	System.debug('Listado de clientes: '+listaClientes);
	    	//Actualización/inserción de clientes y direcciones de entrega
			direccionesEntregaUpsert = new List<Direcci_n_de_entrega__c>();
	    	List<Account> clientesUpsert = new List<Account>();
	    	
			Account clienteSf;
			
			Map<String,Pricebook2> mapaListasPrecio = insertarTarifasNuevasDeNavision(listaClientes);
			
			List<ClienteDireccionesEntregaNav> clientesNavisio = new List<ClienteDireccionesEntregaNav>();
			
			RecordType clienteExistenteRecordType_empresa = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');	
			RecordType clientePotencialRecordType_empresa = Util.objectsRecordTypesMap.get('Account').get('Cliente');		
			Map<String,String> mapaclientesYaCreadosIdTipoClienteTodos = new Map<String,String>();
			Set<String> idsClientesUpsertCorrecto = new Set<String>();
			Map<Id,String> mapaClientesIdNombre = new Map<Id,String>();

			Map<Id,String> mapaClientesIdNombreSF = new Map<Id,String>();
			Map<Id,String> mapaClientesIdApellidoSF = new Map<Id,String>(); //Para empresas tambien se va a utilizar este

			String clienteNavName;
			Set<String> idsDireccionesComprobarExistentesSf = new Set<String>();

			//Cambios rfernandez (31/01/2017)
			Map<String, Id> gestoresConAlias = new Map<String, Id>();
			for(User usuario: [SELECT Id, Alias, Name FROM User WHERE IsActive = true])
            {
            	gestoresConAlias.put(usuario.Alias , usuario.Id);
            }
			//Fin cambios rfernandez (31/01/2017)
			
			//Para duplicados
			Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.AllowSave = true;
			dml.optAllOrNone = false;
			
			
			for (SchemaCliente.etCustomer clienteNav:listaClientes)
			{ 
				clienteSf = new Account();

				clienteSf.setOptions(dml);
									
				clienteSf.Id_Navision__c = clienteNav.CustomerNo ;
	
				clienteNavName = clienteNav.Name;
			    
				if(!String.IsEmpty(clienteNav.Name2))
				{
					clienteNavName = clienteNavName + clienteNav.Name2;
				}
					
			    clienteSf.Calle_Facturacion__c 			= clienteNav.Addres;
			    clienteSf.Calle_2__c 					= clienteNav.Addres2;
		        clienteSf.Recibir_factura_por_mail__c 	= clienteNav.eMailInvoice;
				clienteSf.Poblacion_Facturacion__c 		= clienteNav.City;			
			    clienteSf.Codigo_Postal__c 				= clienteNav.PostCode;
			    clienteSf.Provincia__c 					= clienteNav.County;
			    clienteSf.Pais__c 						= clienteNav.Country;
			    clienteSf.Phone 						= clienteNav.Phone;
			    clienteSf.Mobile_Phone_No__c 			= clienteNav.Mobile;
			    clienteSf.Fax 							= clienteNav.Fax;
			    
			    //Desde Nav nos pasan 1, 2 o 3 mails seguidos de ;
			    if(!String.IsEmpty(clienteNav.email) && clienteNav.email.contains(';'))
			    { 
			       	clienteSf.E_mail__c = clienteNav.email.subString(0,clienteNav.email.indexOf(';'));
			       	String email2y3 	= clienteNav.email.subString(clienteNav.email.indexOf(';')+1,clienteNav.email.length());
			       	if(email2y3.contains(';'))
			       	{
			       		clienteSf.Email2__c = email2y3.subString(0,email2y3.indexOf(';'));
			       		clienteSf.Email3__c = email2y3.subString(email2y3.indexOf(';')+1,email2y3.length()).replace(';',''); 
			       	}
			       	else
			       	{
			       		clienteSf.Email2__c = email2y3;
			       	}
			    }
			    else
			    {
			    	clienteSf.E_mail__c = clienteNav.email;
			    }
			    
			    clienteSf.Id_Fiscal__c 			= clienteNav.VatRegistration;

				//gserrano 28/01/2019 se dejan de sincronizar estos campos a petición de Sandra
				
			    /*clienteSf.Cod_terminos_pago__c 	= clienteNav.PaymentTerms;
			    clienteSf.Cod_forma_pago__c 	= clienteNav.PaymentMethod;
			    clienteSf.Fecha_ltima_Sync__c 	= System.now();
			    
			    if(!String.IsEmpty(clienteNav.PaymentDays))
			    {
			    	clienteSf.D_as_pago__c = clienteNav.PaymentDays;
			    }
			    else
			    	clienteSf.D_as_pago__c = null;
			    	
			    clienteSf.Cod_periodo_no_pago__c = clienteNav.NoPaymentDays;*/
			    
				//Cambios rfernandez (31/01/2017)
				//Se obtiene el Comercial si es que lo tiene y con ese Alias se busca en el mapa para obtener el id del usuario propietario
				if(!String.IsEmpty(clienteNav.Comercial))
				{
					if(gestoresConAlias.containsKey(clienteNav.Comercial))
					{
						clienteSf.OwnerId = gestoresConAlias.get(clienteNav.Comercial);
					}	
				}
				//Fin cambios rfernandez (31/01/2017)
			    
				//Si se trata de una actualización se inserta el Id, si no se le pone el tipo Cliente Existente (Los que vienen de Nav son clientes existentes)
				if(!String.IsEmpty(clienteNav.SalesForceId))
				{
					clienteSf.Id = clienteNav.SalesForceId;
					mapaclientesYaCreadosIdTipoClienteTodos.put(clienteNav.SalesForceId, clienteNav.DOM_PROF);
					mapaClientesIdNombre.put(clienteNav.SalesForceId, clienteNavName);
					System.debug('Es actualizacion '+mapaclientesYaCreadosIdTipoClienteTodos);

					//Cambios rfernandez (27/04/2017)
					//@change rcastanos (06/06/2019) Solo se tiene en cuenta != DOM
					mapaClientesIdApellidoSF.put(clienteNav.SalesForceId, clienteNav.Surname_SF);
					

				}
				else
				{
					//Cambios rfernandez (28/04/2017)
					//@change rcastanos (06/06/2019) Se elimina la comprobación de cuentas personales

					clienteSf.RecordTypeId 	= clienteExistenteRecordType_empresa.Id;
					clienteSf.Name 			= clienteNav.Surname_SF;

				}
				System.debug('mapaClientesIdNombreSF '+mapaClientesIdNombreSF);
				System.debug('mapaClientesIdApellidoSF '+mapaClientesIdApellidoSF);
				List<Direcci_n_de_entrega__c> listaDireccionesEntrega = new List<Direcci_n_de_entrega__c>();
				//Actualización/inserción de direcciones de entrega
				if(clienteNav.etAddres!=null && clienteNav.etAddres.size() > 0)
				{
					for (SchemaCliente.etAddres dirNav:clienteNav.etAddres)
					{ 	
						Direcci_n_de_entrega__c dirEntregaSF = new Direcci_n_de_entrega__c();
						
						dirEntregaSF.Id_Navision__c 				= dirNav.ADCode;
						dirEntregaSF.Fecha_ultima_Sync__c 			= System.now();
						dirEntregaSF.Direccion__c 					= dirNav.ADAddres;
						dirEntregaSF.Direccion_2__c 				= dirNav.ADAddres2;
						dirEntregaSF.Codigo_Postal__c 				= dirNav.ADPostCode;
						dirEntregaSF.Poblacion__c 					= dirNav.ADCity;
						dirEntregaSF.Pais__c 						= dirNav.ADCountry;
						dirEntregaSF.Actividad_1__c 				= dirNav.Activity1;
						dirEntregaSF.Actividad_2__c 				= dirNav.Activity2;
						dirEntregaSF.Temperatura_fija__c 			= dirNav.FixTemperature;
						dirEntregaSF.Estado__c 						= dirNav.ADStatus;
						dirEntregaSF.Motivo_bloqueo__c 				= dirNav.ADBlockedReason;
						dirEntregaSF.Bloqueado__c 					= dirNav.ADBlocked;
						dirEntregaSF.Tipo_de_direccion_de_envio__c 	= dirNav.ADDAddressType;
						dirEntregaSF.Fecha_1er_llenado__c 			= dirNav.ADFirstFilledDate;
						
						if(String.isNotEmpty(dirNav.ADCounty))
						{
							dirEntregaSF.Provincia__c 		= dirNav.ADCounty;
						}

						if(!String.IsEmpty(dirNav.ADCodePriceDiscount))
						{
							if(mapaListasPrecio.get(dirNav.ADCodePriceDiscount) != null)
							{
								dirEntregaSF.C_digo_tarifa__c = mapaListasPrecio.get(dirNav.ADCodePriceDiscount).Id;
							}
							else
							{
								LogUtil.crearLog('Error, este error no debería darse. El Id Nav: ' + dirNav.ADCodePriceDiscount +  'de la tarifa (lista de precios) no está en SF', 'Nav2sfdc_Clientes.execute', 'Cliente - Direcci_n_de_entrega__c', 'Sync', true);
							}
						}

						if(!String.IsEmpty(clienteNav.SalesForceId))
						{
							dirEntregaSF.cuenta__c = clienteNav.SalesForceId;
						}
						
						//Con el Id de salesforce si lo tenemos actualizamos y si no hacemos insert
						if(!String.IsEmpty(dirNav.ADSalesForceId))
						{
							dirEntregaSF.Id = dirNav.ADSalesForceId;
							idsDireccionesComprobarExistentesSf.add(dirNav.ADSalesForceId);
						}
							
						listaDireccionesEntrega.add(dirEntregaSF);
					}
				}
				
				ClienteDireccionesEntregaNav clienteNavisio = new ClienteDireccionesEntregaNav();
				clienteNavisio.cliente = clienteSf;
				
				if(listaDireccionesEntrega.size() > 0)
				{
					clienteNavisio.direccionesEntrega = listaDireccionesEntrega;
				}
					
				clientesNavisio.add(clienteNavisio);
			}

			Set<String> idsCuentasPendientesConfirmar 		= new Set<String>();
			
			Set<String> idsDireccionesPendientesConfirmar 	= new Set<String>();			
			
			for(ClienteDireccionesEntregaNav clienteDireccionesEntrega : clientesNavisio)
			{
				clientesUpsert.add(clienteDireccionesEntrega.cliente);
			}
			System.debug('Clientes upsert '+clientesUpsert);
			//Actualizo el nombre de los clientes teniendo en cuenta si es cuenta personal o no
			Map<Id,Account> tipoRegistroClientes = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN: mapaClientesIdApellidoSF.keySet()]);
			String nombreCuenta;
			List<Account> clientesUpsertCopia = new List<Account>();
			clientesUpsertCopia.addAll(clientesUpsert);
			clientesUpsert.clear();
			Set<String> setClientesValidosIds = new Set<String>();
			for(Account clienteUpsert: clientesUpsertCopia)
			{			
				//Aquí estarán solo los que han venido con un id de salesforce informado. En clientesUpsertCopia deberían estar todos
				if(mapaClientesIdApellidoSF.containsKey(clienteUpsert.Id))
				{
					if(tipoRegistroClientes.containsKey(clienteUpsert.Id))
					{
						//Cambios rfernandez (28/04/2017)

						if(mapaClientesIdApellidoSF.containsKey(clienteUpsert.Id))
						{
							clienteUpsert.Name 		= mapaClientesIdApellidoSF.get(clienteUpsert.Id);
						}
						
						clientesUpsert.add(clienteUpsert);
						setClientesValidosIds.add(clienteUpsert.Id);
					}
					else
					{
						LogUtil.crearLog('Cliente con Id Salesforce no válido. Id Salesforce: ' + clienteUpsert.Id + ' - Id Navision: '+ clienteUpsert.Id_Navision__c, 'Nav2sfdc_Clientes.execute', 'Cliente', 'Sync', true);
					}						
				}
				else
				{
					clientesUpsert.add(clienteUpsert);
				}
			}	
			//Por cada cliente afectado por el servicio, se creará un registro de Log con el ID de salesforce, Id de NAV, si ha ocurrido algún error y la descripción del error.
			//Antes de realizar la modificación del cliente , se activará una variable global en AccountUtil encargada de evitar el reenvío de datos a NAV cuando no es necesario.
			// Aquí realizaremos el intento de inserción/actualización de los clientes en el sistema generando un Log por cada uno.
			if(clientesUpsert != null && clientesUpsert.size()>0)
			{  
				System.debug('Clientes a insertar/actualizar: ' + clientesUpsert);
				//Cambios rfernandez (20/04/2018) Esta dando algun error de Duplicate id in list por lo que vamos a generar un mapa. El id de navision debería ser unico
				Map<String, Account> clientesUpsertMap = new Map<String, Account>();
				
				Database.DMLOptions dmlopt = new Database.DMLOptions();
				dmlopt.DuplicateRuleHeader.AllowSave = true;
				dmlopt.optAllOrNone = false;

				for(Account cuentaUpsert : clientesUpsert)
				{
					if(!clientesUpsertMap.containsKey(cuentaUpsert.Id_Navision__c))
					{
						cuentaUpsert.setOptions(dmlopt);
						//En caso de que tenga id de Salesforce informado, lo limpiamos ya que ahora el upsert se hace por el id externo y no debería tener id de salesforce
						cuentaUpsert.Id = null;
						clientesUpsertMap.put(cuentaUpsert.Id_Navision__c, cuentaUpsert);
					}
				}
				System.debug('clientesUpsertMap.values() '+clientesUpsertMap.values());

				//Fin cambios rfernandez
				AccountUtil.semaforoUpdate 	= false;
				Database.UpsertResult[] res = Database.upsert(clientesUpsertMap.values(), Account.Fields.Id_Navision__c,false);				
		        AccountUtil.semaforoUpdate 	= true;
		        
				for(Integer i = 0; i < res.size(); i++)
		        {
		            Database.UpsertResult sr = res[i];
		            if(!sr.isSuccess())
		            {
		                Database.Error err = sr.getErrors()[0];
		                LogUtil.crearLog('Error - Id Navision: '+ clientesUpsert[i].Id_Navision__c +' Datos Cliente: '+clientesUpsert[i]+' - Message: '+ err.getMessage(), 'Nav2sfdc_Clientes.execute', 'Cliente', 'Sync', true);
		                System.debug('ERROR UPSERT '+err.getMessage() + 'cliente '+clientesUpsert[i]);
		            }
		            else
		            {
		            	LogUtil.crearLog('Id Salesforce: ' + clientesUpsert[i].Id + ' - Id Navision: '+ clientesUpsert[i].Id_Navision__c+ ' Is success: ' + sr.isSuccess() + ', Is Created: ' + sr.isCreated() + ', Is Updated: ' + !sr.isCreated(), 'Nav2sfdc_Clientes.execute', 'Cliente', 'Sync', false);
		            	//Almacenamos el Id de Navisio de las cuentas actualizadas para enviar la confirmación
		            	idsCuentasPendientesConfirmar.add(clientesUpsert[i].Id);
		            	idsClientesUpsertCorrecto.add(clientesUpsert[i].Id);
		            }
		        }
			}
			System.debug('idsClientesUpsertCorrecto '+idsClientesUpsertCorrecto);
			//Recorremos la lista de clientes para actualizar el Id de las direcciones de entrega de cuentas insertadas
			//Las  direcciones de entrega de cuentas actualizadas ya tienen el Id de salesforce
			//Si el id está relleno, se comprueba si existe en sf y en caso de no existir se deja el campo vacío
			//////
			Map<String,Direcci_n_de_entrega__c> direccionesExistentesSf = new Map<String,Direcci_n_de_entrega__c>([SELECT Id FROM Direcci_n_de_entrega__c WHERE Id IN: idsDireccionesComprobarExistentesSf]);
			//////En clientesNavisio está todo lo que se ha recibido. Cuentas con direcciones de entrega. Las cuentas se han tenido que insertar previamente por lo que deberían tener Id
			for(ClienteDireccionesEntregaNav clienteDirsEntregaNav : clientesNavisio)
			{
				//Si la cuenta tiene id de salesforce se asigna el lookup de las direcciones de entrega
				if(!String.IsEmpty(clienteDirsEntregaNav.cliente.Id))
				{
					if(clienteDirsEntregaNav.direccionesEntrega != null)
					{
						for(Direcci_n_de_entrega__c direccionEntrega : clienteDirsEntregaNav.direccionesEntrega)
						{

							if(direccionEntrega.Id!=null)
							{
								if( !direccionesExistentesSf.containsKey(direccionEntrega.Id) )
								{
									direccionEntrega.Id = null;
								}
							}

							if(setClientesValidosIds.contains(clienteDirsEntregaNav.cliente.Id) || String.IsEmpty(direccionEntrega.cuenta__c))
							{
								direccionEntrega.cuenta__c = clienteDirsEntregaNav.cliente.Id;
								direccionesEntregaUpsert.add(direccionEntrega);
							}
							else
							{
								LogUtil.crearLog('Cliente con Id Salesforce no válido dentro de Dirección de entrega. Id Salesforce: ' + clienteDirsEntregaNav.cliente.Id + ' - Id Navision: '+ clienteDirsEntregaNav.cliente.Id_Navision__c, 'Nav2sfdc_Clientes.execute', 'Direcci_n_de_entrega__c', 'Sync', true);
							}
						}
					}
				}
				else
				{
					LogUtil.crearLog('Error este mensaje no debería darse. La cuenta con Id de Navisio: ' + clienteDirsEntregaNav.cliente.Id_Navision__c + ' no tiene Id de SF', 'Nav2sfdc_Clientes.execute', 'Cliente - Direcci_n_de_entrega__c', 'Sync', true);
				}
			}
			
			Set<String> setIdsCuentasDireccionesEntregaFallidas = new Set<String>();
			
			//Insercion/Actualización de direcciones de entrega
			if(direccionesEntregaUpsert != null && direccionesEntregaUpsert.size()>0)
			{
				Set<Direcci_n_de_entrega__c> direccionesEntregaUpsertSet = new Set<Direcci_n_de_entrega__c>();
				direccionesEntregaUpsertSet.addAll(direccionesEntregaUpsert);
				direccionesEntregaUpsert.clear();
				direccionesEntregaUpsert.addAll(direccionesEntregaUpsertSet);

				DireccionEnvioUtil.semaforoUpdate 	= false;
				Database.UpsertResult[] res2 		= Database.upsert(direccionesEntregaUpsert, false);
				DireccionEnvioUtil.semaforoUpdate 	= true;
				
				for(Integer i = 0; i < res2.size(); i++)
		        {
		            Database.UpsertResult sr = res2[i]; 
		            if(!sr.isSuccess())
		            {
		                Database.Error err = sr.getErrors()[0];
		                LogUtil.crearLog('Error - Id Navision: '+ direccionesEntregaUpsert[i].Id_Navision__c + ' Id Salesforce: ' + direccionesEntregaUpsert[i].Id +' Datos Direccion: '+direccionesEntregaUpsert[i]+' - Message: ' + err.getMessage(), 'Nav2sfdc_Clientes.execute', 'Direcci_n_de_entrega__c', 'Sync', true);
		            	//Si falla el envío de la dirección de entrega quitamos la confirmación de la cuenta (respuesta Nav)
		            	setIdsCuentasDireccionesEntregaFallidas.add(direccionesEntregaUpsert[i].cuenta__c);
		            	if(idsCuentasPendientesConfirmar.contains(direccionesEntregaUpsert[i].cuenta__c))
		            	{
		            		idsCuentasPendientesConfirmar.remove(direccionesEntregaUpsert[i].cuenta__c);
		            	}
		            }
		            else
		            {
		            	LogUtil.crearLog('Id Salesforce: ' + direccionesEntregaUpsert[i].Id + ' Is success: ' + sr.isSuccess() + ', Is Created: ' + sr.isCreated() + ', Is Updated: ' + !sr.isCreated(), 'Nav2sfdc_Clientes.execute', 'Direcci_n_de_entrega__c', 'Sync', false);
		            	//Insertamos las cuentas de las direcciones de entrega correctas
		            	//Si ha fallado esta cuenta para otra dirección de entrega no se añade la confirmación para las siguientes direcciones de entrega
		            	if(!setIdsCuentasDireccionesEntregaFallidas.contains(direccionesEntregaUpsert[i].cuenta__c))
		            	{
		            		idsCuentasPendientesConfirmar.add(direccionesEntregaUpsert[i].cuenta__c);
		            	}
	            		//Almacenamos el Id de Navisio de las direcciones actualizadas para enviar la confirmación
		            	idsDireccionesPendientesConfirmar.add(direccionesEntregaUpsert[i].Id);
		            }
		        }        
			}

	        // Por último registramos los logs en el sistema
	        LogUtil.guardarLog();
	        System.debug('idsCuentasPendientesConfirmar: ' + idsCuentasPendientesConfirmar);
	        System.debug('idsDireccionesPendientesConfirmar: ' + idsDireccionesPendientesConfirmar);
	        
	        //Ponemos pendientes de confirmar las cuentas actualizadas en Salesforce
	        List<String> listaCuentasPendientesConfirmar = new List<String>();
			listaCuentasPendientesConfirmar.addAll(idsCuentasPendientesConfirmar);
			
			AccountUtil.semaforoUpdate = false;
	        actualizarConfirmacionCuentas(listaCuentasPendientesConfirmar);
	        AccountUtil.semaforoUpdate = true;
	        //NavWSUtil.peticionWSConfirmarClientes(mapaIdsCuentasIdNavisio);

	        //////
	        //Ponemos pendientes de confirmar las direcciones actualizadas en Salesforce
	        List<String> listaDireccionesPendientesConfirmar = new List<String>();
			listaDireccionesPendientesConfirmar.addAll(idsDireccionesPendientesConfirmar);
			
			DireccionEnvioUtil.semaforoUpdate = false;
	        actualizarConfirmacionDirecciones(listaDireccionesPendientesConfirmar);
	        DireccionEnvioUtil.semaforoUpdate = true;
	        //////
	    }  
	    catch(Exception e) 
	    {
	    	if(e.getMessage().contains('Duplicate id in list') && direccionesEntregaUpsert != null && !direccionesEntregaUpsert.isEmpty())
	    	{
	    		LogUtil.crearLog('Error duplicados' + e.getLineNumber() + ' - ' + e.getMessage()  + ' - Lista direcciones: ' +direccionesEntregaUpsert, 'Nav2sfdc_Clientes', 'cargarClientesNavEnSf', 'Error', true);
	    	}else
	    	{
        		LogUtil.crearLog('Error ' + e.getLineNumber() + ' - ' + e.getMessage(), 'Nav2sfdc_Clientes', 'cargarClientesNavEnSf', 'Error', true);
	    	}
        	LogUtil.guardarLog();
        }
        finally{
        	Nav2sfdc_Clientes.programarProximoBatch();

        }
        
        //Se programa la ejecución del batch dinámicamente, aunque falle la petición
        //programarProximoBatch();
    }
    
    public static void programarProximoBatch()
    {
    	try
    	{   	
	    	//Eliminamos las que ya no se van a ejecutar más
	        Map<String,String> mapaIdDetailsIdJob = new Map<String,String>();
	        
	        for(CronTrigger cronTr : [SELECT CronJobDetailId, id, CronExpression, TimesTriggered, NextFireTime, State FROM CronTrigger WHERE NextFireTime = null])
	        {
	            mapaIdDetailsIdJob.put(cronTr.CronJobDetailId,cronTr.Id);
	        }
	        
	        List<CronJobDetail> listaJobDetails = [select Name, Id from CronJobDetail where Id in: mapaIdDetailsIdJob.keySet()];
	        for(CronJobDetail jobDetail : listaJobDetails)
	        {
	        	if(jobDetail.Name.startsWith('Nav2sfdc_Clientes'))
	        	{
	        		try
	        		{
	        			System.abortJob(mapaIdDetailsIdJob.get(jobDetail.Id));
	        		}catch(Exception e) 
	    			{
						LogUtil.crearLog('No se ha parado el trabajo: ' + jobDetail.Id +  ' con nombre: '+jobDetail.Name, 'Nav2sfdc_Clientes.programarProximoBatch', 'Cliente', 'Error', true);
					}
	        	}
	        		
	        }
	        
	        
	        if(!Test.isRunningTest()) 
	        {
	            //Programamos la siguiente ejecución
	            Datetime now = System.now();
	            // Le sumamos un número determinado de minutos establecidos en un Metadata
	            String params = Util.valoresIntegracionNavision.get('Nav2sfdc_Clientes');
	            if (params != null)
	            {
	            	now = now.addMinutes(Integer.valueOf(params));	
	            	System.debug('Valor Custom Setting: Nav2sfdc_Clientes - ' + Integer.valueOf(params));
	            }
	            else
	            {
	            	now = now.addMinutes(60);
	            	System.debug('Valor Custom Setting: Nav2sfdc_Clientes - vacío');
	            }
	            String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
	            System.schedule('Nav2sfdc_Clientes_Confirmacion' + now.addHours(2), cron, new Nav2sfdc_Clientes_Confirmacion());
	        } 	
    	}catch(Exception e) 
	    {
        	LogUtil.crearLog('Error -' + e.getMessage(), 'Nav2sfdc_Clientes', 'programarProximoBatch', 'Sync', true);
        	LogUtil.guardarLog();

        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = new String[] { 'rfernandez@nts-solutions.com'};
			message.subject = 'Fallo en Clientes';
			message.plainTextBody = ('Error: '+ e.getMessage());
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			Datetime now = System.now();
			now = now.addMinutes(30);

			String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
            System.schedule('Nav2sfdc_Clientes_Confirmacion' + now.addHours(2), cron, new Nav2sfdc_Clientes_Confirmacion());
        }    
    }
    
    //Indicamos las cuentas que faltan por confirmar, posteriormente se lanza el batch encargado de hacer la petición de la confirmación
    public static void actualizarConfirmacionCuentas(List<String> idsCuentas)
    {
    	List<Account> listaCuentas = [select Pendiente_de_confirmar__c from Account where Id in :idsCuentas];
    	for(Account cuenta : listaCuentas)
    	{
    		cuenta.Pendiente_de_confirmar__c = true;
    	}
    	
    	update listaCuentas;
    }

    //Indicamos las direcciones que faltan por confirmar, posteriormente se lanza el batch encargado de hacer la petición de la confirmación
    public static void actualizarConfirmacionDirecciones(List<String> idsDirecciones)
    {
    	List<Direcci_n_de_entrega__c> listaDirecciones = [select Pendiente_de_confirmar__c from Direcci_n_de_entrega__c where Id in :idsDirecciones];
    	for(Direcci_n_de_entrega__c direccion : listaDirecciones)
    	{
    		direccion.Pendiente_de_confirmar__c = true;
    	}
    	
    	update listaDirecciones;
    } 

	//Clase utilizada para relacionar cada cliente con sus direcciones de entrega
	public class ClienteDireccionesEntregaNav {
		public List<Direcci_n_de_entrega__c> direccionesEntrega {get; set;}
    	public Account cliente {get; set;}
	}  
	
	//Este método se encarga de insertar las tarifas nuevas creadas en Navision.
	//Si no está la lista de precios con el código creado se crea nuevo, si no se le asigna el existente (Se busca por Id de Nav)
	//Devuelve un mapa con todas las tarifas para posteriormente asignarlas a sus direcciones de entrega correspondientes
	public static Map<String,Pricebook2>insertarTarifasNuevasDeNavision(List<SchemaCliente.etCustomer> listaClientes){
		System.debug(' before insertarTarifasNuevasDeNavision: ' + listaClientes);
		List<Pricebook2> listaPreciosACrear = new List<Pricebook2>();
		List<String> listaIdNavisionTarifas = new List<String>();
		Set<String> IdNavisiolistasDePreciosACrear = new Set<String>();
		Map<String,Pricebook2> mapaListaPrecios = new Map<String,Pricebook2>();
		
		for(SchemaCliente.etCustomer clienteNav : listaClientes)
		{
			List<SchemaCliente.etAddres> listaDirecciones = clienteNav.etAddres;
			if(listaDirecciones != null)
			{
				for (SchemaCliente.etAddres dirNav:listaDirecciones)
				{
					if(!String.IsEmpty(dirNav.ADCodePriceDiscount))
						listaIdNavisionTarifas.add(dirNav.ADCodePriceDiscount);
				}
			}
		}
		
		if(listaIdNavisionTarifas!=null && listaIdNavisionTarifas.size()>0)
		{
			//Se consultan las tarifas de SF con los Ids de Navision, si no existen se crean nuevas			
			List<Pricebook2> listaPrecios = [select Id, Id_Navision__c from Pricebook2 where Id_Navision__c in :listaIdNavisionTarifas];
			System.debug('listaPrecios: ' + listaPrecios);
						
			Set<String> setListaPreciosSalesforce = new Set<String>();
			for(Pricebook2 pb : listaPrecios)
			{
				setListaPreciosSalesforce.add(pb.Id_Navision__c);
			}
						
			for(String idNavTarifaNavision : listaIdNavisionTarifas)
			{
				//Si el Id de Navision no está en las tarifas de SF se guarda en la lista para crearlas en SF
				if(!setListaPreciosSalesforce.contains(idNavTarifaNavision))
					IdNavisiolistasDePreciosACrear.add(idNavTarifaNavision);
			}
						
			for(String idNavisio : IdNavisiolistasDePreciosACrear)
			{
				System.debug('Creando Pricebook2: ' + idNavisio);
				Pricebook2 pb = new Pricebook2();
				pb.Id_Navision__c = idNavisio;
				pb.Fecha_ltima_Sync__c = System.now();
				//En la consulta ya se actualizará el nombre correcto de la tarifa
				pb.Name = 'Pendiente de asignar';
				pb.Description = 'Pendiente de asignar';
				pb.IsActive = false;
				listaPreciosACrear.add(pb);
			}
			
			if(listaPreciosACrear != null && listaPreciosACrear.size()>0)	
				insert listaPreciosACrear;
				
			listaPrecios = [select Id, Id_Navision__c from Pricebook2 where Id_Navision__c in :listaIdNavisionTarifas];
			for(Pricebook2 pb : listaPrecios)
			{
				mapaListaPrecios.put(pb.Id_Navision__c,pb);
			}
		}
		
		return mapaListaPrecios;
	}
}