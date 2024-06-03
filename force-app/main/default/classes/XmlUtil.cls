/**
 * @description       : 
 * @author            : ivan.contreras@blackbirdcrew.com
 * @group             : 
 * @last modified on  : 04-05-2022
 * @last modified by  : ivan.contreras@blackbirdcrew.com
**/
public class XmlUtil {
	
	//Tipos de schemas para los objetos
	public static String WS_CLIENTE_SCHEMA 				= 'urn:microsoft-dynamics-nav/xmlports/x50020'; //LCS 01/2023: cambio x50050 por x50020
	public static String WS_TARIFA_SCHEMA 				= 'urn:microsoft-dynamics-nav/xmlports/x50021'; //LCS 01/2023: cambio x50053 por x50021
	public static String WS_CONTRATO_SCHEMA 			= 'urn:microsoft-dynamics-nav/xmlports/x50022'; //LCS 01/2023: cambio x50056 por x50022
	public static String WS_DETALLE_CLIENTE_SCHEMA		= 'urn:microsoft-dynamics-nav/xmlports/x50023'; //LCS 01/2023: cambio x50062 por x50023
	public static String WS_FACTURA_SCHEMA				= 'urn:microsoft-dynamics-nav/xmlports/x50017'; //LCS 01/2023: cambio '' por ...x50017

	//Métodos del WS de clientes 
	public static String WS_METHOD_CONFIRMAR_CLIENTES 	= 'Nav2sfdc_ClientesConfirmacion';
	public static String WS_METHOD_CONSULTAR_CLIENTES 	= 'Nav2sfdc_ConsultarClientes';
	public static String WS_METHOD_SINCRONIZAR_CLIENTES = 'Sfdc2Nav_CrearCliente';
	public static String WS_METHOD_DETALLE_CLIENTES 	= 'Nav2sfdc_DetailCustomer';

	//Métodos del WS de tarifas
	public static String WS_METHOD_CONFIRMAR_TARIFAS 	= 'Nav2sfdc_TarifasConfirmacion';
	public static String WS_METHOD_CONSULTAR_TARIFAS 	= 'Nav2sfdc_Tarifas';
	
	//Métodos del WS de serviceItems
	public static String WS_METHOD_CONSULTAR_SERVICE_ITEMS = 'Nav2sfdc_ConsultarServiceItems';
	
	//Métodos del WS de contratos
	public static String WS_METHOD_SINCRONIZAR_CONTRATOS = 'Sfdc2Nav_CrearContrato';

	//Métodos del WS de facturas
	public static String WS_METHOD_CONSULTAR_FACTURAS = '';
	
	//CLASES UTILIZADAS PARA EL PARSEO DE LOS XMLs 
	
	//Estas clases se crean para almacenar en un único objeto todos los parámetros necesarios devueltos por Navision
	public class RespuestaPeticionSincronizarClientes { 
		//Se almacena la relación entre los Ids de SF y Ids de Nav de las cuentas
		public Map<String,String> mapaIdsSalesforceIdsNavisioCuentas {get; set;}
		  
		//Se almacena la relación entre los Ids de SF y Ids de Nav de las direcciones de entrega
		public Map<String,String> mapaIdsSalesforceIdsNavisioDireccionesEntrega {get; set;}
		
		//Se almacena la relación entre los Ids de SF y los datos bancarios de las cuentas
		public Map<String,String> mapaIdsSalesforceIdNavDatosBancarios {get; set;}
		
	}
	
	public class RespuestaPeticionConsultarTarifas { 
		public String idNavisio {get; set;}
		public String idSalesforce {get; set;}
		public String descripcion {get; set;} 
	}

