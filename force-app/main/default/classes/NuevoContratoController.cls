public with sharing class NuevoContratoController
{

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
    public NuevoContratoController(ApexPages.StandardController stdController)
    {
        // Los datos para el duplicado, se pasan desde la URL del Botón
        duplicarTarifa = ApexPages.currentPage().getParameters().get('duplicarTarifa');
        duplicarTitular = ApexPages.currentPage().getParameters().get('duplicarTitular');

        /* Obtenemos el registro nuevo (la funcion getRecord utiliza el Id pasado en la URL como contexto),
         * con el campo del objeto relacionado relleno*/
        contract = (Contract) stdController.getRecord();

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
            List<Contract> contratos = new List<Contract>(
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
                    Direccion_de_entrega__r.Id_Navision__c, Account.Id_Navision__c, Account.Segmento1__c, Tanque_propio__c
                    FROM Contract
                    WHERE Id = : idContrato
                ]);

            contract = new Contract();

            if ( !contratos.isEmpty() )
            {
                // Se ACTUALIZA en la cuenta antigua (desde la que se DUPLICA) el motivo de baja
                contratoAnterior = contratos[0];
                cuentaID = contratoAnterior.AccountId;

                if(cuentaID != null)
                {
                    List<Account> cuentasActualizar = new List<Account>(
                        [
                            SELECT Id, Status_baja__c, Motivo_baja__c, Estado_baja__c, Detalles_baja__c, Fecha_baja__c, Fecha_cierre_baja__c
                            FROM Account
                            WHERE Id = : cuentaID]);

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

                // Se rellena el tipo de registro en el contrato NUEVO
                String tipoRegistro = contratoAnterior.RecordTypeId;
                nombreTipoRegistro = mapaTiposRegistro.get(tipoRegistro);

                if (tipoRegistro.length() == 18)
                {
                    nombreTipoRegistro = mapaTiposRegistro.get( tipoRegistro.left(15) );
                }

                // Se inicializa la variable del tipo de registro con el RT del contratoAnterior
                Id idTipoRegistro = contratoAnterior.RecordTypeId;

                // Se comprueba si idTipoRegistro tiene que tener un valor diferente al del contratoAnterior
                if( contratoAnterior.RecordTypeId == Util.objectsRecordTypesMap.get('Contract').get('From_Navision').Id )
                {
                    if( contratoAnterior.Tanque_propio__c == false && contratoAnterior.Account.Segmento1__c != null && contratoAnterior.Account.Segmento1__c != '' )
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

                direccionesEnvio = new List<Direcci_n_de_entrega__c>(
                    [SELECT Id, Name, cuenta__r.Name, Pais__c, Provincia__c, Codigo_Postal__c, Tipo_de_camion__c, Direccion__c, Direccion_2__c, Poblacion__c
                     FROM Direcci_n_de_entrega__c
                     WHERE Id = : contract.Direccion_de_entrega__c]);


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
            List<Contract> contratos = new List<Contract>(
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
                    Direccion_de_entrega__r.Id_Navision__c, Account.Id_Navision__c, Account.Segmento1__c, Tanque_propio__c
                    FROM Contract
                    WHERE Id = : idContrato]);

            if ( !contratos.isEmpty() )
            {
                contratoAnterior = contratos[0];
            }

            Id idCuentaAnterior = contratoAnterior.AccountId;
            
            /*Para actualizacion de motivos de baja*/
            if(idCuentaAnterior != null)
            {
                List<Account> cuentasActualizar = new List<Account>(
                    [
                        SELECT Id, Status_baja__c, Motivo_baja__c, Estado_baja__c, Detalles_baja__c, Fecha_baja__c, Fecha_cierre_baja__c
                        FROM Account WHERE Id = : idCuentaAnterior]);

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


            String tipoRegistro = contratoAnterior.RecordTypeId;
            nombreTipoRegistro = mapaTiposRegistro.get( tipoRegistro );

            if (tipoRegistro.length() == 18)
            {
                nombreTipoRegistro = mapaTiposRegistro.get( tipoRegistro.left(15) );
            }

            // Se inicializa la variable del tipo de registro con el RT del contratoAnterior
            Id idTipoRegistro = contratoAnterior.RecordTypeId;

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
                direccionesEnvio = new List<Direcci_n_de_entrega__c>(
                    [SELECT Id, Name, cuenta__r.Name, Pais__c, Provincia__c, Codigo_Postal__c, Tipo_de_camion__c, Direccion__c, Direccion_2__c, Poblacion__c
                     FROM Direcci_n_de_entrega__c
                     WHERE cuenta__c = : cuentaID]);

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

                    cuenta = [
                        SELECT Id, Name, Id_Fiscal__c, E_mail__c, Fax, Phone, PersonMobilePhone, Codigo_Postal__c, Calle_Facturacion__c, Prescriptor__c,
                        Poblacion_Facturacion__c, Provincia__c, Pais_Facturacion__c, Origen__c
                        FROM Account
                        WHERE Id = : cuentaID LIMIT 1
                    ];

                    if ( cuenta != null )
                    {
                        //Recogida de INFORMACIÓN DE CUENTA
                        contract.AccountId = cuenta.Id;
                        contract.CIF__c = cuenta.Id_Fiscal__c;
                        contract.BillingStreet = cuenta.Calle_Facturacion__c;
                        contract.BillingCity = cuenta.Poblacion_Facturacion__c;
                        contract.BillingState = cuenta.Provincia__c;
                        contract.BillingCountry = cuenta.Pais_Facturacion__c;
                        contract.BillingPostalCode = cuenta.Codigo_Postal__c;
                        contract.Origen__c = cuenta.Origen__c;
                        contract.Prescriptor__c = cuenta.Prescriptor__c;

                        //Recogida de INFORMACIÓN DE CONTACTO (o de OpportunityContactRole en caso de no existir la de contacto)
                        List<Contact> contactoPrincipal = [
                            SELECT Id, Phone, MobilePhone, Fax, Email
                            FROM Contact
                            WHERE AccountId =: cuentaID and Contacto_principal__c = true
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
                            List<OpportunityContactRole> listaContactosRol = [
                                SELECT Id, ContactId, IsPrimary, OpportunityId, Role
                                FROM OpportunityContactRole
                                WHERE OpportunityId=:oportunidad.Id
                            ];

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

                // Recuperamos la información de DIRECCIÓN asociada a la CUENTA y se rellenan los campos del contrato.
                dirp = new Direcci_n_de_entrega__c();
                direccionesEnvioCustom = new List<DireccionEntrega>();

                if (cuentaID != null && cuentaID != '')
                {
                    direccionesEnvio = new List<Direcci_n_de_entrega__c>(
                        [SELECT Id, Name, cuenta__r.Name, Pais__c, Provincia__c, Codigo_Postal__c, Tipo_de_camion__c, Direccion__c, Direccion_2__c, Poblacion__c
                         FROM Direcci_n_de_entrega__c
                         WHERE cuenta__c = : cuentaID]);

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
                    cuenta = [
                        SELECT Id, Name, Id_Fiscal__c, E_mail__c, Fax, Phone, PersonMobilePhone, Codigo_Postal__c, Calle_Facturacion__c, Prescriptor__c,
                        Poblacion_Facturacion__c, Provincia__c, Pais_Facturacion__c, Origen__c
                        FROM Account
                        WHERE Id = : cuentaID LIMIT 1
                    ];
                }

                if ( cuenta != null )
                {
                    //Recogida de INFORMACIÓN DE CUENTA
                    contract.AccountId = cuenta.Id;
                    contract.CIF__c = cuenta.Id_Fiscal__c;
                    contract.BillingStreet = cuenta.Calle_Facturacion__c;
                    contract.BillingCity = cuenta.Poblacion_Facturacion__c;
                    contract.BillingState = cuenta.Provincia__c;
                    contract.BillingCountry = cuenta.Pais_Facturacion__c;
                    contract.BillingPostalCode = cuenta.Codigo_Postal__c;
                    contract.Origen__c = cuenta.Origen__c;
                    contract.Prescriptor__c = cuenta.Prescriptor__c;

                    //Recogida de INFORMACIÓN DE CONTACTO (o de OpportunityContactRole en caso de no existir la de contacto)
                    List<Contact> contactoPrincipal = [
                        SELECT Id, Phone, MobilePhone, Fax, Email
                        FROM Contact
                        WHERE AccountId =: cuentaID and Contacto_principal__c = true
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
                        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([ SELECT Id FROM Opportunity WHERE AccountId =: cuentaID ]);

                        List<OpportunityContactRole> listaContactosRol = [
                            SELECT Id, ContactId, IsPrimary, OpportunityId, Role
                            FROM OpportunityContactRole
                            WHERE OpportunityId IN :opportunities.keySet()
                        ];

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

                // Recuperamos la información de DIRECCIÓN asociada a la CUENTA y se rellenan los campos del contrato.
                dirp = new Direcci_n_de_entrega__c();
                direccionesEnvioCustom = new List<DireccionEntrega>();

                if (cuentaID != null && cuentaID != '')
                {
                    direccionesEnvio = new List<Direcci_n_de_entrega__c>(
                        [SELECT Id, Name, cuenta__r.Name, Pais__c, Provincia__c, Codigo_Postal__c, Tipo_de_camion__c, Direccion__c, Direccion_2__c, Poblacion__c
                         FROM Direcci_n_de_entrega__c
                         WHERE cuenta__c = : cuentaID]);

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
                    LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoController.onSave Cambio de cuenta de direccion de entrega', 'Contrato', 'Error', true);
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
                LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoController.onSave', 'Contrato', 'Error', true);
            }
            LogUtil.guardarLog();
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

                direccionesEnvio = new List<Direcci_n_de_entrega__c>(
                    [SELECT Id, Name, cuenta__r.Name, Pais__c, Provincia__c, Codigo_Postal__c, Tipo_de_camion__c, Direccion__c, Direccion_2__c, Poblacion__c
                     FROM Direcci_n_de_entrega__c
                     WHERE cuenta__c = : cuentaID]);

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
        //Obtencion de datos de cuenta
        if (contract.AccountId != null)
        {
            cuentaSeleccionada = [SELECT Id, Name, Id_Fiscal__c, Mobile_Phone_No__c, E_mail__c, PersonEmail, Fax, Phone,
                                  Calle_Facturacion__c, Provincia__c, Poblacion_Facturacion__c, Pais_Facturacion__c, Codigo_Postal__c
                                  FROM Account
                                  WHERE Id =:contract.AccountId Limit 1];

            contract.CIF__c = cuentaSeleccionada.Id_Fiscal__c;
            contract.N_telefono_movil__c = cuentaSeleccionada.Mobile_Phone_No__c;
            contract.e_mail__c = cuentaSeleccionada.E_mail__c;
            contract.N_fax__c = cuentaSeleccionada.Fax;
            contract.N_telefono__c = cuentaSeleccionada.Phone;
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
                    LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoController.actualizarEstado', 'Contrato', 'Error', true);
                }

                Database.SaveResult sr2 = Database.update(cuentaAnterior);
                if( !sr.isSuccess() )
                {
                    Database.Error err = sr.getErrors()[0];
                    Database.rollback(savePoint);
                    LogUtil.crearLog('Error: ' + err.getMessage(), 'NuevoContratoController.actualizarEstado', 'Cuenta', 'Error', true);
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
                LogUtil.crearLog('Error: ' + err.getMessage() + 'contract.RecordTypeId: ' + contract.RecordTypeId, 'NuevoContratoController.actualizarEstado', 'Contrato', 'Error', true);
            }
        }

        return new PageReference('/' + contract.Id);
    }

}