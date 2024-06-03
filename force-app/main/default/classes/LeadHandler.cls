/**
 * Trigger Handler for the Lead SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class LeadHandler implements ITrigger
{ 
    /*Usamos este semaforo para evitar que se llame al future desde el batch de creacion de personas*/
    public static Boolean semaforoLead = true; 
    /**
     * bulkBefore
     *
     * These methods are called prior to execution of a BEFORE or AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)
    {
    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)
    {
        if(Trigger.isUpdate)
        {
            LeadUtil.recuperarPersonas((List<Lead>)newList, null);
        }

        if(Trigger.isDelete)
        {
            LeadUtil.recuperarPersonas(null, (Map<Id, Lead>)oldMap);
        }
        
    }
    
    /**
     * These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)
    {
        LeadUtil.crearRegistrosPersona((List<Lead>)newList);
		
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
    }
    
    public void beforeDelete(map<Id,SObject> oldMap)
    {
        
    }
    
    /**
     * These methods ara called for records to be processed during a AFTER 
     * trigger.
     */ 
    public void afterInsert(list<SObject> newList)
    {    	
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        //System.Debug('## afterUpdate Lead: ' + newList);
        List<Id> listaIdsLeads = new List<Id>();
        for(Lead l: (List<Lead>)newList)
        {
            listaIdsLeads.add(l.Id);
        }
        if(semaforoLead)
        {
            LeadUtil.insertarDatosConversionCuentaYOportunidad(listaIdsLeads);
        }
        
        LeadUtil.actualizarRegistrosPersona((List<Lead>)newList);
    }
     
    public void afterDelete(map<Id,SObject> oldMap)
    {
	   LeadUtil.eliminarRegistroPersona((Map<Id, Lead>)oldMap);
    }
     
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
    	LeadUtil.insertUpdateDeleteRecords();
    }
}