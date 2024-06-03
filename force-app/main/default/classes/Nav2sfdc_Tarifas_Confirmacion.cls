global class Nav2sfdc_Tarifas_Confirmacion implements Database.AllowsCallouts, Database.Batchable<sObject>,Schedulable 
{
	public String query = '';

	public Nav2sfdc_Tarifas_Confirmacion() 
	{
		System.Debug('## Constructor de Nav2sfdc_Tarifas_Confirmacion');
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('## Start de Nav2sfdc_Tarifas_Confirmacion');
        return Database.getQueryLocator('Select Id, Id_Navision__c, Pendiente_de_confirmar__c from Pricebook2 where Pendiente_de_confirmar__c = true');
    }

    //Execute del Scheduler --> Inicia el Batch Apex
    //Envía a Navision la confirmación de las tarifas correctamente insertadas/actualizadas en SF
    //Desde Navision se controla que cuando se intenta mandar 5 veces una tarifa y esta no se ha
    //confirmado se marca como erronea
    global void execute(SchedulableContext SC) 
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
        		System.abortJob(mapaIdDetailsIdJob.get(jobDetail.Id));
        }  
        
        database.executeBatch(new Nav2sfdc_Tarifas_Confirmacion(), 200);                
    }
    
    global void execute(Database.BatchableContext BC, List<Pricebook2> tarifasPendientesActualizar)
    { 
       System.debug('## Batch Nav2sfdc_Tarifas_Confirmacion tarifasPendientesActualizar: ' + tarifasPendientesActualizar);
       Map<String,String> mapaIdsTarifasIdNavisio = new Map<String,String>();
       
       for(Pricebook2 tarifa : tarifasPendientesActualizar)
       {
       		mapaIdsTarifasIdNavisio.put(tarifa.Id, tarifa.Id_Navision__c);
       }
       
       // Aquí hacemos la petición de confirmación pasando los Ids de Salesforce y de Navision
       boolean confirmacion = NavWSUtil.peticionWSConfirmarTarifas(mapaIdsTarifasIdNavisio);
       
       if(confirmacion == true) 
       {
	       //A continuación se quita el check de pendiente de confirmación de Salesforce
	       for(Pricebook2 tarifa : tarifasPendientesActualizar)
	       {  
	       		tarifa.Pendiente_de_confirmar__c = false;
	       }
	       
	       //AccountUtil.semaforoUpdate = false;
	       update tarifasPendientesActualizar;
	       //AccountUtil.semaforoUpdate = true;
       }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug('## Finish de Nav2sfdc_Tarifas_Confirmacion');  

        if(!Test.isRunningTest())
        {
            //Programamos la siguiente ejecución
            Datetime now = System.now();
            // Le sumamos un número determinado de minutos establecidos en un Custom Setting
            String params = Util.valoresIntegracionNavision.get('Nav2sfdc_Tarifas_Confirmacion');
            if (params != null)
            {
              now = now.addMinutes(Integer.valueOf(params)); 
            }
            else
            {
              now = now.addMinutes(60);
            }
            String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
            System.schedule('Nav2sfdc_Tarifas' + now.addHours(2), cron, new Nav2sfdc_Tarifas());
        }        
    }
}