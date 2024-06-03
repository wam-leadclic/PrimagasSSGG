/*
	Clase encargada de eliminar aquellas facturas superiores a 1 año con estado Pagado

*/
global class BatchBorrarFacturas implements Database.Batchable<sObject>, Schedulable
{
	String query;
	global Boolean ejecucionGenerica = false; //Para cuando se le ha pasado una query especifica al batch


	global BatchBorrarFacturas(String pQuery) 
	{
		query = pQuery;
	}

	global void execute(SchedulableContext BC)
   	{
        //Database.executeBatch(new BatchBorrarFacturas(null), 200);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		//Si no se pasa una query concreta
		/*if(query == null || query == '')
		{
			String unAnyoString = formatDate(System.today().addYears(-1));

			query = 'SELECT Id, Fecha_registro__c, Estado_documento__c FROM Factura__c WHERE Fecha_registro__c <= '+unAnyoString+' AND Estado_documento__c = \'Pagado\'';
		}
		else
		{
			ejecucionGenerica = true;
		}*/
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> facturasList) 
   	{
		/*if(facturasList != null && !facturasList.isEmpty())
		{
			Database.DeleteResult[] deleteResultFacturas = Database.delete(facturasList, false);
			
			for(Integer i = 0; i < deleteResultFacturas.size(); i++)
	        {
	            Database.DeleteResult dr = deleteResultFacturas[i]; 
	            if(!dr.isSuccess())
	            {
	                Database.Error err = dr.getErrors()[0];
	                LogUtil.crearLog('Error en Borrado de factura ' + deleteResultFacturas[i].Id + ' - Message: ' + err.getMessage(), 'BatchBorrarFacturas.execute', 'Factura__c', 'Error', true);
	            }
	        }       
		}*/
	}
	
	global void finish(Database.BatchableContext BC) 
	{
        /*Parametros_generales__c minsSiguienteEjecucionSetting = Parametros_generales__c.getValues('BatchBorrarFacturas');
        Integer minsSiguienteEjecucion;
        if (minsSiguienteEjecucionSetting != null)
        {
        	minsSiguienteEjecucion = Integer.valueOf(minsSiguienteEjecucionSetting.Valor__c);	
        }
        else
        {
        	minsSiguienteEjecucion = 1440;
        }
        //Programamos la siguiente ejecución sumandole los minutos establecidos en la custom setting
 		Datetime siguiente = System.now().addMinutes(minsSiguienteEjecucion);
        
        
        String cron ='0 ' + siguiente.minute() + ' ' + siguiente.hour() + ' ' + siguiente.day() + ' ' + siguiente.month() + ' ? ' + siguiente.year();
       
        if(!Test.isRunningTest())
        {
            System.schedule('BatchBorrarFacturas' + siguiente, cron, new BatchBorrarFacturas(null));
        }    	*/
	}


	/*public static String formatDate(Date d) 
	{
		String dateString = d.year()+'-';
		if(d.month() < 10)
        {
            dateString += '0' + d.month()+'-';
        }
        else
        {
            dateString += d.month()+'-';
        }
        if(d.day() < 10)
        {
            dateString += '0' + d.day();
        }
        else
        {
            dateString += d.day();
        }
    	return dateString;
	}*/
}