global class Nav2sfdc_Facturas implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		/*try
		{
			Set<String> idsClientesNavList = new Set<String>();

			//Lanzamos la consulta
			List<> facturasNavList = NavWSUtil.peticionWSConsultarFacturas();
	     	
	     	System.debug('Facturas Recibidas: '+facturasNavList);

	     	if(facturasNavList != null && facturasNavList.size() > 0)
	     	{
	     		//Recuperamos los ids de los clientes y los metemos a un set para recuperar las cuentas a las que hacen referencia
	     		for (Schema  facturaNav: facturasNavList)
				{
					if(!String.isBlank(clienteNav.CustomerNo) && !String.isBlank(clienteNav.ShiptTo))
					{
						idsClientesNavList.add(clienteNav.CustomerNo);
					}
				}

				//Sacamos las cuentas en un mapa por Id de Navision
				Map<String, Account> cuentasMap = new Map<String, Account>();

				for(Account cuenta: [SELECT Id, Id_Navision__c FROM Account WHERE Id_Navision__c IN: idsClientesNavList])
				{   
					cuentasMap.put(cuenta.Id_Navision__c, cuenta);
				}
				System.debug('Mapa de cuentas '+cuentasMap.size());
				
				Set<Factura__c> facturasList = new Set<Factura__c>();
				Set<String> idsFacturasPendientesConfirmar = new Set<String>();
				//Volvemos a recorrer lo que hemos recuperado de navision para insertar o actualizar los registros
				for (Schema facturaNav: facturasNavList)
				{
					if(!String.isBlank(facturaNav.CustomerNo) && !cuentasMap.isEmpty() && cuentasMap.containsKey(facturaNav.CustomerNo))
					{
						Account cuentaSF = cuentasMap.get(facturaNav.CustomerNo);
						Factura__c facturaSF = new Factura__c();

						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Cod_forma_pago__c 	= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Estado_documento__c 	= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Fecha_registro__c 	= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Fecha_vencimiento__c 	= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Importe__c 			= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Importe_inicial__c 	= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Importe_pendiente__c 	= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Id_Navision__c 		= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Numero_documento__c 	= facturaNav.;	
						}
						if(!String.isBlank(facturaNav.))
						{
							facturaSF.Tipo_documento__c 	= facturaNav.;	
						}
						facturasList.add(facturaSF);
					}
				}

				if(facturasList != null && !facturasList.isEmpty())
				{
					Database.UpsertResult[] upsertResult = Database.upsert(facturasList, ,false);
										
					for(Integer i = 0; i < upsertResult.size(); i++)
			        {
			            Database.UpsertResult sr = upsertResult[i]; 
			            if(!sr.isSuccess())
			            {
			                Database.Error err = sr.getErrors()[0];
			                LogUtil.crearLog('', '', 'Factura__c', 'Sync', true);
			            } else
			            {
			            	LogUtil.crearLog('Id Salesforce: ' + facturasList[i].Id + ' Is success: ' + sr.isSuccess() + ', Is Created: ' + sr.isCreated() + ', Is Updated: ' + !sr.isCreated(), '', '', 'Sync', false);

			            	idsFacturasPendientesConfirmar.add(facturasList[i].Id_Navision__c);
			            }
			        }       
				}

	     	}else
	     	{
	     		LogUtil.crearLog('Respuesta vacia, no hay registros para actualizar. '+System.now(), 'Nav2sfdc_Facturas', '', 'Sync', false);
	     	}
		}catch(Exception e)
		{
				
		}
		finally
		{
			LogUtil.guardarLog();
        	confirmarFacturas();
        }*/
	}

    //Indicamos las facturas que faltan por confirmar, posteriormente se lanza el batch encargado de hacer la petición de la confirmación
    /*public static void actualizarConfirmacionFacturas(Set<String> idsFacturas)
    {
    	List<Factura__c> facturasList = [SELECT Pendiente_de_confirmar__c FROM Factura__c WHERE Id_Navision__c IN: idsFacturas];
    	for(Factura__c factura : facturasList)
    	{
    		factura.Pendiente_de_confirmar__c = true;
    	}
    	update facturasList;
    }

	public static void confirmarFacturas()
	{
		Database.executeBatch(new Nav2sfdc_Facturas_Confirmacion(null), 200);
	}*/
}