@isTest
private class TEST_WSDatosContrato
{
    @isTest static void peticionEnviarConDatosIncorrectos() 
    {
        WSDatosContrato.PeticionDatosContrato peticion = new WSDatosContrato.PeticionDatosContrato();
        peticion.datosContrato = null;

        Test.startTest();
        String jDatos = WSDatosContrato.enviar(peticion);
        Test.stopTest();

        WSDatosContrato.Respuesta r = (WSDatosContrato.Respuesta) JSON.deserialize(jDatos, WSDatosContrato.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('801', r.resultado.codigo);
    }

    @isTest static void peticionEnviarConDatosCorrectos() 
    {
        WSDatosContrato.PeticionDatosContrato peticion = new WSDatosContrato.PeticionDatosContrato();
        peticion.datosContrato = new WSDatosContrato.DatosContrato();
        peticion.datosCliente = new EntidadesWSClientesYOfertas.DatosCliente();
        peticion.datosOferta = new WSDatosContrato.DatosOferta();

        //Creo el presupuesto al que estará asociado el contrato, la oportunidad a la que estará asociado el presupuesto y
        //la cuenta a la que estará asociada la oportunidad. También creo la dirección de entrega asociada a la cuenta
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta prueba';
        cuenta.Id_Fiscal__c = '11111111A';
        cuenta.RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Cliente').Id;
        insert cuenta;

        Direcci_n_de_entrega__c dirEntrega = new Direcci_n_de_entrega__c();
        dirEntrega.Direccion__c = 'Calle test';
        dirEntrega.Poblacion__c = 'Población test';
        dirEntrega.Codigo_Postal__c = '11111';
        dirEntrega.Actividad_1__c = 'Actividad test';
        dirEntrega.Actividad_2__c = 'Subactividad test';
        dirEntrega.Tipo_de_camion__c = '';
        dirEntrega.Cuenta__c = cuenta.Id;
        insert dirEntrega;

        Opportunity oportunidad = new Opportunity();
        oportunidad.Name = 'Oportunidad prueba';
        oportunidad.AccountId = cuenta.Id;
        oportunidad.LeadSource = 'Prescriptor';
        oportunidad.CloseDate = Date.today();
        oportunidad.StageName = 'Identificada';
        oportunidad.Estimaci_n_consumo_en_kilos__c = 10;
        insert oportunidad;

        Contact contacto = new Contact();
        contacto.LastName = 'Contacto prueba';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        OpportunityContactRole contactoRol = new OpportunityContactRole();
        contactoRol.ContactId = contacto.Id;
        contactoRol.OpportunityId = oportunidad.Id;
        contactoRol.Role = 'Firmante de contrato';
        insert contactoRol;

        Quote presupuesto = new Quote();
        presupuesto.Name = 'Presupuesto prueba';
        presupuesto.OpportunityId = oportunidad.Id;
        presupuesto.Origen__c = 'web';
        presupuesto.Origen_tipo_cliente__c = 'Cambio botellas';
        presupuesto.Provincia_env_o__c = 'VIZCAYA';
        presupuesto.NIF_CIF__c = '11111111A';
        presupuesto.Resolucion_anticipada__c = 11;
        insert presupuesto;

        //datosContrato
        peticion.datosContrato.idOfertaSF = presupuesto.Id;
        peticion.datosContrato.numContrato = '00001';
        peticion.datosContrato.plazoPago = '5';
        peticion.datosContrato.numTramoDto = '1';
        peticion.datosContrato.pagoFraccionado = '1';
        peticion.datosContrato.compraventaMinima = '12000';
        peticion.datosContrato.observacionesEquipos = 'Prueba observaciones equipos';
        peticion.datosContrato.tipoCamion = '7';
        peticion.datosContrato.coordenadasGPS = '40.123456,50.567891';
        peticion.datosContrato.terminos_pago = '005';
        peticion.datosContrato.forma_pago = 'CHEQUE';
        String dia;
        if(Date.today().day()<10)
        {
            dia = '0' + String.valueOf(Date.today().day());
        }
        else
        {
            dia = String.valueOf(Date.today().day());
        }
        String mes;
        if(Date.today().month()<10)
        {
            mes = '0' + String.valueOf(Date.today().month());
        }
        else
        {
            mes = String.valueOf(Date.today().month());
        }   
        String anyo = String.valueOf(Date.today().year());
        peticion.datosContrato.fecha_prevista_obra_civil = anyo + mes + dia;
        peticion.datosContrato.fecha_firma_cliente = anyo + mes + dia;
        peticion.datosContrato.iban = 'ES5820381787493000637569';
        peticion.datosContrato.fecha_prevista_1er_llenado = anyo + mes + dia;
        peticion.datosContrato.coste_resolucion_anticipada_toneladas = '11';

        Proveedor__c proveedor = new Proveedor__c();
        insert proveedor;

        //Creo una cuenta de tipo partner
        RecordType tipoRegistroPartner = Util.objectsRecordTypesMap.get('Account').get('Partner');
        Account partner = new Account();
        partner.Name = 'Partner prueba';
        partner.Prescriptor__c = proveedor.Id;
        partner.Id_Fiscal__c = '22222222A';
        partner.RecordTypeId = tipoRegistroPartner.Id;
        insert partner;

        //DMLs y asignaciones de campos no permitidas para OpportunityPartner
        Partner partner2 = new Partner();
        //partner2.AccountFromId = cuenta.Id;
        partner2.AccountToId = partner.Id;
        partner2.OpportunityId = oportunidad.Id;
        insert partner2;

        peticion.datosContrato.instalador = partner.Id;
        peticion.datosContrato.uso = 'Carburante';
        peticion.datosContrato.ritmoConsumo = 'Regular';
        peticion.datosContrato.titularDerechos = 'Propiedad';
        peticion.datosContrato.toma_agua_15_m = 'false';

        peticion.datosContrato.proyectista = partner.Id; 
        peticion.datosContrato.descripcionUbicacionDeposito = 'Ubicación prueba';
        peticion.datosContrato.equiposInstalacion = 'Equipos prueba';
        peticion.datosContrato.responsabilidad_cliente = WSDatosContrato.RESP_PROYECTO_EXTERIOR + ';' + WSDatosContrato.RESP_OBRA_CIVIL_DEPOSITO + ';' + 
                                                        WSDatosContrato.RESP_OBRA_CIVIL_TUBERIA + ';' + WSDatosContrato.RESP_ENTREGA + ';' + WSDatosContrato.RESP_OTROS;
        peticion.datosContrato.responsabilidad_primagas = WSDatosContrato.RESP_VALLADO + ';' + WSDatosContrato.RESP_INSTALACION_INTERIOR + ';' + 
                                                        WSDatosContrato.RESP_INSTALACION_EXTERIOR + ';' + WSDatosContrato.RESP_PRESENTACION_AYUNTAMIENTO + ';' + WSDatosContrato.RESP_PROYECTO_INTERIOR;
        peticion.datosContrato.directorio_pdf = 'url/Clientes/hotelDulce.pdf';
        peticion.datosContrato.coberturaMovil = '1';
        peticion.datosContrato.otros = 'Otros prueba (cliente)';

        //datosCliente
        peticion.datosCliente.nombre = 'Nombre test';
        peticion.datosCliente.apellidos = 'Apellidos test';
        peticion.datosCliente.dni = '12345678E';
        peticion.datosCliente.cif = '00000000L';
        peticion.datosCliente.identificador = cuenta.Id; 
        peticion.datosCliente.compania = 'Compañía test';
        peticion.datosCliente.telefono = '900000000';
        peticion.datosCliente.telefonoMovil = '600000000';
        peticion.datosCliente.fax = '911111111';
        peticion.datosCliente.email = 'test@test.com';
        peticion.datosCliente.calle = 'Calle test';
        peticion.datosCliente.calleFacturacion = 'Calle facturación test';
        peticion.datosCliente.provincia = 'Provincia test';
        peticion.datosCliente.provinciaFacturacion = 'Provincia facturación test';
        peticion.datosCliente.cp = '11111';
        peticion.datosCliente.cpFacturacion = '22222';     
        peticion.datosCliente.poblacion = 'Población test';
        peticion.datosCliente.poblacionFacturacion = 'Población facturación test';
        peticion.datosCliente.actividad = 'Actividad test';
        peticion.datosCliente.subactividad = 'Subactividad test';

        Test.startTest();
        String jDatos = WSDatosContrato.enviar(peticion);
        Test.stopTest();

        WSDatosContrato.Respuesta r = (WSDatosContrato.Respuesta) JSON.deserialize(jDatos, WSDatosContrato.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('800', r.resultado.codigo);

        List<Contract> contrato = [SELECT Id, Numero_de_contrato_app__c, AccountId, BillingStreet, BillingCity, BillingPostalCode, BillingState, Plazo_de_pagos__c, 
                                    Pago_fraccionado__c, Compraventa_minima_en_kg__c, Duraci_n_del_contrato_a_os__c, Observaciones_equipos__c, 
                                    Coordenadas_GPS__Latitude__s, Coordenadas_GPS__Longitude__s, Cod_forma_de_pago__c, 
                                    Fecha_prevista_obra_civil__c, CustomerSignedDate, IBAN__c, Fecha_prevista_1er_llenado__c,
                                    Coste_resolucion_anticipada__c, Instalador__c, Uso__c, Perfil_de_consumo__c, Derechos_de_titular__c, Toma_agua_15_m__c, N_fax__c, Proyectista__c, 
                                    Ubicacion_deposito__c, 
                                    Equipos_instalacion__c, Proyecto_exterior_memoria__c, Obra_civil_deposito__c, Obra_civil_tuberia__c, Entrega_y_colocacion_deposito__c, Vallado__c, 
                                    Instalacion_y_certificado_interior__c, Instalacion_exterior__c, Presentacion_en_ayuntamiento__c, Proyecto_interior__c, Directorio_pdf__c, Otros_cliente__c, 
                                    Otros_primagas__c, Cobertura_movil__c, RecordTypeId, Status, CustomerSignedId, Tramo_con_descuento__c
                                    FROM Contract];
                                    
        System.assertEquals(1, contrato.size());

        //Compruebo el tipo de registro
        RecordType d = Util.objectsRecordTypesMap.get('Contract').get('GLP');  
        System.assertEquals(d.Id, contrato[0].RecordTypeId);

        //Compruebo los campos de contrato
        System.assertEquals(peticion.datosContrato.numContrato, contrato[0].Numero_de_contrato_app__c);
        System.assertEquals(cuenta.Id, contrato[0].AccountId);
        System.assertEquals(peticion.datosCliente.calleFacturacion, contrato[0].BillingStreet);
        System.assertEquals(peticion.datosCliente.poblacionFacturacion, contrato[0].BillingCity);
        System.assertEquals(peticion.datosCliente.cpFacturacion, contrato[0].BillingPostalCode);
        System.assertEquals(peticion.datosCliente.provinciaFacturacion, contrato[0].BillingState);
        System.assertEquals(peticion.datosContrato.plazoPago, contrato[0].Plazo_de_pagos__c);
        //Cambios rfernandez (06/03/2017)
        //System.assertEquals(Double.valueOf(peticion.datosContrato.numTramoDto), contrato[0].Tramo_con_descuento__c);
        System.assertEquals(peticion.datosContrato.numTramoDto, contrato[0].Tramo_con_descuento__c);
        //Fin cambios rfernandez
        System.assertEquals(true, contrato[0].Pago_fraccionado__c);
        System.assertEquals(Double.valueOf(peticion.datosContrato.compraventaMinima), contrato[0].Compraventa_minima_en_kg__c);
        System.assertEquals(peticion.datosContrato.observacionesEquipos, contrato[0].Observaciones_equipos__c);
        System.assertEquals(40.123456, contrato[0].Coordenadas_GPS__Latitude__s);
        System.assertEquals(50.567891, contrato[0].Coordenadas_GPS__Longitude__s);
        System.assertEquals(peticion.datosContrato.forma_pago, contrato[0].Cod_forma_de_pago__c);
        System.assertEquals(System.today(), contrato[0].Fecha_prevista_obra_civil__c);
        System.assertEquals(System.today(), contrato[0].CustomerSignedDate);
        System.assertEquals(peticion.datosContrato.iban, contrato[0].IBAN__c);
        System.assertEquals(System.today(), contrato[0].Fecha_prevista_1er_llenado__c);
        System.assertEquals(presupuesto.Resolucion_anticipada__c, contrato[0].Coste_resolucion_anticipada__c);
        System.assertEquals(partner.Id, contrato[0].Instalador__c);
        System.assertEquals(peticion.datosContrato.uso, contrato[0].Uso__c);
        System.assertEquals(peticion.datosContrato.ritmoConsumo, contrato[0].Perfil_de_consumo__c);
        System.assertEquals(peticion.datosContrato.titularDerechos, contrato[0].Derechos_de_titular__c);
        System.assertEquals(false, contrato[0].Toma_agua_15_m__c);
        System.assertEquals(peticion.datosCliente.fax, contrato[0].N_fax__c);
        System.assertEquals(partner.Id, contrato[0].Proyectista__c);
        System.assertEquals(peticion.datosContrato.descripcionUbicacionDeposito, contrato[0].Ubicacion_deposito__c);
        System.assertEquals(peticion.datosContrato.equiposInstalacion, contrato[0].Equipos_instalacion__c);
        System.assertEquals('CLIENTE', contrato[0].Proyecto_exterior_memoria__c);
        System.assertEquals('CLIENTE', contrato[0].Obra_civil_deposito__c);
        System.assertEquals('CLIENTE', contrato[0].Obra_civil_tuberia__c);
        System.assertEquals('CLIENTE', contrato[0].Entrega_y_colocacion_deposito__c);
        System.assertEquals('PRIMAGAS', contrato[0].Vallado__c);
        System.assertEquals('PRIMAGAS', contrato[0].Instalacion_y_certificado_interior__c);
        System.assertEquals('PRIMAGAS', contrato[0].Instalacion_exterior__c);
        System.assertEquals('PRIMAGAS', contrato[0].Presentacion_en_ayuntamiento__c);
        System.assertEquals('PRIMAGAS', contrato[0].Proyecto_interior__c);
        System.assertEquals(peticion.datosContrato.otros, contrato[0].Otros_cliente__c);
        System.assertEquals(null, contrato[0].Otros_primagas__c);
        System.assertEquals(peticion.datosContrato.directorio_pdf, contrato[0].Directorio_pdf__c);
        System.assertEquals(true, contrato[0].Cobertura_movil__c);

        //Compruebo que el presupuesto tiene asociado el nuevo contrato
        presupuesto = [SELECT Id, ContractId FROM Quote WHERE Id=: presupuesto.Id];
        System.assertEquals(contrato[0].Id, presupuesto.ContractId);

        //Compruebo que la oportunidad tiene asociado el nuevo contrato
        oportunidad = [SELECT Id, ContractId, SyncedQuoteId FROM Opportunity WHERE Id=: oportunidad.Id];
        System.assertEquals(contrato[0].Id, oportunidad.ContractId);

        //Compruebo que la oportunidad tiene el presupuesto sincronizado
        System.assertEquals(presupuesto.Id, oportunidad.SyncedQuoteId);

        //Compruebo que se ha actualizado el CIF de la cuenta
        cuenta = [SELECT Id, Id_Fiscal__c FROM Account WHERE Id=: cuenta.Id];
        System.assertEquals(peticion.datosCliente.cif, cuenta.Id_Fiscal__c);

        //Compruebo que se ha rellenado el DNI del contacto
        contacto = [SELECT Id, DNI__c FROM Contact WHERE Id=: contacto.Id];
        System.assertEquals(peticion.datosCliente.dni, contacto.DNI__c);

        //Compruebo que el presupuesto está firmado por el contacto
        System.assertEquals(contacto.Id, contrato[0].CustomerSignedId);     

        //Compruebo que el contrato se ha enviado correctamente a aprobación y está en estado "Pendiente de registrar"
        System.assertEquals('Pendiente de registrar', contrato[0].Status);
    }
}