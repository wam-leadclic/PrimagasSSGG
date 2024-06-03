global class BatchComprobarPresupuestosCaducados implements Database.Batchable<sObject>, Schedulable, Database.Stateful{

	public String query; 	

	global BatchComprobarPresupuestosCaducados() {
		
	}

	global Database.Querylocator start(Database.BatchableContext info)
    {
   		System.Debug('******** BatchComprobarPresupuestosCaducados start() ***********');
   		
   		Database.Querylocator resultado = null;
   		   		
   		if (query == null)
       	{
       	  	query = 'Select Id, Name, LastModifiedDate, OpportunityId, Status, Fecha_vigencia__c from Quote';
       	}
   		
   		System.Debug('*** SQL -> ' + query);
   		resultado = Database.getQueryLocator(query);
   		System.Debug('*** Resultado --> ' + resultado);

   		return resultado;
    }

     //Execute del Scheduler --> Inicia el Batch Apex
    global void execute(SchedulableContext SC)
	{
		BatchComprobarPresupuestosCaducados batch = new BatchComprobarPresupuestosCaducados();
		Id batchprocessid = Database.executeBatch(batch,200);

		//Eliminamos las que ya no se van a ejecutar más
        for(CronTrigger cronTr : [SELECT id, CronExpression, TimesTriggered, NextFireTime, State FROM CronTrigger WHERE NextFireTime = null])
        {
            System.debug('borrar '+cronTr.id+' '+cronTr.State+' '+cronTr.CronExpression);
            System.abortJob(cronTr.Id);
        } 
	}

	/*Comprueba diariamente si hay algún presupuesto que tenga la fecha de vigencia menor 
	 al día actual. Si se encuentran registros que cumplan esta condición, se cambiará el estado 
	 de estos presupuestos a “Caducado”.*/
	global void execute(Database.BatchableContext info, List<SObject> scope)
	{
		List<Quote> listaPresupuestos = new List<Quote>();
		for(sObject s : scope)
		{	
			System.debug('scope '+ s);				
			Quote presupuesto = (Quote)s;
	
			listaPresupuestos.add(presupuesto);
		}

		List<Quote> presupuestosActualizar = new List<Quote>();
		for(Quote presupuesto: listaPresupuestos)
		{
			if(presupuesto.Fecha_vigencia__c < System.today() && presupuesto.Status!='Caducado')
			{
				presupuesto.Status = 'Caducado';
				presupuestosActualizar.add(presupuesto);
			}
		}
		System.debug('##Presupuestos a pasar a estado caducado: ' + presupuestosActualizar);

		Database.SaveResult[] res = Database.update(presupuestosActualizar, false);
		for(Database.SaveResult r: res)	
		{
			if(!r.isSuccess())
            {
                Database.Error error = r.getErrors()[0];
                LogUtil.crearLog('Error - Actualizar estado a caducado a presupuesto '+ r.getId() + ' - Message: ' + error.getMessage(), 'BatchComprobarPresupuestosCaducados', 'Quote', 'Update', true);
                LogUtil.guardarLog();
            }
		}	
	}

	global void finish(Database.BatchableContext info)
   	{
   		System.debug('## Finish de BatchComprobarPresupuestosCaducados');  

        if(!Test.isRunningTest())
        {
            //Programamos la siguiente ejecución para dentro de 1 día
            Datetime now = System.now();     
        	now = now.addMinutes(1440);

            String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
            System.schedule('BatchComprobarPresupuestosCaducados ' + now.addHours(2), cron, new BatchComprobarPresupuestosCaducados());
        }        		  
   	}
}