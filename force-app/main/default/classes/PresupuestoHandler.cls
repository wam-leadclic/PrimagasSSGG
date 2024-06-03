/**
 * Trigger Handler for the Quote SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class PresupuestoHandler implements ITrigger
{
    public static List<Quote>  ofertasParaActualizar;
    // Constructor
    public PresupuestoHandler() {}
 
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
        ofertasParaActualizar = new List<Quote>();
    }
    
    /**
     * These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)
    {
		
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
    	System.Debug('## afterInsert presupuesto: ' + newList);
    	PresupuestoUtil.actualizarFechaUltimaModificacionDePresupuestosEnOportunidad((List<Quote>)newList);
        PresupuestoUtil.cambiarEstadoNegociacion((List<Quote>)newList);

        //PresupuestoUtil.crearEnergiasEnOportunidad(newList);
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
    	System.Debug('## afterUpdate presupuesto: ' + newList);
    	PresupuestoUtil.actualizarFechaUltimaModificacionDePresupuestosEnOportunidad((List<Quote>)newList);
        PresupuestoUtil.cambiarEstadoNegociacion((List<Quote>)newList);
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