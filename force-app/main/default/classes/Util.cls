public with sharing class Util 
{
	public class customException extends Exception {}

    //gserrano 10-1-2019
    /*Recupera el valor para activar logs de metadatos personalizados*/
    public static Boolean LogsNavisionActivados 
    {
        get
        {
            if(LogsNavisionActivados == null)
            {
                LogsNavisionActivados = Boolean.valueOf([SELECT Activado__c FROM LogNavision__mdt LIMIT 1].Activado__c);
            }
            return LogsNavisionActivados;
        }
        set;
    } 

   	/*Recupera el hash id de metadatos personalizados*/
    public static String hashID
    {
        get
        {
            if(hashID == null)
            {
                hashID = String.valueOf([SELECT Valor__c FROM Parametros__mdt WHERE DeveloperName = 'Hash_Id' LIMIT 1]);
            }
            return hashID;
        }
        set;
    }

    //Propiedad para la obtención de valores para la integración con Navision
    //@rcastanos (04/06/2019)
    public static Map<String, String> valoresIntegracionNavision
    {
        get
        {   
            //Si no hemos recuperado todavía los valores lo hacemos y preparamos el mapa
            if(valoresIntegracionNavision == null)
            {
                valoresIntegracionNavision = new Map<String, String>();

                //Recuperamos todos los metadatos
                List<Integracion_Navision__mdt> integracionNavisionMetadatos = [SELECT MasterLabel, Valor__c FROM Integracion_Navision__mdt];

                //Recorremos todos los metadatos que hemos recuperado para generar el mapa
                for(Integracion_Navision__mdt registro : integracionNavisionMetadatos)
                {
                    valoresIntegracionNavision.put(registro.MasterLabel, registro.Valor__c);
                }
            }

            return valoresIntegracionNavision; 
        }

        set;
    }

    //Propiedad para saber si estamos en una sandbox o no
    //@rcastanos (05/06/2019)
    public static Boolean runningInASandbox
    {
        get
        {
            if(runningInASandbox == null)
            {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return runningInASandbox;
        }
        set;
    }

    //Propiedad para la obtención de valores para la activación/desactivación de los triggers
    //@rcastanos (04/06/2019)
    public static Map<String, Configuration_Switch__mdt> configurationSwitchMap
    {
        get
        {   
            //Si no hemos recuperado todavía los valores lo hacemos y preparamos el mapa
            if(configurationSwitchMap == null)
            {
                configurationSwitchMap = new Map<String, Configuration_Switch__mdt>();

                //Recuperamos todos los metadatos
                List<Configuration_Switch__mdt> triggersMetadatos = [SELECT DeveloperName, Name__c, Activo__c FROM Configuration_Switch__mdt];

                //Recorremos todos los metadatos que hemos recuperado para generar el mapa
                for(Configuration_Switch__mdt registro : triggersMetadatos)
                {
                    configurationSwitchMap.put(registro.Name__c, registro);
                }
            }

            return configurationSwitchMap; 
        }

        set;
    }

    //Propiedad para la obtención de un mapa que contiene todos los RecordTypes
    //@rcastanos (05/06/2019)
    public static Map<String, Map<String, RecordType>> objectsRecordTypesMap
    {
        get
        {   
            if(objectsRecordTypesMap == null)
            {    
                objectsRecordTypesMap = new Map<String, Map<String, RecordType>>();
                for(RecordType rType : [Select Id, DeveloperName, SObjectType From RecordType Order By CreatedDate ASC])
                {
                    if(!objectsRecordTypesMap.containsKey(rType.SObjectType))
                    {
                        objectsRecordTypesMap.put(rType.SObjectType, new Map<String, RecordType>());
                    }

                    if(!objectsRecordTypesMap.get(rType.SObjectType).containsKey(rType.DeveloperName))
                    {
                        objectsRecordTypesMap.get(rType.SObjectType).put(rType.DeveloperName, rType);
                    }
                }
            }

            return objectsRecordTypesMap;
        }
        set;
    }

    //Propiedad para la obtención del id de la cuenta TELPER
    //@rcastanos (05/06/2019)
    public static Id idClienteTelperWeb
    {
        get
        {   
            if(idClienteTelperWeb == null)
            {    
                List<Account> telper = [SELECT Id FROM Account WHERE Name = 'TELPER' LIMIT 1];

                if(telper != null && !telper.isEmpty())
                {
                    idClienteTelperWeb = telper[0].Id;
                }
                
            }

            return idClienteTelperWeb;
        }
        set;
    }

    //Propiedad para la obtención del id del usuario Gemma Montejano
    //@rcastanos (05/06/2019)
    public static Id idUserSolicitudDuplicadoFactura
    {
        get
        {   
            if(idUserSolicitudDuplicadoFactura == null)
            {    
                User usuario = [SELECT Id FROM User WHERE Name = 'Gemma Montejano' LIMIT 1];
                idUserSolicitudDuplicadoFactura = usuario.Id;
            }

            return idUserSolicitudDuplicadoFactura;
        }
        set;
    }

    //Propiedad para la obtención del id del usuario Eva Calabuig
    //@rcastanos (05/06/2019)
    public static Id idUserIncidencia
    {
        get
        {   
            if(idUserIncidencia == null)
            {    
                User usuario = [SELECT Id FROM User WHERE Name = 'Eva Calabuig' LIMIT 1];
                idUserIncidencia = usuario.Id;
            }

            return idUserIncidencia;
        }
        set;
    }

    //Propiedad para la obtención de constantes NewSales
    //@rcastanos (05/06/2019)
    public static Map<String, String> constantesNewSales
    {
        get
        {   
            //Si no hemos recuperado todavía los valores lo hacemos y preparamos el mapa
            if(constantesNewSales == null)
            {
                constantesNewSales = new Map<String, String>();

                //Recuperamos todos los metadatos
                List<Constantes_NewSales__mdt> constantesNewSalesMetadatos = [SELECT DeveloperName, Valor__c FROM Constantes_NewSales__mdt];

                //Recorremos todos los metadatos que hemos recuperado para generar el mapa
                for(Constantes_NewSales__mdt registro : constantesNewSalesMetadatos)
                {
                    constantesNewSales.put(registro.DeveloperName, registro.Valor__c);
                }
            }

            return constantesNewSales; 
        }

        set;
    }

    //Propiedad para la obtención de constantes WebClientes
    //@rcastanos (05/06/2019)
    public static Map<String, String> constantesWebClientes
    {
        get
        {   
            //Si no hemos recuperado todavía los valores lo hacemos y preparamos el mapa
            if(constantesWebClientes == null)
            {
                constantesWebClientes = new Map<String, String>();

                //Recuperamos todos los metadatos
                List<Constantes_WebClientes__mdt> constantesWebClientesMetadatos = [SELECT DeveloperName, Valor__c FROM Constantes_WebClientes__mdt];

                //Recorremos todos los metadatos que hemos recuperado para generar el mapa
                for(Constantes_WebClientes__mdt registro : constantesWebClientesMetadatos)
                {
                    constantesWebClientes.put(registro.DeveloperName, registro.Valor__c);
                }
            }

            return constantesWebClientes; 
        }

        set;
    }
	
    public static String calcularHash(Id identificador)
    {
        String hash = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-512', Blob.valueOf(String.valueOf(identificador) + hashID)));
        return hash;
    }

    public static Map<Id, String> calcularHashMasivo(Set<Id> identificadoresList)
    {
        Map<Id, String> idHashMap = new Map<Id, String>();
        String hash;
        for(Id identificador : identificadoresList)
        {
            hash = calcularHash(identificador);
            idHashMap.put(identificador, hash);
        }
        
        return idHashMap;
    }

    public static Set<Id> recuperarRegistrosQueApuntenAPersonas(String objeto, String campo, Set<Id> personasNoEliminables,  Map<Id, Individual> personasMap)
    {
        String recordIds = '(';
        for(Id record : personasMap.keySet())
        {
            recordIds +=  '\''+String.valueOf(record)+'\', ';
        }
        recordIds = recordIds.substringBeforeLast(', '); 
        recordIds += ')';

        for(sObject persona : Database.query('SELECT Id FROM Individual WHERE Id IN (SELECT '+campo+' FROM '+objeto+') AND Id IN '+recordIds) )
        {
            if(!personasNoEliminables.contains(persona.Id))
            {
                personasNoEliminables.add(persona.Id);
            }
        }
        return personasNoEliminables;
    }

    public static String obtenerIP() 
    {
        // True-Client-IP has the value when the request is coming via the caching integration.
        String ip = ApexPages.currentPage().getHeaders().get('True-Client-IP');  

        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if(String.isBlank(ip)) 
        {
            ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)
 
        if(String.isBlank(ip)) 
        {
            ip = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }// get IP address from standard header if proxy in use
        //System.debug('IP '+ip);
        return ip; 
    }

    /*
    ===========================================================================================================================================================================
    * -- GENERADOR DE REGISTROS  ----------------------------------------------------------------------------------------------------------------------------------------------
    ===========================================================================================================================================================================
    */
    public static List<Lead> generarCandidatos(Integer numCandidatos, Integer inicio)
    {
        List<Lead> candidatosList = new List<Lead>();
        for(Integer i = inicio ; i < (inicio + numCandidatos) ; i++)
        {
            Lead candidato = new Lead(
                FirstName   = 'TestFirstName'+i,
                LastName    = 'TestLastName'+i,
                Email       = 'test'+i+'@test.com',
                N_mero_Cliente_Anterior__c = 1111+i
                );
            candidatosList.add(candidato);
        }
        return candidatosList;
    }

    public static List<Account> generarCuentas(Integer numCuentas, Integer inicio, Id tipoRegistro)
    {
        List<Account> cuentasList = new List<Account>();
        Account cuenta;
        for(Integer i = inicio ; i < (inicio + numCuentas) ; i++)
        {
            cuenta = new Account();

            cuenta.Name         = 'TestName'+i;
            cuenta.E_mail__c    = 'test'+i+'@test.com';
            
            cuenta.RecordTypeId = tipoRegistro;
    
            cuentasList.add(cuenta);
        }
        return cuentasList;
    }

    /**
     * genera cuentas de test con IBAN
     * 
     * @author pmartin
     * @date 18/002/2020
     */
    public static List<Account> generarCuentasConIbanCorrecto(Integer numCuentas, Integer inicio, Id tipoRegistro)
    {
        List<Account> cuentasList = new List<Account>();
        Account cuenta;
        for(Integer i = inicio ; i < (inicio + numCuentas) ; i++)
        {
            cuenta = new Account();

            cuenta.Name         = 'TestName'+i;
            cuenta.E_mail__c    = 'test'+i+'@test.com';
            /**
             * hay que generar un iban para las cuentas de test
             */
            cuenta.IBAN__c      = 'ES8921004544981234567897';
            
            cuenta.RecordTypeId = tipoRegistro;
    
            cuentasList.add(cuenta);
        }
        return cuentasList;
    }
    
    /**
     * genera cuentas de test con IBAN
     * 
     * @author pmartin
     * @date 18/002/2020
     */
    public static List<Account> generarCuentasConIbanIncorrecto(Integer numCuentas, Integer inicio, Id tipoRegistro)
    {
        List<Account> cuentasList = new List<Account>();
        Account cuenta;
        for(Integer i = inicio ; i < (inicio + numCuentas) ; i++)
        {
            cuenta = new Account();

            cuenta.Name         = 'TestName'+i;
            cuenta.E_mail__c    = 'test'+i+'@test.com';
            /**
             * hay que generar un iban para las cuentas de test
             */
            cuenta.IBAN__c      = 'ES892100454498123456789';
            
            cuenta.RecordTypeId = tipoRegistro;
    
            cuentasList.add(cuenta);
        }
        return cuentasList;
    }
    public static List<Contact> generarContactos(Integer numContactosPorCuenta, Integer inicio, List<Account> cuentasList)
    {
        List<Contact> contactosList = new List<Contact>();
        for(Account cuenta : cuentasList)
        {
            for(Integer i = inicio ; i < (inicio + numContactosPorCuenta) ; i++)
            {
                Contact contacto = new Contact(
                    FirstName   = 'TestFirstName'+i,
                    LastName    = 'TestLastName'+i,
                    Email       = 'test'+i+'@test.com',
                    AccountId   = cuenta.Id
                    // Contacto_principal__c = true
                    );
                contactosList.add(contacto);
                System.debug('+CONTACTO '+contacto);
            }
        }
        return contactosList;
    }
    public static List<Contact> generarContactosPrincipales(Integer numContactosPorCuenta, Integer inicio, List<Account> cuentasList)
    {
        List<Contact> contactosList = new List<Contact>();
        for(Account cuenta : cuentasList)
        {
            for(Integer i = inicio ; i < (inicio + numContactosPorCuenta) ; i++)
            {
                Contact contacto = new Contact(
                    FirstName   = 'TestFirstName'+i,
                    LastName    = 'TestLastName'+i,
                    Email       = 'test'+i+'@test.com',
                    AccountId   = cuenta.Id,
                    Contacto_principal__c = true
                    );
                contactosList.add(contacto);
                System.debug('+CONTACTO '+contacto);
            }
        }
        return contactosList;
    }


    public static List<Individual> generarPersonas(Integer numPersonas, Integer inicio)
    {
        List<Individual> personasList = new List<Individual>();

        for(Integer i = inicio ; i < (inicio + numPersonas) ; i++)
        {
            Individual persona = new Individual(
                FirstName   = 'TestFirstName'+i,
                LastName    = 'TestLastName'+i,
                Email__c    = 'test'+i+'@test.com'
                );
            personasList.add(persona);
        }

        return personasList;
    }

    public static List<User> generarUsuarios(Integer numUsuarios, Integer inicio,Account cuenta)
    {
        List<User> usuariosList = new List<User>();

        for(Integer i = inicio; i < numUsuarios; i++)
        {
            User user = new User(
                alias = 'test12'+1,
                email='test12'+i+'@noemail.com',
                emailencodingkey='UTF-8',
                lastname='Testing'+i,
                languagelocalekey='en_US',
                localesidkey='en_US',
                country='United States',
                IsActive =true,
                ProfileId = '00e57000001oRRD',
                timezonesidkey='America/Los_Angeles',
                username='tester'+i+'@noemail.com'
            );

            usuariosList.add(user);
        }

        return usuariosList;
    }

    public static List<Contract> generarContratos(Integer numContratos, Integer inicio, Id tipoRegistro, Direcci_n_de_entrega__c direccionEntrega, String cuentaId)
    {
        List<Contract> contratosList = new List<Contract>();

        for(Integer i = inicio; i < numContratos; i++)
        {
            Contract contrato = new Contract(
                RecordTypeId = tipoRegistro,
                AccountId = cuentaId,
                StartDate = Date.today(),
                Consumo_previsto_tons__c = 100,
                Campa_a_relacionada__c = null,
                Entrega_de_producto__c = 'Automática',
                Direccion_de_entrega__c = direccionEntrega.Id,
                Status = 'Borrador'
            );

            contratosList.add(contrato);
            
        }

        return contratosList;
    }

    public static List<Solicitud_de_revision__mdt> obtenerMetadatosRevisionInterior()
    {
        List<Solicitud_de_revision__mdt> metadatoSolicitudRevision = [select Id, Asunto__c, Descripcion__c, Persona_asignada__c, Tipo_de_la_tarea__c from Solicitud_de_revision__mdt];
        if(!metadatoSolicitudRevision.isEmpty())
        {
            return metadatoSolicitudRevision;
        }
        else
        {
            return new List<Solicitud_de_revision__mdt>();    
        }
    }
}