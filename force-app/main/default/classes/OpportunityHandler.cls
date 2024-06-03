/**
 * Trigger Handler for the Opportunity SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class OpportunityHandler implements ITrigger
{
    // Constructor
    public OpportunityHandler() {}
 
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

    }
    
    /**
     * These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)
    {
		System.Debug('## beforeInsert Opportunity: ' + newList);
        //OpportunityUtil.comprobarEstadoNegociacion((List<Opportunity>)newList);
        //OpportunityUtil.comprobarEstadoCerradaGanada((List<Opportunity>)newList);
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
		System.Debug('## beforeUpdate Opportunity: ' + newList);
        //OpportunityUtil.comprobarEstadoNegociacion((List<Opportunity>)newList);
        //OpportunityUtil.comprobarEstadoCerradaGanada((List<Opportunity>)newList);
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
        OpportunityUtil.crearFuncionesDeContacto(newList);
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        OpportunityUtil.setCountyGasRates((List<Opportunity>) newList, (Map<Id, Opportunity>) oldMap);
    }
     
    public void afterDelete(map<Id,SObject> oldMap)
    {
    	
    }
     
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
    	
    }
}