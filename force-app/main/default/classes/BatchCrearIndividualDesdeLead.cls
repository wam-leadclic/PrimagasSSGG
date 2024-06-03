global class BatchCrearIndividualDesdeLead implements Database.Batchable<sObject> 
{
    
	global Database.Querylocator start(Database.BatchableContext BC) 
	{
       //Query to fetch non-converted Leads that don't have Individual created. You may modify the query to add custom fields  
       return Database.getQueryLocator('Select FirstName, LastName, Salutation, Email, Fecha_deteccion__c, CreatedDate from Lead where IsConverted = false and IndividualId = NULL');
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList) 
    { 
        Map<Id, Individual> individualRecordsToCreate = new Map<Id, Individual>();
        for(Lead l : leadList) 
        {
            individualRecordsToCreate.put(l.Id, new Individual(FirstName = l.FirstName, LastName = l.LastName, Salutation=l.Salutation, Email__c = l.Email));
        }

        insert individualRecordsToCreate.values();
        
        //Generamos el hash para cada persona. Necesitamos el Id de la persona para generar el hash.
        Set<Id> personasIdsList = new Set<Id>();
        for(Individual persona : individualRecordsToCreate.values())
        {
            personasIdsList.add(persona.Id);
        }

        Map<Id, String> idHashMap = Util.calcularHashMasivo(personasIdsList);
        
        for(Individual persona : individualRecordsToCreate.values())
        {
            if(idHashMap.containsKey(persona.Id))
            {
                persona.Hash__c = idHashMap.get(persona.Id);
            }
        }

        //Actualizamos las personas para generar el hash
        update individualRecordsToCreate.values();

        for(Lead l : leadList) 
        {
            if(l.Fecha_deteccion__c == null)
            {
                l.Fecha_deteccion__c = Date.newinstance(l.CreatedDate.year(), l.CreatedDate.month(), l.CreatedDate.day());
            }
            l.IndividualId = individualRecordsToCreate.get(l.Id).Id;
        }
        LeadHandler.semaforoLead = false;
        Database.SaveResult[] updateResultLead = Database.update(leadList, false);
        
        for(Integer i = 0; i < updateResultLead.size(); i++)
        {
            Database.SaveResult sr = updateResultLead[i]; 
            if(!sr.isSuccess())
            {
                Database.Error err = sr.getErrors()[0];
                LogUtil.crearLog('Error al actualizar Lead - Message: ' + err.getMessage(), 'BatchCrearIndividualDesdeLead', 'Lead', 'Error', true);
            }
        }  
        LogUtil.guardarLog();   
    }
    
    global void finish(Database.BatchableContext BC) {}  
    
}