public with sharing class NuevoContratoCPQController
{

    private static final String POLIZA_API = 'Poliza';
    private static final String GLP_API = 'GLP';
    private static final String GNL_API = 'GNL';
    private static final String DEPOSITO_PROPIO_API = 'Deposito_propio';

    private static Id POLIZA_RECORDTYPE = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(POLIZA_API).getRecordTypeId();
    private static Id GLP_RECORDTYPE = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(GLP_API).getRecordTypeId();
    private static Id GNL_RECORDTYPE = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(GNL_API).getRecordTypeId();
    private static Id DEPOSITO_PROPIO_RECORDTYPE = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(DEPOSITO_PROPIO_API).getRecordTypeId();

    // Clase para añadir el checkbox a las direcciones de envío
    public class DireccionEntrega
    {
        public Boolean selected {get; set;}
        public Boolean nueva {get; set;}
        public Direcci_n_de_entrega__c dir {get; set;}
        public String dirID {get; set;}
        public String direccion1 {get; set;}
        public String direccion2 {get; set;}
        public String poblacion {get; set;}
        public String provincia {get; set;}
        public String codigoPostal {get; set;}
        public String pais {get; set;}
        public String tipoCamion {get; set;}

        public DireccionEntrega()
        {
            selected = false;
            nueva = true;
        }

        public DireccionEntrega(Direcci_n_de_entrega__c dirEntrega)
        {
            selected = false;
            nueva = false;
            this.dir = dirEntrega;
            dirID = dirEntrega.Id;
            direccion1 = dirEntrega.Direccion__c;
            direccion2 = dirEntrega.Direccion_2__c;
            poblacion = dirEntrega.Poblacion__c;
            provincia = dirEntrega.Provincia__c;
            pais = dirEntrega.Pais__c;
            codigoPostal = dirEntrega.Codigo_Postal__c;
            tipoCamion = dirEntrega.Tipo_de_camion__c;
        }
    }

    private String readonlyFieldsPoliza = String.join(new List<String>{
                                            // Datos de contacto
                                            'DNI__c',
                                            // Consumo y duración
                                            'Duracion_contrato_en_toneladas__c',
                                            'Coste_resolucion_anticipada_toneladas__c',
                                            'Coste_resolucion_anticipada__c',
                                            'Fecha_fin_contrato__c',
                                            // Datos de instalación
                                            'Capacidad_tanque__c',
                                            'Tipo_de_tanque__c',
                                            'Telemedida__c',
                                            // PrimaConfort (DocuSign)
                                            'DocusignAsistencia24H__c',
                                            'DocuSignSuministroAutomatico__c',
                                            'DocuSignInspeccionInstalacionReceptora__c',
                                            'DocuSignLectorNivelDistancia__c',
                                            'DocuSignMantenimientoCentroAlmacenamient__c',
                                            'DocuSignPuestaDisposicionDeposito__c',
                                            'DocuSignContador__c',
                                            // Inversión en instalación
                                            'Importe_dep_sito__c',
                                            'Importe_instalaci_n_exterior__c',
                                            'Importe_instalaci_n_interior__c',
                                            'Importe_obra_Civil__c',
                                            'Importe_proyectos__c',
                                            'Importe_equipos__c',
                                            // Tarifa Gas
                                            'dp_cad_min1__c',
                                            'dp_cad_min2__c',
                                            'dp_cad_min3__c',
                                            'dp_cad_min4__c',
                                            'dp_cad_min5__c',
                                            'dp_cad_min6__c',
                                            'DocuSignTramoContrato__c',
                                            'dto_Kg_1__c',
                                            'dto_Kg_2__c',
                                            'dto_Kg_3__c',
                                            'dto_Kg_4__c',
                                            'dto_Kg_5__c',
                                            'dto_Kg_6__c'},';');

    /**
     * Set the read only fields for POLIZA, GLP, GNL AND DEPOSITO PROPIO Contracts:
     */
    private String readonlyFields = String.join(new List<String>{
                                            // Datos de contacto
                                            'DNI__c',
                                            // Consumo y duración
                                            'Duracion_contrato_en_toneladas__c',
                                            'Coste_resolucion_anticipada_toneladas__c',
                                            'Coste_resolucion_anticipada__c',
                                            'Fecha_fin_contrato__c',
                                            'Consumo_previsto_tons__c',
                                            'Duraci_n_del_contrato_a_os__c',
                                            // Datos de instalación
                                            'Capacidad_tanque__c',
                                            'Tipo_de_tanque__c',
                                            'Telemedida__c',
                                            // PrimaConfort (DocuSign)
                                            'DocusignAsistencia24H__c',
                                            'DocuSignSuministroAutomatico__c',
                                            'DocuSignInspeccionInstalacionReceptora__c',
                                            'DocuSignLectorNivelDistancia__c',
                                            'DocuSignMantenimientoCentroAlmacenamient__c',
                                            'DocuSignPuestaDisposicionDeposito__c',
                                            'DocuSignContador__c',
                                            // Inversión en instalación
                                            'Importe_dep_sito__c',
                                            'Importe_instalaci_n_exterior__c',
                                            'Importe_instalaci_n_interior__c',
                                            'Importe_obra_Civil__c',
                                            'Importe_proyectos__c',
                                            'Importe_equipos__c',
                                            // Tarifa Gas
                                            'Tarifa__c',
                                            'dp_cad_min1__c',
                                            'dp_cad_min2__c',
                                            'dp_cad_min3__c',
                                            'dp_cad_min4__c',
                                            'dp_cad_min5__c',
                                            'dp_cad_min6__c',
                                            'DocuSignTramoContrato__c',
                                            'dto_Kg_1__c',
                                            'dto_Kg_2__c',
                                            'dto_Kg_3__c',
                                            'dto_Kg_4__c',
                                            'dto_Kg_5__c',
                                            'dto_Kg_6__c'},';');

    /**
     * Set the required fields for POLIZA, GLP, GNL AND DEPOSITO PROPIO Contracts:
     */    
    private String requiredFields = String.join(new List<String>{'CustomerSignedId'}, ';');

    public String getRequiredFields(){
        if(isContractType(POLIZA_RECORDTYPE) || isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE))
            return requiredFields;

        return '';
    }

    public String getReadonlyFields(){
        if(isContractType(POLIZA_RECORDTYPE)){
            return readonlyFieldsPoliza;
        }else if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE))
            return readonlyFields;

        return '';
    }

    // OFERTA
    public SBQQ__Quote__c quote {get;set;}

    // OPORTUNIDAD
    public String oportunidadID {get; set;}
    public Opportunity oportunidad {get; set;}

    // CUENTA
    public String cuentaID {get; set;}
    public Account cuenta {get; set;}
    public Account cuentaAnterior {get; set;}

    // CONTRATO
    public Contract contract {get; set;}
    public Contract contratoAnterior {get; set;}

    // TIPOS DE REGISTRO
    public Map<String, String> mapaTiposRegistro {get; set;}
    public Map<String, String> mapaTiposRegistroPorNombre {get; set;}
    public String nombreTipoRegistro {get; set;}

    // DIRECCIONES
    public Direcci_n_de_entrega__c dirp {get; set;}
    public DireccionEntrega nuevaDireccionCustom {get; set;}
    public List<DireccionEntrega> direccionesEnvioCustom {get; set;}
    public List<Direcci_n_de_entrega__c> direccionesEnvio {get; set;}
    public Map<String, Direcci_n_de_entrega__c> mapaDirecciones {get; set;}
    public String direccionSeleccionada {get; set;}

    public String duplicarTarifa;
    public String duplicarTitular;
    public Boolean botonGuardarInactivo {get; set;}
    public Boolean controlGuardado {get; set;}

    public Boolean esDuplicarTarifa {
        get {
            if(esDuplicarTarifa == null)
            {
                String duplicarTarifaURL  = ApexPages.currentPage().getParameters().get('duplicarTarifa');

                if( String.isNotEmpty(duplicarTarifaURL) )
                {
                    esDuplicarTarifa = true;
                }
                else
                {
                    esDuplicarTarifa = false;
                }
            }
            return esDuplicarTarifa;
        }
        set;
    }
    public Boolean esCambioTitular {
        get {
            if(esCambioTitular == null)
            {
                String duplicarTitularURL = ApexPages.currentPage().getParameters().get('duplicarTitular');

                if( String.isNotEmpty(duplicarTitularURL) )
                {
                    esCambioTitular = true;
                }
                else
                {
                    esCambioTitular = false;
                }
            }
            return esCambioTitular;
        }
        set;
    }

    //////MOD- Comprueba si es una duplicación de tarifa, una duplicación de titular o un nuevo contrato
    public Boolean isDuplicar {
        get {
            if(isDuplicar == null)
            {
                String duplicarTitularURL = ApexPages.currentPage().getParameters().get('duplicarTitular');
                String duplicarTarifaURL  = ApexPages.currentPage().getParameters().get('duplicarTarifa');

                if(duplicarTarifaURL != null || duplicarTitularURL != null)
                {
                    isDuplicar = true;
                }
                else
                {
                    isDuplicar = false;
                }
            }
            return isDuplicar;
        }
        set;
    }

    public Account cuentaSeleccionada {get; set;}
    private String estado = null;
    private String estado2 = null;

    //MOD - Estados en los que se actualiza en contrato.
    private static final Set<String> ESTADOS_ACTUALIZAR = new Set<String>
    {
        'Activado',
        'Anulado'
    };

    // Constructor del "Extension" del constructor estandar
    public NuevoContratoCPQController(ApexPages.StandardController stdController)
    {
        // Los datos para el duplicado, se pasan desde la URL del Botón
        duplicarTarifa = ApexPages.currentPage().getParameters().get('duplicarTarifa');
        duplicarTitular = ApexPages.currentPage().getParameters().get('duplicarTitular');

        /* Obtenemos el registro nuevo (la funcion getRecord utiliza el Id pasado en la URL como contexto),
         * con el campo del objeto relacionado relleno*/
        if(ApexPages.currentPage().getParameters().containsKey('contract')){
            System.debug('FROM LWC: '+JSON.deserialize(ApexPages.currentPage().getParameters().get('contract'), Contract.class));
            contract = (Contract) JSON.deserialize(ApexPages.currentPage().getParameters().get('contract'), Contract.class);
        }else{
            contract = (Contract) stdController.getRecord();
        }

        botonGuardarInactivo = false;
        controlGuardado = false;

        // Se generan Maps de los tipos de registros
        Map<String, RecordType> tiposRegistro = Util.objectsRecordTypesMap.get('Contract');
        mapaTiposRegistro = new Map<String, String>();
        mapaTiposRegistroPorNombre = new Map<String, String>();
        String ID;

        for ( String nombre : tiposRegistro.keyset() )
        {
            ID = tiposRegistro.get(nombre).Id;
            mapaTiposRegistro.put( ID.left(15), nombre );
            mapaTiposRegistroPorNombre.put( nombre, ID.left(15) );
        }

        /*20/12/2017 gmiranda: Faltaba por añadirle el id de la cuenta al contrato y refrescamos direcciones*/
        String idAccount = contract.AccountId;
        recalcularDirecciones();

        // ################## COMPROBAR SI SE LLAMA DESDE BOTÓN "DUPLICAR CAMBIO TITULAR" ###############
        // Si en la URL llega algún ID se estará duplicando el contrato y cambiando
        // el titular o la tarifa que se esté empleando en el contrato a duplicar. Copiaremos todos los campos del
        // contrato original para que el usuario pueda modificarlos según convenga.

        if ( (duplicarTitular != null && duplicarTitular != '') )
        {
            System.debug('DUPLICAR CAMBIO DE TITULAR');
            String idContrato = duplicarTitular;
            List<Contract> contratos = getContracts(idContrato);

            contract = new Contract();

            if ( !contratos.isEmpty() )
            {
                // Se ACTUALIZA en la cuenta antigua (desde la que se DUPLICA) el motivo de baja
                contratoAnterior = contratos[0];
                cuentaID = contratoAnterior.AccountId;

                if(cuentaID != null)
                {
                    List<Account> cuentasActualizar = getAccountsToUpdate(cuentaID);

                    if ( !cuentasActualizar.isEmpty() )
                    {
                        cuentaAnterior = cuentasActualizar[0];
                        cuentaAnterior.Status_baja__c = 'Anulado';
                        cuentaAnterior.Motivo_baja__c = 'Cambio titular';
                        cuentaAnterior.Estado_baja__c = 'Cerrado';
                        cuentaAnterior.Fecha_baja__c = System.today();
                        cuentaAnterior.Fecha_cierre_baja__c = System.today();
                    }
                }

                // Se indica en el NUEVO contrato, cual era el anterior
                //MOD- El estado ha de estar activado por defecto
                contract.Contrato_anterior__c = contratoAnterior.Id;
                contract.Status = 'Activado';
                contract.Direccion_de_entrega__c = contratoAnterior.Direccion_de_entrega__c;
                contract.IsTitularChange__c = true;

                Id idTipoRegistro = setRecordTypeBasedOnPreviousContract();

                // Quitamos los campos del contrato NUEVO que tengan relación con la CUENTA asociada (se va a cambiar el titular) y rellenamos los campos necesarios
                contract.AccountId = null;
                contract.N_telefono__c = null;
                contract.N_fax__c = null;
                contract.N_telefono_movil__c = null;
                contract.e_mail__c = null;
                contract.CIF__c = null;
                contract.RecordTypeId = idTipoRegistro;
                contract.Motivo_de_renovacion__c = 'Cambio titular';
                contract.Estado_2__c = 'Cambio titular';
                contract.OldCustomerNavCode__c = contratoAnterior.Account.Id_Navision__c;
                contract.OldShiptoCode__c = contratoAnterior.Direccion_de_entrega__r.Id_Navision__c;

                // Y actualizamos los que sobran en el contrato ANTIGUO
                contratoAnterior.Status = 'Anulado';
                contratoAnterior.Estado_2__c = 'Cambio titular';
                contratoAnterior.Direccion_de_entrega__c = null;

                // Se recupera/genera la dirección del contrato
                dirp = new Direcci_n_de_entrega__c();
                direccionesEnvioCustom = new List<DireccionEntrega>();

                direccionesEnvio = getDireccionesDeEntregaFromId(contract.Direccion_de_entrega__c);

                mapaDirecciones = new Map<String, Direcci_n_de_entrega__c>();
                for ( Direcci_n_de_entrega__c direccion : direccionesEnvio )
                {
                    direccionesEnvioCustom.add( new DireccionEntrega(direccion) );
                    mapaDirecciones.put(direccion.Id, direccion);
                }

                // Si EXISTE direcciones, dejamos la primera dirección de entrega marcada por defecto
                if( !direccionesEnvioCustom.isEmpty() )
                {
                    direccionesEnvioCustom[0].selected = true; //REVISAR
                    direccionSeleccionada = direccionesEnvioCustom[0].dirID;
                }
                // Si no, se crea una nueva dirección vacía y se deja seleccionada
                else
                {
                    nuevaDireccionCustom = new DireccionEntrega();
                    nuevaDireccionCustom.dir = dirp;
                    direccionesEnvioCustom.add( nuevaDireccionCustom );
                    direccionesEnvioCustom[0].selected = true;
                    direccionSeleccionada = direccionesEnvioCustom[0].dirID;
                }

            }

        }
        // ################## COMPROBAR SI SE LLAMA DESDE BOTÓN "DUPLICAR CAMBIO TARIFA" #######################
        else if( (duplicarTarifa != null && duplicarTarifa != '') )
        {
            System.debug('DUPLICAR TARIFA');
            String idContrato = duplicarTarifa;
            contract = new Contract();
            List<Contract> contratos = getContracts(idContrato);

            if ( !contratos.isEmpty() )
            {
                contratoAnterior = contratos[0];
            }

            Id idCuentaAnterior = contratoAnterior.AccountId;
            
            /*Para actualizacion de motivos de baja*/
            if(idCuentaAnterior != null)
            {
                List<Account> cuentasActualizar = getAccountsToUpdate(idCuentaAnterior);

                if ( !cuentasActualizar.isEmpty() )
                {
                    cuentaAnterior = cuentasActualizar[0];
                }
            }

            if( esCambioTitular == false )
            {
                contract = contratoAnterior.clone(false, true, false, false);
            }

            contract.Contrato_anterior__c = contratoAnterior.Id;
            contract.Status = 'Activado';     //MOD- El estado ha de estar activado por defecto
            contract.Direccion_de_entrega__c = contratoAnterior.Direccion_de_entrega__c;

            Id idTipoRegistro = setRecordTypeBasedOnPreviousContract();

            cuentaID = contratoAnterior.AccountId;
            contract.RecordTypeId = idTipoRegistro;

            //MOD- Si es un duplicar tarifa, también se anula el anterior contrato.
            contract.Estado_2__c = 'Renovado';
            contratoAnterior.Status = 'Anulado';
            contratoAnterior.Estado_2__c = null;
            contract.Motivo_de_renovacion__c = 'Cambio tarifa';
            contract.Tarifa__c = null;

            // Se recupera/genera la dirección del contrato
            dirp = new Direcci_n_de_entrega__c();
            direccionesEnvioCustom = new List<DireccionEntrega>();

            if (cuentaID != null && cuentaID != '')
            {
                direccionesEnvio = getDireccionesDeEntregaForAccount(cuentaID);

                mapaDirecciones = new Map<String, Direcci_n_de_entrega__c>();

                for (Direcci_n_de_entrega__c direccion:direccionesEnvio)
                {
                    direccionesEnvioCustom.add( new DireccionEntrega(direccion) );
                    mapaDirecciones.put(direccion.Id, direccion);
                }

                nuevaDireccionCustom = new DireccionEntrega();

                // Si EXISTE direcciones, dejamos la primera dirección de entrega marcada por defecto
                if( !direccionesEnvioCustom.isEmpty() )
                {
                    direccionesEnvioCustom.add(nuevaDireccionCustom);
                    // Dejamos la primera dirección de entrega marcada por defecto
                    direccionesEnvioCustom[0].selected = true;
                    direccionSeleccionada = direccionesEnvioCustom[0].dirID;
                }
                // Si no, se crea una nueva dirección vacía y se deja seleccionada
                else
                {
                    nuevaDireccionCustom = new DireccionEntrega();
                    nuevaDireccionCustom.dir = dirp;
                    direccionesEnvioCustom.add( nuevaDireccionCustom );
                    direccionesEnvioCustom[0].selected = true;
                    direccionSeleccionada = direccionesEnvioCustom[0].dirID;
                }
            }
        }
        // ################## COMPROBAR SI SE LLAMA DESDE BOTÓN "NUEVO" ########################################
        else
        {
            // Obtener el tipo de registro de la cuenta
            String tipoRegistro = contract.RecordTypeId;

            nombreTipoRegistro = mapaTiposRegistro.get( tipoRegistro.left(15) );

            // Comprobamos si el contrato se está creando desde:
            // -Una Oportunidad
            if( contract.Oportunidad__c != null && ( (String) contract.Oportunidad__c ).startsWith('006') )
            {
                // Si se está creando desde una OPORTUNIDAD recuperamos la información del cliente asociado.
                oportunidadID = contract.Oportunidad__c;

                if ( oportunidadID != null && oportunidadID.startsWith('006') )
                {
                    oportunidad = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = : oportunidadID LIMIT 1];
                }

                // Recuperamos la información del cliente (CUENTA) asociado a la OPORTUNIDAD para rellenar los campos pertinentes en el contrato.
                if (oportunidad.AccountId != null)
                {
                    cuentaID = oportunidad.AccountId;

                    cuenta = getAccountById(cuentaID);

                    fillContractWithAccountDataAndOpportunity(cuenta, oportunidad);
                }

                // Recuperamos la información de DIRECCIÓN asociada a la CUENTA y se rellenan los campos del contrato.
                dirp = new Direcci_n_de_entrega__c();
                direccionesEnvioCustom = new List<DireccionEntrega>();

                if (cuentaID != null && cuentaID != '')
                {
                    direccionesEnvio = getDireccionesDeEntregaForAccount(cuentaID);

                    mapaDirecciones = new Map<String, Direcci_n_de_entrega__c>();
                    for (Direcci_n_de_entrega__c direccion:direccionesEnvio)
                    {
                        direccionesEnvioCustom.add( new DireccionEntrega(direccion) );
                        mapaDirecciones.put(direccion.Id, direccion);
                    }

                    nuevaDireccionCustom = new DireccionEntrega();
                    direccionesEnvioCustom.add(nuevaDireccionCustom);
                    // Dejamos la primera dirección de entrega marcada por defecto
                    direccionesEnvioCustom[0].selected = true;
                    direccionSeleccionada = direccionesEnvioCustom[0].dirID;
                }

            }
            // -Desde una cuenta.
            else if( contract.AccountId != null && ( (String) contract.AccountId ).startsWith('001') )
            {
                cuentaID = contract.AccountId;

                if ( cuentaID != null && cuentaID.startsWith('001') )
                {
                    cuenta = getAccountById(cuentaID);
                }

                fillContractWithAccountDataAndOpportunity(cuenta, null);

                // Recuperamos la información de DIRECCIÓN asociada a la CUENTA y se rellenan los campos del contrato.
                dirp = new Direcci_n_de_entrega__c();
                direccionesEnvioCustom = new List<DireccionEntrega>();

                if (cuentaID != null && cuentaID != '')
                {
                    direccionesEnvio = getDireccionesDeEntregaForAccount(cuentaID);

                    mapaDirecciones = new Map<String, Direcci_n_de_entrega__c>();
                    for (Direcci_n_de_entrega__c direccion:direccionesEnvio)
                    {
                        direccionesEnvioCustom.add( new DireccionEntrega(direccion) );
                        mapaDirecciones.put(direccion.Id, direccion);
                    }

                    nuevaDireccionCustom = new DireccionEntrega();
                    direccionesEnvioCustom.add(nuevaDireccionCustom);
                    // Dejamos la primera dirección de entrega marcada por defecto
                    direccionesEnvioCustom[0].selected = true;
                    direccionSeleccionada = direccionesEnvioCustom[0].dirID;
                }

            }
            // -Desde la propia pestaña de contratos
            else
            {
                dirp = new Direcci_n_de_entrega__c();
                direccionesEnvioCustom = new List<DireccionEntrega>();
                nuevaDireccionCustom = new DireccionEntrega();
                direccionesEnvioCustom.add(nuevaDireccionCustom);
                // Dejamos la primera dirección de entrega marcada por defecto
                direccionesEnvioCustom[0].selected = true;
                direccionSeleccionada = direccionesEnvioCustom[0].dirID;
            }

        }

        if(!isDuplicar && (isContractType(POLIZA_RECORDTYPE) || isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE))){
            fillDefaultFieldsForPolizaGLPGNLDepositoPropio();
        }
    }

    public class DefaultFieldsSettingException extends Exception {
        
    }

    public List<Direcci_n_de_entrega__c> getDireccionesDeEntregaForAccount(Id relatedAccountId){
        return new List<Direcci_n_de_entrega__c>(
                    [SELECT Id, Name, cuenta__r.Name, Pais__c, Provincia__c, Codigo_Postal__c, Tipo_de_camion__c, Direccion__c, Direccion_2__c, Poblacion__c
                     FROM Direcci_n_de_entrega__c
                     WHERE cuenta__c = : relatedAccountId]);
    }

    public List<Direcci_n_de_entrega__c> getDireccionesDeEntregaFromId(Id direccionDeEntregaId){
        return new List<Direcci_n_de_entrega__c>(
                    [SELECT Id, Name, cuenta__r.Name, Pais__c, Provincia__c, Codigo_Postal__c, Tipo_de_camion__c, Direccion__c, Direccion_2__c, Poblacion__c
                     FROM Direcci_n_de_entrega__c
                     WHERE Id = : direccionDeEntregaId]);
    }

    private List<Contract> getContracts(Id contractIdToQuery){
        return new List<Contract>(
                [
                    SELECT Id, OwnerExpirationNotice, SpecialTerms, Description, ShippingAddress, BillingAddress, ContractTerm, Status, ActivatedDate, CompanySignedDate,
                    CustomerSignedDate, StartDate, EndDate, AccountId, Name, ContractNumber, OwnerId, RecordTypeId, CustomerSignedTitle, Altitud__c, Aportaci_n_al_cliente__c,
                    Aportacion_maxima_interior__c, Caldera__c, Capacidad_tanque__c, CIF__c, Cod_forma_de_pago__c, Cod_forma_pago_servicios__c, Cod_tarifa__c, Cod_terminos_de_pago__c,
                    Cod_terminos_pago_servicios__c, Cod_dia_de_pago__c, Consumo_previsto_GWh__c, Consumo_previsto_tons__c,
                    Contrato_anterior__c, Coste_resolucion_anticipada__c, dcm_propano1__c, dcm_propano2__c, dcm_propano3__c, dcm_propano4__c, Direccion_de_entrega__c, dp_cad_min1__c,
                    dp_cad_min2__c, dp_cad_min3__c, dp_cad_min4__c, dp_cad_min5__c, dp_cad_min6__c, dto_Kg_1__c, dto_Kg_2__c, dto_Kg_3__c, dto_Kg_4__c, dto_Kg_5__c, dto_Kg_6__c, dto_a_o_1__c, dto_a_o_2__c,
                    dto_a_o_3__c, dto_a_o_4__c, Duracion_contrato_en_toneladas__c, Duraci_n_contrato_GWh__c, e_mail__c, Entrega_de_producto__c, Error_Sync__c, Fecha_prevista_1er_llenado__c,
                    Fecha_prevista_obra_civil__c, Fecha_ltima_Sync__c, IBAN__c, Id_Navision__c, Importe_alquiler_contador__c, Importe_contador_nuevo__c, Importe_derechos_acometida__c,
                    Importe_inspecci_n_quinquenal__c, Importe_modalidad_instalacion__c, Importe_prima__c, Importe_prima_por_tonelada__c, Importe_reenganche__c, Importe_SAU__c, Importe_t_rmino_fijo__c,
                    Inertizado_Dep_Cliente__c, Inversion_no_recuperable__c, Inversion_recuperable__c, Modalidad_de_instalaci_n__c, Motivo_de_renovacion__c,
                    Nombre_cliente__c, N_mero_de_vaporizadores__c, N_fax__c, N_telefono__c, N_telefono_movil__c, Oportunidad__c, Origen__c, Origen_tipo_de_cliente__c, Perfil_base__c, Perfil_de_consumo__c, Prescriptor__c,
                    Prescriptor_no_en_BD__c, Producto_contratado__c, Rentabilidad_prevista__c,
                    Segmento_1__c, Segmento_2__c, Servicios__c, Estado_2__c, Subcontratista__C, SWI__c, Tipo_camion__c, Tipo_de_tanque__c, TP_tipo_instalacion__c, Uso__c, Vaporizaci_n_Nm3h__c, Tarifa__c,
                    BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, OldCustomerNavCode__c, OldShiptoCode__c, Ultima_lectura_de_contador__c,
                    Direccion_de_entrega__r.Id_Navision__c, Account.Id_Navision__c, Account.Segmento1__c, Tanque_propio__c, Duraci_n_del_contrato_a_os__c
                    FROM Contract
                    WHERE Id = : contractIdToQuery]);
    }

    private Account getAccountById(Id accountIdToRetrieve){
        return [
                    SELECT Id, Name, Id_Fiscal__c, E_mail__c, Fax, Phone, PersonMobilePhone, Codigo_Postal__c, Calle_Facturacion__c, Prescriptor__c,
                    Poblacion_Facturacion__c, Provincia__c, Pais_Facturacion__c, Origen__c
                    FROM Account
                    WHERE Id = : accountIdToRetrieve LIMIT 1
                ];
    }

    private List<Account> getAccountsToUpdate(Id accountIdToRetrieve){
        return new List<Account>([
                                SELECT Id, Status_baja__c, Motivo_baja__c, Estado_baja__c, Detalles_baja__c, Fecha_baja__c, Fecha_cierre_baja__c, IBAN__c
                                FROM Account
                                WHERE Id = : accountIdToRetrieve]);
    }

    private Id setRecordTypeBasedOnPreviousContract(){
        String tipoRegistro = contratoAnterior.RecordTypeId;
        nombreTipoRegistro = mapaTiposRegistro.get(tipoRegistro);

        if (tipoRegistro.length() == 18)
        {
            nombreTipoRegistro = mapaTiposRegistro.get( tipoRegistro.left(15) );
        }

        // Se inicializa la variable del tipo de registro con el RT del contratoAnterior
        Id idTipoRegistro = contratoAnterior.RecordTypeId;

        System.debug('Contrato Anterior '+contratoAnterior.RecordTypeId+' - '+contratoAnterior.Tanque_propio__c+ ' - '+contratoAnterior.Account.Segmento1__c);

        // Se comprueba si idTipoRegistro tiene que tener un valor diferente al del contratoAnterior
        if(contratoAnterior.RecordTypeId == Util.objectsRecordTypesMap.get('Contract').get('From_Navision').Id)
        {
            if(contratoAnterior.Tanque_propio__c == false && contratoAnterior.Account.Segmento1__c != null && contratoAnterior.Account.Segmento1__c != '')
            {
                if( contratoAnterior.Account.Segmento1__c.equals('Depósito') )
                {
                    idTipoRegistro = Util.objectsRecordTypesMap.get('Contract').get('GLP').Id;
                    nombreTipoRegistro = 'GLP';
                }
                else if( contratoAnterior.Account.Segmento1__c.equals('Canalizado') )
                {
                    idTipoRegistro = Util.objectsRecordTypesMap.get('Contract').get('Poliza').Id;
                    nombreTipoRegistro = 'Poliza';
                }
            }
            else
            {
                idTipoRegistro = Util.objectsRecordTypesMap.get('Contract').get('Deposito_propio').Id;
                nombreTipoRegistro = 'Deposito_propio';
            }
        }
        return idTipoRegistro;
    }
    
    private Contact getRelatedContact(Id oppId){
        try{
            return [SELECT Id, Contact.Email FROM OpportunityContactRole WHERE Role = 'Firmante de contrato' AND OpportunityId =: oppId].Contact;
        }catch(System.QueryException e){
            if(e.getMessage().startsWith('List has no rows for assignment to SObject')){
                System.debug(LoggingLevel.WARN, 'La póliza no tiene un contacto "Firmante de contrato" en la oportunidad relacionada.');
            }else{
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
        return null;
    }

    private void fillDefaultFieldsForPolizaGLPGNLDepositoPropio(){
        System.debug('fillDefaultFieldsForPolizaGLPGNLDepositoPropio '+contract.RecordTypeId);
        Id accountId = null;
        CPQ_Quote.QuoteWrapper quoteWrapper = null;
        CPQ_TablesDataWrapper tablesData = null;
        List<Stretch__c> stretches = new List<Stretch__c>();
        Contact firmadoPorCliente = null;

        if(isContractType(POLIZA_RECORDTYPE)){
            // Get the account from the related opportunity record:
            if(contract.SBQQ__Opportunity__c == null){
                System.debug(LoggingLevel.WARN, 'La póliza no tiene una oportunidad relacionada.');
            }
            try{
                Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = : contract.SBQQ__Opportunity__c LIMIT 1];
                
                accountId = opp.AccountId;
                firmadoPorCliente = getRelatedContact(opp.Id);
            }catch(Exception e){

            }
            
        }else if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
            // Get the account from the related quote record:
            System.debug('CONTRACT '+contract);
            try{
                quote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Dimension1__c, SBQQ__Account__c, PaymentMethod__c, PaymentTerm__c
                         FROM SBQQ__Quote__c WHERE Id =: contract.SBQQ__Quote__c];
            }catch(Exception e){
                System.debug(LoggingLevel.WARN, 'El contrato no tiene una oferta relacionada.');
            }
            if(quote != null){
                accountId = quote?.SBQQ__Account__c;
                quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{quote?.Id})[0];
                tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);
            
                Map<Id, List<Stretch__c>> stretchesByQuoteId = CPQ_StretchService.getStretchesByQuoteId(new Set<Id>{quote?.Id});
                if(stretchesByQuoteId.containsKey(quote?.Id)){
                    stretches = stretchesByQuoteId.get(quote?.Id);
                }
                firmadoPorCliente = getRelatedContact(quote?.SBQQ__Opportunity2__c);
            }
        }

        // Set the account:
        if(contract.AccountId == null){
            contract.AccountId = accountId;
            System.debug('acId:'+accountId);
            //System.debug('cuenta selec'+cuentaSeleccionada);
            if(accountId != null ){
                Account acc = [SELECT Id, Calle_Facturacion__c,Provincia__c, Pais_Facturacion__c, Poblacion_Facturacion__c, Codigo_Postal__c  FROM Account WHERE Id =:accountId];

                contract.BillingStreet          = acc.Calle_Facturacion__c;
                contract.BillingState           = acc.Provincia__c;
                contract.BillingCountry         = acc.Pais_Facturacion__c;
                contract.BillingCity            = acc.Poblacion_Facturacion__c;
                contract.BillingPostalCode      = acc.Codigo_Postal__c;
            }
        }

        refreshCalculatedFields();
        recalcularDirecciones();

        // Datos Contacto > Estado 2
        contract.Estado_2__c = null;
        // Datos Contacto > Estado
        contract.Status = 'Borrador';
        // Datos Contacto > Firmado por el cliente
        contract.CustomerSignedId = firmadoPorCliente?.Id;
        // Firmado por la compañía
        contract.CompanySignedId = Userinfo.getUserId();
        // DNI
        // Dni is a formula field (CustomerSigned.DNI__c)
        // e-mail
        contract.e_mail__c = firmadoPorCliente?.Email;


        if(quote != null){
            // ================ GLP ================ //
            if(isContractType(GLP_RECORDTYPE)){
                // Telemedida
                contract.Telemedida__c = quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.TELEMEDIDA) != null;
                // Toma agua < 15 m.
                contract.Toma_agua_15_m__c = true;
            }

            // ================ GNL ================ //
            if(isContractType(GNL_RECORDTYPE)){
                // Datos de instalación > Tipo GNL
                contract.Tipo_GNL__c = (quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.SPOT) != null) ? 'SPOT' : 'PLATINO';
            }

            // ================ GLP & GNL ================ //
            if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE)){
                
                // Condiciones de pago > Cod. forma pago servicios
                contract.Cod_forma_pago_servicios__c = quote.PaymentMethod__c;
                // Condiciones de pago > Cod. terminos pago servicios
                contract.Cod_terminos_pago_servicios__c = quote.PaymentTerm__c;

                // Inversión en instalación > Importe depósito
                contract.Importe_dep_sito__c = CPQ_AggregateUtil.convertToZeroIfNull(
                    quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.SBQQ__NetTotal__c
                );
                
                Set<String> otherEquipmentProductCodes = new Set<String>(CPQ_QuoteLineService.getProductCodesForLines(
                    quoteWrapper.getLinesByProductFamily(CPQ_ProductFamilies.OTROS_EQUIPOS)));

                // Inversión en instalación > Importe instalación exterior
                contract.Importe_instalaci_n_exterior__c = CPQ_AggregateUtil.sumFieldForRecords(
                    quoteWrapper.getLinesForMultipleProductCodes(tablesData.emd.filterProductCodesByIsIndoor(false, otherEquipmentProductCodes)),
                    SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
                );
                // Inversión en instalación > Importe instalación interior
                contract.Importe_instalaci_n_interior__c = CPQ_AggregateUtil.sumFieldForRecords(
                    quoteWrapper.getLinesForMultipleProductCodes(tablesData.emd.filterProductCodesByIsIndoor(true, otherEquipmentProductCodes)),
                    SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
                );
                // Inversión en instalación > Importe obra Civil
                contract.Importe_obra_Civil__c = CPQ_AggregateUtil.convertToZeroIfNull(
                    quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.OBRACIVIL)?.SBQQ__NetTotal__c
                );
                // Inversión en instalación > Importe proyectos
                contract.Importe_proyectos__c = CPQ_AggregateUtil.convertToZeroIfNull(
                    quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.PROYECTOMEMORIA)?.SBQQ__NetTotal__c
                );
                // Inversión en instalación > Importe equipos
                contract.Importe_equipos__c = CPQ_AggregateUtil.sumFieldForRecords(
                    quoteWrapper.getLinesByProductFamily(CPQ_ProductFamilies.OTROS_EQUIPOS),
                    SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
                );
                
                // Prima Servicios > Importe forfait
                contract.Importe_forfait__c = CPQ_AggregateUtil.convertToZeroIfNull(
                    quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.CUOTASINVERSION)?.SBQQ__NetTotal__c
                );
                // Prima Servicios > Importe servicios
                contract.Importe_servicios__c = CPQ_AggregateUtil.convertToZeroIfNull(
                    quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.PRIMASERVICIOS)?.SBQQ__NetTotal__c
                );
                
                for(Integer i=0;i<6 && i<stretches.size();i++){
                    // Prima Servicios > dcm propano1, dcm propano2, dcm propano3, dcm propano4, dcm propano5, dcm propano6
                    contract.put('dcm_propano'+(i+1)+'__c', stretches[i].FromConsumptionKG__c);
                    // Prima Servicios > dto(%/año)1, dto(%/año)2, dto(%/año)3, dto(%/año)4, dto(%/año)5, dto(%/año)6
                    contract.put('dto_a_o_'+(i+1)+'__c', stretches[i].DiscountKG__c);
                }

                // PrimaConfort (DocuSign) > Asistencia 24 h
                contract.DocusignAsistencia24H__c                       = quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.ATENCION24) != null;
                // PrimaConfort (DocuSign) > Suministro automático
                contract.DocuSignSuministroAutomatico__c                = quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.AUTOGAS) != null;
                // PrimaConfort (DocuSign) > Inspección instalación receptora
                contract.DocuSignInspeccionInstalacionReceptora__c      = quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.INSPOBLIGATORIA) != null;
                // PrimaConfort (DocuSign) > Lector a distancia nivel gas disponible
                contract.DocuSignLectorNivelDistancia__c                = quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.LECTORADISTANCIA) != null;
                // PrimaConfort (DocuSign) > Mantenimiento centro almacenamiento
                contract.DocuSignMantenimientoCentroAlmacenamient__c    = quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.MANTDEPOSITO) != null;
                // PrimaConfort (DocuSign) > Puesta a disposición del depósito
                contract.DocuSignPuestaDisposicionDeposito__c           = quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.PUESTAAPUNTO) != null;
                // PrimaConfort (DocuSign) > Contador
                contract.DocuSignContador__c                            = quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.SERVICIOCONTADOR) != null;
            }

            // GLP & GNL & Depósito propio
            if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                Boolean isAerial = tablesData.tmd.getFirstForName(quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.TankName__c)?.IsAerial__c;
                // Tipo de tanque
                contract.Tipo_de_tanque__c = isAerial != null && isAerial ? 'Aereo' : 'Enterrado';
                // Capacidad tanque
                contract.Capacidad_tanque__c = CPQ_AggregateUtil.convertToZeroIfNull(
                    tablesData.tmd.getFirstForName(quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.TankName__c)
                        ?.Capacity__c
                );
                // Condiciones de pago > Cod. forma de pago
                contract.Cod_forma_de_pago__c = quote.PaymentMethod__c;
                // Condiciones de pago > Cod. terminos de pago
                contract.Cod_terminos_de_pago__c = quote.PaymentTerm__c;
                // Consumo y duración > Duración del contrato (años)
                contract.Duraci_n_del_contrato_a_os__c = String.valueOf(quoteWrapper.Quote.Duration__c);
                // Consumo y duración > Consumo contratado
                contract.Consumo_previsto_tons__c = quoteWrapper.Quote.EstimatedConsumption__c / 1000;
                // Datos Contacto > Carburante Autogas
                // It's a formula field, no need to fill it here.

                // Tarifa Gas > Tarifa
                // Find the Pricebook with the Rate name:
                System.debug('getfirstline::'+quoteWrapper.getFirstLineByProductFamilyExcludingProductCodes(CPQ_ProductFamilies.TARIFAS, new Set<String>{CPQ_ProductCodes.TARIFA}));
                System.debug('Assign tarifa:'+findPricebookIdForRateProductCode(quoteWrapper.getFirstLineByProductFamilyExcludingProductCodes(CPQ_ProductFamilies.TARIFAS, new Set<String>{CPQ_ProductCodes.TARIFA})?.SBQQ__ProductCode__c));
                contract.Tarifa__c = findPricebookIdForRateProductCode(quoteWrapper.getFirstLineByProductFamilyExcludingProductCodes(CPQ_ProductFamilies.TARIFAS, new Set<String>{CPQ_ProductCodes.TARIFA})?.SBQQ__ProductCode__c);
            }

            // GLP & DEPOSITO PROPIO
            if(isContractType(GLP_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                for(Integer i=0;i<6 && i<stretches.size();i++){
                    // Tarifa Gas > dto(€/Kg)1, dto(€/Kg)2, dto(€/Kg)3, dto(€/Kg)4, dto(€/Kg)5, dto(€/Kg)6
                    contract.put('dto_Kg_'+(i+1)+'__c', stretches[i].DiscountKG__c);
                    // Tarifa Gas > dp cad min1, dp cad min2, dp cad min3, dp cad min4, dp cad min5, dp cad min6
                    contract.put('dp_cad_min'+(i+1)+'__c', stretches[i].FromConsumptionKG__c);
                    if(quoteWrapper.Quote.EstimatedConsumption__c == stretches[i].FromConsumptionKG__c){
                        // Tarifa Gas > Tramo Contrato (DocuSign)
                        contract.DocuSignTramoContrato__c = String.valueOf(i+1);
                    }
                }
                
                // Tarifa Gas > Duración descuento (años)
                contract.DocuSignDiscountDuration__c = quoteWrapper.DiscountDurationInYears;
            }

            // DEPOSITO PROPIO
            if(isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                List<SBQQ__QuoteLine__c> tankLines = quoteWrapper.getLinesByProductCode(CPQ_ProductCodes.DEPOSITO);
                for(Integer i=0;i<tankLines.size() && i < 4;i++){
                    Boolean isAerial = tablesData.tmd.getFirstForName(tankLines[i].TankName__c)?.IsAerial__c;

                    // Datos Instalación (DocuSign) > Modelo Depósito 1 (DocuSign)
                    contract.put('DocuSignModeloDeposito'+(i+1)+'__c', tankLines[i].TankName__c);
                    // Datos Instalación (DocuSign) > Nº de depósitos 1 (DocuSign)
                    contract.put('DocuSignNumeroDepositos'+(i+1)+'__c', tankLines[i].SBQQ__Quantity__c);
                    // Datos Instalación (DocuSign) > Capacidad litros depósito 1
                    contract.put('DocuSignCapacidadLitrosDeposito'+(i+1)+'__c', tablesData.tmd.getFirstForName(tankLines[i].TankName__c)?.Capacity__c);
                    // Datos Instalación (DocuSign) > Aéreo Depósito 1 (DocuSign)
                    contract.put('DocuSignAereoDeposito'+(i+1)+'__c', isAerial);
                    // Datos Instalación (DocuSign) > Enterrado Depósito 1 (DocuSign)
                    contract.put('DocuSignEnterradoDeposito'+(i+1)+'__c', !isAerial);
                }
            }
        }
        // For the Carburante__c field:
        Formula.recalculateFormulas(new List<Contract>{contract});
    }

    private Id findPricebookIdForRateProductCode(String code){
        try{
            return [SELECT Id FROM Pricebook2 WHERE Name_DelWhitespaces__c =: code].Id;
        }catch(Exception e){
            System.debug('Exception findPB: '+e.getMessage());
        }
        return null;
    }

    private Boolean isContractType(Id type){
        return contract.RecordTypeId == type;
    }

    public void refreshCalculatedFields(){
        recuperarDatosDeCuenta();

        if(contract.StartDate != null && contract.Duraci_n_del_contrato_a_os__c != null){
            // Consumo y duración > Fecha fin contrato
            contract.Fecha_fin_contrato__c = contract.StartDate.addYears(Integer.valueOf(contract.Duraci_n_del_contrato_a_os__c));
        }

        if(quote != null){
            if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{quote.Id})[0];
                Decimal earlyTermination = calculateEarlyTermination(quoteWrapper);
                
                // ================ GLP & DEPOSITO PROPIO ================ //
                if(isContractType(GLP_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){

                    if(contract.Duraci_n_del_contrato_a_os__c != null){
                        // Consumo y duración > Duracion contrato en toneladas
                        contract.Duracion_contrato_en_toneladas__c = (quoteWrapper.Quote.EstimatedConsumption__c * Integer.valueOf(contract.Duraci_n_del_contrato_a_os__c)) / 1000;
                    }

                    if(earlyTermination != null){
                        // Coste resolucion anticipada (€/tonelada).
                        contract.Coste_resolucion_anticipada_toneladas__c = earlyTermination / (quoteWrapper.Quote.EstimatedConsumption__c / 1000);
                    }
                }
                
                // ================ GLP & GNL & DEPOSITO PROPIO ================ //
                if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                    if(earlyTermination != null){
                        // Consumo y duración > Coste resolucion anticipada (€/año)
                        contract.Coste_resolucion_anticipada__c = earlyTermination;
                    }
                }
            }
        }
    }

    /*
       public void setDireccionEnvio()
       {
        System.Debug('## before setDireccionEnvio direccionSeleccionada: ' + direccionSeleccionada);
        if (direccionSeleccionada != null && direccionSeleccionada != '')
        {
            // Aquí imagino que habrá que cambiar la información de direcciones del contrato
            contract.ShippingStreet = mapaDirecciones.get(direccionSeleccionada).Direccion__c;
            contract.ShippingCity = mapaDirecciones.get(direccionSeleccionada).Direccion_2__c;
            contract.ShippingState = mapaDirecciones.get(direccionSeleccionada).Provincia__c;
            contract.ShippingCountry = mapaDirecciones.get(direccionSeleccionada).Pais__c;
            contract.ShippingPostalCode = mapaDirecciones.get(direccionSeleccionada).Codigo_Postal__c;
            contract.Tipo_camion__c = mapaDirecciones.get(direccionSeleccionada).Tipo_de_camion__c;
        }
        else
        {
            contract.ShippingStreet = '';
            contract.ShippingCity = '';
            contract.ShippingState = '';
            contract.ShippingCountry = '';
            contract.ShippingPostalCode = '';
            contract.Tipo_camion__c = '';
        }
        System.Debug('## after setDireccionEnvio direccionSeleccionada: ' + direccionSeleccionada);
       }*/

    // Método para seleccionar una dirección de envío del cliente mostradas en la tabla. En caso de querer crear una nueva se
    // deberá seleccionar la última fila que viene en blanco y permite editar.
    /*public void marcarDireccion()
       {
        System.Debug('## before marcarDireccion direccionSeleccionada: ' + direccionSeleccionada + ' direccionesEnvioCustom: ' + direccionesEnvioCustom);
        System.Debug('## dirp: ' + dirp);
        for (DireccionEntrega dir:direccionesEnvioCustom)
        {
            if (dir.dirID != direccionSeleccionada)
            {
                dir.selected = false;
            }
            if ((direccionSeleccionada == null || direccionSeleccionada == '') && dir.dirID == null)
            {
                // Sirve para poner siempre la nueva direccion como por defecto.
                dir.selected = true;
            }
        }
        System.Debug('## after marcarDireccion direccionSeleccionada: ' + direccionSeleccionada + ' direccionesEnvioCustom: ' + direccionesEnvioCustom);
       }*/

    /* Método para guardar el registro de contrato.
    ** - Registra la nueva dirección (si es necesario, al crearse una nueva)
    ** - Crea el contrato
    ** - Añadir CONTRATOS DE SERVICIO al contrato.
    ** @change rcastanos (06/06/2019) se implementa el método insertDireccion directamente y se elimina su llamada
    */

    public void onSave()
    {
        if( !controlGuardado )
        {
            System.debug('On SAVE');

            controlGuardado = true;
            SavePoint savePoint = Database.setSavePoint();

            // Recorremos la LISTA de direccionesCustom DISPONIBLES para ver qué dirección ha sido seleccionada y marcarla en la variable direccionSeleccionada
            for ( DireccionEntrega direccion : direccionesEnvioCustom )
            {
                if ( direccion.selected )
                {
                    direccionSeleccionada = direccion.dirID;
                }
            }

            // ################## COMPROBRAR si la dirección existe en SF #################################
            Direcci_n_de_entrega__c nuevaDireccion;
            // Si NO esta en SF la dirección
            if ( direccionSeleccionada == null && (dirp.Direccion__c != null || dirp.Direccion_2__c != null || dirp.Poblacion__c != null || dirp.Provincia__c != null || dirp.Codigo_Postal__c != null /*|| dirp.Pais__c != null*/) )
            {
                nuevaDireccion = dirp;
                nuevaDireccion.cuenta__c = contract.AccountId;

                if ( nuevaDireccion != null )
                {
                    try
                    {
                        insert nuevaDireccion;
                    }
                    catch (Exception e)
                    {
                        LogUtil.crearLog('Error: ' + e.getMessage(), 'onSave', 'Direccion Envío', 'Error', true);
                        LogUtil.guardarLog();
                    }
                }

            }
            // EXISTE
            else
            {
                nuevaDireccion = mapaDirecciones.get(direccionSeleccionada);
            }

            // Ahora los contratos contarán con una dirección de envío asociada
            if (nuevaDireccion != null)
            {
                contract.Direccion_de_entrega__c = nuevaDireccion.Id;
            }

            //MOD- Si el contrato es de duplicación Guardamos sus estados.
            if( isDuplicar )
            {
                estado  = contract.Status;
                estado2 = contract.Estado_2__c;
                contract.Status = 'Borrador';
            }

            // En caso de ser CAMBIO DE TITULAR y de que el estado sea DISTINTO de BORRADOR hay que actualizar el titular (Account) de la direccion de entrega
            if( esCambioTitular && ESTADOS_ACTUALIZAR.contains( estado ) )
            {
                Direcci_n_de_entrega__c direccion = direccionesEnvioCustom[0].dir;
                direccion.cuenta__c = contract.AccountId;

                //Evitamos el envío ya que al enviar el contrato tambien se enviará el cliente
                DireccionEnvioUtil.semaforoUpdate = false;
                AccountUtil.semaforoUpdate = false;

                Database.SaveResult res2 = Database.update(direccion, false);
                AccountUtil.semaforoUpdate = true;
                DireccionEnvioUtil.semaforoUpdate = true;
                Database.Saveresult sr2 = res2;

                if( !sr2.isSuccess() )
                {
                    Database.Error err = sr2.getErrors()[0];
                    Database.rollback(savePoint);
                    LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoCPQController.onSave Cambio de cuenta de direccion de entrega', 'Contrato', 'Error', true);
                }
                LogUtil.guardarLog();

                // Al no ser borrador, se reinicializa la variable
                contract.IsTitularChange__c = false;
            }

            Database.SaveResult res = Database.insert(contract);
            Database.Saveresult sr = res;

            if( !sr.isSuccess() )
            {
                System.debug('Punto 9');
                Database.Error err = sr.getErrors()[0];
                Database.rollback(savePoint);
                LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoCPQController.onSave', 'Contrato', 'Error', true);
            }
            LogUtil.guardarLog();

            // Update the related account if required:
            if(cuentaSeleccionada.IBAN__c == null){
                    
                Database.SaveResult updateSaveResult = Database.update(new Account(Id = cuentaSeleccionada.Id, IBAN__c = contract.IBAN__c));
                
                if( !updateSaveResult.isSuccess() ) {
                    System.debug('Punto 9');
                    Database.Error err = updateSaveResult.getErrors()[0];
                    Database.rollback(savePoint);
                    LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoCPQController.onSave', 'Account', 'Error', true);
                }
                LogUtil.guardarLog();
            }

            System.debug('contract '+contract);
            System.debug('cuenta '+cuenta);

        }

    }

    // Método para forzar el paso por el controlador cuando se insertan campos en el nuevo registro de dirección de entrega
    // para que los datos se almacenen en la variable del controlador.
    public void setDir()
    {
        System.Debug('## before setDir dirp: ' + dirp);
        System.Debug('## after setDir');
    }

    // Método para obtener las direcciones de entrega del cliente seleccionado cuando cambian el cliente destinatario
    public void recalcularDirecciones()
    {
        // Also retrieve the account data again in case it has changed:
        recuperarDatosDeCuenta();

        if( (duplicarTitular != null && duplicarTitular != '') )
        {
            System.Debug('## Es cambio de titular');
        }
        else
        {
            if (contract.AccountId != null && cuentaID != contract.AccountId)
            {
                cuentaID = contract.AccountId;
                direccionesEnvioCustom = new List<DireccionEntrega>();

                    direccionesEnvio = getDireccionesDeEntregaForAccount(cuentaID);

                    mapaDirecciones = new Map<String, Direcci_n_de_entrega__c>();
                    for (Direcci_n_de_entrega__c direccion:direccionesEnvio)
                    {
                        direccionesEnvioCustom.add( new DireccionEntrega(direccion) );
                        mapaDirecciones.put(direccion.Id, direccion);
                    }

                    nuevaDireccionCustom = new DireccionEntrega();
                    direccionesEnvioCustom.add(nuevaDireccionCustom);
                    direccionesEnvioCustom[0].selected = true;
                    direccionSeleccionada = direccionesEnvioCustom[0].dirID;
            }
            else if (contract.AccountId == null  && cuentaID != null)
            {
                cuentaID = null;
                direccionesEnvioCustom = new List<DireccionEntrega>();
                nuevaDireccionCustom = new DireccionEntrega();
                direccionesEnvioCustom.add(nuevaDireccionCustom);
                direccionesEnvioCustom[0].selected = true;
                direccionSeleccionada = direccionesEnvioCustom[0].dirID;
            }
        }
    }
    // Método que se ejecuta cuando el usuario selecciona una cuenta desde el LOOKUP de la página VF
    public void recuperarDatosDeCuenta()
    {
        Boolean hasChangedAccount = contract.AccountId != cuentaSeleccionada?.Id;
        //Obtencion de datos de cuenta
        if (contract.AccountId != null)
        {
            cuentaSeleccionada = [SELECT Id, Name, Id_Fiscal__c, Mobile_Phone_No__c, E_mail__c, PersonEmail, Fax, Phone,
                                  Calle_Facturacion__c, Provincia__c, Poblacion_Facturacion__c, Pais_Facturacion__c, Codigo_Postal__c, IBAN__c
                                  FROM Account
                                  WHERE Id =:contract.AccountId Limit 1];

            if(hasChangedAccount){
                // Every time the selected account changes the fields below will be overwritten for contract:
                // IBAN
                contract.IBAN__c = cuentaSeleccionada.IBAN__c;
            }
            // Teléfono principal
            contract.N_telefono__c = cuentaSeleccionada.Phone;
            // Nº fax
            contract.N_fax__c = cuentaSeleccionada.Fax;
            // CIF
            contract.CIF__c = cuentaSeleccionada.Id_Fiscal__c;
            // Teléfono secundario
            contract.N_telefono_movil__c = cuentaSeleccionada.Mobile_Phone_No__c;

            // Fill the contract email with the account's one if not one of the types below:
            if(!(isContractType(POLIZA_RECORDTYPE) || isContractType(GLP_RECORDTYPE)
            || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE))){
                contract.e_mail__c = cuentaSeleccionada.E_mail__c;
            }
            // For the Carburante__c field:
            Formula.recalculateFormulas(new List<Contract>{contract});
        }
    }

    //MOD - Actualizamos el contrato anterior y el estado. Al cambiar a anulado, no se va a enviar el cliente antiguo
    public PageReference actualizarEstado()
    {
        // Si estamos duplicando un contrato y cambiando el titular habria que actualizar el contrato anterior
        SavePoint savePoint = Database.setSavePoint();

        /* MOD - Si el estado del contrato es BORRADOR, no se ejecuta la actualización entera del contrato/cuenta anterior
        ** (se tiene que realizar al actualizarlo en el registro), solo se realiza la actualización del estado a Activado.
        */
        if( !ESTADOS_ACTUALIZAR.contains( estado ) && esCambioTitular )
        {
            Contract contratoAux = new Contract(
                Id = contratoAnterior.Id,
                Status = 'Activado'
                );

            update contratoAux;
        }
        // Al NO ser estado borrador
        else
        {
            if ( isDuplicar && contratoAnterior != null )
            {
                Database.SaveResult sr = Database.update(contratoAnterior);

                if( !sr.isSuccess() )
                {
                    Database.Error err = sr.getErrors()[0];
                    Database.rollback(savePoint);
                    LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoCPQController.actualizarEstado', 'Contrato', 'Error', true);
                }

                Database.SaveResult sr2 = Database.update(cuentaAnterior);
                if( !sr.isSuccess() )
                {
                    Database.Error err = sr.getErrors()[0];
                    Database.rollback(savePoint);
                    LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoCPQController.actualizarEstado', 'Cuenta', 'Error', true);
                }
            }
        }

        //MOD - Solo se ACTUALIZA el nuevo ESTADO si es Activado o Anulado (NO esta en BORRADOR).
        if( estado != null && estado2 != null && isDuplicar && ESTADOS_ACTUALIZAR.contains( estado ) )
        {
            contract.Status = estado;
            contract.Estado_2__c = estado2;

            if( cuentaSeleccionada != null )
            {
                contract.BillingStreet          = cuentaSeleccionada.Calle_Facturacion__c;
                contract.BillingState           = cuentaSeleccionada.Provincia__c;
                contract.BillingCountry         = cuentaSeleccionada.Pais_Facturacion__c;
                contract.BillingCity            = cuentaSeleccionada.Poblacion_Facturacion__c;
                contract.BillingPostalCode      = cuentaSeleccionada.Codigo_Postal__c;
            }

            //Al haber hecho un insert, no se por qué se hace esto pero si el estado no cambia no se va a sincronizar de nuevo.
            Database.SaveResult sr = Database.update(contract);

            if( !sr.isSuccess() )
            {
                Database.Error err = sr.getErrors()[0];
                Database.rollback(savePoint);
                LogUtil.crearLog('Error: ' + err.getMessage() + 'contract.RecordTypeId: ' + contract.RecordTypeId, 'NuevoContratoCPQController.actualizarEstado', 'Contrato', 'Error', true);
            }
        }

        return new PageReference('/' + contract.Id);
    }

    public void fillContractWithAccountDataAndOpportunity(Account relatedAccount, Opportunity relatedOpportunity){
        if ( relatedAccount != null )
        {
            //Recogida de INFORMACIÓN DE CUENTA
            contract.AccountId = relatedAccount.Id;
            contract.CIF__c = relatedAccount.Id_Fiscal__c;
            contract.BillingStreet = relatedAccount.Calle_Facturacion__c;
            contract.BillingCity = relatedAccount.Poblacion_Facturacion__c;
            contract.BillingState = relatedAccount.Provincia__c;
            contract.BillingCountry = relatedAccount.Pais_Facturacion__c;
            contract.BillingPostalCode = relatedAccount.Codigo_Postal__c;
            contract.Origen__c = relatedAccount.Origen__c;
            contract.Prescriptor__c = relatedAccount.Prescriptor__c;
        
            //Recogida de INFORMACIÓN DE CONTACTO (o de OpportunityContactRole en caso de no existir la de contacto)
            List<Contact> contactoPrincipal = [
                SELECT Id, Phone, MobilePhone, Fax, Email
                FROM Contact
                WHERE AccountId =: relatedAccount.Id and Contacto_principal__c = true
            ];
            
        
            if( !contactoPrincipal.isEmpty() )
            {
                contract.N_telefono__c = contactoPrincipal.get(0).Phone;
                contract.N_telefono_movil__c = contactoPrincipal.get(0).MobilePhone;
                contract.N_fax__c = contactoPrincipal.get(0).Fax;
                contract.E_mail__c = contactoPrincipal.get(0).Email;
            }
            else
            {
                List<OpportunityContactRole> listaContactosRol = null;
                if(relatedOpportunity == null){
                    Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([ SELECT Id FROM Opportunity WHERE AccountId =: relatedAccount.Id ]);
        
                    listaContactosRol = [
                        SELECT Id, ContactId, IsPrimary, OpportunityId, Role
                        FROM OpportunityContactRole
                        WHERE OpportunityId IN :opportunities.keySet()
                    ];
                }else{
                    listaContactosRol = [
                        SELECT Id, ContactId, IsPrimary, OpportunityId, Role
                        FROM OpportunityContactRole
                        WHERE OpportunityId=:relatedOpportunity.Id
                    ];
                }
        
                if( !listaContactosRol.isEmpty() )
                {
                    Boolean encontradoPrimario = false;
                    OpportunityContactRole contactoRol = null;
        
                    for(OpportunityContactRole c: listaContactosRol)
                    {
                        if(c.IsPrimary)
                        {
                            encontradoPrimario = true;
                            contactoRol = c;
                            break;
                        }
                    }
                    if( !encontradoPrimario )
                    {
                        ApexPages.Message mensajeError = new ApexPages.Message(ApexPages.Severity.ERROR, 'Es necesario que haya un contacto principal en la cuenta o una función de contacto de oportunidad que sea primaria.');
                        ApexPages.addMessage(mensajeError);
                        botonGuardarInactivo = true;
                        System.debug('ERROR: Es necesario que haya un contacto principal en la cuenta o una función de contacto de oportunidad que sea primaria.');
                    }
                    else
                    {
                        if(contactoRol != null)
                        {
                            List<Contact> contacto = [SELECT Id, Phone, MobilePhone, Fax, Email FROM Contact WHERE Id=:contactoRol.ContactId];
                            contract.N_telefono__c = contacto.get(0).Phone;
                            contract.N_telefono_movil__c = contacto.get(0).MobilePhone;
                            contract.N_fax__c = contacto.get(0).Fax;
                            contract.E_mail__c = contacto.get(0).Email;
                        }
                    }
                }
                else
                {
                    ApexPages.Message mensajeError = new ApexPages.Message(ApexPages.Severity.ERROR, 'Es necesario que haya un contacto principal en la cuenta o alguna función de contacto en la oportunidad.');
                    ApexPages.addMessage(mensajeError);
                    botonGuardarInactivo = true;
                    System.debug('ERROR: Es necesario que haya un contacto principal en la cuenta o alguna función de contacto en la oportunidad.');
                }
        
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordTypeOption> getValidRecordTypeOptionsForQuoteContracts(){
        try {
            Map<String, Schema.RecordTypeInfo> m = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName() ;
            return new List<RecordTypeOption>{
                new RecordTypeOption(m.get(GLP_API).getName(), GLP_RECORDTYPE),
                new RecordTypeOption(m.get(GNL_API).getName(), GNL_RECORDTYPE),
                new RecordTypeOption(m.get(DEPOSITO_PROPIO_API).getName(), DEPOSITO_PROPIO_RECORDTYPE)
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class RecordTypeOption {

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public RecordTypeOption (String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    
    public Decimal calculateEarlyTermination(CPQ_Quote.QuoteWrapper quoteWrapper){
        if(contract.Duraci_n_del_contrato_a_os__c != null){
            CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

            Decimal installation = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesByProductCode(CPQ_ProductCodes.INSTALACION),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            Decimal dismantling = CPQ_AggregateUtil.convertToZeroIfNull(
                tablesData.tmd.getFirstForName(quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.TankName__c)
                    ?.Dismantle__c
            );

            Set<String> otherEquipmentProductCodes = new Set<String>(CPQ_QuoteLineService.getProductCodesForLines(
                quoteWrapper.getLinesByProductFamily(CPQ_ProductFamilies.OTROS_EQUIPOS)));

            Decimal equipmentsIndoors = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesForMultipleProductCodes(tablesData.emd.filterProductCodesByIsIndoor(true, otherEquipmentProductCodes)),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            Decimal equipmentsOutdoors = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesForMultipleProductCodes(tablesData.emd.filterProductCodesByIsIndoor(false, otherEquipmentProductCodes)),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            Decimal tank = CPQ_AggregateUtil.convertToZeroIfNull(
                quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.SBQQ__NetTotal__c
            );

            Decimal earlyTermination = CPQ_AggregateUtil.convertToZeroIfNull(
                tablesData.tmd.getFirstForName(quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.TankName__c)
                    ?.EarlyTermination__c
            );

            Decimal contractDuration = Integer.valueOf(contract.Duraci_n_del_contrato_a_os__c);

            return (installation + dismantling + equipmentsIndoors + (equipmentsOutdoors + tank) * earlyTermination) / contractDuration;
        }
        return null;
    }

    public List<Schema.FieldSetMember> FieldSet_InformacionDelSistema {
        get{
            if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Informacion_del_sistema_GLP_GNL_DP');
            }else{
                return getFieldSetMembers('Contract', 'Informacion_del_sistema');
            }
        }
    }
    public List<Schema.FieldSetMember> FieldSet_DatosDeCaptacion {
        get{
            if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Datos_de_captacion_GLP_GNL_DP');
            }else{
                return getFieldSetMembers('Contract', 'CPQ_Datos_de_captacion');
            }
        }
    }
    
    public List<Schema.FieldSetMember> FieldSet_Primaservicios {
        get{
            if(isContractType(GLP_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Primaservicios_GLP');
            }else if(isContractType(GNL_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Primaservicios_GNL');
            }
            return null;
        }
    }

    public List<Schema.FieldSetMember> FieldSet_InversionEnInstalacion {
        get{
            if(isContractType(GLP_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Inversion_en_instalacion_GLP');
            }else if(isContractType(GNL_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Inversion_en_instalacion_GNL');
            }
            return null;
        }
    }

    public List<Schema.FieldSetMember> FieldSet_DatosDeInstalacion {
        get{
            if(isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Datos_de_Instalacion_Deposito_Propio');
            }else if(isContractType(GLP_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Datos_de_Instalacion_GLP');
            }else if(isContractType(GNL_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Datos_de_Instalacion_GNL');
            }
            return null;
        }
    }
    
    public List<Schema.FieldSetMember> FieldSet_TarifasGas {
        get{
            if(isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Tarifas_Gas_Deposito_Propio');
            }else if(isContractType(GLP_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Tarifas_Gas_GLP');
            }else if(isContractType(GNL_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Tarifas_Gas_GNL');
            }else if(isContractType(POLIZA_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Tarifas_Gas_Poliza');
            }
            return null;
        }
    }
    
    public List<Schema.FieldSetMember> FieldSet_SuministroProducto {
        get{
            if(isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Suministro_Producto_Deposito_Propio');
            }else if(isContractType(GLP_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Suministro_Producto_GLP');
            }else if(isContractType(GNL_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Suministro_Producto_GNL');
            }else if(isContractType(POLIZA_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Suministro_Producto_Poliza');
            }
            return null;
        }
    }

    public List<Schema.FieldSetMember> FieldSet_Observaciones {
        get{
            if(isContractType(GLP_RECORDTYPE) || isContractType(GNL_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Observaciones_GLP_GNL');
            }else if(isContractType(POLIZA_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'CPQ_Observaciones');
            }
            return null;
        }
    }
    
    public List<Schema.FieldSetMember> FieldSet_DatosDeContacto {
        get{
            if(isContractType(GLP_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Datos_de_Contacto_GLP');
            }else if(isContractType(POLIZA_RECORDTYPE) || isContractType(DEPOSITO_PROPIO_RECORDTYPE) || isContractType(GNL_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'CPQ_Datos_de_Contacto');
            }
            return null;
        }
    }

    public List<Schema.FieldSetMember> FieldSet_CondicionesDePago {
        get{
            if(isContractType(DEPOSITO_PROPIO_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Condiciones_de_Pago_Deposito_propio');
            }else if(isContractType(GLP_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Condiciones_de_Pago_GLP');
            }else if(isContractType(GNL_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Condiciones_de_Pago_GNL');
            }else if(isContractType(POLIZA_RECORDTYPE)){
                return getFieldSetMembers('Contract', 'Condiciones_de_Pago_Poliza');
            }
            return null;
        }
    }

    public static List<Schema.FieldSetMember> getFieldSetMembers(String objectName, String fieldSetName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        return fieldSetObj.getFields(); 
    }  

}