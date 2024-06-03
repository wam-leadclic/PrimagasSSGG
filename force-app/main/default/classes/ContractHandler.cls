/**
 * Trigger Handler for the Contract SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class ContractHandler implements ITrigger
{
    
    Map<String, Account> mapaClientes = new Map<String, Account>();
    //Map<String, List<Elemento_de_servicio__c>> mapaActivos = new Map<String, List<Elemento_de_servicio__c>>();
    Map<String, Contract> mapaContratosAnteriores = new Map<String, Contract>();

    // Constructor
    public ContractHandler() {}
 
    /**
     * bulkBefore
     *
     * These methods are called prior to execution of a BEFORE or AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)
    {
		ContractUtil.loadData((List<Contract>)newList, mapaContratosAnteriores);
    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)
    {
    	ContractUtil.loadData((List<Contract>)newList, mapaClientes/*, mapaActivos*/);	

        if(Trigger.isInsert)
        {
            ContractUtil.createOpportunitiesMap((List<Contract>)newList);
        }
    }
    
    /**
     * These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)
    {
        ContractUtil.renovarContrato((List<Contract>)newList, mapaContratosAnteriores);
        ContractUtil.populateContractEndDate((List<Contract>)newList);
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        ContractUtil.populateContractEndDateUpdate((List<Contract>)newList, (Map<Id, Contract>)oldMap);
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
    	// ESTE MÉTODO NO SE USA ACTUALMENTE, SE COMENTA POR SI SE UTILIZA A FUTURO
        //ContractUtil.CrearContratosServicio((List<Contract>)newList);
        ContractUtil.cambiarEstadoOportunidadCerradaGanada((List<Contract>)newList);
        ContractUtil.updateOppsWithContract((List<Contract>)newList);
        //ContractUtil.populateContractEndDate((List<Contract>)newList);
        /*Copiar Id de Contrato en campo ExternalId */
        List<Contract> contractsToUpdate = new List<Contract>();     
        for(Contract iContrato : (List<Contract>)newList){
            contractsToUpdate.add(new Contract(Id = iContrato.Id, ExternalId__c = iContrato.Id) );
        }
        if(contractsToUpdate.size()>0){update contractsToUpdate;}

    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        //ContractUtil.procesoCambioTitularAPosteriori( (List<Contract>)oldMap.values(), (List<Contract>)newList );
    	ContractUtil.actualizarDatosClienteYDireccionEntrega((List<Contract>)newList, (map<Id,Contract>)oldMap, mapaClientes); //importante que se llame antes de registrarContrato para que se mande el cliente con los datos correctos a Navision
        ContractUtil.RegistrarContrato((List<Contract>)newList, (Map<Id, Contract>)oldMap, mapaClientes);
        ContractUtil.cambiarEstadoOportunidadCerradaGanada((List<Contract>)newList);
        ContractUtil.activarDireccionEntrega((List<Contract>)newList, (Map<Id, Contract>)oldMap);

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
    	ContractUtil.insertUpdateDeleteRecords();
    }
}