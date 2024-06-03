global class Nav2sfdc_Clientes_Confirmacion implements Database.AllowsCallouts, Database.Batchable<sObject>,Schedulable 
{
	public String query = '';

	public Nav2sfdc_Clientes_Confirmacion() 
	{
		System.Debug('## Constructor de Nav2sfdc_Clientes_Confirmacion');
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('## Start de Nav2sfdc_Clientes_Confirmacion');
        return Database.getQueryLocator('Select Id, Id_Navision__c, Pendiente_de_confirmar__c from Account where Pendiente_de_confirmar__c = true');
    }

    //Execute del Scheduler --> Inicia el Batch Apex
    //Envía a Navision la confirmación de los clientes correctamente insertados/actualizados en SF
    //Desde Navision se controla que cuando se intenta mandar 5 veces un cliente y este no se ha
    //confirmado se marca como erroneo
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
        	if(jobDetail.Name.startsWith('Nav2sfdc_Clientes'))
        		System.abortJob(mapaIdDetailsIdJob.get(jobDetail.Id));
            System.debug('##Se ha parado el trabajo: '+jobDetail.Name);
            LogUtil.crearLog('Se ha parado el trabajo: ' + jobDetail.Id +  ' con nombre: '+jobDetail.Name, 'Nav2sfdc_Clientes_Confirmacion.execute', 'Cliente', 'Error', true);
        }  
              
        database.executeBatch(new Nav2sfdc_Clientes_Confirmacion(), 100);                
    }
    
    global void execute(Database.BatchableContext BC, List<Account> cuentasPendientesActualizar)
    { 
       System.debug('## Batch Nav2sfdc_Clientes_Confirmacion cuentasPendientesActualizar: ' + cuentasPendientesActualizar);
       //////
       List<Id> idsCuentasPendientesActualizar = new List<Id>();
       for(Account c: cuentasPendientesActualizar)
       {
          idsCuentasPendientesActualizar.add(c.Id);
       }
       List<Direcci_n_de_entrega__c> listaDireccionesPendientesActualizar = [SELECT Id, Id_Navision__c, Cuenta__c FROM Direcci_n_de_entrega__c WHERE Cuenta__c IN: idsCuentasPendientesActualizar and Pendiente_de_confirmar__c = true];
       Map<Account,List<Direcci_n_de_entrega__c>> mapaIdsCuentasIdNavisio = new Map<Account,List<Direcci_n_de_entrega__c>>();
       List<Direcci_n_de_entrega__c> listaDirecciones;
       for(Account c: cuentasPendientesActualizar)
       {
          listaDirecciones = new List<Direcci_n_de_entrega__c>();
          for(Direcci_n_de_entrega__c d: listaDireccionesPendientesActualizar)
          {
              if(c.Id==d.Cuenta__c)
              {
                  listaDirecciones.add(d);
              }
          }
          mapaIdsCuentasIdNavisio.put(c,listaDirecciones);
       }
       //////
       /*Map<String,String> mapaIdsCuentasIdNavisio = new Map<String,String>();
       
       for(Account cuenta : cuentasPendientesActualizar)
       {
       		mapaIdsCuentasIdNavisio.put(cuenta.Id, cuenta.Id_Navision__c);
       }*/
       
       // Aquí hacemos la petición de confirmación pasando los Ids de Salesforce y de Navision
       boolean confirmacion = NavWSUtil.peticionWSConfirmarClientes(mapaIdsCuentasIdNavisio);
       
       if(confirmacion == true)
       {
	       //A continuación se quita el check de pendiente de confirmación de Salesforce
	       for(Account cuenta : cuentasPendientesActualizar)
	       {  
	       		cuenta.Pendiente_de_confirmar__c = false;
	       }
	       
	       AccountUtil.semaforoUpdate = false;
	       update cuentasPendientesActualizar;
	       AccountUtil.semaforoUpdate = true;
         //////
         for(Direcci_n_de_entrega__c direccion : listaDireccionesPendientesActualizar)
         {  
            direccion.Pendiente_de_confirmar__c = false;
         }
         
         DireccionEnvioUtil.semaforoUpdate = false;
         update listaDireccionesPendientesActualizar;
         DireccionEnvioUtil.semaforoUpdate = true;
         //////
       }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug('## Finish de Nav2sfdc_Clientes_Confirmacion');  
        /* A petición de cliente (Sandra), se deja de llamar a nav2sfdc_clientes Marzo-2023
        if(!Test.isRunningTest())
        {
            //Programamos la siguiente ejecución
            Datetime now = System.now();
            // Le sumamos un número determinado de minutos establecidos en un Custom Setting
            String params = Util.valoresIntegracionNavision.get('Nav2sfdc_Clientes_Confirmacion');
            if(params != null)
            {
              now = now.addMinutes(Integer.valueOf(params)); 
            }
            else
            {
              now = now.addMinutes(60);
            }
            String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
            System.schedule('Nav2sfdc_Clientes' + now.addHours(2), cron, new Nav2sfdc_Clientes());
        }  
        */      
    }
}