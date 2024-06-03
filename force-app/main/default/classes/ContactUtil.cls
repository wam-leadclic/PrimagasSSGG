public with sharing class ContactUtil 
{
    private static Map<Id, Individual> personasMap
    {
        get
        {
            if(personasMap == null)
            {
                personasMap = new Map<Id, Individual>();
            }
            return personasMap;
        }
        set;
    }

    private static Map<Id, Account> cuentasMap
    {
        get
        {
            if(cuentasMap == null)
            {
                cuentasMap = new Map<Id, Account>();
            }
            return cuentasMap;
        }
        set;
    }

    private static Map<Id, Map<Id,Contact>> contactosMap
    {
        get
        {
            if(contactosMap == null)
            {
                contactosMap = new Map<Id, Map<Id,Contact>>();
            }
            return contactosMap;
        }
        set;
    }

    private static Map<Id, Individual> personasToUpdate
    {
        get
        {
            if(personasToUpdate == null)
            {
                personasToUpdate = new Map<Id, Individual>();
            }
            return personasToUpdate;
        }
        set;
    }

    private static Map<Id, Individual> personasToDelete
    {
        get
        {
            if(personasToDelete == null)
            {
                personasToDelete = new Map<Id, Individual>();
            }
            return personasToDelete;
        }
        set;
    }

    private static Map<Id, Account> cuentasToUpdate
    {
        get
        {
            if(cuentasToUpdate == null)
            {
                cuentasToUpdate = new Map<Id, Account>();
            }
            return cuentasToUpdate;
        }
        set;
    }
    
    /**
    *   Recupera los registros Persona a los que estan asociados las cuentas personales
    **
    *  @author rfernandez
    *  @date 15/05/2018
    *  @param list<Contact> contactList - Lista de contactos
    *  @where Bulk after 
    */
    public static void recuperarPersonas(List<Contact> contactList, Map<Id, Contact> oldMap)
    {
        Set<Id> personasByIdList = new Set<Id>();

        if(contactList != null)
        {
            for(Contact contacto : contactList)
            {
                if(contacto.IndividualId != null)
                {
                    personasByIdList.add(contacto.IndividualId);
                }
            }
        }else//Para el after delete
        {
            for(Contact contacto : oldMap.values())
            {
                if(contacto.IndividualId != null)
                {
                    personasByIdList.add(contacto.IndividualId);
                }
            }
        }

        for(Individual persona : [SELECT Id, Email__c, FirstName, LastName FROM Individual WHERE Id IN: personasByIdList])
        {
            personasMap.put(persona.Id, persona);
        }
    }

    /**
    *   Recupera las cuentas a las que estan asociados los contactos
    **
    *  @author rfernandez
    *  @date 25/07/2018
    *  @param list<Contact> contactList - Lista de contactos
    *  @where Bulk after 
    */
    public static void recuperarCuentas(List<Contact> contactList, Map<Id, Contact> oldMap)
    {
        Set<Id> accountIdsList = new Set<Id>();
        for(Contact contacto : contactList)
        {
            if(contacto.AccountId != null)
            {
                accountIdsList.add(contacto.AccountId);
            }
        }
        for(Account cuenta : [SELECT Id, RecordTypeId, Convertido__c, E_mail__c FROM Account WHERE Id IN: accountIdsList])
        {
            cuentasMap.put(cuenta.Id, cuenta);
        }
    }

    /**
    *   Crea un nuevo registro persona en caso de no existir y asigna el contacto a este registro
    **
    *  @author rfernandez
    *  @date 15/05/2018
    *  @param list<Contact> contactList - Lista de contactos
    *  @where Before insert 
    */
    public static void crearRegistrosPersona(List<Contact> contactList)
    {
        Map<Contact, Individual> contactoPersonaMap = new Map<Contact, Individual>();
        Set<Id> personasIdsList = new Set<Id>();

        Individual nuevaPersona;
        for(Contact contacto : contactList)
        {
            if(contacto.IndividualId == null)
            {
                nuevaPersona = new Individual(
                                        FirstName   = contacto.FirstName, 
                                        LastName    = contacto.LastName, 
                                        Salutation  = contacto.Salutation);   
                if(String.isNotBlank(contacto.Email))
                {
                    nuevaPersona.Email__c = contacto.Email;
                }else if(String.isNotBlank(contacto.Otra_direcci_n_de_correo_electr_nico__c))
                {
                    nuevaPersona.Email__c = contacto.Otra_direcci_n_de_correo_electr_nico__c;
                }else if(String.isNotBlank(contacto.Otra_direcci_n_de_correo_electr_nico_2__c))
                {
                    nuevaPersona.Email__c = contacto.Otra_direcci_n_de_correo_electr_nico_2__c;
                }

                contactoPersonaMap.put(contacto, nuevaPersona);
            }
        }

        //Insercion de nuevas personas
        if(!contactoPersonaMap.isEmpty())
        {
            insert contactoPersonaMap.values();
        }

        //Generamos el hash para cada persona. Necesitamos el Id de la persona para generar el hash.
        for(Individual persona : contactoPersonaMap.values())
        {
            personasIdsList.add(persona.Id);
        }

        Map<Id, String> idHashMap = Util.calcularHashMasivo(personasIdsList);
        
        for(Individual persona : contactoPersonaMap.values())
        {
            if(idHashMap.containsKey(persona.Id))
            {
                persona.Hash__c = idHashMap.get(persona.Id);
            }
        }

        //Actualizamos las personas para generar el hash
        if(!contactoPersonaMap.isEmpty())
        {
            update contactoPersonaMap.values();
        }

        //Volvemos a recorrer los candidatos para asignarle la persona correspondiente
        for(Contact contacto : contactList)
        {
            if(contactoPersonaMap.containsKey(contacto))
            {
                contacto.IndividualId = contactoPersonaMap.get(contacto).Id;
            }
        }
    }

    /**
    *   Si los datos entre el contacto y la persona no coinciden, se actualiza la persona.
    **
    *  @author rfernandez
    *  @date 15/05/2018
    *  @param list<Contact> contactList - Lista de contactos
    *  @where Before insert 
    */
    public static void actualizarRegistrosPersona(List<Contact> contactList, Map<Id, Contact> oldMap)
    {
        for(Contact contacto : contactList)
        {
            if(contacto.IndividualId != null && personasMap.containsKey(contacto.IndividualId) && 
                (       contacto.FirstName                                    != oldMap.get(contacto.Id).FirstName 
                    ||  contacto.LastName                                     != oldMap.get(contacto.Id).LastName
                    ||  contacto.Email                                        != oldMap.get(contacto.Id).Email
                    ||  contacto.Otra_direcci_n_de_correo_electr_nico__c     != oldMap.get(contacto.Id).Otra_direcci_n_de_correo_electr_nico__c
                    ||  contacto.Otra_direcci_n_de_correo_electr_nico_2__c   != oldMap.get(contacto.Id).Otra_direcci_n_de_correo_electr_nico_2__c)
            )
            {
                Individual persona = personasMap.get(contacto.IndividualId);
                persona.FirstName   = contacto.FirstName;
                persona.LastName    = contacto.LastName;

                if(String.isNotBlank(contacto.Email) && (contacto.Email != personasMap.get(contacto.IndividualId).Email__c))
                {
                    persona.Email__c = contacto.Email;
                }else if(String.isNotBlank(contacto.Otra_direcci_n_de_correo_electr_nico__c) && (contacto.Otra_direcci_n_de_correo_electr_nico__c != personasMap.get(contacto.IndividualId).Email__c))
                {
                    persona.Email__c = contacto.Otra_direcci_n_de_correo_electr_nico__c;
                }else if(String.isNotBlank(contacto.Otra_direcci_n_de_correo_electr_nico_2__c) && (contacto.Otra_direcci_n_de_correo_electr_nico_2__c != personasMap.get(contacto.IndividualId).Email__c))
                {
                    persona.Email__c = contacto.Otra_direcci_n_de_correo_electr_nico_2__c;
                }               
                personasToUpdate.put(persona.Id, persona);
            }
        }
    }

    /**
    *   Borra los registros persona siempre y cuando no exista un registro asociado a ellos.
    **
    *  @author rfernandez
    *  @date 15/05/2018
    *  @param list<Contact> contactList - Lista de contactos
    *  @where After delete 
    */
    public static void eliminarRegistroPersona(Map<Id, Contact> oldMap)
    {
        if(!personasMap.isEmpty())
        {
            Set<Id> personasNoEliminables = new Set<Id>();

            //recuperamos personas que siguen referenciadas por otros candidatos, cuentas o contactos
            personasNoEliminables = Util.recuperarRegistrosQueApuntenAPersonas('Lead', 'IndividualId', personasNoEliminables, personasMap);
            personasNoEliminables = Util.recuperarRegistrosQueApuntenAPersonas('Account', 'PersonIndividualId', personasNoEliminables, personasMap);
            personasNoEliminables = Util.recuperarRegistrosQueApuntenAPersonas('Contact', 'IndividualId', personasNoEliminables, personasMap);

            //personasMap contiene todas las personas a las que estaba asociadas las cuentas
            for(Contact contacto : oldMap.values())
            {
                if(!personasNoEliminables.contains(contacto.IndividualId) && personasMap.containsKey(contacto.IndividualId))
                {
                    personasToDelete.put(personasMap.get(contacto.IndividualId).Id, personasMap.get(contacto.IndividualId));
                }
            }
        }
    }

    /**
    *   Si se inserta un contacto y el tipo de registro de la cuenta es existente empresa, se deben marcar sus preferencias
    **
    *  @author rfernandez
    *  @date 15/05/2018
    *  @param list<Contact> contactList - Lista de contactos
    *  @where After insert 
    *  @change rcastanos (05/06/2019) Se modifica el acceso al tipo de registro. Ahora se hace mediante la propiedad objectsRecordTypesMap
    */
    public static void aceptarPreferencias(List<Contact> contactList)
    {
        for(Contact contacto : contactList)
        {
            RecordType clienteExistente = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');

            if(contacto.AccountId != null 
                && cuentasMap.containsKey(contacto.AccountId) 
                && cuentasMap.get(contacto.AccountId).RecordTypeId == clienteExistente.Id
                && personasMap.containsKey(contacto.IndividualId)
            )
            {
                Individual persona;
                if(personasToUpdate.containsKey(contacto.IndividualId))
                {
                    persona =  personasToUpdate.get(contacto.IndividualId);
                }else{
                    persona =  personasMap.get(contacto.IndividualId);
                }
                persona.Fecha_promociones__c        = System.now();
                persona.Promociones__c              = true;
                persona.Fecha_encuestas__c          = System.now();
                persona.Encuestas_satisfaccion__c   = true;
                personasToUpdate.put(persona.Id, persona);
            }
        }
    }

    /**
    *   Encargado de verificar que la cuenta con la que está relacionado tiene el campo Convertido__c a true. 
        De ser así, se actualizará el campo E_mail__c de la cuenta con la información del campo Email del contacto. 
        Además, el método se encargará de poner a false el campo Convertido__c de forma que, 
        si se crea un nuevo contacto para esa cuenta, el campo E_mail__c no será actualizado automáticamente
    **
    *  @author rcastanos
    *  @date 11/06/2019
    *  @param list<Contact> contactList - Lista de contactos
    *  @where After insert 
    */
    public static void actualizarEmailCuenta(List<Contact> contactList)
    {
        for(Contact contacto : contactList)
        {
            if(contacto.AccountId != null && contacto.Email != null)
            {
                Account cuenta = cuentasMap.get(contacto.AccountId);

                if(cuenta != null && cuenta.Convertido__c)
                {
                    cuenta.E_mail__c = contacto.Email;
                    cuenta.Convertido__c = false;

                    cuentasToUpdate.put(cuenta.Id, cuenta);
                }

            }
            
        }
    }

    /**
    *   Encargado de generar un mapa de listas con todos los contactos asociados a la cuenta con la que está relacionada
        el contacto que está siendo insertado o actualizado
    **
    *  @author rcastanos
    *  @date 12/06/2019
    *  @param list<Contact> contactList - Lista de contactos
    *  @where Bulk before y Bulk after
    */
    public static void recuperarContactosAsociadosACuenta(List<Contact> contactList, Map<Id,Contact> oldMap)
    {
        Set<Id> accountIds = new Set<Id>();
        
        //Primero recuperamos todos las cuentas asociadas a los contactos
        if(contactList != null)
        {
            for(Contact contacto : contactList)
            {
                if(contacto.AccountId != null)
                {
                    accountIds.add(contacto.AccountId);
                }
            }

            //Recogemos todos los contactos asociados a las cuentas y generamos un mapa por cada cuenta sus contactos
            for(Contact contacto : [SELECT Id, AccountId, Contacto_principal__c FROM Contact WHERE AccountId IN: accountIds])
            {
                Map<Id,Contact> contactosCuenta = contactosMap.get(contacto.AccountId);

                if(contactosCuenta != null && !contactosCuenta.isEmpty())
                {
                    contactosCuenta.put(contacto.Id, contacto);
                }
                else
                {
                    contactosCuenta = new Map<Id,Contact>();
                    contactosCuenta.put(contacto.Id, contacto);

                    contactosMap.put(contacto.AccountId, contactosCuenta);
                }
                
            }
        }
        
    }

    /**
    *   Encargado de comprobar si el contacto insertado o actualizado es el único contacto de la cuenta:
        - Si es el único contacto de la cuenta, se marcará como contacto principal
        - Si existen más contactos para la misma cuenta se deberá comprobar si alguno se encuentra marcado como principal
          y, de ser así, el contacto no será marcado como principal
        - Si el contacto insertado o actualizado viene con el campo Contacto_principal__c a true y ya existe un contacto principal
          para la cuenta, se deberá lanzar un error indicando al usuario que antes de marcar el contacto como principal, deberá desmarcar el ya existente
        - Si se insertan varios contactos a la vez para una nueva cuenta, se deberá comprobar si existe un contacto principal. 
          Si existe uno se mantiene y si no existe se marcará uno de ello como principal (cualquiera).
    **
    *  @author rcastanos
    *  @date 12/06/2019
    *  @param list<Contact> contactList - Lista de contactos
    *  @where Before insert y before update
    */
    public static void comprobarContactoPrincipal(List<Contact> contactList, Map<Id,Contact> oldMap)
    {
        //Primero creamos un mapa de la cuenta y sus contactos asociados entrantes
        Map<Id, Map<Id, Contact>> mapaContactosNuevos = generarMapaCuentaContactos(contactList);

        //Recorremos el mapa de cuentas con contactos a insertar/actualizar
        for(Id idCuenta : mapaContactosNuevos.keySet())
        {
            //Comprobamos si la cuenta ya tiene un contacto principal
            Boolean existeContactoPrincipal = existeContactoPrincipal(idCuenta);

            //Comprobamos cuantos nuevos contactos principales se quieren insertar para la cuenta
            Integer contadorNuevoContactoPrincipal = contadorNuevoContactoPrincipal(mapaContactosNuevos.get(idCuenta), oldMap);

            //Si se quiere insertar un contacto principal pero la cuenta ya tiene uno, lanzamos un error
            if(existeContactoPrincipal && contadorNuevoContactoPrincipal > 0)
            {
                contactList[0].addError('Ya existe un contacto prinpical para la cuenta. Desmarca antes un contacto principal para después añadir otro');
            }
            //Si se quiere insertar más de un contacto principal para la misma cuenta, lanzamos un error
            else if(contadorNuevoContactoPrincipal > 1)
            {
                contactList[0].addError('No se puede marcar más de un contacto principal para una cuenta');

            }
            else 
            {
                Id contactoNuevoId = mapaContactosNuevos.get(idCuenta).values()[0].Id;
                
                //Si la cuenta no tiene ningún contacto asociado o la cuenta tiene solo un contacto y es el que se está actualizando
                if( (contactosMap.get(idCuenta) == null) || 
                    (contactosMap.get(idCuenta) != null && contactosMap.get(idCuenta).size() == 1 && contactoNuevoId == contactosMap.get(idCuenta).values()[0].Id))
                {
                    //Si no se ha marcado ningún contacto de los nuevos como principal marcamos el primero como principal
                    if(contadorNuevoContactoPrincipal == 0)
                    {
                        mapaContactosNuevos.get(idCuenta).values()[0].Contacto_principal__c = true;
                    }
                    
                }
            }
    
        }
  
    }

    /**
    *   Encargado de generar un mapa de cuenta y sus contactos asociados entrantes
    **
    *  @author rcastanos
    *  @date 12/06/2019
    *  @param list<Contact> contactList - Lista de contactos
    *  @where comprobarContactoPrincipal
    */
    public static Map<Id, Map<Id, Contact>> generarMapaCuentaContactos(List<Contact> contactList)
    {
        Map<Id, Map<Id, Contact>> mapaContactosNuevos = new Map<Id, Map<Id, Contact>>();

        for(Contact contacto : contactList)
        {
            Map<Id, Contact> contactosCuenta = mapaContactosNuevos.get(contacto.AccountId);

            if(contactosCuenta != null && !contactosCuenta.isEmpty())
            {
                contactosCuenta.put(contacto.Id, contacto);
            }
            else
            {
                contactosCuenta = new Map<Id, Contact>();
                contactosCuenta.put(contacto.Id, contacto);

                mapaContactosNuevos.put(contacto.AccountId, contactosCuenta);
            }
        }

        return mapaContactosNuevos;

    }

    /**
    *   Encargado de verificar si existe un contacto principal para la cuenta
    **
    *  @author rcastanos
    *  @date 12/06/2019
    *  @param Id idCuenta - Id de la cuenta a comprobar los contactos
    *  @where comprobarContactoPrincipal
    */
    public static Boolean existeContactoPrincipal(Id idCuenta)
    {
        Boolean existeContactoPrincipal = false;
        
        //Comprobamos si la cuenta ya tiene un contacto principal
        if(contactosMap.get(idCuenta) != null)
        {
            for(Id idContacto : contactosMap.get(idCuenta).keySet())
            {
                Contact contacto = contactosMap.get(idCuenta).get(idContacto);
                if(contacto.Contacto_principal__c)
                {
                    return true;
                }
            }
        }

        return existeContactoPrincipal;
    }

    /**
    *   Encargado de verificar cuantos contactos principales se quieren insertar para una cuenta
    **
    *  @author rcastanos
    *  @date 12/06/2019
    *  @param Id idCuenta - Id de la cuenta a comprobar los contactos
    *  @where comprobarContactoPrincipal
    */
    public static Integer contadorNuevoContactoPrincipal(Map<Id, Contact> mapaContactosNuevos, Map<Id,Contact> oldMap)
    {
        Integer contadorNuevoContactoPrincipal = 0;
        
        //Recorremos todos los contactos de la cuenta
        for(Id idContacto : mapaContactosNuevos.keySet())
        {
            Contact nuevoContacto = mapaContactosNuevos.get(idContacto);

            if(oldMap != null)
            {
                Contact viejoContacto = oldMap.get(idContacto);

                if(viejoContacto != null && nuevoContacto.Contacto_principal__c && !viejoContacto.Contacto_principal__c)
                {
                    contadorNuevoContactoPrincipal++;
                }
            }
            else
            {
                if(nuevoContacto.Contacto_principal__c)
                {
                    contadorNuevoContactoPrincipal++;
                }
            }
            
        }
        
        return contadorNuevoContactoPrincipal;
    }

    /**
    *   Execute DMLs after data process
    **
    *  @author rfernandez
    *  @date 17/05/2018    
    *  @where andFinally
    */
    public static void insertUpdateDeleteRecords()
    {
        
        if(!personasToUpdate.isEmpty())
        {   
            update personasToUpdate.values();
        }

        if(!personasToDelete.isEmpty())
        {   
            delete personasToDelete.values();
        }

        if(!cuentasToUpdate.isEmpty())
        {   
            update cuentasToUpdate.values();
        }

        personasToUpdate.clear();
        personasToDelete.clear();
        cuentasToUpdate.clear();
    }

}