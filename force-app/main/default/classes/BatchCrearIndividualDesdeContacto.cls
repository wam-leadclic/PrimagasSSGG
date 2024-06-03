global class BatchCrearIndividualDesdeContacto implements Database.Batchable<sObject> 
{
	
	global Database.Querylocator start(Database.BatchableContext BC) 
	{
       //Query to fetch contacts that don't have Individual created. You may modify the query to add custom fields  
       //Please add  "IsPersonAccount = false" condition to below query to exclude person accounts
       return Database.getQueryLocator('Select FirstName, LastName, Salutation, Email, Otra_direcci_n_de_correo_electr_nico__c, Otra_direcci_n_de_correo_electr_nico_2__c from Contact where IndividualId = NULL');
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactList) 
    { 
        Map<Id, Individual> individualRecordsToCreate = new Map<Id, Individual>();
        Individual nuevaPersona;
        for(Contact con : contactList) 
        {
            nuevaPersona = new Individual();
            nuevaPersona.FirstName  = con.FirstName;
            nuevaPersona.LastName   = con.LastName;
            nuevaPersona.Salutation = con.Salutation;
            
            if(String.isNotBlank(con.Email))
            {
                nuevaPersona.Email__c = con.Email;
            }else if(String.isNotBlank(con.Otra_direcci_n_de_correo_electr_nico__c))
            {
                nuevaPersona.Email__c = con.Otra_direcci_n_de_correo_electr_nico__c;
            }else if(String.isNotBlank(con.Otra_direcci_n_de_correo_electr_nico_2__c))
            {
                nuevaPersona.Email__c = con.Otra_direcci_n_de_correo_electr_nico_2__c;
            }
            individualRecordsToCreate.put(con.Id, nuevaPersona);
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

        for(Contact con : contactList) 
        {
            con.IndividualId = individualRecordsToCreate.get(con.Id).Id;
        }
        AccountUtil.semaforoUpdate = false;
        update contactList;
    }
    
    global void finish(Database.BatchableContext BC) {}
	
}