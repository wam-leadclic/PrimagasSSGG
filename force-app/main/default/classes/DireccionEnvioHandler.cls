/**
 * Trigger Handler for the Direcci_n_de_entrega__c SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class DireccionEnvioHandler implements ITrigger
{
    
    Map<String, Account> mapaClientes = new Map<String, Account>();
    //Map<String, String> mapaRecordTypeIDs = new Map<String, String>();

    // Constructor
    public DireccionEnvioHandler() {}
 
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
    	DireccionEnvioUtil.loadData((List<Direcci_n_de_entrega__c>)newList, mapaClientes /*, mapaRecordTypeIDs*/);
    }
    
    /**
     * These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)
    {
        
        /*CAMBIO A PEDIDO DE ALEJANDRO 14/12/2022. Cuando una DirecciondeEnvio contiene el Id_Navision e Id_Cliente_Navision se concatenan los valores en el ExternalId para realizar actuaizacion via API */
		/*for(Direcci_n_de_entrega__c iDireccion : (List<Direcci_n_de_entrega__c>) newList){
            if(String.isNotBlank(iDireccion.Id_Navision__c) && String.isNotBlank(iDireccion.Id_Cliente_Navision__c) ){
                iDireccion.ExternalId__c = iDireccion.Id_Cliente_Navision__c+'-'+iDireccion.Id_Navision__c;
            }
        }
        */
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        /*CAMBIO A PEDIDO DE ALEJANDRO 14/12/2022. Si hay algun cambio, y Id_Navision e Id_Cliente_Navision no son nulos, se actualiza el valor del ExternalId */
        /*for(Direcci_n_de_entrega__c iDireccion : (List<Direcci_n_de_entrega__c>) newList){
            if(String.isNotBlank(iDireccion.Id_Navision__c) && String.isNotBlank(iDireccion.Id_Cliente_Navision__c) ){
                iDireccion.ExternalId__c = iDireccion.Id_Cliente_Navision__c+'-'+iDireccion.Id_Navision__c;
            }else if(String.isBlank(iDireccion.Id_Navision__c) || String.isBlank(iDireccion.Id_Cliente_Navision__c) ){
                iDireccion.ExternalId__c = '';
            }
        }
        */
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
    	//DireccionEnvioUtil.SincronizarClientes((List<Direcci_n_de_entrega__c>)newList);	
    	DireccionEnvioUtil.SincronizarClientes((List<Direcci_n_de_entrega__c>)newList, mapaClientes/*, mapaRecordTypeIDs*/);
        DireccionEnvioUtil.ComprobarContratos(newList);
        /*Se asigna como ExternalId el Id de SF */
        List<Direcci_n_de_entrega__c> updateListDirecciones = new List<Direcci_n_de_entrega__c>();
        for(Direcci_n_de_entrega__c iDireccion : (List<Direcci_n_de_entrega__c>) newList){
            updateListDirecciones.add(new Direcci_n_de_entrega__c(Id=iDireccion.Id, ExternalId__c=iDireccion.Id)); 
        }
        if(updateListDirecciones.size()>0){
            update updateListDirecciones;
        }

        
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
    	//DireccionEnvioUtil.SincronizarClientes((List<Direcci_n_de_entrega__c>)newList);	
    	DireccionEnvioUtil.SincronizarClientes((List<Direcci_n_de_entrega__c>)newList, mapaClientes/*, mapaRecordTypeIDs*/);
        DireccionEnvioUtil.ComprobarContratos(newList);
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