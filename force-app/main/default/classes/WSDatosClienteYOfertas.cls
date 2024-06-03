@RestResource(urlMapping='/DatosClienteYOfertas/*')
global with sharing class WSDatosClienteYOfertas {

    @HttpPost
    webservice static String getDatosCliente(PeticionDatosBusqueda peticion)
    {
        System.debug('JSON: ' + peticion);

        Respuesta r = new Respuesta();
        RespuestaSoloIds r1 = new RespuestaSoloIds();
        String jRespuesta = '';

        DatosBusqueda peticionDatos;
        List<Contact> listaContactos;
        Contact contacto;
        Map<String,Account> mapaCuentas;
        Account cuenta = null;
        Set<Id> setIdsOfertas;
        Set<Id> setIdsOfertasModulares;
        Set<Id> setIdsOfertasPersonalizadas;
        Set<String> setIdsOportunidadesTotales = null;
        Set<String> setIdsOportunidades = null;
        List<OpportunityContactRole> listIdsOportunidadesTotales;
        List<String> listIdsOportunidades;
        List<Quote> listaQuotes;
        List<Quote> listaQuotesTotales;
        Map<String, List<EntidadesWSClientesYOfertas.Oferta>> mapOportunidadOfertas;
        Map<String, List<OfertaId>> mapOportunidadOfertas1;
        Map<Id, String> mapNamesOportunidad;
        List<EntidadesWSClientesYOfertas.Oferta> listOfertasAux;
        List<OfertaId> listOfertasAux1;
        List<Tramo__c> listaTramos;
        Map<String, List<EntidadesWSClientesYOfertas.Tramo>> mapQuoteTramos;
        List<EntidadesWSClientesYOfertas.Tramo> listTramosAux;
        List<EntidadesWSClientesYOfertas.Tramo> listTramosNormal;
        List<EntidadesWSClientesYOfertas.Escalado> listTramosEscalado;
        Map<String, List<EntidadesWSClientesYOfertas.Escalado>> mapQuoteEscalado;
        List<EntidadesWSClientesYOfertas.Escalado> listEscaladoAux;
        List<Equipo_actual__c> listEquiposActuales;
        Map<Id, List<EntidadesWSClientesYOfertas.Equipo>> mapQuoteEquipos;
        List<EntidadesWSClientesYOfertas.Equipo> listEquiposAux;
        List<EntidadesWSClientesYOfertas.Equipo> listaEquipos;
        List<Energia_Actual__c> listEnergiasActuales;
        Map<Id, List<EntidadesWSClientesYOfertas.Energia>> mapQuoteEnergias;
        List<EntidadesWSClientesYOfertas.Energia> listEnergiasAux;
        List<EntidadesWSClientesYOfertas.Energia> listaEnergias;
        List<Pack_de_servicio__c> listPacksServicioActuales;
        Map<Id, EntidadesWSClientesYOfertas.Pack> mapQuotePacks;
        EntidadesWSClientesYOfertas.Pack pack;
        List<Deposito__c> listDepositos;
        Map<Id, List<EntidadesWSClientesYOfertas.Deposito>> mapQuoteDepositos;
        List<EntidadesWSClientesYOfertas.Deposito> listDepositosAux;
        List<EntidadesWSClientesYOfertas.Deposito> listaDepositos;
        List<Equipo_ajuste__c> listEquiposAjuste;
        Map<Id, List<EntidadesWSClientesYOfertas.EquipoAjuste>> mapQuoteEquiposAjuste;
        List<EntidadesWSClientesYOfertas.EquipoAjuste> listaEquiposAjusteAux;
        List<EntidadesWSClientesYOfertas.EquipoAjuste> listaEquiposAjuste;
        List<Direcci_n_de_entrega__c> listaDireccionesEntregaTotales;
        List<Direcci_n_de_entrega__c> listaDireccionesEntrega;        
        Direcci_n_de_entrega__c direccionEntregaAux;
        Boolean encontradaDir;
        Map<String,Opportunity> mapaOportunidadesSinOfertas;
        List<EntidadesWSClientesYOfertas.Energia> listaEnergiasAux;
        Map<String,String> mapaOportunidadIdPrescriptorId;
        ClienteYOportunidadesIds clienteYOportunidadesIdsAux;
        ClienteYOportunidades clienteYOportunidadesAux;
        Map<String,Opportunity> mapaOportunidadesTotales;
        Map<String,Opportunity> mapaOportunidades;      
        List<OpportunityPartner> listaOpportunityPartnerTotales;
        List<OpportunityPartner> listaOpportunityPartner;
        Map<String,List<Direcci_n_de_entrega__c>> mapaCuentaIdDireccionesEntrega;
        Map<String,Set<String>> mapaContactosIdsOportunidadesIds;
        Map<String, List<OpportunityPartner>> mapaOportunidadesIdsPartners;
        Map<String,List<Quote>> mapaOportunidadesIdsQuotes;
        Map<String,List<EntidadesWSClientesYOfertas.Energia>> mapaOportunidadesIdsEnergiasNS;
        List<OpportunityPartner> listaPartnersAux;
        String prescriptorId;
        try
        {
            if(peticion != null && peticion.datosBusqueda != null )
            {
                peticionDatos = peticion.datosBusqueda;
                
                if( String.isNotBlank(peticionDatos.nombre) || String.isNotBlank(peticionDatos.apellido) || String.isNotBlank(peticionDatos.compania) ||
                    String.isNotBlank(peticionDatos.telefonoMovil) || String.isNotBlank(peticionDatos.telefono) )
                {
                    /*Cambios rfernandez (20/02/2017) Se ha modificado la query para que sea SOSL de forma que no importe si el registro está guardado
                    * con o sin tilde
                    (23/05/2017) Se han añadido los asteriscos para que busque en los campos que contengan ese valor de string
                    */
                    String query = 'FIND {';
                    if(String.isNotBlank(peticionDatos.nombre))
                    {
                        String peticionDatosNombre = limpiarSosl(peticionDatos.nombre);
                        query += '*' + peticionDatosNombre + '*' +', ';
                    }    
                    if(String.isNotBlank(peticionDatos.apellido))
                    {
                        String peticionDatosApellido = limpiarSosl(peticionDatos.apellido);
                        query += '*' + peticionDatosApellido + '*' +', ';
                    }
                    if(String.isNotBlank(peticionDatos.compania))
                    {
                        String peticionDatosCompania = limpiarSosl(peticionDatos.compania);
                        query += '*' + peticionDatosCompania + '*' +', ';
                    }
                    if(String.isNotBlank(peticionDatos.telefonoMovil))
                    {
                        query += '*' + peticionDatos.telefonoMovil + '*' +', ';
                    }
                    if(String.isNotBlank(peticionDatos.telefono))
                    {
                        query += '*' + peticionDatos.telefono + '*' +', ';
                    }
                    query = query.substringBeforeLast(', ');                
                    query += '} IN ALL FIELDS RETURNING Contact (Id, FirstName, LastName, Phone, MobilePhone, Fax, Email, LeadSource, DNI__c, AccountId ORDER BY Id)';
                    
                    //(11/01/2018)Limpiamos las comillas simple porque sino casca la query
                    query = query.replaceAll('\'', '');
                    System.debug('query: '+query);
                    
                    List<List<sObject>> results = search.query(query);
                    System.debug('results: '+results);

                    for(List<SObject> listaElementos : results)
                    {
                        if(listaElementos != null && !listaElementos.isEmpty())
                        {
                            if(listaElementos[0].getSObjectType() == Contact.sObjectType)
                            {
                                listaContactos = listaElementos;
                            }
                        }
                    }
                    //Fin cambios rfernandez
                }

                if(listaContactos == null || listaContactos.isEmpty())
                {
                    r1.resultado.codigo = '503';
                    r1.resultado.texto = Label.WSError_503 
                                        + (String.isNotBlank(peticionDatos.nombre) ? ' Nombre: ' + peticionDatos.nombre + '.' : '') 
                                        + (String.isNotBlank(peticionDatos.apellido) ? ' Apellido: ' + peticionDatos.apellido + '.' : '')
                                        + (String.isNotBlank(peticionDatos.compania) ? ' Compañía: ' + peticionDatos.compania + '.' : '')
                                        + (String.isNotBlank(peticionDatos.telefono) ? ' Teléfono: ' + peticionDatos.telefono + '.' : '')
                                        + (String.isNotBlank(peticionDatos.telefonoMovil) ? ' Teléfono móvil: ' + peticionDatos.telefonoMovil + '.' : '');
                    LogUtil.crearLog(r1.resultado.texto, 'Errores NewSales', 'WSDatosClienteYOfertas', 'Error', true);                    
                }
                else
                {
                    System.debug('Dentro del else ');
                    // se sacan fuera del for las queries para poder hacer búsquedas que devuelvan varios contactos
                    List<String> idsCuentas = new List<String>();
                    List<String> idsContactos = new List<String>();
                    for(Contact c: listaContactos)
                    {
                        idsCuentas.add(c.AccountId);
                        idsContactos.add(c.Id);
                    }

                    mapaCuentas = new Map <String,Account>([select Id, Name, ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Actividad__c, Sub_actividad__c, 
                                                        Id_fiscal__c, Calle_Facturacion__c, Poblacion_Facturacion__c, Provincia__c, Codigo_Postal__c,
                                                        Prescriptor_Cuenta__r.Name, FirstName, Lastname, Phone, PersonMobilePhone, Fax, E_mail__c
                                                        from Account where Id IN: idsCuentas]);

                    listaDireccionesEntregaTotales = [select Id, Direccion__c, Poblacion__c, Codigo_Postal__c, Provincia__c, Actividad_1__c, Actividad_2__c, Cuenta__c
                                                        from Direcci_n_de_entrega__c where Cuenta__c IN: idsCuentas order by CreatedDate desc];
                    mapaCuentaIdDireccionesEntrega = new Map<String,List<Direcci_n_de_entrega__c>>();
                    List<Direcci_n_de_entrega__c> listaDireccionesAux;
                    for(Direcci_n_de_entrega__c dir : listaDireccionesEntregaTotales)
                    {
                        if(mapaCuentaIdDireccionesEntrega.containsKey(dir.Cuenta__c))
                        {
                            mapaCuentaIdDireccionesEntrega.get(dir.Cuenta__c).add(dir);
                        }
                        else
                        {
                            listaDireccionesAux = new List<Direcci_n_de_entrega__c>();
                            listaDireccionesAux.add(dir);
                            mapaCuentaIdDireccionesEntrega.put(dir.Cuenta__c, listaDireccionesAux);
                        }
                    }

                    listIdsOportunidadesTotales = [select OpportunityId, ContactId from OpportunityContactRole where ContactId IN: idsContactos and Opportunity.StageName != 'Cerrada ganada' 
                                                    and Opportunity.StageName != 'Cerrada perdida' and Opportunity.StageName != 'Caducada' order by Opportunity.CreatedDate desc];
                    mapaContactosIdsOportunidadesIds = new Map<String,Set<String>>();
                    Set<String> listaOportunidadesIdsAux;
                    setIdsOportunidadesTotales = new Set<String>();

                    System.debug('##listIdsOportunidadesTotales: '+listIdsOportunidadesTotales);
                    for(OpportunityContactRole ocr : listIdsOportunidadesTotales)
                    {
                        if(mapaContactosIdsOportunidadesIds.containsKey(ocr.ContactId))
                        {
                            mapaContactosIdsOportunidadesIds.get(ocr.ContactId).add(ocr.OpportunityId);
                        }
                        else
                        {
                            listaOportunidadesIdsAux = new Set<String>();
                            listaOportunidadesIdsAux.add(ocr.OpportunityId);
                            mapaContactosIdsOportunidadesIds.put(ocr.ContactId, listaOportunidadesIdsAux);
                        }
                        setIdsOportunidadesTotales.add(ocr.OpportunityId);
                    }
        
                    mapaOportunidadesTotales = new Map<String,Opportunity>([select Id, Name, LeadSource, CreatedDate, AccountId, (select Name from Quotes where ContractId = null), 
                                                                            (select Id, Name, Consumo__c, Consumo_KWH__c, Consumo_KgCo2__c, Consumo_L_Primagas__c, 
                                                                            Unidad_consumo__c, Consumo_KWH_Primagas__c, Consumo_Kg_Primagas__c, Consumo_KgCO2_Primagas__c,
                                                                            Precio__c, Unidad_precio__c, Proveedor__r.Name, Rendimiento__c, Cambio__c, Presupuesto__c, 
                                                                            Importe_situacion_actual__c, Tipo_energia__c from Energias_Actuales__r)
                                                                            from Opportunity where Id = :setIdsOportunidadesTotales order by CreatedDate desc]);
                    System.debug('##mapaOportunidadesTotales: '+mapaOportunidadesTotales);

                    listaOpportunityPartnerTotales = [select Id, AccountToId, OpportunityId, Role from OpportunityPartner where OpportunityId = :setIdsOportunidadesTotales
                                                        order by Opportunity.CreatedDate desc];
                    mapaOportunidadesIdsPartners = new Map<String,List<OpportunityPartner>>();
                    for(OpportunityPartner partner : listaOpportunityPartnerTotales)
                    {
                        if(mapaOportunidadesTotales!=null && mapaOportunidadesTotales.size()>0 && mapaOportunidadesTotales.containsKey(partner.OpportunityId) && 
                            partner.AccountToId != mapaOportunidadesTotales.get(partner.OpportunityId).AccountId)
                        {
                            if(mapaOportunidadesIdsPartners.containsKey(partner.OpportunityId))
                            {
                                mapaOportunidadesIdsPartners.get(partner.OpportunityId).add(partner);
                            }
                            else
                            {
                                listaPartnersAux = new List<OpportunityPartner>();
                                listaPartnersAux.add(partner);
                                mapaOportunidadesIdsPartners.put(partner.OpportunityId, listaPartnersAux);
                            }
                        }
                    }

                    listaQuotesTotales = [select Id, OpportunityId, Opportunity.Name, Status, QuoteNumber, CreatedDate, RecordTypeId, Notas__c from Quote where OpportunityId = :setIdsOportunidadesTotales 
                                            and ContractId = null and (RecordTypeId =: Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id or RecordTypeId =: Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id
                                            or RecordTypeId =: Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id) order by CreatedDate desc];
                    mapaOportunidadesIdsQuotes = new Map<String,List<Quote>>();
                    List<Quote> listaQuotesAux;
                    for(Quote q : listaQuotesTotales)
                    {
                        if(mapaOportunidadesIdsQuotes.containsKey(q.OpportunityId))
                        {
                            mapaOportunidadesIdsQuotes.get(q.OpportunityId).add(q);
                        }
                        else
                        {
                            listaQuotesAux = new List<Quote>();
                            listaQuotesAux.add(q);
                            mapaOportunidadesIdsQuotes.put(q.OpportunityId, listaQuotesAux);
                        }
                    }

                    for(Integer i=0; i<listaContactos.size(); i++)
                    {
                        contacto = listaContactos.get(i);
                        System.debug('##contacto: ' + contacto);
                        clienteYOportunidadesIdsAux = new ClienteYOportunidadesIds();
                        clienteYOportunidadesAux = new ClienteYOportunidades();
                        if(contacto.AccountId != null)
                        {
                            System.debug('mapaCuentas: ' + mapaCuentas);
                            if(mapaCuentas != null && !mapaCuentas.isEmpty() && mapaCuentas.containsKey(contacto.AccountId))
                            {
                                cuenta = mapaCuentas.get(contacto.AccountId);
                            }
                        }
                        
                        if(cuenta != null)
                        {
                            clienteYOportunidadesAux.datosCliente.identificador = (cuenta.Id == null ? '' : cuenta.Id);
                            clienteYOportunidadesAux.datosCliente.calleFacturacion = (cuenta.Calle_Facturacion__c == null ? '' : cuenta.Calle_Facturacion__c.replace('"',''));
                            clienteYOportunidadesAux.datosCliente.poblacionFacturacion = (cuenta.Poblacion_Facturacion__c == null ? '' : cuenta.Poblacion_Facturacion__c.replace('"',''));
                            clienteYOportunidadesAux.datosCliente.cpFacturacion = (cuenta.Codigo_Postal__c == null ? '' : cuenta.Codigo_Postal__c.replace('"',''));
                            clienteYOportunidadesAux.datosCliente.provinciaFacturacion = (cuenta.Provincia__c == null ? '' : cuenta.Provincia__c.replace('"',''));

                            // inicializo los campos a rellenar con la dirección de entrega a '' por si no entrasen en ningún if
                            clienteYOportunidadesAux.datosCliente.calle = '';
                            clienteYOportunidadesAux.datosCliente.provincia = '';
                            clienteYOportunidadesAux.datosCliente.cp = '';
                            clienteYOportunidadesAux.datosCliente.poblacion = '';
                            clienteYOportunidadesAux.datosCliente.actividad = '';
                            clienteYOportunidadesAux.datosCliente.subactividad = '';
                            clienteYOportunidadesAux.datosCliente.idDireccion = '';

                            // recuperación de la dirección de entrega
                            if(mapaCuentaIdDireccionesEntrega != null && !mapaCuentaIdDireccionesEntrega.isEmpty() && mapaCuentaIdDireccionesEntrega.containsKey(cuenta.Id))
                            {
                                listaDireccionesEntrega = mapaCuentaIdDireccionesEntrega.get(cuenta.Id);
                            }
                            
                            if(cuenta.ShippingStreet == null || cuenta.ShippingPostalCode == null || cuenta.ShippingState == null || cuenta.ShippingCity == null 
                                    || cuenta.Actividad__c == null || cuenta.Sub_actividad__c == null )
                            {
                                    // se recupera la primera dirección de la lista que debe coincidir con la de fecha de creación más reciente
                                if(listaDireccionesEntrega != null && !listaDireccionesEntrega.isEmpty())
                                {
                                    direccionEntregaAux = listaDireccionesEntrega[0];
                                    System.debug('##1 Direccion de entrega: '+ direccionEntregaAux);
                                    if(direccionEntregaAux != null)
                                    {
                                        clienteYOportunidadesAux.datosCliente.calle = (direccionEntregaAux.Direccion__c == null ? '' : direccionEntregaAux.Direccion__c.replace('"',''));
                                        clienteYOportunidadesAux.datosCliente.provincia = (direccionEntregaAux.Provincia__c == null ? '' : direccionEntregaAux.Provincia__c.replace('"',''));
                                        clienteYOportunidadesAux.datosCliente.cp = (direccionEntregaAux.Codigo_Postal__c == null ? '' : direccionEntregaAux.Codigo_Postal__c.replace('"',''));
                                        clienteYOportunidadesAux.datosCliente.poblacion = (direccionEntregaAux.Poblacion__c == null ? '' : direccionEntregaAux.Poblacion__c.replace('"',''));
                                        clienteYOportunidadesAux.datosCliente.actividad = (direccionEntregaAux.Actividad_1__c == null ? '' : direccionEntregaAux.Actividad_1__c.replace('"',''));

                                        clienteYOportunidadesAux.datosCliente.actividad = eliminarCaracterRaro(clienteYOportunidadesAux).datosCliente.actividad;

                                        clienteYOportunidadesAux.datosCliente.subactividad = (direccionEntregaAux.Actividad_2__c == null ? '' : direccionEntregaAux.Actividad_2__c.replace('"',''));
                                        clienteYOportunidadesAux.datosCliente.idDireccion = (direccionEntregaAux.Id == null ? '' : direccionEntregaAux.Id);
                                    }
                                }
                            }
                            else
                            {
                                // se comprueba si existe una dirección que coincida con la del cliente
                                if(listaDireccionesEntrega != null && !listaDireccionesEntrega.isEmpty())
                                {
                                    encontradaDir = false;
                                    for(Direcci_n_de_entrega__c dir : listaDireccionesEntrega)
                                    {
                                        if(dir != null && dir.Direccion__c == cuenta.ShippingStreet && dir.Poblacion__c == cuenta.ShippingCity 
                                                && dir.Codigo_Postal__c == cuenta.ShippingPostalCode && dir.Provincia__c == cuenta.ShippingState
                                                && dir.Actividad_1__c == cuenta.Actividad__c && dir.Actividad_2__c == cuenta.Sub_actividad__c)
                                        {
                                                clienteYOportunidadesAux.datosCliente.calle = (dir.Direccion__c == null ? '' : dir.Direccion__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.provincia = (dir.Provincia__c == null ? '' : dir.Provincia__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.cp = (dir.Codigo_Postal__c == null ? '' : dir.Codigo_Postal__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.poblacion = (dir.Poblacion__c == null ? '' : dir.Poblacion__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.actividad = (dir.Actividad_1__c == null ? '' : dir.Actividad_1__c.replace('"',''));

                                                clienteYOportunidadesAux.datosCliente.actividad = eliminarCaracterRaro(clienteYOportunidadesAux).datosCliente.actividad;

                                                clienteYOportunidadesAux.datosCliente.subactividad = (dir.Actividad_2__c == null ? '' : dir.Actividad_2__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.idDireccion = (dir.Id == null ? '' : dir.Id);
                                                encontradaDir = true;
                                                break;
                                        }
                                    }
                                    if(!encontradaDir)
                                    {
                                        //System.debug('##4 No Encontrada ');
                                        direccionEntregaAux = listaDireccionesEntrega[0];
                                        //System.debug('##5 Direccion de entrega: '+ direccionEntregaAux);

                                        if(direccionEntregaAux != null)
                                        {
                                                clienteYOportunidadesAux.datosCliente.calle = (direccionEntregaAux.Direccion__c == null ? '' : direccionEntregaAux.Direccion__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.provincia = (direccionEntregaAux.Provincia__c == null ? '' : direccionEntregaAux.Provincia__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.cp = (direccionEntregaAux.Codigo_Postal__c == null ? '' : direccionEntregaAux.Codigo_Postal__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.poblacion = (direccionEntregaAux.Poblacion__c == null ? '' : direccionEntregaAux.Poblacion__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.actividad = (direccionEntregaAux.Actividad_1__c == null ? '' : direccionEntregaAux.Actividad_1__c.replace('"',''));
                                               
                                                clienteYOportunidadesAux.datosCliente.actividad = eliminarCaracterRaro(clienteYOportunidadesAux).datosCliente.actividad;

                                                clienteYOportunidadesAux.datosCliente.subactividad = (direccionEntregaAux.Actividad_2__c == null ? '' : direccionEntregaAux.Actividad_2__c.replace('"',''));
                                                clienteYOportunidadesAux.datosCliente.idDireccion = (direccionEntregaAux.Id == null ? '' : direccionEntregaAux.Id);
                                        }
                                    }
                                }
                                //System.debug('##2  clienteYOportunidadesAux.datosCliente.actividad: '+  clienteYOportunidadesAux.datosCliente.actividad);

                                    /*r.datosCliente.calle = (cuenta.ShippingStreet == null ? '' : cuenta.ShippingStreet);
                                    r.datosCliente.provincia = (cuenta.ShippingState == null ? '' : cuenta.ShippingState);
                                    r.datosCliente.cp = (cuenta.ShippingPostalCode == null ? '' : cuenta.ShippingPostalCode);
                                    r.datosCliente.poblacion = (cuenta.ShippingCity == null ? '' : cuenta.ShippingCity);  
                                    r.datosCliente.actividad = (cuenta.Actividad__c == null ? '' : cuenta.Actividad__c);
                                    r.datosCliente.subactividad = (cuenta.Sub_actividad__c == null ? '' : cuenta.Sub_actividad__c); */ 
                            }

                            
                            clienteYOportunidadesAux.datosCliente.nombre = (contacto.FirstName == null ? '' : contacto.FirstName.replace('"',''));
                            clienteYOportunidadesAux.datosCliente.apellidos = (contacto.Lastname == null ? '' : contacto.Lastname.replace('"',''));
                            clienteYOportunidadesAux.datosCliente.telefono = (contacto.Phone == null ? '' : contacto.Phone);
                            clienteYOportunidadesAux.datosCliente.telefonoMovil = (contacto.MobilePhone == null ? '' : contacto.MobilePhone);
                            clienteYOportunidadesAux.datosCliente.fax = (contacto.Fax == null ? '' : contacto.Fax);
                            clienteYOportunidadesAux.datosCliente.email = (contacto.Email == null ? '' : contacto.Email);
                            //r.datosCliente.canal = (contacto.LeadSource == null ? '' : contacto.LeadSource);
                            clienteYOportunidadesAux.datosCliente.dni = (contacto.DNI__c == null ? '' : contacto.DNI__c.replace('"',''));

                            clienteYOportunidadesAux.datosCliente.cif = (cuenta.Id_fiscal__c == null ? '' : cuenta.Id_fiscal__c.replace('"',''));
                            clienteYOportunidadesAux.datosCliente.compania = (cuenta.Name == null ? '' : cuenta.Name.replace('"',''));
                            

                        }

                        //System.debug('clienteYOportunidadesAux.datosCliente: ' + clienteYOportunidadesAux.datosCliente);

                        if(peticionDatos.ofertas == null || peticionDatos.ofertas.size() <= 0)
                        { // no se han recibido ids de ofertas, así que se devuelven únicamente los ids de oportunidades y ofertas del cliente que no se encuentren finalizadas
                            // las ofertas no finalizadas son las que pertenecen a oportunidades no cerradas
                            // recuperar oportunidades del contacto no cerradas
                            if(mapaContactosIdsOportunidadesIds != null && !mapaContactosIdsOportunidadesIds.isEmpty() && mapaContactosIdsOportunidadesIds.containsKey(contacto.Id))
                            {
                                setIdsOportunidades = mapaContactosIdsOportunidadesIds.get(contacto.Id);
                            }
                            else
                            {
                                setIdsOportunidades = null;
                            }

                            if(setIdsOportunidades != null && !setIdsOportunidades.isEmpty())
                            {
                                Opportunity oportunidad;
                                List<Quote> listaOfertas;
                                List<OfertaId> listaOfertasAux;
                                for(String idOp : setIdsOportunidades)
                                {
                                    if(mapaOportunidadesTotales != null && !mapaOportunidadesTotales.isEmpty() && mapaOportunidadesTotales.containsKey(idOp))
                                    {
                                        oportunidad = mapaOportunidadesTotales.get(idOp);

                                        //energias actuales
                                        if(oportunidad.Energias_Actuales__r.size()>0)
                                        {
                                            listaEnergiasAux = new List<EntidadesWSClientesYOfertas.Energia>();
                                            for(Energia_Actual__c energia: oportunidad.Energias_Actuales__r)
                                            {
                                                listaEnergiasAux.add(WSDatosClienteYOfertas.crearEnergiaConEnergiaActualSF(energia));
                                            }
                                        }
                                        else
                                        {
                                            listaEnergiasAux = null;
                                        }

                                        //prescriptor
                                        if(mapaOportunidadesIdsPartners != null && !mapaOportunidadesIdsPartners.isEmpty() && mapaOportunidadesIdsPartners.containsKey(oportunidad.Id))
                                        {
                                            prescriptorId =  mapaOportunidadesIdsPartners.get(oportunidad.Id).get(0).AccountToId; //cojo el primer prescriptor (solo deberia haber 1)                                    
                                        }
                                        else
                                        {
                                            prescriptorId = null;
                                        }

                                        if(mapaOportunidadesIdsQuotes == null || mapaOportunidadesIdsQuotes.isEmpty() || !mapaOportunidadesIdsQuotes.containsKey(oportunidad.Id))
                                        {
                                            //es una oportunidad SIN ofertas                                          
                                            clienteYOportunidadesIdsAux.oportunidades.add(new OportunidadId(idOp, oportunidad.Name, null, listaEnergiasAux, prescriptorId, oportunidad.LeadSource, oportunidad.CreatedDate.format('yyyy-MM-dd HH:mm:ss','Spain/Madrid')));                            
                                        }
                                        else
                                        {
                                            //es una oportunidad CON ofertas
                                            listaOfertas = mapaOportunidadesIdsQuotes.get(oportunidad.Id);
                                            listaOfertasAux = new List<OfertaId>();
                                            String tipo;
                                            for(Quote q : listaOfertas)
                                            {
                                                tipo = '';
                                                if(q.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id)
                                                {
                                                    tipo = Util.constantesNewSales.get('TIPO_OFERTA_ESTANDAR');
                                                }
                                                else if(q.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id)
                                                {
                                                    tipo = Util.constantesNewSales.get('TIPO_OFERTA_MODULAR');
                                                }
                                                else if(q.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id)
                                                {
                                                    tipo = Util.constantesNewSales.get('TIPO_OFERTA_PERSONALIZADA');
                                                }
                                                listaOfertasAux.add(new OfertaId(String.valueOf(q.Id), q.QuoteNumber, q.Status, q.CreatedDate.format('yyyy-MM-dd HH:mm:ss','Spain/Madrid'), tipo, q.Notas__c));
                                                //listaOfertasAux.add(new OfertaId(String.valueOf(q.Id), q.QuoteNumber, q.Status, String.valueOf(q.CreatedDate), tipo));
                                            }
                                            clienteYOportunidadesIdsAux.oportunidades.add(new OportunidadId(idOp, oportunidad.Name, listaOfertasAux, listaEnergiasAux, prescriptorId, oportunidad.LeadSource, oportunidad.CreatedDate.format('yyyy-MM-dd HH:mm:ss','Spain/Madrid')));                            
                                        }

                                    }
                                }
                                clienteYOportunidadesIdsAux.datosCliente = clienteYOportunidadesAux.datosCliente;
                                r1.datosBusqueda.add(clienteYOportunidadesIdsAux);
                            }
                            else
                            {
                                clienteYOportunidadesIdsAux.datosCliente = clienteYOportunidadesAux.datosCliente;
                                r1.datosBusqueda.add(clienteYOportunidadesIdsAux);
                            }                         

                            if(i == listaContactos.size()-1) //cuando ya se ha completado la respuesta con todos los contactos
                            {
                                r1.resultado.codigo = '500';
                                r1.resultado.texto = Label.WSError_500_1;

                                try
                                {
                                    jRespuesta = (String)JSON.serialize(r1);
                                }
                                catch(Exception e)
                                {
                                    LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSDatosClienteYOfertas', 'Error', true);
                                }
                            }
                        }
                        else
                        { // se han recibido ids de ofertas, así que se devuelve toda la información de dichas ofertas
                            setIdsOfertas = new Set<Id>();
                            for(OfertaIdPeticion ofId : peticionDatos.ofertas)
                            {
                                if(ofId != null )
                                {
                                    setIdsOfertas.add(ofId.identificador);
                                }
                            }
                            if(setIdsOfertas.size() > 0 )
                            {
                                listaQuotes = [select Id, QuoteNumber, OpportunityId, Opportunity.Name, RecordTypeId, Status, Observaciones__c, Enviar_email__c, Prioridades_comodidad__c, 
                                                    Prioridades_despreocuparse__c, Prioridades_enterrado__c, Prioridades_ahorro_anual__c, Prioridades_precio_regulado__c, 
                                                    Prioridades_pagar_consumo__c, Prioridades_precio_fijo__c, Prioridades_tarifa_plana__c, Prioridades_impacto__c, 
                                                    Kg__c, KWh__c, Litros__c, KgCO2__c, KgCO2_Primagas__c, KWh_Primagas__c, Diferencia_kgCO2__c, Diferencia_kWh__c, Name, 
                                                    Coste_vallado__c, Coste_instalacion_exterior__c, Coste_instalacion_interior__c, Equipo_interior__c, CreatedDate,
                                                    Coste_proyectos__c, Precio_Primaservicios__c, Equipos_a_instalar_Primagas__c, Resolucion_anticipada__c, 
                                                    Coste_obra_civil__c, Total_inversion__c, Deposito_nombre__c, Coste_deposito__c, Obra_civil__c, Fecha_vigencia__c, Vallado__c,
                                                    Total_financiable__c, Pago_inicial__c, Tipo_de_interes__c, Numero_de_cuotas__c, Importe_de_cuotas__c, Exterior__c,
                                                    Importe_12_cuotas__c, Importe_en_gas_en_E_L__c, Importe_en_gas_en_E_Kg__c, Importe_ahorro_instalacion__c,
                                                    Precio_mensual_L__c, Precio_fijo_anual_L__c, Contador_L__c, Tarifa_plana_L__c, Precio_mensual_Kg__c, Coste_interior__c,
                                                    Precio_fijo_anual_Kg__c, Contador_Kg__c, Tarifa_plana_Kg__c, Nivel_PB__c, Tipo_de_tarifa__c, Dto_1_Llenado_inversion__c, 
                                                    Duracion_descuento__c, Pago_inicial_inversion__c, Cuota_inversion__c, Duracion_cuota_inversion__c, Interior__c,
                                                    Interior_estandar__c, Exterior_estandar__c, Servicio_estandar__c, Tarifa_estandar__c, Tipo_producto_gas__c, Proyectos__c,
                                                    Precio_L__c, Precio_Kg__c, Valor_del_servicio_estandar__c, Diferencia_importes_totales__c, Duracion_contratado__c,
                                                    Importe_total__c, Importe_total_primagas__c, Tipo_de_pago_inversion__c, Precio_producto_gas__c, Dto_Producto_gas__c,
                                                    Tipo_Primaservicios__c, Mantenimiento_primaservicios__c, Inspeccion_interior_primaservicios__c, Coste_equipo_interior__c,
                                                    Revision_interior_primaservicios__c, Instalacion_interior__c, Importe_ahorro_gas__c, Opcion_seleccionada_producto__c,
                                                    Texto_fecha_producto__c, Aplica_tramos__c, Financiacion_seleccionada__c, Name_OpcionesOfertaSTD_maestro__c, Name_ImagenesOferta_maestro__c,
                                                    Consumo_contratado_L__c, Consumo_contratado_kg__c, Dto_Estandar__c, Texto_servicio_estandar__c, Precio_fecha__c, Tramo_escalado_a_aplicar__c,
                                                    Opportunity.LeadSource, Opportunity.CreatedDate, Notas__c
                                                    from Quote where Id = :setIdsOfertas];

                                if(listaQuotes != null)
                                {
                                    setIdsOfertasModulares = new Set<Id>();
                                    setIdsOfertasPersonalizadas = new Set<Id>();
                                    for(Quote q : listaQuotes)
                                    {
                                        if(q.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id)
                                        {
                                            setIdsOfertasModulares.add(q.Id);
                                        }
                                        else if( q.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id)
                                        {
                                            setIdsOfertasPersonalizadas.add(q.Id);
                                        }
                                    }
                                    
                                    // recuperar energías actuales de la oportunidad
                                    setIdsOportunidades = new Set<String>();
                                    for(Quote q: listaQuotes)
                                    {
                                        setIdsOportunidades.add(q.OpportunityId);
                                    }
                                    mapaOportunidades = new Map<String,Opportunity>([select Id, Name, LeadSource, CreatedDate, AccountId, 
                                                                            (select Id, Name, Consumo__c, Consumo_KWH__c, Consumo_KgCo2__c, Consumo_L_Primagas__c, 
                                                                            Unidad_consumo__c, Consumo_KWH_Primagas__c, Consumo_Kg_Primagas__c, Consumo_KgCO2_Primagas__c,
                                                                            Precio__c, Unidad_precio__c, Proveedor__r.Name, Rendimiento__c, Cambio__c, Presupuesto__c, 
                                                                            Importe_situacion_actual__c, Tipo_energia__c from Energias_Actuales__r)
                                                                            from Opportunity where Id = :setIdsOportunidades order by CreatedDate desc]);
                                    mapaOportunidadesIdsEnergiasNS = new Map<String,List<EntidadesWSClientesYOfertas.Energia>>();
                                    if(mapaOportunidades!=null && mapaOportunidades.size()>0)
                                    {
                                        for(String opId: mapaOportunidades.keySet())
                                        {
                                            if(mapaOportunidades.get(opId).Energias_Actuales__r.size()>0)
                                            {
                                                listaEnergiasAux = new List<EntidadesWSClientesYOfertas.Energia>();
                                                for(Energia_Actual__c energia: mapaOportunidades.get(opId).Energias_Actuales__r)
                                                {
                                                    listaEnergiasAux.add(WSDatosClienteYOfertas.crearEnergiaConEnergiaActualSF(energia));
                                                }
                                                mapaOportunidadesIdsEnergiasNS.put(opId, listaEnergiasAux);
                                            }                                            
                                        }
                                    }
                    
                                    // recuperar partners de la oportunidad
                                    listaOpportunityPartner = [select Id, AccountToId, OpportunityId, Role from OpportunityPartner where OpportunityId = :setIdsOportunidades
                                                                order by Opportunity.CreatedDate desc];
                                    mapaOportunidadesIdsPartners = new Map<String,List<OpportunityPartner>>();
                                    if(listaOpportunityPartner!=null && listaOpportunityPartner.size()>0)
                                    {
                                        for(OpportunityPartner partner : listaOpportunityPartner)
                                        {
                                            if(mapaOportunidades!=null && mapaOportunidades.size()>0 && mapaOportunidades.containsKey(partner.OpportunityId) && 
                                                partner.AccountToId != mapaOportunidades.get(partner.OpportunityId).AccountId)
                                            {
                                                if(mapaOportunidadesIdsPartners.containsKey(partner.OpportunityId))
                                                {
                                                    mapaOportunidadesIdsPartners.get(partner.OpportunityId).add(partner);
                                                }
                                                else
                                                {
                                                    listaPartnersAux = new List<OpportunityPartner>();
                                                    listaPartnersAux.add(partner);
                                                    mapaOportunidadesIdsPartners.put(partner.OpportunityId, listaPartnersAux);
                                                }
                                            }
                                        }
                                    }
                                    System.debug('##mapaOportunidadesIdsPartners: ' + mapaOportunidadesIdsPartners);

                                    // recuperar equipos actuales de las ofertas
                                    listEquiposActuales = [select Id, Name, Cantidad__c, Uso__c, Potencia_KW__c, Anyo__c, Energ_a__c, Presupuesto__c
                                                            from Equipo_actual__c where Presupuesto__c = :setIdsOfertas];
                                    if(listEquiposActuales != null)
                                    {
                                        mapQuoteEquipos = new Map<Id, List<EntidadesWSClientesYOfertas.Equipo>>();
                                        for(Equipo_actual__c equipo : listEquiposActuales)
                                        {
                                            if(equipo != null && equipo.Presupuesto__c != null)
                                            {
                                                if(mapQuoteEquipos.containsKey(equipo.Presupuesto__c))
                                                {
                                                    listEquiposAux = mapQuoteEquipos.remove(equipo.Presupuesto__c);
                                                    if(listEquiposAux==null)
                                                        listEquiposAux = new List<EntidadesWSClientesYOfertas.Equipo>();
                                                }
                                                else
                                                {
                                                    listEquiposAux = new List<EntidadesWSClientesYOfertas.Equipo>();
                                                }
                                                listEquiposAux.add(WSDatosClienteYOfertas.crearEquipoConEquipoActualSF(equipo));
                                                mapQuoteEquipos.put(equipo.Presupuesto__c, listEquiposAux);
                                            }
                                        }
                                    }

                                    // recuperar energías actuales de las ofertas
                                    listEnergiasActuales = [select Id, Name, Consumo__c, Consumo_KWH__c, Consumo_KgCo2__c, Consumo_L_Primagas__c, 
                                                                    Unidad_consumo__c, Consumo_KWH_Primagas__c, Consumo_Kg_Primagas__c, Consumo_KgCO2_Primagas__c,
                                                                    Precio__c, Unidad_precio__c, Proveedor__r.Name, Rendimiento__c, Cambio__c, Presupuesto__c, 
                                                                    Importe_situacion_actual__c, Tipo_energia__c 
                                                                    from Energia_Actual__c where Presupuesto__c = :setIdsOfertas];

                                    if(listEnergiasActuales != null)
                                    {
                                        mapQuoteEnergias = new Map<Id, List<EntidadesWSClientesYOfertas.Energia>>();
                                        for(Energia_Actual__c energia : listEnergiasActuales)
                                        {
                                            if(energia != null && energia.Presupuesto__c != null)
                                            {
                                                if(mapQuoteEnergias.containsKey(energia.Presupuesto__c))
                                                {
                                                    listEnergiasAux = mapQuoteEnergias.remove(energia.Presupuesto__c);
                                                    if(listEnergiasAux==null)
                                                        listEnergiasAux = new List<EntidadesWSClientesYOfertas.Energia>();
                                                }
                                                else
                                                {
                                                    listEnergiasAux = new List<EntidadesWSClientesYOfertas.Energia>();
                                                }
                                                listEnergiasAux.add(WSDatosClienteYOfertas.crearEnergiaConEnergiaActualSF(energia));
                                                mapQuoteEnergias.put(energia.Presupuesto__c, listEnergiasAux);
                                            }
                                        }
                                    }

                                    // para las ofertas modulares, recuperar packs de servicios
                                    // packs de servicios
                                    listPacksServicioActuales = [select Id, Presupuesto__c, Total_importe__c, Numero_de_pack__c, Name_Pack_maestros__c
                                                                    from Pack_de_servicio__c where Presupuesto__c = :setIdsOfertasModulares];
                                    if(listPacksServicioActuales != null)
                                    {
                                        mapQuotePacks = new Map<Id, EntidadesWSClientesYOfertas.Pack>();
                                        for(Pack_de_servicio__c packAct : listPacksServicioActuales)
                                        {
                                            if(packAct != null && packAct.Presupuesto__c != null)
                                            {
                                                if(!mapQuotePacks.containsKey(packAct.Presupuesto__c))
                                                {
                                                    mapQuotePacks.put(packAct.Presupuesto__c, WSDatosClienteYOfertas.crearPackConPackServicioSF(packAct));  
                                                }
                                            }
                                        }
                                    }

                                    // para las ofertas modulares y personalizadas, recuperar depósitos, equipos ajuste y tramos
                                    // tramos

                                    //gserrano se añaden campos a la query clv5, clv10, gp
                                    //String clv5 = '';
                                    //Sring clv10 = '';
                                    //String gp = '';

                                    listaTramos = [select Id, Name, RecordTypeId, Presupuesto__c, Consumo_desde_Kg__c, Consumo_desde_L__c, Consumo_hasta_Kg__c, PBA__c, Consumo_hasta_L__c,
                                                   Financiacion_en_gas_en_E_Kg__c, Financiacion_en_gas_en_E_L__c, Porcentaje_desde__c, CLV5__c, CLV10__c, gp__c,
                                                   Porcentaje_hasta__c, Dto_Kg__c, Dto_L__c, Duracion_descuento__c, Precio_HOY_Kg__c, Precio_HOY_L__c, Prima_servicios_A__c
                                                   from Tramo__c where Presupuesto__c = :setIdsOfertasModulares or Presupuesto__c = :setIdsOfertasPersonalizadas order by Name];
                                    
                                    if(listaTramos != null)
                                    {
                                        mapQuoteTramos = new Map<String, List<EntidadesWSClientesYOfertas.Tramo>>();
                                        mapQuoteEscalado = new Map<String, List<EntidadesWSClientesYOfertas.Escalado>>();

                                        //clv5 = listaTramos[0].clv5__c;
                                        //clv10 = listaTramos[0].clv10__c;

                                        for(Tramo__c tramo : listaTramos)
                                        {
                                            if( tramo != null && tramo.Presupuesto__c != null)
                                            {
                                                if(tramo.RecordTypeId == Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_normal').Id)
                                                {
                                                    if(mapQuoteTramos.containsKey(tramo.Presupuesto__c))
                                                    {
                                                        listTramosAux = mapQuoteTramos.remove(tramo.Presupuesto__c);
                                                        if(listTramosAux==null)
                                                            listTramosAux = new List<EntidadesWSClientesYOfertas.Tramo>();
                                                    }
                                                    else
                                                    {
                                                        listTramosAux = new List<EntidadesWSClientesYOfertas.Tramo>();
                                                    }

                                                    //gp += tramo.gp__c + '-';

                                                    listTramosAux.add(WSDatosClienteYOfertas.crearTramoConTramoSF(tramo));
                                                    mapQuoteTramos.put(tramo.Presupuesto__c, listTramosAux);
                                                }
                                                else if( tramo.RecordTypeId == Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_escalado').Id)
                                                {
                                                    if(mapQuoteEscalado.containsKey(tramo.Presupuesto__c))
                                                    {
                                                        listEscaladoAux = mapQuoteEscalado.remove(tramo.Presupuesto__c);
                                                        if(listEscaladoAux==null)
                                                            listEscaladoAux = new List<EntidadesWSClientesYOfertas.Escalado>();
                                                    }
                                                    else
                                                    {
                                                        listEscaladoAux = new List<EntidadesWSClientesYOfertas.Escalado>();
                                                    }
                                                    listEscaladoAux.add(WSDatosClienteYOfertas.crearEscaladoConTramoSF(tramo));
                                                    mapQuoteEscalado.put(tramo.Presupuesto__c, listEscaladoAux);
                                                }
                                            }
                                        }

                                        //gp = gp.removesEnd('-');
                                    }

                                    // depósitos
                                    listDepositos = [select Id, Name, Cantidad__c, Presupuesto__c, Equipos_exterior__c, Instalacion_exterior__c, Obra_civil_vallado__c, 
                                                        Proyectos__c
                                                        from Deposito__c where Presupuesto__c = :setIdsOfertasModulares or Presupuesto__c = :setIdsOfertasPersonalizadas];
                                    if(listDepositos != null)
                                    {
                                        mapQuoteDepositos = new Map<Id, List<EntidadesWSClientesYOfertas.Deposito>>();
                                        for(Deposito__c deposito : listDepositos)
                                        {
                                            if(deposito != null && deposito.Presupuesto__c != null)
                                            {
                                                if(mapQuoteDepositos.containsKey(deposito.Presupuesto__c))
                                                {
                                                    listDepositosAux = mapQuoteDepositos.remove(deposito.Presupuesto__c);
                                                    if(listDepositosAux==null)
                                                        listDepositosAux = new List<EntidadesWSClientesYOfertas.Deposito>();
                                                }
                                                else
                                                {
                                                    listDepositosAux = new List<EntidadesWSClientesYOfertas.Deposito>();
                                                }
                                                listDepositosAux.add(WSDatosClienteYOfertas.crearDepositoConDepositoSF(deposito));
                                                mapQuoteDepositos.put(deposito.Presupuesto__c, listDepositosAux);
                                            }
                                        }
                                    }

                                    // equipos ajuste
                                    listEquiposAjuste = [select Id, Name, Cantidad__c, Presupuesto__c, Equipos_exterior__c, Equipos_interior__c, Instalacion_exterior__c, Instalacion_interior__c
                                                            from Equipo_Ajuste__c where Presupuesto__c = :setIdsOfertasModulares or Presupuesto__c = :setIdsOfertasPersonalizadas];
                                    if(listEquiposAjuste != null)
                                    {
                                        mapQuoteEquiposAjuste = new Map<Id, List<EntidadesWSClientesYOfertas.EquipoAjuste>>();
                                        for(Equipo_Ajuste__c eqAj : listEquiposAjuste)
                                        {
                                            if(eqAj != null && eqAj.Presupuesto__c != null)
                                            {
                                                if(mapQuoteEquiposAjuste.containsKey(eqAj.Presupuesto__c))
                                                {
                                                    listaEquiposAjusteAux = mapQuoteEquiposAjuste.remove(eqAj.Presupuesto__c);
                                                    if(listaEquiposAjusteAux==null)
                                                        listaEquiposAjusteAux = new List<EntidadesWSClientesYOfertas.EquipoAjuste>();
                                                }
                                                else
                                                {
                                                    listaEquiposAjusteAux = new List<EntidadesWSClientesYOfertas.EquipoAjuste>();
                                                }
                                                listaEquiposAjusteAux.add(WSDatosClienteYOfertas.crearEquipoAjusteConEquipoAjusteSF(eqAj));
                                                mapQuoteEquiposAjuste.put(eqAj.Presupuesto__c, listaEquiposAjusteAux);
                                            }
                                        }
                                    }

                                    // recorrer la lista de ofertas recuperadas, para agruparlas por su oportunidad
                                    mapOportunidadOfertas = new Map<String, List<EntidadesWSClientesYOfertas.Oferta>>();
                                    mapNamesOportunidad = new Map<Id, String>();
                                    for(Quote q : listaQuotes)
                                    {
                                        system.debug('q: ' + q);
                                        listTramosNormal = null;
                                        listTramosEscalado = null;
                                        if(q != null && q.OpportunityId != null)
                                        {
                                            if(!mapNamesOportunidad.containsKey(q.OpportunityId))
                                            {
                                                mapNamesOportunidad.put(q.OpportunityId, q.Opportunity.Name);
                                            }

                                            if(mapOportunidadOfertas.containsKey(q.OpportunityId))
                                            {
                                                listOfertasAux = mapOportunidadOfertas.remove(q.OpportunityId);
                                                if(listOfertasAux==null)
                                                    listOfertasAux = new List<EntidadesWSClientesYOfertas.Oferta>();
                                            }
                                            else
                                            {
                                                listOfertasAux = new List<EntidadesWSClientesYOfertas.Oferta>();    
                                            }
                                            
                                            if(mapQuoteTramos != null)
                                            {
                                                listTramosNormal = mapQuoteTramos.get(q.Id);
                                            }
                                            if(mapQuoteEscalado != null)
                                            {
                                                listTramosEscalado = mapQuoteEscalado.get(q.Id);
                                            }
                                            if(mapQuoteEnergias != null)
                                            {
                                                listaEnergias = mapQuoteEnergias.get(q.Id);
                                            }
                                            if(mapQuoteEquipos != null)
                                            {
                                                listaEquipos = mapQuoteEquipos.get(q.Id);
                                            }
                                            if(mapQuotePacks != null)
                                            {
                                                pack = mapQuotePacks.get(q.Id);
                                            }
                                            if(mapQuoteDepositos != null)
                                            {
                                                listaDepositos = mapQuoteDepositos.get(q.Id);
                                            }
                                            if(mapQuoteEquiposAjuste != null)
                                            {
                                                listaEquiposAjuste = mapQuoteEquiposAjuste.get(q.Id);
                                            }

                                            listOfertasAux.add(WSDatosClienteYOfertas.crearOfertaConQuote(q, listTramosNormal, listTramosEscalado, listaEquipos, listaEnergias, pack, listaDepositos, listaEquiposAjuste));
                                            //listOfertasAux.add(WSDatosClienteYOfertas.crearOfertaConQuote(q, listTramosNormal, listTramosEscalado, listaEquipos, listaEnergias, pack, listaDepositos, listaEquiposAjuste, clv5, clv10, gp));
                                            mapOportunidadOfertas.put(q.OpportunityId, listOfertasAux);
                                        }
                                    }
                                    if(!mapOportunidadOfertas.isEmpty())
                                    {
                                        for(String idOpp : mapOportunidadOfertas.keySet())
                                        {
                                            //energías actuales de la oportunidad
                                            if(mapaOportunidadesIdsEnergiasNS!=null && mapaOportunidadesIdsEnergiasNS.size()>0 && mapaOportunidadesIdsEnergiasNS.containsKey(idOpp))
                                            {   
                                                listaEnergiasAux = mapaOportunidadesIdsEnergiasNS.get(idOpp);
                                            }
                                            else
                                            {
                                                listaEnergiasAux = null;
                                            }
                                            
                                            //prescriptor de la oportunidad
                                            if(mapaOportunidadesIdsPartners!=null && mapaOportunidadesIdsPartners.size()>0 && mapaOportunidadesIdsPartners.containsKey(idOpp))
                                            {
                                                prescriptorId =  mapaOportunidadesIdsPartners.get(idOpp).get(0).AccountToId; //cojo el primer prescriptor (solo deberia haber 1)
                                            }
                                            else
                                            {
                                                prescriptorId = null;
                                            }

                                            //canal de ventas y fecha de creación
                                            String canal = null;
                                            String fechaCreacion = null;
                                            if(mapaOportunidades!=null && mapaOportunidades.size()>0 && mapaOportunidades.containsKey(idOpp))
                                            {
                                                canal = mapaOportunidades.get(idOpp).LeadSource;
                                                fechaCreacion = mapaOportunidades.get(idOpp).CreatedDate.format('yyyy-MM-dd HH:mm:ss','Spain/Madrid');
                                            }
                                            
                                            if(mapNamesOportunidad != null && mapNamesOportunidad.containsKey(idOpp))
                                            {
                                                clienteYOportunidadesAux.oportunidades.add(new Oportunidad(idOpp, mapNamesOportunidad.get(idOpp), mapOportunidadOfertas.get(idOpp), 
                                                                                                            listaEnergiasAux, prescriptorId, canal, fechaCreacion));
                                            }
                                            else
                                            {
                                                clienteYOportunidadesAux.oportunidades.add(new Oportunidad(idOpp, '', mapOportunidadOfertas.get(idOpp),
                                                                                                            listaEnergiasAux, prescriptorId, canal, fechaCreacion));
                                            }
                                        }
                                    }
                                }
                            }
                            r.resultado.codigo = '500';
                            r1.resultado.texto = Label.WSError_500_2;
                            r.datosBusqueda.add(clienteYOportunidadesAux);
                            try
                            {
                                jRespuesta = (String)JSON.serialize(r);
                            }
                            catch(Exception e)
                            {
                                LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSDatosClienteYOfertas', 'Error', true);
                            }

                            break; //cuando se envía la respuesta con detalles de ofertas solo se hace para 1 contacto
                        }
                    }
                }
            }
            else
            {
                r1.resultado.codigo = '501';
                r1.resultado.texto = Label.WSError_501;
                LogUtil.crearLog(r1.resultado.texto, 'Errores NewSales', 'WSDatosClienteYOfertas', 'Error', true);
            }
        }
        catch(Exception e)
        {
            r1.resultado.codigo = '502';
            r1.resultado.texto = Label.WSError_502;
            LogUtil.crearLog(r.resultado.texto + ' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'Errores NewSales', 'WSDatosClienteYOfertas', 'Error', true);
        }

        try
        {
            if(jRespuesta == '')
            {
                jRespuesta = (String)JSON.serialize(r1);
            }
        }
        catch(Exception e)
        {
            LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSDatosClienteYOfertas', 'Error', true);
        }
        
        if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
        {
            LogUtil.guardarLog();
        }
        
        return jRespuesta;
    }

    private static ClienteYOportunidades eliminarCaracterRaro(ClienteYOportunidades clienteYOportunidadesAux)
    {
        if (clienteYOportunidadesAux.datosCliente.actividad == 'Doméstico Unifamiliar')
        {
            System.debug('## Es domestico');
        }else{
            System.debug('## No es domestico');
            clienteYOportunidadesAux.datosCliente.actividad = clienteYOportunidadesAux.datosCliente.actividad.replaceAll(' ', ' ');
            if(clienteYOportunidadesAux.datosCliente.actividad == 'Doméstico Unifamiliar')
            {
                System.debug('## Es domestico 2');
            }
        }
        return clienteYOportunidadesAux;
    }

    private static EntidadesWSClientesYOfertas.Tramo crearTramoConTramoSF(Tramo__c tramo)
    {
        EntidadesWSClientesYOfertas.Tramo resultado = null;
        try
        {
            if(tramo != null)
            {
                resultado = new EntidadesWSClientesYOfertas.Tramo();
                resultado.idSalesforce = (tramo.Id == null ? '' : tramo.Id);
                resultado.tramo = (tramo.Name == null ? '' : tramo.Name);
                resultado.porcentajeDesde = (tramo.Porcentaje_desde__c == null ? '': String.valueOf(tramo.Porcentaje_desde__c));
                resultado.porcentajeHasta = (tramo.Porcentaje_hasta__c == null ? '' : String.valueOf(tramo.Porcentaje_hasta__c));
                resultado.consumoDesdeL = (tramo.Consumo_desde_L__c == null ? '' : String.valueOf(tramo.Consumo_desde_L__c));
                resultado.consumoHastaL = (tramo.Consumo_hasta_L__c == null ? '' : String.valueOf(tramo.Consumo_hasta_L__c));
                resultado.consumoDesdeKg = (tramo.Consumo_desde_Kg__c == null ? '' : String.valueOf(tramo.Consumo_desde_Kg__c));
                resultado.consumoHastaKg = (tramo.Consumo_hasta_Kg__c == null ? '' : String.valueOf(tramo.Consumo_hasta_Kg__c));
                resultado.financiacionL = (tramo.Financiacion_en_gas_en_E_L__c == null ? '' : String.valueOf(tramo.Financiacion_en_gas_en_E_L__c));
                resultado.financiacionKg = (tramo.Financiacion_en_gas_en_E_Kg__c == null ? '' : String.valueOf(tramo.Financiacion_en_gas_en_E_Kg__c));

                //gserrano 12/12/2018
                //resultado.clv5 = (tramo.CLV5__c == null ? '' : String.valueOf(tramo.CLV5__c));
                //resultado.clv10 = (tramo.CLV10__c == null ? '' : String.valueOf(tramo.CLV10__c));
                //resultado.gp = (tramo.gp__c == null ? '' : String.valueOf(tramo.gp__c));
       
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción al crear tramo con tramo__c: ' + ex.getMessage());
        }
        return resultado;
    }

    private static EntidadesWSClientesYOfertas.Escalado crearEscaladoConTramoSF(Tramo__c tramo)
    {
        EntidadesWSClientesYOfertas.Escalado resultado = null;
        try
        {
            if(tramo != null)
            {
                resultado = new EntidadesWSClientesYOfertas.Escalado();
                resultado.idSalesforce = (tramo.Id == null ? '' : tramo.Id);
                resultado.tramo = (tramo.Name == null ? '' : tramo.Name);
                resultado.porcentajeDesde = (tramo.Porcentaje_desde__c == null ? '': String.valueOf(tramo.Porcentaje_desde__c));
                resultado.porcentajeHasta = (tramo.Porcentaje_hasta__c == null ? '' : String.valueOf(tramo.Porcentaje_hasta__c));
                resultado.consumoDesdeL = (tramo.Consumo_desde_L__c == null ? '' : String.valueOf(tramo.Consumo_desde_L__c));
                resultado.consumoHastaL = (tramo.Consumo_hasta_L__c == null ? '' : String.valueOf(tramo.Consumo_hasta_L__c));
                resultado.consumoDesdeKg = (tramo.Consumo_desde_Kg__c == null ? '' : String.valueOf(tramo.Consumo_desde_Kg__c));
                resultado.consumoHastaKg = (tramo.Consumo_hasta_Kg__c == null ? '' : String.valueOf(tramo.Consumo_hasta_Kg__c));
                resultado.dtoL = (tramo.Dto_L__c == null ? '' : String.valueOf(tramo.Dto_L__c));
                resultado.dtoKg = (tramo.Dto_Kg__c == null ? '' : String.valueOf(tramo.Dto_Kg__c));
                resultado.duracionDTO = (tramo.Duracion_descuento__c == null ? '' : String.valueOf(tramo.Duracion_descuento__c));
                resultado.precioHoyL = (tramo.Precio_HOY_L__c == null ? '' : String.valueOf(tramo.Precio_HOY_L__c));
                resultado.precioHoyK = (tramo.Precio_HOY_Kg__c == null ? '' : String.valueOf(tramo.Precio_HOY_Kg__c));
                resultado.primaServiciosA = (tramo.Prima_servicios_A__c == null ? '' : String.valueOf(tramo.Prima_servicios_A__c));
                resultado.pba = (tramo.PBA__c == null ? '' : String.valueOf(tramo.PBA__c));

                //gserrano 12/12/2018
                //resultado.clv5 = (tramo.CLV5__c == null ? '' : String.valueOf(tramo.CLV5__c));
                //resultado.clv10 = (tramo.CLV10__c == null ? '' : String.valueOf(tramo.CLV10__c));
                //resultado.gp = (tramo.gp__c == null ? '' : String.valueOf(tramo.gp__c));

            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción al crear tramo con tramo__c: ' + ex.getMessage());
        }
        return resultado;
    }

    private static EntidadesWSClientesYOfertas.Equipo crearEquipoConEquipoActualSF(Equipo_actual__c equipoAct)
    {
        EntidadesWSClientesYOfertas.Equipo resultado = null;
        try
        {
            if(equipoAct != null)
            {
                resultado = new EntidadesWSClientesYOfertas.Equipo();
                resultado.idSalesforce = (equipoAct.Id == null ? '' : equipoAct.Id);
                resultado.nombre = (equipoAct.Name == null ? '' : equipoAct.Name);
                resultado.cantidad = (equipoAct.Cantidad__c == null ? '' : String.valueOf(equipoAct.Cantidad__c));
                resultado.uso = (equipoAct.Uso__c == null ? '' : equipoAct.Uso__c);
                resultado.potenciaKW = (equipoAct.Potencia_KW__c == null ? '' : String.valueOf(equipoAct.Potencia_KW__c));
                resultado.antiguedad = (equipoAct.Anyo__c == null ? '' : equipoAct.Anyo__c);
                resultado.energia = (equipoAct.Energ_a__c == null ? '' : equipoAct.Energ_a__c);
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción al crear equipo con Equipo_actual__c: ' + ex.getMessage());
        }
        return resultado;
    }

    private static EntidadesWSClientesYOfertas.Energia crearEnergiaConEnergiaActualSF(Energia_Actual__c energiaAct)
    {
        EntidadesWSClientesYOfertas.Energia resultado = null;
        try
        {
            if(energiaAct != null)
            {
                resultado = new EntidadesWSClientesYOfertas.Energia();
                resultado.idSalesforce = (energiaAct.Id == null ? '' : energiaAct.Id);
                resultado.nombre = (energiaAct.Tipo_energia__c == null ? '' : energiaAct.Tipo_energia__c);
                resultado.consumo = (energiaAct.Consumo__c == null ? '' : String.valueOf(energiaAct.Consumo__c));
                resultado.consumoKWH = (energiaAct.Consumo_KWH__c == null ? '' : String.valueOf(energiaAct.Consumo_KWH__c));
                resultado.consumoKgCO2 = (energiaAct.Consumo_KgCo2__c == null ? '' : String.valueOf(energiaAct.Consumo_KgCo2__c));
                resultado.consumoL_primagas = (energiaAct.Consumo_L_Primagas__c == null ? '' : String.valueOf(energiaAct.Consumo_L_Primagas__c));
                resultado.consumoKWH_primagas = (energiaAct.Consumo_KWH_Primagas__c == null ? '' : String.valueOf(energiaAct.Consumo_KWH_Primagas__c));
                resultado.consumoKg_primagas = (energiaAct.Consumo_Kg_Primagas__c == null ? '' : String.valueOf(energiaAct.Consumo_Kg_Primagas__c));
                resultado.consumoKgCO2_primagas = (energiaAct.Consumo_KgCO2_Primagas__c == null ? '' : String.valueOf(energiaAct.Consumo_KgCO2_Primagas__c));
                resultado.unidadConsumo = (energiaAct.Unidad_consumo__c == null ? '' : energiaAct.Unidad_consumo__c);
                resultado.precio = (energiaAct.Precio__c == null ? '' : String.valueOf(energiaAct.Precio__c));
                resultado.unidadPrecio = (energiaAct.Unidad_precio__c == null ? '' : energiaAct.Unidad_precio__c);
                resultado.proveedor = (energiaAct.Proveedor__r.Name == null ? '' : energiaAct.Proveedor__r.Name);
                resultado.rendimiento = (energiaAct.Rendimiento__c == null ? '' : String.valueOf(energiaAct.Rendimiento__c));
                resultado.cambio = (energiaAct.Cambio__c == null ? '' : energiaAct.Cambio__c);
                resultado.importeSituacionActual = (energiaAct.Importe_situacion_actual__c == null ? '' : String.valueOf(energiaAct.Importe_situacion_actual__c));
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción al crear energia con Energia_Actual__c: ' + ex.getMessage());
        }
        return resultado;
    }

    private static EntidadesWSClientesYOfertas.Pack crearPackConPackServicioSF(Pack_de_servicio__c pack)
    {
        EntidadesWSClientesYOfertas.Pack resultado = null;
        Pack__c packMaestro;
        List<Servicio__c> listServiciosDePack;
        List<EntidadesWSClientesYOfertas.ServicioSeleccionado> listServiciosSeleccionados;
        try
        {
            if( pack != null )
            {
                resultado = new EntidadesWSClientesYOfertas.Pack();
                resultado.packSeleccionado = (pack.Name_Pack_maestros__c == null ? '' : pack.Name_Pack_maestros__c);
                resultado.totalImporte = (pack.Total_importe__c == null ? '' : String.valueOf(pack.Total_importe__c));
                listServiciosDePack = [select Id, Name_Servicio_pack_maestro__c from Servicio__c where Pack_de_servicio__c = :pack.Id and Incluido__c = false];
                //system.debug('listServiciosDePack: ' + listServiciosDePack);
                if(listServiciosDePack != null)
                {
                    listServiciosSeleccionados = new List<EntidadesWSClientesYOfertas.ServicioSeleccionado>();
                    for(Servicio__c serv : listServiciosDePack)
                    {
                        listServiciosSeleccionados.add(new EntidadesWSClientesYOfertas.ServicioSeleccionado( serv.Name_Servicio_pack_maestro__c ));
                    }
                    resultado.serviciosSeleccionados = new List<EntidadesWSClientesYOfertas.ServicioSeleccionado>(listServiciosSeleccionados);
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción al crear pack con Pack_de_servicio__c: ' + ex.getMessage());
        }
        return resultado;
    }

    private static EntidadesWSClientesYOfertas.EquipoAjuste crearEquipoAjusteConEquipoAjusteSF(Equipo_Ajuste__c equipoAj)
    {
        EntidadesWSClientesYOfertas.EquipoAjuste resultado = null;
        try
        {
            if(equipoAj != null)
            {
                resultado = new EntidadesWSClientesYOfertas.EquipoAjuste();
                resultado.idSalesforce = (equipoAj.Id == null ? '' : equipoAj.Id);
                resultado.nombre = (equipoAj.Name == null ? '' : equipoAj.Name);
                resultado.cantidad = (equipoAj.Cantidad__c == null ? '' :String.valueOf(equipoAj.Cantidad__c));
                resultado.equiposExterior = (equipoAj.Equipos_exterior__c == null ? '' : String.valueOf(equipoAj.Equipos_exterior__c));
                resultado.equiposInterior = (equipoAj.Equipos_interior__c == null ? '' : String.valueOf(equipoAj.Equipos_interior__c));
                resultado.instalacionExterior = (equipoAj.Instalacion_exterior__c == null ? '' : String.valueOf(equipoAj.Instalacion_exterior__c));
                resultado.instalacionInterior = (equipoAj.Instalacion_interior__c == null ? '' : String.valueOf(equipoAj.Instalacion_interior__c));
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción al crear equipoAjuste con Equipo_Ajuste__c: ' + ex.getMessage());
        }
        return resultado;
    }

    private static EntidadesWSClientesYOfertas.Deposito crearDepositoConDepositoSF(Deposito__c deposito)
    {
        EntidadesWSClientesYOfertas.Deposito resultado = null;
        try
        {
            if(deposito != null)
            {
                resultado = new EntidadesWSClientesYOfertas.Deposito();
                resultado.idSalesforce = (deposito.Id == null ? '' : deposito.Id);
                resultado.tipo = (deposito.Name == null ? '' : deposito.Name);
                resultado.cantidad = (deposito.Cantidad__c == null ? '' : String.valueOf(deposito.Cantidad__c));
                resultado.equiposExterior = (deposito.Equipos_exterior__c == null ? '' : String.valueOf(deposito.Equipos_exterior__c));
                resultado.instalacionExterior = (deposito.Instalacion_exterior__c == null ? '' : String.valueOf(deposito.Instalacion_exterior__c));
                resultado.proyectos = (deposito.Proyectos__c == null ? '' : String.valueOf(deposito.Proyectos__c));
                resultado.obraCivilVallado = (deposito.Obra_civil_vallado__c == null ? '' : String.valueOf(deposito.Obra_civil_vallado__c));
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción al crear deposito con Deposito__c: ' + ex.getMessage());
        }
        return resultado;
    }

    private static EntidadesWSClientesYOfertas.Oferta crearOfertaConQuote(Quote quote, List<EntidadesWSClientesYOfertas.Tramo> listaTramosNormal, List<EntidadesWSClientesYOfertas.Escalado> listaTramosEscalado, List<EntidadesWSClientesYOfertas.Equipo> listaEquipos, List<EntidadesWSClientesYOfertas.Energia> listaEnergias, EntidadesWSClientesYOfertas.Pack packQuote, List<EntidadesWSClientesYOfertas.Deposito> listaDepositos, List<EntidadesWSClientesYOfertas.EquipoAjuste> listaEquiposAjuste)
    //private static EntidadesWSClientesYOfertas.Oferta crearOfertaConQuote(Quote quote, List<EntidadesWSClientesYOfertas.Tramo> listaTramosNormal, List<EntidadesWSClientesYOfertas.Escalado> listaTramosEscalado, List<EntidadesWSClientesYOfertas.Equipo> listaEquipos, List<EntidadesWSClientesYOfertas.Energia> listaEnergias, EntidadesWSClientesYOfertas.Pack packQuote, List<EntidadesWSClientesYOfertas.Deposito> listaDepositos, List<EntidadesWSClientesYOfertas.EquipoAjuste> listaEquiposAjuste, String clv5, String clv10, String gp)
    {
        EntidadesWSClientesYOfertas.Oferta oferta = null;
        EntidadesWSClientesYOfertas.Prioridades infoPrioridades;
        EntidadesWSClientesYOfertas.Total infoTotal;
        EntidadesWSClientesYOfertas.Instalacion infoInstalacion;
        EntidadesWSClientesYOfertas.InstalacionModular infoInstalacionMod;
        EntidadesWSClientesYOfertas.Producto infoProducto;
        EntidadesWSClientesYOfertas.PagoInversion infoPagoInversion;
        EntidadesWSClientesYOfertas.Productogas infoProdGas;
        EntidadesWSClientesYOfertas.PrimaServicios infoPrimaServ;
        EntidadesWSClientesYOfertas.Ajuste infoAjuste;
        EntidadesWSClientesYOfertas.Estandar infoEstandar;
        String mes;
        String dia;
        String anyo;
        try
        {
            if(quote != null)
            {
                oferta = new EntidadesWSClientesYOfertas.Oferta(String.valueOf(quote.Id));
                oferta.numPresupuesto = (quote.QuoteNumber == null ? '' : quote.QuoteNumber);
                oferta.fechaCreacion = (quote.CreatedDate == null ? '' : quote.CreatedDate.format('yyyy-MM-dd HH:mm:ss','Spain/Madrid'));
                //oferta.fechaCreacion = (quote.CreatedDate == null ? '' : String.valueOf(quote.CreatedDate));
                if(quote.Fecha_vigencia__c == null )
                {
                    oferta.fechaVigencia = '';
                }
                else
                {
                    dia = String.valueOf(quote.Fecha_vigencia__c.day());
                    while( dia.length() < 2 )
                        dia = '0' + dia;
                    mes = String.valueOf(quote.Fecha_vigencia__c.month());
                    while( mes.length() < 2 )
                        mes = '0' + mes;
                    anyo = String.valueOf(quote.Fecha_vigencia__c.year());
                    while(anyo.length() < 4)
                        anyo = '0' + anyo;
                    oferta.fechaVigencia = anyo + mes + dia;
                }
                oferta.duracionAnyos = (quote.Duracion_contratado__c == null ? '' : String.valueOf(quote.Duracion_contratado__c));
                oferta.estado = (quote.Status == null ? '' : quote.Status);
                oferta.observaciones = (quote.Observaciones__c == null ? '' : quote.Observaciones__c);
                
                oferta.notas = (quote.Notas__c == null ? '' : quote.Notas__c);
               
                oferta.enviarEmail = quote.Enviar_email__c ? '1' : '0';
                oferta.resolucionAnticipada = (quote.Resolucion_anticipada__c == null ? '' : String.valueOf(quote.Resolucion_anticipada__c));

                oferta.equiposInstalarPrimagas = new EntidadesWSClientesYOfertas.EquiposInstalarPrimagas(quote.Equipos_a_instalar_Primagas__c);
                
                // prioridades
                infoPrioridades = new EntidadesWSClientesYOfertas.Prioridades();
                infoPrioridades.comodidad = quote.Prioridades_comodidad__c ? '1' : '0';
                infoPrioridades.despreocuparse = quote.Prioridades_despreocuparse__c ? '1' : '0';
                infoPrioridades.enterrado = quote.Prioridades_enterrado__c ? '1' : '0';
                infoPrioridades.ahorroAnual = quote.Prioridades_ahorro_anual__c ? '1' : '0';
                infoPrioridades.precioRegulado = quote.Prioridades_precio_regulado__c ? '1' : '0';
                infoPrioridades.pagarConsumo = quote.Prioridades_pagar_consumo__c ? '1' : '0';
                infoPrioridades.precioFijo = quote.Prioridades_precio_fijo__c ? '1' : '0';
                infoPrioridades.tarifaPlana = quote.Prioridades_tarifa_plana__c ? '1' : '0';
                infoPrioridades.impacto = (quote.Prioridades_impacto__c == null ? '' : quote.Prioridades_impacto__c);
                oferta.prioridades = infoPrioridades;

                oferta.ahorroEstimado = new EntidadesWSClientesYOfertas.AhorroEstimado(String.valueOf(quote.Importe_total__c), String.valueOf(quote.Importe_total_primagas__c), String.valueOf(quote.Diferencia_importes_totales__c));

                // total
                infoTotal = new EntidadesWSClientesYOfertas.Total(String.valueOf(quote.Kg__c), String.valueOf(quote.KWh__c), String.valueOf(quote.Litros__c), String.valueOf(quote.KgCO2__c), String.valueOf(quote.Diferencia_kWh__c), String.valueOf(quote.Diferencia_kgCO2__c), String.valueOf(quote.KWh_Primagas__c), String.valueOf(quote.KgCO2_Primagas__c)); 

                // instalación
                infoInstalacion = new EntidadesWSClientesYOfertas.Instalacion();
                if( listaEquipos != null)
                    infoInstalacion.equipos = listaEquipos;
                if( listaEnergias != null)
                    infoInstalacion.energias = listaEnergias;
                infoInstalacion.total = infoTotal;
                oferta.instalacion = infoInstalacion;

                // comprobar el tipo de oferta para cumplimentar el resto de datos
                if(quote.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id)
                {
                    oferta.tipo = Util.constantesNewSales.get('TIPO_OFERTA_MODULAR');

                    // instalación
                    infoInstalacionMod = new EntidadesWSClientesYOfertas.InstalacionModular();
                    infoInstalacionMod.equipoInterior = (quote.Equipo_interior__c == null ? '' : quote.Equipo_interior__c);
                    infoInstalacionMod.costeEquipoInterior = (quote.Coste_equipo_interior__c == null ? '' : String.valueOf(quote.Coste_equipo_interior__c));
                    infoInstalacionMod.interior = quote.Interior__c ? '1' : '0';
                    infoInstalacionMod.costeInterior = (quote.Coste_interior__c == null ? '' : String.valueOf(quote.Coste_interior__c));
                    infoInstalacionMod.deposito = (quote.Deposito_nombre__c == null ? '' : String.valueOf(quote.Deposito_nombre__c));
                    infoInstalacionMod.costeDeposito = (quote.Coste_deposito__c == null ? '' : String.valueOf(quote.Coste_deposito__c));
                    infoInstalacionMod.exterior = quote.Exterior__c ? '1' : '0';
                    infoInstalacionMod.costeExterior = (quote.Coste_instalacion_exterior__c == null ? '' : String.valueOf(quote.Coste_instalacion_exterior__c));
                    infoInstalacionMod.vallado = quote.Vallado__c ? '1' : '0';
                    infoInstalacionMod.costeVallado = (quote.Coste_vallado__c == null ? '' : String.valueOf(quote.Coste_vallado__c));
                    infoInstalacionMod.obraCivil = quote.Obra_civil__c ? '1' : '0';
                    infoInstalacionMod.costeObraCivil = (quote.Coste_obra_civil__c == null ? '' : String.valueOf(quote.Coste_obra_civil__c));
                    infoInstalacionMod.totalInversion = (quote.Total_inversion__c == null ? '' : String.valueOf(quote.Total_inversion__c));
                    infoInstalacionMod.totalfinanciable = (quote.Total_financiable__c == null ? '' : String.valueOf(quote.Total_financiable__c));
                    infoInstalacionMod.pagoInicial = (quote.Pago_inicial__c == null ? '' : String.valueOf(quote.Pago_inicial__c));
                    infoInstalacionMod.tipoInteres = (quote.Tipo_de_interes__c == null ? '' : String.valueOf(quote.Tipo_de_interes__c));
                    infoInstalacionMod.instalacionInterior = (quote.Instalacion_interior__c == null ? '' : quote.Instalacion_interior__c);
                    infoInstalacionMod.costeInstalacionInterior = (quote.Coste_instalacion_interior__c == null ? '' : String.valueOf(quote.Coste_instalacion_interior__c));
                    infoInstalacionMod.costeProyectos = (quote.Coste_proyectos__c == null ? '' : String.valueOf(quote.Coste_proyectos__c));
                    infoInstalacionMod.proyectos = (quote.Proyectos__c == null ? '' : quote.Proyectos__c);
                    infoInstalacionMod.financiacionSeleccionada = (quote.Financiacion_seleccionada__c == null ? '' : quote.Financiacion_seleccionada__c);
                    infoInstalacionMod.numeroCuotas = (quote.Numero_de_cuotas__c == null ? '' : String.valueOf(quote.Numero_de_cuotas__c));
                    infoInstalacionMod.importeCuotas = (quote.Importe_de_cuotas__c == null ? '' : String.valueOf(quote.Importe_de_cuotas__c));
                    infoInstalacionMod.importeDoceCuotas = (quote.Importe_12_cuotas__c == null ? '' : String.valueOf(quote.Importe_12_cuotas__c));
                    infoInstalacionMod.importeEnGasEurosL = (quote.Importe_en_gas_en_E_L__c == null ? '' : String.valueOf(quote.Importe_en_gas_en_E_L__c));
                    infoInstalacionMod.importeEnGasEurosKg = (quote.Importe_en_gas_en_E_Kg__c == null ? '' : String.valueOf(quote.Importe_en_gas_en_E_Kg__c));
                    infoInstalacionMod.importeAhorroInstalacion = (quote.Importe_ahorro_instalacion__c == null ? '' : String.valueOf(quote.Importe_ahorro_instalacion__c));
                    infoInstalacionMod.aplicaTramo = quote.Aplica_tramos__c ? '1' : '0';
                    infoInstalacionMod.tramos = new List<EntidadesWSClientesYOfertas.Tramo>(listaTramosNormal);
    
                    // producto
                    infoProducto = new EntidadesWSClientesYOfertas.Producto();
                    infoProducto.precioMensualL = (quote.Precio_mensual_L__c == null ? '' : String.valueOf(quote.Precio_mensual_L__c));
                    infoProducto.precioFijoAnualL = (quote.Precio_fijo_anual_L__c == null ? '' : String.valueOf(quote.Precio_fijo_anual_L__c));
                    infoProducto.contadorL = (quote.Contador_L__c == null ? '' : String.valueOf(quote.Contador_L__c));
                    infoProducto.tarifaPlanaL = (quote.Tarifa_plana_L__c == null ? '' : String.valueOf(quote.Tarifa_plana_L__c));
                    infoProducto.precioMensualKg = (quote.Precio_mensual_Kg__c == null ? '' : String.valueOf(quote.Precio_mensual_Kg__c));
                    infoProducto.precioFijoAnualKg = (quote.Precio_fijo_anual_Kg__c == null ? '' : String.valueOf(quote.Precio_fijo_anual_Kg__c));
                    infoProducto.contadorKg = (quote.Contador_Kg__c == null ? '' : String.valueOf(quote.Contador_Kg__c));
                    infoProducto.tarifaPlanaKg = (quote.Tarifa_plana_Kg__c == null ? '' : String.valueOf(quote.Tarifa_plana_Kg__c));
                    infoProducto.nivelPB = (quote.Nivel_PB__c == null ? '' : quote.Nivel_PB__c);
                    infoProducto.fecha = (quote.Texto_fecha_producto__c == null ? '' : quote.Texto_fecha_producto__c);
                    infoProducto.opcionSeleccionada = (quote.Opcion_seleccionada_producto__c == null ? '' : quote.Opcion_seleccionada_producto__c);
                    infoProducto.importeAhorroGas = (quote.Importe_ahorro_gas__c == null ? '' : String.valueOf(quote.Importe_ahorro_gas__c));

                    //infoProducto.clv5 = (clv5 == null ? '' : clv5);
                    //infoProducto.clv10 = (clv10 == null ? '' : clv10);
                    //infoProducto.gp = (gp == null ? '' : gp);

                    // modular
                    oferta.modular = new EntidadesWSClientesYOfertas.Modular(infoInstalacionMod, packQuote, infoProducto);
                }
                else
                {
                    if(quote.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id)
                    {
                        oferta.tipo = Util.constantesNewSales.get('TIPO_OFERTA_PERSONALIZADA');

                        // Si tiene un tramo escalado principal, se indica
                        oferta.aplicarTramoEscalado = (quote.Tramo_escalado_a_aplicar__c == null ? '' : quote.Tramo_escalado_a_aplicar__c);

                        // tarifa
                        infoPagoInversion = new EntidadesWSClientesYOfertas.PagoInversion();
                        infoPagoInversion.tipo = (quote.Tipo_de_pago_inversion__c == null ? '' : quote.Tipo_de_pago_inversion__c);
                        infoPagoInversion.pagoIncial = (quote.Pago_inicial_inversion__c == null ? '' : String.valueOf(quote.Pago_inicial_inversion__c));
                        infoPagoInversion.cuotaInversion = (quote.Cuota_inversion__c == null ? '' : String.valueOf(quote.Cuota_inversion__c));
                        infoPagoInversion.duracionCuota = (quote.Duracion_cuota_inversion__c == null ? '' : String.valueOf(quote.Duracion_cuota_inversion__c));
                        infoPagoInversion.dto1llenado = (quote.Dto_1_Llenado_inversion__c == null ? '' : String.valueOf(quote.Dto_1_Llenado_inversion__c));

                        // producto gas
                        infoProdGas = new EntidadesWSClientesYOfertas.ProductoGas();
                        infoProdGas.tipo = (quote.Tipo_producto_gas__c == null ? '' : quote.Tipo_producto_gas__c);
                        infoProdGas.tarifa = (quote.Tipo_de_tarifa__c == null ? '' : quote.Tipo_de_tarifa__c);
                        infoProdGas.dto = (quote.Dto_Producto_gas__c == null ? '' : String.valueOf(quote.Dto_Producto_gas__c));
                        infoProdGas.duracionDto = (quote.Duracion_descuento__c == null ? '' : String.valueOf(quote.Duracion_descuento__c));
                        infoProdGas.precio = (quote.Precio_producto_gas__c == null ? '' : String.valueOf(quote.Precio_producto_gas__c));

                        // primaservicios
                        infoPrimaServ = new EntidadesWSClientesYOfertas.PrimaServicios();
                        infoPrimaServ.tipo = (quote.Tipo_Primaservicios__c == null ? '' : quote.Tipo_Primaservicios__c);
                        infoPrimaServ.mto = (quote.Mantenimiento_primaservicios__c ? '1' : '0');
                        infoPrimaServ.inspeccionInterior = (quote.Inspeccion_interior_primaservicios__c ? '1' : '0');
                        infoPrimaServ.revisionInterior = (quote.Revision_interior_primaservicios__c ? '1' : '0');
                        infoPrimaServ.precio = (quote.Precio_Primaservicios__c == null ? '' : String.valueOf(quote.Precio_Primaservicios__c));

                        // personalizada
                        oferta.personalizada = new EntidadesWSClientesYOfertas.Ajuste(listaDepositos, listaEquiposAjuste, infoPagoInversion, infoProdGas, infoPrimaServ, listaTramosEscalado);
                    }
                    else
                    {
                        if(quote.RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id)
                        {
                            oferta.tipo = Util.constantesNewSales.get('TIPO_OFERTA_ESTANDAR');

                            // estandar
                            infoEstandar = new EntidadesWSClientesYOfertas.Estandar();
                            infoEstandar.tipoOferta = (quote.Name == null ? '' : quote.Name);
                            infoEstandar.interior = (quote.Interior_estandar__c == null ? '' : quote.Interior_estandar__c);
                            infoEstandar.exterior = (quote.Exterior_estandar__c == null ? '' : quote.Exterior_estandar__c);
                            infoEstandar.servicio = (quote.Servicio_estandar__c == null ? '' : quote.Servicio_estandar__c);
                            infoEstandar.consumoContratado = (quote.Consumo_contratado_L__c == null ? '' : (String.valueOf(quote.Consumo_contratado_L__c) + ' l')) 
                                                            + ' (' + (quote.Consumo_contratado_kg__c == null ? '' : (String.valueOf(quote.Consumo_contratado_kg__c) + ' kg')) + ')'; 
                            infoEstandar.tarifa = (quote.Tarifa_estandar__c == null ? '' : quote.Tarifa_estandar__c);
                            infoEstandar.dto = (quote.Dto_Estandar__c == null ? '' : String.valueOf(quote.Dto_Estandar__c));
                            infoEstandar.duracionDto = (quote.Duracion_descuento__c == null ? '' : String.valueOf(quote.Duracion_descuento__c));
                            infoEstandar.texto = (quote.Texto_servicio_estandar__c == null ? '' : quote.Texto_servicio_estandar__c);
                            infoEstandar.pagoInicial = (quote.Pago_inicial__c == null ? '' : String.valueOf(quote.Pago_inicial__c));
                            infoEstandar.precioFecha = (quote.Precio_fecha__c == null ? '' : quote.Precio_fecha__c);
                            infoEstandar.precioL = (quote.Precio_L__c == null ? '' : String.valueOf(quote.Precio_L__c));
                            infoEstandar.precioKg = (quote.Precio_Kg__c == null ? '' : String.valueOf(quote.Precio_Kg__c));
                            infoEstandar.servicioValor = (quote.Valor_del_servicio_estandar__c == null ? '' : String.valueOf(quote.Valor_del_servicio_estandar__c));
                            infoEstandar.idSalesforce = (quote.Name_OpcionesOfertaSTD_maestro__c == null ? '' : String.valueOf(quote.Name_OpcionesOfertaSTD_maestro__c));
                            infoEstandar.idSalesforceTipoOferta = (quote.Name_ImagenesOferta_maestro__c == null ? '' : String.valueOf(quote.Name_ImagenesOferta_maestro__c));
                            oferta.estandar = infoEstandar;
                        }
                    }
                }
                system.debug('oferta: ' + oferta);
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción al crear oferta con quote: ' + ex.getMessage());
        }
        return oferta;
    }

    //Cambios rfernandez (07/03/2017)
    /**
    * Función encargada de eliminar caracteres especiales para realizar búsquedas SOSL
    * @param text Texto al que se le van a quitar caracteres especiales
    * @author rfernandez (07/03/2017)
    * @modificaciones 
    */
    public static String limpiarSosl( String text ) 
    {
        //Caracteres especiales para las SOSL --> ? & | ! { } [ ] ( ) ^ ~ * : \ " ' + -
        text = text.replaceAll('[?]', '');
        text = text.replaceAll('[&]', '');
        text = text.replaceAll('[|]', '');
        text = text.replaceAll('[!]', '');
        text = text.replaceAll('[{]', '');
        text = text.replaceAll('[}]', '');
        text = text.replaceAll('[(]', '');
        text = text.replaceAll('[)]', '');
        text = text.replaceAll('[~]', '');
        text = text.replaceAll('[*]', '');
        text = text.replaceAll('[:]', '');
        text = text.replaceAll('["]', '');
        text = text.replaceAll('[+]', '');
        text = text.replaceAll('[-]', '');
        return text;
    }
    //Fin cambios rfernandez

    global class PeticionDatosBusqueda
    {
        public DatosBusqueda datosBusqueda;
    }

    public class DatosBusqueda
    {
        public String nombre {get;set;}
        public String apellido {get;set;}
        public String telefono {get;set;}
        public String telefonoMovil {get;set;}
        public String compania {get;set;}
        public List<OfertaIdPeticion> ofertas {get;set;}
    }

    public class OfertaIdPeticion
    {
        public String identificador {get;set;}

        public OfertaIdPeticion(String pId)
        {
            this.identificador = (pId == null ? '' : pId);
        }
    }

    public class OfertaId
    {
        public String identificador {get;set;}
        public String numPresupuesto {get;set;}
        public String estado {get;set;}
        public String fechaCreacion {get;set;}
        public String tipo {get;set;}
        public String notas {get;set;}

        public OfertaId(String pId, String pNumPresupuesto, String pEstado, String pFechaCreacion, String pTipo, String pNotas)
        {
            this.identificador = (pId == null ? '' : pId);
            this.numPresupuesto = (pNumPresupuesto == null ? '' : pNumPresupuesto);
            this.estado = (pEstado == null ? '' : pEstado);
            this.fechaCreacion = (pFechaCreacion == null ? '' : pFechaCreacion);
            this.tipo = (pTipo == null ? '' : pTipo);
            this.notas = (pNotas == null ? '' : pNotas);
        }
    }

    public class RespuestaSoloIds
    {   
        public Resultado resultado {get;set;}
        public List<ClienteYOportunidadesIds> datosBusqueda {get;set;}

        public RespuestaSoloIds()
        {
            resultado = new Resultado();
            datosBusqueda = new  List<ClienteYOportunidadesIds>();
        }
    }

    public class ClienteYOportunidadesIds
    {   
        public EntidadesWSClientesYOfertas.DatosCliente datosCliente {get;set;}
        public List<OportunidadId> oportunidades {get;set;}

        public ClienteYOportunidadesIds()
        {
            datosCliente = new EntidadesWSClientesYOfertas.DatosCliente();
            oportunidades = new List<OportunidadId>();
        }
    }

    public class Respuesta
    {   
        public Resultado resultado {get;set;}
        public List<ClienteYOportunidades> datosBusqueda {get;set;}

        public Respuesta()
        {
            resultado = new Resultado();
            datosBusqueda = new  List<ClienteYOportunidades>();
        }
    }

    public class ClienteYOportunidades
    {   
        public EntidadesWSClientesYOfertas.DatosCliente datosCliente {get;set;}
        public List<Oportunidad> oportunidades {get;set;}

        public ClienteYOportunidades()
        {
            datosCliente = new EntidadesWSClientesYOfertas.DatosCliente();
            oportunidades = new List<Oportunidad>();
        }
    }

    public class Resultado 
    {
        public String codigo {get;set;}
        public String texto {get;set;}
        public Resultado()
        {
            this.codigo = '';
            this.texto = '';
        }
    }

    public class Oportunidad
    {
        public String identificador {get;set;} // identificador de la oportunidad
        public String nombre {get;set;}
        public List<EntidadesWSClientesYOfertas.Oferta> ofertas {get;set;}
        public List<EntidadesWSClientesYOfertas.Energia> energias {get;set;}
        public String prescriptor {get;set;} // información del prescriptor del cliente
        public String canal {get;set;} // descripción del canal del cliente     
        public String fechaCreacion {get;set;} // formato yyyyMMdd

        public Oportunidad(String pId, String pNombre, List<EntidadesWSClientesYOfertas.Oferta> pListaofertas, List<EntidadesWSClientesYOfertas.Energia> pListaenergias, String pPrescriptor, String pCanal, String pFechaCreacion)
        {
            this.identificador = (pId == null ? '' : pId);
            this.nombre = (pNombre == null ? '' : pNombre);
            if(pListaofertas == null)
            {
                this.ofertas = new List<EntidadesWSClientesYOfertas.Oferta>();
            }
            else
            {
                this.ofertas = new List<EntidadesWSClientesYOfertas.Oferta>(pListaofertas);
            }
            if(pListaenergias == null)
            {
                this.energias = new List<EntidadesWSClientesYOfertas.Energia>();
            }
            else
            {
                this.energias = new List<EntidadesWSClientesYOfertas.Energia>(pListaenergias);
            }
            this.prescriptor = (pPrescriptor == null ? '' : pPrescriptor);
            this.canal = (pCanal == null ? '' : pCanal);            
            this.fechaCreacion = (pFechaCreacion == null ? '' : pFechaCreacion);
        }
    }

    public class OportunidadId
    {
        public String identificador {get;set;}
        public String nombre {get;set;}
        public List<OfertaId> ofertas {get;set;}
        public List<EntidadesWSClientesYOfertas.Energia> energias {get;set;}
        public String prescriptor {get;set;} // información del prescriptor del cliente
        public String canal {get;set;} // descripción del canal del cliente     
        public String fechaCreacion {get;set;} // formato yyyyMMdd

        public OportunidadId(String pId, String pNombre, List<OfertaId> pOfertas, List<EntidadesWSClientesYOfertas.Energia> pListaenergias, String pPrescriptor, String pCanal, String pFechaCreacion)
        {
            this.identificador = (pId == null ? '' : pId);
            this.nombre = (pNombre == null ? '' : pNombre);
            if(pOfertas == null)
            {
                this.ofertas = new List<OfertaId>();
            }
            else
            {
                this.ofertas = pOfertas;
            }         
            if(pListaenergias == null)
            {
                this.energias = new List<EntidadesWSClientesYOfertas.Energia>();
            }
            else
            {
                this.energias = new List<EntidadesWSClientesYOfertas.Energia>(pListaenergias);
            }
            this.prescriptor = (pPrescriptor == null ? '' : pPrescriptor);
            this.canal = (pCanal == null ? '' : pCanal);            
            this.fechaCreacion = (pFechaCreacion == null ? '' : pFechaCreacion);
        }
    }
}