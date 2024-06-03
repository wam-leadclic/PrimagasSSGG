/**
 * Trigger Handler for the Contact SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class ContactHandler implements ITrigger
{
    public ContactHandler() {}
 

    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)
    {
        ContactUtil.recuperarContactosAsociadosACuenta((List<Contact>)newList, null);
    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)
    {
        if(Trigger.isInsert)
        {
            ContactUtil.recuperarPersonas((List<Contact>)newList, null);
            ContactUtil.recuperarCuentas((List<Contact>)newList, null);
            ContactUtil.recuperarContactosAsociadosACuenta((List<Contact>)newList, null);
        }

        if(Trigger.isUpdate)
        {
            ContactUtil.recuperarPersonas((List<Contact>)newList, null);
            ContactUtil.recuperarCuentas((List<Contact>)newList, null);
            ContactUtil.recuperarContactosAsociadosACuenta((List<Contact>)newList, null);
        }

        if(Trigger.isDelete)
        {
            ContactUtil.recuperarPersonas(null, (Map<Id, Contact>)oldMap);
        }
    }

    public void beforeInsert(list<SObject> newList)
    {
        ContactUtil.comprobarContactoPrincipal((List<Contact>)newList, null);
        ContactUtil.crearRegistrosPersona((List<Contact>)newList);
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        ContactUtil.comprobarContactoPrincipal((List<Contact>)newList, (Map<Id, Contact>)oldMap);
    }
    
    public void beforeDelete(map<Id,SObject> oldMap)
    {
        
    }

    public void afterInsert(list<SObject> newList)
    {       
        ContactUtil.aceptarPreferencias((List<Contact>)newList);
        ContactUtil.actualizarEmailCuenta((List<Contact>)newList);
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {
        ContactUtil.actualizarRegistrosPersona((List<Contact>)newList, (Map<Id, Contact>) oldMap);
    }
     
    public void afterDelete(map<Id,SObject> oldMap)
    {
        ContactUtil.eliminarRegistroPersona((Map<Id, Contact>)oldMap);
    }

    public void andFinally()
    {
        ContactUtil.insertUpdateDeleteRecords();
    }
}