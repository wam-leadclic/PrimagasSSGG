@isTest
private class TEST_WSDatosClienteYOfertas
{
    @isTest static void peticionConDatosIncorrectos() 
    {
        // preparar petición
        WSDatosClienteYOfertas.PeticionDatosBusqueda peticion = new WSDatosClienteYOfertas.PeticionDatosBusqueda();
        peticion.datosBusqueda = null;

        // ejecutar test
        Test.startTest();
        String jDatos = WSDatosClienteYOfertas.getDatosCliente(peticion);
        Test.stopTest();

        // comprobar resultado
        WSDatosClienteYOfertas.Respuesta r = (WSDatosClienteYOfertas.Respuesta) JSON.deserialize(jDatos, WSDatosClienteYOfertas.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('501', r.resultado.codigo);
    }

    @isTest static void peticionSinDatosCliente()
    {
        // preparar petición
        WSDatosClienteYOfertas.PeticionDatosBusqueda peticion = new WSDatosClienteYOfertas.PeticionDatosBusqueda();
        peticion.datosBusqueda = new WSDatosClienteYOfertas.DatosBusqueda();
        peticion.datosBusqueda.telefono = 'TEST';
        peticion.datosBusqueda.nombre = 'NOMBRE_TEST';
        peticion.datosBusqueda.ofertas = new List<WSDatosClienteYOfertas.OfertaIdPeticion>();

        // ejecutar test
        Test.startTest();
        String jDatos = WSDatosClienteYOfertas.getDatosCliente(peticion);
        Test.stopTest();

        // comprobar resultado
        WSDatosClienteYOfertas.Respuesta r = (WSDatosClienteYOfertas.Respuesta) JSON.deserialize(jDatos, WSDatosClienteYOfertas.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('503', r.resultado.codigo);
    }

    @isTest static void peticionConDatosClienteSinOfertasAsociadas()
    {
        // preparar datos
        Account proveedor = new Account();
        proveedor.RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Partner').Id;
        proveedor.Name = 'Proveedor';
        insert proveedor;

        Account a = new Account();
        a.Name = 'EMPRESA';
        a.Id_fiscal__c = 'G08245474';
        a.ShippingStreet = 'calleTest';
        a.ShippingState = 'provinciaTest';
        a.ShippingPostalCode = '54321';
        a.Actividad__c = 'ActTest';
        a.ShippingCity = 'PoblaciónTest';
        a.Sub_actividad__c = 'SubActTest';
        a.Provincia__c = 'provFactTest'; 
        a.Codigo_Postal__c = '12345';
        a.Calle_Facturacion__c = 'calle fact test';
        a.Poblacion_Facturacion__c = 'poblaciónFact test';
        a.Prescriptor_Cuenta__c = proveedor.Id;
        insert a;

        Direcci_n_de_entrega__c d = new Direcci_n_de_entrega__c(cuenta__c = a.Id, Direccion__c='calleTest', Poblacion__c= 'PoblaciónTest', Codigo_Postal__c='54321', 
                                                                Provincia__c='provinciaTest', Actividad_1__c='ActTest', Actividad_2__c='SubActTest');
        insert d;
        
        Contact c = new Contact();
        c.FirstName = 'ClienteTest';
        c.LastName = 'NTS';
        c.Phone = '123456789';
        c.MobilePhone = '9887654321';
        c.Fax = '458521458';
        c.Email = 'emailtest@nts.com';
        c.DNI__c = '63731990W';
        c.AccountId = a.Id;
        insert c;

        //Cambios rfernandez (15/03/2017)
        //Necesario para las queries SOSL, forzando que se indexe ese registro para poder realizar las busquedas
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        //Fin de cambios rfernanez

        // preparar petición
        WSDatosClienteYOfertas.PeticionDatosBusqueda peticion = new WSDatosClienteYOfertas.PeticionDatosBusqueda();
        peticion.datosBusqueda = new WSDatosClienteYOfertas.DatosBusqueda();
        peticion.datosBusqueda.telefono = '123456789';
        peticion.datosBusqueda.nombre = 'ClienteTest';
        peticion.datosBusqueda.ofertas = new List<WSDatosClienteYOfertas.OfertaIdPeticion>();

        // ejecutar test
        Test.startTest();
        String jDatos = WSDatosClienteYOfertas.getDatosCliente(peticion);
        Test.stopTest();

        // comprobar resultado
        WSDatosClienteYOfertas.Respuesta r = (WSDatosClienteYOfertas.Respuesta) JSON.deserialize(jDatos, WSDatosClienteYOfertas.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('500', r.resultado.codigo);
        System.assertEquals(c.FirstName, r.datosBusqueda[0].datosCliente.nombre);
        System.assertEquals(c.Lastname, r.datosBusqueda[0].datosCliente.apellidos);
        System.assertEquals(a.Name, r.datosBusqueda[0].datosCliente.compania);
        System.assertEquals(c.Phone, r.datosBusqueda[0].datosCliente.telefono);
        System.assertEquals(c.MobilePhone, r.datosBusqueda[0].datosCliente.telefonoMovil);
        System.assertEquals(c.Email, r.datosBusqueda[0].datosCliente.email);
        System.assertEquals(a.ShippingStreet, r.datosBusqueda[0].datosCliente.calle);
        System.assertEquals(a.ShippingState, r.datosBusqueda[0].datosCliente.provincia);
        System.assertEquals(a.ShippingPostalCode, r.datosBusqueda[0].datosCliente.cp);
        System.assertEquals(a.Actividad__c, r.datosBusqueda[0].datosCliente.actividad);
        System.assertEquals(a.ShippingCity, r.datosBusqueda[0].datosCliente.poblacion);
        System.assertEquals(a.Sub_actividad__c, r.datosBusqueda[0].datosCliente.subactividad);
        System.assertEquals(a.Calle_Facturacion__c, r.datosBusqueda[0].datosCliente.calleFacturacion);
        System.assertEquals(a.Provincia__c, r.datosBusqueda[0].datosCliente.provinciaFacturacion);
        System.assertEquals(a.Poblacion_Facturacion__c, r.datosBusqueda[0].datosCliente.poblacionFacturacion);
        System.assertEquals(a.Codigo_Postal__c, r.datosBusqueda[0].datosCliente.cpFacturacion);
        System.assert(r.datosBusqueda[0].oportunidades == null || r.datosBusqueda[0].oportunidades.isEmpty());
    }

    @isTest static void peticionConDatosClienteConOfertasAsociadas()
    {
        // preparar datos
        Account proveedor = new Account();
        proveedor.RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Partner').Id;
        proveedor.Name = 'Proveedor';
        insert proveedor;

        Account a = new Account();
        a.Name = 'EMPRESA';
        a.Id_fiscal__c = 'G08245474';
        a.ShippingStreet = 'calleTest';
        a.ShippingState = 'provinciaTest';
        a.ShippingPostalCode = '54321';
        a.Actividad__c = 'ActTest';
        a.ShippingCity = 'PoblaciónTest';
        a.Sub_actividad__c = 'SubActTest';
        a.Provincia__c = 'provFactTest'; 
        a.Codigo_Postal__c = '12345';
        a.Calle_Facturacion__c = 'calle fact test';
        a.Poblacion_Facturacion__c = 'poblaciónFact test';
        a.Prescriptor_Cuenta__c = proveedor.Id;
        insert a;

        Direcci_n_de_entrega__c d = new Direcci_n_de_entrega__c(cuenta__c = a.Id, Direccion__c='calleTest', Poblacion__c= 'PoblaciónTest', Codigo_Postal__c='54321', 
                                                                Provincia__c='provinciaTest', Actividad_1__c='ActTest', Actividad_2__c='SubActTest');
        insert d;

        Contact c = new Contact();
        c.FirstName = 'ClienteTest';
        c.LastName = 'NTS';
        c.Phone = '123456789';
        c.MobilePhone = '987654321';
        c.Fax = '458521458';
        c.Email = 'emailtest@nts.com';
        c.AccountId = a.Id;
        c.DNI__c = '63731990W';
        insert c;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Opportunity op = new Opportunity();
        op.Name ='OpTest';
        op.StageName = 'Identificada';
        op.CloseDate = Date.today();
        op.AccountId = a.Id;
        insert op;

        OpportunityContactRole opcr = new OpportunityContactRole();
        opcr.OpportunityId = op.Id;
        opcr.ContactId = c.Id;
        insert opcr;

        Quote q = new Quote();
        q.Name = 'OfTest';
        q.Status = 'Preparando';
        q.OpportunityId = op.Id;
        insert q;

        // preparar petición
        WSDatosClienteYOfertas.PeticionDatosBusqueda peticion = new WSDatosClienteYOfertas.PeticionDatosBusqueda();
        peticion.datosBusqueda = new WSDatosClienteYOfertas.DatosBusqueda();
        peticion.datosBusqueda.telefono = '123456789';
        peticion.datosBusqueda.nombre = 'ClienteTest';
        peticion.datosBusqueda.ofertas = new List<WSDatosClienteYOfertas.OfertaIdPeticion>();

        // ejecutar test
        Test.startTest();
        String jDatos = WSDatosClienteYOfertas.getDatosCliente(peticion);
        Test.stopTest();

        // comprobar resultado
        WSDatosClienteYOfertas.Respuesta r = (WSDatosClienteYOfertas.Respuesta) JSON.deserialize(jDatos, WSDatosClienteYOfertas.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('500', r.resultado.codigo);
        System.assertEquals(c.FirstName, r.datosBusqueda[0].datosCliente.nombre);
        System.assertEquals(c.Lastname, r.datosBusqueda[0].datosCliente.apellidos);
        System.assertEquals(a.Name, r.datosBusqueda[0].datosCliente.compania);
        System.assertEquals(c.Phone, r.datosBusqueda[0].datosCliente.telefono);
        System.assertEquals(c.MobilePhone, r.datosBusqueda[0].datosCliente.telefonoMovil);
        System.assertEquals(c.Email, r.datosBusqueda[0].datosCliente.email);
        System.assertEquals(a.ShippingStreet, r.datosBusqueda[0].datosCliente.calle);
        System.assertEquals(a.ShippingState, r.datosBusqueda[0].datosCliente.provincia);
        System.assertEquals(a.ShippingPostalCode, r.datosBusqueda[0].datosCliente.cp);
        System.assertEquals(a.Actividad__c, r.datosBusqueda[0].datosCliente.actividad);
        System.assertEquals(a.ShippingCity, r.datosBusqueda[0].datosCliente.poblacion);
        System.assertEquals(a.Sub_actividad__c, r.datosBusqueda[0].datosCliente.subactividad);
        System.assertEquals(a.Calle_Facturacion__c, r.datosBusqueda[0].datosCliente.calleFacturacion);
        System.assertEquals(a.Provincia__c, r.datosBusqueda[0].datosCliente.provinciaFacturacion);
        System.assertEquals(a.Poblacion_Facturacion__c, r.datosBusqueda[0].datosCliente.poblacionFacturacion);
        System.assertEquals(a.Codigo_Postal__c, r.datosBusqueda[0].datosCliente.cpFacturacion);
        System.assertEquals(1, r.datosBusqueda[0].oportunidades.size());
        System.assertEquals(op.Id, r.datosBusqueda[0].oportunidades.get(0).identificador);
        System.assertEquals(1, r.datosBusqueda[0].oportunidades.get(0).ofertas.size());
        System.assertEquals(q.Id, r.datosBusqueda[0].oportunidades.get(0).ofertas.get(0).identificador);
    }

    @isTest static void peticionConDatosClienteYOfertas()
    {
        // preparar datos
        Account proveedor = new Account();
        proveedor.RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Partner').Id;
        proveedor.Name = 'Proveedor';
        insert proveedor;

        List<Account> listaAccs = new List<Account>();
        Account a = new Account();
        a.Name = 'EMPRESA';
        a.Id_fiscal__c = 'G08245474';
        a.ShippingStreet = 'calleTest';
        a.ShippingState = 'provinciaTest';
        a.ShippingPostalCode = '54321';
        a.Actividad__c = 'ActTest';
        a.ShippingCity = 'PoblaciónTest';
        a.Sub_actividad__c = 'SubActTest';
        a.Provincia__c = 'provFactTest'; 
        a.Codigo_Postal__c = '12345';
        a.Calle_Facturacion__c = 'calle fact test';
        a.Poblacion_Facturacion__c = 'poblaciónFact test';
        a.Prescriptor_Cuenta__c = proveedor.Id;
        listaAccs.add(a);
        Account competidor = new Account();
        competidor.Name = 'PROVEEDOR TEST';
        competidor.RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Competidor').Id;
        listaAccs.add(competidor);
        insert listaAccs;

        Direcci_n_de_entrega__c d = new Direcci_n_de_entrega__c(cuenta__c = a.Id, Direccion__c='calleTest', Poblacion__c= 'PoblaciónTest', Codigo_Postal__c='54321', 
                                                                Provincia__c='provinciaTest', Actividad_1__c='ActTest', Actividad_2__c='SubActTest');
        insert d;

        Contact c = new Contact();
        c.FirstName = 'ClienteTest';
        c.LastName = 'NTS';
        c.Phone = '123456789';
        c.MobilePhone = '987654321';
        c.Fax = '458521458';
        c.Email = 'emailtest@nts.com';
        c.DNI__c = '63731990W';
        c.AccountId = a.Id;
        insert c;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Opportunity op = new Opportunity();
        op.Name ='OpTest';
        op.StageName = 'Identificada';
        op.CloseDate = Date.today();
        op.AccountId = a.Id;
        insert op;

        OpportunityContactRole opcr = new OpportunityContactRole();
        opcr.OpportunityId = op.Id;
        opcr.ContactId = c.Id;
        insert opcr;

        List<Quote> listQ = new List<Quote>();
        Quote qE = new Quote();
        qE.Name = 'OfETest';
        qE.Status = 'Preparando';
        qE.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id;
        qE.OpportunityId = op.Id;
        qE.Fecha_vigencia__c = Date.today().addYears(1);
        qE.Observaciones__c = 'ObservacionesQE';
        qE.Enviar_email__c = true;
        qE.Resolucion_anticipada__c = 1202;
        qE.Prioridades_comodidad__c = true;
        qE.Prioridades_despreocuparse__c = false;
        qE.Prioridades_enterrado__c = true;
        qE.Prioridades_ahorro_anual__c = false;
        qE.Prioridades_precio_regulado__c = true;
        qE.Prioridades_pagar_consumo__c = false;
        qE.Prioridades_precio_fijo__c = true;
        qE.Prioridades_tarifa_plana__c = false;
        qE.Prioridades_impacto__c = 'Impacto bajo';
        qE.Kg__c = 1;
        qE.KWh__c = 2;
        qE.Litros__c = 3;
        qE.KgCO2__c = 4;
        qE.KgCO2_Primagas__c = 5;
        qE.KWh_Primagas__c = 11;
        qE.Diferencia_kgCO2__c = 12;
        qE.Diferencia_kWh__c = 13;
        qE.Interior_estandar__c = 'IntEstandarTest';
        qE.Exterior_estandar__c = 'ExtEstandarTest';
        qE.Servicio_estandar__c = 'ServEstandarTest';
        qE.Tarifa_estandar__c = 'TARIFA_TEST';
        qE.Precio_L__c = 7;
        qE.Precio_Kg__c = 8;
        qE.Valor_del_servicio_estandar__c = 9;
        qE.Importe_total_primagas__c = 14;
        qE.Importe_total__c = 15;
        qE.Diferencia_importes_totales__c = 16;
        qE.Pago_inicial__c = 17;
        qE.Duracion_descuento__c = '18 AÑOS';
        qE.Consumo_contratado_kg__c = 19;
        qE.Consumo_contratado_L__c = 20;
        qE.Duracion_contratado__c = '21 AÑOS';
        qE.Dto_Estandar__c = 22;
        qE.Texto_servicio_estandar__c = 'Texto opción servicio seleccionado';
        qE.Precio_fecha__c = 'Precio SEP';
        qE.Equipos_a_instalar_Primagas__c = 'Contador;';
        listQ.add(qE);
        Quote qM = new Quote();
        qM.Name = 'OfMTest';
        qM.Status = 'Preparando';
        qM.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id;
        qM.OpportunityId = op.Id;
        qM.Fecha_vigencia__c = Date.today().addYears(1);
        qM.Observaciones__c = 'ObservacionesQM';
        qM.Enviar_email__c = false;
        qM.Resolucion_anticipada__c = 1201;
        qM.Prioridades_comodidad__c = true;
        qM.Prioridades_despreocuparse__c = false;
        qM.Prioridades_enterrado__c = true;
        qM.Prioridades_ahorro_anual__c = false;
        qM.Prioridades_precio_regulado__c = true;
        qM.Prioridades_pagar_consumo__c = false;
        qM.Prioridades_precio_fijo__c = true;
        qM.Prioridades_tarifa_plana__c = false;
        qM.Prioridades_impacto__c = 'Impacto alto';
        qM.Importe_total_primagas__c = 14;
        qM.Importe_total__c = 15;
        qM.Diferencia_importes_totales__c = 16;
        qM.Duracion_contratado__c = '21 AÑOS';
        qM.Kg__c = 11;
        qM.KWh__c = 12;
        qM.Litros__c = 13;
        qM.KgCO2__c = 14;
        qM.KgCO2_Primagas__c = 15;
        qM.KWh_Primagas__c = 10;
        qM.Diferencia_kgCO2__c = 9;
        qM.Diferencia_kWh__c = 8;
        qM.Equipo_interior__c = 'EquipoIntMod';
        qM.Coste_equipo_interior__c = 21;
        qM.Interior__c = true;
        qM.Exterior__c = false;
        qM.Coste_instalacion_interior__c = 16;
        qM.Coste_instalacion_exterior__c = 17;
        qM.Deposito_nombre__c = 'Depósito Nombre';
        qM.Coste_deposito__c = 19;
        qM.Vallado__c = true;
        qM.Coste_vallado__c = 10;
        qM.Obra_civil__c = false;
        qM.Coste_obra_civil__c = 11;
        qM.Total_inversion__c = 12;
        qM.Total_financiable__c = 13;
        qM.Pago_inicial__c = 14;
        qM.Tipo_de_interes__c = 15;
        qM.Instalacion_interior__c = 'InstIntMod';
        qM.Coste_proyectos__c = 22;
        qM.Proyectos__c = 'Proyecto';
        qM.Financiacion_seleccionada__c = 'Financia12';
        qM.Numero_de_cuotas__c = 16;
        qM.Importe_de_cuotas__c = 17;
        qM.Importe_12_cuotas__c = 18;
        qM.Importe_en_gas_en_E_L__c = 19;
        qM.Importe_en_gas_en_E_Kg__c = 20;
        qM.Precio_mensual_L__c = 23;
        qM.Precio_fijo_anual_L__c = 24;
        qM.Contador_L__c = 25;
        qM.Tarifa_plana_L__c = 26;
        qM.Precio_mensual_Kg__c = 27;
        qM.Precio_fijo_anual_Kg__c = 28;
        qM.Contador_Kg__c = 29;
        qM.Tarifa_plana_Kg__c = 30;
        qM.Nivel_PB__c = 'NivelPBQM';
        qM.Tipo_de_tarifa__c = 'TipoTarifaQM';
        qM.Pago_inicial_inversion__c = 41;
        qM.Cuota_inversion__c = 34;
        qM.Duracion_cuota_inversion__c = 35;
        qM.Dto_1_Llenado_inversion__c = 36;
        qM.Importe_ahorro_instalacion__c = 37;
        qM.Opcion_seleccionada_producto__c = 'Fijo';
        qM.Importe_ahorro_gas__c = 38;
        qM.Texto_fecha_producto__c = 'Precio JUL';
        qM.Tipo_de_pago_inversion__c = 'Pagotest';
        qM.Tipo_producto_gas__c = 'ProdGasTest';
        qM.Duracion_descuento__c = '50 AÑOS';
        qM.Dto_Producto_gas__c = 51;
        qM.Precio_producto_gas__c = 52;
        qM.Coste_interior__c = 53;
        qM.Tipo_Primaservicios__c = 'PrimaservTest';
        qM.Mantenimiento_primaservicios__c = true;
        qM.Inspeccion_interior_primaservicios__c = false;
        qM.Revision_interior_primaservicios__c = true;
        qM.Precio_Primaservicios__c = 60;
        qM.Equipos_a_instalar_Primagas__c = 'Contador;';
        qM.Aplica_tramos__c = true;
        listQ.add(qM);
        Quote qP = new Quote();
        qP.Name = 'OfPTest';
        qP.Status = 'Preparando';
        qP.RecordTypeId = Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id;
        qP.OpportunityId = op.Id;
        qP.Fecha_vigencia__c = Date.today().addYears(1);
        qP.Observaciones__c = 'ObservacionesQP';
        qP.Enviar_email__c = false;
        qP.Resolucion_anticipada__c = 1200;
        qP.Prioridades_comodidad__c = true;
        qP.Prioridades_despreocuparse__c = false;
        qP.Prioridades_enterrado__c = true;
        qP.Prioridades_ahorro_anual__c = false;
        qP.Prioridades_precio_regulado__c = true;
        qP.Prioridades_pagar_consumo__c = false;
        qP.Prioridades_precio_fijo__c = true;
        qP.Prioridades_tarifa_plana__c = false;
        qP.Prioridades_impacto__c = 'Impacto medio';
        qP.Duracion_contratado__c = '21 AÑOS';
        qP.Kg__c = 21;
        qP.KWh__c = 22;
        qP.Litros__c = 23;
        qP.KgCO2__c = 24;
        qP.KgCO2_Primagas__c = 25;
        qP.KWh_Primagas__c = 20;
        qP.Diferencia_kgCO2__c = 19;
        qP.Diferencia_kWh__c = 18;
        qP.Tipo_de_tarifa__c = 'TipoTarifaQP';
        qP.Pago_inicial_inversion__c = 41;
        qP.Cuota_inversion__c = 34;
        qP.Duracion_cuota_inversion__c = 35;
        qP.Dto_1_Llenado_inversion__c = 36;
        qP.Importe_total_primagas__c = 14;
        qP.Importe_total__c = 15;
        qP.Diferencia_importes_totales__c = 16;
        qP.Tipo_de_pago_inversion__c = 'Pagotest';
        qP.Tipo_producto_gas__c = 'ProdGasTest';
        qP.Duracion_descuento__c = '50 AÑOS';
        qP.Dto_Producto_gas__c = 51;
        qP.Precio_producto_gas__c = 52;
        qP.Tipo_Primaservicios__c = 'PrimaservTest';
        qP.Mantenimiento_primaservicios__c = true;
        qP.Inspeccion_interior_primaservicios__c = false;
        qP.Revision_interior_primaservicios__c = true;
        qP.Precio_Primaservicios__c = 60;
        qP.Equipos_a_instalar_Primagas__c = 'Contador;';
        listQ.add(qP);
        insert listQ;

        List<Equipo_actual__c> listEq = new List<Equipo_actual__c>();
        Equipo_actual__c eqM = new Equipo_actual__c();
        eqM.Name = 'EquipoTestM';
        eqM.Cantidad__c = 30;
        eqM.Uso__c = 'Uso TestM';
        eqM.Potencia_KW__c = 31;
        eqM.Anyo__c = '2016';
        eqM.Energ_a__c = 'Butano';
        eqM.Presupuesto__c = qM.Id;
        listEq.add(eqM);
        Equipo_actual__c eqP = new Equipo_actual__c();
        eqP.Name = 'EquipoTestP';
        eqP.Cantidad__c = 40;
        eqP.Uso__c = 'Uso TestP';
        eqP.Potencia_KW__c = 41;
        eqP.Anyo__c = '2014';
        eqP.Energ_a__c = 'Propano';
        eqP.Presupuesto__c = qP.Id;
        listEq.add(eqP);
        Equipo_actual__c eqE = new Equipo_actual__c();
        eqE.Name = 'EquipoTestE';
        eqE.Cantidad__c = 50;
        eqE.Uso__c = 'Uso TestE';
        eqE.Potencia_KW__c = 51;
        eqE.Anyo__c = '2015';
        eqE.Energ_a__c = 'Electricidad';
        eqE.Presupuesto__c = qE.Id;
        listEq.add(eqE);
        insert listEq;

        List<Energia_Actual__c> listEn = new List<Energia_Actual__c>();
        Energia_Actual__c enM = new Energia_Actual__c();
        enM.Tipo_energia__c = 'Gasóleo';
        enM.Consumo__c = 60;
        enM.Consumo_KWH__c = 61;
        enM.Consumo_KgCo2__c = 63;
        enM.Consumo_L_Primagas__c = 64;
        enM.Unidad_consumo__c = 'Litros';
        enM.Precio__c = 65;
        enM.Unidad_precio__c = 'Kg';
        enM.Proveedor__c = competidor.Id;
        enM.Rendimiento__c = 66;
        enM.Cambio__c = 'Cambio TestM';
        enM.Presupuesto__c = qM.Id;
        enM.Consumo_KWH_Primagas__c = 67;
        enM.Consumo_Kg_Primagas__c = 68;
        enM.Consumo_KgCO2_Primagas__c = 69;
        enM.Importe_situacion_actual__c = 70;
        listEn.add(enM);
        Energia_Actual__c enP = new Energia_Actual__c();
        enP.Tipo_energia__c = 'Electricidad';
        enP.Consumo__c = 70;
        enP.Consumo_KWH__c = 71;
        enP.Consumo_KgCo2__c = 73;
        enP.Consumo_L_Primagas__c = 74;
        enP.Unidad_consumo__c = 'Litros';
        enP.Precio__c = 75;
        enP.Unidad_precio__c = 'Kg';
        enP.Proveedor__c = competidor.Id;
        enP.Rendimiento__c = 76;
        enP.Cambio__c = 'Cambio TestP';
        enP.Presupuesto__c = qP.Id;
        enP.Consumo_KWH_Primagas__c = 77;
        enP.Consumo_Kg_Primagas__c = 78;
        enP.Consumo_KgCO2_Primagas__c = 79;
        enP.Importe_situacion_actual__c = 80;
        listEn.add(enP);
        Energia_Actual__c enE = new Energia_Actual__c();
        enE.Tipo_energia__c = 'Butano';
        enE.Consumo__c = 80;
        enE.Consumo_KWH__c = 81;
        enE.Consumo_KgCo2__c = 83;
        enE.Consumo_L_Primagas__c = 84;
        enE.Unidad_consumo__c = 'Litros';
        enE.Precio__c = 85;
        enE.Unidad_precio__c = 'Kg';
        enE.Proveedor__c = competidor.Id;
        enE.Rendimiento__c = 86;
        enE.Cambio__c = 'Cambio TestE';
        enE.Presupuesto__c = qE.Id;
        enE.Consumo_KWH_Primagas__c = 87;
        enE.Consumo_Kg_Primagas__c = 88;
        enE.Consumo_KgCO2_Primagas__c = 89;
        enE.Importe_situacion_actual__c = 90;
        listEn.add(enE);
        insert listEn;

        List<Tramo__c> listTr = new List<Tramo__c>();
        Tramo__c tN = new Tramo__c();
        tN.RecordTypeId = Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_normal').Id;
        tN.Name = 'Tramo NTest';
        tN.Porcentaje_desde__c = 90;
        tN.Porcentaje_hasta__c= 91;
        tN.Consumo_desde_L__c = 92;
        tN.Consumo_desde_Kg__c = 93;
        tN.Consumo_hasta_Kg__c = 94;
        tN.Consumo_hasta_L__c = 95;
        tN.Financiacion_en_gas_en_E_L__c = 96;
        tN.Financiacion_en_gas_en_E_Kg__c = 97;
        tN.Presupuesto__c = qM.Id;
        listTr.add(tN);
        Tramo__c tEM = new Tramo__c();
        tEM.RecordTypeId = Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_escalado').Id;
        tEM.Name = 'Tramo EMTest';
        tEM.Porcentaje_desde__c = 10;
        tEM.Porcentaje_hasta__c= 11;
        tEM.Consumo_desde_L__c = 12;
        tEM.Consumo_desde_Kg__c = 13;
        tEM.Consumo_hasta_Kg__c = 14;
        tEM.Consumo_hasta_L__c = 15;
        tEM.Presupuesto__c = qM.Id;
        listTr.add(tEM);
        Tramo__c tEP = new Tramo__c();
        tEP.RecordTypeId = Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_escalado').Id;
        tEP.Name = 'Tramo EMTest';
        tEP.Porcentaje_desde__c = 10;
        tEP.Porcentaje_hasta__c= 11;
        tEP.Consumo_desde_L__c = 12;
        tEP.Consumo_desde_Kg__c = 13;
        tEP.Consumo_hasta_Kg__c = 14;
        tEP.Consumo_hasta_L__c = 15;
        tEP.Presupuesto__c = qP.Id;
        listTr.add(tEP);
        insert listTr;

        List<Deposito__c> listDepo = new List<Deposito__c>();
        Deposito__c d1M = new Deposito__c();
        d1M.Name = 'DepoTestM1';
        d1M.Cantidad__c = 100;
        d1M.Equipos_exterior__c = 101;
        d1M.Instalacion_exterior__c = 105;
        d1M.Proyectos__c = 103;
        d1M.Obra_civil_vallado__c = 104;
        d1M.Presupuesto__c = qM.Id;
        listDepo.add(d1M);
        Deposito__c d1P = new Deposito__c();
        d1P.Name = 'DepoTestP1';
        d1P.Cantidad__c = 110;
        d1P.Equipos_exterior__c = 111;
        d1P.Instalacion_exterior__c = 112;
        d1P.Proyectos__c = 113;
        d1P.Obra_civil_vallado__c = 114;
        d1P.Presupuesto__c = qP.Id;
        listDepo.add(d1P);
        insert listDepo;

        List<Equipo_ajuste__c> listEqAj = new List<Equipo_ajuste__c>();
        Equipo_ajuste__c eA1M = new Equipo_ajuste__c();
        eA1M.Name = 'EATestM1';
        eA1M.Cantidad__c = 9;
        eA1M.Equipos_interior__c = 10;
        eA1M.Equipos_exterior__c = 11;
        eA1M.Instalacion_exterior__c = 12;
        eA1M.Instalacion_interior__c = 13;
        eA1M.Presupuesto__c = qM.Id;
        listEqAj.add(eA1M);
        Equipo_ajuste__c eA1P = new Equipo_ajuste__c();
        eA1P.Name = 'EATestP1';
        ea1P.Cantidad__c = 9;
        eA1P.Equipos_interior__c = 11;
        eA1P.Equipos_exterior__c = 12;
        eA1P.Instalacion_exterior__c = 14;
        eA1P.Instalacion_interior__c = 13;
        eA1P.Presupuesto__c = qP.Id;
        listEqAj.add(eA1P);
        insert listEqAj;

        Pack__c p = new Pack__c();
        p.Name = 'PackTest1';
        p.Numero_de_pack__c = 1;
        p.Nombre__c = 'Pack test 1';
        p.ConsumoMax__c = 10;
        p.Activo__c = true;
        p.ImporteMensual__c = 11;
        insert p;

        ServiciosPacks__c sp = new ServiciosPacks__c();
        sp.Name = 'ServPackTest1';
        sp.Incluido__c = true;
        sp.Nombre__c = 'Servicio Test 1';
        sp.Numero_de_pack__c = 1;
        insert sp;

        Pack_de_servicio__c ps = new Pack_de_servicio__c();
        ps.Consumo_maximo__c = 10;
        ps.Importe_mensual__c = 11;
        ps.Numero_de_pack__c =1;
        ps.Name_Pack_maestros__c = p.Name;
        ps.Presupuesto__c = qM.Id;
        ps.Total_importe__c = 12;
        insert ps;

        Servicio__c s = new Servicio__c();
        s.Incluido__c = true;
        s.Name_Servicio_pack_maestro__c = sp.Name;
        s.Pack_de_servicio__c = ps.Id;
        insert s;

        // preparar petición
        WSDatosClienteYOfertas.PeticionDatosBusqueda peticion = new WSDatosClienteYOfertas.PeticionDatosBusqueda();
        peticion.datosBusqueda = new WSDatosClienteYOfertas.DatosBusqueda();
        peticion.datosBusqueda.telefono = '123456789';
        peticion.datosBusqueda.nombre = 'ClienteTest';
        peticion.datosBusqueda.ofertas = new List<WSDatosClienteYOfertas.OfertaIdPeticion>();
        peticion.datosBusqueda.ofertas.add(new WSDatosClienteYOfertas.OfertaIdPeticion(String.valueOf(qE.Id)));
        peticion.datosBusqueda.ofertas.add(new WSDatosClienteYOfertas.OfertaIdPeticion(String.valueOf(qM.Id)));
        peticion.datosBusqueda.ofertas.add(new WSDatosClienteYOfertas.OfertaIdPeticion(String.valueOf(qP.Id)));

        // ejecutar test
        Test.startTest();
        String jDatos = WSDatosClienteYOfertas.getDatosCliente(peticion);
        Test.stopTest();

        // comprobar resultado
        WSDatosClienteYOfertas.Respuesta r = (WSDatosClienteYOfertas.Respuesta) JSON.deserialize(jDatos, WSDatosClienteYOfertas.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('500', r.resultado.codigo);
        System.assertEquals(c.FirstName, r.datosBusqueda[0].datosCliente.nombre);
        System.assertEquals(c.Lastname, r.datosBusqueda[0].datosCliente.apellidos);
        System.assertEquals(a.Name, r.datosBusqueda[0].datosCliente.compania);
        System.assertEquals(c.Phone, r.datosBusqueda[0].datosCliente.telefono);
        System.assertEquals(c.MobilePhone, r.datosBusqueda[0].datosCliente.telefonoMovil);
        System.assertEquals(c.Email, r.datosBusqueda[0].datosCliente.email);
        System.assertEquals(a.ShippingStreet, r.datosBusqueda[0].datosCliente.calle);
        System.assertEquals(a.ShippingState, r.datosBusqueda[0].datosCliente.provincia);
        System.assertEquals(a.ShippingPostalCode, r.datosBusqueda[0].datosCliente.cp);
        System.assertEquals(a.Actividad__c, r.datosBusqueda[0].datosCliente.actividad);
        System.assertEquals(a.ShippingCity, r.datosBusqueda[0].datosCliente.poblacion);
        System.assertEquals(a.Sub_actividad__c, r.datosBusqueda[0].datosCliente.subactividad);
        System.assertEquals(a.Calle_Facturacion__c, r.datosBusqueda[0].datosCliente.calleFacturacion);
        System.assertEquals(a.Provincia__c, r.datosBusqueda[0].datosCliente.provinciaFacturacion);
        System.assertEquals(a.Poblacion_Facturacion__c, r.datosBusqueda[0].datosCliente.poblacionFacturacion);
        System.assertEquals(a.Codigo_Postal__c, r.datosBusqueda[0].datosCliente.cpFacturacion);
        System.assertEquals(1, r.datosBusqueda[0].oportunidades.size());
        System.assertEquals(op.Id, r.datosBusqueda[0].oportunidades.get(0).identificador);
        System.assertEquals(3, r.datosBusqueda[0].oportunidades.get(0).ofertas.size());
        //System.assertEquals(qE.Id, r.oportunidades.get(0).ofertas.get(0).identificador);
    }
}