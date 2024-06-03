/** 
* Clase BatchBorrarLogs
**
* @Funcionalidad: Clase Schedulable encargada de eliminar los logs de más de un mes de antigüedad
* @Autor: Aritz Uriarte de Alayo (28/07/2015)
**
**/
global class BatchBorrarLogs implements Database.Batchable<sObject>,Schedulable 
{
	public String query = '';

	public BatchBorrarLogs() 
	{
		System.Debug('## Constructor de BatchBorrarLogs');
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('## Start de BatchBorrarLogs');
        //return Database.getQueryLocator(query);
        Database.Querylocator resultado = null;

        DateTime lastMonth = System.now();
        lastMonth = lastMonth.addDays(-31);
        String lastMonthString = String.valueOf(lastMonth);
        lastMonthString = lastMonthString.substring(0, 10) + 'T' + lastMonthString.substring(11, 19) + 'Z';
               
        if (query == '')
        {
            query = 'Select Id, CreatedDate from Log__c where ' +
                            + 'CreatedDate < ' + lastMonthString;
        }
        
        System.Debug('*** SQL -> ' + query);
        resultado = Database.getQueryLocator(query);
        System.Debug('*** Resultado --> ' + resultado);

        return resultado;
    }

    //Execute del Scheduler --> Inicia el Batch Apex
    global void execute(SchedulableContext SC) 
    {           
        BatchBorrarLogs controller = new BatchBorrarLogs();
        //controller.query = 'Select Id, CreatedDate from Log__c where ' +
        //                    + 'CreatedDate < LAST_MONTH';
        Integer batchSize = 200;
        System.debug('## Execute del Scheduler');
        //System.debug('query -> '+controller.query);
        database.executeBatch(controller, batchSize);    

        //Eliminamos las que ya no se van a ejecutar más
        for(CronTrigger cronTr : [SELECT id, CronExpression, TimesTriggered, NextFireTime, State FROM CronTrigger WHERE NextFireTime = null])
        {
            System.debug('borrar '+cronTr.id+' '+cronTr.State+' '+cronTr.CronExpression);
            System.abortJob(cronTr.Id);
        }             
    }
    
    // Enviamos los logs a Navision y borramos los que tengan más de un mes de antigüedad
    global void execute(Database.BatchableContext BC, List<sObject> logs)
    { 
       System.debug('## before Batch BatchBorrarLogs logs: ' + logs);
       // Aquí habrá que borrar los Logs de más de un mes de antigüedad
       delete logs;
       System.debug('## after Batch BatchBorrarLogs logs: ' + logs);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug('## Finish de BatchBorrarLogs');  

        if(!Test.isRunningTest())
        {
            //Programamos la siguiente ejecución
            Datetime now = System.now();
            // Le sumamos un número determinado de minutos establecidos en un Custom Setting
            String param = Util.valoresIntegracionNavision.get('BatchBorrarLogs');
            if (param != null)
            {
            	now = now.addMinutes(Integer.valueOf(param));	
            }
            else
            {
            	now = now.addMinutes(60);
            }
            String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
            System.schedule('BatchBorrarLogs' + now.addHours(2), cron, new BatchBorrarLogs());
        }        
    }
}