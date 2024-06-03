public class PedidoGasHandler implements ITrigger{
	public PedidoGasHandler() {
		
	}


    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)
    {

    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)
    {
    }


    public void beforeInsert(list<SObject> newList)
    {

    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
    }
    
    public void beforeDelete(map<Id,SObject> oldMap)
    {
        
    }
    

    public void afterInsert(list<SObject> newList)
    {
        PedidoGasUtil.SincronizarPedidoDeGas(newList) ;
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
    }
     
    public void afterDelete(map<Id,SObject> oldMap)
    {
    	
    }
     
    public void andFinally()
    {
    	
    }
}