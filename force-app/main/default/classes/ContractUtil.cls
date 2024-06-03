public with sharing class ContractUtil
{

    public static Boolean semaforoUpdate = true;

    private static Map<Id, Opportunity> opportunitiesMap;

    private static final Set<String> ESTADOS_ACTUALIZAR = new Set<String> {'Activado', 'Anulado'}; //MOD - Estados en los que se actualiza en contrato.

    private static Map<Id, Opportunity> opportunitiesToUpdate
    {
        get
        {
            if(opportunitiesToUpdate == null)
            {
                opportunitiesToUpdate = new Map<Id, Opportunity>();
            }
            return opportunitiesToUpdate;
        }
        set;
    }

    public static void loadData(list<SObject> newList, map<String, Account> mapaClientes /*, map<String, List<Elemento_de_servicio__c>> mapaActivos*/)
    {
        System.Debug('## before loadData AFTER');
        List<String> clientesID = new List<String>();
        List<String> contratosAnterioresID = new List<String>();

        if (newList != null)
        {
            for (Contract contrato : (List<Contract>) newList)
            {
                clientesID.add(contrato.AccountId);
            }

            if ( !clientesID.isEmpty() )
            {
                List<Account> clientes = new List<Account>();
                clientes = [Select Id, Name, RecordTypeId, Cod_terminos_pago__c, Cod_forma_pago__c from Account where Id in :clientesID];
                for (Account cliente:clientes)
                {
                    mapaClientes.put(cliente.Id, cliente);
                }
            }
        }
        System.Debug('## after loadData AFTER');
    }

    public static void loadData(list<Contract> newList, map<String, Contract> mapaContratosAnteriores)
    {
        System.Debug('## before loadData BEFORE newList: ' + newList);
        List<String> contratosAnterioresID = new List<String>();
        List<Contract> contratosAnteriores = new List<Contract>();
        if (newList != null)
        {
            for (Contract contrato:newList)
            {
                if (contrato.Contrato_anterior__c != null)
                {
                    contratosAnterioresID.add(contrato.Contrato_anterior__c);
                }
            }

            if ( !contratosAnterioresID.isEmpty() )
            {
                contratosAnteriores = [Select Id, Status from Contract where Id in: contratosAnterioresID];
                for (Contract contrato:contratosAnteriores)
                {
                    mapaContratosAnteriores.put(contrato.Id, contrato);
                }
            }
        }
        System.Debug('## loadData BEFORE contratosAnteriores: ' + contratosAnteriores);
        System.Debug('## after loadData BEFORE');
    }

    /**
     *   Crea un mapa con las oportunidades relacionadas con los contratos
     **
     *  @author rfernandez
     *  @date 08/05/2018
     *  @param List<Contract> contractList - Lista de contratos
     *  @where Bulk after
     */
    public static void createOpportunitiesMap(List<Contract> contractList)
    {
        Set<Id> opportunitiesList = new Set<Id>();
        opportunitiesMap = new Map<Id, Opportunity>();

        for(Contract cont : contractList)
        {
            opportunitiesList.add(cont.Oportunidad__c);
        }

        for(Opportunity opp : [SELECT Id, ContractId FROM Opportunity WHERE Id IN: opportunitiesList])
        {
            opportunitiesMap.put(opp.Id, opp);
        }
    }

    // Método para cambiar el estado de los activos asociados a un contrato a "Pendiente de baja"
    // cuando el contrato pasa al estado "Pendiente de baja" o "Retirado/Precintado"
    public static void MarcarBajaActivos()
    {
        System.Debug('## before MarcarBajaActivos');

        System.Debug('## after MarcarBajaActivos');
    }

    // Método para anular el contrato anterior cuando éste se duplica por motivo de
    // cambio de tarifa (lista de precios). Se empleará en el after insert.
    // @change rcastanos (06/06/2019) Unificar métodos RenovarContratoTarifas y RenovarContratoTitular
    public static void renovarContrato(list<Contract> newList, map<String, Contract> mapaContratosAnteriores)
    {
        System.Debug('## before renovarContrato');
        if (newList != null)
        {
            List<String> contratosAnterioresID = new List<String>();
            List<Contract> contratosAnteriores = new List<Contract>();
            for (Contract contrato:newList)
            {
                if (contrato.Motivo_de_renovacion__c == 'Cambio tarifa' || contrato.Motivo_de_renovacion__c == 'Cambio titular')
                {
                    if (contrato.Contrato_anterior__c != null)
                    {
                        //contratosAnterioresID.add(contrato.Contrato_anterior__c);
                        mapaContratosAnteriores.get(contrato.Contrato_anterior__c).Status = 'Anulado';
                        contratosAnteriores.add( mapaContratosAnteriores.get(contrato.Contrato_anterior__c) );
                    }
                }
            }
            update contratosAnteriores;
        }
        System.Debug('## after renovarContrato');
    }

    // Método para establecer los clientes relacionados con los contratos registrados como clientes existentes.
    // @change rcastanos (06/06/2019) Modificación para recuperar los tipos de registro a través de una propiedad
    // @change rcastanos (06/06/2019) Modificación para eliminar las cuentas personales
    public static void RegistrarContrato(list<Contract> newList, map<Id,Contract> oldMap, map<String, Account> mapaClientes)
    {
        System.Debug('## before RegistrarContrato newList: ' + newList);
        if(semaforoUpdate)
        {
            System.debug( 'mapaClientes: ' + mapaClientes.keySet() );
            if (newList != null)
            {
                List<String> contratosSyncIDs = new List<String>();
                Map<String, Account> clientesUpdate = new Map<String, Account>();
                Contract contratoAnterior;
                Recordtype rts_empresa = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
                for (Contract contrato:newList)
                {
                    contratoAnterior = oldMap.get(contrato.Id);
                    // Comprobamos si el contrato ha pasado al estado "Registrado" o si tiene identificativo de Navision.
                    // De cumplirse alguna de las dos condiciones anteriores se cambiará el tipo del cliente a "Cliente Existente"
                    // y se actualizarán los campos del cliente a los registrados en el contrato. Además, se enviará el contrato a Navision.

                    System.debug('contratoAnterior.Status - contrato --> ' + contratoAnterior.Status + ' - ' + contrato.Status);

                    if ( (contratoAnterior != null &&
                          contratoAnterior.Status != contrato.Status && contrato.Status == 'Activado') ||
                         (contrato.Id_Navision__c != null && contrato.Id_Navision__c != '') )
                    {
                        System.debug('Contrato-> ' + contrato.Id);
                        contratosSyncIDs.add(contrato.Id);

                        Account cliente = mapaClientes.get(contrato.AccountId);

                        // Si existe ese tipo de registro de cliente y el cliente no lo tenía ya, lo actualizamos
                        if (cliente.RecordTypeId != rts_empresa.Id)
                        {
                            System.debug('El cliente con Id: ' + cliente.Id + ', no era de tipo Cliente_existente');

                            cliente.RecordTypeId = rts_empresa.Id;
                            System.debug('El cliente con Id: ' + cliente.Id + ', no es cuenta personal');


                            // Aquí habría que rellenar los campos del cliente con los reflejados en el contrato
                            // y sobreescribir los que tuviera el cliente previamente en caso de cambio.
                        }
                        clientesUpdate.put(cliente.Id, cliente);
                        mapaClientes.put(cliente.Id, cliente);
                    }
                }

                List<String> idsClientesActualizados = new List<String>();
                // Actualizamos los clientes modificados para establecerlos como clientes existentes.
                if(clientesUpdate.size() > 0)
                {
                    AccountUtil.semaforoUpdate = false;
                    Database.SaveResult[] results = Database.Update(clientesUpdate.values(),false);
                    AccountUtil.semaforoUpdate = true;
                    for(Integer i=0; i < results.size(); i++)
                    {
                        if( results[i].IsSuccess() )
                            idsClientesActualizados.add( results[i].getId() );
                    }
                }
                // Llamamos a la clase SyncNav para enviar el contrato a Navision
                if ( !contratosSyncIDs.isEmpty() && !idsClientesActualizados.IsEmpty() )
                {
                    SyncNav.SincronizarClientesyContratos(contratosSyncIDs,idsClientesActualizados);
                }
            }
        }
        System.Debug('## after RegistrarContrato');
    }

    // ESTE MÉTODO NO SE USA ACTUALMENTE, SE COMENTA POR SI SE UTILIZA A FUTURO
    // Método para crear Contratos Servicio en un contrato en base al campo servicios de selección múltiple
    /*public static void CrearContratosServicio(list<Contract> newList)
       {
       System.Debug('## before CrearContratosServicio');
       if (newList != null)
       {
        List<Contrato_de_servicio__c> contratosServicio = new List<Contrato_de_servicio__c>();
        Contrato_de_servicio__c contratoServicio;

        List<String> servicios = new List<String>();
        for (Contract contrato:newList)
        {
          if (contrato.Servicios__c != null && contrato.Servicios__c != '' && contrato.Direccion_de_entrega__c != null)
          {
            servicios = contrato.Servicios__c.split(';');
            for (String servicio : servicios)
            {
              contratoServicio = new Contrato_de_servicio__c();
              contratoServicio.Direccion_de_entrega__c = contrato.Direccion_de_entrega__c;
              contratoServicio.Contrato__c = contrato.Id;
              contratoServicio.Nombre_de_Servicio__c = servicio;
              contratosServicio.add(contratoServicio);
            }
          }

        }
        //insert contratosServicio;

        Database.SaveResult[] res = Database.insert(contratosServicio, false);
              for(Integer i = 0; i < res.size(); i++)
              {
                  Database.Saveresult sr = res[i];
                  if(!sr.isSuccess())
                  {
                      Database.Error err = sr.getErrors()[0];
                      LogUtil.crearLog('Error: '+err.getMessage(), 'ContractUtil.CrearContratosServicio', 'Contrato de Servicio', 'Error', true);
                  }
              }
              LogUtil.guardarLog();

       }
       System.Debug('## after CrearContratosServicio');
       }*/

    public static void cambiarEstadoOportunidadCerradaGanada(list<Contract> newList)
    {
        List<String> listaContratosFirmadosIds = new List<String>();

        for( Contract contrato : newList )
        {
            if( (contrato.CustomerSignedId != null || contrato.CompanySignedId != null) )
            {
                listaContratosFirmadosIds.add(contrato.Id);
            }
        }
        System.debug('Contratos firmados: ' + listaContratosFirmadosIds);

        List<Opportunity> listaOportunidades = [SELECT Id, StageName, ContractId FROM Opportunity WHERE ContractId IN: listaContratosFirmadosIds];
        List<Opportunity> oportunidadesUpdate = new List<Opportunity>();
        for( Opportunity oportunidad : listaOportunidades)
        {
            if(oportunidad.StageName != 'Cerrada ganada')
            {
                oportunidad.StageName = 'Cerrada ganada';
                oportunidadesUpdate.add(oportunidad);
            }
        }
        System.debug('Oportunidades a pasar al estado "Cerrada ganada": ' + oportunidadesUpdate);

        if( oportunidadesUpdate != null && oportunidadesUpdate.size() > 0)
        {
            Database.SaveResult[] res = Database.update(oportunidadesUpdate, false);
            for(Database.SaveResult r: res)
            {
                if( !r.isSuccess() )
                {
                    Database.Error error = r.getErrors()[0];
                    LogUtil.crearLog('Error al pasar la oportunidad ' + r.getId() + ' al estado "Cerrada ganada". - Message: ' + error.getMessage(), 'cambiarEstadoOportunidadCerradaGanada', 'Oportunidad', 'Update', true);
                    System.debug( 'Error al pasar la oportunidad ' + r.getId() + ' al estado "Cerrada ganada". - Message: ' + error.getMessage() );
                }
            }
        }
    }


    /*Este método actualiza el campo Cod_forma_pago__c y Cod_terminos_pago__c de la cuenta asociada al contrato cuando estos no coinciden con los mismos campos
       del contrato actualizado. También actualiza la tarifa asociada a la dirección de entrega asociada al contrato actualizado.*/
    public static void actualizarDatosClienteYDireccionEntrega(List<Contract> newList, map<Id,Contract> oldMap, Map<String,Account> mapaClientes)
    {
        if (newList != null)
        {
            List<Account> cuentasUpdate = new List<Account>();
            Map<String,String> mapaDireccionIdContratoTarifaId = new Map<String,String>();
            List<Direcci_n_de_entrega__c> direccionesUpdate = new List<Direcci_n_de_entrega__c>();
            for (Contract contrato: newList)
            {
                if(contrato.Status == 'Activado' && oldMap != null && oldMap.containsKey(contrato.Id) && oldMap.get(contrato.Id).Status != 'Activado')
                {
                    //gserrano 28/01/2019 Se comenta todo porque ahora Sandra no quiere que se mapeen estos campos en la cuenta
                    //gserrano 24/01/2019
                    /*if( mapaClientes != null && mapaClientes.containsKey(contrato.AccountId) )
                       {
                       Boolean anadirCuenta = false;

                       if( String.isBlank(mapaClientes.get(contrato.AccountId).Cod_forma_pago__c)  )
                       {
                        mapaClientes.get(contrato.AccountId).Cod_forma_pago__c = contrato.Cod_forma_de_pago__c;
                        anadirCuenta = true;
                       }

                       if(String.isBlank(mapaClientes.get(contrato.AccountId).Cod_terminos_pago__c)  )
                       {
                        mapaClientes.get(contrato.AccountId).Cod_terminos_pago__c = contrato.Cod_terminos_de_pago__c;
                        if(!anadirCuenta)
                          anadirCuenta = true;
                       }

                       if(anadirCuenta)
                        cuentasUpdate.add(mapaClientes.get(contrato.AccountId));
                       }*/
                    if(contrato.Direccion_de_entrega__c != null && contrato.Tarifa__c != null)
                    {
                        mapaDireccionIdContratoTarifaId.put(contrato.Direccion_de_entrega__c, contrato.Tarifa__c);
                    }
                }
            }

            if(mapaDireccionIdContratoTarifaId != null && mapaDireccionIdContratoTarifaId.size() > 0)
            {
                List<Direcci_n_de_entrega__c> direcciones = [SELECT Id, C_digo_tarifa__c FROM Direcci_n_de_entrega__c WHERE Id =: mapaDireccionIdContratoTarifaId.keySet()];
                if(direcciones != null && direcciones.size() > 0)
                {
                    for(Direcci_n_de_entrega__c dir: direcciones)
                    {
                        if(mapaDireccionIdContratoTarifaId.containsKey(dir.Id) && mapaDireccionIdContratoTarifaId.get(dir.Id) != dir.C_digo_tarifa__c)
                        {
                            dir.C_digo_tarifa__c = mapaDireccionIdContratoTarifaId.get(dir.Id);
                            direccionesUpdate.add(dir);
                        }
                    }
                }
            }

            System.debug('##cuentasUpdate: ' + cuentasUpdate);
            if(cuentasUpdate != null && cuentasUpdate.size() > 0)
            {
                AccountUtil.semaforoUpdate = false;
                Database.SaveResult[] results = Database.update(cuentasUpdate,false);
                AccountUtil.semaforoUpdate = true;
                for(Database.SaveResult sr: results)
                {
                    if( !sr.isSuccess() )
                    {
                        Database.Error err = sr.getErrors()[0];
                        LogUtil.crearLog('Error al actualizar los datos de pago del cliente: ' + err.getMessage(), 'ContractUtil.actualizarDatosClienteYDireccionEntrega', 'Cuenta', 'Error', true);
                        System.debug( '##Error al actualizar los datos de pago del cliente: ' + err.getMessage() );
                    }
                }
                LogUtil.guardarLog();
            }

            System.debug('##direccionesUpdate: ' + direccionesUpdate);
            if(direccionesUpdate != null && direccionesUpdate.size() > 0)
            {
                DireccionEnvioUtil.semaforoUpdate = false;
                Database.SaveResult[] results2 = Database.update(direccionesUpdate,false);
                DireccionEnvioUtil.semaforoUpdate = true;
                for(Database.SaveResult sr: results2)
                {
                    if( !sr.isSuccess() )
                    {
                        Database.Error err = sr.getErrors()[0];
                        LogUtil.crearLog('Error al actualizar la tarifa de la dirección de entrega: ' + err.getMessage(), 'ContractUtil.actualizarDatosClienteYDireccionEntrega', 'Dirección de entrega', 'Error', true);
                        System.debug( '##Error al actualizar la tarifa de la dirección de entrega: ' + err.getMessage() );
                    }
                }
                LogUtil.guardarLog();
            }
        }
    }

    /**
     *   Si la oportunidad a la que hace referencia el contrato no tiene el lookup de contrato relleno, lo actualiza. Esto se rellena desde el WSDatosContrato para Newsales, pero no lo hace en el caso
     *	de los contratos creados directamente en Salesforce
     **
     *  @author rfernandez
     *  @date 08/05/2018
     *  @param List<Contract> contractList - Lista de contratos
     *  @where After insert
     */
    public static void updateOppsWithContract(List<Contract> contractList)
    {
        for(Contract cont : contractList)
        {
            if(opportunitiesMap.containsKey( cont.Oportunidad__c ) && opportunitiesMap.get( cont.Oportunidad__c ).ContractId == null )
            {
                Opportunity opp = opportunitiesMap.get(cont.Oportunidad__c);
                opp.ContractId  = cont.Id;
                opportunitiesToUpdate.put(cont.Oportunidad__c, opp);
            }
        }
    }

    /**
     *   Ejecuta las dml despues de procesar todos los registros
     **
     *  @author rfernandez
     *  @date 09/05/2018
     *  @where andFinally
     */
    public static void insertUpdateDeleteRecords()
    {

        if( !opportunitiesToUpdate.isEmpty() )
        {
            update opportunitiesToUpdate.values();
        }

        opportunitiesToUpdate.clear();
    }

    /**
     * Este método se ejecuta en el Trigger AfterUpdate y solo tiene efecto si al insertar el CONTRATO desde 
     * el formulario (CAMBIO de titular) se ha indicado como borrador
     * @author adelacruz
     * @date 09/07/2021
     */
    /*public static void procesoCambioTitularAPosteriori( List<Contract> previousList, List<Contract> newList )
    {
        List<Id> newContractsToUpdateIds = new List<Id>();
        List<Id> previousContractsToUpdateIds = new List<Id>();
        List<Direcci_n_de_entrega__c> direcionesToUpdate = new List<Direcci_n_de_entrega__c>();
        List<Account> previousAccountsToUpdate = new List<Account>();

        // Obtenemos la lista de IDs de contratos para actualizar
        for( Integer i = 0; i < previousList.size(); i++ )
        {
            if( previousList.get(i).Status == 'Borrador' && newList.get(i).Status == 'Activado' && previousList.get(i).IsTitularChange__c )
            {
                newContractsToUpdateIds.add( newList.get(i).Id );
                previousContractsToUpdateIds.add( previousList.get(i).Contrato_anterior__c );
            }
        }

        // Obtenemos los contratos NUEVOS para actualizarlos
        List<Contract> newContractsToUpdate = new List<Contract>();
        if( !newContractsToUpdateIds.isEmpty() )
        {
            newContractsToUpdate = [
                SELECT Id, AccountId, Account.Calle_Facturacion__c,
                Account.Provincia__c, Account.Pais_Facturacion__c, Account.Poblacion_Facturacion__c, Account.Codigo_Postal__c,
                Direccion_de_entrega__r.Id, Direccion_de_entrega__r.cuenta__c, IsTitularChange__c
                FROM Contract
                WHERE Id
                IN :newContractsToUpdateIds
            ];
        }

        // Obtenemos los contratos PREVIOS para actualizarlos
        List<Contract> previousContractsToUpdate = new List<Contract>();
        if( !previousContractsToUpdateIds.isEmpty() )
        {
            previousContractsToUpdate = [
                SELECT Id, AccountId, Account.Status_baja__c, Account.Motivo_baja__c, 
                Account.Estado_baja__c, Account.Fecha_baja__c, Account.Fecha_cierre_baja__c,
                Direccion_de_entrega__r.Id, Direccion_de_entrega__r.cuenta__c, IsTitularChange__c
                FROM Contract
                WHERE Id
                IN :previousContractsToUpdateIds
            ];
        }

        // Realizamos los cambios necesarios en los contratos (nuevos y previos)
        for( Integer i = 0; i < newContractsToUpdate.size(); i++ )
        {
            // Se actualiza dirección de entrega y el estado2 del nuevo contrato
            newContractsToUpdate.get(i).IsTitularChange__c = false;
            newContractsToUpdate.get(i).Estado_2__c = 'Cambio titular';
            newContractsToUpdate.get(i).Direccion_de_entrega__r.cuenta__c = newContractsToUpdate.get(i).AccountId;
            direcionesToUpdate.add( newContractsToUpdate.get(i).Direccion_de_entrega__r );
            
            // Además se rellena la dirección de facturación con la dirección de la cuenta nueva
            newContractsToUpdate.get(i).BillingStreet = newContractsToUpdate.get(i).Account.Calle_Facturacion__c;
            newContractsToUpdate.get(i).BillingState = newContractsToUpdate.get(i).Account.Provincia__c;
            newContractsToUpdate.get(i).BillingCountry = newContractsToUpdate.get(i).Account.Pais_Facturacion__c;
            newContractsToUpdate.get(i).BillingCity = newContractsToUpdate.get(i).Account.Poblacion_Facturacion__c;
            newContractsToUpdate.get(i).BillingPostalCode = newContractsToUpdate.get(i).Account.Codigo_Postal__c;
            
            // Se actualiza los estados y direcciones del contrato anterior
            previousContractsToUpdate.get(i).Status = 'Anulado';
            previousContractsToUpdate.get(i).Estado_2__c = 'Cambio titular';
            previousContractsToUpdate.get(i).Direccion_de_entrega__c = null;
            
            // Se actualiza la cuenta asociada al contrato anterior
            previousContractsToUpdate.get(i).Account.Status_baja__c = 'Anulado';
            previousContractsToUpdate.get(i).Account.Motivo_baja__c = 'Cambio titular';
            previousContractsToUpdate.get(i).Account.Estado_baja__c = 'Cerrado';
            previousContractsToUpdate.get(i).Account.Fecha_baja__c = System.today();
            previousContractsToUpdate.get(i).Account.Fecha_cierre_baja__c = System.today();

            previousAccountsToUpdate.add( previousContractsToUpdate.get(i).Account );
        }

        // Y los actualizamos
        if( !newContractsToUpdate.isEmpty() && !previousContractsToUpdate.isEmpty() && !direcionesToUpdate.isEmpty() && !previousAccountsToUpdate.isEmpty() )
        {
            //Evitamos el envío ya que al enviar el contrato tambien se enviará el cliente
            DireccionEnvioUtil.semaforoUpdate = false;
            AccountUtil.semaforoUpdate = false;
            update newContractsToUpdate ;
            update direcionesToUpdate;
            update previousContractsToUpdate;
            update previousAccountsToUpdate;
            AccountUtil.semaforoUpdate = true;
            DireccionEnvioUtil.semaforoUpdate = true;
        }
    }*/

    /**
    * @Metodo para eliminar la antigua dirección de entrega antigua tras haber duplicado la dirección en un nuevo cliente
    * @author ivan.contreras@blackbirdcrew.com | 01-31-2022 
    * @param newList 
    * @param oldMap 
    **/
    public static void activarDireccionEntrega(List<Contract> newList, map<Id,Contract> oldMap) {
        try {

            List<String> lIdName = new List<String>();
            List<String> loldAddress = new List<String>();
            List<Direcci_n_de_entrega__c> lAddressToDelete = new List<Direcci_n_de_entrega__c>();
            List<Contract> lContract = new List<Contract>();
            Set<Id> setAccount = new Set<Id>();
            List<Account> lAccount = new List<Account>();

            for(Contract c : newList){
                if(c.Status == 'Activado' && oldMap.get(c.Id).Status != 'Activado'){
                    if(String.isNotBlank(c.Direccion_de_entrega__c)){
                        lIdName.add(c.Direccion_de_entrega__c);
                    }
                }
            }
            if(!lIdName.isEmpty()){
                for(Direcci_n_de_entrega__c addressIterator : [SELECT Id, OldId__c FROM Direcci_n_de_entrega__c WHERE Id IN : lIdName]){
                    String oldAddress = addressIterator.OldId__c;
                    if (string.isNotBlank(oldAddress)){
                        loldAddress.add(oldAddress);
                    }
                }
            }
            if(!loldAddress.isEmpty()){
                lContract = [SELECT id,Direccion_de_entrega__c, AccountId FROM Contract WHERE Direccion_de_entrega__r.Name IN : loldAddress];
                if(!lContract.isEmpty()){
                    for(Contract c : lContract){
                        c.Direccion_de_entrega__c = null;
                        c.Status = 'Anulado';
                        setAccount.add(c.AccountId);
                    }
                    update lContract;
                }
                if(!setAccount.isEmpty()){
                    lAccount = [SELECT id,Status_baja__c, Motivo_baja__c, Estado_baja__c, Fecha_baja__c, Fecha_cierre_baja__c, Detalles_baja__c FROM Account WHERE ID IN : setAccount];
                    if(!lAccount.isEmpty()){
                        for(Account acc : lAccount){
                            acc.Status_baja__c = 'Anulado';
                            acc.Motivo_baja__c = 'Cambio de titular';
                            acc.Estado_baja__c = 'Cerrado';
                            acc.Fecha_baja__c = System.today();
                            acc.Fecha_cierre_baja__c = System.today();
                        }
                        update lAccount;
                    }
                }
                lAddressToDelete = [SELECT Id FROM Direcci_n_de_entrega__c WHERE Name IN : loldAddress];
                if(!lAddressToDelete.isEmpty()){
                    delete lAddressToDelete;
                }
            }
        } catch(Exception e){
            system.debug(e);
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
        }
    }

    /**
    * @Metodo para calcular la fecha fin de contrato en la inserción
    * @author icontreras | 04-05-2022 
    * @param newList 
    **/
    public static void populateContractEndDate(List<Contract> newList){
        List<Contract> contractEndDate = new List<Contract>();
        try{
            for(Contract contr : newList){
                    if(contr.DateFirstFilled__c != null && !String.isBlank(contr.Duraci_n_del_contrato_a_os__c) && contr.Estado_2__c == 'Nuevo'){
                        contr.Fecha_fin_contrato__c = contr.DateFirstFilled__c.addYears(integer.valueof(contr.Duraci_n_del_contrato_a_os__c));
                        contractEndDate.add(contr);
                    }else if(contr.ActivatedDate != null  && !String.isBlank(contr.Duraci_n_del_contrato_a_os__c) && contr.Estado_2__c != 'Nuevo'){
                        contr.Fecha_fin_contrato__c =  contr.ActivatedDate.addYears(integer.valueof(contr.Duraci_n_del_contrato_a_os__c)).date();
                        contractEndDate.add(contr);
                    }
            }
            if(!contractEndDate.isEmpty()){
                update contractEndDate;
            }
        } catch(Exception e){
            system.debug(e);
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
        }
    }

        /**
    * @Metodo para calcular la fecha fin de contrato durante el update
    * @author icontreras | 04-05-2022 
    * @param newList 
    **/
    public static void populateContractEndDateUpdate(List<Contract> newList, map<Id,Contract> oldMap){
        List<Contract> contractEndDate = new List<Contract>();
        try{
            for(Contract contr : newList){
                if(contr.Estado_2__c != oldMap.get(contr.Id).Estado_2__c || contr.DateFirstFilled__c != oldMap.get(contr.Id).DateFirstFilled__c || contr.ActivatedDate != oldMap.get(contr.Id).ActivatedDate || contr.Duraci_n_del_contrato_a_os__c != oldMap.get(contr.Id).Duraci_n_del_contrato_a_os__c){
                    if(contr.DateFirstFilled__c != null && !String.isBlank(contr.Duraci_n_del_contrato_a_os__c) && contr.Estado_2__c == 'Nuevo'){
                        contr.Fecha_fin_contrato__c = contr.DateFirstFilled__c.addYears(integer.valueof(contr.Duraci_n_del_contrato_a_os__c));
                    }else if(contr.ActivatedDate != null  && !String.isBlank(contr.Duraci_n_del_contrato_a_os__c) && contr.Estado_2__c != 'Nuevo'){
                        contr.Fecha_fin_contrato__c =  contr.ActivatedDate.addYears(integer.valueof(contr.Duraci_n_del_contrato_a_os__c)).date();
                    }
                 }
            }

        } catch(Exception e){
            system.debug(e);
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
        }
    }
}