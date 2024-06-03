public class NavWSUtil 
{
	public static HttpResponse resPeticionConsultarClientes;

	//Metadata para endpoints y named credentials
	public static Map<String, Integracion_Navision__mdt> valoresIntegracion = Integracion_Navision__mdt.getAll();

	//Propiedad para recuperar el endpoint correcto a Navision en función de si estamos en Sandbox o no
    //@rcastanos (06/06/2019)
    public static String endpointNavision
    {
        get
        {
            if(endpointNavision == null)
            {
                if(Util.runningInASandbox)
				{
					endpointNavision = Util.valoresIntegracionNavision.get('Endpoint_Test_General');
				}
				else
				{
					endpointNavision = Util.valoresIntegracionNavision.get('Enpoint_Pro_General');
				}
            }
            return endpointNavision;
        }
        set;
    }

	//Este método se encarga de separar en 2 Strings si el parámetro de entrada es mayor de 50 caracteres
	//Se usa para separar en dos campos si el campo es demasiado grande para almacenarlo en Navision
	//@rcastanos (04/06/2019) Cambios para la utilización de metadatos
	public static List<String> separarEnDosStrings(String campoCompleto)
	{
		List<String> listaStrings = new List<String>();
		
		if(!String.IsEmpty(campoCompleto))
		{
			if(campoCompleto.length() <= Integer.valueOf(Util.valoresIntegracionNavision.get('Num_max_caracteres_campo')))
				listaStrings.add(campoCompleto);
			else
			{
				listaStrings.add(campoCompleto.substring(0, Integer.valueOf(Util.valoresIntegracionNavision.get('Num_max_caracteres_campo'))));
				listaStrings.add(campoCompleto.substring(Integer.valueOf(Util.valoresIntegracionNavision.get('Num_max_caracteres_campo')), campoCompleto.length()));
			}
		}
		
		return listaStrings;
	}

	//@rcastanos (04/06/2019) Cambios para la utilización de metadatos
	public static Set<String> peticionWSSincronizarContratos(SchemaContrato.entitySyncDto entidad)
	{   
		String body = XmlUtil.generarXmlSincronizarContratos(entidad);
       	HttpResponse res = peticionesWSNavision(endpointNavision, 'Url_crear_contratos',body);
       
      	Set<String> idsSfContratos = XmlUtil.parsearRespuestaSincronizarContratos(res);
       	System.debug('Set Contratos: idSf: ' + idsSfContratos);
		
		return idsSfContratos;
	} 
	
	/*
    ======================================================================================
    * -- CONFIRMACIONES ------------------------------------------------------------------
    ======================================================================================
    */
	//@future(callout=true) 
	//@rcastanos (04/06/2019) Cambios para la utilización de metadatos
	public static boolean peticionWSConfirmarTarifas(Map<String,String> idsNavisioIdsSf)
	{ 
		String body = XMLUtil.generarXmlConfirmarTarifas(idsNavisioIdsSf);
		System.debug(body);
		HttpResponse response = peticionesWSNavision(endpointNavision, 'Url_confirmar_tarifas',body);
		if(response.getStatusCode() == 200)
			return true;
		else
			return false;
	}
	
	//@future(callout=true)
	//public static boolean peticionWSConfirmarClientes(Map<String,String> idsNavisioIdsSf)
	//@rcastanos (04/06/2019) Cambios para la utilización de metadatos
	public static boolean peticionWSConfirmarClientes(Map<Account,List<Direcci_n_de_entrega__c>> idsNavisioIdsSf) //Se llama desde clientes confirmacion para enviar a navision las cuentas y direcciones
	{    
		String body = XMLUtil.generarXmlConfirmarClientes(idsNavisioIdsSf);
		System.debug('peticionWSConfirmarClientes: '+body);
		HttpResponse response = peticionesWSNavision(endpointNavision, 'Url_confirmar_clientes',body);
		if(response.getStatusCode() == 200)
			return true;
		else
			return false;
	}
	
	/*
    ======================================================================================
    * -- CONSULTA DE CLIENTES Y TARIFAS --------------------------------------------------
    ======================================================================================
    */
	//@rcastanos (04/06/2019) Cambios para la utilización de metadatos
	public static List<SchemaCliente.etCustomer> peticionWSConsultarClientes()
	{ 
		String body = XmlUtil.generarXmlConsultarClientes(); 
		HttpResponse res = peticionesWSNavision(endpointNavision, 'Url_consultar_clientes',body);
		System.debug('Respuesta peticionWSConsultarClientes: '+res);
		
		//gserrano 10-1-2019
		try 
		{
			if(Util.LogsNavisionActivados)
			{
				LogUtil.crearLog(res.getBody(), 'LogNavision', 'NavWSUtil', 'Error', false);
			}
		}
		catch (Exception e) 
		{
			system.debug('Error al guardar el log de Navision');
		}
		//Hasta aquí

		resPeticionConsultarClientes = res;
      	List<SchemaCliente.etCustomer> clientes = XmlUtil.parsearRespuestaConsultarClientes(res);
      	 
      	String listaClientesDebug = '';
      	
      	for(SchemaCliente.etCustomer cliente : clientes)
      	{
      		listaClientesDebug = listaClientesDebug +' - '+cliente.CustomerNo+'/'+cliente.SalesForceId;
      	}
      	
      	System.debug(LoggingLevel.ERROR,'Lista clientes: ' + listaClientesDebug);
      	
		return clientes;
	}
	
	//@rcastanos (04/06/2019) Cambios para la utilización de metadatos
	public static List<XmlUtil.RespuestaPeticionConsultarTarifas> peticionWSConsultarTarifas()
	{ 
		String body = XmlUtil.generarXmlConsultarTarifas();
		HttpResponse res = peticionesWSNavision(endpointNavision, 'Url_consultar_tarifas',body);
      	List<XmlUtil.RespuestaPeticionConsultarTarifas> listaTarifas = XmlUtil.parsearRespuestaConsultarTarifas(res);
      	
      	String listaTarifasDebug = '';
      	
      	for(XmlUtil.RespuestaPeticionConsultarTarifas tarifa : listaTarifas)
      	{
      		listaTarifasDebug = listaTarifasDebug +' - '+tarifa.idNavisio+'/'+tarifa.idSalesforce+'/'+tarifa.descripcion;
      	}
      	
      	System.debug('Lista tarifas: ' + listaTarifasDebug);
		return listaTarifas;
	}  
	
	/*
    ======================================================================================
    * -- SINCRONIZACION DE CLIENTES SF a NAV ---------------------------------------------
    ======================================================================================
    */
	//@rcastanos (04/06/2019) Cambios para la utilización de metadatos
    public static XmlUtil.RespuestaPeticionSincronizarClientes peticionWSSincronizarClientes(SchemaCliente.entitySyncDto entidad)
    {      
    	String body = XmlUtil.generarXmlSincronizarClientes(entidad);
       	HttpResponse res = peticionesWSNavision(endpointNavision, 'Url_crear_clientes',body);
       
      	XmlUtil.RespuestaPeticionSincronizarClientes camposRespuestaPeticion = XmlUtil.parsearRespuestaSincronizarClientes(res);
       	System.debug('Campos RespuestaPeticion: ' + camposRespuestaPeticion);
       	
       	if(camposRespuestaPeticion.mapaIdsSalesforceIdNavDatosBancarios != null)
        	System.debug('Se han cargado los datos bancarios de los clientes con Ids: '+camposRespuestaPeticion.mapaIdsSalesforceIdNavDatosBancarios.KeySet() + ' Valores: ' + camposRespuestaPeticion.mapaIdsSalesforceIdNavDatosBancarios.values());
    	
    	if(camposRespuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega != null)
    		System.debug('Se han cargado las direcciones de entrega de los clientes con Ids: '+camposRespuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.KeySet() + ' Valores: ' + camposRespuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega.values());
     	
     	if(camposRespuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas != null)
     		System.debug('Se han cargado los Ids de Navisio de los clientes con Ids: '+camposRespuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.KeySet() + ' Valores: ' + camposRespuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas.values());
        
        return camposRespuestaPeticion;
    }

	/*
    ======================================================================================
    * -- DETALLE CLIENTES ----------------------------------------------------------------
    ======================================================================================
    */
	//@rcastanos (04/06/2019) Cambios para la utilización de metadatos
	public static List<SchemaClientesDiarios.etDetailCustomer> peticionWSActualizarClientesYDireccionesEntrega()
	{ 
		String body = XmlUtil.generarXmlConsultarClientesYDireccionesEntrega(); 
		HttpResponse res = peticionesWSNavision(endpointNavision, 'Url_consultar_detalle_clientes', body); 
		System.debug('Respuesta peticionWSConsultarDetalleClientes: '+res);
      	List<SchemaClientesDiarios.etDetailCustomer> detalleClientesList = XmlUtil.parsearRespuestaConsultarClientesYDireccionesEntrega(res);
		  
    	LogUtil.crearLog('Peticion parseada: ' + detalleClientesList, 'peticionWSActualizarClientesYDireccionesEntrega', 'JSON respuesta', 'Sync', false);
      	System.debug('detalleClientesList '+detalleClientesList.size());
      	String listaDetalleClientesDebug = '';
      	
      	for(SchemaClientesDiarios.etDetailCustomer cliente : detalleClientesList)
      	{
      		listaDetalleClientesDebug = listaDetalleClientesDebug +' - '+cliente.CustomerNo;
      	}
      	
      	//System.debug(LoggingLevel.ERROR,'Lista detalle clientes: ' + listaDetalleClientesDebug);
      	
		return detalleClientesList;
	}

 	/*
    ======================================================================================
    * -- FACTURAS ------------------------------------------------------------------------
    ======================================================================================
    */
    /*public static List<> peticionWSConsultarFacturas()
	{
		String body = XmlUtil.generarXmlConsultarFacturas()); 
		HttpResponse res = peticionWSGenericaNavision(URL_CONSULTAR_FACTURAS, body, 4); 
		System.debug('Respuesta peticionWSConsultarFacturas: '+res);
      	List<> facturasList = XmlUtil.parsearRespuestaConsultarFacturas(res);
      	 
      	String listaFacturasDebug = '';
      	
      	for( factura : facturasList)
      	{
      		listaFacturasDebug = listaFacturasDebug +' - '+factura.;
      	}
      	
      	//System.debug(LoggingLevel.ERROR,'Lista detalle clientes: ' + listaDetalleClientesDebug);
      	
		return facturasList;
	}

	public static Boolean peticionWSConfirmarFacturas(Map<String,String> idsNavIdsSf)
	{
		String body = XMLUtil.generarXmlConfirmacionFacturas(idsNavisioIdsSf);
		System.debug('peticionWSConfirmarFacturas: '+ body);
		HttpResponse response = peticionWSGenerica(URL_CONFIRMAR_FACTURAS, body);
		if(response.getStatusCode() == 200)
		{
			return true;
		}
		else
		{
			return false;
		}
	}*/

    /*
    ======================================================================================
    * -- PETICIONES ----------------------------------------------------------------------
    ======================================================================================
    */

	//Refactorizacion de los varios métodos en uno solo. Ahora también se hacen uso de los metadatos
	//@rcastanos (04/06/2019)
	//public static HttpResponse peticionesWSNavision(String endpoint, String soapAction, String body) 
	public static HttpResponse peticionesWSNavision(String endpoint, String soapAction, String body)
	{
		HttpRequest req = new HttpRequest();
		HTTPResponse res = new HTTPResponse();
		Http http = new Http();
		Map<String, String> headers = new Map<String, String>();

		if(String.isNotBlank(valoresIntegracion.get(soapAction).namedCredential__c)){

			System.debug('***Utiliza NamCredential Boomi');
			req.setBody(body);
			req.setEndpoint('callout:'+valoresIntegracion.get(soapAction).namedCredential__c);
			req.setMethod('POST');
			req.setHeader('SOAPAction', Util.valoresIntegracionNavision.get(soapAction));
			res = http.send(req);
		}
		else{
			//Se utiliza una autenticación NTLM para callouts a Navision/BusinessCentral, se hace uso de la clase HttpClient 
			System.debug('***Utiliza BC/Navision Autenticación');

			req.setTimeout(Integer.valueOf(Util.valoresIntegracionNavision.get('Num_miliseconds_time_out')));
        	req.setBody(body);
        	Integer bodyLength = body.length();
			headers.put('VsDebuggerCausalityData', Util.valoresIntegracionNavision.get('Vsdebuggercausalitydata'));
			headers.put('Content-Type', Util.valoresIntegracionNavision.get('ContentType'));
			headers.put('SOAPAction', Util.valoresIntegracionNavision.get(soapAction));
			headers.put('Host', Util.valoresIntegracionNavision.get('Host'));
			headers.put('Content-Length', String.valueOf(bodyLength));
			//headers.put('Expect', '100-continue');
			headers.put('Connection', Util.valoresIntegracionNavision.get('Connection'));
			req.setMethod('POST');
			req.setHeader('Content-Type', Util.valoresIntegracionNavision.get('ContentType'));
			req.setEndpoint(endpoint);
			HttpClient httpObj = new HttpClient( Util.valoresIntegracionNavision.get('Domain') + '\\' + Util.valoresIntegracionNavision.get('User_Name') , Util.valoresIntegracionNavision.get('Password') ,True);
			res = httpObj.send(req,headers);
		}

		/*Cambios rfernandez (25/05/2018) Se van a guardar las peticiones realizadas entre las 8am y 7pm*/
        Time desde = Time.newInstance( 8, 0, 0, 0 );
		Time hasta = Time.newInstance( 19, 0, 0, 0 );
        if(System.now().time() > desde && System.now().time() < hasta)
        {
        	if( soapAction.equals('Url_crear_contratos') || soapAction.equals('Url_crear_clientes') )
        	{
    			LogUtil.crearLog('Peticion: '+body+ ' SoapAction: '+soapAction, 'PeticionNavision', soapAction, 'Sync', false);
			}	
        }

        //HttpResponse res = httpObj.send(req,headers);
		//HttpResponse res = httpObj.send(req);
		System.debug(LoggingLevel.ERROR, '***Request getMethod**: ' + req.getMethod());
		System.debug(LoggingLevel.ERROR, '***Request getHeaderAuthorization**: ' + req.getHeader('Authorization'));
		System.debug(LoggingLevel.ERROR, '***Request getHeaderSOAP**: ' + req.getHeader('SOAPAction'));
        System.debug(LoggingLevel.ERROR, '***Response getBody**: ' + res.getBody());
        System.debug(LoggingLevel.ERROR, '***Response headerKeys**: ' + res.getHeaderKeys());
        System.debug(LoggingLevel.ERROR, '***Response Code**: ' + res.getStatus()+' ***StatusCode:'+res.getStatusCode());
        
        List<String> headerKeys = res.getHeaderKeys();
        System.debug('Header Keys: ' + headerKeys );
        
        for(String key : headerKeys)
        {
        	if(key!=null)
        	{
	        	String header = res.getHeader(key);
	        	System.debug('Header ' + key + ' - valor:' + header);
        	}
        }
        
        for(String key : headers.keySet())
        {
        	if(key!=null)
        	{
	        	String header = headers.get(key);
	        	System.debug('Header ' + key + ' - valor:' + header);
        	}
        }
        
        return res;
	}

}