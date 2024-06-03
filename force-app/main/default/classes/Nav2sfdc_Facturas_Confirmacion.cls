global class Nav2sfdc_Facturas_Confirmacion implements Database.Batchable<sObject> {
	
	String query;
	
	global Nav2sfdc_Facturas_Confirmacion(String pQuery)
	{
		query = pQuery;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		/*if(String.isBlank(query))
		{
			query = 'Select Id, Id_Navision__c, Pendiente_de_confirmar__c from Factura__c where Pendiente_de_confirmar__c = true';
		}*/

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
   		// Aquí hacemos la petición de confirmación pasando los Ids de Salesforce y de Navision
       	/*Boolean confirmacion = NavWSUtil.peticionWSConfirmarFacturas(mapaIdsCuentasIdNavisio);

       	if(confirmacion)
       	{
       		for(Factura__c factura : facturasList)
			{  
				cuenta.Pendiente_de_confirmar__c = false;
			}

			update facturasList;
       	}*/
	
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		//Programamos la siguiente peticion
	 	/*Parametros_generales__c params = Parametros_generales__c.getValues('Nav2sfdc_Clientes_Confirmacion');
        if (params != null)
        {
          now = now.addMinutes(Integer.valueOf(params.Valor__c)); 
        }
        else
        {
          now = now.addMinutes(60);
        }
        String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
        System.schedule('Nav2sfdc_Facturas', cron, new Nav2sfdc_Clientes());*/		
	}
	
}