public with sharing class AccountUtil 
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

    private static Map<Id, List<Contact>> contactosMap
    {
        get
        {
            if(contactosMap == null)
            {
                contactosMap = new Map<Id, List<Contact>>();
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

    // La variable semáforo evitará que al actualizar un registro y sincronizarlo con Navision, al volver a actualizar la fecha
    // de última actualización o ID de Navision, se vuelva a tratar de sincronizar (bucle infinito)
    public static Boolean semaforoUpdate = true;

    // Método para mandar a sincronizar a Navision los clientes cuando han sido actualizados/insertados
    // y son del tipo de registro cliente existente o tienen ID de Navision
    //@rcastanos (05/06/2019) Modificación para obtener el tipo de registro mediante la propiedad objectsRecordTypesMap
    public static void SincronizarCliente(list<Account> newList, Map<Id,Account> oldMap)
    {
        //System.debug('## before SincronizarCliente semaforoUpdate: ' + semaforoUpdate);
        if (semaforoUpdate) 
        {         
            // Recuperamos el tipo de registro "Cliente existente"
            RecordType rts = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');

            if (newList != null)
            {
                List<String> clientesSync = new List<String>();
                
                for (Account cliente:newList)
                {
                    // Si son del tipo de registro Cliente existente o tienen un ID de Navision los mandamos a sincronizar
                    // Se hace doble validación, se comprueba que sea de tipo de registro Cliente existente y que tenga algún contrato Activado
                    // Validamos que se haya producido algun cambio en los campos a enviar para enviarlos
                    //System.debug('$$ - sincronizarCliente cliente.IBAN__c : '+cliente.IBAN__c);
                    //System.debug('$$ - sincronizarCliente oldMap.IBAN__c : '+oldMap.get(cliente.Id).IBAN__c);
                    if( 
                        (cliente.RecordTypeId == rts.Id) && 
                        !String.IsEmpty(cliente.Id_Navision__c) && 
                        (
                            cliente.Id_Navision__c              != oldMap.get(cliente.Id).Id_Navision__c || 
                            cliente.Calle_Facturacion__c        != oldMap.get(cliente.Id).Calle_Facturacion__c || 
                            cliente.Calle_2__c                  != oldMap.get(cliente.Id).Calle_2__c || 
                            cliente.Recibir_factura_por_mail__c != oldMap.get(cliente.Id).Recibir_factura_por_mail__c || 
                            cliente.Poblacion_Facturacion__c    != oldMap.get(cliente.Id).Poblacion_Facturacion__c || 
                            cliente.Codigo_Postal__c            != oldMap.get(cliente.Id).Codigo_Postal__c || 
                            cliente.Provincia__c                != oldMap.get(cliente.Id).Provincia__c || 
                            cliente.Pais__c                     != oldMap.get(cliente.Id).Pais__c || 
                            cliente.Phone                       != oldMap.get(cliente.Id).Phone || 
                            cliente.Mobile_Phone_No__c          != oldMap.get(cliente.Id).Mobile_Phone_No__c || 
                            cliente.Fax                         != oldMap.get(cliente.Id).Fax || 
                            cliente.Id_Fiscal__c                != oldMap.get(cliente.Id).Id_Fiscal__c || 

                            //gserrano 28/01/2019 se dejan de sincronizar estos campos a petición de Sandra
                            /*cliente.Cod_terminos_pago__c        != oldMap.get(cliente.Id).Cod_terminos_pago__c || 
                            cliente.Cod_forma_pago__c           != oldMap.get(cliente.Id).Cod_forma_pago__c || 
                            cliente.Cod_terminos_pago__c        != oldMap.get(cliente.Id).Cod_terminos_pago__c ||
                            cliente.Cod_terminos_pago__c        != oldMap.get(cliente.Id).Cod_terminos_pago__c || 
                            cliente.Cod_terminos_pago__c        != oldMap.get(cliente.Id).Cod_terminos_pago__c ||*/
                            (cliente.IsPersonAccount &&  (cliente.FirstName  != oldMap.get(cliente.Id).FirstName || cliente.LastName != oldMap.get(cliente.Id).LastName))|| 
                            (!cliente.IsPersonAccount && cliente.Name       != oldMap.get(cliente.Id).Name)||
                            cliente.E_mail__c                   != oldMap.get(cliente.Id).E_mail__c || 
                            cliente.Email2__c                   != oldMap.get(cliente.Id).Email2__c || 
                            cliente.Email3__c                   != oldMap.get(cliente.Id).Email3__c || 
                            //gserrano 28/01/2019 se dejan de sincronizar estos campos a petición de Sandra
                            /*cliente.D_as_pago__c              != oldMap.get(cliente.Id).D_as_pago__c || 
                            cliente.Cod_periodo_no_pago__c      != oldMap.get(cliente.Id).Cod_periodo_no_pago__c ||*/
                            cliente.OwnerId                     != oldMap.get(cliente.Id).OwnerId ||
                            //pmartin 01/04/2020 se añade el campo IBAN__c
                            cliente.IBAN__c                     != oldMap.get(cliente.Id).IBAN__c
                        )
                    )
                    {
                        clientesSync.add(cliente.Id);
                    }
                }
                // Enviamos los clientes correspondientes a sincronizar
                if(clientesSync.size() > 0) 
                    SyncNav.SincronizarClientesFuture(clientesSync);
            }
        }
        //System.debug('## after SincronizarCliente semaforoUpdate: ' + semaforoUpdate);
    }


    /**
    * Metodo encargado de marcar la variable de clase de oportunidad para saber que no hay que crear funciones de contacto cuando procede de conversion
    * @author rfernandez (16/02/2017)
    * @modificaciones 
    */
    public static void comprobarProcedenciaDeConversion(List<Account> listaCuentas)
    {
        for(Account cuenta: listaCuentas)
        {
            if(cuenta.Procede_de_conversion__c == true)
            {
                OpportunityUtil.semaforoCreacionFuncionesDeContacto = false;
                cuenta.Procede_de_conversion__c = false;
            }
        }
    }


    /**
    * Metodo encargado de actualizar el campo Usuario_Web_Clientes__c con el valor del campo Id_Fiscal__c
    * @author rfernandez (31/05/2017)
    * @modificaciones 
    */
    public static void actualizarUsuarioWebClientes(List<Account> listaCuentas)
    {
        for(Account cuenta: listaCuentas)
        {
            if(String.isNotBlank(cuenta.Id_Fiscal__c) && String.isEmpty(cuenta.Usuario_Web_Clientes__c))//Si hay algun valor en el id fiscal lo pasamos a Usuario_Web_Clientes__c
            {
                cuenta.Usuario_Web_Clientes__c = cuenta.Id_Fiscal__c;
            }
        }
    }


    /**
    *   Recupera los contactos asociados a cuentas de empresa
    **
    *  @author rfernandez
    *  @date 25/07/2018
    *  @param list<Account> accountList - Lista de cuentas
    *  @where Bulk after 
    *  @change rcastanos (05/06/2016) Modificación para obtener el tipo de registro mediante la propiedad objectsRecordTypesMap
    */
    public static void recuperarContactos(List<Account> accountList, Map<Id, Account> oldMap)
    {
        
        Set<Id> cuentasEmpresaList = new Set<Id>();

        for(Account cuenta : accountList)
        {
            RecordType clienteExistente = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
            RecordType clientePotencial = Util.objectsRecordTypesMap.get('Account').get('Cliente');

            if(cuenta.RecordTypeId == clienteExistente.Id && oldMap.get(cuenta.Id).RecordTypeId == clientePotencial.Id)
            {
                cuentasEmpresaList.add(cuenta.Id);
            }
        }

        for(Contact contacto : [SELECT Id, IndividualId, AccountId FROM Contact WHERE AccountId IN: cuentasEmpresaList])
        {
            if(!contactosMap.containsKey(contacto.AccountId))
            {
                if (!contactosMap.containsKey(contacto.AccountId))
                {
                    contactosMap.put(contacto.AccountId, new List<Contact>());
                }
                contactosMap.get(contacto.AccountId).add(contacto);
            }
        }
    }

    /**
    *   Recupera los registros Persona a los que estan asociados los contactos de cuentas de empresa
    **
    *  @author rfernandez
    *  @date 25/07/2018
    *  @param list<Account> accountList - Lista de cuentas
    *  @where Bulk after 
    */
    public static void recuperarPersonasDeContactos(List<Account> accountList, Map<Id, Account> oldMap)
    {
        if(!contactosMap.isEmpty())
        {
            Set<Id> personasIdsList = new Set<Id>();
            for(Id idCuenta : contactosMap.keySet())
            {
                for(Contact contacto : contactosMap.get(idCuenta))
                {
                    personasIdsList.add(contacto.IndividualId);
                }
            }

            for(Individual persona : [SELECT Id, Email__c, FirstName, LastName FROM Individual WHERE Id IN: personasIdsList])
            {
                personasMap.put(persona.Id, persona);
            }    
        }
    }

    /**
    *   Si una cuenta pasa a ser cliente existente se deben marcar los checks de preferencias de su individual relacionado
    *       - Si es empresa, se marcarán los individuals a los que estan asociados los contactos
    *  @author rfernandez
    *  @date 25/07/2018
    *  @param list<Account> accountList - Lista de cuentas
    *  @where After update 
    *  @change rcastanos (05/06/2019) Se modifica para recuperar los tipos de registro a través de la nueva propiedad. Se elimina toda referencia a cuentas personales
    */
    public static void aceptarPreferenciasPorClienteExistente(List<Account> accountList, Map<Id, Account> oldMap)
    {
        Map<Id, Account> cuentasEmpresaMap     = new Map<Id, Account>();

        //Recuperamos las cuentas a tratar
        for(Account cuenta : accountList)
        {
            RecordType clienteExistente = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
            RecordType clientePotencial = Util.objectsRecordTypesMap.get('Account').get('Cliente');
            
            if(cuenta.RecordTypeId == clienteExistente.Id && oldMap.get(cuenta.Id).RecordTypeId == clientePotencial.Id)
            {
                cuentasEmpresaMap.put(cuenta.Id, cuenta);
            }
        }

        //Gestionamos las cuentas empresariales
        if(!cuentasEmpresaMap.isEmpty())
        {
            for(Account cuenta : cuentasEmpresaMap.values())
            {
                if(!contactosMap.isEmpty() && contactosMap.containsKey(cuenta.Id))
                {
                    for(Contact contacto : contactosMap.get(cuenta.Id))
                    {
                        if(contacto.IndividualId != null && personasMap.containsKey(contacto.IndividualId))
                        {
                            aceptarPreferenciasPorClienteExistente2(contacto.IndividualId);
                        }
                    }
                }
            }
        }
    }
    
    public static void aceptarPreferenciasPorClienteExistente2(Id recordId)
    {
        Individual persona;
        if(personasToUpdate.containsKey(recordId))
        {
            persona =  personasToUpdate.get(recordId);
        }else{
            persona =  personasMap.get(recordId);
        }
        persona.Fecha_promociones__c        = System.now();
        persona.Promociones__c              = true;
        persona.Fecha_encuestas__c          = System.now();
        persona.Encuestas_satisfaccion__c   = true;

        personasToUpdate.put(persona.Id, persona);
    }

    /**
    *   Execute DMLs after data process
    **
    *  @author rfernandez
    *  @date 17/05/2018    
    *  @where andFinally
    *  @change rcastanos (05/06/2019) Se elimina personasToDelete
    */
    public static void insertUpdateDeleteRecords()
    {
        
        if(!personasToUpdate.isEmpty())
        {   
            update personasToUpdate.values();
        }

        personasToUpdate.clear();
    }

    /**
     * Comprobación de IBAN de cuenta a través de la validación de los dígitos de control
     * 
     * @author pmartin
     * @date 18/02/2020
     * @where before insert / before update
     */
    public static void validarIBAN( Account acc, String oldIBAN)
    {
        System.debug('$$ - validarIBAN accountIBAN : '+acc.IBAN__c);
        if(!String.isEmpty(acc.IBAN__c))
        {
            if(acc.IBAN__c.length() == 24)
            {
                String entidad = acc.IBAN__c.substring(4,8);
                String sucursal = acc.IBAN__c.substring(8,12);
                String digitosDeControl = acc.IBAN__c.substring(12,14);
                String numCC = acc.IBAN__c.substring(14,acc.IBAN__c.length());
                
                try
                {   
                    
                    if (entidad.length()!=4 && sucursal.length()!=4)
                    {
                        Log__c log = new Log__c (Name ='AccountUtil', Descripcion__c ='Validación de IBAN '+acc.IBAN__c+' incorrecta para la cuenta '+acc.Name+': La longitud del código de entidad y sucursal son incorrectos (diferente a 4). IBAN ANTERIOR : '+oldIBAN);
                        insert log;
                        if(String.isEmpty(oldIBAN))
                        {
                            acc.IBAN__c = '';
                            //System.debug('$$ - validarIBAN vacío por fallo de IBAN (entidad)');
                        }
                        else
                        {
                            acc.IBAN__c = oldIBAN;
                            //System.debug('$$ - validarIBAN valor previo por fallo (entidad) : '+acc.IBAN__c);
                        }
                    }
                    else
                    {                           
                        Integer digcontrol1 = 0;
                        Integer digcontrol2 = 0;
                        
                        digcontrol1 =   Integer.valueOf(entidad.substring(0, 1)) * 4 + 
                                        Integer.valueOf(entidad.substring(1, 2))* 8 + 
                                        Integer.valueOf(entidad.substring(2, 3))* 5 + 
                                        Integer.valueOf(entidad.substring(3, 4)) * 10;
                        
                        digcontrol1 =   digcontrol1 + 
                                        Integer.valueOf(sucursal.substring(0, 1))* 9 + 
                                        Integer.valueOf(sucursal.substring(1, 2))* (8 - 1) + 
                                        Integer.valueOf(sucursal.substring(2, 3))* 3 + 
                                        Integer.valueOf(sucursal.substring(3, 4)) * (5 + 1);
                                        
                        digcontrol1 = math.mod(digcontrol1,(10 + 1));
                        
                        if (digcontrol1 != 0) {
                            digcontrol1 = (10 + 1) - digcontrol1;
                        }
                        
                        if (digcontrol1 == 10) {
                            digcontrol1 = 1;
                        }
                        
                        digcontrol2 =   Integer.valueOf(numCC.substring(0, 1))* 1 + 
                                        Integer.valueOf(numCC.substring(1, 2))* 2 + 
                                        Integer.valueOf(numCC.substring(2, 3))* 4 + 
                                        Integer.valueOf(numCC.substring(3, 4))* 8 + 
                                        Integer.valueOf(numCC.substring(4, 5))* 5 + 
                                        Integer.valueOf(numCC.substring(5, 5 + 1))* 10 + 
                                        Integer.valueOf(numCC.substring((5 + 1), 5 + 2))* 9 + 
                                        Integer.valueOf(numCC.substring((5 + 2), 8))* (5 + 2) + 
                                        Integer.valueOf(numCC.substring(8, 9))* 3 + 
                                        Integer.valueOf(numCC.substring(9, 10)) * (5 + 1);
                
                        digcontrol2 = math.mod(digcontrol2,(10 + 1));
                        
                        if (digcontrol2 != 0) {
                            digcontrol2 = (10 + 1) - digcontrol2;
                        }
                        
                        if (digcontrol2 == 10) {
                            digcontrol2 = 1;
                        }
    
                        String digControl = String.valueOf(digcontrol1) + String.valueOf(digcontrol2);
                        //System.debug(digControl);
                        if( !(digControl == digitosDeControl))
                        {
                            Log__c log = new Log__c(Name ='AccountUtil', Descripcion__c='Validación de IBAN '+acc.IBAN__c+' incorrecta para la cuenta '+ acc.Id +': No ha pasado la validación del Dígito de Control: '+ acc.IBAN__c+' -- '+digitosDeControl+' : '+digControl+'. IBAN ANTERIOR : '+oldIBAN);
                            insert log;
                            if(String.isEmpty(oldIBAN))
                            {
                                acc.IBAN__c = '';
                                //System.debug('$$ - validarIBAN vacío por fallo de IBAN (digitos de control)');
                            }
                            else
                            {
                                acc.IBAN__c = oldIBAN;
                                //System.debug('$$ - validarIBAN valor previo por fallo (digitos de control): '+acc.IBAN__c);
                            }
                        }
                    }          
                }
                catch (Exception ex)
                {
                    if(ex.getMessage().contains('out of bounds'))
                    {
                        Log__c log = new Log__c(Name ='AccountUtil', Descripcion__c='Validación de IBAN '+acc.IBAN__c+' incorrecta para la cuenta '+ acc.Name +': Entidad u Oficina incorrectas. IBAN ANTERIOR : '+oldIBAN);
                        insert log;
                        if(String.isEmpty(oldIBAN))
                        {
                            acc.IBAN__c = '';
                            //System.debug('$$ - validarIBAN vacío por fallo (excepcion): '+acc.IBAN__c);
                        }
                        else
                        {
                            acc.IBAN__c = oldIBAN;
                            //System.debug('$$ - validarIBAN valor previo por fallo (excepcion) : '+acc.IBAN__c);
                        }
                    }
                    else
                    {
                        Log__c log = new Log__c (Name ='AccountUtil', Descripcion__c ='Validación de IBAN '+acc.IBAN__c+' incorrecta para la cuenta '+acc.Name+': '+ex.getMessage()+'. IBAN ANTERIOR : '+oldIBAN);
                        insert log;
                        if(String.isEmpty(oldIBAN))
                        {
                            acc.IBAN__c = '';
                            //System.debug('$$ - validarIBAN valor previo por fallo (otros): '+acc.IBAN__c);
                        }
                        else
                        {
                            acc.IBAN__c = oldIBAN;
                            //System.debug('$$ - validarIBAN valor previo por fallo (otros): '+acc.IBAN__c);
                        }
                    }     
                }
            }else
            {
                Log__c log = new Log__c(Name='AccountUtil', Descripcion__c ='Validación de IBAN '+acc.IBAN__c+' incorrecta para la cuenta '+ acc.Name +': Longitud del IBAN incorrecta (diferente a 24). IBAN ANTERIOR : '+oldIBAN);    
                insert log;
                if(String.isEmpty(oldIBAN))
                {
                    acc.IBAN__c = '';
                    //System.debug('$$ - validarIBAN valor previo por fallo (longitud iban): '+acc.IBAN__c);
                }
                else
                {
                    acc.IBAN__c = oldIBAN;
                    //System.debug('$$ - validarIBAN valor previo por fallo (longitud iban): '+acc.IBAN__c);
                }
            }  
        }
    }

    /**
     * Ejecuta validación de IBAN para cada cuenta de la lista del trigger
     * 
     * @author pmartin
     * @date 18/02/2020
     * @where before insert / before update
     */

    public static void procesarCuentasTriggerParaValidarIBAN(List<Account> cuentas, Map<Id, Account> oldMap)
    {
        for(Account acc : cuentas)
        {
            String iban = '';
            //si existe un mapa de registros anteriores (caso update)
            if(oldMap != null)
            {
                Account mapAccount = oldMap.get(acc.Id);
                if(acc.IBAN__c != mapAccount.IBAN__c)
                {
                    // asignamos el iban antiguo a una variable 
                    iban = mapAccount.IBAN__c;  
                }
            }
            System.debug('$$ - procesarCuentavalidarIBAN : '+acc.IBAN__c);
            System.debug('$$ - procesarCuentavalidarIBAN from oldMap : '+iban);
            //si no (caso insert), pasa vacío
            validarIBAN(acc, iban);
        }
    }

    /**
     * modifica el valor del campo Cuenta_bloqueada_cambio__c cuando el cambio va a ocurrir desde el código
     * 
     * @author pmartin
     * @date 05/03/2020
     * @event before
     */

    /*public static void bloquearActualizacionCuenta(List<Account> cuentas)
    {
        if(cuentas.size() > 0 )
       {
            List<Account> cuentasUpdate = new List<Account>();

            for(Account cuenta : cuentas)
            {
                cuenta.Cuenta_bloqueada_cambio__c = true;
            }
        }
    }*/

    /**
     * establece el valor del campo Origen_de_modificacion__c en función de si el cambio procede de la interfaz o del código
     * 
     * @author pmartin
     * @date 05/03/2020
     * @event after
     */

     public static void definirOrigenDeModificacion(List<Account> cuentasTrigger, map<Id,Account> oldMap)
     {
      
        System.debug('en el trigger de definir '+cuentasTrigger[0].Cuenta_actualizada_desde_codigo__c);
        if(cuentasTrigger.size() > 0)
        {
            //List<Account> cuentas = [select Id, Cuenta_actualizada_desde_codigo__c, Origen_de_modificacion__c from Account where Id in: cuentasTrigger];
            List<Account> cuentas = cuentasTrigger;
            if(cuentas.size() > 0)
            {
                //List<Account> cuentasUpdate = new List<Account>();
                // for(Account c : cuentas)
                // {
                //     // se borran las cuentas que no estén en el trigger
                //     for(Account a : cuentasTrigger)
                //     {
                //         if(c.Id == a.Id)
                //         {
                //             cuentasUpdate.add(c);
                //         }
                //     }
                // }

                // tras filtrar las cuentas y dejar sólo las que están en el trigger se continúa con la ejecución
                for(Account c : cuentas)
                {
                    //System.debug(c.Cuenta_bloqueada_cambio__c);
                    System.debug(c.Cuenta_actualizada_desde_codigo__c);

                    if(c.IBAN__c != oldMap.get(c.Id).IBAN__c)
                    {

                        if(c.Cuenta_actualizada_desde_codigo__c)
                        {
                            c.Origen_de_modificacion__c = 'Salesforce';
                            
                        }
                        else
                        {
                            c.Origen_de_modificacion__c = 'Web';
                            c.Cuenta_actualizada_desde_codigo__c = true;
                        }
                    }
                    else
                    {
                        c.Origen_de_modificacion__c = oldMap.get(c.Id).Origen_de_modificacion__c;
                    }   
                }
            }
        }
     }

}