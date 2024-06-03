/**
 * Trigger Handler for the Account SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class AccountHandler implements ITrigger
{
    public AccountHandler() {}
 
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)
    {

    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)
    {
    	if(Trigger.isUpdate)
        {
            AccountUtil.recuperarContactos((List<Account>)newList, (Map<Id, Account>)oldMap);
            AccountUtil.recuperarPersonasDeContactos((List<Account>)newList, (Map<Id, Account>)oldMap);
        }

        if(Trigger.isDelete)
        {

        }
    }
    
    public void beforeInsert(list<SObject> newList)
    {
        AccountUtil.actualizarUsuarioWebClientes(newList);
        AccountUtil.comprobarProcedenciaDeConversion(newList);
        AccountUtil.procesarCuentasTriggerParaValidarIBAN((List<Account>)newList, (Map<Id, Account>)Trigger.oldMap);
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        AccountUtil.actualizarUsuarioWebClientes(newList);
        AccountUtil.procesarCuentasTriggerParaValidarIBAN((List<Account>)newList, (Map<Id, Account>)Trigger.oldMap);
        //AccountUtil.bloquearActualizacionCuenta(newList);
        AccountUtil.definirOrigenDeModificacion(newList, (Map<Id, Account>)oldMap);
    }
    
    public void beforeDelete(map<Id,SObject> oldMap)
    { 
    }

    public void afterInsert(list<SObject> newList)
    {
        /*Copiar Id de Cuenta en campo ExternalId */
        List<Account> accountToUpdate = new List<Account>();     
        for(Account iCuenta : (List<Account>)newList){
            accountToUpdate.add(new Account(Id = iCuenta.Id, ExternalId__c = iCuenta.Id) );
        }
        if(accountToUpdate.size()>0){update accountToUpdate;}
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
    	AccountUtil.SincronizarCliente((List<Account>)newList, (Map<Id, Account>) oldMap);	

        AccountUtil.aceptarPreferenciasPorClienteExistente((List<Account>)newList, (Map<Id, Account>) oldMap);
        
    }
     
    public void afterDelete(map<Id,SObject> oldMap)
    {

    }
     
    public void andFinally()
    {
    	AccountUtil.insertUpdateDeleteRecords();
    }
}