	//MÉTODOS DE PARSEO DE XMLs
	public static List<SchemaCliente.etCustomer> parsearRespuestaConsultarClientes(HttpResponse res)
    {
    	System.debug(' before parsearRespuestaConsultarClientes');
    	List<SchemaCliente.etCustomer> listaEtCustomers = new List<SchemaCliente.etCustomer>();
    	Dom.Document documentoClientes = res.getBodyDocument();

    	for(dom.XmlNode nodoRaiz : documentoClientes.getRootElement().getChildElements())
    	{
    		//System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		//System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == WS_METHOD_CONSULTAR_CLIENTES + '_Result')
		    		{
		    			for(dom.XmlNode nodoHijo : nodo.getChildElements())
		    			{
		    				//System.debug('nodoHijo: '+nodoHijo.getName());
		    				if(nodoHijo.getName() == 'entitySyncDto_OUT')
		    				{
		    					for(dom.XmlNode nodoNieto : nodoHijo.getChildElements())
		    					{
				    				//System.debug('nodoNieto: ' + nodoNieto.getName());
				    				if(nodoNieto.getName() == 'etCustomer')
				    				{
				    					SchemaCliente.etCustomer etCustomer = new SchemaCliente.etCustomer();
				    					for(dom.XmlNode nodoBisNieto : nodoNieto.getChildElements())
				    					{ 
						    				//System.debug('nodoBisNieto - Nombre: ' + nodoBisNieto.getName() + ', Valor: ' + nodoBisNieto.getText() );
						    				if(nodoBisNieto.getName() == 'CustomerNo')
							    			{
						    					etCustomer.CustomerNo = nodoBisNieto.getText();
							    			}  
							    			else if(nodoBisNieto.getName() == 'Name')
							    			{
						    					etCustomer.Name = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Name2')
							    			{
						    					etCustomer.Name2 = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Name_SF')
							    			{
						    					etCustomer.Name_SF = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Surname_SF')
							    			{
						    					etCustomer.Surname_SF = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Addres')
							    			{
						    					etCustomer.Addres = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Addres2')
							    			{
						    					etCustomer.Addres2 = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'City')
							    			{
						    					etCustomer.City = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'PostCode')
							    			{
						    					etCustomer.PostCode = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'County')
							    			{
						    					etCustomer.County = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Country')
							    			{
						    					etCustomer.Country = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Phone')
							    			{
						    					etCustomer.Phone = nodoBisNieto.getText();
							    			}
							    			//////
							    			else if(nodoBisNieto.getName() == 'Mobile')
							    			{
						    					etCustomer.Mobile = nodoBisNieto.getText();
							    			}
							    			//////
							    			else if(nodoBisNieto.getName() == 'Fax')
							    			{
						    					etCustomer.Fax = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'email')
							    			{
						    					etCustomer.email = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'VatRegistration')
							    			{
						    					etCustomer.VatRegistration = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'PaymentTerms')
							    			{
						    					etCustomer.PaymentTerms = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'PaymentMethod')
							    			{
						    					etCustomer.PaymentMethod = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'PaymentTermsStdOrd')
							    			{
						    					etCustomer.PaymentTermsStdOrd = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'PaymentTermsFuelOrd')
							    			{
						    					etCustomer.PaymentTermsFuelOrd = nodoBisNieto.getText();
							    			}
							    			/*else if(nodoBisNieto.getName() == 'PaymentTermsCrdCardOrd')
							    			{
						    					etCustomer.PaymentTermsCrdCardOrd = nodoBisNieto.getText();
							    			}*/
							    			else if(nodoBisNieto.getName() == 'PaymentDays')
							    			{
						    					etCustomer.PaymentDays = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'NoPaymentDays')
							    			{
						    					etCustomer.NoPaymentDays = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Comercial')//cambios rfernandez (30/01/2017)
							    			{
						    					etCustomer.Comercial = nodoBisNieto.getText();
							    			}
							    			//////
											else if(nodoBisNieto.getName() == 'DOM_PROF') 
							    			{
						    					etCustomer.DOM_PROF = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'eMailInvoice')//cambios rfernandez (26/05/2017)
							    			{
						    					etCustomer.eMailInvoice = Boolean.valueOf(nodoBisNieto.getText());
							    			}
							    			else if(nodoBisNieto.getName() == 'AlertaBloqueo') //Cambios rfernandez (26/06/2017)
							    			{
							    				List<String> alertaBloqueoList = new List<String>{nodoBisNieto.getText()};
						    					etCustomer.AlertaBloqueo = alertaBloqueoList;
							    			}
							    			else if(nodoBisNieto.getName() == 'SaldoPendiente')
							    			{
							    				List<String> saldoPendienteList = new List<String>{nodoBisNieto.getText()};
							    				etCustomer.SaldoPendiente = saldoPendienteList;
							    			}
							    			else if(nodoBisNieto.getName() == 'SaldoVivo')
							    			{
							    				List<String> saldoVivoList = new List<String>{nodoBisNieto.getText()};
							    				etCustomer.SaldoVivo = saldoVivoList;
							    			}											//Fin cambios rfernandez (26/06/2017)
							    			else if(nodoBisNieto.getName() == 'SalesForceId')
							    			{
							    				etCustomer.SalesForceId = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'etAddres' )
							    			{	
							    				SchemaCliente.etAddres etAddres = new SchemaCliente.etAddres();
				    							for(dom.XmlNode nodoTataraNieto : nodoBisNieto.getChildElements())
					    						{
								    				//System.debug('nodoTataraNieto - Nombre: ' + nodoTataraNieto.getName() + ', Valor: ' + nodoTataraNieto.getText() );
								    				//Hay que actualizarlo con el campo IdNavisio
								    				if(nodoTataraNieto.getName() == 'ADCode')
									    			{
								    					etAddres.ADCode = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADAddres')
									    			{
								    					etAddres.ADAddres = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADAddres2')
									    			{
								    					etAddres.ADAddres2 = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADCity')
									    			{
								    					etAddres.ADCity = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADCounty')//cambios rfernandez (25/04/2017)
									    			{
								    					etAddres.ADCounty = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADPostCode') 
									    			{
								    					etAddres.ADPostCode = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADCountry')
									    			{
								    					etAddres.ADCountry = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'Activity1')
									    			{
								    					etAddres.Activity1 = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'Activity2')
									    			{
								    					etAddres.Activity2 = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'FixTemperature')
									    			{
								    					etAddres.FixTemperature = Integer.valueOf(nodoTataraNieto.getText());
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADCodePriceDiscount')
									    			{
								    					etAddres.ADCodePriceDiscount = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADStatus')//cambios rfernandez (25/05/2017)
									    			{
								    					etAddres.ADStatus = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADBlocked')
									    			{
								    					etAddres.ADBlocked = Boolean.valueOf(nodoTataraNieto.getText());
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADBlockedReason')
									    			{
								    					etAddres.ADBlockedReason = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADConsumoPrevistoKgs') //Cambios rfernandez (26/06/2017)
									    			{
									    				List<String> consumoPrevistoKList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.ADConsumoPrevistoKgs = consumoPrevistoKList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADConsumoPromedioLast3y')
									    			{
									    				List<String> consumoPromedioList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.ADConsumoPromedioLast3y = consumoPromedioList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADConsumoPromedioLast12m')
									    			{
									    				List<String> consumoPromedioLastList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.ADConsumoPromedioLast12m = consumoPromedioLastList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADActualPrice')
									    			{
									    				List<String> actualPriceList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.ADActualPrice = actualPriceList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADDiscounts')
									    			{
									    				List<String> discountList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.ADDiscounts = discountList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADDAddressType')
									    			{
								    					etAddres.ADDAddressType = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'SIBocaCarga')
									    			{
									    				List<String> bocaCargaList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.SIBocaCarga = bocaCargaList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'SIEstadoBocaCarga')
									    			{
									    				List<String> estadoBocaCargaList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.SIEstadoBocaCarga = estadoBocaCargaList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'SIDeposito')
									    			{
									    				List<String> depositoList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.SIDeposito = depositoList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'SIEstadoDeposito')
									    			{
									    				List<String> estadoDepositoList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.SIEstadoDeposito = estadoDepositoList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'SITelemedida')
									    			{
									    				List<String> telemedidaList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.SITelemedida =telemedidaList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'SIEstadoTelemedida')
									    			{
									    				List<String> estadoTelemedidaList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.SIEstadoTelemedida = estadoTelemedidaList;
									    			}
									    			else if(nodoTataraNieto.getName() == 'SIPropiedadTanque')
									    			{
									    				List<String> propiedadTanqueList = new List<String>{nodoTataraNieto.getText()};
								    					etAddres.SIPropiedadTanque = propiedadTanqueList;
									    			}																//Fin cambios rfernandez (26/06/2017)
									    			else if(nodoTataraNieto.getName() == 'ADFirstFilledDate')		//Cambios rfernandez (08/02/2018)
									    			{
									    				String fechaPrimerLlenadoString = nodoTataraNieto.getText();
														Date fechaPrimerLlenadoDate;
														//Comprobamos el formato de la fecha para ver si viene de una de estas formas 08-02-2018 o 2018-02-08
														if(fechaPrimerLlenadoString.left(3).contains('-') && !fechaPrimerLlenadoString.right(4).contains('-'))
														{
															List<String> fechaPrimerLlenadoList = fechaPrimerLlenadoString.split('-');
															String dia 	= fechaPrimerLlenadoList[0];
															String mes 	= fechaPrimerLlenadoList[1];
															String anyo	= fechaPrimerLlenadoList[2];
															
															fechaPrimerLlenadoDate = Date.valueOf(anyo+'-'+mes+'-'+dia);
															
														}else if(!fechaPrimerLlenadoString.left(4).contains('-') && fechaPrimerLlenadoString.right(3).contains('-'))
														{
															fechaPrimerLlenadoDate = Date.valueOf(fechaPrimerLlenadoString);
														}
														if(fechaPrimerLlenadoDate != null)
														{
															etAddres.ADFirstFilledDate = fechaPrimerLlenadoDate;	
														}
								    					
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADSalesForceId')
									    			{
								    					etAddres.ADSalesForceId = nodoTataraNieto.getText();
									    			}
					    						}
					    						
					    						List<SchemaCliente.etAddres> etAddresList;
						    					if(etCustomer.etAddres == null)
						    					{
						    						etAddresList = new List<SchemaCliente.etAddres>(); 
						    					}
						    					else
						    					{
						    						etAddresList = etCustomer.etAddres; 
						    					}
						    						
						    					etAddresList.add(etAddres);
						    					etCustomer.etAddres = etAddresList;
							    			}
							    			else if(nodoBisNieto.getName() == 'etDataBank')
							    			{
							    				SchemaCliente.etDataBank etDataBank = new SchemaCliente.etDataBank();
				    							
							    				for(dom.XmlNode nodoTataraNieto : nodoBisNieto.getChildElements())
					    						{
								    				//System.debug('nodoTataraNieto - Nombre: ' + nodoTataraNieto.getName() + ', Valor: ' + nodoTataraNieto.getText() );
								    				if(nodoTataraNieto.getName() == 'BankCode')
									    			{
								    					etDataBank.BankCode = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'BankIBAN')
									    			{
								    					etDataBank.BankIBAN = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'BankSWIFT')
									    			{
								    					etDataBank.BankSWIFT = nodoTataraNieto.getText();
									    			}
					    						}
					    						
					    						List<SchemaCliente.etDataBank> etDataBankList;
							    				if(etCustomer.etDataBank == null)
							    				{
							    					etDataBankList = new List<SchemaCliente.etDataBank>(); 
							    				}
							    				else
							    				{
							    					etDataBankList = etCustomer.etDataBank; 
							    				}
						    						
						    					etDataBankList.add(etDataBank);
						    					etCustomer.etDataBank = etDataBankList;
							    			}
				    					}
				    					
				    					listaEtCustomers.add(etCustomer);
				    				}
		    					}
		    				}
		    			}
		    		}
    			}
    		}
    	} 
    	
    	return listaEtCustomers;
    }
	
	public static List<RespuestaPeticionConsultarTarifas> parsearRespuestaConsultarTarifas(HttpResponse res)
    {
    	
    	List<RespuestaPeticionConsultarTarifas> listaRespuestaTarifas = new List<RespuestaPeticionConsultarTarifas>();
    	
    	try
    	{
    		Dom.Document doc = res.getBodyDocument();
		}catch(Exception e)
		{
			LogUtil.crearLog('Respuesta Tarifas: '+res.getBody(), 'parsearRespuestaConsultarTarifas', '', 'Sync', false);
			LogUtil.guardarLog();
		}

    	Dom.Document doc = res.getBodyDocument();

    	for(dom.XmlNode nodoRaiz : doc.getRootElement().getChildElements())
    	{
    		System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == WS_METHOD_CONSULTAR_TARIFAS + '_Result')
		    		{
		    			for(dom.XmlNode nodoHijo : nodo.getChildElements())
		    			{
		    				System.debug('nodoHijo: '+nodoHijo.getName());
		    				if(nodoHijo.getName() == 'entitySyncDto_OUT')
		    				{
		    					for(dom.XmlNode nodoNieto : nodoHijo.getChildElements())
		    					{
				    				System.debug('nodoNieto: ' + nodoNieto.getName());
				    				if(nodoNieto.getName() == 'etTarifa')
				    				{
				    					String tarifaCode = '';
				    					String description = '';
				    					String salesforceId = '';
				    					
				    					for(dom.XmlNode nodoBisNieto : nodoNieto.getChildElements())
				    					{
						    				System.debug('nodoBisNieto - Nombre: ' + nodoBisNieto.getName() + ', Valor: ' + nodoBisNieto.getText() );
						    				if(nodoBisNieto.getName() == 'TarifaCode')
							    			{
						    					tarifaCode = nodoBisNieto.getText();
							    			}  
							    			else if(nodoBisNieto.getName() == 'Description')
							    			{
						    					description = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'SalesforceId')
							    			{
						    					salesforceId = nodoBisNieto.getText();
							    			}
				    					}
				    					
				    					
				    					if(!String.IsEmpty(tarifaCode) || !String.IsEmpty(description) || !String.IsEmpty(salesforceId))
				    					{
					    					RespuestaPeticionConsultarTarifas tarifa = new RespuestaPeticionConsultarTarifas();
					    					
					    					if(!String.IsEmpty(tarifaCode))
					    						tarifa.idNavisio = tarifaCode;
					    						
					    					if(!String.IsEmpty(description))
												tarifa.descripcion = description;
					    					
					    					if(!String.IsEmpty(salesforceId))
												tarifa.idSalesforce = salesforceId;
					    					
					    					listaRespuestaTarifas.add(tarifa);
				    					}
				    				}
		    					}
		    				}
		    			}
		    		}
    			}
    		}
    	} 
    	
    	return listaRespuestaTarifas;
    }
    
    //En este método se rellena el mapa de Id de contrato e Id de Salesforce
	//Con la respuesta del WS en el método de SincronizarContratos
    public static Set<String> parsearRespuestaSincronizarContratos(HttpResponse res)
	{
    	Set<String> setIdSFContratos = new Set<String>();
    	
    	Dom.Document doc = res.getBodyDocument();

    	for(dom.XmlNode nodoRaiz : doc.getRootElement().getChildElements())
    	{
    		System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == WS_METHOD_SINCRONIZAR_CONTRATOS + '_Result')
		    		{
		    			for(dom.XmlNode nodoHijo : nodo.getChildElements())
		    			{
		    				System.debug('nodoHijo: '+nodoHijo.getName());
		    				if(nodoHijo.getName() == 'entitySyncDto_OUT')
		    				{
		    					for(dom.XmlNode nodoNieto : nodoHijo.getChildElements())
		    					{
				    				System.debug('nodoNieto: ' + nodoNieto.getName());
				    				if(nodoNieto.getName() == 'etContract')
				    				{
				    					if(nodoNieto.getChildElement('IDSalesForce', WS_CONTRATO_SCHEMA) != null)
				    					{
				    						String idSFC = nodoNieto.getChildElement('IDSalesForce', WS_CONTRATO_SCHEMA).getText();
				    						setIdSFContratos.add(idSFC);
				    					}
				    				}
		    					}
		    				}
		    			}
		    		}
    			}
    		} 
    	} 
    	return setIdSFContratos;
    }
	
	//En este método se rellenan los mapas de clientes, direcciones de entrega y datos bancarios
	//Con la respuesta del WS en el método de SincronizarClientes
    public static RespuestaPeticionSincronizarClientes parsearRespuestaSincronizarClientes(HttpResponse res)
    {
    	Map<String,String> mapaIdSFIdNavClientes = new Map<String,String>();
    	Map<String,String> mapaIdSFIdNavAddress = new Map<String,String>();
    	Map<String,String> mapaIdSFIdDatosBancarios = new Map<String,String>();
    	
    	Dom.Document doc = res.getBodyDocument();

    	//////
    	if(doc==null || doc.getRootElement()==null || doc.getRootElement().getChildElements().size()==0)
    	{
    		LogUtil.crearLog('No se ha recibido respuesta al sincronizar el cliente', 'SincronizarClientes', 'Cliente', 'Sync', true);
			//LogUtil.guardarLog();
    	}
    	//////
    	for(dom.XmlNode nodoRaiz : doc.getRootElement().getChildElements())
    	{
    		System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			//////
		    	if(nodoRaiz.getChildElements().size()==0)
		    	{
		    		LogUtil.crearLog('No se ha recibido respuesta al sincronizar el cliente', 'SincronizarClientes', 'Cliente', 'Sync', true);
					//LogUtil.guardarLog();
		    	}
		    	//////
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == WS_METHOD_SINCRONIZAR_CLIENTES + '_Result')
		    		{
		    			for(dom.XmlNode nodoHijo : nodo.getChildElements())
		    			{
		    				System.debug('nodoHijo: '+nodoHijo.getName());
		    				if(nodoHijo.getName() == 'entitySyncDto_OUT')
		    				{
		    					for(dom.XmlNode nodoNieto : nodoHijo.getChildElements())
		    					{
				    				System.debug('nodoNieto: ' + nodoNieto.getName());
				    				if(nodoNieto.getName() == 'etCustomer')
				    				{
				    					//Sacamos el Id Navisio y de SF de cada cliente
    									String idNavC = '';
				    					String idSFC = '';
				    					
				    					//Necesitamos obtener primero el Id de SF, el objeto etAddres necesita este campo
				    					if(nodoNieto.getChildElement('SalesForceId', WS_CLIENTE_SCHEMA) != null)
				    					{
				    						idSFC = nodoNieto.getChildElement('SalesForceId', WS_CLIENTE_SCHEMA).getText();
				    						System.debug('SalesForceId: '+idSFC);
				    					}
				    					
				    					if(nodoNieto.getChildElement('CustomerNo', WS_CLIENTE_SCHEMA) != null)
				    					{
				    						idNavC = nodoNieto.getChildElement('CustomerNo', WS_CLIENTE_SCHEMA).getText();
				    						System.debug('CustomerNo: '+idSFC);
				    					}
				    					
				    					for(dom.XmlNode nodoBisNieto : nodoNieto.getChildElements())
				    					{
						    				System.debug('nodoBisNieto - Nombre: ' + nodoBisNieto.getName() + ', Valor: ' + nodoBisNieto.getText() );
						    				  
							    			if(nodoBisNieto.getName() == 'etAddres')
							    			{
							    				//Sacamos el Id Navisio y de SF de cada dirección de entrega
		    									String idNavA = '';
						    					String idSFA = '';
							    				for(dom.XmlNode nodoTataraNieto : nodoBisNieto.getChildElements())
					    						{
								    				System.debug('nodoTataraNieto - Nombre: ' + nodoTataraNieto.getName() + ', Valor: ' + nodoTataraNieto.getText() );
								    				if(nodoTataraNieto.getName() == 'ADCode')
									    			{
								    					idNavA = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'ADSalesForceId')
									    			{
								    					idSFA = nodoTataraNieto.getText();
									    			}
					    						}
					    						
					    						System.debug('idNavA: '+idNavA+' - idSFA:'+idSFA);
					    						
					    						if(!String.IsEmpty(idNavA) && !String.IsEmpty(idSFA))
						    						mapaIdSFIdNavAddress.put(idSFA,idNavA);
							    			}
							    			else if(nodoBisNieto.getName() == 'etDataBank')
							    			{
							    				//Sacamos el Id Navisio y de SF de los datos de 
		    									String BankCode = '';
						    					String BankIBAN = '';
						    					String BankSWIFT = '';
						    					
							    				for(dom.XmlNode nodoTataraNieto : nodoBisNieto.getChildElements())
					    						{
								    				System.debug('nodoTataraNieto - Nombre: ' + nodoTataraNieto.getName() + ', Valor: ' + nodoTataraNieto.getText() );
								    				if(nodoTataraNieto.getName() == 'BankCode')
									    			{
								    					BankCode = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'BankIBAN')
									    			{
								    					BankIBAN = nodoTataraNieto.getText();
									    			}
									    			else if(nodoTataraNieto.getName() == 'BankSWIFT')
									    			{
								    					BankSWIFT = nodoTataraNieto.getText();
									    			}
					    						}
					    						
					    						if(!String.IsEmpty(BankCode))
						    					{
						    						if(!String.IsEmpty(BankCode))
						    							mapaIdSFIdDatosBancarios.put(idSFC,BankCode);
						    					}
							    			}
				    					}
				    					
				    					System.debug('idNavC: '+idNavC+' - idSFC:'+idSFC);
				    						
				    					if(!String.IsEmpty(idNavC) && !String.IsEmpty(idSFC))
						    				mapaIdSFIdNavClientes.put(idSFC,idNavC);
					    				//////
										else
										{
											if(String.IsEmpty(idNavC))
											{
												LogUtil.crearLog('Falta el id de Navision en la respuesta al sincronizar el cliente. Id Salesforce: ' + idSFC, 'SincronizarClientes', 'Cliente', 'Sync', true);
											}
											else
											{
												LogUtil.crearLog('Falta el id de Salesforce en la respuesta al sincronizar el cliente. Id Navision: ' + idNavC, 'SincronizarClientes', 'Cliente', 'Sync', true);
											}
											//LogUtil.guardarLog();
										}
										//////				    			
				    				}
		    					}
		    				}
		    			}
		    		}
		    		//////
		    		else
		    		{
		    			LogUtil.crearLog('No se ha recibido respuesta al sincronizar el cliente', 'SincronizarClientes', 'Cliente', 'Sync', true);
						//LogUtil.guardarLog();
		    		}
		    		//////
    			}
    		}
    	} 
    	
    	//LogUtil.guardarLog();
    	
    	RespuestaPeticionSincronizarClientes respuestaPeticion = new RespuestaPeticionSincronizarClientes();
    	
    	//Comentado para que se rellene con una lista sin elementos pero inicializada
    	//if(mapaIdSFIdNavClientes.KeySet().size()>0)
    		respuestaPeticion.mapaIdsSalesforceIdsNavisioCuentas = mapaIdSFIdNavClientes;
    	
    	//if(mapaIdSFIdDatosBancarios.KeySet().size()>0)
    		respuestaPeticion.mapaIdsSalesforceIdNavDatosBancarios = mapaIdSFIdDatosBancarios; 
    	
    	//if(mapaIdSFIdNavAddress.KeySet().size()>0)
    		respuestaPeticion.mapaIdsSalesforceIdsNavisioDireccionesEntrega = mapaIdSFIdNavAddress;
    	
    	return respuestaPeticion;
    }
    
    //MÉTODOS PARA LA CREACIÓN DE XMLs
    
	//Este método pone a true el campo SFUpdated de los clientes con el id de navisio indicado
    public static String generarXmlConfirmarTarifas(Map<String,String> mapaIdsNavisioIdSf) {
    	Xmlstreamwriter xmlW = new Xmlstreamwriter(); 
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_CONFIRMAR_TARIFAS, null);
					//LCS 01/2023: Se añade prefijo WSSF_ por cambio en BC
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WSSF_PGE_SF');
	        		xmlW.writeStartElement(null, 'entitySyncDto', null);
	        		if(mapaIdsNavisioIdSf!=null && mapaIdsNavisioIdSf.KeySet().size()>0) 
	        		{ 
	        			for(String idSf : mapaIdsNavisioIdSf.KeySet())
						{
						    xmlW.writeStartElement(null,'etTarifa',null);
					    		xmlW.writeAttribute(null, null,'xmlns',WS_TARIFA_SCHEMA);
					    		
					    		String idNav = mapaIdsNavisioIdSf.get(idSf);
					    	
					    		if(!String.IsEmpty(idNav))
						    	{
							    	xmlW.writeStartElement(null, 'TarifaCode', null);
				                   	    xmlW.writeCharacters(idNav);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'TarifaCode', null);
						    	
						    	if(!String.IsEmpty(idSf))
						    	{
							    	xmlW.writeStartElement(null, 'SalesForceId', null);
				                   	    xmlW.writeCharacters(idSf);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'SalesForceId', null);
							    
							    xmlW.writeStartElement(null, 'SFUpdated', null);
				                	xmlW.writeCharacters('true');
				                xmlW.writeEndElement();
				                    
						    xmlW.writeEndElement();
						  }
						}
						     
						xmlW.writeEndElement();
						//Creamos el entitySyncDto_OUT vacío
				    	xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
				   		xmlW.writeEmptyElement(null, 'etTarifa',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        System.debug('Body: '+mensaje);
        
        return mensaje;
    }    
    
    //Este método pone a true el campo SFUpdated de los clientes con el id de navisio indicado
    //public static String generarXmlConfirmarClientes(Map<String,String> mapaIdsNavisioIdSf) {
	public static String generarXmlConfirmarClientes(Map<Account,List<Direcci_n_de_entrega__c>> mapaIdsNavisioIdSf) {
    	Xmlstreamwriter xmlW = new Xmlstreamwriter(); 
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_CONFIRMAR_CLIENTES, null);
					//LCS 01/2023: Se añade prefijo WSSF_ por cambio en BC
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WSSF_PGE_SF');
	        		xmlW.writeStartElement(null, 'entitySyncDto', null);
	        		if(mapaIdsNavisioIdSf!=null && mapaIdsNavisioIdSf.KeySet().size()>0) 
	        		{
	        			//////
	        			for(Account cuenta: mapaIdsNavisioIdSf.KeySet())
	        			{
	        				xmlW.writeStartElement(null,'etCustomer',null);
				    		xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
				    	
				    		if(cuenta.Id_Navision__c!=null)
					    	{
						    	xmlW.writeStartElement(null, 'CustomerNo', null);
			                   	    xmlW.writeCharacters(cuenta.Id_Navision__c);
			                    xmlW.writeEndElement();
					    	}
					    	else 
					    		xmlW.writeEmptyElement(null, 'CustomerNo', null);
					    	
					    	if(cuenta.Id!=null)
					    	{
						    	xmlW.writeStartElement(null, 'SalesForceId', null);
			                   	    xmlW.writeCharacters(cuenta.Id);
			                    xmlW.writeEndElement();
					    	}
					    	else 
					    		xmlW.writeEmptyElement(null, 'SalesForceId', null);
						    
						    xmlW.writeStartElement(null, 'SFUpdated', null);
			                	xmlW.writeCharacters('true');
			                xmlW.writeEndElement();

	
			                if(mapaIdsNavisioIdSf.get(cuenta)!=null && mapaIdsNavisioIdSf.get(cuenta).size()>0)
							{
								for(Direcci_n_de_entrega__c addres: mapaIdsNavisioIdSf.get(cuenta))
								{
									xmlW.writeStartElement(null, 'etAddres', null);
									
									if(addres.Id_Navision__c!=null)
									{		
										xmlW.writeStartElement(null, 'ADCode', null);
											xmlW.writeCharacters(addres.Id_Navision__c);
										xmlW.writeEndElement();
									}
									else 
										xmlW.writeEmptyElement(null, 'ADCode', null);

									if(addres.Id!=null)
							    	{		
						                xmlW.writeStartElement(null, 'ADSalesForceId', null);
						                   	xmlW.writeCharacters(addres.Id);
						                xmlW.writeEndElement();
							    	}
							    	else 
					    				xmlW.writeEmptyElement(null, 'ADSalesForceId', null);
					    	
					                xmlW.writeEndElement();
				                }
				            }

				            xmlW.writeEndElement();
	        			}
	        		}
	        			//////
	        			/*for(String idSf : mapaIdsNavisioIdSf.KeySet())
						{
						    	xmlW.writeStartElement(null,'etCustomer',null);
					    		xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
					    		
					    		String idNav = mapaIdsNavisioIdSf.get(idSf);
					    	
					    		if(!String.IsEmpty(idNav))
						    	{
							    	xmlW.writeStartElement(null, 'CustomerNo', null);
				                   	    xmlW.writeCharacters(idNav);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'CustomerNo', null);
						    	
						    	if(!String.IsEmpty(idSf))
						    	{
							    	xmlW.writeStartElement(null, 'SalesForceId', null);
				                   	    xmlW.writeCharacters(idSf);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'SalesForceId', null);
							    
							    xmlW.writeStartElement(null, 'SFUpdated', null);
				                	xmlW.writeCharacters('true');
				                xmlW.writeEndElement();
				                    
						    xmlW.writeEndElement();
						  }
						}*/
						    
						xmlW.writeEndElement();
						//Creamos el entitySyncDto_OUT vacío
				    	xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
				   		xmlW.writeEmptyElement(null, 'etCustomer',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        System.debug('Body: '+mensaje);
      
        return mensaje;
    }
    
    //En este método se crea el xml de clientes, direcciones de entrega y datos bancarios
	//Para realizar la petición en el método de SincronizarClientes
    public static String generarXmlSincronizarClientes(SchemaCliente.entitySyncDto entidad) {
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_SINCRONIZAR_CLIENTES, null);
					//LCS 01/2023: Se añade prefijo WSSF_ por cambio en BC
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WSSF_PGE_SF');
	        		xmlW.writeStartElement(null, 'entitySyncDto', null);
	        		if(entidad!=null && entidad.etCustomer!=null && entidad.etCustomer.size()>0)
	        		{
	        			for(SchemaCliente.etCustomer ent : entidad.etCustomer)
						{
						    xmlW.writeStartElement(null,'etCustomer',null);
					    		xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
					    	
					    		if(!String.IsEmpty(ent.CustomerNo))
						    	{
							    	xmlW.writeStartElement(null, 'CustomerNo', null);
				                   	    xmlW.writeCharacters(ent.CustomerNo);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'CustomerNo', null);
					    	
						    	if(!String.IsEmpty(ent.Name))
						    	{
							    	xmlW.writeStartElement(null, 'Name', null);
				                   	    xmlW.writeCharacters(ent.Name);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Name', null);
						    	
						    	if(!String.IsEmpty(ent.Name2))
						    	{
							    	xmlW.writeStartElement(null, 'Name2', null);
				                   	    xmlW.writeCharacters(ent.Name2);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Name2', null);
						    	
						    	if(!String.IsEmpty(ent.Name_SF))
						    	{
							    	xmlW.writeStartElement(null, 'Name_SF', null);
				                   	    xmlW.writeCharacters(ent.Name_SF);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Name_SF', null);

						    	if(!String.IsEmpty(ent.Surname_SF))
						    	{
							    	xmlW.writeStartElement(null, 'Surname_SF', null);
				                   	    xmlW.writeCharacters(ent.Surname_SF);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Surname_SF', null);
						    	
						    	if(!String.IsEmpty(ent.Addres))
						    	{
							    	xmlW.writeStartElement(null, 'Addres', null);
				                   	    xmlW.writeCharacters(ent.Addres);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Addres', null);
						    	
						    	
						    	if(!String.IsEmpty(ent.Addres2))
						    	{
							    	xmlW.writeStartElement(null, 'Addres2', null);
				                   	    xmlW.writeCharacters(ent.Addres2);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Addres2', null);
						    	
						    	//La ciudad falla
						    	if(!String.IsEmpty(ent.City))
						    	{
							    	xmlW.writeStartElement(null, 'City', null);
				                   	    xmlW.writeCharacters(ent.City);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'City', null);
						    	
						    	if(!String.IsEmpty(ent.PostCode))
						    	{
							    	xmlW.writeStartElement(null, 'PostCode', null);
				                   	    xmlW.writeCharacters(ent.PostCode);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'PostCode', null);
						    	
						    	if(!String.IsEmpty(ent.County))
						    	{
							    	xmlW.writeStartElement(null, 'County', null);
				                   	    xmlW.writeCharacters(ent.County);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'County', null);
						    	
						    	if(!String.IsEmpty(ent.Country))
						    	{
							    	xmlW.writeStartElement(null, 'Country', null);
				                   	    xmlW.writeCharacters(ent.Country);
				                    xmlW.writeEndElement();
						    	}
						    	else 
									xmlW.writeEmptyElement(null, 'Country', null);
						    	
						    	if(!String.IsEmpty(ent.Phone))
						    	{
							    	xmlW.writeStartElement(null, 'Phone', null);
				                   	    xmlW.writeCharacters(ent.Phone);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Phone', null);

					    		//////
					    		if(!String.IsEmpty(ent.Mobile))
						    	{
							    	xmlW.writeStartElement(null, 'Mobile', null);
				                   	    xmlW.writeCharacters(ent.Mobile);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Mobile', null);
					    		//////
						    	
						    	if(!String.IsEmpty(ent.Fax))
						    	{
							    	xmlW.writeStartElement(null, 'Fax', null);
				                   	    xmlW.writeCharacters(ent.Fax);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Fax', null);
						    	
						    	if(!String.IsEmpty(ent.email))
						    	{
							    	xmlW.writeStartElement(null, 'email', null);
				                   	    xmlW.writeCharacters(ent.email);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'email', null);
						    	
						    	if(!String.IsEmpty(ent.VatRegistration))
						    	{
							    	xmlW.writeStartElement(null, 'VatRegistration', null);
				                   	    xmlW.writeCharacters(ent.VatRegistration);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'VatRegistration', null);
						    	
						    	if(!String.IsEmpty(ent.PaymentTerms))
						    	{
							    	xmlW.writeStartElement(null, 'PaymentTerms', null);
				                   	    xmlW.writeCharacters(ent.PaymentTerms);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'PaymentTerms', null);
						    	
						    	if(!String.IsEmpty(ent.PaymentMethod))
						    	{
							    	xmlW.writeStartElement(null, 'PaymentMethod', null);
				                   	    xmlW.writeCharacters(ent.PaymentMethod);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'PaymentMethod', null);
						    	
						    	if(!String.IsEmpty(ent.PaymentTermsStdOrd))
						    	{
							    	xmlW.writeStartElement(null, 'PaymentTermsStdOrd', null);
				                   	    xmlW.writeCharacters(ent.PaymentTermsStdOrd);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'PaymentTermsStdOrd', null);
						    	
						    	if(!String.IsEmpty(ent.PaymentTermsFuelOrd))
						    	{
							    	xmlW.writeStartElement(null, 'PaymentTermsFuelOrd', null);
				                   	    xmlW.writeCharacters(ent.PaymentTermsFuelOrd);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'PaymentTermsFuelOrd', null);
						    	
						    	/*if(!String.IsEmpty(ent.PaymentTermsCrdCardOrd))
						    	{
							    	xmlW.writeStartElement(null, 'PaymentTermsCrdCardOrd', null);
				                   	    xmlW.writeCharacters(ent.PaymentTermsCrdCardOrd);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'PaymentTermsCrdCardOrd', null);
						    	*/
						    	if(!String.IsEmpty(ent.PaymentDays))
						    	{
							    	xmlW.writeStartElement(null, 'PaymentDays', null);
				                   	    xmlW.writeCharacters(ent.PaymentDays);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'PaymentDays', null);
						    	
						    	if(!String.IsEmpty(ent.NoPaymentDays))
						    	{
							    	xmlW.writeStartElement(null, 'NoPaymentDays', null);
				                   	    xmlW.writeCharacters(ent.NoPaymentDays);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'NoPaymentDays', null);

					    		//////
					    		if(!String.IsEmpty(ent.Comercial))
						    	{
							    	xmlW.writeStartElement(null, 'Comercial', null);
				                   	    xmlW.writeCharacters(ent.Comercial);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'Comercial', null);

								//gserrano se comenta porque se deja de usar este campo en Navision 06/03/2019
					    		/*if(!String.IsEmpty(ent.DOM_PROF))
						    	{
							    	xmlW.writeStartElement(null, 'DOM_PROF', null);
				                   	    xmlW.writeCharacters(ent.DOM_PROF);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'DOM_PROF', null);*/
					    		//////

					    		if(ent.eMailInvoice != null)
						    	{		
					                xmlW.writeStartElement(null, 'eMailInvoice', null);
					                   	xmlW.writeCharacters(String.valueOf(ent.eMailInvoice));
					                xmlW.writeEndElement();
						    	}
						    	else 
				    				xmlW.writeEmptyElement(null, 'eMailInvoice', null);
								
								if(!String.IsEmpty(ent.IBAN))
								{
									xmlW.writeStartElement(null, 'IBAN', null);
											xmlW.writeCharacters(ent.IBAN);
									xmlW.writeEndElement();
								}
								else 
									xmlW.writeEmptyElement(null, 'IBAN', null);
						    	
						    	if(!String.IsEmpty(ent.SalesForceId))
						    	{
							    	xmlW.writeStartElement(null, 'SalesForceId', null);
				                   	    xmlW.writeCharacters(ent.SalesForceId);
				                    xmlW.writeEndElement();
						    	}
						    	else 
						    		xmlW.writeEmptyElement(null, 'SalesForceId', null);
						    	
						    	if(ent.etAddres != null && ent.etAddres.size()>0)
						    	{
						    		for(SchemaCliente.etAddres addres : ent.etAddres)
							    	{
								    	xmlW.writeStartElement(null, 'etAddres', null);
								    	
						                if(!String.IsEmpty(addres.ADCode))
								    	{		
							                xmlW.writeStartElement(null, 'ADCode', null);
							                   	xmlW.writeCharacters(addres.ADCode);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADCode', null);
						    	
								    	if(!String.IsEmpty(addres.ADAddres))
								    	{		
							                xmlW.writeStartElement(null, 'ADAddres', null);
							                   	xmlW.writeCharacters(addres.ADAddres);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADAddres', null);
						    	
								    	if(!String.IsEmpty(addres.ADAddres2))
								    	{		
							                xmlW.writeStartElement(null, 'ADAddres2', null);
							                   	xmlW.writeCharacters(addres.ADAddres2);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADAddres2', null);
						    	
								    	if(!String.IsEmpty(addres.ADCity))
								    	{		
							                xmlW.writeStartElement(null, 'ADCity', null);
							                   	xmlW.writeCharacters(addres.ADCity);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADCity', null);
						    			
						    			if(!String.IsEmpty(addres.ADCounty))
								    	{		
							                xmlW.writeStartElement(null, 'ADCounty', null);
							                   	xmlW.writeCharacters(addres.ADCounty);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADCounty', null);
								    	if(!String.IsEmpty(addres.ADPostCode))
								    	{		
							                xmlW.writeStartElement(null, 'ADPostCode', null);
							                   	xmlW.writeCharacters(addres.ADPostCode);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADPostCode', null);
						    	
								    	if(!String.IsEmpty(addres.ADCountry))
								    	{		
							                xmlW.writeStartElement(null, 'ADCountry', null);
							                   	xmlW.writeCharacters(addres.ADCountry);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADCountry', null);

					    				//////
					    				if(!String.IsEmpty(addres.Activity1))
								    	{		
							                xmlW.writeStartElement(null, 'Activity1', null);
							                   	xmlW.writeCharacters(addres.Activity1);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'Activity1', null);

					    				if(!String.IsEmpty(addres.Activity2))
								    	{		
							                xmlW.writeStartElement(null, 'Activity2', null);
							                   	xmlW.writeCharacters(addres.Activity2);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'Activity2', null);
					    				if(addres.FixTemperature != null)
										{		
											xmlW.writeStartElement(null, 'FixTemperature', null);
										    	xmlW.writeCharacters(String.valueOf(addres.FixTemperature));
										    xmlW.writeEndElement();
										}
										else 
									    	xmlW.writeEmptyElement(null, 'FixTemperature', null);
					    				//////
						    	
								    	if(!String.IsEmpty(addres.ADCodePriceDiscount))
								    	{		
							                xmlW.writeStartElement(null, 'ADCodePriceDiscount', null);
							                   	xmlW.writeCharacters(addres.ADCodePriceDiscount);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADCodePriceDiscount', null);
						    	
						    			/*if(!String.IsEmpty(addres.ADStatus))
								    	{		
							                xmlW.writeStartElement(null, 'ADStatus', null);
							                   	xmlW.writeCharacters(addres.ADStatus);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADStatus', null);

						    			if(addres.ADBlocked != null)
								    	{		
							                xmlW.writeStartElement(null, 'ADBlocked', null);
							                   	xmlW.writeCharacters(String.valueOf(addres.ADBlocked));
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADBlocked', null);

						    			if(!String.IsEmpty(addres.ADBlockedReason))
								    	{		
							                xmlW.writeStartElement(null, 'ADBlockedReason', null);
							                   	xmlW.writeCharacters(addres.ADBlockedReason);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADBlockedReason', null);*/

								    	if(!String.IsEmpty(addres.ADSalesForceId))
								    	{		
							                xmlW.writeStartElement(null, 'ADSalesForceId', null);
							                   	xmlW.writeCharacters(addres.ADSalesForceId);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'ADSalesForceId', null);
						    	
						                xmlW.writeEndElement();
							    	}
						    	}
						    	
						    	if(ent.etDataBank != null && ent.etDataBank.size()>0)
						    	{
						    		for(SchemaCliente.etDataBank etBank : ent.etDataBank)
							    	{
								    	xmlW.writeStartElement(null, 'etDataBank', null);
						                if(!String.IsEmpty(etBank.BankCode))
								    	{		
							                xmlW.writeStartElement(null, 'BankCode', null);
							                   	xmlW.writeCharacters(etBank.BankCode);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'BankCode', null);
								    	
								    	if(!String.IsEmpty(etBank.BankIBAN))
								    	{		
							                xmlW.writeStartElement(null, 'BankIBAN', null);
							                   	xmlW.writeCharacters(etBank.BankIBAN);
							                xmlW.writeEndElement();
								    	}
								    	else 
						    				xmlW.writeEmptyElement(null, 'BankIBAN', null);
								    	
								    	if(!String.IsEmpty(etBank.BankSWIFT))
								    	{		
							                xmlW.writeStartElement(null, 'BankSWIFT', null);
							                   	xmlW.writeCharacters(etBank.BankSWIFT);
							                xmlW.writeEndElement();
								    	} 
								    	else 
						    				xmlW.writeEmptyElement(null, 'BankSWIFT', null);
								    	
						                xmlW.writeEndElement();
							    	}
						    	}
						    	
						    	xmlW.writeEndElement();
						    }
						}
						    
						xmlW.writeEndElement();
						//Creamos el entitySyncDto_OUT vacío
				    	xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
				   		xmlW.writeEmptyElement(null, 'etCustomer',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        System.debug('Body: '+mensaje);
        
        return mensaje;
    }
    
     //En este método se crea el xml de clientes, direcciones de entrega y datos bancarios
	//Para realizar la petición en el método de SincronizarClientes
    public static String generarXmlSincronizarContratos(SchemaContrato.entitySyncDto entidad) {
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_SINCRONIZAR_CONTRATOS, null);
					//LCS 01/2023: Se añade prefijo WSSF_ por cambio en BC
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WSSF_PGE_SF');
	        		xmlW.writeStartElement(null, 'entitySyncDto', null);
	        		if(entidad!=null && entidad.etContract!=null && entidad.etContract.size()>0)
	        		{
	        			for(SchemaContrato.etContract ent : entidad.etContract)
						{ 
						    xmlW.writeStartElement(null,'etContract',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_CONTRATO_SCHEMA);
					    	
						    if(!String.IsEmpty(ent.CustomerNavCode))
							{		
								xmlW.writeStartElement(null, 'CustomerNavCode', null);
							    	xmlW.writeCharacters(ent.CustomerNavCode);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'CustomerNavCode', null);
						    	
						    if(!String.IsEmpty(ent.ShiptoCode))
							{		
								xmlW.writeStartElement(null, 'ShiptoCode', null);
							    	xmlW.writeCharacters(ent.ShiptoCode);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ShiptoCode', null);
						    	
						    if(!String.IsEmpty(ent.ContractType))
							{		
								xmlW.writeStartElement(null, 'ContractType', null);
							    	xmlW.writeCharacters(ent.ContractType);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ContractType', null);
						    	
						    if(ent.ContractDurationTons != null)
							{		
								xmlW.writeStartElement(null, 'ContractDurationTons', null);
							    	xmlW.writeCharacters(String.valueOf(ent.ContractDurationTons));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ContractDurationTons', null);
						    	
						    if(ent.ContractDurationYears != null)
							{		
								xmlW.writeStartElement(null, 'ContractDurationYears', null);
							    	xmlW.writeCharacters(String.valueOf(ent.ContractDurationYears));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ContractDurationYears', null);
						    	
						    if(ent.PlannedConsumptionTons != null)
							{		
								xmlW.writeStartElement(null, 'PlannedConsumptionTons', null);
							    	xmlW.writeCharacters(String.valueOf(ent.PlannedConsumptionTons));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'PlannedConsumptionTons', null);
						    //////
						    if(!String.IsEmpty(ent.PaymentTermsServices))
							{		
								xmlW.writeStartElement(null, 'PaymentTermsServices', null);
							    	xmlW.writeCharacters(ent.PaymentTermsServices);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'PaymentTermsServices', null);

					    	if(!String.IsEmpty(ent.PaymentMetodServices))
							{		
								xmlW.writeStartElement(null, 'PaymentMetodServices', null);
							    	xmlW.writeCharacters(ent.PaymentMetodServices);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'PaymentMetodServices', null);

					    	if(!String.IsEmpty(ent.PaymentTermsFuel))
							{		
								xmlW.writeStartElement(null, 'PaymentTermsFuel', null);
							    	xmlW.writeCharacters(ent.PaymentTermsFuel);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'PaymentTermsFuel', null);

					    	if(!String.IsEmpty(ent.PaymentMethodFuel))
							{		
								xmlW.writeStartElement(null, 'PaymentMethodFuel', null);
							    	xmlW.writeCharacters(ent.PaymentMethodFuel);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'PaymentMethodFuel', null);
						    //////	
/*						    if(!String.IsEmpty(ent.CodePaymentTermsServices))
							{		
								xmlW.writeStartElement(null, 'CodePaymentTermsServices', null);
							    	xmlW.writeCharacters(ent.CodePaymentTermsServices);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'CodePaymentTermsServices', null);
*/						    	
						    if(!String.IsEmpty(ent.CodePaymentDay))
							{		
								xmlW.writeStartElement(null, 'CodePaymentDay', null);
							    	xmlW.writeCharacters(ent.CodePaymentDay);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'CodePaymentDay', null);
						    	
/*						    if(!String.IsEmpty(ent.CodePaymentServices))
							{		
								xmlW.writeStartElement(null, 'CodePaymentServices', null);
							    	xmlW.writeCharacters(ent.CodePaymentServices);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'CodePaymentServices', null);
*/						    
						    if(!String.IsEmpty(ent.ReminderTermsCode))
							{		
								xmlW.writeStartElement(null, 'ReminderTermsCode', null);
							    	xmlW.writeCharacters(ent.ReminderTermsCode);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ReminderTermsCode', null);
						    	
						    if(ent.DateFirstFill != null)
							{		
								xmlW.writeStartElement(null, 'DateFirstFill', null);
							    	xmlW.writeCharacters(String.valueOf(ent.DateFirstFill));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'DateFirstFill', null);
						    	
						    if(ent.DateCivilWork != null)
							{		
								xmlW.writeStartElement(null, 'DateCivilWork', null);
							    	xmlW.writeCharacters(String.valueOf(ent.DateCivilWork));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'DateCivilWork', null);
						    	
						    if(!String.IsEmpty(ent.Subcontractor))
							{		
								xmlW.writeStartElement(null, 'Subcontractor', null);
							    	xmlW.writeCharacters(ent.Subcontractor);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Subcontractor', null);
						    	
						    if(ent.CapacityTank != null)
							{		
								xmlW.writeStartElement(null, 'CapacityTank', null);
							    	xmlW.writeCharacters(String.valueOf(ent.CapacityTank));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'CapacityTank', null);
						    	
						    if(ent.Carburante != null)
							{		
								xmlW.writeStartElement(null, 'Carburante', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Carburante));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Carburante', null);
						    	
						    if(!String.IsEmpty(ent.TankType))
							{		
								xmlW.writeStartElement(null, 'TankType', null);
							    	xmlW.writeCharacters(ent.TankType);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'TankType', null);
						    	
						    if(ent.AmountDepo!=null)
							{		
								xmlW.writeStartElement(null, 'AmountDepo', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountDepo));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountDepo', null);
						    	
						    if(ent.AmountINEX!=null)
							{		
								xmlW.writeStartElement(null, 'AmountINEX', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountINEX));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountINEX', null);
						    	
						    if(ent.AmountININ!=null)
							{		
								xmlW.writeStartElement(null, 'AmountININ', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountININ));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountININ', null);
						    	
						    if(ent.AmountOC!=null)
							{		
								xmlW.writeStartElement(null, 'AmountOC', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountOC));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountOC', null);
						    	
						    if(ent.AmountEquipment!=null)
							{		
								xmlW.writeStartElement(null, 'AmountEquipment', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountEquipment));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountEquipment', null);
						    	
						    if(ent.AmountProyect!=null)
							{		
								xmlW.writeStartElement(null, 'AmountProyect', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountProyect));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountProyect', null);
						    	
						    if(ent.dpcadmin1!=null)
							{		
								xmlW.writeStartElement(null, 'dpcadmin1', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dpcadmin1));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dpcadmin1', null);
						    	
						    if(ent.dpcadmin2!=null)
							{		
								xmlW.writeStartElement(null, 'dpcadmin2', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dpcadmin2));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dpcadmin2', null);
						    	
						    if(ent.dpcadmin3!=null)
							{		
								xmlW.writeStartElement(null, 'dpcadmin3', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dpcadmin3));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dpcadmin3', null);
						    	
						    if(ent.dpcadmin4!=null)
							{		
								xmlW.writeStartElement(null, 'dpcadmin4', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dpcadmin4));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dpcadmin4', null);
						    	
						    if(ent.dpcadmin5!=null)
							{		
								xmlW.writeStartElement(null, 'dpcadmin5', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dpcadmin5));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dpcadmin5', null);
						    	
						    if(ent.dpcadmin6!=null)
							{		
								xmlW.writeStartElement(null, 'dpcadmin6', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dpcadmin6));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dpcadmin6', null);
						    	
						    if(!String.IsEmpty(ent.Tariff))
							{		
								xmlW.writeStartElement(null, 'Tariff', null);
							    	xmlW.writeCharacters(ent.Tariff);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Tariff', null);
						    	
						    if(ent.Dto1 != null)
							{		
								xmlW.writeStartElement(null, 'Dto1', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto1));
							    xmlW.writeEndElement();
							} 
							else 
						    	xmlW.writeEmptyElement(null, 'Dto1', null);
						    	
						    if(ent.Dto2 != null)
							{		
								xmlW.writeStartElement(null, 'Dto2', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto2));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto2', null);
						    	
						    if(ent.Dto3 != null)
							{		
								xmlW.writeStartElement(null, 'Dto3', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto3));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto3', null);
						    	
						    if(ent.Dto4 != null)
							{		
								xmlW.writeStartElement(null, 'Dto4', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto4));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto4', null);
						    	
						    if(ent.Dto5 != null)
							{		
								xmlW.writeStartElement(null, 'Dto5', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto5));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto5', null);
						    	
						    if(ent.Dto6 != null)
							{		
								xmlW.writeStartElement(null, 'Dto6', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto6));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto6', null);
						    	
						    if(!String.IsEmpty(ent.TPinstallationType))
							{		
								xmlW.writeStartElement(null, 'TPinstallationType', null);
							    	xmlW.writeCharacters(ent.TPinstallationType);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'TPinstallationType', null);
						    	
						    if(ent.Dto1kg!=null)
							{		
								xmlW.writeStartElement(null, 'Dto1kg', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto1kg));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto1kg', null);
						    	
						    if(ent.Dto2kg!=null)
							{		
								xmlW.writeStartElement(null, 'Dto2kg', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto2kg));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto2kg', null);
						    	
						    if(ent.Dto3kg!=null)
							{		
								xmlW.writeStartElement(null, 'Dto3kg', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto3kg));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto3kg', null);
						    	
						    if(ent.Dto4kg!=null)
							{		
								xmlW.writeStartElement(null, 'Dto4kg', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto4kg));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto4kg', null);
						    	
						    if(ent.Dto5kg!=null)
							{		
								xmlW.writeStartElement(null, 'Dto5kg', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto5kg));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto5kg', null);

						    if(ent.Dto6kg!=null)
							{		
								xmlW.writeStartElement(null, 'Dto6kg', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto6kg));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto6kg', null);
						    	
						    if(ent.Services!=null)
							{		
								xmlW.writeStartElement(null, 'Services', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Services));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Services', null);
						    	
						    if(ent.dcmpropano1!=null)
							{		
								xmlW.writeStartElement(null, 'dcmpropano1', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dcmpropano1));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dcmpropano1', null);
						    	
						    if(ent.dcmpropano2!=null)
							{		
								xmlW.writeStartElement(null, 'dcmpropano2', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dcmpropano2));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dcmpropano2', null);
						    	
						    if(ent.dcmpropano3!=null)
							{		
								xmlW.writeStartElement(null, 'dcmpropano3', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dcmpropano3));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dcmpropano3', null);
						    	
						    if(ent.dcmpropano4!=null)
							{		
								xmlW.writeStartElement(null, 'dcmpropano4', null);
							    	xmlW.writeCharacters(String.valueOf(ent.dcmpropano4));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'dcmpropano4', null);
						    	
						    if(ent.AmountServices!=null)
							{		
								xmlW.writeStartElement(null, 'AmountServices', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountServices));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountServices', null);
						    	
						    if(ent.Dto1Year!=null)
							{		
								xmlW.writeStartElement(null, 'Dto1Year', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto1Year));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto1Year', null);
						    	
						    if(ent.Dto2Year!=null)
							{		
								xmlW.writeStartElement(null, 'Dto2Year', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto2Year));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto2Year', null);
						    	
						    if(ent.Dto3Year!=null)
							{		
								xmlW.writeStartElement(null, 'Dto3Year', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto3Year));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto3Year', null);
						    	
						    if(ent.Dto4Year!=null)
							{		
								xmlW.writeStartElement(null, 'Dto4Year', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Dto4Year));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Dto4Year', null);
						    	
						    if(ent.AmountContractManagement!=null)
							{		
								xmlW.writeStartElement(null, 'AmountContractManagement', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountContractManagement));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountContractManagement', null);
						    	
						    if(ent.GasMeterRentAmount!=null)
							{		
								xmlW.writeStartElement(null, 'GasMeterRentAmount', null);
							    	xmlW.writeCharacters(String.valueOf(ent.GasMeterRentAmount));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'GasMeterRentAmount', null);
						    	
						    if(ent.AmountSAU!=null)
							{		
								xmlW.writeStartElement(null, 'AmountSAU', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountSAU));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountSAU', null);
						    	
						    if(ent.ImporteDerechosAlta!=null)
							{		
								xmlW.writeStartElement(null, 'ImporteDerechosAlta', null);
							    	xmlW.writeCharacters(String.valueOf(ent.ImporteDerechosAlta));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ImporteDerechosAlta', null);
						    	
						    if(ent.ImporteDerechosAcometida!=null)
							{		
								xmlW.writeStartElement(null, 'ImporteDerechosAcometida', null);
							    	xmlW.writeCharacters(String.valueOf(ent.ImporteDerechosAcometida));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ImporteDerechosAcometida', null);
						    	
						    if(ent.AmountFixTerm!=null)
							{		
								xmlW.writeStartElement(null, 'AmountFixTerm', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountFixTerm));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountFixTerm', null);

							if(ent.AmountForfait!=null)
							{		
								xmlW.writeStartElement(null, 'AmountForfait', null);
							    	xmlW.writeCharacters(String.valueOf(ent.AmountForfait));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'AmountForfait', null);
						    	
							//cambios iescalante
							if(ent.AmountPrima != null)
							{
								xmlW.writeStartElement(null, 'AmountPrima', null);
								xmlW.writeCharacters(String.valueOf(ent.AmountPrima));

							    xmlW.writeEndElement();
							}
							else 
								xmlW.writeEmptyElement(null, 'AmountPrima', null);


						    if(ent.WaterAvailable!=null)
							{		
								xmlW.writeStartElement(null, 'WaterAvailable', null);
							    	xmlW.writeCharacters(String.valueOf(ent.WaterAvailable));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'WaterAvailable', null);
						    	
						    if(!String.IsEmpty(ent.Promotor))
							{		
								xmlW.writeStartElement(null, 'Promotor', null);
							    	xmlW.writeCharacters(ent.Promotor);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Promotor', null);
						    	
						    if(!String.IsEmpty(ent.ConsumptionProfile))
							{		
								xmlW.writeStartElement(null, 'ConsumptionProfile', null);
							    	xmlW.writeCharacters(ent.ConsumptionProfile);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ConsumptionProfile', null);
						    	
						    if(!String.IsEmpty(ent.ContractedProduct))
							{		
								xmlW.writeStartElement(null, 'ContractedProduct', null);
							    	xmlW.writeCharacters(ent.ContractedProduct);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'ContractedProduct', null);
						    	
						    if(!String.IsEmpty(ent.Segment1))
							{		
								xmlW.writeStartElement(null, 'Segment1', null);
							    	xmlW.writeCharacters(ent.Segment1);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Segment1', null);
						    	
						    if(!String.IsEmpty(ent.Segment2))
							{		
								xmlW.writeStartElement(null, 'Segment2', null);
							    	xmlW.writeCharacters(ent.Segment2);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Segment2', null);
						    	
						    if(ent.Primaconta!=null)
							{		
								xmlW.writeStartElement(null, 'Primaconta', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Primaconta));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Primaconta', null);
						    
						    if(ent.Telemedida!=null)
							{		
								xmlW.writeStartElement(null, 'Telemedida', null);
							    	xmlW.writeCharacters(String.valueOf(ent.Telemedida));
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'Telemedida', null);

						    if(!String.IsEmpty(ent.CanalizadoPromotor))
							{		
								xmlW.writeStartElement(null, 'CanalizadoPromotor', null);
							    	xmlW.writeCharacters(ent.CanalizadoPromotor);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'CanalizadoPromotor', null);
						    //////
						    if(!String.IsEmpty(ent.TruckType))
							{		
								xmlW.writeStartElement(null, 'TruckType', null);
							    	xmlW.writeCharacters(ent.TruckType);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'TruckType', null);

					    	if(!String.IsEmpty(ent.DeliveryItem))
							{		
								xmlW.writeStartElement(null, 'DeliveryItem', null);
							    	xmlW.writeCharacters(ent.DeliveryItem);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'DeliveryItem', null);						    
						    //////	
						    //
						    if(!String.IsEmpty(ent.BankIBAN))
							{		
								xmlW.writeStartElement(null, 'BankIBAN', null);
							    	xmlW.writeCharacters(ent.BankIBAN);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'BankIBAN', null);

						    if(!String.IsEmpty(ent.BankSWIFT))
							{		
								xmlW.writeStartElement(null, 'BankSWIFT', null);
							    	xmlW.writeCharacters(ent.BankSWIFT);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'BankSWIFT', null);

						    if(!String.IsEmpty(ent.ModalidadInstalacion))
							{		
								xmlW.writeStartElement(null, 'ModalidadInstalacion', null);
							    	xmlW.writeCharacters(ent.ModalidadInstalacion);
							    xmlW.writeEndElement();
							}
							else 
							{
						    	xmlW.writeEmptyElement(null, 'ModalidadInstalacion', null);
							}    

							//Añadido por gserrano 20/12/2018
							if(ent.SplitFirstPaymentIn3!=null)
							{	
								xmlW.writeStartElement(null, 'SplitFirstPaymentIn3', null);
							    	xmlW.writeCharacters(String.valueOf(ent.SplitFirstPaymentIn3));
							    xmlW.writeEndElement();
								
							}
							else 
							{
						    	xmlW.writeEmptyElement(null, 'SplitFirstPaymentIn3', null);
							}  

							//Cambios rfernandez (12/07/2017)
							
							if(!String.IsEmpty(ent.OldCustomerNavCode))
							{		
								xmlW.writeStartElement(null, 'OldCustomerNavCode', null);
							    	xmlW.writeCharacters(ent.OldCustomerNavCode);
							    xmlW.writeEndElement();
							}
							else 
							{
						    	xmlW.writeEmptyElement(null, 'OldCustomerNavCode', null);
							}
							if(!String.IsEmpty(ent.OldShiptoCode))
							{		
								xmlW.writeStartElement(null, 'OldShiptoCode', null);
							    	xmlW.writeCharacters(ent.OldShiptoCode);
							    xmlW.writeEndElement();
							}
							else 
							{
						    	xmlW.writeEmptyElement(null, 'OldShiptoCode', null);
							}
							if(ent.LastMeterReading != null)
							{		
								xmlW.writeStartElement(null, 'LastMeterReading', null);
							    	xmlW.writeCharacters(String.valueOf(ent.LastMeterReading));
							    xmlW.writeEndElement();
							}
							else 
							{
						    	xmlW.writeEmptyElement(null, 'LastMeterReading', null);
							}
							//Fin cambios rfernandez
						    //
						    if(!String.IsEmpty(ent.IDSalesForce))
							{		
								xmlW.writeStartElement(null, 'IDSalesForce', null);
							    	xmlW.writeCharacters(ent.IDSalesForce);
							    xmlW.writeEndElement();
							}
							else 
						    	xmlW.writeEmptyElement(null, 'IDSalesForce', null);
						    	
							xmlW.writeEndElement();
						}
					}
						    
					xmlW.writeEndElement();
					//Creamos el entitySyncDto_OUT vacío
				    xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
				   	xmlW.writeEmptyElement(null, 'etContract',null);
					    xmlW.writeAttribute(null, null,'xmlns',WS_CONTRATO_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        System.debug('Body: '+mensaje);
        
        return mensaje;
    }
    
    public static String generarXmlConsultarTarifas() {
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_CONSULTAR_TARIFAS, null);
					//LCS 01/2023: Se añade prefijo WSSF_ por cambio en BC
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WSSF_PGE_SF');
						//Creamos el entitySyncDto vacío
				    	/*xmlW.writeStartElement(null, 'entitySyncDto', null);
				   		xmlW.writeEmptyElement(null, 'etTarifa',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_TARIFA_SCHEMA);
				    xmlW.writeEndElement();*/
				    xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
				   		xmlW.writeEmptyElement(null, 'etTarifa',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_TARIFA_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        
        //String mensaje25 = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><Nav2sfdc_Tarifas xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto_OUT><etTarifa xmlns="urn:microsoft-dynamics-nav/xmlports/x50053" /></entitySyncDto_OUT></Nav2sfdc_Tarifas></soap:Body></soap:Envelope>';
        
		System.debug('Body: ' + mensaje);
        return mensaje;
    }
    
    public static String generarXmlConsultarClientes() { 
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_CONSULTAR_CLIENTES, null);
					//LCS 01/2023: Se añade prefijo WSSF_ por cambio en BC
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WSSF_PGE_SF');
						//Creamos el entitySyncDto vacío
				    	/*xmlW.writeStartElement(null, 'entitySyncDto', null);
				   		xmlW.writeEmptyElement(null, 'etCustomer',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
				    xmlW.writeEndElement();*/
				    xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
				   		xmlW.writeEmptyElement(null, 'etCustomer',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        //String mensaje8 = '<?xml version="1.0" encoding="UTF-8"?><Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/"><Soap:Body><Nav2sfdc_ConsultarClientes xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto_OUT><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"></etCustomer></entitySyncDto_OUT></Nav2sfdc_ConsultarClientes></Soap:Body></Soap:Envelope>';
        
		System.debug('Body: ' + mensaje);
        return mensaje;
    }

    // ------------------------------------------------Nuevos objetos para integrar -------------------------------------------------------------------------------------------------
	//Pedidos de gas
	public static String generarXmlEnviarPedidosGas(Pedido_de_gas__c pedidoGas) 
	{
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        //xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        //xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
	    	xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WS_App');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, 'App_Order', null);
				    	
			    		if(!String.IsEmpty(pedidoGas.Direccion_de_entrega__r.cuenta__r.Id_navision__c))
				    	{
							System.debug('@@@@@ info cuenta ' + pedidoGas.Direccion_de_entrega__r.cuenta__r.Id_navision__c);
					    	xmlW.writeStartElement(null, 'codPrmCliente', null);
		                   	    xmlW.writeCharacters(pedidoGas.Direccion_de_entrega__r.cuenta__r.Id_navision__c);
		                    xmlW.writeEndElement();
				    	}
				    	else 
				    		xmlW.writeEmptyElement(null, 'codPrmCliente', null);
			    	
				    	if(!String.IsEmpty(pedidoGas.Direccion_de_entrega__r.Id_navision__c))
				    	{
					    	xmlW.writeStartElement(null, 'codPrmshipto', null);
		                   	    xmlW.writeCharacters(pedidoGas.Direccion_de_entrega__r.Id_navision__c);
		                    xmlW.writeEndElement();
				    	}
				    	else 
				    		xmlW.writeEmptyElement(null, 'codPrmshipto', null);
				    	
				    	if(!String.IsEmpty(String.valueOf(pedidoGas.Nivel_del_deposito__c)))
				    	{
					    	xmlW.writeStartElement(null, 'intPrmLevel', null);
		                   	    xmlW.writeCharacters(String.valueOf(pedidoGas.Nivel_del_deposito__c));
		                    xmlW.writeEndElement();
				    	}
				    	else 
				    		xmlW.writeEmptyElement(null, 'intPrmLevel', null);
				    	
				    	if(!String.IsEmpty(pedidoGas.Comentarios__c))
				    	{
					    	xmlW.writeStartElement(null, 'txtPrmComentario', null);
		                   	    xmlW.writeCharacters(pedidoGas.Comentarios__c);
		                    xmlW.writeEndElement();
				    	}
				    	else 
				    		xmlW.writeEmptyElement(null, 'txtPrmComentario', null);


				    	xmlW.writeStartElement(null, 'codPrmLanguage', null);
	                   	    xmlW.writeCharacters('ESP');
	                    xmlW.writeEndElement();
	    	

				    	xmlW.writeStartElement(null, 'txtPrmMessage', null);
	                   	    xmlW.writeCharacters('Datos');
	                    xmlW.writeEndElement();
	

			   	 	xmlW.writeEndElement();
						    
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        System.debug('Body: '+mensaje);
        
        return mensaje;
    }

    //Metodo encargado de parsear la respuesta para ver si el registro se ha creado correctamente en Nav.
    public static Boolean parsearRespuestaEnviarPedidosGas(HttpResponse res) 
	{
		Dom.Document doc = res.getBodyDocument();
		Boolean respuesta = false;

    	for(dom.XmlNode nodoRaiz : doc.getRootElement().getChildElements())
    	{
    		System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == 'Fault')
		    		{	
		    			respuesta = false;
		    		}else if (nodo.getName() == 'App_Order_Result')
		    		{
		    			respuesta = true;
		    		}
    			}
    		}
    	} 
    	
    	    	
    	return respuesta;
	}

	//Lecturas Contador
	public static String generarXmlEnviarLecturasContador(Lectura_contador__c lecturaContador) 
	{
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        //xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        //xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
	    	xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WS_App');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, 'App_ReadingCustAddress', null);
				    	
			    		if(!String.IsEmpty(lecturaContador.Direccion_de_entrega__r.cuenta__r.Id_navision__c))
				    	{
					    	xmlW.writeStartElement(null, 'codPrmCliente', null);
		                   	    xmlW.writeCharacters(lecturaContador.Direccion_de_entrega__r.cuenta__r.Id_navision__c);
		                    xmlW.writeEndElement();
				    	}
				    	else 
				    		xmlW.writeEmptyElement(null, 'codPrmCliente', null);
			    	
				    	if(!String.IsEmpty(lecturaContador.Direccion_de_entrega__r.Id_navision__c))
				    	{
					    	xmlW.writeStartElement(null, 'codPrmshipto', null);
		                   	    xmlW.writeCharacters(lecturaContador.Direccion_de_entrega__r.Id_navision__c);
		                    xmlW.writeEndElement();
				    	}
				    	else 
				    		xmlW.writeEmptyElement(null, 'codPrmshipto', null);
				    	
				    	if(!String.IsEmpty(String.valueOf(lecturaContador.Lectura__c)))
				    	{
					    	xmlW.writeStartElement(null, 'intPrmLectura', null);
		                   	    xmlW.writeCharacters(String.valueOf(lecturaContador.Lectura__c));
		                    xmlW.writeEndElement();
				    	}
				    	else 
				    		xmlW.writeEmptyElement(null, 'intPrmLectura', null);
				    	
				    	xmlW.writeStartElement(null, 'txtPrmMessage', null);
	                   	    xmlW.writeCharacters('Datos');
	                    xmlW.writeEndElement();

			   	 	xmlW.writeEndElement();
						    
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        System.debug('Body: '+mensaje);
        
        return mensaje;
    }

    //Metodo encargado de parsear la respuesta para ver si el registro se ha creado correctamente en Nav.
    public static Boolean parsearRespuestaEnviarLecturasContador(HttpResponse res) 
	{
		Dom.Document doc = res.getBodyDocument();
		Boolean respuesta = false;

    	for(dom.XmlNode nodoRaiz : doc.getRootElement().getChildElements())
    	{
    		System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == 'Fault')
		    		{	
		    			respuesta = false;
		    		}else if (nodo.getName() == 'App_ReadingCustAddress_Result')
		    		{
		    			respuesta = true;
		    		}
    			}
    		}
    	}   	
    	return respuesta;
	}


	//Consulta de pedidos de gas 
    public static String generarXmlConsultarPedidosGas(String idNavCliente) 
    { 
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns', 'urn:microsoft-dynamics-schemas/page/salesorders');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, 'ReadMultiple', null);
				    xmlW.writeStartElement(null, 'filter', null);
				    	
				    	xmlW.writeStartElement(null, 'Field', null);
	                   	    xmlW.writeCharacters('Bill_to_Customer_No');
	                    xmlW.writeEndElement();


				    	xmlW.writeStartElement(null, 'Criteria', null);
	                   	    xmlW.writeCharacters(idNavCliente);
	                    xmlW.writeEndElement();


				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        
		System.debug('Body: ' + mensaje);
        return mensaje;
    } 

    //Consulta de lecturas contador
    public static String generarXmlConsultarLecturasContador(String idNavCliente) 
    { 
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns', 'urn:microsoft-dynamics-schemas/page/meterreading');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, 'ReadMultiple', null);
				    xmlW.writeStartElement(null, 'filter', null);
				    	
				    	xmlW.writeStartElement(null, 'Field', null);
	                   	    xmlW.writeCharacters('Customer_No');
	                    xmlW.writeEndElement();


				    	xmlW.writeStartElement(null, 'Criteria', null);
	                   	    xmlW.writeCharacters(idNavCliente);//'91200157'
	                    xmlW.writeEndElement();


				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        
		System.debug('Body: ' + mensaje);
        return mensaje;
    } 

    //Parseamos las respuestas de las peticiones para obtener las lecturas y los pedidos, creando listas de los objetos correspondientes que
    //seran mostradas en la visualforce de cada uno
    public static List<Pedido_de_gas__c> parsearRespuestaConsultarPedidosGas(HttpResponse res) 
	{

		System.debug(' before parsearRespuestaConsultarPedidosGas');
		List<Pedido_de_gas__c> pedidosGasNav = new List<Pedido_de_gas__c>();

    	Dom.Document documentoPedidosGas = res.getBodyDocument();

    	for(dom.XmlNode nodoRaiz : documentoPedidosGas.getRootElement().getChildElements())
    	{
    		System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == 'ReadMultiple_Result')
		    		{
		    			for(dom.XmlNode nodoHijo : nodo.getChildElements())
		    			{
		    				System.debug('nodoHijo: '+nodoHijo.getName());
		    				if(nodoHijo.getName() == 'ReadMultiple_Result')
		    				{
		    					for(dom.XmlNode nodoNieto : nodoHijo.getChildElements())
		    					{
				    				System.debug('nodoNieto: ' + nodoNieto.getName());
				    				if(nodoNieto.getName() == 'SalesOrders')
				    				{
				    					Pedido_de_gas__c pedido = new Pedido_de_gas__c();
				    					for(dom.XmlNode nodoBisNieto : nodoNieto.getChildElements())
				    					{ 
						    				//System.debug('nodoBisNieto - Nombre: ' + nodoBisNieto.getName());
						    				if(nodoBisNieto.getName() == 'No')
							    			{
						    					pedido.Codigo__c = nodoBisNieto.getText();
							    			}  
							    			else if(nodoBisNieto.getName() == 'Posting_Date')
							    			{
						    					pedido.Fecha__c = Date.valueOf(nodoBisNieto.getText());
							    			}
							    			else if(nodoBisNieto.getName() == 'Status')
							    			{
						    					pedido.Status__c = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Ship_to_Code')
							    			{
						    					pedido.Id_Navision_Direccion_de_entrega__c = nodoBisNieto.getText();
							    			}
				    					}
				    					
				    					pedidosGasNav.add(pedido);
				    				}
		    					}
		    				}
		    			}
		    		}
    			}
    		}
    	} 
		return pedidosGasNav;
	}

	public static List<Lectura_contador__c> parsearRespuestaConsultarLecturasContador(HttpResponse res) 
	{
		System.debug(' before parsearRespuestaConsultarLecturasContador');
		List<Lectura_contador__c> lecturasContadorNav = new List<Lectura_contador__c>();

    	Dom.Document documentoPedidosGas = res.getBodyDocument();

    	for(dom.XmlNode nodoRaiz : documentoPedidosGas.getRootElement().getChildElements())
    	{
    		System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == 'ReadMultiple_Result')
		    		{
		    			for(dom.XmlNode nodoHijo : nodo.getChildElements())
		    			{
		    				System.debug('nodoHijo: '+nodoHijo.getName());
		    				if(nodoHijo.getName() == 'ReadMultiple_Result')
		    				{
		    					for(dom.XmlNode nodoNieto : nodoHijo.getChildElements())
		    					{
				    				System.debug('nodoNieto: ' + nodoNieto.getName());
				    				if(nodoNieto.getName() == 'MeterReading')
				    				{
				    					Lectura_contador__c lectura = new Lectura_contador__c();
				    					for(dom.XmlNode nodoBisNieto : nodoNieto.getChildElements())
				    					{ 
						    				//System.debug('nodoBisNieto - Nombre: ' + nodoBisNieto.getName() + ', Valor: ' + nodoBisNieto.getText() );
						    				if(nodoBisNieto.getName() == 'Ending_Date')
							    			{
						    					lectura.Fecha__c = Date.valueOf(nodoBisNieto.getText());
							    			}  
							    			else if(nodoBisNieto.getName() == 'End_Reading')
							    			{
						    					lectura.Lectura__c = Decimal.valueOf(nodoBisNieto.getText());
							    			}
							    			else if(nodoBisNieto.getName() == 'Source')
							    			{
						    					lectura.Origen__c = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Ship_to_Address_Code')
							    			{
						    					lectura.Id_Navision_Direccion_de_entrega__c = nodoBisNieto.getText();
							    			}
				    					}
				    					
				    					lecturasContadorNav.add(lectura);
				    				}
		    					}
		    				}
		    			}
		    		}
    			}
    		}
    	} 

		return lecturasContadorNav;
	}

    // ------------------------------------------------Actualizacion diaria de clientes y direcciones de entrega--------------------------------------------------------------------------
    public static String generarXmlConsultarClientesYDireccionesEntrega() 
    {
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_DETALLE_CLIENTES, null);
					//LCS 01/2023: Se añade prefijo WSSF_ por cambio en BC
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/WSSF_PGE_SF');
				    xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
				   		xmlW.writeEmptyElement(null, 'etDetailCustomer',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_DETALLE_CLIENTE_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        
		System.debug('Body: ' + mensaje);
        return mensaje;
    }

    public static List<SchemaClientesDiarios.etDetailCustomer> parsearRespuestaConsultarClientesYDireccionesEntrega(HttpResponse res) 
	{
		System.debug(' before parsearRespuestaConsultarClientesYDireccionesEntrega');
    	List<SchemaClientesDiarios.etDetailCustomer> listaEtDetailCustomers = new List<SchemaClientesDiarios.etDetailCustomer>();
    	Dom.Document documentoClientesYDirEntrega = res.getBodyDocument();
    	//System.debug('documentoClientesYDirEntrega: '+documentoClientesYDirEntrega);
    	for(dom.XmlNode nodoRaiz : documentoClientesYDirEntrega.getRootElement().getChildElements())
    	{
    		//System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		//System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == 'Nav2sfdc_DetailCustomer_Result')
		    		{
		    			for(dom.XmlNode nodoHijo : nodo.getChildElements())
		    			{
		    				//System.debug('nodoHijo: '+nodoHijo.getName());
		    				if(nodoHijo.getName() == 'entitySyncDto_OUT')
		    				{
		    					for(dom.XmlNode nodoNieto : nodoHijo.getChildElements())
		    					{
				    				//System.debug('nodoNieto: ' + nodoNieto.getName());
				    				if(nodoNieto.getName() == 'etDetailCustomer')
				    				{
				    					SchemaClientesDiarios.etDetailCustomer etDetailCustomer = new SchemaClientesDiarios.etDetailCustomer();
				    					for(dom.XmlNode nodoBisNieto : nodoNieto.getChildElements())
				    					{ 
						    				//System.debug('nodoBisNieto - Nombre: ' + nodoBisNieto.getName() + ', Valor: ' + nodoBisNieto.getText() );
						    				if(nodoBisNieto.getName() == 'CustomerNo')
							    			{
						    					etDetailCustomer.CustomerNo = nodoBisNieto.getText();
							    			}  
							    			else if(nodoBisNieto.getName() == 'ShiptTo')
							    			{
						    					etDetailCustomer.ShiptTo = nodoBisNieto.getText();
							    			}
					    					else if(nodoBisNieto.getName() == 'CalcDate')
							    			{
						    					String fechaCalcDateString = nodoBisNieto.getText();
												Date fechaCalcDateDate;
												//Comprobamos el formato de la fecha para ver si viene de una de estas formas 08-02-2018 o 2018-02-08
												if(fechaCalcDateString.left(3).contains('-') && !fechaCalcDateString.right(4).contains('-'))
												{
													List<String> fechaCalcDateList = fechaCalcDateString.split('-');
													String dia 	= fechaCalcDateList[0];
													String mes 	= fechaCalcDateList[1];
													String anyo	= fechaCalcDateList[2];
													
													fechaCalcDateDate = Date.valueOf(anyo+'-'+mes+'-'+dia);
													
												}else if(!fechaCalcDateString.left(4).contains('-') && fechaCalcDateString.right(3).contains('-'))
												{
													fechaCalcDateDate = Date.valueOf(fechaCalcDateString);
												}
												if(fechaCalcDateDate != null)
												{
													etDetailCustomer.CalcDate = fechaCalcDateDate;	
												}
							    			}
							    			else if(nodoBisNieto.getName() == 'SaldoVivo')
							    			{
						    					etDetailCustomer.SaldoVivo = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'SaldoPendiente')
							    			{
						    					etDetailCustomer.SaldoPendiente = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'AlertaBloqueo')
							    			{
						    					etDetailCustomer.AlertaBloqueo = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'ConsumoPrevistoKgs')
							    			{
						    					etDetailCustomer.ConsumoPrevistoKgs = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'ConsumoPromedioLast3y')
							    			{
						    					etDetailCustomer.ConsumoPromedioLast3y = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'ConsumoPromedioLast12m')
							    			{
						    					etDetailCustomer.ConsumoPromedioLast12m = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'ActualPrice')
							    			{
						    					etDetailCustomer.ActualPrice = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Discounts')
							    			{
						    					etDetailCustomer.Discounts = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'BocaCarga')
							    			{
						    					etDetailCustomer.BocaCarga = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'EstadoBocaCarga')
							    			{
						    					etDetailCustomer.EstadoBocaCarga = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Deposito')
							    			{
						    					etDetailCustomer.Deposito = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'EstadoDeposito')
							    			{
						    					etDetailCustomer.EstadoDeposito = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'Telemedida')
							    			{
						    					etDetailCustomer.Telemedida = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'EstadoTelemedida')
							    			{
						    					etDetailCustomer.EstadoTelemedida = nodoBisNieto.getText();
							    			}
							    			else if(nodoBisNieto.getName() == 'PropiedadTanque')
							    			{
						    					etDetailCustomer.PropiedadTanque = nodoBisNieto.getText();
							    			} 
				    					}
				    					
				    					listaEtDetailCustomers.add(etDetailCustomer);
				    				}
		    					}
		    				}
		    			}
		    		}
    			}
    		}
    	} 
    	
    	return listaEtDetailCustomers;
	}


	// ------------------------------------------------Consulta y confirmacion de facturas---------------------------------------------------------------------------------
    /*public static String generarXmlConsultarClientesYDireccionesEntrega() 
    {
    	Xmlstreamwriter xmlW = new Xmlstreamwriter();
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_DETALLE_CLIENTES, null);
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/PGE_SF');
				    xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
				   		xmlW.writeEmptyElement(null, 'etDetailCustomer',null);
					    	xmlW.writeAttribute(null, null,'xmlns',WS_DETALLE_CLIENTE_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        
		System.debug('Body: ' + mensaje);
        return mensaje;
    }

    public static List<> parsearRespuestaConsultarFacturas(HttpResponse res) 
	{
		System.debug(' before parsearRespuestaConsultarFacturas');
    	List<SchemaClientesDiarios.etDetailCustomer> listaEtDetailCustomers = new List<SchemaClientesDiarios.etDetailCustomer>();
    	Dom.Document documentoClientesYDirEntrega = res.getBodyDocument();
    	//System.debug('documentoClientesYDirEntrega: '+documentoClientesYDirEntrega);
    	for(dom.XmlNode nodoRaiz : documentoClientesYDirEntrega.getRootElement().getChildElements())
    	{
    		//System.debug('nodoRaiz: '+nodoRaiz.getName());
    		if(nodoRaiz.getName() == 'body')
    		{
    			for(dom.XmlNode nodo : nodoRaiz.getChildElements())
    			{
		    		//System.debug('Nodo: '+nodo.getName());
		    		if(nodo.getName() == WS_METHOD_CONSULTAR_FACTURAS)
		    		{
		    			for(dom.XmlNode nodoHijo : nodo.getChildElements())
		    			{
		    				//System.debug('nodoHijo: '+nodoHijo.getName());
		    				if(nodoHijo.getName() == 'entitySyncDto_OUT')
		    				{
		    					for(dom.XmlNode nodoNieto : nodoHijo.getChildElements())
		    					{
				    				//System.debug('nodoNieto: ' + nodoNieto.getName());
				    				if(nodoNieto.getName() == 'etDetailCustomer')
				    				{
				    					SchemaClientesDiarios.etDetailCustomer etDetailCustomer = new SchemaClientesDiarios.etDetailCustomer();
				    					for(dom.XmlNode nodoBisNieto : nodoNieto.getChildElements())
				    					{ 
						    				//System.debug('nodoBisNieto - Nombre: ' + nodoBisNieto.getName() + ', Valor: ' + nodoBisNieto.getText() );
						    				if(nodoBisNieto.getName() == 'CustomerNo')
							    			{
						    					etDetailCustomer.CustomerNo = nodoBisNieto.getText();
							    			}  
							    			else if(nodoBisNieto.getName() == 'ShiptTo')
							    			{
						    					etDetailCustomer.ShiptTo = nodoBisNieto.getText();
							    			}
					    					else if(nodoBisNieto.getName() == 'CalcDate')
							    			{
						    					String fechaCalcDateString = nodoBisNieto.getText();
												Date fechaCalcDateDate;
												//Comprobamos el formato de la fecha para ver si viene de una de estas formas 08-02-2018 o 2018-02-08
												if(fechaCalcDateString.left(3).contains('-') && !fechaCalcDateString.right(4).contains('-'))
												{
													List<String> fechaCalcDateList = fechaCalcDateString.split('-');
													String dia 	= fechaCalcDateList[0];
													String mes 	= fechaCalcDateList[1];
													String anyo	= fechaCalcDateList[2];
													
													fechaCalcDateDate = Date.valueOf(anyo+'-'+mes+'-'+dia);
													
												}else if(!fechaCalcDateString.left(4).contains('-') && fechaCalcDateString.right(3).contains('-'))
												{
													fechaCalcDateDate = Date.valueOf(fechaCalcDateString);
												}
												if(fechaCalcDateDate != null)
												{
													etDetailCustomer.CalcDate = fechaCalcDateDate;	
												}
							    			}
							    			else if(nodoBisNieto.getName() == 'SaldoVivo')
							    			{
						    					etDetailCustomer.SaldoVivo = nodoBisNieto.getText();
							    			}
				    					}
				    					
				    					listaEtDetailCustomers.add(etDetailCustomer);
				    				}
		    					}
		    				}
		    			}
		    		}
    			}
    		}
    	} 
    	
    	return listaEtDetailCustomers;
	}

	public static String generarXmlConfirmacionFacturas() 
    {
    	Xmlstreamwriter xmlW = new Xmlstreamwriter(); 
    	xmlW.writeStartElement(null, 'soap:Envelope', null);
	        xmlW.writeAttribute(null, null,'xmlns:soap', 'http://schemas.xmlsoap.org/soap/envelope/');
	        xmlW.writeAttribute(null, null,'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
	        xmlW.writeAttribute(null, null,'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
			xmlW.writeStartElement(null, 'soap:Body', null);
		       	xmlW.writeStartElement(null, WS_METHOD_CONFIRMAR_CLIENTES, null);
				    xmlW.writeAttribute(null, null,'xmlns','urn:microsoft-dynamics-schemas/codeunit/PGE_SF');
	        		xmlW.writeStartElement(null, 'entitySyncDto', null);
	        		if(mapaIdsNavisioIdSf!=null && mapaIdsNavisioIdSf.KeySet().size()>0) 
	        		{
	        			//////
	        			for(Account cuenta: mapaIdsNavisioIdSf.KeySet())
	        			{
	        				xmlW.writeStartElement(null,'etCustomer',null);
				    		xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
				    	
				    		if(cuenta.Id_Navision__c!=null)
					    	{
						    	xmlW.writeStartElement(null, 'CustomerNo', null);
			                   	    xmlW.writeCharacters(cuenta.Id_Navision__c);
			                    xmlW.writeEndElement();
					    	}
					    	else 
					    		xmlW.writeEmptyElement(null, 'CustomerNo', null);
					    	
					    	if(cuenta.Id!=null)
					    	{
						    	xmlW.writeStartElement(null, 'SalesForceId', null);
			                   	    xmlW.writeCharacters(cuenta.Id);
			                    xmlW.writeEndElement();
					    	}
					    	else 
					    		xmlW.writeEmptyElement(null, 'SalesForceId', null);
						    
						    xmlW.writeStartElement(null, 'SFUpdated', null);
			                	xmlW.writeCharacters('true');
			                xmlW.writeEndElement();

				            xmlW.writeEndElement();
	        			}
	        		}
	        									    
					xmlW.writeEndElement();
					//Creamos el entitySyncDto_OUT vacío
			    	xmlW.writeStartElement(null, 'entitySyncDto_OUT', null);
			   		xmlW.writeEmptyElement(null, 'etCustomer',null);
				    	xmlW.writeAttribute(null, null,'xmlns',WS_CLIENTE_SCHEMA);
				    xmlW.writeEndElement();
	       		xmlW.writeEndElement();
	       	xmlW.writeEndElement();
	    xmlW.writeEndElement();
       	
        String mensaje = xmlW.getXmlString();
        mensaje = '<?xml version="1.0" encoding="utf-8"?>' + mensaje;
        xmlW.close();
        System.debug('Body: '+mensaje);
      
        return mensaje;
    }*/
}