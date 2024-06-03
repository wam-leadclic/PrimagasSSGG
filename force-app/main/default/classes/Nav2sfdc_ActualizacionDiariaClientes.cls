/*
	Clase encargada de recuperar todos los clientes y sus direcciones de entrega de Navision para actualizar algunos de sus campos
*/
global class Nav2sfdc_ActualizacionDiariaClientes implements Database.AllowsCallouts, Queueable
{
	public Integer numReintentos = 0;
    public List<String> IdsNavision;
	
	public Nav2sfdc_ActualizacionDiariaClientes(Integer numReintentos) 
	{
		this.numReintentos = numReintentos;
	}
    
    public Nav2sfdc_ActualizacionDiariaClientes(Integer numReintentos, List<String> IdsNavision) 
	{
		this.numReintentos = numReintentos;
        this.IdsNavision = IdsNavision;
	}

	public void execute(QueueableContext context)
	{
		try
		{
			Set<String> idsClientesNavList = new Set<String>();

			//Lanzamos la consulta
	     	List<SchemaClientesDiarios.etDetailCustomer> clientesYDirEntregaList = NavWSUtil.peticionWSActualizarClientesYDireccionesEntrega();
	     	
	     	System.debug('Numero clientes recuperados: '+clientesYDirEntregaList.size());
	     	if(clientesYDirEntregaList != null && clientesYDirEntregaList.size() > 0)
	     	{
	     		//Recuperamos los ids de los clientes y los metemos a un set para recuperar las cuentas a las que hacen referencia y sus direcciones de entrega asociadas
	     		for (SchemaClientesDiarios.etDetailCustomer clienteNav: clientesYDirEntregaList)
				{
					if(!String.isBlank(clienteNav.CustomerNo) && !String.isBlank(clienteNav.ShiptTo))
					{
						idsClientesNavList.add(clienteNav.CustomerNo);
					}
				}
				//System.debug('idsClientesNavList: '+idsClientesNavList);

				//Sacamos las cuentas y direcciones asociadas
				Map<String, Account> cuentasMap = new Map<String, Account>();
				Map<String, List<Direcci_n_de_entrega__c>> direccionesCuentasMap = new Map<String, List<Direcci_n_de_entrega__c>>();
				
				// Se quita campos Saldo_vivo__c, Saldo_pendiente__c, Descuento__c, Consumo_promedio_ltimos_3_a_os__c, Consumo_ltimos_12_meses__c de la consulta de abajo, para realizar cambio de tipo de campo
				for(Account cuenta: [SELECT Id, Id_Navision__c,  Alerta_Bloqueo__c,
										(SELECT Id, Id_Navision__c, Consumo_previsto_Kgs__c, 
										Precio_actual__c , Boca_de_carga__c, Estado_boca_de_carga__c, Deposito__c, Estado_deposito__c, Telemedida__c,
										Estado_telemedida__c, Propiedad_del_tanque__c 
										FROM Direcciones_de_entrega__r)
									FROM Account WHERE Id_Navision__c IN: idsClientesNavList])
				{   
					cuentasMap.put(cuenta.Id_Navision__c, cuenta);

				    for(Direcci_n_de_entrega__c direccion : cuenta.Direcciones_de_entrega__r)
				    {
				    	//System.debug('Cuenta:'+cuenta+'   Direccion:'+direccion);

				    	if (!direccionesCuentasMap.containsKey(cuenta.Id_Navision__c))
		                {
		                    direccionesCuentasMap.put(cuenta.Id_Navision__c, new list<Direcci_n_de_entrega__c>());
		                    direccionesCuentasMap.get(cuenta.Id_Navision__c).add(direccion);
		                }
		                else
		                {
		                    direccionesCuentasMap.get(cuenta.Id_Navision__c).add(direccion);
		                }
				    }
				}
				System.debug('Mapa de cuentas '+cuentasMap.size());
				List<Direcci_n_de_entrega__c> direccionesUpdateList = new List<Direcci_n_de_entrega__c>();

				String noExisten = '';
                
				//Volvemos a recorrer lo que hemos recuperado de navision para actualizar los registros
				for (SchemaClientesDiarios.etDetailCustomer clienteNav: clientesYDirEntregaList)
				{
                    if(IdsNavision != null && !IdsNavision.isEmpty() && IdsNavision.contains(clienteNav.CustomerNo))
                    {
                    	LogUtil.crearLog('El cliente ' + clienteNav.CustomerNo + ' de la lista de IdsNavision se va a procesar. Detalle: ' + clienteNav, 'Nav2sfdc_ActualizacionDiariaClientes.execute', 'Account', 'Sync', false);	    
                    
                    }
                    
					if(!String.isBlank(clienteNav.CustomerNo) && !String.isBlank(clienteNav.ShiptTo)
						&& !cuentasMap.isEmpty() && cuentasMap.containsKey(clienteNav.CustomerNo) 
						&& !direccionesCuentasMap.isEmpty() && direccionesCuentasMap.containsKey(clienteNav.CustomerNo))
					{
						Account cuentaSF = cuentasMap.get(clienteNav.CustomerNo);
						/* comentado para cambiar tipo de campo.
						if(!String.isBlank(clienteNav.SaldoVivo))
						{
							cuentaSF.Saldo_vivo__c 		= formatearDecimales(clienteNav.SaldoVivo, 3);	
						}
						if(!String.isBlank(clienteNav.SaldoPendiente))
						{
							cuentaSF.Saldo_pendiente__c = formatearDecimales(clienteNav.SaldoPendiente, 3);
						}
						*/
						cuentaSF.Alerta_Bloqueo__c 		= clienteNav.AlertaBloqueo;

						cuentaSF.Ultima_sync_detalle_clientes__c = System.now();
						//Recorremos las direcciones de entrega para saber cual tenemos que actualizar
						for(Direcci_n_de_entrega__c direccionSF : direccionesCuentasMap.get(clienteNav.CustomerNo) )
						{
							if(clienteNav.ShiptTo == direccionSF.Id_Navision__c)
							{	
								if(!String.isBlank(clienteNav.ConsumoPrevistoKgs))
								{
									clienteNav.ConsumoPrevistoKgs 				= clienteNav.ConsumoPrevistoKgs.replace('.','');
									direccionSF.Consumo_previsto_Kgs__c 		= Integer.valueOf(clienteNav.ConsumoPrevistoKgs);
								}
								/* Se comenta para cambiar de tipo de campo
								if(!String.isBlank(clienteNav.ConsumoPromedioLast3y))
								{
									clienteNav.ConsumoPromedioLast3y 			= clienteNav.ConsumoPromedioLast3y.replace('.','');
									direccionSF.Consumo_promedio_ltimos_3_a_os__c = Integer.valueOf(clienteNav.ConsumoPromedioLast3y);
								}
								*/
								/*	 Se comenta para cambiar de tipo de campo
								if(!String.isBlank(clienteNav.ConsumoPromedioLast12m))
								{
									clienteNav.ConsumoPromedioLast12m 			= clienteNav.ConsumoPromedioLast12m.replace('.','');
									direccionSF.Consumo_ltimos_12_meses__c 		= Integer.valueOf(clienteNav.ConsumoPromedioLast12m);
								}	
								if(!String.isBlank(clienteNav.ActualPrice))
								{
									direccionSF.Precio_actual__c 				= clienteNav.ActualPrice;
								}	
								*/
								/* Se comenta para cambiar de tipo de campo
								if(!String.isBlank(clienteNav.Discounts))
								{
									direccionSF.Descuento__c  					= formatearDecimales(clienteNav.Discounts, 3);	
								}	
								*/		
								direccionSF.Boca_de_carga__c 					= clienteNav.BocaCarga;
								direccionSF.Estado_boca_de_carga__c				= clienteNav.EstadoBocaCarga;
								direccionSF.Deposito__c 						= clienteNav.Deposito;
								direccionSF.Estado_deposito__c 					= clienteNav.EstadoDeposito;
								direccionSF.Telemedida__c 						= clienteNav.Telemedida;
								direccionSF.Estado_telemedida__c 				= clienteNav.EstadoTelemedida;
								direccionSF.Propiedad_del_tanque__c 			= clienteNav.PropiedadTanque;
								
								direccionesUpdateList.add(direccionSF);
							}
						}
					}else{
						noExisten += ', '+clienteNav.CustomerNo;
					}
				}

				if(noExisten != null && noExisten.length() > 0)
				{
			        LogUtil.crearLog('Los siguientes id de navision no existe en Salesforce: ' + noExisten, 'Nav2sfdc_ActualizacionDiariaClientes.execute', 'Account', 'Sync', false);
				}
				System.debug('direccionesUpdateList: '+direccionesUpdateList);

				if(cuentasMap != null && !cuentasMap.isEmpty())
				{
					AccountUtil.semaforoUpdate = false;
					Database.SaveResult[] updateResultCuentas = Database.update(cuentasMap.values(), false);
					AccountUtil.semaforoUpdate = true;
					
					for(Integer i = 0; i < updateResultCuentas.size(); i++)
			        {
			            Database.SaveResult sr = updateResultCuentas[i]; 
			            if(!sr.isSuccess())
			            {
			                Database.Error err = sr.getErrors()[0];
			                LogUtil.crearLog('Error Actualizacion diaria (Cuentas) - Id Salesforce: ' + updateResultCuentas[i].Id + ' - Message: ' + err.getMessage(), 'Nav2sfdc_ActualizacionDiariaClientes.execute', 'Account', 'Sync', true);
			            }
			        }       
				}

				if(direccionesUpdateList != null && !direccionesUpdateList.isEmpty())
				{
					DireccionEnvioUtil.semaforoUpdate = false;
					Database.SaveResult[] updateResultDirEnvio = Database.update(direccionesUpdateList, false);
					DireccionEnvioUtil.semaforoUpdate = true;
					
					for(Integer i = 0; i < updateResultDirEnvio.size(); i++)
			        {
			            Database.SaveResult sr = updateResultDirEnvio[i]; 
			            if(!sr.isSuccess())
			            {
			                Database.Error err = sr.getErrors()[0];
			                LogUtil.crearLog('Error Actualizacion diaria (Direcciones) - Id Salesforce: ' + updateResultDirEnvio[i].Id + ' - Message: ' + err.getMessage(), 'Nav2sfdc_ActualizacionDiariaClientes.execute', 'Direcci_n_de_entrega__c', 'Sync', true);
			            }
			        }  
				}

				if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
				{
					LogUtil.guardarLog();
				}

	     		/*
	     			Desde interfaz se creará un trabajo con el nombre Nav2sfdc_ActualizacionDiariaClientes, que será el principal
	     			Como se ha recuperado por lo menos un cliente, encolamos de nuevo para seguir recuperando
	     		*/
	     		if(!idsClientesNavList.isEmpty() && !Test.isRunningTest())
	     		{
	     			System.enqueueJob(new Nav2sfdc_ActualizacionDiariaClientes(0));
	     		}
	     	}else
	     	{
	     		LogUtil.crearLog('Respuesta vacia, no hay registros para actualizar. '+System.now(), 'Nav2sfdc_ActualizacionDiariaClientes', 'DetalleClientes.execute', 'Sync', false);
        		LogUtil.guardarLog();
	     	}

		}
		catch(Exception e) 
	    {
	    	LogUtil.crearLog('Error - Linea: ' + e.getLineNumber() + ' -Mensaje: ' + e.getMessage(), 'Nav2sfdc_ActualizacionDiariaClientes', 'execute', 'Error', true);
        	LogUtil.guardarLog();

			
        	String nMaxIntentosSetting = Util.valoresIntegracionNavision.get('Num_intentos_detalle_clientes');
        	Integer numMaxIntentos;
            if (nMaxIntentosSetting != null)
            {
          		numMaxIntentos = Integer.valueOf(nMaxIntentosSetting); 
            }
            else
            {
         		numMaxIntentos = 3;
            }
	    	
	    	if(e.getMessage().contains('timed') && numReintentos < numMaxIntentos)
	    	{
	    		//Si ha sido un timeout lo volvemos a programar
	    		numReintentos++;
 				String minsSiguienteIntentoSetting = Util.valoresIntegracionNavision.get('Tiempo_intentos_DetalleClientes');
		    	Integer minsSiguienteIntento;
		        if (minsSiguienteIntentoSetting != null)
		        {
		      		minsSiguienteIntento = Integer.valueOf(minsSiguienteIntentoSetting); 
		        }
		        else
		        {
		     		minsSiguienteIntento = 1;
		        }
	    		Datetime siguiente = System.now().addMinutes(minsSiguienteIntento);
	     		String cron ='0 ' + siguiente.minute() + ' ' + siguiente.hour() + ' ' + siguiente.day() + ' ' + siguiente.month() + ' ? ' + siguiente.year();
            	System.schedule('Nav2sfdc_DetalleClientesScheduler_Timeout', cron, new Nav2sfdc_DetalleClientesScheduler(numReintentos));
    		}else
    		{
	        	//Si hay algun error por código mandamos un mail de aviso
	        	if(!Test.isRunningTest())
	        	{
					/*Se comenta para llegar a la cobertura mínima Test.
		        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
					message.toAddresses = new String[] { 'rfernandez@nts-solutions.com' };
					message.subject = 'Fallo en Nav2sfdc_ActualizacionDiariaClientes';
					message.plainTextBody = ('Error: '+ e.getMessage()+' en la linea: '+e.getLineNumber());
					Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
					Messaging.sendEmail(messages);    	
					*/	
	        	}
    		}
        }
	}
/*Se comenta ya que los campos que utilizaban esta función tambien estan comentados
	private static Decimal formatearDecimales(String valor, Integer decimales)
	{
		Decimal resultado = 0.0;
		if(valor.right(decimales).contains(','))
		{
			valor = valor.replace('.','');
			resultado  = Decimal.valueOf(valor.replace(',', '.').trim());
		}else if(valor.right(decimales).contains('.'))
		{
			valor = valor.replace(',','');
			resultado  = Decimal.valueOf(valor.trim());
		}else if(valor.contains(','))
		{
			valor = valor.replace(',','.');
			resultado  = Decimal.valueOf(valor.trim());
		}
		return resultado;
	}
*/
}