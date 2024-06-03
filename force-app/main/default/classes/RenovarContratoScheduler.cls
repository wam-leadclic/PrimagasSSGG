/** 
* Clase RenovarContratoScheduler
**
* @Funcionalidad: Clase Schedulable encargada de enviar los Logs del objeto Contrato a Navision
* @Autor: Aritz Uriarte de Alayo (21/07/2015)
**
**/
global class RenovarContratoScheduler implements Database.Batchable<sObject>,Schedulable 
{
	public String query = '';

	public RenovarContratoScheduler() 
	{
		System.Debug('## Constructor de RenovarContratoScheduler');
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('## Start de RenovarContratoScheduler');
        return Database.getQueryLocator(query);
    }

    //Execute del Scheduler --> Inicia el Batch Apex
    global void execute(SchedulableContext SC) 
    {           
        RenovarContratoScheduler controller = new RenovarContratoScheduler();
        Datetime today = System.today();
        String statusAnulado = 'Anulado';
        String statusPendiente = 'Pendiente de Renovar';
        
                              
        controller.query = 'Select Id, OwnerExpirationNotice, SpecialTerms, Description, ShippingAddress, BillingAddress, ContractTerm, Status, ActivatedDate, CompanySignedDate,' + 
                            + 'CustomerSignedDate, StartDate, EndDate, AccountId, Name, ContractNumber, OwnerId, RecordTypeId, CustomerSignedTitle, Altitud__c, Aportaci_n_al_cliente__c,' + 
                            + 'Aportacion_maxima_interior__c, Caldera__c, Capacidad_tanque__c, CIF__c, Cod_forma_de_pago__c, Cod_forma_pago_servicios__c, Cod_tarifa__c, Cod_terminos_de_pago__c, ' +
                            + 'Cod_terminos_pago_servicios__c, Cod_dia_de_pago__c, Consumo_previsto_GWh__c, Consumo_previsto_tons__c, '+
                            + 'Contrato_anterior__c, Coste_resolucion_anticipada__c, dcm_propano1__c, dcm_propano2__c, dcm_propano3__c, dcm_propano4__c, Direccion_de_entrega__c, dp_cad_min1__c, ' +
                            + 'dp_cad_min2__c, dp_cad_min3__c, dp_cad_min4__c, dp_cad_min5__c, dp_cad_min6__c, dto_Kg_1__c, dto_Kg_2__c, dto_Kg_3__c, dto_Kg_4__c, dto_Kg_5__c, dto_Kg_6__c, dto_a_o_1__c, dto_a_o_2__c, ' +
                            + 'dto_a_o_3__c, dto_a_o_4__c, Duracion_contrato_en_toneladas__c, Duraci_n_contrato_GWh__c, e_mail__c, Entrega_de_producto__c, Error_Sync__c, Fecha_prevista_1er_llenado__c, ' +
                            + 'Fecha_prevista_obra_civil__c, Fecha_ltima_Sync__c, IBAN__c, Id_Navision__c, Importe_alquiler_contador__c, Importe_contador_nuevo__c, Importe_derechos_acometida__c, ' +
                            + 'Importe_inspecci_n_quinquenal__c, Importe_modalidad_instalacion__c, Importe_prima__c, Importe_prima_por_tonelada__c, Importe_reenganche__c, Importe_SAU__c, Importe_t_rmino_fijo__c, ' + 
                            + 'Inertizado_Dep_Cliente__c, Inversion_no_recuperable__c, Inversion_recuperable__c, Modalidad_de_instalaci_n__c, Motivo_de_renovacion__c, ' +
                            + 'Nombre_cliente__c, N_mero_de_vaporizadores__c, N_fax__c, N_telefono__c, N_telefono_movil__c, ' +
                            + 'Oportunidad__c, Origen__c, Origen_tipo_de_cliente__c, Perfil_base__c, Perfil_de_consumo__c, Prescriptor__c, ' +
                            + 'Prescriptor_no_en_BD__c, Primaservicios_gratuitos__c, Producto_contratado__c, Rentabilidad_prevista__c, ' +
                            + 'Segmento_1__c, Segmento_2__c, Servicios__c, Subcontratista__c, SWI__c, Tipo_camion__c, Tipo_de_tanque__c, TP_tipo_instalacion__c, Uso__c, Vaporizaci_n_Nm3h__c, Tarifa__c ' +
                            + 'from Contract where ' +
                            + 'EndDate < TODAY ' +
                            + 'and Status != \'Anulado\' ' + 
                            + 'and Status != \'Pendiente de renovar\'';
        Integer batchSize = 200;
        System.debug('query -> '+controller.query);
        database.executeBatch(controller, batchSize);    

        //Eliminamos las que ya no se van a ejecutar más
        for(CronTrigger cronTr : [SELECT id, CronExpression, TimesTriggered, NextFireTime, State FROM CronTrigger WHERE NextFireTime = null])
        {
            System.debug('borrar '+cronTr.id+' '+cronTr.State+' '+cronTr.CronExpression);
            System.abortJob(cronTr.Id);
        }                
    }
    
    // Cambiamos el estado de los contratos finalizados a 'Anulado' y los duplicamos cambiándole el estado a 'Pendiente de Renovar'.
    // Los contratos duplicados se enviarán a aprobación directamente.
    global void execute(Database.BatchableContext BC, List<Contract> contratos)
    { 
       System.debug('## before Batch RenovarContratoScheduler contratos: ' + contratos);
       
       List<String> contratosID = new List<String>();
       Map<String, Contract> mapaContratosClonados = new Map<String, Contract>();
       Contract contratoClonado;
       for (Contract contrato:contratos)
       {
       		contratosID.add(contrato.Id);
       		contratoClonado = contrato.clone(false, true, false, false);
       		//contratoClonado.Status = 'Pendiente de Renovar';
          contratoClonado.Status = 'Borrador';
       		contratoClonado.Motivo_de_renovacion__c = 'Caducado';
          contratoClonado.Contrato_anterior__c = contrato.Id;
          contratoClonado.Id_Navision__c = '';
       		mapaContratosClonados.put(contrato.Id, contratoClonado);
       		contrato.Status = 'Anulado';
       }

       // Insertamos los contratos clonados
       insert mapaContratosClonados.values();

       List<String> contratosClonadosIDs = new List<String>();
       for (Contract contrato:mapaContratosClonados.values())
       {
          contratosClonadosIDs.add(contrato.Id);
       }
       List<Contract> contratosClonados = new List<Contract>([Select Id, Status from Contract where Id in :contratosClonadosIDs]);

       for (Contract contrato:contratosClonados)
       {
       		System.Debug('## executeBatch contrato: ' + contrato);
          if (contrato.Status == 'Borrador')
          {
            System.Debug('## executeBatch enviando a aprobación contrato: ' + contrato);
            // Create an approval request for the Opportunity
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Pendiente de aprobación por renovación automática.');
            req1.setObjectId(contrato.Id);
            //req1.setNextApproverIds(new Id[] {opp.Next_Approver__c});
            // Submit the approval request for the Opportunity
            Approval.ProcessResult result = Approval.process(req1);
          }          
       }

       // Recuperamos los contratos de servicio y los duplicamos también
       /*
       List<Contrato_de_servicio__c> listaContratosServicio = new List<Contrato_de_servicio__c>([Select Direccion_de_entrega__c, Contrato__c, Nombre_de_Servicio__c from Contrato_de_servicio__c where Contrato__c in :contratosID]);       
       List<Contrato_de_servicio__c> contratosServicioClonados = new List<Contrato_de_servicio__c>();
       Contrato_de_servicio__c contratoServicioClonado;

       for (Contrato_de_servicio__c servicio:listaContratosServicio)
       {
    			contratoServicioClonado = servicio.clone(false, true, false, false);
    			contratoServicioClonado.Contrato__c = mapaContratosClonados.get(servicio.Contrato__c).Id;       			
    			contratosServicioClonados.add(contratoServicioClonado);
       }

       // Insertamos los contratos de servicio clonados
       insert contratosServicioClonados;*/

       // Actualizamos los contratos originales
       update contratos;
       
       System.debug('## after Batch RenovarContratoScheduler contratos: ' + contratos);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Finish de RenovarContratoScheduler');  

        if(!Test.isRunningTest())
        {
            //Programamos la siguiente ejecución
            Datetime now = System.now();
            // Le sumamos un número determinado de minutos establecidos en un Custom Setting
            String params = Util.valoresIntegracionNavision.get('RenovarContratoScheduler');
            now = now.addMinutes(Integer.valueOf(params));
            String cron ='0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();
            System.schedule('RenovarContratoScheduler' + now.addHours(2), cron, new RenovarContratoScheduler());
        }        
    }
}