/** 
* Clase Nav2sfdc_Tarifas
**
* @Funcionalidad: Clase Schedulable encargada de solicitar a Navision información acerca de nuevas tarifas
* @Autor: Aritz Uriarte de Alayo (28/07/2015)
**
**/
global class Nav2sfdc_Tarifas implements Schedulable 
{   
    global void execute(SchedulableContext SC) 
    {
    	cargarTarifasNavEnSf();
    } 
    
    @future(callout=true)
    public static void cargarTarifasNavEnSf()
    {
    	try
		{
	    	List<XmlUtil.RespuestaPeticionConsultarTarifas> listaTarifasNav = NavWSUtil.peticionWSConsultarTarifas();
	    	System.debug('listaTarifasNav -> ' + listaTarifasNav);
	    	//Actualización/inserción de tarifas
			List<Pricebook2> tarifasUpsert = new List<Pricebook2>();
			Pricebook2 tarifaUpsert;
			Set<String> idsNavisio = new Set<String>();
			//Buscamos las tarifas en SF por el Id de Navisio, puede que se cree en SF la tarifa solo con el Id de Nav
			//De esta forma mantenemos la relación de la tarifa con el cliente, en ese momento la tarifa no está visible
			//(Is active = false), cuando posteriormente se llame al método ConsultarTarifas y se actualicen en Sf el 
			//resto de campos pasará a ser visible (Is active = true) y en ese momento podrá ser seleccionada por el
			//comercial cuando este crea un contrato
			for (XmlUtil.RespuestaPeticionConsultarTarifas tarifaNav:listaTarifasNav)
			{  
				idsNavisio.add(tarifaNav.idNavisio);
			}
			
			List<Pricebook2> listaPrecios = [select Id, Id_Navision__c from Pricebook2 where Id_Navision__c in : idsNavisio];
			Map<String,String> mapaListaPreciosIdNavIdSf = new Map<String,String>();
			for(Pricebook2 pb : listaPrecios)
			{
				mapaListaPreciosIdNavIdSf.put(pb.Id_Navision__c,pb.Id);
			}
			
			for (XmlUtil.RespuestaPeticionConsultarTarifas tarifaNav:listaTarifasNav)
			{  
				tarifaUpsert = new Pricebook2();
				tarifaUpsert.Id_Navision__c = tarifaNav.idNavisio;
				tarifaUpsert.Fecha_ltima_Sync__c = System.now();
				
				//Si no tenemos la descripción se pone pendiente de asignar para que no falle en SF
				if(!String.IsEmpty(tarifaNav.descripcion))
				{
					tarifaUpsert.Name = tarifaNav.descripcion;
					tarifaUpsert.Description = tarifaNav.descripcion;
				}
				else
				{
					tarifaUpsert.Name = 'Pendiente de asignar';
					tarifaUpsert.Description = 'Pendiente de asignar';
				}
				
				
				//Si recibimos el Id de SF porque se ha creado en SF primero
				if(!String.IsEmpty(tarifaNav.idSalesforce))
					tarifaUpsert.Id = tarifaNav.idSalesforce;
				else if(mapaListaPreciosIdNavIdSf.get(tarifaNav.idNavisio) != null)
				{
					//Si no recibimos el Id de SF porque se ha creado en Nav primero
					//Puede que esté creado de antemano en SF (Se ha llamado primero al método de consultar clientes)
					tarifaUpsert.Id = mapaListaPreciosIdNavIdSf.get(tarifaNav.idNavisio);
				}
				//Si no se realiza insert, no se pone Id
				
				//La tarifa es activa, de esta forma se puede seleccionar cuando se crea un contrato
				tarifaUpsert.IsActive = true;
				
				tarifasUpsert.add(tarifaUpsert);
			}
	
			Set<String> idsTarifasPendientesConfirmar = new Set<String>();
			// Aquí realizaremos el intento de inserción/actualización de las nuevas tarifas en el sistema generando un Log por cada una.
			if(tarifasUpsert!=null && tarifasUpsert.size()>0)
			{
				Database.UpsertResult[] res = Database.upsert(tarifasUpsert, false);
		        for(Integer i = 0; i < res.size(); i++)
		        {
		            Database.UpsertResult sr = res[i];
		            if(!sr.isSuccess())
		            {
		                Database.Error err = sr.getErrors()[0];
		                LogUtil.crearLog('Error - Id Navision: '+ tarifasUpsert[i].Id_Navision__c +' - Message: '+ err.getMessage(), 'Nav2sfdc_Tarifas.execute', 'Tarifa', 'Sync', true);
		            }
		            else
		            {
		            	idsTarifasPendientesConfirmar.add(tarifasUpsert[i].Id);
		            	LogUtil.crearLog('Id Salesforce: ' + tarifasUpsert[i].Id + ' - Id Navision: '+ tarifasUpsert[i].Id_Navision__c+' Is success: ' + sr.isSuccess() + ', Is Created: ' + sr.isCreated() + ', Is Updated: ' + !sr.isCreated(), 'Nav2sfdc_Tarifas.execute', 'Tarifa', 'Sync', false);
		            }
		        }
			}
			
	        // Recuperamos los logs de la entidad LogUtil para no tener que hacer una búsqueda posterior y ahorrar DMLs
	        /*List<Log__c> errores = new List<Log__c>();
	        // Extraemos los mensajes de error
	        for (Log__c log:LogUtil.errores)
	        {
	        	if (log.Error__c)
	        	{
	        		errores.add(log);
	        	}
	        }
	
	        // Enviamos a Navision el paquete con los logs, si no obtenemos un mensaje de error marcamos la casilla de enviado a Navision
	        for (Log__c log:LogUtil.errores)
	        {
	        	if (log.Error__c)
	        	{
	        		log.Enviado_a_Navision__c = true;
	        	}
	        }*/
	
	        // Por último registramos los logs en el sistema
	        LogUtil.guardarLog();
	        
	        System.debug('idsTarifasPendientesConfirmar: ' + idsTarifasPendientesConfirmar);
	        
	        //Ponemos pendientes de confirmar las cuentas actualizadas en Salesforce
	        List<String> listaTarifasPendientesConfirmar = new List<String>();
			listaTarifasPendientesConfirmar.addAll(idsTarifasPendientesConfirmar);
			
			//AccountUtil.semaforoUpdate = false;
	        actualizarConfirmacionTarifas(listaTarifasPendientesConfirmar);
	        //AccountUtil.semaforoUpdate = true;
	        //NavWSUtil.peticionWSConfirmarClientes(mapaIdsCuentasIdNavisio);
	
	    }
    	catch(Exception e) 
	    {
        	LogUtil.crearLog('Error ' + e.getLineNumber() + ' -' + e.getMessage(), 'Nav2sfdc_Tarifas', 'cargarTarifasNavEnSf', 'Sync', true);
        	LogUtil.guardarLog();
        }
        finally{
        	Nav2sfdc_Tarifas.programarProximoBatch();

        }
        //Se programa la ejecución del batch dinámicamente, aunque falle la petición
       //programarProximoBatch();
    }
    
    public static void programarProximoBatch(){
    	try
    	{
	        //Eliminamos las que ya no se van a ejecutar más
	        Map<String,String> mapaIdDetailsIdJob = new Map<String,String>();
	        
	        for(CronTrigger cronTr : [SELECT CronJobDetailId, id, CronExpression, TimesTriggered, NextFireTime, State FROM CronTrigger WHERE NextFireTime = null])
	        {
	            System.debug('-- '+cronTr.id+' '+cronTr.State+' '+cronTr.CronExpression);
	            mapaIdDetailsIdJob.put(cronTr.CronJobDetailId,cronTr.Id);
	        }
	        
	        List<CronJobDetail> listaJobDetails = [select Name, Id from CronJobDetail where Id in: mapaIdDetailsIdJob.keySet()];
	        for(CronJobDetail jobDetail : listaJobDetails)
	        {
	        	if(jobDetail.Name.startsWith('Nav2sfdc_Tarifas'))
	        	{
	        		try
	        		{
	        			System.abortJob(mapaIdDetailsIdJob.get(jobDetail.Id));
	        		}catch(Exception e) 
	    			{
	        			System.debug('##No se ha parado el trabajo: '+jobDetail.Name);
						//LogUtil.crearLog('No se ha parado el trabajo: ' + jobDetail.Id +  ' con nombre: '+jobDetail.Name, 'Nav2sfdc_Tarifas.programarProximoBatch', 'Tarifas', 'Error', true);
					}
	        	}
	        } 
	        
	        if(!Test.isRunningTest())
	        {
	            //Programamos la siguiente ejecución
	            Datetime now = System.now();
	            // Le sumamos un número determinado de minutos establecidos en un Metadato
	            String params = Util.valoresIntegracionNavision.get('Nav2sfdc_Tarifas');
	            if (params != null)
	            {
	            	now = now.addMinutes(Integer.valueOf(params));	
	            	System.debug('Valor Custom Setting: Nav2sfdc_Tarifas - ' + Integer.valueOf(params));
	            }
	            else
	            {
	            	now = now.addMinutes(60);
	            	System.debug('Valor Custom Setting: Nav2sfdc_Tarifas - vacío');
	            }
	            String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
	            System.schedule('Nav2sfdc_Tarifas_Confirmacion' + now.addHours(2), cron, new Nav2sfdc_Tarifas_Confirmacion());
	        }   
        }catch(Exception e) 
	    {
        	LogUtil.crearLog('Error -' + e.getMessage(), 'Nav2sfdc_Tarifas', 'programarProximoBatch', 'Sync', true);
        	LogUtil.guardarLog();

        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = new String[] { 'rfernandez@nts-solutions.com', 'ngarcia@nts-solutions.com' };
			message.subject = 'Fallo en Tarifas';
			message.plainTextBody = ('Error: '+ e.getMessage());
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			Datetime now = System.now();
			now = now.addMinutes(30);

			String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
            System.schedule('Nav2sfdc_Tarifas_Confirmacion' + now.addHours(2), cron, new Nav2sfdc_Tarifas_Confirmacion());
        }
    } 
    
     //Indicamos las tarifas que faltan por confirmar, posteriormente se lanza el batch encargado de hacer la petición de la confirmación
    public static void actualizarConfirmacionTarifas(List<String> idsTarifas)
    {
    	List<Pricebook2> listaTarifas = [select Pendiente_de_confirmar__c from Pricebook2 where Id in :idsTarifas];
    	for(Pricebook2 tarifa : listaTarifas)
    	{
    		tarifa.Pendiente_de_confirmar__c = true;
    	}
    	
    	update listaTarifas;
    }   
    
}