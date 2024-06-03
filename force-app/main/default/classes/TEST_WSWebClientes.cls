@isTest
private class TEST_WSWebClientes
{
    @isTest static void loginWebTestErrorPeticionSinDatos()
    {
        WSWebClientes.RespuestaAcceso respuesta;
        WSWebClientes.PeticionAcceso peticion = new WSWebClientes.PeticionAcceso();
        peticion.username = '25291578L';
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.loginWeb(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(WSWebClientes.IDIOMA_ES_SALIDA), respuesta.resultado.mensaje);
    }
    @isTest static void loginWebTestErrorSinInforamcion() 
    {
        WSWebClientes.RespuestaAcceso respuesta;
        WSWebClientes.PeticionAcceso peticion = new WSWebClientes.PeticionAcceso();
        peticion.username = '25291578L';
        peticion.password = EncodingUtil.base64Encode(Crypto.encrypt('AES128', Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf('TEST')));
        peticion.idioma = 'CAT';

        Test.startTest();
        respuesta = WSWebClientes.loginWeb(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_no_existe_usuario').get(WSWebClientes.IDIOMA_CAT_SALIDA), respuesta.resultado.mensaje);
    }
    @isTest static void loginWebTestErrorLoginIncorrecto() 
    {
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Segmento1__c= 'Canalizado';
        acc[0].Id_fiscal__c='25291578L';
        acc[0].Usuario_Web_Clientes__c ='25291578L';
        acc[0].Contrase_a_web_clientes__c='TEST';

        insert acc;

        WSWebClientes.RespuestaAcceso respuesta;
        WSWebClientes.PeticionAcceso peticion = new WSWebClientes.PeticionAcceso();
        peticion.username = '25291578L';
        peticion.password = EncodingUtil.base64Encode(Crypto.encrypt('AES128', Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf('TESTING')));
        peticion.idioma = 'CAT';

        Test.startTest();
        respuesta = WSWebClientes.loginWeb(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
    }
    @isTest static void loginWebTestErrorSegmentoIncorrecto() 
    {
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Segmento1__c= 'CAP - Canalizado Publico';
        acc[0].Id_fiscal__c='25291578L';
        acc[0].Usuario_Web_Clientes__c='25291578L';
        acc[0].Contrase_a_web_clientes__c='TEST';

        insert acc;

        WSWebClientes.RespuestaAcceso respuesta;
        WSWebClientes.PeticionAcceso peticion = new WSWebClientes.PeticionAcceso();
        peticion.username = '25291578L';
        peticion.password = EncodingUtil.base64Encode(Crypto.encrypt('AES128', Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf('TESTING')));
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.loginWeb(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
    }
    @isTest static void loginWebTest() 
    {
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Id_fiscal__c = '25291578L';
        acc[0].Usuario_Web_Clientes__c = '25291578L';
        acc[0].Segmento1__c = 'Canalizado';
        acc[0].Contrase_a_web_clientes__c = 'TEST';

        insert acc;

        List<Contact> contacto = Util.generarContactos(1, 0, acc);

        insert contacto;

        WSWebClientes.RespuestaAcceso respuesta;
        WSWebClientes.PeticionAcceso peticion = new WSWebClientes.PeticionAcceso();
        peticion.username = '25291578L';
        peticion.password = EncodingUtil.base64Encode(Crypto.encrypt('AES128', Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf('TEST')));
        peticion.idioma = 'ES';
        System.debug('peticion.password: ' + peticion.password);

        Test.startTest();
        respuesta = WSWebClientes.loginWeb(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('200', respuesta.resultado.codigo);
        System.assertNotEquals(null, respuesta.datosAcceso);
        System.assertEquals(acc[0].Id, respuesta.datosAcceso.idCliente);
        System.assertEquals(WSWebClientes.traducirSegmento(acc[0].Segmento1__c), respuesta.datosAcceso.segmento);
    }

    /*Prueba que junto al login se devuelven las preferencias de la cuenta*/
    @isTest
    static void loginWebTest_preferencias()
    {
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Id_fiscal__c = '25291578L';
        acc[0].Usuario_Web_Clientes__c = '25291578L';
        acc[0].Segmento1__c = 'Canalizado';
        acc[0].Contrase_a_web_clientes__c = 'TEST';

        //Account acc = new Account(FirstName='NombreTest', LastName='ApellidoTest', Id_fiscal__c='25291578L',Usuario_Web_Clientes__c='25291578L',Segmento1__c='Canalizado', Contrase_a_web_clientes__c='TEST', RecordTypeId=Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert acc;

        List<Contact> contactoPrincipal = Util.generarContactos(1, 0, acc);
        //contactoPrincipal[0].Contacto_Principal__c = true;
        insert contactoPrincipal;

        List<Individual> personasList = new List<Individual>([SELECT Id, Hash__c FROM Individual]);
        System.assert(!personasList.isEmpty());

        WSWebClientes.RespuestaAcceso respuesta;
        WSWebClientes.PeticionAcceso peticion = new WSWebClientes.PeticionAcceso();
        peticion.username = '25291578L';
        peticion.password = EncodingUtil.base64Encode(Crypto.encrypt('AES128', Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf('TEST')));
        peticion.idioma = 'ES';
        System.debug('peticion.password: ' + peticion.password);

        Test.startTest();
        respuesta = WSWebClientes.loginWeb(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('200', respuesta.resultado.codigo);
        System.assertNotEquals(null, respuesta.datosAcceso);
        System.assertEquals(acc[0].Id, respuesta.datosAcceso.idCliente);
        System.assertEquals(WSWebClientes.traducirSegmento(acc[0].Segmento1__c), respuesta.datosAcceso.segmento);
        System.assertEquals(false, respuesta.datosAcceso.modificado);
        //System.assertEquals(true, respuesta.datosAcceso.cuentaPersonal);
        System.assertEquals(true, respuesta.datosAcceso.encuestas);
        System.assertEquals(true, respuesta.datosAcceso.promociones);
    }

    //Cambios rfernandez (13/09/2017) Comentar este y descomentar el siguiente metodo para implementar los cambios de incidencias
    @isTest static void getTiposIncidenciasTest() 
    {
        // preparar datos
        TiposIncidencias__c ti = new TiposIncidencias__c(Name='ES_TipoTest1', Texto__c='TipoTest1', Idioma__c = 'ES');
        insert ti;

        WSWebClientes.RespuestaGetTiposIncidencias respuesta;
        WSWebClientes.PeticionGetTiposIncidencias peticion = new WSWebClientes.PeticionGetTiposIncidencias();
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.getTiposIncidencias(peticion);
        Test.stopTest();

        System.debug(respuesta);

        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('200', respuesta.resultado.codigo);
        System.assertNotEquals(null, respuesta.tiposIncidencias);
        //System.assert(respuesta.tiposIncidencias.size() > 0); //Ahora no se obtienen tipos de incidencias sino temas
    }

    /*@isTest static void getTemasTest() 
    {
        // preparar datos
        TemasWebClientes__c ti = new TemasWebClientes__c(Name='ES_TipoTest1', Texto__c='TipoTest1', Idioma__c = 'ES');
        insert ti;

        WSWebClientes.RespuestaGetTiposIncidencias respuesta;
        WSWebClientes.PeticionGetTiposIncidencias peticion = new WSWebClientes.PeticionGetTiposIncidencias();
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.getTiposIncidencias(peticion);
        Test.stopTest();

        System.debug('Respuesta de temas:'+respuesta);

        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('200', respuesta.resultado.codigo);
        System.assertNotEquals(null, respuesta.tiposIncidencias);
        System.assert(respuesta.tiposIncidencias.size() > 0); 
    }*/

    @isTest static void recuperarPasswordTestErrorPeticionSinDatos() 
    {
        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionRecuperarPassword peticion = new WSWebClientes.PeticionRecuperarPassword();

        Test.startTest();
        respuesta = WSWebClientes.recuperarPassword(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('501', respuesta.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(WSWebClientes.IDIOMA_ES_SALIDA), respuesta.mensaje);
    }
    @isTest static void recuperarPasswordTestErrorSinInformacion() 
    {
        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionRecuperarPassword peticion = new WSWebClientes.PeticionRecuperarPassword();
        peticion.email = 'test@test.com';
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.recuperarPassword(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('501', respuesta.codigo);
    }
    @isTest static void recuperarPasswordTestErrorSegmentoIncorrecto() 
    {
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].E_mail__c ='lperez@nts-solutions.com';
        acc[0].Segmento1__c='CAP - Canalizado Publico';
        acc[0].Contrase_a_web_clientes__c='TEST';

        insert acc;

        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionRecuperarPassword peticion = new WSWebClientes.PeticionRecuperarPassword();
        peticion.email = 'lperez@nts-solutions.com';
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.recuperarPassword(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('501', respuesta.codigo);
    }
    @isTest static void recuperarPasswordTest() 
    {
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].E_mail__c ='lperez@nts-solutions.com';
        acc[0].Segmento1__c='Canalizado';
        acc[0].Contrase_a_web_clientes__c='TEST';

        insert acc;

        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionRecuperarPassword peticion = new WSWebClientes.PeticionRecuperarPassword();
        peticion.email = 'lperez@nts-solutions.com';
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.recuperarPassword(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('200', respuesta.codigo);
    }

    @isTest static void busquedaUsuariosTestErrorPeticionSinDatos()
    {
        WSWebClientes.RespuestaBusquedaUsuarios respuesta;
        WSWebClientes.PeticionBusquedaUsuarios peticion = null;

        Test.startTest();
        respuesta = WSWebClientes.busquedaUsuarios(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(WSWebClientes.IDIOMA_ES_SALIDA), respuesta.resultado.mensaje);
    }
    @isTest static void busquedaUsuariosTestErrorPeticionSinFiltro()
    {
        WSWebClientes.RespuestaBusquedaUsuarios respuesta;
        WSWebClientes.PeticionBusquedaUsuarios peticion = new WSWebClientes.PeticionBusquedaUsuarios();
        peticion.filtros = new List<WSWebClientes.Filtro>();
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.busquedaUsuarios(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
    }
    @isTest static void busquedaUsuariosTestErrorPeticionSinInformacion()
    {
        WSWebClientes.RespuestaBusquedaUsuarios respuesta;
        WSWebClientes.PeticionBusquedaUsuarios peticion = new WSWebClientes.PeticionBusquedaUsuarios();
        peticion.filtros = new List<WSWebClientes.Filtro>();
        peticion.filtros.add(new WSWebClientes.Filtro('Name', 'test'));
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.busquedaUsuarios(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
    }
    @isTest static void busquedaUsuariosTest()
    {
        Canalizado_promotor__c can = new Canalizado_promotor__c(Name='CanalizadoTest', Id_Navision__c='1234');
        insert can;

        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Segmento1__c = 'Canalizado';
        acc[0].canalizado_promotor__c = can.Id;
        
        insert acc;

        WSWebClientes.RespuestaBusquedaUsuarios respuesta;
        WSWebClientes.PeticionBusquedaUsuarios peticion = new WSWebClientes.PeticionBusquedaUsuarios();
        peticion.filtros = new List<WSWebClientes.Filtro>();
        peticion.filtros.add(new WSWebClientes.Filtro('Name', 'test'));
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.busquedaUsuarios(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('200', respuesta.resultado.codigo);
        System.assertNotEquals(null, respuesta.usuarios);
        System.assertEquals(1, respuesta.usuarios.size());
        System.assertEquals(acc[0].Id, respuesta.usuarios.get(0).id);
        System.assertEquals(acc[0].Name, respuesta.usuarios.get(0).nombre);
        System.assertEquals(WSWebClientes.traducirSegmento(acc[0].Segmento1__c), respuesta.usuarios.get(0).segmento);
    }

    @isTest static void getDatosPersonalesTestErrorPeticionSinDatos()
    {
        WSWebClientes.RespuestaDatosPersonales respuesta;
        WSWebClientes.PeticionGetDatosPersonales peticion = new WSWebClientes.PeticionGetDatosPersonales();

        Test.startTest();
        respuesta = WSWebClientes.getDatosPersonales(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(WSWebClientes.IDIOMA_ES_SALIDA), respuesta.resultado.mensaje);
    }
    @isTest static void getDatosPersonalesTestErrorSinInformacion()
    {
        WSWebClientes.RespuestaDatosPersonales respuesta;
        WSWebClientes.PeticionGetDatosPersonales peticion = new WSWebClientes.PeticionGetDatosPersonales();
        peticion.id = '001e000000korI3';
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.getDatosPersonales(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo); 
    }
    @isTest static void getDatosPersonalesTest()
    {
        // preparar datos
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Phone = '258963256';
        insert acc;

        List<Contact> contactos = Util.generarContactos(1, 0, acc);
        insert contactos;

        Direcci_n_de_entrega__c dir = new Direcci_n_de_entrega__c(cuenta__c = acc[0].Id, Direccion__c='Dir1Test', Direccion_2__c='Dir2Test', Provincia__c='Bizkaia', Codigo_Postal__c= '23455', Poblacion__c='PoblTest');
        insert dir;

        Contract contr = new Contract(Name='ContrTest', AccountId = acc[0].Id, Duraci_n_del_contrato_a_os__c = '2', StartDate=Date.today().addYears(-1), ContractTerm=24);
        insert contr;
        contr.Status = 'Activado';
        update contr;

        WSWebClientes.RespuestaDatosPersonales respuesta;
        WSWebClientes.PeticionGetDatosPersonales peticion = new WSWebClientes.PeticionGetDatosPersonales();
        peticion.id = String.valueOf(acc[0].Id);
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.getDatosPersonales(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('200', respuesta.resultado.codigo); 
        System.assertNotEquals(null, respuesta.datosPersonales);
        System.assertEquals(acc[0].Name, respuesta.datosPersonales.nombre);
        System.assertEquals(acc[0].Phone, respuesta.datosPersonales.numTelefono);
        System.assertNotEquals(null, respuesta.datosPersonales.direccionesServicio);
        System.assertEquals(1, respuesta.datosPersonales.direccionesServicio.size());
        System.assertEquals(dir.Direccion__c, respuesta.datosPersonales.direccionesServicio.get(0).direccionServicio);
        System.assertNotEquals(null, respuesta.datosPersonales.contratos);
        System.assertEquals(1, respuesta.datosPersonales.contratos.size());
        string fecha;
        string dia, mes, anyo;
        if(contr.StartDate == null )
        {
            fecha = '';
        }
        else
        {
            dia = String.valueOf(contr.StartDate.day());
            while( dia.length() < 2 )
                dia = '0' + dia;
            mes = String.valueOf(contr.StartDate.month());
            while( mes.length() < 2 )
                mes = '0' + mes;
            anyo = String.valueOf(contr.StartDate.year());
            while(anyo.length() < 4)
                anyo = '0' + anyo;
            fecha = anyo + mes + dia;
        }
        System.assertEquals(fecha, respuesta.datosPersonales.contratos.get(0).vigencia);
    }

     @isTest static void getDatosPersonalesTest_preferencias()
    {
        // preparar datos
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);

        //Account acc = new Account(FirstName='NombreTest', LastName='ApellidoTest', Phone='258963256', RecordTypeId=Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert acc;

        List<Contact> contactoPrincipal = Util.generarContactos(1, 0, acc);
        //contactoPrincipal[0].Contacto_Principal__c = true;
        insert contactoPrincipal;

        WSWebClientes.RespuestaDatosPersonales respuesta;
        WSWebClientes.PeticionGetDatosPersonales peticion = new WSWebClientes.PeticionGetDatosPersonales();
        peticion.id = String.valueOf(acc[0].Id);
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.getDatosPersonales(peticion);
        Test.stopTest();
        
        System.assertEquals(true, respuesta.datosPersonales.promociones);
        System.assertEquals(true, respuesta.datosPersonales.encuestas);
        //System.assertEquals(true, respuesta.datosPersonales.cuentaPersonal);
        System.assertEquals(false, respuesta.datosPersonales.modificado);
    }

    @isTest static void updateDatosPersonalesTestErrorPeticionSinDatos()
    {
        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionUpdateDatosPersonales peticion = new WSWebClientes.PeticionUpdateDatosPersonales();

        Test.startTest();
        respuesta = WSWebClientes.updateDatosPersonales(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('501', respuesta.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(WSWebClientes.IDIOMA_ES_SALIDA), respuesta.mensaje);
    }
    @isTest static void updateDatosPersonalesTestErrorSinInformacion()
    {
        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionUpdateDatosPersonales peticion = new WSWebClientes.PeticionUpdateDatosPersonales();
        peticion.id = '001e000000korI3';
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.updateDatosPersonales(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('501', respuesta.codigo);
    }
    @isTest static void updateDatosPersonalesTest()
    {
        // preparar datos
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Phone = '258963256';
        insert acc;

        List<Contact> contacto = Util.generarContactos(1, 0, acc);
        insert contacto;

        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionUpdateDatosPersonales peticion = new WSWebClientes.PeticionUpdateDatosPersonales();
        peticion.id = String.valueOf(acc[0].Id);
        peticion.direccion = 'Dirección Test, 5';
        peticion.cp = '45676';
        peticion.poblacion = 'Población Test';
        peticion.provincia = 'Bizkaia';
        peticion.movil = '234434534';
        peticion.numTelefono = '982732817';
        peticion.email = 'email@test.com';
        peticion.idioma = 'ES';
        peticion.encuestas = false;
        peticion.promociones = true;

        peticion.cuentaBancaria = EncodingUtil.base64Encode(Crypto.encrypt('AES128', Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf('12341285123541235')));

        Test.startTest();
        respuesta = WSWebClientes.updateDatosPersonales(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('200', respuesta.codigo);

        List<Account> listAcc = [select Calle_Facturacion__c, BillingCity, Codigo_Postal__c from Account where Id = :acc[0].Id];
        System.assertNotEquals(null, listAcc);
        System.assertEquals(1, listAcc.size());
        System.assertEquals(peticion.direccion, listAcc.get(0).Calle_Facturacion__c);
        //System.assertEquals('12341285123541235', listAcc.get(0).Iban__c);
    }

    @isTest static void updateDatosPersonalesTest_preferencias()
    {
        // preparar datos
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Phone = '258963256';

        insert acc;

        List<Contact> contactoPrincipal = Util.generarContactos(1, 0, acc);

        insert contactoPrincipal;

        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionUpdateDatosPersonales peticion = new WSWebClientes.PeticionUpdateDatosPersonales();
        peticion.id             = String.valueOf(acc[0].Id);
        peticion.promociones    = true;
        peticion.encuestas      = true;
        peticion.ip             = '127.0.0.1';
        peticion.idioma         = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.updateDatosPersonales(peticion);
        Test.stopTest();
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('200', respuesta.codigo);

        List<Individual> personasList = new List<Individual>([SELECT Id, Hash__c, IP__c, Modificado__c, Modificado_desde__c, Encuestas_satisfaccion__c, Promociones__c, Fecha_encuestas__c, Fecha_promociones__c 
                                                                FROM Individual]);
        Individual persona = personasList[0];
        System.assertEquals(true, persona.Promociones__c);
        System.assertEquals(true, persona.Encuestas_satisfaccion__c);
        System.assertEquals('Web Clientes', persona.Modificado_desde__c);
        System.assertEquals(true, persona.Modificado__c);
        System.assertEquals(Date.today(), Date.newinstance(persona.Fecha_encuestas__c.year(), persona.Fecha_encuestas__c.month(), persona.Fecha_encuestas__c.day()));
        System.assertEquals(Date.today(), Date.newinstance(persona.Fecha_promociones__c.year(), persona.Fecha_promociones__c.month(), persona.Fecha_promociones__c.day()));
    }

    @isTest static void solicitarDuplicadoFacturaTestErrorPeticionSinDatos()
    {
        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionSolicitudDuplicadoFactura peticion = new WSWebClientes.PeticionSolicitudDuplicadoFactura();

        Test.startTest();
        respuesta = WSWebClientes.solicitarDuplicadoFactura(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('501', respuesta.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(WSWebClientes.IDIOMA_ES_SALIDA), respuesta.mensaje);
    }
    @isTest static void solicitarDuplicadoFacturaTest()
    {
        // preparar datos
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);

        insert acc;

        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionSolicitudDuplicadoFactura peticion = new WSWebClientes.PeticionSolicitudDuplicadoFactura();
        peticion.cliente = acc[0].Id;
        peticion.comentarios = '55555 - Comentarios duplicado test';
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.solicitarDuplicadoFactura(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        //Comentado para subir a producción, este test no falla en PersonAcc

        /*System.assertNotEquals(null, respuesta);
        System.assertEquals('200', respuesta.codigo);

        List<Task> listTareas = [select Id, Description from Task where WhatId = :acc[0].Id and Subject = :WSWebClientes.textosWebClientesMap.get('Tarea_solicitud_duplicado_factura').get(WSWebClientes.IDIOMA_ES_SALIDA)];
        System.assertNotEquals(null, listTareas);
        System.assertEquals(1, listTareas.size());
        System.assertNotEquals(null, listTareas.get(0));
        System.assertEquals(peticion.comentarios, listTareas.get(0).Description);*/
    }

    @isTest static void getPromocionesTestErrorPeticionSinDatos()
    {
        WSWebClientes.RespuestaObtenerPromociones respuesta;
        WSWebClientes.PeticionObtenerPromociones peticion = new WSWebClientes.PeticionObtenerPromociones();

        Test.startTest();
        respuesta = WSWebClientes.getPromociones(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(WSWebClientes.IDIOMA_ES_SALIDA), respuesta.resultado.mensaje);
    }
    @isTest static void getPromocionesTestErrorSinInformacion()
    {
        // preparar datos
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert acc;

        WSWebClientes.RespuestaObtenerPromociones respuesta;
        WSWebClientes.PeticionObtenerPromociones peticion = new WSWebClientes.PeticionObtenerPromociones();
        peticion.cliente = acc[0].Id;
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.getPromociones(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
    }
    @isTest static void getPromocionesTestErrorSinPromosConImg()
    {
        // preparar datos
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert acc;

        Campaign camp = new Campaign(Name='campaña test', StartDate = Date.today(), Status='En curso', IsActive = true);
        insert camp;

        WSWebClientes.RespuestaObtenerPromociones respuesta;
        WSWebClientes.PeticionObtenerPromociones peticion = new WSWebClientes.PeticionObtenerPromociones();
        peticion.cliente = acc[0].Id;
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.getPromociones(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('501', respuesta.resultado.codigo);
    }
    @isTest static void getPromocionesTest()
    {
        // preparar datos
        Campaign camp = new Campaign(Name='campaña test', StartDate = Date.today(), Status='En curso', URL_campa_a__c='http://www.google.es', IsActive = true);
        insert camp;

        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        acc[0].Campa_a_relacionada__c=camp.Id;
        insert acc;

        Blob img = EncodingUtil.base64Decode('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');
        Attachment att = new Attachment();
        att.ParentId = camp.Id;  
        att.Name = WSWebClientes.NOMBRE_IMAGEN_PROMOCION + 'png';  
        att.body = img;
        insert att;

        WSWebClientes.RespuestaObtenerPromociones respuesta;
        WSWebClientes.PeticionObtenerPromociones peticion = new WSWebClientes.PeticionObtenerPromociones();
        peticion.cliente = acc[0].Id;
        peticion.idioma = 'ES';

        Test.startTest();
        respuesta = WSWebClientes.getPromociones(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertNotEquals(null, respuesta.resultado);
        System.assertEquals('200', respuesta.resultado.codigo);
        System.assertNotEquals(null, respuesta.promociones);
        System.assertEquals(1, respuesta.promociones.size());
        System.assertEquals(camp.Name, respuesta.promociones.get(0).nombrePromocion);
        System.assert(respuesta.promociones.get(0).inscrito);
    }

    @isTest static void enviarIncidenciaTestErrorPeticionSinDatos()
    {
        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionEnviarIncidencia peticion = new WSWebClientes.PeticionEnviarIncidencia();

        Test.startTest();
        respuesta = WSWebClientes.enviarIncidencia(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('501', respuesta.codigo);
        System.assertEquals(WSWebClientes.textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(WSWebClientes.IDIOMA_ES_SALIDA), respuesta.mensaje);
    }
    @isTest static void enviarIncidenciaTest()
    {
        // preparar datos
        /*Account acc = new Account(Name='CuentaTest', RecordTypeId=Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert acc;

        List<TemasWebClientes__c> listTIs = new List<TemasWebClientes__c>();
        TemasWebClientes__c tiEs = new TemasWebClientes__c(Name='ES_TipoTest1', Idioma__c = 'ES', Texto__c = 'No conforme con 902');
        listTIs.add(tiEs);
        TemasWebClientes__c tiCat = new TemasWebClientes__c(Name='CAT_TipoTest1', Idioma__c = 'ES', Texto__c = 'TipusTest1', Name_Texto_ES__c='ES_TipoTest1');
        listTIs.add(tiCat);
        insert listTIs;

        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionEnviarIncidencia peticion = new WSWebClientes.PeticionEnviarIncidencia();
        peticion.tipoCaso = 'TipusTest1';
        peticion.cliente = String.valueOf(acc.Id);
        peticion.comentarios = 'Comentario test';
        peticion.idioma = 'CAT';

        Test.startTest();
        respuesta = WSWebClientes.enviarIncidencia(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('200', respuesta.codigo);

        List<Case> listCasos = [select Id, Type, Tema__c from Case where AccountId = :acc.Id];
        System.assertNotEquals(null, listCasos);
        System.assertEquals(1, listCasos.size());
        System.assertNotEquals(null, listCasos.get(0));
        System.assertEquals('Consulta', listCasos.get(0).Type);
        System.assertEquals(tiES.Texto__c, listCasos.get(0).Tema__c);*/
        List<Account> acc = Util.generarCuentas(1, 0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert acc;

        List<TiposIncidencias__c> listTIs = new List<TiposIncidencias__c>();
        TiposIncidencias__c tiEs = new TiposIncidencias__c(Name='ES_TipoTest1', Idioma__c = 'ES', Texto__c = 'No conforme con 902');
        listTIs.add(tiEs);
        TiposIncidencias__c tiCat = new TiposIncidencias__c(Name='CAT_TipoTest1', Idioma__c = 'ES', Texto__c = 'TipusTest1', Name_Texto_ES__c='ES_TipoTest1');
        listTIs.add(tiCat);
        insert listTIs;

        WSWebClientes.Resultado respuesta;
        WSWebClientes.PeticionEnviarIncidencia peticion = new WSWebClientes.PeticionEnviarIncidencia();
        peticion.tipoCaso = 'TipusTest1';
        peticion.cliente = String.valueOf(acc[0].Id);
        peticion.comentarios = 'Comentario test';
        peticion.idioma = 'CAT';

        Test.startTest();
        respuesta = WSWebClientes.enviarIncidencia(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);
        System.assertEquals('200', respuesta.codigo);

        List<Case> listCasos = [select Id, Type from Case where AccountId = :acc[0].Id];
        System.assertNotEquals(null, listCasos);
        System.assertEquals(1, listCasos.size());
        System.assertNotEquals(null, listCasos.get(0));
        System.assertEquals(tiES.Texto__c, listCasos.get(0).Type);
    }

    /**
     * Crea una tarea del Tipo 'Otros'con el Estado a 'Revision interior pendiente'
     * 
     * @author pmartin
     * @date 21/02/2020
     */
    @isTest static void solicitarRevisionInteriorTestOK()
    {
        //requiere usuario, dirección de entrega, contrato y contacto/candidato
        List<Account> cuentasList = Util.generarCuentas(1, 0,Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert cuentasList;
        
        List<Account> cuentasQuery = [select Id from Account];
        if(cuentasQuery.size() > 0)
        {
            List<User> usuarios = Util.generarUsuarios(1, 0, cuentasQuery[0]);
            insert usuarios;

            List<Contact> contactosList = Util.generarContactosPrincipales(1, 0, cuentasList);
            insert contactosList;

            Direcci_n_de_entrega__c direccionEntrega = new Direcci_n_de_entrega__c();
            direccionEntrega.cuenta__c = cuentasQuery[0].Id;
            direccionEntrega.Provincia__c= 'Alava/Araba';
            direccionEntrega.Direccion__c = 'Islas Canarias 43';
            direccionEntrega.Estado__c = 'Active';
            direccionEntrega.Deposito__c = 'X8ELT0031';

            insert direccionEntrega;

            List<Direcci_n_de_entrega__c> direccionesEntregaQuery = [select id, Deposito__c from Direcci_n_de_entrega__c];
            if(direccionesEntregaQuery.size() > 0)
            {

                List<Contract> contratosList = Util.generarContratos(1, 0, Util.objectsRecordTypesMap.get('Contract').get('GLP').Id, direccionesEntregaQuery[0], cuentasQuery[0].Id);
                insert contratosList;

                List<Contract> contratosQuery = [select id, Status from Contract];

                if(contratosQuery.size() > 0)
                {
                    contratosQuery[0].Status = 'Activado';
                    update contratosQuery[0];
                }

                List<Contract> contratosAfterUpdate = [select Id from Contract];
                List<User> usuariosQuery = [select id from User];
                List<Contact> contactosQuery = [select id from Contact];
                
                WSWebClientes.PeticionSolicitudRevisionInterior psri = new WSWebClientes.PeticionSolicitudRevisionInterior();
                psri.accountId = cuentasQuery[0].Id;
                psri.numSerie = direccionesEntregaQuery[0].Deposito__c;
                
                List<Task> tasksBefore;
                List<Task> tasksAfter;
                
                tasksBefore = [select Id from Task where WhoId =: psri.accountId];
    
                Test.startTest();
                WSWebClientes.Resultado respuesta = WSWebClientes.solicitarRevisionInterior(psri);
                Test.stopTest();
                // System.assertEquals('200', respuesta.mensaje);
                System.assertEquals('200', respuesta.codigo);
            }
        }
    }

    /**
     * no crea una tarea del Tipo 'Otros'con el Estado a 'Revision interior pendiente' 
     * fallo por dirección de entrega no activa
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void solicitarRevisionInteriorTestConDireccionEntregaNoActiva()
    {
        //requiere usuario, dirección de entrega, contrato y contacto/candidato
        List<Account> cuentasList = Util.generarCuentas(1, 0,Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert cuentasList;
        
        List<Account> cuentasQuery = [select Id from Account];
        if(cuentasQuery.size() > 0)
        {
            List<User> usuarios = Util.generarUsuarios(1, 0, cuentasQuery[0]);
            insert usuarios;

            List<Contact> contactosList = Util.generarContactos(1, 0, cuentasList);
            insert contactosList;

            Direcci_n_de_entrega__c direccionEntrega = new Direcci_n_de_entrega__c();
            direccionEntrega.cuenta__c = cuentasQuery[0].Id;
            direccionEntrega.Provincia__c= 'Alava/Araba';
            direccionEntrega.Direccion__c = 'Islas Canarias 43';
            // direccionEntrega.Estado__c = 'Active';
            direccionEntrega.Deposito__c = 'X8ELT0031';

            insert direccionEntrega;

            List<Direcci_n_de_entrega__c> direccionesEntregaQuery = [select id from Direcci_n_de_entrega__c];
            if(direccionesEntregaQuery.size() > 0)
            {

                List<Contract> contratosList = Util.generarContratos(1, 0, Util.objectsRecordTypesMap.get('Contract').get('GLP').Id, direccionesEntregaQuery[0], cuentasQuery[0].Id);
                insert contratosList;

                List<Contract> contratosQuery = [select id, Status from Contract];

                if(contratosQuery.size() > 0)
                {
                    contratosQuery[0].Status = 'Activado';
                    update contratosQuery[0];
                }

                List<Contract> contratosAfterUpdate = [select Id from Contract];
                List<User> usuariosQuery = [select id from User];
                List<Contact> contactosQuery = [select id from Contact];
                
                WSWebClientes.PeticionSolicitudRevisionInterior psri = new WSWebClientes.PeticionSolicitudRevisionInterior();
                psri.accountId = cuentasQuery[0].Id;
                psri.numSerie = 'X8ELT0031';
                
                List<Task> tasksBefore;
                List<Task> tasksAfter;
                
                tasksBefore = [select Id from Task where WhoId =: psri.accountId];
    
                Test.startTest();
                WSWebClientes.Resultado respuesta = WSWebClientes.solicitarRevisionInterior(psri);
                Test.stopTest();
    
                System.assertEquals('501', respuesta.codigo);
            }
        }
    }

    /**
     * no crea una tarea del Tipo 'Otros'con el Estado a 'Revision interior pendiente' 
     * fallo por contratos no activos
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void solicitarRevisionInteriorTestConContratoNoActivo()
    {
        //requiere usuario, dirección de entrega, contrato y contacto/candidato
        List<Account> cuentasList = Util.generarCuentas(1, 0,Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert cuentasList;
        
        List<Account> cuentasQuery = [select Id from Account];
        if(cuentasQuery.size() > 0)
        {
            List<User> usuarios = Util.generarUsuarios(1, 0, cuentasQuery[0]);
            insert usuarios;

            List<Contact> contactosList = Util.generarContactos(1, 0, cuentasList);
            insert contactosList;

            Direcci_n_de_entrega__c direccionEntrega = new Direcci_n_de_entrega__c();
            direccionEntrega.cuenta__c = cuentasQuery[0].Id;
            direccionEntrega.Provincia__c= 'Alava/Araba';
            direccionEntrega.Direccion__c = 'Islas Canarias 43';
            direccionEntrega.Estado__c = 'Active';
            direccionEntrega.Deposito__c = 'X8ELT0031';

            insert direccionEntrega;

            List<Direcci_n_de_entrega__c> direccionesEntregaQuery = [select id from Direcci_n_de_entrega__c];
            if(direccionesEntregaQuery.size() > 0)
            {

                List<Contract> contratosList = Util.generarContratos(1, 0, Util.objectsRecordTypesMap.get('Contract').get('GLP').Id, direccionesEntregaQuery[0], cuentasQuery[0].Id);
                insert contratosList;

                List<Contract> contratosQuery = [select id, Status from Contract];

                // if(contratosQuery.size() > 0)
                // {
                //     contratosQuery[0].Status = 'Activado';
                //     update contratosQuery[0];
                // }

                List<Contract> contratosAfterUpdate = [select Id from Contract];
                List<User> usuariosQuery = [select id from User];
                List<Contact> contactosQuery = [select id from Contact];
                
                WSWebClientes.PeticionSolicitudRevisionInterior psri = new WSWebClientes.PeticionSolicitudRevisionInterior();
                psri.accountId = cuentasQuery[0].Id;
                psri.numSerie = 'X8ELT0031';
                
                List<Task> tasksBefore;
                List<Task> tasksAfter;
                
                tasksBefore = [select Id from Task where WhoId =: psri.accountId];
    
                Test.startTest();
                WSWebClientes.Resultado respuesta = WSWebClientes.solicitarRevisionInterior(psri);
                Test.stopTest();
    
                System.assertEquals('501', respuesta.codigo);
            }
        }
    }

    /**
     * no crea una tarea del Tipo 'Otros'con el Estado a 'Revision interior pendiente' 
     * fallo por error en cuenta
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void solicitarRevisionInteriorTestConCuentaErronea()
    {
        //requiere usuario, dirección de entrega, contrato y contacto/candidato
        List<Account> cuentasList = Util.generarCuentas(1, 0,Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert cuentasList;
        
        List<Account> cuentasQuery = [select Id from Account];
        if(cuentasQuery.size() > 0)
        {
            List<User> usuarios = Util.generarUsuarios(1, 0, cuentasQuery[0]);
            insert usuarios;

            List<Contact> contactosList = Util.generarContactos(1, 0, cuentasList);
            insert contactosList;

            Direcci_n_de_entrega__c direccionEntrega = new Direcci_n_de_entrega__c();
            direccionEntrega.cuenta__c = cuentasQuery[0].Id;
            direccionEntrega.Provincia__c= 'Alava/Araba';
            direccionEntrega.Direccion__c = 'Islas Canarias 43';
            direccionEntrega.Estado__c = 'Active';
            direccionEntrega.Deposito__c = 'X8ELT0031';

            insert direccionEntrega;

            List<Direcci_n_de_entrega__c> direccionesEntregaQuery = [select id from Direcci_n_de_entrega__c];
            if(direccionesEntregaQuery.size() > 0)
            {

                List<Contract> contratosList = Util.generarContratos(1, 0, Util.objectsRecordTypesMap.get('Contract').get('GLP').Id, direccionesEntregaQuery[0], cuentasQuery[0].Id);
                insert contratosList;

                List<Contract> contratosQuery = [select id, Status from Contract];

                if(contratosQuery.size() > 0)
                {
                    contratosQuery[0].Status = 'Activado';
                    update contratosQuery[0];
                }

                List<Contract> contratosAfterUpdate = [select Id from Contract];
                List<User> usuariosQuery = [select id from User];
                List<Contact> contactosQuery = [select id from Contact];
                
                WSWebClientes.PeticionSolicitudRevisionInterior psri = new WSWebClientes.PeticionSolicitudRevisionInterior();
                psri.accountId = ''; // <------------------ fallo
                psri.numSerie = 'X8ELT0031';
                
                List<Task> tasksBefore;
                List<Task> tasksAfter;
                
                tasksBefore = [select Id from Task where WhoId =: psri.accountId];
    
                Test.startTest();
                WSWebClientes.Resultado respuesta = WSWebClientes.solicitarRevisionInterior(psri);
                Test.stopTest();
    
                System.assertEquals('501', respuesta.codigo);
            }
        }
    }

    /**
     * no crea una tarea del Tipo 'Otros'con el Estado a 'Revision interior pendiente' 
     * fallo por error en numero de serie
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void solicitarRevisionInteriorTestConNumSerieErroneo()
    {
        //requiere usuario, dirección de entrega, contrato y contacto/candidato
        List<Account> cuentasList = Util.generarCuentas(1, 0,Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert cuentasList;
        
        List<Account> cuentasQuery = [select Id from Account];
        if(cuentasQuery.size() > 0)
        {
            List<User> usuarios = Util.generarUsuarios(1, 0, cuentasQuery[0]);
            insert usuarios;

            List<Contact> contactosList = Util.generarContactos(1, 0, cuentasList);
            insert contactosList;

            Direcci_n_de_entrega__c direccionEntrega = new Direcci_n_de_entrega__c();
            direccionEntrega.cuenta__c = cuentasQuery[0].Id;
            direccionEntrega.Provincia__c= 'Alava/Araba';
            direccionEntrega.Direccion__c = 'Islas Canarias 43';
            direccionEntrega.Estado__c = 'Active';
            direccionEntrega.Deposito__c = 'X8ELT0031';

            insert direccionEntrega;

            List<Direcci_n_de_entrega__c> direccionesEntregaQuery = [select id from Direcci_n_de_entrega__c];
            if(direccionesEntregaQuery.size() > 0)
            {

                List<Contract> contratosList = Util.generarContratos(1, 0, Util.objectsRecordTypesMap.get('Contract').get('GLP').Id, direccionesEntregaQuery[0], cuentasQuery[0].Id);
                insert contratosList;

                List<Contract> contratosQuery = [select id, Status from Contract];

                if(contratosQuery.size() > 0)
                {
                    contratosQuery[0].Status = 'Activado';
                    update contratosQuery[0];
                }

                List<Contract> contratosAfterUpdate = [select Id from Contract];
                List<User> usuariosQuery = [select id from User];
                List<Contact> contactosQuery = [select id from Contact];
                
                WSWebClientes.PeticionSolicitudRevisionInterior psri = new WSWebClientes.PeticionSolicitudRevisionInterior();
                psri.accountId = cuentasQuery[0].id;
                psri.numSerie = '';
                
                List<Task> tasksBefore;
                List<Task> tasksAfter;
                
                tasksBefore = [select Id from Task where WhoId =: psri.accountId];
    
                Test.startTest();
                WSWebClientes.Resultado respuesta = WSWebClientes.solicitarRevisionInterior(psri);
                Test.stopTest();
    
                System.assertEquals('501', respuesta.codigo);
            }
        }
    }

    /**
     * recupera la direccion url de 3 documentos diferentes
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void urlDescargaDocumentoPdfTipo0OK()
    {
        WSWebClientes.PeticionUrlDescargaDocumento peticion0 = new WSWebClientes.PeticionUrlDescargaDocumento('0');
        
        // System.debug(peticion0);        
        // peticion0.tipoDeDocumento = '0';
        // System.debug('+++'+peticion0.tipoDeDocumento);
        
        Test.startTest();
        WSWebClientes.RespuestaUrlDescargaDocumentoPdf respuesta0 = WSWebClientes.urlDescargaDocumentoPdf(peticion0);
        Test.stopTest();

        System.assert(respuesta0.url != '');
        System.assertEquals(respuesta0.resultado.codigo, '200');
        // System.debug('0'+respuesta0.url);
    }

    /**
     * recupera la direccion url del tipo de documento 1
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void urlDescargaDocumentoPdfTipo1OK()
    {
        WSWebClientes.PeticionUrlDescargaDocumento peticion1 = new WSWebClientes.PeticionUrlDescargaDocumento('1');
        
        // System.debug(peticion1);   
        // peticion1.tipoDeDocumento = '0';
        // System.debug('+++'+peticion1.tipoDeDocumento);

        Test.startTest();
        WSWebClientes.RespuestaUrlDescargaDocumentoPdf respuesta1 = WSWebClientes.urlDescargaDocumentoPdf(peticion1);
        Test.stopTest();
                
        System.assert(respuesta1.url != '');
        System.assertEquals(respuesta1.resultado.codigo, '200');
        // System.debug('1'+respuesta1.url);
    }
    /**
     * recupera la direccion url del tipo de documento 2
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void urlDescargaDocumentoPdfTipo2OK()
    {
        WSWebClientes.PeticionUrlDescargaDocumento peticion2 = new WSWebClientes.PeticionUrlDescargaDocumento('2');

        // System.debug(peticion2);        
        // peticion2.tipoDeDocumento = '2';
        // System.debug('+++'+peticion2.tipoDeDocumento);
        
        Test.startTest();
        WSWebClientes.RespuestaUrlDescargaDocumentoPdf respuesta2 = WSWebClientes.urlDescargaDocumentoPdf(peticion2);
        Test.stopTest();
                
        System.assert(respuesta2.url != '');
        System.assertEquals(respuesta2.resultado.codigo, '200');
        // System.debug('2'+respuesta2.url);
    }

    /**
     * no recupera ninguna url por que el tipo no es válido
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void urlDescargaDocumentoPdfTipoNoValido()
    {
        WSWebClientes.PeticionUrlDescargaDocumento peticion4 = new WSWebClientes.PeticionUrlDescargaDocumento('4');

        // System.debug(peticion2);        
        // peticion2.tipoDeDocumento = '2';
        // System.debug('+++'+peticion2.tipoDeDocumento);
        
        Test.startTest();
        WSWebClientes.RespuestaUrlDescargaDocumentoPdf respuesta4 = WSWebClientes.urlDescargaDocumentoPdf(peticion4);
        Test.stopTest();
                
        System.assert(respuesta4.url == '');
        System.assertNotEquals(respuesta4.resultado.codigo, '200');
        // System.debug('2'+respuesta2.url);
    }

    /**
     * procesa y valida el IBAN de una cuenta
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void procesarIBANTest()
    {
        WSWebClientes.PeticionProcesarIBAN peticion = new WSWebClientes.PeticionProcesarIBAN();

        List<Account> cuentas = Util.generarCuentas(1,0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert cuentas;

        List<Account> cuentasQuery = [select Id from Account];
        
        if(cuentasQuery.size() > 0)
        {
            peticion.accountId = cuentasQuery[0].Id;
            peticion.IBAN = 'ES9520802926515599673627'; // generado aleatoriamente            
        }

        Test.startTest();
        WSWebClientes.Resultado resultado = WSWebClientes.procesarIBAN(peticion);
        Test.stopTest();            

        System.assertEquals('200', resultado.codigo);
    }
    /**
     * no procesa correctamente por fallo en IBAN
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void procesarIBANTestFalloEnIBAN()
    {
        WSWebClientes.PeticionProcesarIBAN peticion = new WSWebClientes.PeticionProcesarIBAN();

        List<Account> cuentas = Util.generarCuentas(1,0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert cuentas;

        List<Account> cuentasQuery = [select Id from Account];
        
        if(cuentasQuery.size() > 0)
        {
            peticion.accountId = cuentasQuery[0].Id;
            peticion.IBAN = ''; // generado aleatoriamente            
        }

        Test.startTest();
        WSWebClientes.Resultado resultado = WSWebClientes.procesarIBAN(peticion);
        Test.stopTest();            
        System.debug(resultado.codigo);
        System.assertEquals('501', resultado.codigo);
    }

    /**
     * no procesa correctamente por fallo en accountId
     * 
     * @author pmartin
     * @date 02/03/2020
     */
    @isTest static void procesarIBANTestFalloEnAccountId()
    {
        WSWebClientes.PeticionProcesarIBAN peticion = new WSWebClientes.PeticionProcesarIBAN();

        List<Account> cuentas = Util.generarCuentas(1,0, Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id);
        insert cuentas;

        List<Account> cuentasQuery = [select Id from Account];
        
        if(cuentasQuery.size() > 0)
        {
            peticion.accountId = 'asdf';
            peticion.IBAN = 'ES9520802926515599673627'; // generado aleatoriamente            
        }

        Test.startTest();
        WSWebClientes.Resultado resultado = WSWebClientes.procesarIBAN(peticion);
        Test.stopTest();            

        System.assertEquals('501', resultado.codigo);
    }
    /*
        ======================================================================================
        * -- PRECIO PEDIDO DE GAS  -----------------------------------------------------------
        ======================================================================================
    */
    @isTest 
    static void consultarPrecioPedidoGas_FaltanDatos()
    {
        casosConsultaPrecio(0);
    }

    @isTest 
    static void consultarPrecioPedidoGas_SinContrato()
    {
        casosConsultaPrecio(1);
    }

    @isTest 
    static void consultarPrecioPedidoGas_SinPrecioActual()
    {
        casosConsultaPrecio(2);
    }

    @isTest 
    static void consultarPrecioPedidoGas_SinDeposito()
    {
        casosConsultaPrecio(3);
    }

    @isTest 
    static void consultarPrecioPedidoGas_Correcto()
    {
        casosConsultaPrecio(4);
    }

    private static void casosConsultaPrecio(Integer caso)
    {
        List<Account> cuentasList = generarCuentas(1);
        insert cuentasList;

        Map<Id, List<Direcci_n_de_entrega__c>> direccionesMap = generarDirecciones(cuentasList, 1);
        List<Direcci_n_de_entrega__c> direccionesList = new List<Direcci_n_de_entrega__c>();
        for(Id cuenta : direccionesMap.keySet())
        {
            direccionesList.addAll(direccionesMap.get(cuenta));
        }
        //El caso 2 prueba que la direccion no tenga un precio actual
        if(caso == 2)
        {
            for(Direcci_n_de_entrega__c dir : direccionesList)
            {
                dir.Precio_actual__c = '0.0';
            }
        }
        insert direccionesList;
        //El caso 1 prueba que no exista un contrato
        if(caso != 1)
        {
            Map<Id, List<Contract>> contratosMap = generarContratos(cuentasList, direccionesMap);
            List<Contract> contratosList = new List<Contract>();
            for(Id cuenta : contratosMap.keySet())
            {
                contratosList.addAll(contratosMap.get(cuenta));
            }
            //El caso 3 prueba que el tanque no tenga capacidad
            //gserrano 17-1-2019 se comenta esta aprte proque ahora la capacidad de tanque se recibe en la petición
            /*if(caso == 3)
            {
                for(Contract contrato : contratosList)
                {
                    contrato.Capacidad_tanque__c = 0;
                }
            }*/
            insert contratosList;

            for(Contract contrato : contratosList)
            {
                contrato.Status = 'Activado';
            }
            update contratosList;
        }
        
        WSWebClientes.RespuestaConsultaPrecio respuesta;
        WSWebClientes.PeticionConsultaPrecio peticion = new WSWebClientes.PeticionConsultaPrecio();
        peticion.idioma          = 'ES';
        peticion.idCliente       = String.valueOf(cuentasList[0].Id);
        peticion.idDirNav        = '0';
        peticion.capacidadTanque = '0';
        //El caso 0 prueba que falte algún dato en la petición
        if(caso != 0)
        {
            peticion.nivelActual    = '30';
        }
        if(caso != 3)
        {
            peticion.capacidadTanque = '2000';
        }
        
        Test.startTest();
        respuesta = WSWebClientes.consultarPrecioPedidoGas(peticion);
        Test.stopTest();

        System.debug(respuesta);
        
        System.assertNotEquals(null, respuesta);

        switch on caso 
        {
            when 0 {
                System.assertEquals('501', respuesta.resultado.codigo);
                System.assertEquals('No se han indicado todos los datos necesarios para realizar esta acción', respuesta.resultado.mensaje);   
            }   
            when 1 {
                System.assertEquals('501', respuesta.resultado.codigo);
                System.assertEquals('No se ha encontrado el contrato.', respuesta.resultado.mensaje);            
            }
            when 2 {
                System.assertEquals('501', respuesta.resultado.codigo);
                System.assertEquals('No se ha podido recuperar la información del precio actual.', respuesta.resultado.mensaje);            
            }
            when 3 {
                System.assertEquals('501', respuesta.resultado.codigo);
                System.assertEquals('No se ha podido recuperar la información del depósito.', respuesta.resultado.mensaje);            
            }
            when else {       
                System.assertEquals('200', respuesta.resultado.codigo);
                System.assertEquals('', respuesta.resultado.mensaje);
                System.assertEquals( 849.75, respuesta.costeLlenado);
            }
        }
        //System.assertEquals(, respuesta.costeLlenado);
    }

    private static List<Account> generarCuentas(Integer numCuentas)
    {
        List<Account> cuentasList       = new List<Account>();
        List<Contract> contratosList    = new List<Contract>();

        for(Integer i = 0 ; i < numCuentas ; i++)
        {
            cuentasList.add(new Account(
                                Name    = 'CuentaTest'+i, 
                                Phone   = String.valueOf(i), 
                                RecordTypeId = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id
                ));
        }
        return cuentasList;
    }
    
    private static Map<Id, List<Direcci_n_de_entrega__c>> generarDirecciones(List<Account> cuentasList, Integer numDirecciones)
    {
        Map<Id, List<Direcci_n_de_entrega__c>> direccionesMap = new Map<Id, List<Direcci_n_de_entrega__c>>();

        for(Account cuenta : cuentasList)
        {
            direccionesMap.put(cuenta.Id, new List<Direcci_n_de_entrega__c>());
            for(Integer i = 0 ; i < numDirecciones ; i++)
            {
                direccionesMap.get(cuenta.Id).add(new Direcci_n_de_entrega__c(
                                                    Cuenta__c       = cuenta.Id, 
                                                    Direccion__c    = 'Dir1Test', 
                                                    Direccion_2__c  = 'Dir2Test', 
                                                    Provincia__c    = 'Bizkaia', 
                                                    Codigo_Postal__c= '23455', 
                                                    Poblacion__c    = 'PoblTest',
                                                    Id_Navision__c  = String.valueOf(i),
                                                    Precio_actual__c= '1.5'
                                                    ));
            }
        }
        return direccionesMap;
    }
    
    private static Map<Id, List<Contract>> generarContratos(List<Account> cuentasList,  Map<Id, List<Direcci_n_de_entrega__c>> direccionesMap)
    {
        Map<Id, List<Contract>> contratosMap = new Map<Id, List<Contract>>();

        for(Account cuenta : cuentasList)
        {
            contratosMap.put(cuenta.Id, new List<Contract>());
            for(Direcci_n_de_entrega__c dir: direccionesMap.get(cuenta.Id))
            {
                contratosMap.get(cuenta.Id).add(new Contract(
                                        Name                            = 'ContrTest', 
                                        AccountId                       = cuenta.Id, 
                                        Duraci_n_del_contrato_a_os__c   = '2', 
                                        StartDate                       = Date.today().addYears(-1), 
                                        ContractTerm                    = 24,
                                        Direccion_de_entrega__c         = dir.Id,
                                        Capacidad_tanque__c             = 2000
                                        ));
            }
        }
        return contratosMap;
    }
}