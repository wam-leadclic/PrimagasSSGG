@isTest
global class NTLMHttpCalloutMockImpl implements HttpCalloutMock 
{
	
	public String idSalesforceAddress;
	public String idSalesforceEtCustomer;
	public String idSalesforceAddress2;
	public String idSalesforceEtCustomer2;
	public String idSalesforceTarifa;
	public String idSalesforceTarifa2;
	public String idSalesforceContract;
	public Integer tipoRespuesta;
	
	//Constructor para confirmar los clientes y las tarifas
	public NTLMHttpCalloutMockImpl()
	{
		
	}
	
	//Constructor para la creación de contratos
	public NTLMHttpCalloutMockImpl(String idContract){
		this.idSalesforceContract = idContract;
	}
	
	//Constructor para la consulta de tarifas
	public NTLMHttpCalloutMockImpl(String tarifa, String tarifa2, boolean isTarifa){
		this.idSalesforceTarifa = tarifa;
		this.idSalesforceTarifa2 = tarifa2;
	} 
	
	//Constructor para la creación de clientes
	public NTLMHttpCalloutMockImpl(String idAddress, String idEtCustomer){
		this.idSalesforceEtCustomer = idEtCustomer;
		this.idSalesforceAddress = idAddress;
	}
	
	//Constructor para la consulta de clientes
	public NTLMHttpCalloutMockImpl(String idAddress, String idEtCustomer, String idAddress2, String idEtCustomer2){
		this.idSalesforceEtCustomer = idEtCustomer;
		this.idSalesforceAddress = idAddress;
		this.idSalesforceEtCustomer2 = idEtCustomer2;
		this.idSalesforceAddress2 = idAddress2;
	}

	public NTLMHttpCalloutMockImpl(Integer tipoRespuesta)
	{
		this.tipoRespuesta = tipoRespuesta;
	}
	
	//Simula las diferentes respuestas del WebService de Navision en funcón de la cabecera SOAP Action
	//@rcastanos (04/06/2019) Se han modificado los endpoint para que los tome desde los metadatos
    global HttpResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        string endPoint = req.getEndpoint();

        //string Authorization = req.getHeader('Authorization');
        string Authorization = 'NTLM';

        if (String.isBlank(Authorization) || String.isEmpty(Authorization)  )
        {
            System.debug('Step 0');
            res.setHeader('WWW-Authenticate', 'NTLM');
            res.setStatusCode(401);

        } else 
        {

            NTLMAuth mNtlm = new NTLMAuth();
            if (Authorization.contains('NTLM'))
            {
                if (Authorization == 'NTLM ' + mNtlm.getType1Message()) 
                {
                    System.debug('Step 1');
                    
                    Integer[] message2 = new Integer[] { 78, 84, 76, 77, 83, 83, 80, 0, 2, //header of type 2 (9 in total)
                        4, 5, 6, 8, 10, 11, 15, 16, 20, 22, 26, 29, 31, 45, 46, 49, 58, 66, 74, 85, 86, 97, 100 }; //numbers from random org
                    string message2String = BitConverter.encodeBase64String(message2);

                    res.setHeader('WWW-Authenticate', 'NTLM ' + message2String);
                    res.setStatusCode(401);

                }
                else
                {
                	System.debug('SOAP ACTION:: '+req.getHeader('SOAPAction'));
                	//Dependiendo del header simulamos una respuesta u otra del servidor
                	if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_crear_clientes'))
	                {
	                	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_crear_clientes'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
	                    //////
	                    String body;
	                    if(idSalesforceEtCustomer=='')
	                    {
	                    	if(idSalesforceAddress=='')
	                    	{
	                    		body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"> <soap:Body> </soap:Body></soap:Envelope>';
	                    	}
	                    	else
	                    	{
	                    		body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"> <soap:Body> <Sfdc2Nav_CrearCliente_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"/></entitySyncDto><entitySyncDto_OUT><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo></CustomerNo><Name>ALMACENES2</Name><VatRegistration>A61128014</VatRegistration><City>Bilbao</City><etAddres><ADCode>31</ADCode><ADAddres2>ADAddres2</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress+ '</ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' + idSalesforceEtCustomer + '</SalesForceId></etCustomer></entitySyncDto_OUT></Sfdc2Nav_CrearCliente_Result></soap:Body></soap:Envelope>';
	                    	}	                    }
	                    else
	                    //////
	                    {
	                    	body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"> <soap:Body> <Sfdc2Nav_CrearCliente_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"/></entitySyncDto><entitySyncDto_OUT><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><VatRegistration>A61128014</VatRegistration><City>Bilbao</City><etAddres><ADCode>31</ADCode><ADAddres2>ADAddres2</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress+ '</ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' + idSalesforceEtCustomer + '</SalesForceId></etCustomer></entitySyncDto_OUT></Sfdc2Nav_CrearCliente_Result></soap:Body></soap:Envelope>';	    				
	                    }
	    				res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_consultar_clientes'))
	                {
	                   	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_consultar_clientes'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
	
	                    //String body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"> <soap:Body> <Nav2sfdc_ConsultarClientes_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto_OUT><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><Name2>Name2</Name2><VatRegistration>A61128014</VatRegistration><City/><DOM_PROF>DOM</DOM_PROF><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress + '</ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' + idSalesforceEtCustomer + '</SalesForceId></etCustomer><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000002</CustomerNo><Name>ALMACENES5</Name><Name2>Name2</Name2><VatRegistration>A61128013</VatRegistration><City/><DOM_PROF>PROF</DOM_PROF><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADCode>32</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress2 + '</ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' +  idSalesforceEtCustomer2 + '</SalesForceId></etCustomer></entitySyncDto_OUT><entitySyncDto><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><Name2>Name2</Name2><VatRegistration>A61128014</VatRegistration><City/><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId></ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId></SalesForceId></etCustomer><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000002</CustomerNo><Name>ALMACENES4</Name><VatRegistration>A61128013</VatRegistration><City/><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId></ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId></SalesForceId></etCustomer></entitySyncDto></Nav2sfdc_ConsultarClientes_Result></soap:Body></soap:Envelope>';
	                    //Cambios rfernandez (28/04/2017) Se han añadido los campos de nombre y apellido.
	                    //Cambios rfernandez (29/05/2017) Los 4 nuevos campos email invoice, blocked, etc...
						//Cambios rfernandez (27/06/2017) Nuevos campos de la integracion String body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"> <soap:Body> <Nav2sfdc_ConsultarClientes_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto_OUT><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128014</VatRegistration><City/><DOM_PROF>DOM</DOM_PROF><eMailInvoice>true</eMailInvoice><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress + '</ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' + idSalesforceEtCustomer + '</SalesForceId></etCustomer><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000002</CustomerNo><Name>ALMACENES5</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128013</VatRegistration><City/><DOM_PROF>PROF</DOM_PROF><eMailInvoice>true</eMailInvoice><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>32</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress2 + '</ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' +  idSalesforceEtCustomer2 + '</SalesForceId></etCustomer></entitySyncDto_OUT><entitySyncDto><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128014</VatRegistration><City/><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId></ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId></SalesForceId></etCustomer><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000002</CustomerNo><Name>ALMACENES4</Name><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128013</VatRegistration><City/><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId></ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId></SalesForceId></etCustomer></entitySyncDto></Nav2sfdc_ConsultarClientes_Result></soap:Body></soap:Envelope>';
						//Cambios rfernandez (08/02/2018) Campo dir entrega '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><Nav2sfdc_ConsultarClientes_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto_OUT><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128014</VatRegistration><City /><DOM_PROF>DOM</DOM_PROF><eMailInvoice>true</eMailInvoice><AlertaBloqueo /><SaldoPendiente>9,95</SaldoPendiente><SaldoVivo>9,95</SaldoVivo><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress + '</ADSalesForceId><ADConsumoPrevistoKgs>1.000</ADConsumoPrevistoKgs><ADConsumoPromedioLast3y>526</ADConsumoPromedioLast3y><ADConsumoPromedioLast12m>526</ADConsumoPromedioLast12m><ADActualPrice>1,012</ADActualPrice><ADDiscounts>0</ADDiscounts><SIBocaCarga /><SIEstadoBocaCarga /><SIDeposito>DEP010199--245490729</SIDeposito><SIEstadoDeposito>Installed</SIEstadoDeposito><SITelemedida>TELM001058--4962748</SITelemedida><SIEstadoTelemedida>Installed</SIEstadoTelemedida><SIPropiedadTanque>Own</SIPropiedadTanque></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' + idSalesforceEtCustomer + '</SalesForceId></etCustomer><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000002</CustomerNo><Name>ALMACENES5</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128013</VatRegistration><City /><DOM_PROF>PROF</DOM_PROF><eMailInvoice>true</eMailInvoice><AlertaBloqueo /><SaldoPendiente>9,95</SaldoPendiente><SaldoVivo>9,95</SaldoVivo><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>32</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress2 + '</ADSalesForceId><ADConsumoPrevistoKgs>1.000</ADConsumoPrevistoKgs><ADConsumoPromedioLast3y>526</ADConsumoPromedioLast3y><ADConsumoPromedioLast12m>526</ADConsumoPromedioLast12m><ADActualPrice>1,012</ADActualPrice><ADDiscounts>0</ADDiscounts><SIBocaCarga /><SIEstadoBocaCarga /><SIDeposito>DEP010199--245490729</SIDeposito><SIEstadoDeposito>Installed</SIEstadoDeposito><SITelemedida>TELM001058--4962748</SITelemedida><SIEstadoTelemedida>Installed</SIEstadoTelemedida><SIPropiedadTanque>Own</SIPropiedadTanque></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' +idSalesforceEtCustomer2 + '</SalesForceId></etCustomer></entitySyncDto_OUT><entitySyncDto><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128014</VatRegistration><City /><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId></ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId></SalesForceId></etCustomer><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000002</CustomerNo><Name>ALMACENES4</Name><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128013</VatRegistration><City /><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId></ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId></SalesForceId></etCustomer></entitySyncDto></Nav2sfdc_ConsultarClientes_Result></soap:Body></soap:Envelope>';
						String body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><Nav2sfdc_ConsultarClientes_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto_OUT><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128014</VatRegistration><City /><DOM_PROF>DOM</DOM_PROF><eMailInvoice>true</eMailInvoice><AlertaBloqueo /><SaldoPendiente>9,95</SaldoPendiente><SaldoVivo>9,95</SaldoVivo><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress + '</ADSalesForceId><ADConsumoPrevistoKgs>1.000</ADConsumoPrevistoKgs><ADConsumoPromedioLast3y>526</ADConsumoPromedioLast3y><ADConsumoPromedioLast12m>526</ADConsumoPromedioLast12m><ADActualPrice>1,012</ADActualPrice><ADDiscounts>0</ADDiscounts><SIBocaCarga /><SIEstadoBocaCarga /><SIDeposito>DEP010199--245490729</SIDeposito><SIEstadoDeposito>Installed</SIEstadoDeposito><SITelemedida>TELM001058--4962748</SITelemedida><SIEstadoTelemedida>Installed</SIEstadoTelemedida><SIPropiedadTanque>Own</SIPropiedadTanque><ADOldCustomerNo>123</ADOldCustomerNo><ADOldAddress>01</ADOldAddress><ADFirstFilledDate>08-02-2018</ADFirstFilledDate></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' + idSalesforceEtCustomer + '</SalesForceId></etCustomer><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000002</CustomerNo><Name>ALMACENES5</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128013</VatRegistration><City /><DOM_PROF>PROF</DOM_PROF><eMailInvoice>true</eMailInvoice><AlertaBloqueo /><SaldoPendiente>9,95</SaldoPendiente><SaldoVivo>9,95</SaldoVivo><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>32</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId>' + idSalesforceAddress2 + '</ADSalesForceId><ADConsumoPrevistoKgs>1.000</ADConsumoPrevistoKgs><ADConsumoPromedioLast3y>526</ADConsumoPromedioLast3y><ADConsumoPromedioLast12m>526</ADConsumoPromedioLast12m><ADActualPrice>1,012</ADActualPrice><ADDiscounts>0</ADDiscounts><SIBocaCarga /><SIEstadoBocaCarga /><SIDeposito>DEP010199--245490729</SIDeposito><SIEstadoDeposito>Installed</SIEstadoDeposito><SITelemedida>TELM001058--4962748</SITelemedida><SIEstadoTelemedida>Installed</SIEstadoTelemedida><SIPropiedadTanque>Own</SIPropiedadTanque><ADOldCustomerNo>123</ADOldCustomerNo><ADOldAddress>01</ADOldAddress><ADFirstFilledDate>2018-02-08</ADFirstFilledDate></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId>' +idSalesforceEtCustomer2 + '</SalesForceId></etCustomer></entitySyncDto_OUT><entitySyncDto><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000000</CustomerNo><Name>ALMACENES2</Name><Name2>Name2</Name2><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128014</VatRegistration><City /><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId></ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId></SalesForceId></etCustomer><etCustomer xmlns="urn:microsoft-dynamics-nav/xmlports/x50050"><CustomerNo>90000002</CustomerNo><Name>ALMACENES4</Name><Name_SF>ALMACENES2</Name_SF><Surname_SF>ALMACENES2</Surname_SF><VatRegistration>A61128013</VatRegistration><City /><etAddres><ADCodePriceDiscount>IdNav</ADCodePriceDiscount><ADStatus>ADStatus</ADStatus><ADBlocked>true</ADBlocked><ADBlockedReason>ADBlockedReason</ADBlockedReason><ADCode>31</ADCode><ADAddres2>ADAddres23</ADAddres2><ADAddres>ADAddres</ADAddres><ADSalesForceId></ADSalesForceId></etAddres><etDataBank><BankCode>2</BankCode><BankIBAN>BankIBAN</BankIBAN><BankSWIFT>BankSWIFT</BankSWIFT></etDataBank><SalesForceId></SalesForceId></etCustomer></entitySyncDto></Nav2sfdc_ConsultarClientes_Result></soap:Body></soap:Envelope>';
						res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_consultar_tarifas'))
	                {
	                    System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_consultar_tarifas'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
	
	                    String body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><Nav2sfdc_Tarifas_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto_OUT><etTarifa xmlns="urn:microsoft-dynamics-nav/xmlports/x50053"><TarifaCode>90000012</TarifaCode><Description>Descripcion tarifa 1</Description><SalesForceId>' + idSalesforceTarifa + '</SalesForceId></etTarifa><etTarifa xmlns="urn:microsoft-dynamics-nav/xmlports/x50053"><TarifaCode>90000013</TarifaCode><Description>Descripcion tarifa 2</Description><SalesForceId>' +  idSalesforceTarifa2 + '</SalesForceId></etTarifa></entitySyncDto_OUT><entitySyncDto><etTarifa xmlns="urn:microsoft-dynamics-nav/xmlports/x50053"><TarifaCode>90000012</TarifaCode><Description>Descripcion tarifa 1</Description><SalesForceId></SalesForceId></etTarifa><etTarifa xmlns="urn:microsoft-dynamics-nav/xmlports/x50053"><TarifaCode>90000013</TarifaCode><Description>Descripcion tarifa 2</Description><SalesForceId></SalesForceId></etTarifa></entitySyncDto></Nav2sfdc_Tarifas_Result></soap:Body></soap:Envelope>';
	    				res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_confirmar_clientes'))
	                {
	                   	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_confirmar_clientes'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
	                    
	                    String body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><Nav2sfdc_ClientesConfirmacion xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"></Nav2sfdc_ClientesConfirmacion></soap:Body></soap:Envelope>';
	    				res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_confirmar_tarifas'))
	                {
	                   	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_confirmar_tarifas'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
	                    
	                    String body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><Nav2sfdc_TarifasConfirmacion xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"></Nav2sfdc_TarifasConfirmacion></soap:Body></soap:Envelope>';
	    				res.setBody(body);
	                }
	                //Cambios rfernandez (03/08/2017) Añadidas nuevas respuestas para los objetos nuevos
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_crear_contratos'))
	                {
	                	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_crear_contratos'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
	                    String body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"> <soap:Body> <Sfdc2Nav_CrearContrato_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/TEST_SF"><entitySyncDto><etContract xmlns="urn:microsoft-dynamics-nav/xmlports/x50056"/></entitySyncDto><entitySyncDto_OUT><etContract xmlns="urn:microsoft-dynamics-nav/xmlports/x50056"><IDSalesForce>' + idSalesforceContract + '</IDSalesForce><NavisionId>idNavision</NavisionId></etContract></entitySyncDto_OUT></Sfdc2Nav_CrearContrato_Result></soap:Body></soap:Envelope>';
	                    res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_crear_pedidos_gas'))
	                {
	                	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_crear_pedidos_gas'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	
                    	String body;
	                    if(tipoRespuesta == 0)
	                    {
	                    	res.setStatusCode(200);
	                    	body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><App_Order_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/WS_App"><txtPrmMessage>0.Se ha creado el Pedido no. GAS17-007530</txtPrmMessage></App_Order_Result></soap:Body></soap:Envelope>';
                    	}else if(tipoRespuesta == 1){
                    		res.setStatusCode(401);
                    		body = '';
                    	}else{
                    		res.setStatusCode(200);
                    		body = '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><s:Fault></s:Fault></s:Body></s:Envelope>';
                    	}
	                    res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_crear_lecturas_contador'))
	                {
	                	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_crear_lecturas_contador'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                   
	                    String body;
	                    if(tipoRespuesta == 0)
	                    {
	                    	res.setStatusCode(200);
	                    	body = '<?xml version="1.0" encoding="utf-8"?><Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/"><Soap:Body><App_ReadingCustAddress_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/WS_App"><txtPrmMessage>Prueba</txtPrmMessage></App_ReadingCustAddress_Result></Soap:Body></Soap:Envelope>';
                    	}else if(tipoRespuesta == 1){
                    		res.setStatusCode(401);
                    		body = '';
                    	}else{
                    		res.setStatusCode(200);
                    		body = '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><s:Fault></s:Fault></s:Body></s:Envelope>';
                    	}
	                    res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_consultar_pedidos_gas'))
	                {
	                	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_consultar_pedidos_gas'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
 						String body = '<?xml version="1.0" encoding="utf-8"?><Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/"><Soap:Body><ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/salesorders"><ReadMultiple_Result><SalesOrders><No>GAS16-009012</No><Ship_to_Code>1</Ship_to_Code><Status>Released</Status><Posting_Date>2016-05-12</Posting_Date></SalesOrders><SalesOrders><No>GAS16-009022</No><Ship_to_Code>1</Ship_to_Code><Status>Released</Status><Posting_Date>2016-05-12</Posting_Date></SalesOrders></ReadMultiple_Result></ReadMultiple_Result></Soap:Body></Soap:Envelope>';
 	                    res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_consultar_lecturas_contador'))
	                {
	                	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_consultar_lecturas_contador'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
	                    String body = '<?xml version="1.0" encoding="utf-8"?><Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/"><Soap:Body><ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/meterreading"><ReadMultiple_Result><MeterReading><Ship_to_Address_Code>1</Ship_to_Address_Code><Ending_Date>2016-04-24</Ending_Date><End_Reading>4457</End_Reading><Source>System</Source></MeterReading><MeterReading><Ship_to_Address_Code>1</Ship_to_Address_Code><Ending_Date>2016-07-24</Ending_Date><End_Reading>4466</End_Reading><Source>System</Source></MeterReading></ReadMultiple_Result></ReadMultiple_Result></Soap:Body></Soap:Envelope>';
	                    res.setBody(body);
	                }
	                else if(req.getHeader('SOAPAction') == Util.valoresIntegracionNavision.get('Url_consultar_detalle_clientes'))
	                {
	                   	System.debug('SOAPAction: '+ Util.valoresIntegracionNavision.get('Url_consultar_detalle_clientes'));
	                    System.debug('Step 2');
	                    req.setHeader('Authorization', 'NTLM ');
	
	                    res.setHeader('Content-Type', 'text/xml; charset=utf-8');
	                    res.setStatusCode(200);
	
	                  	String body = '';
	                  	if(tipoRespuesta == 0)
	                  	{
	                  		//Un solo registro
	                  		body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pge="urn:microsoft-dynamics-schemas/codeunit/PGE_SF" xmlns:x50="urn:microsoft-dynamics-nav/xmlports/x50062"><soap:Header/><soap:Body><Nav2sfdc_DetailCustomer_Result><entitySyncDto_OUT><etDetailCustomer><CustomerNo>1</CustomerNo><ShiptTo>1</ShiptTo><CalcDate>2018-02-12</CalcDate><SaldoVivo>9,95</SaldoVivo><SaldoPendiente>9,95000</SaldoPendiente><AlertaBloqueo>TestAlertaBloqueo</AlertaBloqueo><ConsumoPrevistoKgs>1.000</ConsumoPrevistoKgs><ConsumoPromedioLast3y>526</ConsumoPromedioLast3y><ConsumoPromedioLast12m>526</ConsumoPromedioLast12m><ActualPrice>1,012</ActualPrice><Discounts>0</Discounts><BocaCarga>TestBocaCarga</BocaCarga><EstadoBocaCarga>TestBocaCarga</EstadoBocaCarga><Deposito>DEP010199--245490729</Deposito><EstadoDeposito>Installed</EstadoDeposito><Telemedida>TELM001058--4962748</Telemedida><EstadoTelemedida>Installed</EstadoTelemedida><PropiedadTanque>Own</PropiedadTanque></etDetailCustomer></entitySyncDto_OUT></Nav2sfdc_DetailCustomer_Result></soap:Body></soap:Envelope>';
	                  	}else if (tipoRespuesta == 1)
	                  	{
	                  		//Un par de registros
							body = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pge="urn:microsoft-dynamics-schemas/codeunit/PGE_SF" xmlns:x50="urn:microsoft-dynamics-nav/xmlports/x50062"><soap:Header/><soap:Body><Nav2sfdc_DetailCustomer_Result><entitySyncDto_OUT><etDetailCustomer><CustomerNo>1</CustomerNo><ShiptTo>1</ShiptTo><CalcDate>2018-02-12</CalcDate><SaldoVivo>9,95</SaldoVivo><SaldoPendiente>9,95</SaldoPendiente><AlertaBloqueo>TestAlertaBloqueo</AlertaBloqueo><ConsumoPrevistoKgs>1.000</ConsumoPrevistoKgs><ConsumoPromedioLast3y>526</ConsumoPromedioLast3y><ConsumoPromedioLast12m>526</ConsumoPromedioLast12m><ActualPrice>1,012</ActualPrice><Discounts>0</Discounts><BocaCarga>TestBocaCarga</BocaCarga><EstadoBocaCarga>TestBocaCarga</EstadoBocaCarga><Deposito>DEP010199--245490729</Deposito><EstadoDeposito>Installed</EstadoDeposito><Telemedida>TELM001058--4962748</Telemedida><EstadoTelemedida>Installed</EstadoTelemedida><PropiedadTanque>Own</PropiedadTanque></etDetailCustomer><etDetailCustomer><CustomerNo>1</CustomerNo><ShiptTo>2</ShiptTo><CalcDate>2018-02-12</CalcDate><SaldoVivo>9.95</SaldoVivo><SaldoPendiente>9.95</SaldoPendiente><AlertaBloqueo>TestAlertaBloqueo</AlertaBloqueo><ConsumoPrevistoKgs>1.000</ConsumoPrevistoKgs><ConsumoPromedioLast3y>526</ConsumoPromedioLast3y><ConsumoPromedioLast12m>526</ConsumoPromedioLast12m><ActualPrice>1,012</ActualPrice><Discounts>0</Discounts><BocaCarga>TestBocaCarga</BocaCarga><EstadoBocaCarga>TestBocaCarga</EstadoBocaCarga><Deposito>DEP010199--245490729</Deposito><EstadoDeposito>Installed</EstadoDeposito><Telemedida>TELM001058--4962748</Telemedida><EstadoTelemedida>Installed</EstadoTelemedida><PropiedadTanque>Own</PropiedadTanque></etDetailCustomer></entitySyncDto_OUT></Nav2sfdc_DetailCustomer_Result></soap:Body></soap:Envelope>';
	                  	}else if (tipoRespuesta == 2)
	                  	{
	                  		//Respuesta sin registros
	                  		body = '<?xml version="1.0" encoding="utf-8"?><Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/"><Soap:Body><Nav2sfdc_DetailCustomer_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/PGE_SF"><entitySyncDto_OUT></entitySyncDto_OUT></Nav2sfdc_DetailCustomer_Result></Soap:Body></Soap:Envelope>';
	                  	}else if (tipoRespuesta == 3)
	                  	{
	                  		CalloutException e = new CalloutException();
							e.setMessage('Read timed out');
							throw e;
	                  	}
	                  	res.setBody(body);
	                }

                }
            }
        }
        return res;
    }
}