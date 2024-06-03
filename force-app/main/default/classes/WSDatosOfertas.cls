@RestResource(urlMapping='/DatosOfertas/*')
global class WSDatosOfertas
{
    public static Map<String, Decimal> depositosConCoste;
    public static Map<String, OpcionesOfertaSTD__c> ofertasStdMap;
    public static Map<String, Map<String, Decimal> > costesDeLegalizacionMap;

    public static Boolean comprobarEnvioEmail = false;
    public static String identificadorOfertaExistente;

    @HttpPost
    webservice static String enviar(PeticionEnvioOferta peticion)
    {
        // ##region Declaraciones

            LogUtil.crearLog(JSON.serialize(peticion), 'Peticiones NewSales', 'WSDatosOfertas', 'Error', false);
            
            //Desactivo la creacion de funciones de contacto en el trigger de oportunidad, sino al insertarlas aqui crearia funciones de contacto extra
            OpportunityUtil.semaforoCreacionFuncionesDeContacto = false;
            
            System.debug('WSDatosOfertas.enviar - JSON: ' + peticion);
            Respuesta r = new Respuesta();
            String jRespuesta = '';
            
            EntidadesWSClientesYOfertas.DatosCliente datosCliente;
            List<Account> listaCuentas;
            Account cuenta;
            Id idCuenta;
            List<Contact> listaContactos;
            Contact contacto;
            Boolean crearOpportunityContactRole = false;
            List<Opportunity> listOpportunities;
            List<OpportunityContactRole> listOpportunityContactRoles;
            Map<String, OpportunityContactRole> mapOpportunityContactRoles; //Para la incidencia que devuelve un error cuando se inserta este objeto, puede que la lista anterior tuviera duplicados
            List<OpportunityPartner> listOpportunityPartner;
            List<OpportunityPartner> listOpportunityPartnerDelete;
            List<Partner> listPartners;
            List<Partner> listPartnersDelete;
            List<Quote> listQuotes;
            Map<String, List<Quote>> mapEmailQuotes;
            List<Equipo_actual__c> listEquiposActuales;
            List<Energia_Actual__c> listEnergiasActuales;
            List<Tramo__c> listTramos;
            List<Pack_de_servicio__c> listPacks;
            List<Deposito__c> listDepositos;
            List<Equipo_Ajuste__c> listEquiposAjuste;
            Quote quoteNS;
            List<EntidadesWSClientesYOfertas.Tramo> listaTramosNS;
            List<EntidadesWSClientesYOfertas.Deposito> listaDepositosNS;
            List<EntidadesWSClientesYOfertas.EquipoAjuste> listaEquiposAjustesNS;
            EntidadesWSClientesYOfertas.EquiposInstalarPrimagas equiposAjustesInstalarNS;
            List<EntidadesWSClientesYOfertas.Escalado> listaEscaladoNS;
            Opportunity oppAux;
            Set<String> setIdsNewSales;
            List<OfertaIds> listOfIds = null;
            Boolean error = false;
            Savepoint sp;
            Map<String, Pack_de_servicio__c> mapPacksServiciosDeOferta;
            Map<String, List<Servicio__c>> mapServiciosDeOferta;
            Pack_de_servicio__c packServicio;
            List<Servicio__c> listaServAux;
            List<Servicio__c> listaServiciosInsert;
            //List<Attachment> listAttachs;
            Attachment attachOferta;
            Id idPrescriptor;
            String nameOpp;
            List<Opportunity> listaOportunidadesUpdate;
            String fechaCreacionOportunidadAux;
            DateTime fechaCreacionOportunidad;
            Integer anyo;
            Integer mes;
            Integer dia;
            Integer hora;
            Integer minuto;
            Integer segundo;
            List<Direcci_n_de_entrega__c> listaDireccionesEntrega;
            Direcci_n_de_entrega__c direccionEntrega;
            Direcci_n_de_entrega__c dirAuxRecibida;
            Tramo__c tramoEscaladoAux;
            Map<String,Tramo__c> mapaQuoteIdTramo;
            List<String> listIdsQuotes;
            Database.DMLOptions dml;
            List<String> emailsDestinatarios;

            Map<String, Id> productosCreadosMap;

            depositosConCoste = new Map<String, Decimal>();
            for(DepositosMaestros__c deposito: [SELECT Id, D__c, Deposito__c FROM DepositosMaestros__c])
            {            
                depositosConCoste.put(deposito.Deposito__c, deposito.D__c);
            }

            ofertasStdMap = new Map<String, OpcionesOfertaSTD__c>();
            for(OpcionesOfertaSTD__c ofertaStd: [SELECT Id, Name, InversionSinDeposito__c, Deposito__c, Imp_inst_ext__c, Imp_inst_int__c, Imp_obra_civil__c, Imp_proyectos__c, Imp_equipos__c FROM OpcionesOfertaSTD__c])
            {            
                ofertasStdMap.put(ofertaStd.Name, ofertaStd);
            }

            costesDeLegalizacionMap = new Map<String, Map<String, Decimal>>();
            for(CostesLegalizacionProvincia__c costeL: [SELECT Id, Name, Coste__c, Deposito__c, Provincia__c FROM CostesLegalizacionProvincia__c])
            {            
                if (!costesDeLegalizacionMap.containsKey(costeL.Deposito__c))
                {
                    costesDeLegalizacionMap.put(costeL.Deposito__c, new  Map<String, Decimal>());
                    costesDeLegalizacionMap.get(costeL.Deposito__c).put(costeL.Provincia__c, costeL.Coste__c);
                }
                else
                {
                    costesDeLegalizacionMap.get(costeL.Deposito__c).put(costeL.Provincia__c, costeL.Coste__c);
                }
            }

        // ##endregion

        try
        {
            System.debug('WSDatosOfertas.enviar ----- INICIO');
            sp = Database.setSavepoint();

            //Permitir duplicados
            dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;

             //SI LA PETICION EXISTE Y HAY DATOS U OPORTUNIDADES

            if( peticion != null && ( (datosCliente = peticion.datosCliente) != null  || ( peticion.oportunidades != null && !peticion.oportunidades.isEmpty() ) ) )
            {
                System.debug('WSDatosOfertas.enviar ----- Con datos');

                productosCreadosMap = new Map<String, Id>();
                for(Product2 prod : [SELECT Id,Name FROM Product2])
                {
                    productosCreadosMap.put(prod.Name, prod.Id);
                }
                System.debug('##Productos: ' + productosCreadosMap);

                if( !String.isBlank(datosCliente.nombre) && !String.isBlank(datosCliente.telefono) )
                {
                    // obtener el id del prescriptor si se ha enviado
                    /*if(!String.isBlank(datosCliente.prescriptor))
                       {
                        idPrescriptor = Id.valueOf(datosCliente.prescriptor);
                       }
                       else
                       {
                        idPrescriptor = null;
                       }*/

                    // si se ha indicado compañía en el cliente, comprobar si existe una cuenta con el nombre indicado para la compañía de los datos del cliente
                    String nombre = datosCliente.compania;

                    if( String.isBlank(nombre) )
                    {
                        nombre = datosCliente.nombre;

                        if( !String.isBlank(datosCliente.apellidos) )
                        {
                            nombre += ' ' + datosCliente.apellidos;
                        }
                    }

                    listaCuentas = [select Id, Name, ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Actividad__c, Sub_actividad__c,
                                    Calle_Facturacion__c, Id_fiscal__c, Poblacion_Facturacion__c, Provincia__c, Codigo_Postal__c
                                    from Account where Id = :datosCliente.identificador and (RecordTypeId = :Util.objectsRecordTypesMap.get('Account').get('Cliente').Id
                                                                                                            or RecordTypeId = :Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id)];
                    System.debug('listaCuentas: ' + listaCuentas);

                    if( listaCuentas == null || listaCuentas.isEmpty() )
                    {
                        System.debug('##No hay cuenta empresarial con esos datos');

                        //21/11/2016 Ruben
                        //Si no existe la cuenta, se comprueba si el id de la oportunidad de la peticion existe. Si es así, se obtiene la cuenta a la que pertenece la oportunidad
                        //y se crea tanto un contacto nuevo para la cuenta como una nueva funcion de contacto para la oportunidad
                        if( peticion.oportunidades != null && !peticion.oportunidades.isEmpty() )
                        {
                            Set<String> setIdsOportunidades = new Set<String>();
                            for(Oportunidad op : peticion.oportunidades)
                            {
                                if( WSDatosOfertas.comprobarIdOportunidadSF(op.identificador) )
                                {
                                    setIdsOportunidades.add(op.identificador);
                                }
                            }
                            List<Opportunity> listaOportunidades = new List<Opportunity>([SELECT Id, Opportunity.AccountId FROM Opportunity WHERE Id = : setIdsOportunidades]);
                            //
                            if( !listaOportunidades.isEmpty() )
                            {
                                System.debug('##Cojo la cuenta empresarial a la que pertenece la oportunidad');
                                Opportunity oportunidadObtenida = listaOportunidades.get(0);
                                Account cuentaAux = [select Id, Name, Id_fiscal__c, E_mail__c, ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Actividad__c, Sub_actividad__c,
                                                     Calle_Facturacion__c, Poblacion_Facturacion__c, Codigo_Postal__c, Provincia__c, RecordTypeId from Account where Id = :oportunidadObtenida.AccountId];
                                idCuenta = cuentaAux.Id;
                                listaContactos = [select Id, FirstName, LastName, Phone, MobilePhone, Fax, Email, LeadSource, DNI__c, AccountId
                                                  from Contact where FirstName = :datosCliente.nombre and Phone = :datosCliente.telefono and IsPersonAccount = false];
                                System.debug('listaContactos: ' + listaContactos);
                                if( listaContactos == null || listaContactos.isEmpty() )
                                {
                                    System.debug('##Nuevo contacto');

                                    // si no existe ningún contacto con ese nombre y teléfono, se inserta
                                    contacto = new Contact(FirstName = datosCliente.nombre,
                                                           LastName = datosCliente.apellidos,
                                                           Phone = datosCliente.telefono,
                                                           MobilePhone =datosCliente.telefonoMovil,
                                                           Fax = datosCliente.fax,
                                                           Email = datosCliente.email,
                                                           DNI__c = datosCliente.dni,
                                                           Permitir_duplicado__c = true,
                                                           AccountId = idCuenta);
                                    contacto.setOptions(dml);
                                    insert contacto;
                                    // si se ha tenido que crear el contacto, se tendrá que crear seguro la función de contacto en la oportunidad
                                    crearOpportunityContactRole = true;
                                }
                                else
                                {
                                    System.debug('##Existe el contacto');

                                    // si existe algún contacto con ese nombre y teléfono, se actualizan sus datos
                                    contacto = listaContactos.get(0);
                                    contacto.LastName = datosCliente.apellidos;
                                    contacto.MobilePhone = datosCliente.telefonoMovil;
                                    contacto.Fax = datosCliente.fax;
                                    contacto.Email = datosCliente.email;
                                    contacto.AccountId = idCuenta;
                                    contacto.DNI__c = datosCliente.dni;
                                    contacto.Permitir_duplicado__c = true;
                                    contacto.setOptions(dml);
                                    update contacto;
                                }
                            }
                            else
                            {    //21/11/2016 Ruben

                                // si no existe ninguna cuenta con ese nombre, y no existe la oportunidad se inserta
                                cuenta = new Account( Name = nombre,
                                                      Id_fiscal__c = datosCliente.cif,
                                                      E_mail__c = datosCliente.email,       //relleno este campo porque es el que se manda a Navision y tambien relleno el del contacto
                                                      ShippingStreet = datosCliente.calle,
                                                      ShippingPostalCode = datosCliente.cp,
                                                      ShippingState = datosCliente.provincia,
                                                      ShippingCity = datosCliente.poblacion,
                                                      Actividad__c = datosCliente.actividad,
                                                      Sub_actividad__c = datosCliente.subactividad,
                                                      Calle_Facturacion__c = datosCliente.calleFacturacion,
                                                      Poblacion_Facturacion__c = datosCliente.poblacionFacturacion,
                                                      Codigo_Postal__c = datosCliente.cpFacturacion,
                                                      Provincia__c = datosCliente.provinciaFacturacion,
                                                      RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Cliente').Id,
                                                      Permitir_duplicado__c = true,
                                                      Mobile_Phone_No__c = datosCliente.telefonoMovil,
                                                      Phone = datosCliente.telefono
                                                      );
                                cuenta.setOptions(dml);
                                AccountUtil.semaforoUpdate = false;
                                insert cuenta;
                                AccountUtil.semaforoUpdate = true;
                                idCuenta = cuenta.Id;



                                /* System.debug('##1 Actividad:'+ datosCliente.actividad);

                                   String eliminarCaracterMalo = '';
                                   if (datosCliente.actividad == 'Doméstico Unifamiliar')
                                   {
                                     System.debug('##1 Es domestico');

                                   }else{
                                     System.debug('##1 No es domestico');
                                     eliminarCaracterMalo = datosCliente.actividad.replaceAll(' ', ' ');
                                     if(eliminarCaracterMalo == 'Doméstico Unifamiliar')
                                     {
                                         System.debug('##1 Es domestico 2');
                                     }
                                   }*/

                                // crear la dirección de entrega
                                String checkDireccion = datosCliente.calle;
                                if(checkDireccion.length() > 50)
                                {
                                    List<String> listaStringsDirecciones = NavWSUtil.separarEnDosStrings(checkDireccion);

                                    direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = listaStringsDirecciones.get(0),
                                                                                   Direccion_2__c = listaStringsDirecciones.get(1), Poblacion__c = datosCliente.poblacion,
                                                                                   Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                                   Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                                }
                                else
                                {
                                    direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = datosCliente.calle, Poblacion__c = datosCliente.poblacion,
                                                                                   Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                                   Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                                }


                                /* direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = datosCliente.calle, Poblacion__c = datosCliente.poblacion,
                                                                                 Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                                 Actividad_1__c = eliminarCaracterMalo, Actividad_2__c = datosCliente.subactividad);*/

                                insert direccionEntrega;
                            }
                        }
                        else
                        {
                            // si no existe ninguna cuenta con ese nombre, se inserta
                            cuenta = new Account( Name = nombre,
                                                  Id_fiscal__c = datosCliente.cif,
                                                  E_mail__c = datosCliente.email,           //relleno este campo porque es el que se manda a Navision y tambien relleno el del contacto
                                                  ShippingStreet = datosCliente.calle,
                                                  ShippingPostalCode = datosCliente.cp,
                                                  ShippingState = datosCliente.provincia,
                                                  ShippingCity = datosCliente.poblacion,
                                                  Actividad__c = datosCliente.actividad,
                                                  Sub_actividad__c = datosCliente.subactividad,
                                                  Calle_Facturacion__c = datosCliente.calleFacturacion,
                                                  Poblacion_Facturacion__c = datosCliente.poblacionFacturacion,
                                                  Codigo_Postal__c = datosCliente.cpFacturacion,
                                                  Provincia__c = datosCliente.provinciaFacturacion,
                                                  RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Cliente').Id,
                                                  Permitir_duplicado__c = true,
                                                  Mobile_Phone_No__c = datosCliente.telefonoMovil,
                                                  Phone = datosCliente.telefono
                                                  );
                            cuenta.setOptions(dml);
                            AccountUtil.semaforoUpdate = false;
                            insert cuenta;
                            AccountUtil.semaforoUpdate = true;
                            idCuenta = cuenta.Id;



                            // crear la dirección de entrega
                            String checkDireccion = datosCliente.calle;
                            if(checkDireccion.length() > 50)
                            {
                                List<String> listaStringsDirecciones = NavWSUtil.separarEnDosStrings(checkDireccion);

                                direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = listaStringsDirecciones.get(0),
                                                                               Direccion_2__c = listaStringsDirecciones.get(1), Poblacion__c = datosCliente.poblacion,
                                                                               Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                               Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                            }
                            else
                            {
                                direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = datosCliente.calle, Poblacion__c = datosCliente.poblacion,
                                                                               Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                               Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                            }

                            insert direccionEntrega;
                        }
                    }
                    else
                    {
                        // si existe alguna cuenta con ese nombre, se actualizan sus datos
                        cuenta = listaCuentas.get(0);
                        cuenta.Id_fiscal__c = datosCliente.cif;
                        cuenta.E_mail__c = datosCliente.email;     //relleno este campo porque es el que se manda a Navision y tambien relleno el del contacto
                        cuenta.ShippingStreet = datosCliente.calle;
                        cuenta.ShippingPostalCode = datosCliente.cp;
                        cuenta.ShippingState = datosCliente.provincia;
                        cuenta.ShippingCity = datosCliente.poblacion;
                        cuenta.Actividad__c = datosCliente.actividad;
                        cuenta.Sub_actividad__c = datosCliente.subactividad;
                        cuenta.Calle_Facturacion__c = datosCliente.calleFacturacion;
                        cuenta.Poblacion_Facturacion__c = datosCliente.poblacionFacturacion;
                        cuenta.Codigo_Postal__c = datosCliente.cpFacturacion;
                        cuenta.Provincia__c = datosCliente.provinciaFacturacion;
                        cuenta.Permitir_duplicado__c = true;
                        cuenta.Mobile_Phone_No__c = datosCliente.telefonoMovil;
                        cuenta.Phone = datosCliente.telefono;
                        
                        cuenta.setOptions(dml);
                        AccountUtil.semaforoUpdate = false;
                        update cuenta;
                        AccountUtil.semaforoUpdate = true;
                        idCuenta = cuenta.Id;

                        // comprobar si existe dirección de entrega según el identificador recibido
                        listaDireccionesEntrega = [select Id, Direccion__c, Poblacion__c, Codigo_Postal__c, Provincia__c, Actividad_1__c, Actividad_2__c
                                                   from Direcci_n_de_entrega__c
                                                   where Cuenta__c =: cuenta.Id];
                        if( listaDireccionesEntrega == null || listaDireccionesEntrega.isEmpty() )
                        {     // no se han encontrado direcciones para esa cuenta
                            String checkDireccion = datosCliente.calle;
                            if(checkDireccion.length() > 50)
                            {
                                List<String> listaStringsDirecciones = NavWSUtil.separarEnDosStrings(checkDireccion);

                                direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = listaStringsDirecciones.get(0),
                                                                               Direccion_2__c = listaStringsDirecciones.get(1), Poblacion__c = datosCliente.poblacion,
                                                                               Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                               Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                            }
                            else
                            {
                                direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = datosCliente.calle, Poblacion__c = datosCliente.poblacion,
                                                                               Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                               Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                            }

                            insert direccionEntrega;
                        }
                        else
                        {
                            String checkDireccion = datosCliente.calle;
                            if(checkDireccion.length() > 50)
                            {
                                List<String> listaStringsDirecciones = NavWSUtil.separarEnDosStrings(checkDireccion);

                                dirAuxRecibida = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = listaStringsDirecciones.get(0),
                                                                             Direccion_2__c = listaStringsDirecciones.get(1), Poblacion__c = datosCliente.poblacion,
                                                                             Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                             Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                            }
                            else
                            {
                                dirAuxRecibida = new Direcci_n_de_entrega__c(Direccion__c = datosCliente.calle, Poblacion__c = datosCliente.poblacion,
                                                                             Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                             Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                            }
                            direccionEntrega = null;
                            for(Direcci_n_de_entrega__c dir : listaDireccionesEntrega)
                            {
                                direccionEntrega = WSDatosOfertas.gestionarDirecciones(dir, dirAuxRecibida);
                                if(direccionEntrega != null)
                                {
                                    direccionEntrega.cuenta__c = cuenta.Id;
                                    direccionEntrega.Id = dir.Id;
                                    update direccionEntrega;
                                    break;
                                }
                            }

                            // si después del for, direccionEntrega sigue siendo null es que no se ha encontrado ninguna que coincida y habrá que insertarla
                            if(direccionEntrega == null)
                            {
                                if(checkDireccion.length() > 50)
                                {
                                    List<String> listaStringsDirecciones = NavWSUtil.separarEnDosStrings(checkDireccion);

                                    direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = listaStringsDirecciones.get(0),
                                                                                   Direccion_2__c = listaStringsDirecciones.get(1), Poblacion__c = datosCliente.poblacion,
                                                                                   Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                                   Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                                }
                                else
                                {
                                    direccionEntrega = new Direcci_n_de_entrega__c(cuenta__c = cuenta.Id, Direccion__c = datosCliente.calle, Poblacion__c = datosCliente.poblacion,
                                                                                   Codigo_Postal__c = datosCliente.cp, Provincia__c = datosCliente.provincia,
                                                                                   Actividad_1__c = datosCliente.actividad, Actividad_2__c = datosCliente.subactividad);
                                }
                                System.debug('##3 Cliente empresarial: Nueva direccion de entrega creada en WSDatosOferta');
                                insert direccionEntrega;
                            }
                        }
                    }

                    listaContactos = [select Id, FirstName, LastName, Phone, MobilePhone, Fax, Email, LeadSource, DNI__c, AccountId
                                      from Contact where FirstName = :datosCliente.nombre and Phone = :datosCliente.telefono and IsPersonAccount = false];

                    if( listaContactos == null || listaContactos.isEmpty() )
                    {
                        // si no existe ningún contacto con esos nombre y teléfono, se inserta
                        contacto = new Contact(FirstName = datosCliente.nombre,
                                               LastName = datosCliente.apellidos,
                                               Phone = datosCliente.telefono,
                                               MobilePhone =datosCliente.telefonoMovil,
                                               Fax = datosCliente.fax,
                                               Email = datosCliente.email,
                                               DNI__c = datosCliente.dni,
                                               Permitir_duplicado__c = true,
                                               AccountId = idCuenta);
                        contacto.setOptions(dml);
                        insert contacto;
                        // si se ha tenido que crear el contacto, se tendrá que crear seguro la función de contacto en la oportunidad
                        crearOpportunityContactRole = true;
                    }
                    else
                    {
                        // si existe algún contacto con esos nombre y teléfono, se actualizan sus datos
                        contacto = listaContactos.get(0);
                        contacto.LastName = datosCliente.apellidos;
                        contacto.MobilePhone = datosCliente.telefonoMovil;
                        contacto.Fax = datosCliente.fax;
                        contacto.Email = datosCliente.email;
                        contacto.AccountId = idCuenta;
                        contacto.DNI__c = datosCliente.dni;
                        contacto.Permitir_duplicado__c = true;
                        contacto.setOptions(dml);
                        update contacto;
                    }



                }
                System.debug('peticion.oportunidades: ' + peticion.oportunidades);

                //SI HAY OPORTUNIDADES
                if(peticion.oportunidades != null)
                {
                    listOpportunities = new List<Opportunity>();
                    //listOpportunityContactRoles = new List<OpportunityContactRole>();
                    mapOpportunityContactRoles = new Map<String, OpportunityContactRole>();
                    listPartners = new List<Partner>();
                    listPartnersDelete = new List<Partner>();
                    listQuotes = new List<Quote>();
                    mapEmailQuotes = new Map<String,List<Quote>>();
                    listEquiposActuales = new List<Equipo_actual__c>();
                    listEnergiasActuales = new List<Energia_Actual__c>();
                    listTramos = new List<Tramo__c>();
                    listPacks = new List<Pack_de_servicio__c>();
                    listDepositos = new List<Deposito__c>();
                    listEquiposAjuste = new List<Equipo_Ajuste__c>();
                    setIdsNewSales = new Set<String>();
                    mapPacksServiciosDeOferta = new Map<String, Pack_de_servicio__c>();
                    mapServiciosDeOferta = new Map<String, List<Servicio__c> >();

                    //
                    Set<String> setIdsOportunidades = new Set<String>();
                    for(Oportunidad op : peticion.oportunidades)
                    {
                        if( WSDatosOfertas.comprobarIdOportunidadSF(op.identificador) )
                        {
                            setIdsOportunidades.add(op.identificador);
                        }
                    }
                    Map<String,Opportunity> mapaOportunidades = new Map<String,Opportunity>([SELECT Id, LeadSource FROM Opportunity WHERE Id = : setIdsOportunidades]);

                    listaOportunidadesUpdate = new List<Opportunity>();
                    Opportunity oportunidadUpdateAux = new Opportunity();
                    //
                    
                    //POR CADA OPORTUNIDAD SE MIRA SI SU ID ES DE SALESFORCE
                    for(Oportunidad op : peticion.oportunidades)
                    {
                        // comprobar si el id de la oportunidad es de SF o no         
                        //TRUE SI IDENTIFICADOR LENGTH = 18 Y EMPIEZA POR 006                   
                        if( WSDatosOfertas.comprobarIdOportunidadSF(op.identificador) )
                        {     // el identificador de la oportunidad es de SF

                            // Si la oportunidad ya existía y el canal de ventas ha cambiado, lo actualizo
                            if( !mapaOportunidades.isEmpty() && mapaOportunidades.containsKey(op.identificador) )
                            {
                                if(String.isBlank(mapaOportunidades.get(op.identificador).LeadSource) && mapaOportunidades.get(op.identificador).LeadSource != op.canal && op.canal != '')
                                {
                                    oportunidadUpdateAux.Id = mapaOportunidades.get(op.identificador).Id;
                                    oportunidadUpdateAux.LeadSource = op.canal;
                                    listaOportunidadesUpdate.add(oportunidadUpdateAux);
                                }
                                //Habría que mirar para actualiar la oportunidad (los campos de actividad y subactividad)
                            }

                            // comprobar si es necesario crear la función de contacto para la oportunidad, o lo que es lo mismo, si se ha insertado el contacto como nuevo
                            if(crearOpportunityContactRole)
                            {
                                String idContacto = String.valueOf(contacto.Id).substring(0,15);
                                String clave = idContacto + 'Firmante de contrato';
                                //listOpportunityContactRoles.add(new OpportunityContactRole(ContactId = contacto.Id, OpportunityId = Id.valueOf(op.identificador), Role='Firmante de contrato'));
                                mapOpportunityContactRoles.put( clave,new OpportunityContactRole(ContactId = contacto.Id, OpportunityId = Id.valueOf(op.identificador), Role='Firmante de contrato') );
                            }
                            // Si se ha recibido el id de prescriptor, crear si es necesario OpportuniyPartner entre éste y la oportunidad recibida
                            if( String.isBlank(op.prescriptor) )
                                idPrescriptor = null;
                            else
                                idPrescriptor = Id.valueOf(op.prescriptor);
                            if( idPrescriptor != null )
                            {
                                // comprobar si ya existe OpportunityPartner entre la oportunidad y el prescriptor de la cuenta
                                listOpportunityPartner = [select Id from OpportunityPartner where AccountToId = :idPrescriptor and OpportunityId = :op.identificador];
                                if( listOpportunityPartner == null || listOpportunityPartner.isEmpty() )
                                {    // si no se ha encontrado OpportunityPartner, crear Partner y borrar los anteriores
                                    listOpportunityPartnerDelete = [select Id, AccountToId, OpportunityId from OpportunityPartner where OpportunityId = :op.identificador
                                                                                                                                                        /*and (Role =:'Comercial' or Role =:'Instalador' or Role =:'Ingeniería')*/];
                                    if( listOpportunityPartnerDelete != null && !listOpportunityPartnerDelete.isEmpty() )
                                    {
                                        for(OpportunityPartner opPartner: listOpportunityPartnerDelete)
                                        {
                                            listPartnersDelete.add( new Partner(Id=opPartner.Id, AccountToId=opPartner.AccountToId, OpportunityId=op.identificador) );
                                        }
                                    }
                                    listPartners.add( new Partner(AccountToId=idPrescriptor, Opportunityid=op.identificador) );
                                }
                                else
                                {    //si se ha encontrado OpportunityPartner, comprobar si existen más y borrar los anteriores
                                    listOpportunityPartnerDelete = [select Id, AccountToId, OpportunityId from OpportunityPartner where AccountToId != :idPrescriptor and OpportunityId = :op.identificador
                                                                                                                                                                                          /*and (Role =:'Comercial' or Role =:'Instalador' or Role =:'Ingeniería')*/];
                                    if( listOpportunityPartnerDelete != null && !listOpportunityPartnerDelete.isEmpty() )
                                    {
                                        for(OpportunityPartner opPartner: listOpportunityPartnerDelete)
                                        {
                                            listPartnersDelete.add( new Partner(Id=opPartner.Id, AccountToId=opPartner.AccountToId, OpportunityId=op.identificador) );
                                        }
                                    }
                                }

                            }
                            //SI LA OPP ES DE SALESFORCE Y TIENE OFERTAS, SE ENVIAN POR EMAIL
                            if(op.ofertas != null)
                            {
                                listIdsQuotes = new List<String>();
                                emailsDestinatarios = new List<String>();
                                for(EntidadesWSClientesYOfertas.Oferta oferta : op.ofertas)
                                {
                                    if( oferta != null && !String.isBlank(oferta.identificador) )
                                    {

                                        identificadorOfertaExistente = oferta.identificador;

                                        //TRUE SI IDENTIFICADOR LENGTH != 18 O NO EMPIEZA POR 0Q0 
                                        if( !WSDatosOfertas.comprobarIdQuoteSF(oferta.identificador) )     // si la oferta no existe, se crea
                                        {
                                            setIdsNewSales.add(oferta.identificador);

                                            // crear quote
                                            Quote qAux = WSDatosOfertas.crearQuoteConOferta(oferta, Id.valueOf(op.identificador), null, idPrescriptor, datosCliente.provincia);
                                            listQuotes.add(qAux);
                                            if(!mapEmailQuotes.containsKey(oferta.emailDestinatario + ';' + oferta.enviarEmail))
                                            {
                                                mapEmailQuotes.put( + ';' + oferta.enviarEmail, new List<Quote>());
                                            }
                                            mapEmailQuotes.get( + ';' + oferta.enviarEmail).add(qAux);
                                            // crear las entidades asociadas a la oferta
                                            // se crear una Quote con el identificador externo, para poder asociarla a sus entidades asociadas
                                            quoteNS = new Quote(IdNewSales__c = oferta.identificador);


                                            if(oferta.instalacion != null)
                                            {
                                                // Equipos
                                                if(oferta.instalacion.equipos != null)
                                                {
                                                    for(EntidadesWSClientesYOfertas.Equipo equipo : oferta.instalacion.equipos)
                                                    {
                                                        listEquiposActuales.add( WSDatosOfertas.crearEquipoActualConEquipo(equipo, quoteNS) );
                                                    }
                                                }
                                                // Energías
                                                if(oferta.instalacion.energias != null)
                                                {
                                                    for(EntidadesWSClientesYOfertas.Energia energia : oferta.instalacion.energias)
                                                    {
                                                        if( energia != null)
                                                        {
                                                            listEnergiasActuales.add( WSDatosOfertas.crearEnergiaActualConEnergia(energia, quoteNS) );
                                                        }
                                                    }
                                                }
                                            }
                                            if(oferta.estandar != null )     // es oferta estandar
                                            {
                                                //Creo depósito
                                                if(oferta.estandar.idSalesforce != null && oferta.estandar.idSalesforce != '')
                                                {
                                                    //gserrano 10/12/2018
                                                    /*List<OpcionesOfertaSTD__c> listaOfertasEstandarMaestras = OpcionesOfertaSTD__c.getAll().values();
                                                    if(listaOfertasEstandarMaestras!=null && listaOfertasEstandarMaestras.size()>0)
                                                    {
                                                        OpcionesOfertaSTD__c ofertaEstandarMaestra = null;
                                                        for(OpcionesOfertaSTD__c oe: listaOfertasEstandarMaestras)
                                                        {
                                                            if(oe.Name==oferta.estandar.idSalesforce)
                                                            {
                                                                ofertaEstandarMaestra = oe;
                                                            }
                                                        }*/
                                                        OpcionesOfertaSTD__c ofertaEstandarMaestra = ofertasStdMap.get(oferta.estandar.idSalesforce);
                                                        if(ofertaEstandarMaestra!=null)
                                                        {
                                                            List<DepositosMaestros__c> listaDepositosMaestros = DepositosMaestros__c.getAll().values();
                                                            if(listaDepositosMaestros!=null && listaDepositosMaestros.size()>0)
                                                            {
                                                                DepositosMaestros__c depositoMaestro = null;
                                                                for(DepositosMaestros__c d: listaDepositosMaestros)
                                                                {
                                                                    if(d.Deposito__c==ofertaEstandarMaestra.Deposito__c)
                                                                    {
                                                                        depositoMaestro = d;
                                                                    }
                                                                }
                                                                if(depositoMaestro!=null)
                                                                {
                                                                    EntidadesWSClientesYOfertas.Deposito deposito = new EntidadesWSClientesYOfertas.Deposito();
                                                                    deposito.tipo = depositoMaestro.Deposito__c;
                                                                    deposito.cantidad = '1';
                                                                    deposito.equiposExterior = String.valueOf(depositoMaestro.D__c);
                                                                    deposito.instalacionExterior = String.valueOf(depositoMaestro.Instalacion_exterior__c);
                                                                    deposito.proyectos = String.valueOf(depositoMaestro.Proyecto__c);
                                                                    deposito.obraCivilVallado = String.valueOf(depositoMaestro.Obra_civil__c + depositoMaestro.Vallado__c);
                                                                    //Total_inversion__c = depositoMaestro.InversionSinDeposito__c;
                                                                    listDepositos.add(WSDatosOfertas.crearDepositoSFConDepositoNS(deposito, quoteNS, datosCliente.provincia));
                                                                }
                                                            }
                                                        }
                                                    }                                              
                                                //}
                                            }
                                            if(oferta.modular != null )     // es oferta modular
                                            {
                                                //Creo depósito
                                                if(oferta.modular.instalacion != null && oferta.modular.instalacion.deposito != null && oferta.modular.instalacion.deposito != '')
                                                {
                                                    List<DepositosMaestros__c> listaDepositosMaestros = DepositosMaestros__c.getAll().values();
                                                    if(listaDepositosMaestros != null && listaDepositosMaestros.size() > 0)
                                                    {
                                                        DepositosMaestros__c depositoMaestro = null;
                                                        for(DepositosMaestros__c d: listaDepositosMaestros)
                                                        {
                                                            if(d.Deposito__c == oferta.modular.instalacion.deposito)
                                                            {
                                                                depositoMaestro = d;
                                                            }
                                                        }
                                                        if(depositoMaestro != null)
                                                        {
                                                            EntidadesWSClientesYOfertas.Deposito deposito = new EntidadesWSClientesYOfertas.Deposito();
                                                            deposito.tipo = depositoMaestro.Deposito__c;
                                                            deposito.cantidad = '1';

                                                            List<CostesLegalizacionProvincia__c> listaCostesLegalProvinciaMaestros = CostesLegalizacionProvincia__c.getAll().values();
                                                            if(listaCostesLegalProvinciaMaestros != null && listaCostesLegalProvinciaMaestros.size() > 0)
                                                            {
                                                                CostesLegalizacionProvincia__c costeLegalProvinciaMaestro = null;
                                                                for(CostesLegalizacionProvincia__c clp: listaCostesLegalProvinciaMaestros)
                                                                {
                                                                    if( clp.Deposito__c == depositoMaestro.Deposito__c && clp.Provincia__c.toUpperCase() == datosCliente.provincia.toUpperCase() )
                                                                    {
                                                                        costeLegalProvinciaMaestro = clp;
                                                                        break;
                                                                    }
                                                                }
                                                                if(costeLegalProvinciaMaestro != null)
                                                                {
                                                                    deposito.equiposExterior = String.valueOf(depositoMaestro.D__c + costeLegalProvinciaMaestro.Coste__c);
                                                                }
                                                            }

                                                            deposito.instalacionExterior = oferta.modular.instalacion.costeExterior;    //String.valueOf(depositoMaestro.Instalacion_exterior__c);
                                                            deposito.proyectos = oferta.modular.instalacion.costeProyectos;    //String.valueOf(depositoMaestro.Proyecto__c);
                                                            deposito.obraCivilVallado = String.valueOf( Decimal.valueOf(oferta.modular.instalacion.costeObraCivil) + Decimal.valueOf(oferta.modular.instalacion.costeVallado) );    //String.valueOf(depositoMaestro.Obra_civil__c + depositoMaestro.Vallado__c);
                                                            listDepositos.add( WSDatosOfertas.crearDepositoSFConDepositoNS(deposito, quoteNS, datosCliente.provincia) );
                                                        }
                                                    }
                                                }
                                                // Tramos
                                                String pba = '';
                                                //gserrano 12/12/2018
                                            	String clv5 = '';
                                            	String clv10 = '';
                                                List <String> gps = new List<String>();
                        	
                                                if(oferta.tipo == 'modular')
                                                {
                                                    if(String.isNotBlank(oferta.modular.producto.nivelPB))
                                                    {
                                                        pba = oferta.modular.producto.nivelPB;
                                                    }
                                                    if(String.isNotBlank(oferta.modular.producto.clv5))
                                                    {
                                                        clv5 = oferta.modular.producto.clv5;
                                                    }
                                                    if(String.isNotBlank(oferta.modular.producto.clv10))
                                                    {
                                                        clv10 = oferta.modular.producto.clv10;
                                                    }
                                                    if(String.isNotBlank(oferta.modular.producto.gp))
                                                    {
                                                        System.debug('*** size gp:' + oferta.modular.producto.gp);

                                                        gps = oferta.modular.producto.gp.split('-');

                                                        for(Integer i = 0; i < gps.size(); i++)
                                                        {
                                                            System.debug('*** gp:' + gps[i]);
                                                        }
                                                    }
                                                }
                                                
                                                //gserrano 12/12/2018 añadida comprobacion de longitud gps = tramos.size
                                           		if(oferta.modular.instalacion != null && (listaTramosNS = oferta.modular.instalacion.tramos) != null && oferta.modular.instalacion.tramos.size() == gps.size())
                                                //if(oferta.modular.instalacion != null && (listaTramosNS = oferta.modular.instalacion.tramos) != null)
                                                {
                                                    //for(EntidadesWSClientesYOfertas.Tramo tramo : listaTramosNS)
                                                    for(Integer i = 0; i < listaTramosNS.size(); i++)
                                                    {
                                                        if(listaTramosNS[i] != null)
                                                        {
                                                            //listTramos.add(WSDatosOfertas.crearTramoSFConTramoNS(listaTramosNS[i], quoteNS, pba));
                                                            if(listaTramosNS.size() == gps.size())
                                                            {
                                                                listTramos.add(WSDatosOfertas.crearTramoSFConTramoNS(listaTramosNS[i], quoteNS, pba, clv5, clv10, gps[i]));
                                                            }
                                                            else
                                                            {
                                                                listTramos.add(WSDatosOfertas.crearTramoSFConTramoNS(listaTramosNS[i], quoteNS, pba, clv5, clv10, null));
                                                            }
                                                        }
                                                    }
                                                }
                                                // Equipos de ajuste Cambios rfernandez (21/03/2017)
                                                if(oferta.tipo == 'modular')
                                                {
                                                    if( (equiposAjustesInstalarNS = oferta.equiposInstalarPrimagas) != null )
                                                    {

                                                        if(equiposAjustesInstalarNS != null)
                                                        {
                                                            listEquiposAjuste = WSDatosOfertas.crearEquipoAjusteInstalarSFConEquipoAjusteNS(equiposAjustesInstalarNS, quoteNS);
                                                        }

                                                    }
                                                }
                                                // Pack y servicios de pack
                                                if(oferta.modular.pack != null)
                                                {
                                                    packServicio = WSDatosOfertas.crearPackServicioSFConPackNS(oferta.modular.pack, quoteNS);
                                                    listPacks.add(packServicio);
                                                    if( !mapPacksServiciosDeOferta.containsKey(oferta.identificador) )
                                                    {
                                                        mapPacksServiciosDeOferta.put(oferta.identificador, packServicio);
                                                    }
                                                    if( !mapServiciosDeOferta.containsKey(oferta.identificador) )
                                                    {
                                                        mapServiciosDeOferta.put( oferta.identificador, WSDatosOfertas.crearServiciosDePackConServiciosSeleccionadosNS(packServicio.Numero_de_pack__c, oferta.modular.pack.serviciosSeleccionados) );
                                                    }

                                                }
                                            }
                                            if(oferta.personalizada != null)     // es oferta personalizada
                                            {
                                                // Depósitos
                                                if( (listaDepositosNS = oferta.personalizada.depositos) != null )
                                                {
                                                    for(EntidadesWSClientesYOfertas.Deposito deposito : listaDepositosNS)
                                                    {
                                                        if(deposito != null)
                                                        {
                                                            listDepositos.add( WSDatosOfertas.crearDepositoSFConDepositoNS(deposito, quoteNS, datosCliente.provincia) );
                                                        }
                                                    }
                                                }
                                                // Equipos de ajuste
                                                if( (listaEquiposAjustesNS = oferta.personalizada.equiposAjuste) != null )
                                                {
                                                    for(EntidadesWSClientesYOfertas.EquipoAjuste equipoAj : listaEquiposAjustesNS)
                                                    {
                                                        if(equipoAj != null)
                                                        {
                                                            listEquiposAjuste.add( WSDatosOfertas.crearEquipoAjusteSFConEquipoAjusteNS(equipoAj, quoteNS) );
                                                        }
                                                    }
                                                }
                                                // Tramos de escalado
                                                if( (listaEscaladoNS = oferta.personalizada.escalado) != null )
                                                {
                                                    mapaQuoteIdTramo = new Map<String,Tramo__c>();
                                                    for(EntidadesWSClientesYOfertas.Escalado tramo : listaEscaladoNS)
                                                    {
                                                        if(tramo != null)
                                                        {
                                                            tramoEscaladoAux = WSDatosOfertas.crearTramoSFConEscaladoNS(tramo, quoteNS);
                                                            listTramos.add(tramoEscaladoAux);
                                                            if(String.isNotBlank(oferta.aplicarTramoEscalado) && oferta.aplicarTramoEscalado == tramo.idSalesforce)
                                                            {
                                                                mapaQuoteIdTramo.put(quoteNS.IdNewSales__c,tramoEscaladoAux);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else     // si la oferta sí existe, solamente se comprueba si hay que enviar el email al cliente
                                        {
                                            //Se añade el ID de cada oferta a la lista y solo se envian por email, sin generar PDF
                                            //AQUI HAY Q RECOGER LOS EMAILS
                                            listIdsQuotes.add(oferta.identificador);
                                            comprobarEnvioEmail = true;
                                        }

                                        System.debug('***' + listIdsQuotes);
                                        System.debug('*** size' + listIdsQuotes.size());
                                        System.debug('*** emailDest' + oferta.emailDestinatario);

                                        //SI LA OPORTNIDAD ERA DE SALESFORCE Y TENIE EMAILDESTINATARIO, SE ENVIA SIEMPRE A SALESFORCE
                                        if(listIdsQuotes!=null && listIdsQuotes.size()>0 && String.isNotBlank(oferta.emailDestinatario))
                                        {
                                            //generar PDF y enviar email (YA NO)
                                            //Cambio gserrano 12/12/2018 (SOLO SE ENVIA POR EMAIL; NO GENERA PDF)
                                            System.debug('Estoy AQUIIIIIIIIIII '+oferta.emailDestinatario);
                                            WSDatosOfertas.generarPDFOferta(listIdsQuotes, contacto.Id, false, true, oferta.emailDestinatario);
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {     //  oportunidad sin identificador de SF --> nueva oportunidad
                            if( String.isBlank(op.nombre) )
                            {
                                nameOpp = datosCliente.nombre + DateTime.now().format('yyyy-MM-dd hh:mm:ss');
                            }
                            else
                            {
                                nameOpp = op.nombre;
                            }
                                
                            //Cambios rfernandez(24/01/2017) Se añade la actividad y subactividad a la oportunidad
                            listOpportunities.add( new Opportunity( AccountId = idCuenta,
                                                                    IdNewSales__c = op.identificador,
                                                                    StageName = 'Identificada',
                                                                    Name = nameOpp,
                                                                    CloseDate = Date.today().addMonths(1),
                                                                    Fecha_validez__c = Date.today().addMonths(1),
                                                                    LeadSource = op.canal,
                                                                    Actividad__c = datosCliente.actividad,
                                                                    Sub_actividad__c = datosCliente.subactividad,
                                                                    Producto__c = productosCreadosMap.get('GLP') ) );

                            // se crear una oportunidad a partir del identificador externo, para poder asociarlo a sus quotes asociadas, así como funciones de contacto y de socio
                            oppAux = new Opportunity(IdNewSales__c = op.identificador);

                            // en este caso, como la oportunidad es nueva, será siempre necesario crear una función de contacto para el contacto indicado
                            //listOpportunityContactRoles.add(new OpportunityContactRole(ContactId = contacto.Id, Opportunity = oppAux, Role='Firmante de contrato'));
                            String idContacto = String.valueOf(contacto.Id).substring(0,15);
                            String clave = idContacto + 'Firmante de contrato';
                            mapOpportunityContactRoles.put( clave,new OpportunityContactRole(ContactId = contacto.Id, Opportunity = oppAux, Role='Firmante de contrato') );

                            // Si se ha recibido el id de prescriptor, crear si es necesario OpportuniyPartner entre éste y la oportunidad recibida
                            if( String.isBlank(op.prescriptor) )
                                idPrescriptor = null;
                            else
                                idPrescriptor = Id.valueOf(op.prescriptor);
                            if( idPrescriptor != null )
                            {
                                // comprobar si ya existe OpportunityPartner entre la oportunidad y el prescriptor de la cuenta
                                listOpportunityPartner = [select Id from OpportunityPartner where AccountToId = :idPrescriptor and Opportunity.IdNewSales__c = :op.identificador];
                                if( listOpportunityPartner == null || listOpportunityPartner.isEmpty() )
                                {    // si no se han encontrado OpportunityPartner, crear Partner
                                    listPartners.add( new Partner(AccountToId=idPrescriptor, Opportunity=oppAux) );
                                }
                            }

                            if( String.isBlank(op.fechaCreacion) )
                            {
                                fechaCreacionOportunidad = null;
                            }
                            else
                            {
                                anyo = Integer.valueOf( op.fechaCreacion.substring(0,4) );
                                mes = Integer.valueOf( op.fechaCreacion.substring(5,7) );
                                dia = Integer.valueOf( op.fechaCreacion.substring(8,10) );
                                hora = Integer.valueOf( op.fechaCreacion.substring(11,13) );
                                minuto = Integer.valueOf( op.fechaCreacion.substring(14,16) );
                                segundo = Integer.valueOf( op.fechaCreacion.substring(17,19) );

                                fechaCreacionOportunidad = DateTime.newInstance(anyo, mes, dia, hora, minuto, segundo);
                            }
                            if(op.ofertas != null)
                            {
                                for(EntidadesWSClientesYOfertas.Oferta oferta : op.ofertas)
                                {
                                    if( oferta != null && !String.isBlank(oferta.identificador) )
                                    {
                                        //Obtengo fechaCreacionOportunidad
                                        /*if(fechaCreacionOportunidad == null)
                                           {
                                            if(oferta.fechaCreacion != null && oferta.fechaCreacion.length() >= 8)
                                            {
                                                anyo = Integer.valueOf(oferta.fechaCreacion.substring(0,4));
                                                mes = Integer.valueOf(oferta.fechaCreacion.substring(4,6));
                                                dia = Integer.valueOf(oferta.fechaCreacion.substring(6,8));
                                                fechaCreacionOportunidad = Datetime.newInstance(anyo, mes, dia);
                                                fechaCreacionOportunidadAux = oferta.fechaCreacion;
                                            }
                                           }
                                           else
                                           {
                                            if(oferta.fechaCreacion != null && oferta.fechaCreacion.length() >= 8 && Integer.valueOf(oferta.fechaCreacion)<Integer.valueOf(fechaCreacionOportunidadAux))
                                            {
                                                anyo = Integer.valueOf(oferta.fechaCreacion.substring(0,4));
                                                mes = Integer.valueOf(oferta.fechaCreacion.substring(4,6));
                                                dia = Integer.valueOf(oferta.fechaCreacion.substring(6,8));
                                                fechaCreacionOportunidad = Datetime.newInstance(anyo, mes, dia);
                                                fechaCreacionOportunidadAux = oferta.fechaCreacion;
                                            }
                                           }*/

                                        setIdsNewSales.add(oferta.identificador);

                                        // crear quote
                                        // crear las entidades asociadas a la oferta
                                        Quote qAux = WSDatosOfertas.crearQuoteConOferta(oferta, null, op.identificador, idPrescriptor, datosCliente.provincia);
                                        listQuotes.add(qAux);
                                        if(!mapEmailQuotes.containsKey(oferta.emailDestinatario + ';' + oferta.enviarEmail))
                                        {
                                            mapEmailQuotes.put(oferta.emailDestinatario + ';' + oferta.enviarEmail, new List<Quote>());
                                        }
                                        mapEmailQuotes.get(oferta.emailDestinatario + ';' + oferta.enviarEmail).add(qAux);
                                        // 
                                        quoteNS = new Quote(IdNewSales__c = oferta.identificador);
                                        if(oferta.instalacion != null)
                                        {
                                            if(oferta.instalacion.equipos != null)
                                            {
                                                for(EntidadesWSClientesYOfertas.Equipo equipo : oferta.instalacion.equipos)
                                                {
                                                    listEquiposActuales.add( WSDatosOfertas.crearEquipoActualConEquipo(equipo, quoteNS) );
                                                }
                                            }
                                            if(oferta.instalacion.energias != null)
                                            {
                                                for(EntidadesWSClientesYOfertas.Energia energia : oferta.instalacion.energias)
                                                {
                                                    if( energia != null)
                                                    {
                                                        listEnergiasActuales.add( WSDatosOfertas.crearEnergiaActualConEnergia(energia, quoteNS) );
                                                    }
                                                }
                                            }
                                        }
                                        if(oferta.estandar != null )     // es oferta estandar
                                        {
                                            //Creo depósito
                                            if(oferta.estandar.idSalesforce != null && oferta.estandar.idSalesforce != '')
                                            {           
                                                //gserrano 10/12/2018
                                                /*List<OpcionesOfertaSTD__c> listaOfertasEstandarMaestras = OpcionesOfertaSTD__c.getAll().values();
                                                if(listaOfertasEstandarMaestras!=null && listaOfertasEstandarMaestras.size()>0)
                                                {
                                                    OpcionesOfertaSTD__c ofertaEstandarMaestra = null;
                                                    for(OpcionesOfertaSTD__c oe: listaOfertasEstandarMaestras)
                                                    {
                                                        if(oe.Name==oferta.estandar.idSalesforce)
                                                        {
                                                            ofertaEstandarMaestra = oe;
                                                        }
                                                    }*/
                                                	OpcionesOfertaSTD__c ofertaEstandarMaestra = ofertasStdMap.get(oferta.estandar.idSalesforce);
                                                    if(ofertaEstandarMaestra!=null)
                                                    {
                                                        List<DepositosMaestros__c> listaDepositosMaestros = DepositosMaestros__c.getAll().values();
                                                        if(listaDepositosMaestros!=null && listaDepositosMaestros.size()>0)
                                                        {
                                                            DepositosMaestros__c depositoMaestro = null;
                                                            for(DepositosMaestros__c d: listaDepositosMaestros)
                                                            {
                                                                if(d.Deposito__c==ofertaEstandarMaestra.Deposito__c)
                                                                {
                                                                    depositoMaestro = d;
                                                                }
                                                            }
                                                            if(depositoMaestro!=null)
                                                            {
                                                                EntidadesWSClientesYOfertas.Deposito deposito = new EntidadesWSClientesYOfertas.Deposito();
                                                                deposito.tipo = depositoMaestro.Deposito__c;
                                                                deposito.cantidad = '1';
                                                                deposito.equiposExterior = String.valueOf(depositoMaestro.D__c);
                                                                deposito.instalacionExterior = String.valueOf(depositoMaestro.Instalacion_exterior__c);
                                                                deposito.proyectos = String.valueOf(depositoMaestro.Proyecto__c);
                                                                deposito.obraCivilVallado = String.valueOf(depositoMaestro.Obra_civil__c + depositoMaestro.Vallado__c);
                                                                listDepositos.add(WSDatosOfertas.crearDepositoSFConDepositoNS(deposito, quoteNS, datosCliente.provincia));
                                                            }
                                                        }
                                                    }
                                                //}                                              
                                            }
                                        }
                                        if(oferta.modular != null )     // es oferta modular
                                        {
                                            //Creo depósito
                                            if(oferta.modular.instalacion != null && oferta.modular.instalacion.deposito != null && oferta.modular.instalacion.deposito != '')
                                            {
                                                List<DepositosMaestros__c> listaDepositosMaestros = DepositosMaestros__c.getAll().values();
                                                if(listaDepositosMaestros != null && listaDepositosMaestros.size() > 0)
                                                {
                                                    DepositosMaestros__c depositoMaestro = null;
                                                    for(DepositosMaestros__c d: listaDepositosMaestros)
                                                    {
                                                        if(d.Deposito__c == oferta.modular.instalacion.deposito)
                                                        {
                                                            depositoMaestro = d;
                                                        }
                                                    }
                                                    if(depositoMaestro != null)
                                                    {
                                                        EntidadesWSClientesYOfertas.Deposito deposito = new EntidadesWSClientesYOfertas.Deposito();
                                                        deposito.tipo = depositoMaestro.Deposito__c;
                                                        deposito.cantidad = '1';

                                                        List<CostesLegalizacionProvincia__c> listaCostesLegalProvinciaMaestros = CostesLegalizacionProvincia__c.getAll().values();
                                                        if(listaCostesLegalProvinciaMaestros != null && listaCostesLegalProvinciaMaestros.size() > 0)
                                                        {
                                                            CostesLegalizacionProvincia__c costeLegalProvinciaMaestro = null;
                                                            for(CostesLegalizacionProvincia__c clp: listaCostesLegalProvinciaMaestros)
                                                            {
                                                                if( clp.Deposito__c == depositoMaestro.Deposito__c && clp.Provincia__c.toUpperCase() == datosCliente.provincia.toUpperCase() )
                                                                {
                                                                    costeLegalProvinciaMaestro = clp;
                                                                    break;
                                                                }
                                                            }
                                                            if(costeLegalProvinciaMaestro != null)
                                                            {
                                                                deposito.equiposExterior = String.valueOf(depositoMaestro.D__c + costeLegalProvinciaMaestro.Coste__c);
                                                            }
                                                        }

                                                        deposito.instalacionExterior = oferta.modular.instalacion.costeExterior;    //String.valueOf(depositoMaestro.Instalacion_exterior__c);
                                                        deposito.proyectos = oferta.modular.instalacion.costeProyectos;    //String.valueOf(depositoMaestro.Proyecto__c);
                                                        deposito.obraCivilVallado = String.valueOf( Decimal.valueOf(oferta.modular.instalacion.costeObraCivil) + Decimal.valueOf(oferta.modular.instalacion.costeVallado) );    //String.valueOf(depositoMaestro.Obra_civil__c + depositoMaestro.Vallado__c);
                                                        listDepositos.add( WSDatosOfertas.crearDepositoSFConDepositoNS(deposito, quoteNS, datosCliente.provincia) );
                                                    }
                                                }
                                            }
                                            // Equipos de ajuste Cambios rfernandez (21/03/2017)
                                            if( (equiposAjustesInstalarNS = oferta.equiposInstalarPrimagas) != null )
                                            {

                                                if(equiposAjustesInstalarNS != null)
                                                {
                                                    System.debug(Logginglevel.ERROR,'###listEquiposAjuste3 Modular');
                                                    listEquiposAjuste = WSDatosOfertas.crearEquipoAjusteInstalarSFConEquipoAjusteNS(equiposAjustesInstalarNS, quoteNS);
                                                }

                                            }

                                            String pba = '';
                                            
                                            //gserrano 12/12/2018
                                            String clv5 = '';
                                            String clv10 = '';
                                            List <String> gps = new List<String>();
                                            
                                            if(oferta.tipo == 'modular')
                                            {
                                                if(String.isNotBlank(oferta.modular.producto.nivelPB))
                                                {
                                                	pba = oferta.modular.producto.nivelPB;
                                                }
                                                if(String.isNotBlank(oferta.modular.producto.clv5))
                                                {
                                                	clv5 = oferta.modular.producto.clv5;
                                                }
                                                if(String.isNotBlank(oferta.modular.producto.clv10))
                                                {
                                                	clv10 = oferta.modular.producto.clv10;
                                                }
                                                if(String.isNotBlank(oferta.modular.producto.gp))
                                                {
                                                	gps = oferta.modular.producto.gp.split('-');
                                                }
                                            }
                                                
                                            //gserrano 12/12/2018 añadida comprobacion de longitud gps = tramos.size
                                            if(oferta.modular.instalacion != null && (listaTramosNS = oferta.modular.instalacion.tramos) != null) //&& oferta.modular.instalacion.tramos.size() == gps.size()
                                            //if(oferta.modular.instalacion != null && (listaTramosNS = oferta.modular.instalacion.tramos) != null)
                                            {
                                                //for(EntidadesWSClientesYOfertas.Tramo tramo : listaTramosNS)
                                                for(Integer i = 0; i < listaTramosNS.size(); i++)
                                                {
                                                    if(listaTramosNS[i] != null)
                                                    {
                                                        //listTramos.add(WSDatosOfertas.crearTramoSFConTramoNS(listaTramosNS[i], quoteNS, pba));
                                                        if(listaTramosNS.size() == gps.size())
                                                        {
                                                        	listTramos.add(WSDatosOfertas.crearTramoSFConTramoNS(listaTramosNS[i], quoteNS, pba, clv5, clv10, gps[i]));
                                                        }
														else
                                                        {
                                                            listTramos.add(WSDatosOfertas.crearTramoSFConTramoNS(listaTramosNS[i], quoteNS, pba, clv5, clv10, null));
                                                        }
                                                    }
                                                }
                                            }
                                            if(oferta.modular.pack != null)
                                            {
                                                packServicio = WSDatosOfertas.crearPackServicioSFConPackNS(oferta.modular.pack, quoteNS);
                                                listPacks.add(packServicio);
                                                if( !mapPacksServiciosDeOferta.containsKey(oferta.identificador) )
                                                {
                                                    mapPacksServiciosDeOferta.put(oferta.identificador, packServicio);
                                                }
                                                if( !mapServiciosDeOferta.containsKey(oferta.identificador) )
                                                {
                                                    mapServiciosDeOferta.put( oferta.identificador, WSDatosOfertas.crearServiciosDePackConServiciosSeleccionadosNS(packServicio.Numero_de_pack__c, oferta.modular.pack.serviciosSeleccionados) );
                                                }
                                            }
                                        }
                                        if(oferta.personalizada != null)     // es oferta personalizada
                                        {
                                            if( (listaDepositosNS = oferta.personalizada.depositos) != null )
                                            {
                                                for(EntidadesWSClientesYOfertas.Deposito deposito : listaDepositosNS)
                                                {
                                                    if(deposito != null)
                                                    {
                                                        listDepositos.add( WSDatosOfertas.crearDepositoSFConDepositoNS(deposito, quoteNS, datosCliente.provincia) );
                                                    }
                                                }
                                            }
                                            if( (listaEquiposAjustesNS = oferta.personalizada.equiposAjuste) != null )
                                            {
                                                for(EntidadesWSClientesYOfertas.EquipoAjuste equipoAj : listaEquiposAjustesNS)
                                                {
                                                    if(equipoAj != null)
                                                    {
                                                        System.debug(Logginglevel.ERROR,'###listEquiposAjuste4 Personalizada');
                                                        listEquiposAjuste.add( WSDatosOfertas.crearEquipoAjusteSFConEquipoAjusteNS(equipoAj, quoteNS) );
                                                    }
                                                }
                                            }

                                            if( (listaEscaladoNS = oferta.personalizada.escalado) != null )
                                            {
                                                mapaQuoteIdTramo = new Map<String,Tramo__c>();
                                                for(EntidadesWSClientesYOfertas.Escalado tramo : listaEscaladoNS)
                                                {
                                                    if(tramo != null)
                                                    {
                                                        tramoEscaladoAux = WSDatosOfertas.crearTramoSFConEscaladoNS(tramo, quoteNS);
                                                        listTramos.add(tramoEscaladoAux);
                                                        if(String.isNotBlank(oferta.aplicarTramoEscalado) && oferta.aplicarTramoEscalado == tramo.idSalesforce)
                                                        {
                                                            mapaQuoteIdTramo.put(quoteNS.IdNewSales__c,tramoEscaladoAux);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            //Modifico fechaCreacionOportunidad si tengo datos
                            if(fechaCreacionOportunidad != null)
                            {
                                listOpportunities[listOpportunities.size() - 1].CreatedDate = fechaCreacionOportunidad;
                            }
                        }
                    }

                    // Actualizo las oportunidades en las que ha cambiado el canal de ventas
                    if( !listaOportunidadesUpdate.isEmpty() )
                    {
                        Database.update(listaOportunidadesUpdate);
                    }

                    // Isnertar en SF las entidades a crear
                    if( !listOpportunities.isEmpty() )
                    {
                        Database.insert(listOpportunities);
                    }
                    /*if(!listOpportunityContactRoles.isEmpty())
                       {
                       System.debug('INSERT listOpportunityContactRoles:' + listOpportunityContactRoles);
                       Database.insert(listOpportunityContactRoles);
                       }*/
                    if( !mapOpportunityContactRoles.isEmpty() )
                    {
                        listOpportunityContactRoles = new List<OpportunityContactRole>();

                        for ( String key : mapOpportunityContactRoles.keySet() )
                        {
                            listOpportunityContactRoles.add( mapOpportunityContactRoles.get(key) );
                        }
                        Database.insert(listOpportunityContactRoles);
                    }
                    if( !listPartners.isEmpty() )
                    {
                        Database.insert(listPartners);
                    }
                    if( !listPartnersDelete.isEmpty() )
                    {
                        Database.delete(listPartnersDelete);
                    }

                    List<Quote> listQuotesInserted = new List<Quote>();
                    Set<String> idNewSalesExistentes = new Set<String>();
                    //cambios gserrano 15/4/19

                    /*if(!listQuotes.isEmpty())
                    {
                        //Comprobamos que no exista ya una oferta en salesforce con ese id de newsales. Si existe, no se hace nada con ella
                        List<Quote> comprobarOfertasList = [select Id, IdNewSales__c, OpportunityId, Opportunity.Name, Opportunity.AccountId, QuoteNumber from Quote where IdNewSales__c = :setIdsNewSales];
                        List<Quote> listQuotesLimpia = new List<Quote>();
                        for(Quote q: listQuotes)
                        {
                            String idNewS = q.IdNewSales__c;
                            Boolean encontrado = false;
                            for(Quote qSF : comprobarOfertasList)
                            {
                                if(idNewS.equals(qSF.IdNewSales__c))
                                {
                                    encontrado = true;
                                    idNewSalesExistentes.add(qSF.IdNewSales__c);
                                }
                            }

                            if(!encontrado)
                            {
                                listQuotesLimpia.add(q);
                            }
                        }
                        listQuotes.clear();
                        listQuotes = listQuotesLimpia.clone();

                        Database.insert(listQuotes);
                        // obtener correspondencia de ids para la respuesta
                        listOfIds = new List<OfertaIds>();
                        if(setIdsNewSales != null)
                        {
                            listQuotesInserted = [select Id, IdNewSales__c, OpportunityId, Opportunity.Name, Opportunity.AccountId, QuoteNumber from Quote where IdNewSales__c = :setIdsNewSales];
                            for(Quote q : listQuotesInserted)
                            {
                                if(q != null && q.Id != null && q.OpportunityId != null)
                                {
                                    listOfIds.add(new OfertaIds(q.IdNewSales__c, String.valueOf(q.Id), String.valueOf(q.OpportunityId), q.Opportunity.Name, q.QuoteNumber, q.Opportunity.AccountId));
                                }
                            }
                        }
                    }*/

                    List<Quote> comprobarOfertasList = [select Id, IdNewSales__c, OpportunityId, Opportunity.Name, Opportunity.AccountId, QuoteNumber from Quote where IdNewSales__c = :setIdsNewSales];
                    List<Quote> listQuotesLimpia = new List<Quote>();
                    List<Quote> listQuotesLimpiaParcial;
                    map<String, List<quote>> mapEmailQuotesLimpio= new map<String,list<quote>>();
                    for(String emailKey : mapEmailQuotes.keySet())
                    {
                        listQuotesLimpiaParcial = new List<Quote>();

                        List<Quote> quotesToSave = mapEmailQuotes.get(emailKey);
                        for(Quote q: quotesToSave)
                        {
                            String idNewS = q.IdNewSales__c;
                            Boolean encontrado = false;
                            for(Quote qSF : comprobarOfertasList)
                            {
                                if(idNewS.equals(qSF.IdNewSales__c))
                                {
                                    encontrado = true;
                                    idNewSalesExistentes.add(qSF.IdNewSales__c);
                                }
                            }

                            if(!encontrado)
                            {
                                listQuotesLimpia.add(q);
                                listQuotesLimpiaParcial.add(q);
                            }
                        }
                        mapEmailQuotesLimpio.put(emailKey, listQuotesLimpiaParcial);
                    }
                    
                    listQuotes = listQuotesLimpia.clone();

                    Database.insert(listQuotes);

                    listOfIds = new List<OfertaIds>();
                    if(setIdsNewSales != null)
                    {
                        listQuotesInserted = [select Id, IdNewSales__c, OpportunityId, Opportunity.Name, Opportunity.AccountId, QuoteNumber from Quote where IdNewSales__c = :setIdsNewSales];
                        for(Quote q : listQuotesInserted)
                        {
                            if(q != null && q.Id != null && q.OpportunityId != null)
                            {
                                listOfIds.add(new OfertaIds(q.IdNewSales__c, String.valueOf(q.Id), String.valueOf(q.OpportunityId), q.Opportunity.Name, q.QuoteNumber, q.Opportunity.AccountId));
                            }
                        }
                    }

                    //cambios gserrano 15/4/19 HASTA AQUI
                    if( !listEquiposActuales.isEmpty() )
                    {

                        List<Equipo_actual__c> listEquiposActualesLimpia = new List<Equipo_actual__c>();
                        for(Equipo_actual__c equipoActual: listEquiposActuales)
                        {
                            if( !idNewSalesExistentes.contains(equipoActual.Presupuesto__r.IdNewSales__c) )
                            {
                                listEquiposActualesLimpia.add(equipoActual);
                            }
                        }
                        Database.insert(listEquiposActualesLimpia);
                    }
                    if( !listEnergiasActuales.isEmpty() )
                    {
                        List<Energia_Actual__c> listEnergiasActualesLimpia = new List<Energia_Actual__c>();
                        for(Energia_Actual__c energiaActual: listEnergiasActuales)
                        {
                            if( !idNewSalesExistentes.contains(energiaActual.Presupuesto__r.IdNewSales__c) )
                            {
                                listEnergiasActualesLimpia.add(energiaActual);
                            }
                        }
                        Database.insert(listEnergiasActualesLimpia);
                    }

                    //Cambios rfernandez (8/03/2017)
                    /*if(!listQuotesInserted.isEmpty())
                       {
                        PresupuestoUtil.crearEnergiasEnOportunidad(listQuotesInserted);
                       }*/
                    //Fin cambios rfernandez

                    if( !listTramos.isEmpty() )
                    {

                        List<Tramo__c> listTramosLimpia = new List<Tramo__c>();
                        for(Tramo__c tramo: listTramos)
                        {
                            if( !idNewSalesExistentes.contains(tramo.Presupuesto__r.IdNewSales__c) )
                            {
                                listTramosLimpia.add(tramo);
                            }
                        }

                        Database.insert(listTramosLimpia);
                    }

                    if(mapaQuoteIdTramo != null && mapaQuoteIdTramo.size() > 0)
                    {
                        //Pongo el tramo escalado principal para las ofertas personalizadas que lo tengan
                        List<Quote> quotesUpdate = [SELECT Id, IdNewSales__c, Tramo_escalado_a_aplicar__c FROM Quote WHERE IdNewSales__c = :mapaQuoteIdTramo.keySet()];
                        if(quotesUpdate != null && quotesUpdate.size() > 0)
                        {
                            for(Quote q: quotesUpdate)
                            {
                                q.Tramo_escalado_a_aplicar__c = mapaQuoteIdTramo.get(q.IdNewSales__c).Id;
                            }
                            Database.update(quotesUpdate);
                        }
                    }
                    if( !listDepositos.isEmpty() )
                    {

                        List<Deposito__c> listDepositosLimpia = new List<Deposito__c>();
                        for(Deposito__c deposito: listDepositos)
                        {
                            if( !idNewSalesExistentes.contains(deposito.Presupuesto__r.IdNewSales__c) )
                            {
                                listDepositosLimpia.add(deposito);
                            }
                        }

                        Database.insert(listDepositosLimpia);
                    }
                    if( !listEquiposAjuste.isEmpty() )
                    {

                        List<Equipo_Ajuste__c> listEquiposAjusteLimpia = new List<Equipo_Ajuste__c>();
                        for(Equipo_Ajuste__c equipoAjuste: listEquiposAjuste)
                        {
                            if( !idNewSalesExistentes.contains(equipoAjuste.Presupuesto__r.IdNewSales__c) )
                            {
                                listEquiposAjusteLimpia.add(equipoAjuste);
                            }
                        }
                        Database.insert(listEquiposAjusteLimpia);
                    }

                    //Cambios rfernandez (24/01/2017) Se calcula el valor de importe total/Total inversion
                    PresupuestoUtil.calcularTotalInversionOfertaPersonalizada(listQuotes);
                    //Cambios rfernandez (21/02/2017) Actualizacion de los depositos de las ofertas modulares
                    //PresupuestoUtil.actualizarCreditoDepositoOfertaModular(listQuotes); //Creo que no hace falta porque en este momento ya tendría el total inversion


                    if( !listPacks.isEmpty() )
                    {

                        List<Pack_de_servicio__c> listPackLimpia = new List<Pack_de_servicio__c>();
                        for(Pack_de_servicio__c p: listPacks)
                        {
                            if( !idNewSalesExistentes.contains(p.Presupuesto__r.IdNewSales__c) )
                            {
                                listPackLimpia.add(p);
                            }
                        }

                        Database.insert(listPackLimpia);

                        listaServiciosInsert = new List<Servicio__c>();
                        for(Pack_de_servicio__c pck : listPackLimpia)
                        {
                            listaServAux = null;
                            if( mapServiciosDeOferta.containsKey( String.valueOf(pck.Presupuesto__c) ) )
                            {
                                listaServAux = mapServiciosDeOferta.get( String.valueOf(pck.Presupuesto__c) );
                            }
                            else
                            {
                                if( mapServiciosDeOferta.containsKey(pck.Presupuesto__r.IdNewSales__c) )
                                {
                                    listaServAux = mapServiciosDeOferta.get(pck.Presupuesto__r.IdNewSales__c);
                                }
                            }
                            if(listaServAux != null)
                            {
                                for(Servicio__c s : listaServAux)
                                {
                                    s.Pack_de_servicio__c = pck.Id;
                                    listaServiciosInsert.add(s);
                                }
                            }
                        }
                        if( !listaServiciosInsert.isEmpty() )
                        {

                            /*List<Servicio__c> listServicioLimpia = new List<Servicio__c>();
                               for(Servicio__c servicio: listaServiciosInsert)
                               {
                                if(!idNewSalesExistentes.contains(servicio.Presupuesto__r.IdNewSales__c))
                                {
                                    listServicioLimpia.add(servicio);
                                }
                               }*/

                            Database.insert(listaServiciosInsert);

                            //Cambios rfernandez(18/04/2017)
                            PresupuestoUtil.actualizarPrimaserviciosParaTramosModular(listQuotes);
                            //Fin cambios rfernandez
                        }
                    }

                    //cambios gserrano 15/4/2019
                    // Enviar quotes para aprobación y generar PDFs
                    /*if(!listQuotes.isEmpty())
                    {
                        listIdsQuotes = new List<String>();
                        for(Quote q : listQuotes)
                        {
                            // enviar aprobación
                            Approval.ProcessSubmitRequest apReq = new Approval.ProcessSubmitRequest();
                            apReq.setObjectId(q.id);
                            try
                            {
                                Approval.ProcessResult result = Approval.process(apReq);

                            }
                            catch (Exception e)
                            {
                                System.debug('##No se ha podido mandar a aprobación '+e.getMessage());
                            }

                            listIdsQuotes.add(q.Id);                         
                        }

                        //generar PDFs
                        //MODIFICADO POR gserrano 10/12/2018, se añade el parámetro null como la dirección de correo de envío, ya que igualmente 
                        //el parámetro enviarEmail es false (la opcion del || que pregunta por el campo enviar_email__c de la quota se basa en lo mismo y también será false)
                        system.debug('*** ENVIO OFERTA 2');

                        //gserrano 19/12/2018 
                        //cambio de parámetros que entran para que el email se pueda enviar aunque sea nuevo.
                        
                        //WSDatosOfertas.generarPDFOferta(listIdsQuotes, contacto.Id, true, false, null);

                        //gserrano cambio prueba email 20/12/2018
                        for(Oportunidad op : peticion.oportunidades)
                        {
                            for(EntidadesWSClientesYOfertas.Oferta oferta : op.ofertas)
                            {
                                WSDatosOfertas.generarPDFOferta(listIdsQuotes, contacto.Id, true, (oferta.enviarEmail == '1'), oferta.emailDestinatario);
                            }
                        }

                        //gserrano 12/04/2019 (Esto al final ni se ha probado)
                        //creo que la línea anterior estaba sujeta al error de generar el mismo pdf varias veces así que se procede de la siguiente forma:
                        //WSDatosOfertas.generarPDFOferta(listIdsQuotes, contacto.Id, true, (peticion.oportunidades[0].ofertas[0].enviarEmail == '1'), peticion.oportunidades[0].ofertas[0].emailDestinatario);
                    }*/

                    for(String emailKey : mapEmailQuotesLimpio.keySet())
                    {
                        listIdsQuotes = new List<String>();
                        List<Quote> quoteList = mapEmailQuotesLimpio.get(emailKey);
                        for(Quote q : quoteList)
                        {
                            // enviar aprobación
                            Approval.ProcessSubmitRequest apReq = new Approval.ProcessSubmitRequest();
                            apReq.setObjectId(q.id);
                            try
                            {
                                Approval.ProcessResult result = Approval.process(apReq);

                            }
                            catch (Exception e)
                            {
                                System.debug('##No se ha podido mandar a aprobación '+e.getMessage());
                            }

                            listIdsQuotes.add(q.Id);                         
                        }
                        
                        //El penúltimo parámetro no deberia ser true, sino preguntar si se debe enviar email o no -> (oferta.enviarEmail == '1')
                        System.debug('¿?¿?¿?');
                        WSDatosOfertas.generarPDFOferta(listIdsQuotes, contacto.Id, true, (emailKey.split(';')[1] == '1'), emailKey.split(';')[0]);
                    }

                    //cambios gserrano 15/4/2019 hasta aquí

                    if(comprobarEnvioEmail)
                    {
                        listOfIds = new List<OfertaIds>();
                        List<Quote> qSF = [SELECT Id, IdNewSales__c, OpportunityId, Opportunity.Name, QuoteNumber, Opportunity.AccountId FROM Quote WHERE Id =: identificadorOfertaExistente];
                        if(qSF != null && qSF.size() > 0)
                        {
                        	listOfIds.add(new OfertaIds(String.valueOf(qSF[0].Id), String.valueOf(qSF[0].Id), String.valueOf(qSF[0].OpportunityId), qSF[0].Opportunity.Name, qSF[0].QuoteNumber, qSF[0].Opportunity.AccountId));
                        }                    }

                    if(listOfIds != null)
                    {
                        r.ofertas = new List<OfertaIds>(listOfIds);
                    }


                }

                r.resultado.codigo = '700';
                r.resultado.texto = Label.WSError_700;
            }
            else
            {
                r.resultado.codigo = '701';
                r.resultado.texto = Label.WSError_701;
                LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSDatosOfertas', 'Error', true);
            }
        }
        catch(Exception e)
        {
            r.resultado.codigo = '702';
            r.resultado.texto = Label.WSError_702;
            LogUtil.crearLog(r.resultado.texto + ' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'Errores NewSales', 'WSDatosOfertas', 'Error', true);
            error = true;
        }

        try
        {
            //Si ha saltado alguna excepción, se hace rollback para que quede como antes
            if(error && sp != null)
            {
                Database.rollback(sp);
            }

            r.resultado.texto = r.resultado.texto + ' Fecha de ejecución:' + String.valueOf( System.now() );
            jRespuesta = (String) JSON.serialize(r);
        }
        catch(Exception e)
        {
			LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSDatosOfertas', 'Error', true);
        }
        
        if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
        {
        	LogUtil.guardarLog();
        }

        return jRespuesta;
    }

    private static Boolean comprobarIdOportunidadSF(String idOpp)
    {
        Boolean resultado = false;
        try
        {
            if( !String.isBlank(idOpp) )
            {
                resultado = ( (idOpp.length() == 18) && ( idOpp.startsWith('006') ) );
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al comprobar si se trata de un id de oportunidad en SF: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static Boolean comprobarIdQuoteSF(String idQ)
    {
        Boolean resultado = false;
        try
        {
            if( !String.isBlank(idQ) )
            {
                resultado = ( (idQ.length() == 18) && ( idQ.startsWith('0Q0') ) );
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al comprobar si se trata de un id de quote en SF: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static Quote crearQuoteConOferta(EntidadesWSClientesYOfertas.Oferta oferta, Id oppIdSF, String oppIdNS, Id idPrescriptor, String provincia)
    {
        Quote resultado;
        Opportunity oppNS;
        EntidadesWSClientesYOfertas.Prioridades infoPrioridades;
        EntidadesWSClientesYOfertas.AhorroEstimado infoAhorro;
        EntidadesWSClientesYOfertas.Total infoTotal;
        EntidadesWSClientesYOfertas.InstalacionModular infoInstalacionMod;
        EntidadesWSClientesYOfertas.Producto infoProducto;
        EntidadesWSClientesYOfertas.PagoInversion infoPagoInversion;
        EntidadesWSClientesYOfertas.ProductoGas infoProdGas;
        EntidadesWSClientesYOfertas.PrimaServicios infoPrimaserv;
        EntidadesWSClientesYOfertas.Estandar infoEstandar;
        NivelesPB__c nivelPBMaestro;
        String txtAux;
        Integer anyo;
        Integer mes;
        Integer dia;
        Integer hora;
        Integer minuto;
        Integer segundo;
        try
        {
            if(oferta != null)
            {
                resultado = new Quote();
                resultado.IdNewSales__c = oferta.identificador;
                if( !String.isBlank(provincia) )
                {
                    resultado.Provincia_facturaci_n__c = provincia.toUpperCase();
                }
                if( oferta.tipo == Util.constantesNewSales.get('TIPO_OFERTA_MODULAR') )
                {
                    resultado.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id;
                }
                else
                {
                    if( oferta.tipo == Util.constantesNewSales.get('TIPO_OFERTA_PERSONALIZADA') )
                    {
                        resultado.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id;
                    }
                    else
                    {
                        if( oferta.tipo == Util.constantesNewSales.get('TIPO_OFERTA_ESTANDAR') )
                        {
                            resultado.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id;
                        }
                    }
                }
                resultado.Status = 'Preparando';
                resultado.Prescriptor__c = idPrescriptor;
                if(oferta.fechaCreacion != null && oferta.fechaCreacion.length() >= 8)
                {
                    anyo = Integer.valueOf( oferta.fechaCreacion.substring(0,4) );
                    mes = Integer.valueOf( oferta.fechaCreacion.substring(5,7) );
                    dia = Integer.valueOf( oferta.fechaCreacion.substring(8,10) );
                    hora = Integer.valueOf( oferta.fechaCreacion.substring(11,13) );
                    minuto = Integer.valueOf( oferta.fechaCreacion.substring(14,16) );
                    segundo = Integer.valueOf( oferta.fechaCreacion.substring(17,19) );

                    resultado.CreatedDate = DateTime.newInstance(anyo, mes, dia, hora, minuto, segundo);
                }
                if(oferta.fechaVigencia != null && oferta.fechaVigencia.length() >= 8)
                {
                    anyo = Integer.valueOf( oferta.fechaVigencia.substring(0,4) );
                    mes = Integer.valueOf( oferta.fechaVigencia.substring(4,6) );
                    dia = Integer.valueOf( oferta.fechaVigencia.substring(6,8) );
                    resultado.Fecha_vigencia__c = Date.newInstance(anyo, mes, dia);
                }

                resultado.Duracion_contratado__c = oferta.duracionAnyos;

                if(oferta.observaciones.length() > 200)
                {
                    String observacionesSubstring = oferta.observaciones.substring(0,200);
                    resultado.Observaciones__c = observacionesSubstring;
                }
                else
                {
                    resultado.Observaciones__c = oferta.observaciones;
                }

                //Cambios rfernandez (20/02/2017)
                if( !String.isBlank(oferta.notas) )
                {
                    resultado.Notas__c = oferta.notas;
                }
                //Fin cambios rfernandez
                resultado.Enviar_email__c = (oferta.enviarEmail == '1');
                if( !String.isBlank(oferta.resolucionAnticipada) )
                    resultado.Resolucion_anticipada__c = Decimal.valueOf(oferta.resolucionAnticipada);
                if(oppIdSF == null)
                {
                    if( !String.isBlank(oppIdNS) )
                    {
                        oppNS = new Opportunity(IdNewSales__c = oppIdNS);
                        resultado.Opportunity = oppNS;
                    }
                }
                else
                {
                    resultado.OpportunityId = oppIdSF;
                }

                if(oferta.equiposInstalarPrimagas != null)
                {
                    resultado.Equipos_a_instalar_Primagas__c = oferta.equiposInstalarPrimagas.equipos;     //Cambios rfernandez (21/03/2017) ponia .descripcion
                }

                // prioridades
                if( (infoPrioridades = oferta.prioridades) != null )
                {
                    resultado.Prioridades_comodidad__c = (infoPrioridades.comodidad == '1');
                    resultado.Prioridades_despreocuparse__c = (infoPrioridades.despreocuparse == '1');
                    resultado.Prioridades_enterrado__c = (infoPrioridades.enterrado == '1');
                    resultado.Prioridades_ahorro_anual__c = (infoPrioridades.ahorroAnual == '1');
                    resultado.Prioridades_precio_regulado__c = (infoPrioridades.precioRegulado == '1');
                    resultado.Prioridades_pagar_consumo__c = (infoPrioridades.pagarConsumo == '1');
                    resultado.Prioridades_precio_fijo__c = (infoPrioridades.precioFijo == '1');
                    resultado.Prioridades_tarifa_plana__c = (infoPrioridades.tarifaPlana == '1');
                    resultado.Prioridades_impacto__c = infoPrioridades.impacto;
                }

                // ahorro estimado
                if( (infoAhorro = oferta.ahorroEstimado) != null )
                {
                    if( !String.isBlank(infoAhorro.total) )
                    {
                        resultado.Importe_total__c = Decimal.valueOf(infoAhorro.total);
                    }
                    if( !String.isBlank(infoAhorro.totalPrimagas) )
                    {
                        resultado.Importe_total_primagas__c = Decimal.valueOf(infoAhorro.totalPrimagas);
                    }
                    if( !String.isBlank(infoAhorro.diferencia) )
                    {
                        resultado.Diferencia_importes_totales__c = Decimal.valueOf(infoAhorro.diferencia);
                    }
                }

                if(oferta.instalacion != null)
                {
                    // total
                    if( (infoTotal = oferta.instalacion.total) != null )
                    {
                        if( !String.isBlank(infoTotal.kg) )
                        {
                            resultado.Kg__c = Decimal.valueOf(infoTotal.kg);
                        }
                        if( !String.isBlank(infoTotal.kwh) )
                        {
                            resultado.KWh__c = Decimal.valueOf(infoTotal.kwh);
                        }
                        if( !String.isBlank(infoTotal.litros) )
                        {
                            resultado.Litros__c = Decimal.valueOf(infoTotal.litros);
                        }
                        if( !String.isBlank(infoTotal.kgCO2) )
                        {
                            resultado.KgCO2__c = Decimal.valueOf(infoTotal.kgCO2);
                        }
                        if( !String.isBlank(infoTotal.diferenciaKwh) )
                        {
                            resultado.Diferencia_kWh__c = Decimal.valueOf(infoTotal.diferenciaKwh);
                        }
                        else
                        {
                            resultado.Diferencia_kWh__c = 0;
                        }
                        if( !String.isBlank(infoTotal.diferenciaKgCo2) )
                        {
                            resultado.Diferencia_kgCO2__c = Decimal.valueOf(infoTotal.diferenciaKgCo2);
                        }
                        else
                        {
                            resultado.Diferencia_kgCO2__c = 0;
                        }
                        if( !String.isBlank(infoTotal.totalKgCO2Primagas) )
                        {
                            resultado.KgCO2_Primagas__c = Decimal.valueOf(infoTotal.totalKgCO2Primagas);
                        }
                        if( !String.isBlank(infoTotal.totalKwhPrimagas) )
                        {
                            resultado.KWh_Primagas__c = Decimal.valueOf(infoTotal.totalKwhPrimagas);
                        }
                    }
                }
                if( oferta.tipo == Util.constantesNewSales.get('TIPO_OFERTA_MODULAR') )
                {
                    if(oferta.modular != null)     // oferta modular
                    {
                        resultado.Name = 'Modular_' + DateTime.now().format('yyyy-MM-dd_hh:mm:ss');
                        // instalación
                        if( (infoInstalacionMod = oferta.modular.instalacion) != null )
                        {
                            resultado.Equipo_interior__c = infoInstalacionMod.equipoInterior;
                            if( !String.isBlank(infoInstalacionMod.costeEquipoInterior) )
                            {
                                resultado.Coste_equipo_interior__c = Decimal.valueOf(infoInstalacionMod.costeEquipoInterior);
                            }
                            resultado.Interior__c = (infoInstalacionMod.interior == '1');
                            if( !String.isBlank(infoInstalacionMod.costeInterior) )
                            {
                                resultado.Coste_interior__c = Decimal.valueOf(infoInstalacionMod.costeInterior);
                            }
                            resultado.Deposito_nombre__c = infoInstalacionMod.deposito;
                            if( !String.isBlank(infoInstalacionMod.costeDeposito) )
                            {
                                resultado.Coste_deposito__c = Decimal.valueOf(infoInstalacionMod.costeDeposito);
                            }
                            resultado.Exterior__c = (infoInstalacionMod.exterior == '1');
                            if( !String.isBlank(infoInstalacionMod.costeExterior) )
                            {
                                resultado.Coste_instalacion_exterior__c = Decimal.valueOf(infoInstalacionMod.costeExterior);
                            }
                            resultado.Vallado__c = (infoInstalacionMod.vallado == '1');
                            if( !String.isBlank(infoInstalacionMod.costeVallado) )
                            {
                                resultado.Coste_vallado__c = Decimal.valueOf(infoInstalacionMod.costeVallado);
                            }
                            resultado.Obra_civil__c = (infoInstalacionMod.obraCivil == '1');
                            if( !String.isBlank(infoInstalacionMod.costeObraCivil) )
                            {
                                resultado.Coste_obra_civil__c = Decimal.valueOf(infoInstalacionMod.costeObraCivil);
                            }
                            if( !String.isBlank(infoInstalacionMod.totalInversion) )
                            {
                                resultado.Total_inversion__c = Decimal.valueOf(infoInstalacionMod.totalInversion);
                            }
                            //Cambios rfernandez (08/02/2017)
                            if( !String.isBlank(provincia) && !String.isBlank(infoInstalacionMod.deposito) )
                            {
                                CostesLegalizacionProvincia__c costeLegalizacion = [Select Coste__c
                                                                                    From CostesLegalizacionProvincia__c
                                                                                    Where Provincia__c =:provincia And Deposito__c =: infoInstalacionMod.deposito];

                                Decimal totalConDeposito = Decimal.valueOf(infoInstalacionMod.totalInversion) + depositosConCoste.get(infoInstalacionMod.deposito) + costeLegalizacion.Coste__c;
                                resultado.Total_Inversion_con_deposito__c = totalConDeposito;
                                System.debug('#####totalConDeposito' + totalConDeposito);
                            }
                            //Fin cambios rfernandez (08/02/2017)

                            if( !String.isBlank(infoInstalacionMod.totalfinanciable) )
                            {
                                resultado.Total_financiable__c = Decimal.valueOf(infoInstalacionMod.totalfinanciable);
                            }
                            if( !String.isBlank(infoInstalacionMod.pagoInicial) )
                            {
                                resultado.Pago_inicial__c = Decimal.valueOf(infoInstalacionMod.pagoInicial);
                            }
                            if( !String.isBlank(infoInstalacionMod.tipoInteres) )
                            {
                                resultado.Tipo_de_interes__c = Decimal.valueOf(infoInstalacionMod.tipoInteres);
                            }
                            resultado.Instalacion_interior__c = infoInstalacionMod.instalacionInterior;
                            if( !String.isBlank(infoInstalacionMod.costeProyectos) )
                            {
                                resultado.Coste_proyectos__c = Decimal.valueOf(infoInstalacionMod.costeProyectos);
                            }
                            resultado.Proyectos__c = infoInstalacionMod.proyectos;
                            resultado.Financiacion_seleccionada__c = infoInstalacionMod.financiacionSeleccionada;
                            if( !String.isBlank(infoInstalacionMod.numeroCuotas) )
                            {
                                resultado.Numero_de_cuotas__c = Decimal.valueOf(infoInstalacionMod.numeroCuotas);
                            }
                            if( !String.isBlank(infoInstalacionMod.importeCuotas) )
                            {
                                resultado.Importe_de_cuotas__c = Decimal.valueOf(infoInstalacionMod.importeCuotas);
                            }
                            if( !String.isBlank(infoInstalacionMod.importeDoceCuotas) )
                            {
                                resultado.Importe_12_cuotas__c = Decimal.valueOf(infoInstalacionMod.importeDoceCuotas);
                            }
                            if( !String.isBlank(infoInstalacionMod.importeEnGasEurosL) )
                            {
                                resultado.Importe_en_gas_en_E_L__c = Decimal.valueOf(infoInstalacionMod.importeEnGasEurosL);
                            }
                            if( !String.isBlank(infoInstalacionMod.importeEnGasEurosKg) )
                            {
                                resultado.Importe_en_gas_en_E_Kg__c = Decimal.valueOf(infoInstalacionMod.importeEnGasEurosKg);
                            }
                            if( !String.isBlank(infoInstalacionMod.importeAhorroInstalacion) )
                            {
                                resultado.Importe_ahorro_instalacion__c = Decimal.valueOf(infoInstalacionMod.importeAhorroInstalacion);
                            }
                            resultado.Aplica_tramos__c = (infoInstalacionMod.aplicaTramo == '1');
                            if( !String.isBlank(infoInstalacionMod.costeInstalacionInterior) )
                            {
                                resultado.Coste_instalacion_interior__c = Decimal.valueOf(infoInstalacionMod.costeInstalacionInterior);
                            }
                        }

                        // producto
                        if( (infoProducto = oferta.modular.producto) != null )
                        {
                            if( !String.isBlank(infoProducto.precioMensualL) )
                            {
                                resultado.Precio_mensual_L__c = Decimal.valueOf(infoProducto.precioMensualL);
                            }
                            if( !String.isBlank(infoProducto.precioFijoAnualL) )
                            {
                                resultado.Precio_fijo_anual_L__c = Decimal.valueOf(infoProducto.precioFijoAnualL);
                            }
                            if( !String.isBlank(infoProducto.contadorL) )
                            {
                                resultado.Contador_L__c = Decimal.valueOf(infoProducto.contadorL);
                            }
                            if( !String.isBlank(infoProducto.tarifaPlanaL) )
                            {
                                resultado.Tarifa_plana_L__c = Decimal.valueOf(infoProducto.tarifaPlanaL);
                            }
                            if( !String.isBlank(infoProducto.precioMensualKg) )
                            {
                                resultado.Precio_mensual_Kg__c = Decimal.valueOf(infoProducto.precioMensualKg);
                            }
                            if( !String.isBlank(infoProducto.precioFijoAnualKg) )
                            {
                                resultado.Precio_fijo_anual_Kg__c = Decimal.valueOf(infoProducto.precioFijoAnualKg);
                            }
                            if( !String.isBlank(infoProducto.contadorKg) )
                            {
                                resultado.Contador_Kg__c = Decimal.valueOf(infoProducto.contadorKg);
                            }
                            if( !String.isBlank(infoProducto.tarifaPlanaKg) )
                            {
                                resultado.Tarifa_plana_Kg__c = Decimal.valueOf(infoProducto.tarifaPlanaKg);
                            }
                            resultado.PB__c = Decimal.valueOf( infoProducto.nivelPB.replace(',','.') );     //TODO QUITAR REEMPLAZAR , POR .
                            /*if(!String.isBlank(infoProducto.nivelPB))
                               {
                                nivelPBMaestro = NivelesPB__c.getValues(infoProducto.nivelPB);
                                if(nivelPBMaestro != null)
                                {
                                    resultado.PB__c = nivelPBMaestro.Valor__c;
                                }
                               }*/
                            resultado.Texto_fecha_producto__c = infoProducto.fecha;
                            resultado.Opcion_seleccionada_producto__c = infoProducto.opcionSeleccionada;
                            if( !String.isBlank(infoProducto.importeAhorroGas) )
                            {
                                resultado.Importe_ahorro_gas__c = Decimal.valueOf(infoProducto.importeAhorroGas);
                            }

                            //gserrano 07/06/2019
                            System.debug('****gserrano 07/06/2019');
                            if(!String.isBlank(infoProducto.gp))
                            {
                                String splitgp = infoProducto.gp.split('-')[0];
                                resultado.gp__c = Decimal.valueOf(splitgp);
                            }
                            if(!String.isBlank(infoProducto.clv5))
                            {
                                resultado.clv5__c = Decimal.valueOf(infoProducto.clv5);
                            }
                            if(!String.isBlank(infoProducto.clv10))
                            {
                                resultado.clv10__C = Decimal.valueOf(infoProducto.clv10);
                            }
                            
                            System.debug('****gserrano 07/06/2019');

                        }
                    }
                }
                else
                {
                    if( oferta.tipo == Util.constantesNewSales.get('TIPO_OFERTA_PERSONALIZADA') )
                    {
                        if(oferta.personalizada != null)     // oferta personalizada
                        {
                            resultado.Name = 'Personalizada_' + DateTime.now().format('yyyy-MM-dd_hh:mm:ss');
                            // pago inversión
                            if( (infoPagoInversion = oferta.personalizada.pagoInversion ) != null )
                            {
                                resultado.Tipo_de_pago_inversion__c = infoPagoInversion.tipo;
                                if( !String.isBlank(infoPagoInversion.pagoIncial) )
                                {
                                    resultado.Pago_inicial_inversion__c = Decimal.valueOf(infoPagoInversion.pagoIncial);
                                }
                                if( !String.isBlank(infoPagoInversion.cuotaInversion) )
                                {
                                    resultado.Cuota_inversion__c = Decimal.valueOf(infoPagoInversion.cuotaInversion);
                                }
                                if( !String.isBlank(infoPagoInversion.duracionCuota) )
                                {
                                    resultado.Duracion_cuota_inversion__c = Decimal.valueOf(infoPagoInversion.duracionCuota);
                                }
                                if( !String.isBlank(infoPagoInversion.dto1llenado) )
                                {
                                    resultado.Dto_1_Llenado_inversion__c = Decimal.valueOf(infoPagoInversion.dto1llenado);
                                }
                            }
                            // producto Gas
                            if( (infoProdGas = oferta.personalizada.productoGasAjuste) != null )
                            {
                                resultado.Tipo_producto_gas__c = infoProdGas.tipo;
                                resultado.Tipo_de_tarifa__c = infoProdGas.tarifa;
                                resultado.Duracion_descuento__c = infoProdGas.duracionDto;
                                /*if(!String.isBlank(infoProdGas.dto))
                                   {
                                    resultado.Dto_Producto_gas__c = Decimal.valueOf(infoProdGas.dto);
                                   }
                                   if(!String.isBlank(infoProdGas.precio))
                                   {
                                    resultado.Precio_producto_gas__c = Decimal.valueOf(infoProdGas.precio);
                                   }*/
                            }
                            // primaservicios
                            if( (infoPrimaserv = oferta.personalizada.primaServiciosAjuste) != null )
                            {
                                resultado.Tipo_Primaservicios__c = infoPrimaserv.tipo;
                                resultado.Mantenimiento_primaservicios__c = (infoPrimaserv.mto == '1');
                                resultado.Inspeccion_interior_primaservicios__c = (infoPrimaserv.inspeccionInterior == '1');
                                resultado.Revision_interior_primaservicios__c = (infoPrimaserv.revisionInterior == '1');
                                /*if(!String.isBlank(infoPrimaserv.precio))
                                   {
                                    resultado.Precio_Primaservicios__c = Decimal.valueOf(infoPrimaserv.precio);
                                   }*/
                            }

                            //Rellenar pb con el valor del tramo medio
                            List<EntidadesWSClientesYOfertas.Escalado> listaEscaladoNS;
                            if( (listaEscaladoNS = oferta.personalizada.escalado) != null )
                            {
                                for(EntidadesWSClientesYOfertas.Escalado tramo : listaEscaladoNS)
                                {
                                    if(tramo != null)
                                    {
                                        if(String.isNotBlank(tramo.porcentajeDesde) && Decimal.valueOf(tramo.porcentajeDesde) <= 100.0 &&
                                           String.isNotBlank(tramo.porcentajeHasta) && Decimal.valueOf(tramo.porcentajeHasta) >= 100.0)
                                        {
                                            //Cambio rfernandez (25/01/2017)
                                            if( !String.isBlank(tramo.dtoKg) )
                                            {
                                                resultado.Dto_Producto_gas__c = Decimal.valueOf(tramo.dtoKg);
                                            }
                                            if( !String.isBlank(tramo.precioHoyK) )
                                            {
                                                resultado.Precio_producto_gas__c = Decimal.valueOf(tramo.precioHoyK);
                                            }
                                            if( !String.isBlank(tramo.primaServiciosA) )
                                            {
                                                resultado.Precio_Primaservicios__c = Decimal.valueOf(tramo.primaServiciosA);
                                            }
                                            resultado.PB__c = Decimal.valueOf(tramo.pba);
                                            resultado.CLV5__c = Decimal.valueOf(tramo.clv5);
                                            resultado.CLV10__c = Decimal.valueOf(tramo.clv10);
                                            resultado.GP__c = Decimal.valueOf(tramo.gp);
                                            break;
                                        }
                                    }
                                }
                            }


                        }
                    }
                    else
                    {
                        if( oferta.tipo == Util.constantesNewSales.get('TIPO_OFERTA_ESTANDAR') )
                        {
                            if( (infoEstandar = oferta.estandar) != null )     // oferta  estándar
                            {
                                resultado.Name = infoEstandar.tipoOferta;
                                resultado.Interior_estandar__c = infoEstandar.interior;
                                resultado.Exterior_estandar__c = infoEstandar.exterior;
                                resultado.Servicio_estandar__c = infoEstandar.servicio;
                                /*if(!String.isBlank(infoEstandar.consumoContratado))
                                   {
                                    txtAux = infoEstandar.consumoContratado.trim().toLowerCase();
                                    if(txtAux.contains('l'))
                                    {
                                        resultado.Consumo_contratado_L__c = Decimal.valueOf(txtAux.substring(0,txtAux.indexOf('l')).trim());
                                    }
                                    txtAux = txtAux.substringBetween('(', ')');
                                    if(!String.isBlank(txtAux) && txtAux.contains('kg'))
                                    {
                                        resultado.Consumo_contratado_kg__c = Decimal.valueOf(txtAux.substring(0,txtAux.indexOf('kg')).trim());
                                    }
                                   }*/
                                resultado.Consumo_contratado_L__c  = Decimal.valueOf(oferta.instalacion.total.litros);
                                resultado.Consumo_contratado_kg__c = Decimal.valueOf(oferta.instalacion.total.kg);
                                resultado.Texto_servicio_estandar__c = infoEstandar.texto;
                                resultado.Tarifa_estandar__c = infoEstandar.tarifa;
                                if( !String.isBlank(infoEstandar.dto) )
                                {
                                    resultado.Dto_Estandar__c = Decimal.valueOf(infoEstandar.dto);
                                }
                                resultado.Duracion_descuento__c = infoEstandar.duracionDto;
                                if( !String.isBlank(infoEstandar.pagoInicial) )
                                {
                                    resultado.Pago_inicial__c = Decimal.valueOf(infoEstandar.pagoInicial);
                                }
                                resultado.Precio_fecha__c = infoEstandar.precioFecha;
                                if( !String.isBlank(infoEstandar.precioL) )
                                {
                                    resultado.Precio_L__c = Decimal.valueOf(infoEstandar.precioL);
                                }
                                if( !String.isBlank(infoEstandar.preciokg) )
                                {
                                    resultado.Precio_Kg__c = Decimal.valueOf(infoEstandar.preciokg);
                                }
                                if( !String.isBlank(infoEstandar.servicioValor) )
                                {
                                    resultado.Valor_del_servicio_estandar__c = Decimal.valueOf(infoEstandar.servicioValor);
                                }
                                //Añadido por gserrano 0/12/2018
                                resultado.Name_OpcionesOfertaSTD_maestro__c = infoEstandar.idSalesforce;    //Nombre 
                                
                                OpcionesOfertaSTD__c ooSTD = ofertasStdMap.get(infoEstandar.idSalesforce);
                                
                                if(ooSTD != null)
                                {
                                    if(ooSTD.Imp_inst_ext__c != null)
                                    {
                                        resultado.Coste_instalacion_exterior__c = ooSTD.Imp_inst_ext__c;
                                    }
                                    
                                    if(ooSTD.Imp_inst_int__c != null)
                                    {
                                        resultado.Coste_instalacion_interior__c = ooSTD.Imp_inst_int__c;
                                    }
                                    
                                    if(ooSTD.Imp_obra_civil__c != null)
                                    {
                                        resultado.Coste_obra_civil__c = ooSTD.Imp_obra_civil__c;
                                    }
                                    
                                    if(ooSTD.Imp_proyectos__c != null)
                                    {
                                        resultado.Coste_proyectos__c = ooSTD.Imp_proyectos__c;
                                    }
                                    
                                    if(ooSTD.Imp_equipos__c != null)
                                    {
                                        resultado.Coste_equipo_interior__c = ooSTD.Imp_equipos__c;
                                    }
                                }
                                //Añadido por gserrano 0/12/2018 hasta aquí
                                resultado.Name_ImagenesOferta_maestro__c = infoEstandar.idSalesforceTipoOferta;

                                //Cambios rfernandez (09/02/2017) El total inversion no se estaba calculando/guardando donde debía
                                if( !String.isBlank(provincia) )
                                {
                                    if( !Test.isRunningTest() )
                                    {
                                        Decimal inversionSinDeposito = ofertasStdMap.get(infoEstandar.idSalesforce).InversionSinDeposito__c;
                                        resultado.Total_inversion__c = inversionSinDeposito;

                                        String nombreDeposito = ofertasStdMap.get(infoEstandar.idSalesforce).Deposito__c;
                                        CostesLegalizacionProvincia__c costeLegalizacion = [Select Coste__c
                                                                                            From CostesLegalizacionProvincia__c
                                                                                            Where Provincia__c =:provincia And Deposito__c =: nombreDeposito];

                                        Decimal totalConDeposito = inversionSinDeposito + depositosConCoste.get(nombreDeposito) + costeLegalizacion.Coste__c;
                                        resultado.Total_Inversion_con_deposito__c = totalConDeposito;
                                        System.debug('#####totalSinDeposito' + inversionSinDeposito);
                                        System.debug('#####totalConDeposito' + totalConDeposito);
                                    }
                                    else
                                    {
                                        resultado.Total_inversion__c = 100.00;
                                        resultado.Total_Inversion_con_deposito__c = 100.00;
                                    }
                                }
                                //Fin cambios rfernandez (09/02/2017)
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear quote con oferta: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        system.debug('QUOTE NAME: ' + resultado.Name);
        return resultado;
    }

    private static Equipo_actual__c crearEquipoActualConEquipo(EntidadesWSClientesYOfertas.Equipo equipo, Quote quoteNS)
    {
        Equipo_actual__c resultado = null;
        try
        {
            if(equipo != null)
            {
                resultado = new Equipo_actual__c();
                if(quoteNS != null)
                {
                    resultado.Presupuesto__r = quoteNS;
                }
                resultado.Name = equipo.nombre;
                if( !String.isBlank(equipo.cantidad) )
                {
                    resultado.Cantidad__c = Decimal.valueOf(equipo.cantidad);
                }
                resultado.Uso__c = equipo.uso;
                if( !String.isBlank(equipo.potenciaKW) )
                {
                    resultado.Potencia_KW__c = Decimal.valueOf(equipo.potenciaKW);
                }
                resultado.Anyo__c = equipo.antiguedad;
                resultado.Energ_a__c = equipo.energia;
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Equipo_actual__c con equipo: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static Energia_Actual__c crearEnergiaActualConEnergia(EntidadesWSClientesYOfertas.Energia energia, Quote quoteNS)
    {
        Energia_Actual__c resultado = null;
        try
        {
            if(energia != null)
            {
                resultado = new Energia_Actual__c();
                if( quoteNS != null)
                {
                    resultado.Presupuesto__r = quoteNS;
                }
                resultado.Tipo_energia__c = energia.nombre;
                if( !String.isBlank(energia.consumo) )
                {
                    resultado.Consumo__c = Decimal.valueOf(energia.consumo);
                }
                if( !String.isBlank(energia.consumoKWH) )
                {
                    resultado.Consumo_KWH__c = Decimal.valueOf(energia.consumoKWH);
                }
                if( !String.isBlank(energia.consumoKgCO2) )
                {
                    resultado.Consumo_KgCo2__c = Decimal.valueOf(energia.consumoKgCO2);
                }
                if( !String.isBlank(energia.consumoL_primagas) )
                {
                    resultado.Consumo_L_Primagas__c = Decimal.valueOf(energia.consumoL_primagas);
                }
                if( !String.isBlank(energia.consumoKWH_primagas) )
                {
                    resultado.Consumo_KWH_Primagas__c = Decimal.valueOf(energia.consumoKWH_primagas);
                }
                if( !String.isBlank(energia.consumoKg_primagas) )
                {
                    resultado.Consumo_Kg_Primagas__c = Decimal.valueOf(energia.consumoKg_primagas);
                }
                if( !String.isBlank(energia.consumoKgCO2_primagas) )
                {
                    resultado.Consumo_KgCO2_Primagas__c = Decimal.valueOf(energia.consumoKgCO2_primagas);
                }
                resultado.Unidad_consumo__c = energia.unidadConsumo;
                if( !String.isBlank(energia.precio) )
                {
                    resultado.Precio__c = Decimal.valueOf(energia.precio);
                }
                resultado.Unidad_precio__c = energia.unidadPrecio;
                if( !String.isBlank(energia.proveedor) )
                {
                    resultado.Proveedor__c = Id.valueOf(energia.proveedor);
                }
                if( !String.isBlank(energia.rendimiento) )
                {
                    resultado.Rendimiento__c = Decimal.valueOf(energia.rendimiento);
                }
                resultado.Cambio__c = energia.cambio;
                if( !String.isBlank(energia.importeSituacionActual) )
                {
                    resultado.Importe_situacion_actual__c = Decimal.valueOf(energia.importeSituacionActual);
                }
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Energia_Actual__c con energia: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static Pack_de_servicio__c crearPackServicioSFConPackNS(EntidadesWSClientesYOfertas.Pack pack, Quote quoteNS)
    {
        Pack_de_servicio__c resultado = null;
        Pack__c packMaestro;
        try
        {
            if(pack != null)
            {
                resultado = new Pack_de_servicio__c();
                if(quoteNS != null)
                {
                    resultado.Presupuesto__r = quoteNS;
                }
                resultado.Name_Pack_maestros__c = pack.packSeleccionado.trim();
                if( !String.isBlank(pack.totalImporte) )
                {
                    resultado.Total_importe__c = Decimal.valueOf(pack.totalImporte);
                }
                packMaestro = Pack__c.getValues(resultado.Name_Pack_maestros__c);
                if(packMaestro != null)
                {
                    resultado.Name = packMaestro.Nombre__c;
                    resultado.Numero_de_pack__c = packMaestro.Numero_de_pack__c;
                }
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Pack_de_servicio__c con pack: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static List<Servicio__c> crearServiciosDePackConServiciosSeleccionadosNS(Decimal numeroPack, List<EntidadesWSClientesYOfertas.ServicioSeleccionado> listaServiciosSelec)
    {
        List<Servicio__c> resultado = null;
        List<ServiciosPacks__c> listaServiciosMaestros;
        Set<String> setIdsServSelec;
        Servicio__c servicio;
        try
        {
            if(numeroPack != null)
            {
                setIdsServSelec = new Set<String>();
                resultado = new List<Servicio__c>();
                if(listaServiciosSelec != null)
                {
                    for(EntidadesWSClientesYOfertas.ServicioSeleccionado ss : listaServiciosSelec)
                    {
                        if( !String.isBlank(ss.idServicio) )
                        {
                            setIdsServSelec.add(ss.idServicio);
                        }
                    }
                }
                listaServiciosMaestros = ServiciosPacks__c.getAll().values();
                if(listaServiciosMaestros != null)
                {
                    for(ServiciosPacks__c serv : listaServiciosMaestros)
                    {
                        if(serv.Numero_de_pack__c == numeroPack)
                        {
                            if( serv.Incluido__c || setIdsServSelec.contains(serv.Name) )
                            {
                                servicio = new Servicio__c();
                                servicio.Name_Servicio_pack_maestro__c = serv.Name;
                                servicio.Importe_mensual__c = serv.Importe_mensual__c;
                                servicio.Incluido__c = serv.Incluido__c;
                                servicio.Name = serv.Nombre__c;
                                resultado.add(servicio);
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Servicio__c con servicioSeleccionado: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static Deposito__c crearDepositoSFConDepositoNS(EntidadesWSClientesYOfertas.Deposito deposito, Quote quoteNS, String provincia)
    {
        Deposito__c resultado = null;
        try
        {
            if(deposito != null)
            {
                resultado = new Deposito__c();
                if(quoteNS != null)
                {
                    resultado.Presupuesto__r = quoteNS;
                }
                resultado.Name = deposito.tipo;
                if( !String.isBlank(deposito.cantidad) )
                {
                    resultado.Cantidad__c = Decimal.valueOf(deposito.cantidad);
                }
                if( !String.isBlank(deposito.equiposExterior) )
                {
                    resultado.Equipos_exterior__c = Decimal.valueOf(deposito.equiposExterior);
                }
                if( !String.isBlank(deposito.instalacionExterior) )
                {
                    resultado.Instalacion_exterior__c = Decimal.valueOf(deposito.instalacionExterior);
                }
                if( !String.isBlank(deposito.proyectos) )
                {
                    resultado.Proyectos__c = Decimal.valueOf(deposito.proyectos);
                }
                if( !String.isBlank(deposito.obraCivilVallado) )
                {
                    resultado.Obra_civil_vallado__c = Decimal.valueOf(deposito.obraCivilVallado);
                }
                DepositosMaestros__c depositoMaestro = DepositosMaestros__c.getValues('Depositos' + deposito.tipo);
                if(depositoMaestro != null)
                {
                    resultado.Es_aereo__c = depositoMaestro.EsAereo__c;
                    resultado.Capacidad__c = depositoMaestro.Capacidad__c;
                }
                //Cambios rfernandez (21/02/2017)
                if( costesDeLegalizacionMap.containskey(deposito.tipo) )
                {
                    resultado.Coste_de_legalizacion__c = costesDeLegalizacionMap.get(deposito.tipo).get(provincia);
                }

            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Deposito__c con deposito: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static Equipo_Ajuste__c crearEquipoAjusteSFConEquipoAjusteNS(EntidadesWSClientesYOfertas.EquipoAjuste equipoAj, Quote quoteNS)
    {
        System.debug(Logginglevel.ERROR,'###crearEquipoAjusteSFConEquipoAjusteNS');
        Equipo_Ajuste__c resultado = null;
        try
        {
            resultado = new Equipo_Ajuste__c();
            if(quoteNS != null)
            {
                resultado.Presupuesto__r = quoteNS;
            }
            resultado.Name = equipoAj.nombre;
            if( !String.isBlank(equipoAj.cantidad) )
            {
                resultado.Cantidad__c = Decimal.valueOf(equipoAj.cantidad);
            }
            if( !String.isBlank(equipoAj.equiposExterior) )
            {
                resultado.Equipos_exterior__c = Decimal.valueOf(equipoAj.equiposExterior);
            }
            if( !String.isBlank(equipoAj.equiposInterior) )
            {
                resultado.Equipos_interior__c = Decimal.valueOf(equipoAj.equiposInterior);
            }
            if( !String.isBlank(equipoAj.instalacionExterior) )
            {
                resultado.Instalacion_exterior__c  = Decimal.valueOf(equipoAj.instalacionExterior);
            }
            if( !String.isBlank(equipoAj.instalacionInterior) )
            {
                resultado.Instalacion_interior__c = Decimal.valueOf(equipoAj.instalacionInterior);
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Equipo_Ajuste__c con equipoAjuste: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static List<Equipo_Ajuste__c> crearEquipoAjusteInstalarSFConEquipoAjusteNS(EntidadesWSClientesYOfertas.EquiposInstalarPrimagas equipoAj, Quote quoteNS)
    {
        System.debug(Logginglevel.ERROR,'###crearEquipoAjusteInstalarSFConEquipoAjusteNS');
        Equipo_Ajuste__c resultado = null;
        List<Equipo_Ajuste__c> equiposAInstalar = new List<Equipo_Ajuste__c>();
        try
        {
            if( !String.isBlank(equipoAj.equipos) )
            {
                String equipos = equipoAj.equipos;

                List<String> equiposList = equipos.split(';');

                System.debug('equiposList: ' + equiposList);

                for(String equipo: equiposList)
                {
                    resultado = new Equipo_Ajuste__c();
                    if(quoteNS != null)
                    {
                        resultado.Presupuesto__r = quoteNS;
                    }

                    List<String> cantidadEquipo = equipo.split(' ');
                    System.debug(cantidadEquipo);

                    if(cantidadEquipo.size() > 1)
                    {
                        resultado.Cantidad__c = Decimal.valueOf(cantidadEquipo[0]);
                        resultado.Name = cantidadEquipo[1];
                    }
                    else
                    {
                        resultado.Cantidad__c = 1;
                        resultado.Name = cantidadEquipo[0];
                    }
                    equiposAInstalar.add(resultado);
                }
            }
            System.debug('equiposAInstalar ' + equiposAInstalar);

        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Equipo_Ajuste__c instalar con equipoAjuste: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return equiposAInstalar;
    }

     //private static Tramo__c crearTramoSFConTramoNS(EntidadesWSClientesYOfertas.Tramo tramo, Quote quoteNS, String pba)
    private static Tramo__c crearTramoSFConTramoNS(EntidadesWSClientesYOfertas.Tramo tramo, Quote quoteNS, String pba, String clv5, String clv10, String gp)  
    {
        System.debug('crearTramoSFConTramoNS (pba): ' + pba);
        Tramo__c resultado = null;
        try
        {
            if(tramo != null)
            {
                resultado = new Tramo__c();
                if(quoteNS != null)
                {
                    resultado.Presupuesto__r = quoteNS;
                }
                resultado.RecordTypeId = Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_normal').Id;
                resultado.Name = tramo.tramo;
                if( !String.isBlank(tramo.porcentajeDesde) )
                {
                    resultado.Porcentaje_desde__c = Decimal.valueOf( tramo.porcentajeDesde.replace(',','.') );
                }
                if( !String.isBlank(tramo.porcentajeHasta) )
                {
                    resultado.Porcentaje_hasta__c = Decimal.valueOf( tramo.porcentajeHasta.replace(',','.') );
                }
                if( !String.isBlank(tramo.consumoDesdeL) )
                {
                    resultado.Consumo_desde_L__c = Decimal.valueOf( tramo.consumoDesdeL.replace(',','.') );
                }
                if( !String.isBlank(tramo.consumoHastaL) )
                {
                    resultado.Consumo_hasta_L__c = Decimal.valueOf( tramo.consumoHastaL.replace(',','.') );
                }
                if( !String.isBlank(tramo.consumoDesdeKg) )
                {
                    resultado.Consumo_desde_Kg__c = Decimal.valueOf( tramo.consumoDesdeKg.replace(',','.') );
                }
                if( !String.isBlank(tramo.consumoHastaKg) )
                {
                    resultado.Consumo_hasta_Kg__c = Decimal.valueOf( tramo.consumoHastaKg.replace(',','.') );
                }
                if( !String.isBlank(tramo.financiacionL) )
                {
                    resultado.Financiacion_en_gas_en_E_L__c = Decimal.valueOf( tramo.financiacionL.replace(',','.') );
                }
                if( !String.isBlank(tramo.financiacionKg) )
                {
                    resultado.Financiacion_en_gas_en_E_Kg__c = Decimal.valueOf( tramo.financiacionKg.replace(',','.') );
                }
                if( !String.isBlank(pba) )
                {
                    resultado.PBA__c = Decimal.valueOf( pba.replace(',','.') );
                }
                if(!String.isBlank(clv5))
                {
                    resultado.CLV5__c = Decimal.valueOf(clv5.replace(',','.'));
                }
                if(!String.isBlank(clv10))
                {
                    resultado.CLV10__c = Decimal.valueOf(clv10.replace(',','.'));
                }
				if(!String.isBlank(gp))
                {
                    resultado.gp__c = Decimal.valueOf(gp.replace(',','.'));
                }
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Tramo__c con tramo: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    private static Tramo__c crearTramoSFConEscaladoNS(EntidadesWSClientesYOfertas.Escalado tramo, Quote quoteNS)
    {
        Tramo__c resultado = null;
        try
        {
            if(tramo != null)
            {
                resultado = new Tramo__c();
                if(quoteNS != null)
                {
                    resultado.Presupuesto__r = quoteNS;
                }
                resultado.RecordTypeId = Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_escalado').Id;
                resultado.Name = tramo.tramo;
                if( !String.isBlank(tramo.porcentajeDesde) )
                {
                    resultado.Porcentaje_desde__c = Decimal.valueOf( tramo.porcentajeDesde.replace(',','.') );
                }
                if( !String.isBlank(tramo.porcentajeHasta) )
                {
                    resultado.Porcentaje_hasta__c = Decimal.valueOf( tramo.porcentajeHasta.replace(',','.') );
                }
                if( !String.isBlank(tramo.consumoDesdeL) )
                {
                    resultado.Consumo_desde_L__c = Decimal.valueOf( tramo.consumoDesdeL.replace(',','.') );
                }
                if( !String.isBlank(tramo.consumoHastaL) )
                {
                    resultado.Consumo_hasta_L__c = Decimal.valueOf( tramo.consumoHastaL.replace(',','.') );
                }
                if( !String.isBlank(tramo.consumoDesdeKg) )
                {
                    resultado.Consumo_desde_Kg__c = Decimal.valueOf( tramo.consumoDesdeKg.replace(',','.') );
                }
                if( !String.isBlank(tramo.consumoHastaKg) )
                {
                    resultado.Consumo_hasta_Kg__c = Decimal.valueOf( tramo.consumoHastaKg.replace(',','.') );
                }
                if( !String.isBlank(tramo.dtoL) )
                {
                    resultado.Dto_L__c = Decimal.valueOf( tramo.dtoL.replace(',','.') );
                }
                if( !String.isBlank(tramo.dtoKg) )
                {
                    resultado.Dto_Kg__c = Decimal.valueOf( tramo.dtoKg.replace(',','.') );
                }
                if( !String.isBlank(tramo.duracionDTO) )
                {
                    resultado.Duracion_descuento__c = Decimal.valueOf( tramo.duracionDTO.replace(',','.') );
                }
                if( !String.isBlank(tramo.precioHoyL) )
                {
                    resultado.Precio_HOY_L__c = Decimal.valueOf( tramo.precioHoyL.replace(',','.') );
                }
                if( !String.isBlank(tramo.precioHoyK) )
                {
                    resultado.Precio_HOY_Kg__c = Decimal.valueOf( tramo.precioHoyK.replace(',','.') );
                }
                if( !String.isBlank(tramo.primaServiciosA) )
                {
                    resultado.Prima_servicios_A__c = Decimal.valueOf( tramo.primaServiciosA.replace(',','.') );
                }
                if(!String.isBlank(tramo.clv5))
                {
                    resultado.CLV5__c = Decimal.valueOf(tramo.clv5.replace(',','.'));
                }
                if(!String.isBlank(tramo.clv10))
                {
                    resultado.CLV10__c = Decimal.valueOf(tramo.clv10.replace(',','.'));
                }if(!String.isBlank(tramo.gp))
                {
                    resultado.gp__c = Decimal.valueOf(tramo.gp.replace(',','.'));
                }
                if( !String.isBlank(tramo.pba) )
                {
                    resultado.PBA__c = Decimal.valueOf(tramo.pba);
                }
            }
        }
        catch(Exception ex)
        {
            System.debug( 'Excepción al crear Escalado__c con tramo: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }
    //dir1 es la guardada y dir2 la que se envia desde la app
    public static Direcci_n_de_entrega__c gestionarDirecciones(Direcci_n_de_entrega__c dir1, Direcci_n_de_entrega__c dir2)
    {
        Direcci_n_de_entrega__c resultado = null;
        Boolean continuar = false;
        try
        {
            if(dir1 != null && dir2 != null)
            {
                resultado = new Direcci_n_de_entrega__c();
                if( String.isBlank(dir1.Direccion__c) )
                {
                    if( String.isBlank(dir2.Direccion__c) )
                    {
                        continuar = true;
                    }
                    else
                    {
                        continuar = true;
                        resultado.Direccion__c = dir2.Direccion__c;
                    }
                }
                else
                {
                    if( String.isBlank(dir2.Direccion__c) )
                    {
                        continuar = true;
                        resultado.Direccion__c = dir1.Direccion__c;
                    }
                    else
                    {
                        continuar = dir1.Direccion__c.Equals(dir2.Direccion__c);
                        if(continuar)
                        {
                            resultado.Direccion__c = dir1.Direccion__c;
                        }
                    }
                }
                if(continuar)
                {
                    if( String.isBlank(dir1.Poblacion__c) )
                    {
                        if( String.isBlank(dir2.Poblacion__c) )
                        {
                            continuar = true;
                        }
                        else
                        {
                            continuar = true;
                            resultado.Poblacion__c = dir2.Poblacion__c;
                        }
                    }
                    else
                    {
                        if( String.isBlank(dir2.Poblacion__c) )
                        {
                            continuar = true;
                            resultado.Poblacion__c = dir1.Poblacion__c;
                        }
                        else
                        {
                            continuar = dir1.Poblacion__c.Equals(dir2.Poblacion__c);
                            if(continuar)
                            {
                                resultado.Poblacion__c = dir1.Poblacion__c;
                            }
                        }
                    }
                    if(continuar)
                    {
                        if( String.isBlank(dir1.Codigo_Postal__c) )
                        {
                            if( String.isBlank(dir2.Codigo_Postal__c) )
                            {
                                continuar = true;
                            }
                            else
                            {
                                continuar = true;
                                resultado.Codigo_Postal__c = dir2.Codigo_Postal__c;
                            }
                        }
                        else
                        {
                            if( String.isBlank(dir2.Codigo_Postal__c) )
                            {
                                continuar = true;
                                resultado.Codigo_Postal__c = dir1.Codigo_Postal__c;
                            }
                            else
                            {
                                continuar = dir1.Codigo_Postal__c.Equals(dir2.Codigo_Postal__c);
                                if(continuar)
                                {
                                    resultado.Codigo_Postal__c = dir1.Codigo_Postal__c;
                                }
                            }
                        }
                        if(continuar)
                        {
                            if( String.isBlank(dir1.Provincia__c) )
                            {
                                if( String.isBlank(dir2.Provincia__c) )
                                {
                                    continuar = true;
                                }
                                else
                                {
                                    continuar = true;
                                    resultado.Provincia__c = dir2.Provincia__c;
                                }
                            }
                            else
                            {
                                if( String.isBlank(dir2.Provincia__c) )
                                {
                                    continuar = true;
                                    resultado.Provincia__c = dir1.Provincia__c;
                                }
                                else
                                {
                                    continuar = dir1.Provincia__c.Equals(dir2.Provincia__c);
                                    if(continuar)
                                    {
                                        resultado.Provincia__c = dir1.Provincia__c;
                                    }
                                }
                            }
                            if(continuar)
                            {
                                if( String.isBlank(dir1.Actividad_1__c) )
                                {
                                    if( String.isBlank(dir2.Actividad_1__c) )
                                    {
                                        continuar = true;
                                    }
                                    else
                                    {
                                        continuar = true;
                                        resultado.Actividad_1__c = dir2.Actividad_1__c;
                                    }
                                }
                                else
                                {
                                    if( String.isBlank(dir2.Actividad_1__c) )
                                    {
                                        continuar = true;
                                        resultado.Actividad_1__c = dir1.Actividad_1__c;
                                    }
                                    else
                                    {
                                        //Cambios rfernandez (25/01/2017) //Hay caracteres raros en las picklist. Los elimino para comparar los dos strings
                                        String actividadGuardada =  eliminarCaracteresRaros(dir1.Actividad_1__c);
                                        String nuevaActividad =  eliminarCaracteresRaros(dir2.Actividad_1__c);

                                        continuar = actividadGuardada.Equals(nuevaActividad);
                                        if(continuar)
                                        {
                                            resultado.Actividad_1__c = dir1.Actividad_1__c;
                                        }
                                    }
                                }
                                if(continuar)
                                {
                                    if( String.isBlank(dir1.Actividad_2__c) )
                                    {
                                        if( String.isBlank(dir2.Actividad_2__c) )
                                        {
                                            continuar = true;
                                        }
                                        else
                                        {
                                            continuar = true;
                                            resultado.Actividad_2__c = dir2.Actividad_2__c;
                                        }
                                    }
                                    else
                                    {
                                        if( String.isBlank(dir2.Actividad_2__c) )
                                        {
                                            continuar = true;
                                            resultado.Actividad_2__c = dir1.Actividad_2__c;
                                        }
                                        else
                                        {
                                            continuar = dir1.Actividad_2__c.Equals(dir2.Actividad_2__c);
                                            if(continuar)
                                            {
                                                resultado.Actividad_2__c = dir1.Actividad_2__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                if(!continuar)     // si se ha llegado hasta aquí con continuar = false es porque no se cumplen todos los requisitos, así que se deja a null el resultado
                {
                    resultado = null;
                }
            }
        }
        catch(Exception ex)
        {
            resultado = null;
            System.debug( 'Excepción al gestionarDirecciones: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber() );
        }
        return resultado;
    }

    //El siguiente método se encarga de eliminar caracteres raros de un string para comparar luego 2 strings
    public static string eliminarCaracteresRaros(String palabra)
    {
        palabra = palabra.trim();
        palabra = palabra.replaceAll('[^\\x00-\\x7F]', '');
        palabra = palabra.replaceAll(' ', '');

        return palabra;
    }

    @future (callout=true)
    private static void generarPDFOferta(List<String> listIdsQuotes, String contactoId, Boolean isNew, Boolean envioDeEmail, String direccionEnvioCorreo)
    {
        System.debug( UserInfo.getProfileId() + '    '+UserInfo.getUserEmail());
        Attachment attach = null;
        PageReference pagePDF = null;
        Blob contenido;
        List<Attachment> listAttachs = new List<Attachment>();
        try
        {
            List<Quote> listQuotes = [SELECT Id, Name, RecordTypeId, Enviar_email__c FROM Quote WHERE Id IN: listIdsQuotes];
            String usuarioId = UserInfo.getUserId();
            List<User> usuario = [SELECT Id, Name, MobilePhone FROM User WHERE Id=: usuarioId];

            for(Quote quote : listQuotes)
            {
                System.debug('test40 '+quote); 
                if(quote != null) 
                {
                    // recuperar pdf
                    if(quote.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id)
                    {
                        pagePDF = Page.OfertaModularPage;
                        //pagePDF = Page.OfertaModularPDFTest;
                    }
                    else
                    {
                        if(quote.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id)
                        {
                            pagePDF = Page.OfertaPersonalizadaPDF;
                        }
                        else
                        {
                            if(quote.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id)
                            {
                                pagePDF = Page.OfertaEstandarPDF;
                            }
                        }
                    }

                    if(pagePDF != null)
                    {
                        System.debug('test41 '+pagePDF);
                        System.debug('test42 '+quote.Id);
                        pagePDF.getParameters().put('idOferta', quote.Id);
                        System.debug('La url con el parametro es'+pagePDF);
                        if( !test.isRunningTest() )
                        { 
                            System.debug('Puedo ver el get content '+pagePDF.getContent());
                            contenido = pagePDF.getContent();
                        }
                        else
                        {
                            contenido = blob.valueOf('TestString');
                        }
                        attach = new Attachment(name = (quote.Name + '.pdf'), ParentId = quote.Id);
                        attach.IsPrivate = false;
                        attach.body = contenido;

                        if(attach != null && isNew)
                        {
                            listAttachs.add(attach);
                        }

                        //Se envía un email al cliente con el pdf de la oferta si está marcado el check
                        //MODIFICADO POR gserrano 10/12/2018 para usar el email pasado al método como parámetro en lugar del asociado al contacto
                       if((quote.Enviar_email__c || envioDeEmail == true) && String.isNotBlank(direccionEnvioCorreo))
                        {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                            efa.setFileName(quote.Name + '.pdf');
                            efa.setBody(contenido);
                            
                            //MODIFICADO POR gserrano 10/12/2018 para usar el email pasado al método como parámetro en lugar del asociado al contacto
                            
                            String[] toAddresses = new List<String>{direccionEnvioCorreo};
                            toAddresses.add(UserInfo.getUserEmail());
                            String subject = Label.Asunto;
                            String body =  Label.Cuerpo_del_email + '\n\n' +
                            UserInfo.getName() + '\n' + 
                            'Delegado de Zona \n' + 
                            (String.isEmpty(usuario[0].MobilePhone) ? '' : 'Telf: (+34) ' + usuario[0].MobilePhone + '\n') +  
                            'Email: ' + UserInfo.getUserEmail();


                            email.setToAddresses( toAddresses );
                            email.setReplyTo(UserInfo.getUserEmail());
                            email.setSenderDisplayName(UserInfo.getName());
                            email.setSubject( subject );                        
                            email.setPlainTextBody( body );
                            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

                            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                        }    
                    }
                }
            }

            if(!listAttachs.isEmpty())
            {
                Database.insert(listAttachs);
            }           
        }
        catch(Exception ex)
        {
            //System.debug('Excepción al generar PDF de la oferta: ' + ex.getMessage() + 'Line: ' +  ex.getLineNumber());
            LogUtil.crearLog('Error al generar el PDF - Message: ' + ex.getMessage(), 'WSDatosOfertas', 'Oferta', 'Error', true);
            LogUtil.guardarLog();   
        }
    }

    global class PeticionEnvioOferta
    {
        public EntidadesWSClientesYOfertas.DatosCliente datosCliente {get; set;}
        public List<Oportunidad> oportunidades {get; set;}
    }

    public class Oportunidad
    {
        public String identificador {get; set;}     // identificador de la oportunidad
        public String nombre {get; set;}
        public String prescriptor {get; set;}     // información del prescriptor del cliente
        public String canal {get; set;}     // descripción del canal del cliente
        public String fechaCreacion {get; set;}     // formato yyyyMMdd
        public List<EntidadesWSClientesYOfertas.Oferta> ofertas {get; set;}

        public Oportunidad(String pId, String pNombre, String pPrescriptor, String pCanal, String pFechaCreacion, List<EntidadesWSClientesYOfertas.Oferta> pListaofertas)
        {
            this.identificador = (pId == null ? '' : pId);
            this.nombre = (pNombre == null ? '' : pNombre);
            this.prescriptor = (pPrescriptor == null ? '' : pPrescriptor);
            this.canal = (pCanal == null ? '' : pCanal);
            this.fechaCreacion = (pFechaCreacion == null ? '' : pFechaCreacion);
            if(pListaofertas == null)
            {
                this.ofertas = new List<EntidadesWSClientesYOfertas.Oferta>();
            }
            else
            {
                this.ofertas = new List<EntidadesWSClientesYOfertas.Oferta>(pListaofertas);
            }
        }
    }

    public class Respuesta
    {
        public Resultado resultado {get; set;}
        public List<OfertaIds> ofertas {get; set;}

        public Respuesta()
        {
            resultado = new Resultado();
            ofertas = new List<OfertaIds>();
        }
    }

    public class Resultado
    {
        public String codigo {get; set;}
        public String texto {get; set;}

        public Resultado()
        {
            this.codigo = '';
            this.texto = '';
        }
    }

    public class OfertaIds
    {
        public String idInternoOferta {get; set;}
        public String idSalesForceOferta {get; set;}
        public String idSalesForceOportunidad {get; set;}
        public String nombreOportunidad {get; set;}
        public String numPresupuesto {get; set;}
        public String idSalesForceCliente {get; set;}

        public OfertaIds(String pIdInternoOferta, String pIdSFOferta, String pIdSFOportunidad, String pNombreOportunidad, String pNumPresupuesto, String pIdSFCliente)
        {
            this.idInternoOferta = pIdInternoOferta;
            this.idSalesForceOferta = pIdSFOferta;
            this.idSalesForceOportunidad = pIdSFOportunidad;
            this.nombreOportunidad = pNombreOportunidad;
            this.numPresupuesto = pNumPresupuesto;
            this.idSalesforceCliente = pIdSFCliente;
        }
    }
}