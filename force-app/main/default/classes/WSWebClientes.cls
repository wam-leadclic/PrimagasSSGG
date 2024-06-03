global class WSWebClientes
{
    // constantes
    public static String NOMBRE_IMAGEN_PROMOCION = 'AdjuntoCampaña.';
    private static String IDIOMA_ES = 'ES';
    private static String IDIOMA_CAT = 'CAT';
    @TestVisible private static String IDIOMA_ES_SALIDA = 'Castellano__c';
    @TestVisible private static String IDIOMA_CAT_SALIDA = 'Catalan__c';

    //Propiedad para la obtención de traducciones de los textos de la web de clientes
    //@rcastanos (04/06/2019)
    @TestVisible private static Map<String, Map<String, String>> textosWebClientesMap
    {
        get
        {   
            //Si no hemos recuperado todavía las traducciones lo hacemos y preparamos el mapa de traducciones
            if(textosWebClientesMap == null)
            {
                textosWebClientesMap = new Map<String, Map<String, String>>();

                //Recuperamos todos los metadatos
                List<Textos_Web_Clientes__mdt> textosMetadatos = [SELECT MasterLabel, Castellano__c, Catalan__c FROM Textos_Web_Clientes__mdt];

                //Recorremos todos los metadatos que hemos recuperado para generar el mapa
                for(Textos_Web_Clientes__mdt texto : textosMetadatos)
                {
                    Map<String, String> traducciones = new Map<String, String>();
                    traducciones.put('Castellano__c', texto.Castellano__c);
                    traducciones.put('Catalan__c', texto.Catalan__c);

                    textosWebClientesMap.put(texto.MasterLabel, traducciones);
                }
            }

            return textosWebClientesMap; 
        }

        set;
    }

    //Método encargado de devolver el valor correcto del idioma para solicitar la traducción en base al idioma devuelto por el WS
    //@rcastanos (04/06/2019)
    private static String getIdioma(String idiomaEntrada)
    {
        //Por defecto, definimos el idioma de salida como castellano
        String idiomaSalida = IDIOMA_ES_SALIDA;

        try
        {
            //Si el método recibe parámetro de entrada y es catalán, cambiamos el idioma de salida a catalán
            if(!String.isBlank(idiomaEntrada) && idiomaEntrada.toUpperCase() == IDIOMA_CAT)
            {
                idiomaSalida = IDIOMA_CAT_SALIDA;
            }
        }
        catch(Exception ex)
        {
            System.debug('getCodIdioma-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
        }

        return idiomaSalida;
    }

    // método para devolver PC o DOM a la app
    public static String traducirSegmento(String segmento)
    {
        String segmentoTraducido;

        if(segmento == 'Canalizado')
        {
            segmentoTraducido = 'PC - Canalizado';
        }
        else
        {
            segmentoTraducido = 'DOM - Doméstico';
        }

        return segmentoTraducido;
    }

    // web services
    //@changes rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente y cambio en la recuperación de las preferencias por la migración de cuentas personales
    webservice static RespuestaAcceso loginWeb (PeticionAcceso peticionAcceso)
    {
        Resultado resultado = new Resultado('501', '');
        List<Account> listaCuentas;
        Account cuenta;
        RespuestaAcceso respuesta = new RespuestaAcceso();
        DatosAcceso dAcceso;
        Blob decryptedPass;
        String idiomaEtiqueta;
        Individual persona;
        List<Contact> contactos;
        
        try
        {
            System.debug('peticionAcceso: ' + peticionAcceso);
            if(peticionAcceso == null || String.isBlank(peticionAcceso.username) || String.isBlank(peticionAcceso.password))
            { // la petición está vacía o no cuenta con alguno de los parámetros obligatorios, se devuelve error
                if(peticionAcceso == null)
                    idiomaEtiqueta = getIdioma(null);
                else
                    idiomaEtiqueta = getIdioma(peticionAcceso.idioma);

                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionAcceso.idioma);

                // recuperar la cuenta que tiene como id_fiscal el recibido
                listaCuentas = [select Id, Id_fiscal__c, Contrase_a_web_clientes__c, Bloqueado__c, Id_Navision__c, Segmento1__c, Usuario_Web_Clientes__c, Name
                                    from Account where Usuario_Web_Clientes__c = :peticionAcceso.username];
                if(listaCuentas == null || listaCuentas.isEmpty())
                {
                    // no se encuentra ninguna cuenta con el id_fiscal recibido, se devuelve error
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_no_existe_usuario').get(idiomaEtiqueta));
                }
                else
                {
                    // descifrar la contraseña recibida
                    decryptedPass = Crypto.decrypt('AES128', Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), EncodingUtil.base64decode(peticionAcceso.password));
                    
                    for(Account acc : listaCuentas)
                    {
                        if(decryptedPass != null && decryptedPass.toString().equals(acc.Contrase_a_web_clientes__c))
                        {
                            cuenta = acc;

                            //Recogemos los contactos principales de la cuenta
                            contactos = [SELECT Id, IndividualId FROM Contact WHERE AccountId = :acc.Id AND Contacto_principal__c = true];
                        }
                    }

                    //cuenta = listaCuentas.get(0); // sólo se debería recuperar una cuenta con ese username (Usuario_Web_Clientes__c) por lo que se toma la primera de la lista

                    // comprobar que el usuario tenga uno de los segmentos soportados por la Web, o que sea el usuario Telper
                    if(
                        cuenta != null && cuenta.Id != Util.idClienteTelperWeb
                        && (String.isBlank(cuenta.Segmento1__c) || (cuenta.Segmento1__c != 'Canalizado' && cuenta.Segmento1__c != 'Depósito'))
                        )
                    {// si no es el usuario Telper ni tiene uno de los segmentos soportados por la Web, se devuelve error
                        System.debug('Segmento del cliente no soportado: ' + cuenta.Segmento1__c);
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_login_segmento_incorrecto').get(idiomaEtiqueta));
                    }
                    //Comprobamos que la cuenta tiene un contacto principal
                    else if(contactos == null || (contactos != null && contactos.size() != 1))
                    {
                        System.debug('Contactos principales erroneos: ' + contactos);
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_contacto_principal').get(idiomaEtiqueta));
                    }
                    else
                    {
                        /*Recuperamos la información de las preferencias si es cuenta personal*/
                        List<Individual> personasList = new List<Individual>();

                        personasList = [SELECT Id, Promociones__c, Encuestas_satisfaccion__c, Modificado__c FROM Individual WHERE Id =: contactos[0].IndividualId];
                        

                        // comprobar la contraseña
                        if(decryptedPass != null && decryptedPass.toString().equals(cuenta.Contrase_a_web_clientes__c))
                        { // la contraseña coincide con la del usuario, se devuelven los datos de la respuesta correcta

                            if(contactos != null && contactos.size() == 1)
                            {
                                dAcceso = new DatosAcceso();
                                dAcceso.idCliente       = cuenta.Id;
                                dAcceso.segmento        = traducirSegmento(cuenta.Segmento1__c);
                                dAcceso.bloqueado       = cuenta.Bloqueado__c;
                                dAcceso.numero          = cuenta.Id_Navision__c;

                                if(!personasList.isEmpty())
                                {
                                    dAcceso.promociones     = personasList[0].Promociones__c;
                                    dAcceso.encuestas       = personasList[0].Encuestas_satisfaccion__c;
                                    dAcceso.modificado      = personasList[0].Modificado__c; 
                                }

                                respuesta.datosAcceso = dAcceso;

                                resultado = new Resultado('200', '');
                            }
                            else
                            {
                                System.debug('Contactos principales erroneos: ' + contactos);
                                resultado = new Resultado('501', textosWebClientesMap.get('Error_contacto_principal').get(idiomaEtiqueta));
                            }
                            
                        }
                        else
                        {
                            // la contraseña del usuario no coincide, devolver error
                            resultado = new Resultado('501', textosWebClientesMap.get('Error_login_incorrecto').get(idiomaEtiqueta));
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('loginWeb-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('Error_generico_login').get(idiomaEtiqueta));
        }
        respuesta.resultado = resultado;
        System.debug('RespuestaAcceso: ' + respuesta);

        return respuesta;
    }

    //Cambios rfernandez (17/02/2017) Se van a recuperar los temas de una nueva custom setting (las incidencias van a ser temas)
    //Cambios rfernandez (13/09/2017) Lo que esta comentado son los cambios para la parte de las incidencias
    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente
    webservice static RespuestaGetTiposIncidencias getTiposIncidencias(PeticionGetTiposIncidencias peticionGetTiposIncidencias)
    {
        Resultado resultado = new Resultado('501', '');
        RespuestaGetTiposIncidencias respuesta = new RespuestaGetTiposIncidencias();
        //List<TemasWebClientes__c> listaTemasSF;
        List<TiposIncidencias__c> listaTiposIncidenciasSF;
        List<String> listaTiposIncidencias = new List<String>();
        String idiomaEtiqueta;
        String idioma = IDIOMA_ES;
        try
        {
            System.debug('PeticionGetTemas: ' + peticionGetTiposIncidencias);
            // se recupera el código de idioma correspondiente al idioma recibido
            if(peticionGetTiposIncidencias == null)
            { // la petción está vacía, se toma como idioma por defecto el castellano
                idiomaEtiqueta = getIdioma(null);
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionGetTiposIncidencias.idioma);

                if(!String.isBlank(peticionGetTiposIncidencias.idioma))
                {
                    idioma = peticionGetTiposIncidencias.idioma.toUpperCase();
                }
            }

            // se recuperan los tipos de incidenias de la custom setting TiposIncidencias__c cuyo idioma sea el recibido como parámetro
            listaTiposIncidenciasSF = [select Texto__c from TiposIncidencias__c where Idioma__c = :idioma];
            //listaTemasSF = [select Texto__c from TemasWebClientes__c where Idioma__c = :idioma];
            /*if(listaTemasSF != null)
            {
                for(TemasWebClientes__c ti : listaTemasSF)
                {
                    listaTiposIncidencias.add(ti.Texto__c);
                }
            }*/
            if(listaTiposIncidenciasSF != null)
            {
                for(TiposIncidencias__c ti : listaTiposIncidenciasSF)
                {
                    listaTiposIncidencias.add(ti.Texto__c);
                }
            }

            resultado = new Resultado('200', '');
            respuesta.tiposIncidencias = listaTiposIncidencias;
        }
        catch(Exception ex)
        {
            System.debug('getTiposIncidencias-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('Error_get_tipos_incidencias').get(idiomaEtiqueta));
        }
        respuesta.resultado = resultado;
        System.debug('RespuestaGetTiposIncidencias: ' + respuesta);

        return respuesta;
    }

    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente
    webservice static Resultado recuperarPassword(PeticionRecuperarPassword peticionRecuperarPassword)
    {
        Resultado resultado = new Resultado('501', '');
        List<Account> listaCuentas;
        Account cuenta;
        String password;
        Messaging.SingleEmailMessage mail;
        Messaging.SendEmailResult[] ser;
        String idiomaEtiqueta;
        Boolean errorEnvio = false;

        try
        {
            System.debug('peticionRecuperarPassword: ' + peticionRecuperarPassword);
            if(peticionRecuperarPassword == null || String.isBlank(peticionRecuperarPassword.email)) 
            { // la petición está vacía o no tiene todos los parámetros necesarios, se devuelve error
                if(peticionRecuperarPassword == null)
                    idiomaEtiqueta = getIdioma(null);
                else
                    idiomaEtiqueta = getIdioma(peticionRecuperarPassword.idioma);

                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionRecuperarPassword.idioma);

                // se recuperan las cuentas cuyo email coincide con el recibido, tanto para cuentas personales como empresariales
                listaCuentas = [select Id, Name, Contrase_a_web_clientes__c, Segmento1__c from Account 
                                    where (E_mail__c = :peticionRecuperarPassword.email) 
                                    and (RecordTypeId = :Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id)];
                
                if(listaCuentas == null || listaCuentas.isEmpty())
                {
                    // no se obtiene ninguna cuenta con el email recibido, se devuelve error
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_no_existe_usuario').get(idiomaEtiqueta));
                }
                else
                {
                    cuenta = listaCuentas.get(0);

                    // se comprueba  que la cuenta tenga un segmento soportado por la Web
                    if(String.isBlank(cuenta.Segmento1__c) 
                        //|| (!cuenta.Segmento1__c.startsWithIgnoreCase('PC -') && !cuenta.Segmento1__c.startsWithIgnoreCase('DOM -') && !cuenta.Segmento1__c.startsWithIgnoreCase('PROF -'))) 
                        || (cuenta.Segmento1__c!='Canalizado' && cuenta.Segmento1__c!='Depósito'))
                    { // la cuenta no tiene un segmento soportado por la Web, se devuelve un error
                        System.debug('Segmento del cliente no soportado: ' + cuenta.Segmento1__c);
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_get_pass_segmento_incorrecto').get(idiomaEtiqueta));
                    }
                    else
                    {
                        // comprobar si la cuneta tiene contraseña
                        if(String.isBlank(cuenta.Contrase_a_web_clientes__c))
                        { // la cuenta no tiene contraseña, se devuelve un error
                            System.debug('Error - No se ha recuperado contraseña para la cuenta');
                            resultado = new Resultado('501', textosWebClientesMap.get('Error_no_existe_usuario').get(idiomaEtiqueta));
                        }
                        else
                        { // la cuenta sí tiene un segmento soportado, se genera el email a enviar al usuario
                            password = cuenta.Contrase_a_web_clientes__c;

                            // enviar email a usuario con contraseña sin cifrar
                            mail = new Messaging.SingleEmailMessage();
                            // destinatario del correo
                            mail.setToAddresses( new String[] {peticionRecuperarPassword.email});
                            // nombre del emisor a mostrar
                            mail.setSenderDisplayName('Primagas');
                            
                            // dirección a los que pueden responder los usuarios
                            mail.setReplyTo('no-replay@primagas.com'); // dirección que no existe para que no puedan responder al email

                            if(idiomaEtiqueta == IDIOMA_CAT_SALIDA)
                            {
                                // asunto
                                mail.setSubject('Primagas - Recuperació de contrasenya');
                                // TODO: cuerpo del mensaje según plantilla de primagas en catalán
                                mail.setPlainTextBody('Estimat ' + cuenta.Name + ',\nLa seva contrasenya d\'accés a la web de Primagas és ' + password + '\nRebi una salutació cordial,\n    L\'equip de  Primagas');
                                mail.setHtmlBody('Estimat ' + cuenta.Name + ',<br /><br />La seva contrasenya d\'accés a la web de Primagas és <b>' + password +'</b><br /><br />Rebi una salutació cordial, <br /><i>&nbsp;&nbsp;&nbsp;&nbsp;L\'equip de  Primagas</i>');
                                //
                            }
                            else
                            {
                                // asunto
                                mail.setSubject('Primagas - Recuperación de contraseña');
                                // TODO: cuerpo del mensaje según plantilla de primagas en castellano
                                mail.setPlainTextBody('Estimado ' + cuenta.Name + ',\nSu contraseña de acceso a la web de Primagas es ' + password + '\nReciba un saludo cordial,\n    El equipo de Primagas');
                                mail.setHtmlBody('Estimado ' + cuenta.Name + ',<br /><br />Su contraseña de acceso a la web de Primagas es <b>' + password +'</b><br /><br />Reciba un cordial saludo, <br /><i>&nbsp;&nbsp;&nbsp;&nbsp;El equipo de Primagas</i>');
                                //
                            }

                            // enviar el correo creado
                            try
                            {
                                ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            }
                            catch(System.EmailException eex)
                            {
                                errorEnvio = true;
                                System.debug('recuperarPassword-EmailExcepción: ' + eex.getMessage() + ' - Line: ' + eex.getLineNumber());
                                // diferenciar si el error de envío es por dirección de correo inválida para devolver distintos mensajes de error
                                if(eex.getMessage().contains('INVALID_EMAIL_ADDRESS'))
                                {
                                    resultado = new Resultado('501', textosWebClientesMap.get('Error_error_envio_email_invalido').get(idiomaEtiqueta));
                                }
                                else
                                {
                                    resultado = new Resultado('501', textosWebClientesMap.get('Error_envio_email').get(idiomaEtiqueta));
                                }
                            }
                            if(!errorEnvio)
                            { // si no ha saltado una excepción en el envío, verificar si el envío se ha realizado realmente
                                if(ser == null || ser.size() < 1 )
                                {
                                    System.debug('recuperarPassword-Error envío email: sin resultado');
                                    resultado = new Resultado('501', textosWebClientesMap.get('Error_envio_email').get(idiomaEtiqueta));
                                }
                                else
                                {
                                    if(ser[0].isSuccess())
                                    { // el envío se ha realizado correctamente, se devuelve respuesta correcta
                                        resultado = new Resultado('200', '');
                                    }
                                    else
                                    { // el envío ha fallado, se devuelve error
                                        if( ser[0].getErrors() == null || ser[0].getErrors().size() < 1)
                                        {
                                            System.debug('recuperarPassword-Error envío email');
                                            resultado = new Resultado('501', textosWebClientesMap.get('Error_envio_email').get(idiomaEtiqueta));
                                        }
                                        else
                                        {
                                            System.debug('recuperarPassword-Error envío email: ' + ser[0].getErrors()[0].getMessage() );
                                            resultado = new Resultado('501', textosWebClientesMap.get('Error_envio_email').get(idiomaEtiqueta));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('recuperarPassword-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('Error_get_pass').get(idiomaEtiqueta));
        }

        System.debug('RespuestaRecuperarPassword: ' + resultado);

        return resultado;
    }

    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente
    webservice static RespuestaBusquedaUsuarios busquedaUsuarios(PeticionBusquedaUsuarios peticionBusquedaUsuarios)
    {
        Resultado resultado = new Resultado('501', '');
        RespuestaBusquedaUsuarios respuesta = new RespuestaBusquedaUsuarios();
        String querySelect;
        List<SObject> listaCuentas;
        List<Usuario> listaUsuarios;
        String idiomaEtiqueta;
        String campo;
        String valor;
        
        try
        {
            System.debug('peticionBusquedaUsuarios: ' + peticionBusquedaUsuarios);
            if(peticionBusquedaUsuarios == null )
            {// la petición está vacía, se devuelve error
                idiomaEtiqueta = getIdioma(null);
                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionBusquedaUsuarios.idioma);
                // comprobar si se reciben filtros
                if(peticionBusquedaUsuarios.filtros == null || peticionBusquedaUsuarios.filtros.isEmpty() )
                { // no se recibe ningún filtro para la búsqueda, se devuelve error
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_busqueda_usuario_sin_filtro').get(idiomaEtiqueta));
                }
                else
                {
                    // formar la query para la select en función de los filtros recibidos en la petición
                    querySelect = 'select Id, Name, Id_Navision__c, Bloqueado__c, Entrega_de_producto__c, canalizado_promotor__r.Id_Navision__c, Segmento1__c from Account where ';
                    for(Filtro filtro : PeticionBusquedaUsuarios.filtros)
                    {
                        if(filtro != null && !String.isBlank(filtro.field))
                        {
                            campo = filtro.field;
                            valor = filtro.criteria;
                            querySelect += campo + ' LIKE \'%' + valor + '%\' and ';
                        }
                    }
                    if(!querySelect.endsWith(' and ') && !querySelect.endsWith(' where '))
                    {
                        querySelect += ' and ';
                    }
                    // siempre se tiene que incluir entre las condiciones de la query que el segmento se encuentre entre los soportados por la Web
                    //querySelect += '(Segmento1__c LIKE \'PC -%\' or Segmento1__c LIKE \'DOM -%\' or Segmento1__c LIKE \'PROF -%\')';
                    querySelect += '(Segmento1__c = \'Canalizado\' or Segmento1__c = \'Depósito\')';

                    System.debug('querySelect: ' + querySelect);

                    // ejecutar la query
                    listaCuentas = Database.query(querySelect);

                    if(listaCuentas == null || listaCuentas.isEmpty())
                    { // no se ha recuperado ninguna cuenta aplicando los filtros recibidos, se devuelve error
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_busqueda_usuario_sin_resultado').get(idiomaEtiqueta));
                    }
                    else
                    { // se han recuperado cuentas aplicando los filtros recibidos, se genera la respuesta correcta
                        listaUsuarios = new List<Usuario>();
                        // se crea un objeto Usuario para cada cuenta recuperada
                        for(sObject cuenta : listaCuentas)
                        {
                            if(cuenta.getSObject('canalizado_promotor__r')!=null)
                            {
                                listaUsuarios.add(new Usuario(String.valueOf(cuenta.get('Id')), String.valueOf(cuenta.get('Name')), String.valueOf(cuenta.get('Entrega_de_producto__c')), 
                                                            Boolean.valueOf(cuenta.get('Bloqueado__c')), traducirSegmento(String.valueOf(cuenta.get('Segmento1__c'))), 
                                                            String.valueOf(cuenta.getSObject('canalizado_promotor__r').get('Id_Navision__c')),
                                                            String.valueOf(cuenta.get('Id_Navision__c'))));
                            }
                            else
                            {
                                listaUsuarios.add(new Usuario(String.valueOf(cuenta.get('Id')), String.valueOf(cuenta.get('Name')), String.valueOf(cuenta.get('Entrega_de_producto__c')), 
                                                            Boolean.valueOf(cuenta.get('Bloqueado__c')), traducirSegmento(String.valueOf(cuenta.get('Segmento1__c'))), 
                                                            '',
                                                            String.valueOf(cuenta.get('Id_Navision__c'))));
                            }
                        }
                        respuesta.usuarios = listaUsuarios;

                        resultado = new Resultado('200', '');
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('busquedaUsuarios-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('Error_busqueda_usuarios').get(idiomaEtiqueta));
        }
        respuesta.resultado = resultado;
        System.debug('RespuestaBusquedaUsuarios: ' + respuesta);

        return respuesta;
    }

    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente y cambio en la recuperación de las preferencias por la migración de cuentas personales
    webservice static RespuestaDatosPersonales getDatosPersonales(PeticionGetDatosPersonales peticionDatosPersonales)
    {
        Resultado resultado = new Resultado('501', '');
        RespuestaDatosPersonales respuesta = new RespuestaDatosPersonales();
        List<Account> listaCuentas;
        List<Contact> contactos;
        List<Direcci_n_de_entrega__c> listDireccionesEntrega;
        List<DireccionServicio> listDireccionesServicio;
        List<Contract> listContractsSF;
        List<Contrato> listContratos;
        Account cuenta;
        String fechaFinContrato;
        String fechaVigencia;
        String mes;
        String dia;
        String anyo;
        String idiomaEtiqueta;
        Date dateFin;
        
        try
        {
            System.debug('peticionDatosPersonales: ' + peticionDatosPersonales);
            if(peticionDatosPersonales == null || String.isBlank(peticionDatosPersonales.id))
            { // la petición está vacía o faltan parámetros obligatorios, se devuelve error
                if(peticionDatosPersonales == null)
                    idiomaEtiqueta = getIdioma(null);
                else
                    idiomaEtiqueta = getIdioma(peticionDatosPersonales.idioma);

                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionDatosPersonales.idioma);

                // se recupera la cuenta cuyo Id coincida con el recibido como parámetro, ya sea cuenta empresarial o personal
                listaCuentas = [select Id, Id_Navision__c, Name, Calle_Facturacion__c, Poblacion_Facturacion__c, Codigo_Postal__c, Provincia__c, Phone, E_mail__c,
                                    Cod_forma_pago__c, Cod_terminos_pago__c, C_digo_tarifa__c, 
                                    Mobile_Phone_No__c, RecordTypeId, Id_Fiscal__c, IBAN__c
                                    from Account 
                                    where Id = :peticionDatosPersonales.id 
                                    and (RecordTypeId = :Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id)];
                
                if(listaCuentas == null || listaCuentas.isEmpty())
                { // no se ha recuperado ninguna cuenta con el Id recibido, se devuelve error
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_no_existe_usuario').get(idiomaEtiqueta));
                }
                else
                {
                    cuenta = listaCuentas.get(0); // sólo se debería haber recuperado una cuenta, así que se recupera la primera
                    
                    // recuperar direcciones de servicio (Direcci_n_de_entrega__c) asociadas a la cuenta
                    listDireccionesServicio= new List<DireccionServicio>();
                    listDireccionesEntrega = [select Direccion__c, Direccion_2__c, Provincia__c, Codigo_Postal__c, Poblacion__c, Tipo_de_direccion_de_envio__c
                                                from Direcci_n_de_entrega__c where cuenta__c = :cuenta.Id];
                    if(listDireccionesEntrega != null)
                    {
                        // para cada direcci_n_de_entrega__c recuperada, generar un objeto DireccionServicio que se incluirá en la respuesta
                        for(Direcci_n_de_entrega__c dir : listDireccionesEntrega)
                        {
                            listDireccionesServicio.add(new DireccionServicio(dir.Direccion__c, dir.Direccion_2__c, dir.Provincia__c, dir.Codigo_Postal__c, dir.Poblacion__c, dir.Tipo_de_direccion_de_envio__c));
                        }
                    }

                    // recuperar contratos (Contract) asociados a la cuenta
                    listContratos = new List<Contrato>();
                    listContractsSF = [select ContractNumber, StartDate, EndDate, Duraci_n_del_contrato_a_os__c  from Contract where AccountId = :cuenta.Id and Status = 'Activado'];
                    if(listContractsSF != null)
                    {
                        // para cada contrat recuperado generar un objeto Contrato que se incluirá en la respuesta
                        for(Contract contr : listContractsSF)
                        {
                            if(contr.StartDate == null )
                            {
                                fechaVigencia = '';
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
                                fechaVigencia = anyo + mes + dia;
                            }
                            if(contr.EndDate == null )
                            {
                                // si no hay fecha de fin, calcularla con la fecha de inicio y la duración
                                if(contr.StartDate != null && !String.isBlank(contr.Duraci_n_del_contrato_a_os__c))
                                {
                                    dateFin = contr.StartDate.addYears(Integer.valueOf(contr.Duraci_n_del_contrato_a_os__c));
                                    if(dateFin != null)
                                    {
                                        dia = String.valueOf(dateFin.day());
                                        while( dia.length() < 2 )
                                            dia = '0' + dia;
                                        mes = String.valueOf(dateFin.month());
                                        while( mes.length() < 2 )
                                            mes = '0' + mes;
                                        anyo = String.valueOf(dateFin.year());
                                        while(anyo.length() < 4)
                                            anyo = '0' + anyo;
                                        fechaFinContrato = anyo + mes + dia;
                                    }
                                }
                                else
                                {
                                    fechaFinContrato = '';
                                }
                            }
                            else
                            {
                                dia = String.valueOf(contr.EndDate.day());
                                while( dia.length() < 2 )
                                    dia = '0' + dia;
                                mes = String.valueOf(contr.EndDate.month());
                                while( mes.length() < 2 )
                                    mes = '0' + mes;
                                anyo = String.valueOf(contr.EndDate.year());
                                while(anyo.length() < 4)
                                    anyo = '0' + anyo;
                                fechaFinContrato = anyo + mes + dia;
                            }
                            listContratos.add(new Contrato(String.valueOf(contr.ContractNumber), fechaVigencia, String.valueOf(contr.Duraci_n_del_contrato_a_os__c), fechaFinContrato));
                        }
                    }
                    
                    // recuperar la información restante de la propia cuenta
                    respuesta.datosPersonales = new DatosPersonales(cuenta.Id_Fiscal__c, cuenta.Id_Navision__c, cuenta.Name, cuenta.Calle_Facturacion__c, cuenta.Poblacion_Facturacion__c, 
                                                                cuenta.Codigo_Postal__c, cuenta.Provincia__c, cuenta.Cod_forma_pago__c, cuenta.Cod_terminos_pago__c, 
                                                                '', cuenta.C_digo_tarifa__c, cuenta.Phone, cuenta.Mobile_Phone_No__c, cuenta.E_mail__c, 
                                                                listDireccionesServicio, listContratos, cuenta.IBAN__c);
                    
                    //Recuperamos el contacto principal
                    contactos = [SELECT Id, IndividualId FROM Contact WHERE AccountId = :cuenta.Id AND Contacto_principal__c = true];

                    if(contactos == null || (contactos != null && contactos.size() != 1))
                    {
                        System.debug('Contactos principales erroneos: ' + contactos);
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_contacto_principal').get(idiomaEtiqueta));
                    }
                    else
                    {
                        List<Individual> personasList = new List<Individual>();

                        personasList = [SELECT Id, Promociones__c, Encuestas_satisfaccion__c, Modificado__c FROM Individual WHERE Id =: contactos[0].IndividualId];
                        
                        if(!personasList.isEmpty())
                        {
                            respuesta.datosPersonales.promociones     = personasList[0].Promociones__c;
                            respuesta.datosPersonales.encuestas       = personasList[0].Encuestas_satisfaccion__c;
                            respuesta.datosPersonales.modificado      = personasList[0].Modificado__c; 
                        }
                        //
                        resultado = new Resultado('200', '');
                    }

                    
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('getDatosPersonales-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('Error_get_datos_personales').get(idiomaEtiqueta));
        }
        respuesta.resultado = resultado;
        System.debug('RespuestaDatosPersonales: ' + respuesta);

        return respuesta;
    }

    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente y cambio en la recuperación de las preferencias por la migración de cuentas personales
    webservice static Resultado updateDatosPersonales(PeticionUpdateDatosPersonales peticionUpdateDatosPersonales)
    {
        Resultado resultado = new Resultado('501', '');
        List<Account> listaCuentas;
        List<Contact> contactos;
        Account cuenta;
        Individual persona;
        Database.Saveresult sr;
        String idiomaEtiqueta;
        Boolean modificado = false;
        Boolean preferenciasModificadas = false;

        try
        {
            System.debug('peticionUpdateDatosPersonales: ' + peticionUpdateDatosPersonales);
            if(peticionUpdateDatosPersonales == null || String.isBlank(peticionUpdateDatosPersonales.id))
            { // la petición está vacía o faltan parámetros obligatorios, se devuelve error
                if(peticionUpdateDatosPersonales == null)
                    idiomaEtiqueta = getIdioma(null);
                else
                    idiomaEtiqueta = getIdioma(peticionUpdateDatosPersonales.idioma);

                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                System.debug('Estoy en el else del WS');
                idiomaEtiqueta = getIdioma(peticionUpdateDatosPersonales.idioma);

                // recuperar las cuentas, empresariales o personales, cuyo Id coincida con el recibido en la petición
                listaCuentas = [select Id, RecordTypeId, Calle_Facturacion__c, Poblacion_Facturacion__c, Codigo_Postal__c, Provincia__c, Phone, E_mail__c, 
                                    Mobile_Phone_No__c, Origen_de_modificacion__c
                                    from Account 
                                    where ID = :peticionUpdateDatosPersonales.id
                                    and (RecordTypeId = :Util.objectsRecordTypesMap.get('Account').get('Cliente_existente').Id)];

                if(listaCuentas != null && !listaCuentas.isEmpty())
                {
                    //Recuperamos el contacto principal
                    contactos = [SELECT Id, IndividualId FROM Contact WHERE AccountId = :listaCuentas[0].Id AND Contacto_principal__c = true];
                }
                

                if(listaCuentas == null || listaCuentas.isEmpty())
                { // no se ha recuperado ninguna cuenta con el Id recibido en la petición, se devuelve error
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_no_existe_usuario').get(idiomaEtiqueta));
                }
                else if(contactos == null || (contactos != null && contactos.size() != 1))
                {
                    System.debug('Contactos principales erroneos: ' + contactos);
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_contacto_principal').get(idiomaEtiqueta));
                }
                else
                {
                    System.debug('Hemos encontrado un contacto/cuenta y la peticion es '+peticionUpdateDatosPersonales);
                    cuenta = listaCuentas.get(0); // sólo se debería haber recuperado una cuenta, así que se toma la primera

                    // se actualizan los datos de la cuenta con los recibidos en la petición, siempre que estos últimos tengan algún valor
                    if(!String.isBlank(peticionUpdateDatosPersonales.direccion))
                    {
                        cuenta.Calle_Facturacion__c = peticionUpdateDatosPersonales.direccion;
                        modificado = true;
                    }
                    if(!String.isBlank(peticionUpdateDatosPersonales.poblacion))
                    {
                        cuenta.Poblacion_Facturacion__c = peticionUpdateDatosPersonales.poblacion;
                        modificado = true;
                    }
                    if(!String.isBlank(peticionUpdateDatosPersonales.cp))
                    {
                        cuenta.Codigo_Postal__c = peticionUpdateDatosPersonales.cp;
                        modificado = true;
                    }
                    if(!String.isBlank(peticionUpdateDatosPersonales.provincia))
                    {
                        cuenta.Provincia__c = peticionUpdateDatosPersonales.provincia;
                        modificado = true;
                    }
                    if(!String.isBlank(peticionUpdateDatosPersonales.numTelefono))
                    {
                        cuenta.Phone = peticionUpdateDatosPersonales.numTelefono;
                        modificado = true;
                    }
                    
                    if(!String.isBlank(peticionUpdateDatosPersonales.email))
                    {
                        cuenta.E_mail__c = peticionUpdateDatosPersonales.email;
                        modificado = true;
                    }
                    if(!String.isBlank(peticionUpdateDatosPersonales.movil))
                    {
                        cuenta.Mobile_Phone_No__c = peticionUpdateDatosPersonales.movil;
                        modificado = true;
                    }
                    
                    
                    List<Individual> personasList = new List<Individual>();

                    personasList = [SELECT Id, Promociones__c, Fecha_promociones__c, Encuestas_satisfaccion__c, Fecha_encuestas__c,  Modificado__c, Modificado_desde__c, IP__c FROM Individual WHERE Id =: contactos[0].IndividualId];
                    

                    if(!personasList.isEmpty())
                    {
                        persona = personasList[0];

                        if(peticionUpdateDatosPersonales.promociones != null && persona.Promociones__c != peticionUpdateDatosPersonales.promociones)
                        {
                            persona.Promociones__c              = peticionUpdateDatosPersonales.promociones;
                            persona.Fecha_promociones__c        = System.now();
                            preferenciasModificadas             = true;
                        }
                        if(peticionUpdateDatosPersonales.encuestas != null && persona.Encuestas_satisfaccion__c != peticionUpdateDatosPersonales.encuestas)
                        {
                            persona.Encuestas_satisfaccion__c   = peticionUpdateDatosPersonales.encuestas;
                            persona.Fecha_encuestas__c          = System.now();
                            preferenciasModificadas             = true;
                        }
                        if(!persona.Modificado__c)
                        {
                            persona.Modificado__c               = true;
                            preferenciasModificadas             = true;
                        }
                        if(String.isNotBlank(peticionUpdateDatosPersonales.ip) && persona.IP__c != peticionUpdateDatosPersonales.ip)
                        {
                            persona.IP__c                       = peticionUpdateDatosPersonales.ip;
                            preferenciasModificadas             = true;
                        }

                        if(preferenciasModificadas)
                        {
                            persona.Modificado_desde__c         = 'Web Clientes';
                        }  
                    }
                    /*// descifrar cuentabancaria
                    if(!String.isBlank(peticionUpdateDatosPersonales.cuentaBancaria))
                    {
                        Blob decrypted = Crypto.decrypt('AES128', Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), Blob.valueOf(Util.constantesWebClientes.get('KEY_CIFRADO_WEB')), EncodingUtil.base64Decode(peticionUpdateDatosPersonales.cuentaBancaria));
                        if(decrypted != null)
                        {
                            cuenta.Iban__c = decrypted.toString();
                            modificado = true;
                        }
                    }*/

                    if(modificado) // si se ha realizado la modificación de algun dato
                    {
                        try
                        {
                            // actualizar
                            sr = Database.update( cuenta );
                            if( sr != null )
                            {
                                if( sr.isSuccess() )
                                { // la actualiación ha sido correcta, se devuelve respuesta correcta
                                    resultado = new Resultado('200', '');
                                }
                                else
                                { // ha ocurrido algún error en la actualización, se devuelve error
                                    system.debug( 'Error al actualizar cuenta: ' + sr.getErrors()[0] );
                                    resultado = new Resultado('501', textosWebClientesMap.get('Error_update_datos_personales').get(idiomaEtiqueta));
                                }
                            }
                            else
                            { // la actualización no se ha realizado correctamente (no se ha obtenido resultado de la misma), se devuelve error
                                system.debug( 'Error al actualizar cuenta.' );
                                resultado = new Resultado('501', textosWebClientesMap.get('Error_update_datos_personales').get(idiomaEtiqueta));
                            }
                        }
                        catch( Exception ei )
                        {
                            System.debug( 'Excepción al actualizar cuenta: ' + ei.getMessage() );
                            resultado = new Resultado('501', textosWebClientesMap.get('Error_update_datos_personales').get(idiomaEtiqueta));
                        }
                    }

                    if(preferenciasModificadas)
                    {
                        try
                        {
                            sr = Database.update( persona );
                            if( sr != null )
                            {
                                if( sr.isSuccess() )
                                { // la actualiación ha sido correcta, se devuelve respuesta correcta
                                    resultado = new Resultado('200', '');
                                }
                                else
                                { // ha ocurrido algún error en la actualización, se devuelve error
                                    System.debug( 'Error al actualizar las preferencias: ' + sr.getErrors()[0] );
                                    resultado = new Resultado('501', textosWebClientesMap.get('Error_update_preferencias').get(idiomaEtiqueta));
                                }
                            }
                            else
                            { // la actualización no se ha realizado correctamente (no se ha obtenido resultado de la misma), se devuelve error
                                System.debug( 'Error al actualizar las preferencias.' );
                                resultado = new Resultado('501', textosWebClientesMap.get('Error_update_preferencias').get(idiomaEtiqueta));
                            }
                        }
                        catch(Exception e)
                        {
                            System.debug( 'Excepción al actualizar el registro persona: ' + e.getMessage() );
                            resultado = new Resultado('501', textosWebClientesMap.get('Error_update_preferencias').get(idiomaEtiqueta));
                        }
                    }else if(!modificado && !preferenciasModificadas)
                    {
                        resultado = new Resultado('200', '');
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('updateDatosPersonales-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('Error_generico_update_datos_personales').get(idiomaEtiqueta));
        }
        System.debug('RespuestaUpdateDatosPersonales: ' + resultado);
        return resultado;
    }

    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente
    webservice static RespuestaConsultaPrecio consultarPrecioPedidoGas (PeticionConsultaPrecio peticionconsultaPrecio)
    {
        Resultado resultado = new Resultado('200', '');
        RespuestaConsultaPrecio respuesta = new RespuestaConsultaPrecio();
       
        String idiomaEtiqueta;

        try
        {
            System.debug('peticionconsultaPrecio: ' + peticionconsultaPrecio);
            
            if(peticionconsultaPrecio == null || String.isBlank(peticionconsultaPrecio.idCliente) || 
                String.isBlank(peticionconsultaPrecio.idDirNav) || String.isBlank(peticionconsultaPrecio.nivelActual) || 
                String.isBlank(peticionconsultaPrecio.capacidadTanque))
            { // la petición está vacía o faltan parámetros obligatorios, se devuelve error
                if(peticionconsultaPrecio == null)
                    idiomaEtiqueta = getIdioma(null);
                else
                    idiomaEtiqueta = getIdioma(peticionconsultaPrecio.idioma);

                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionconsultaPrecio.idioma);

                // Recuperamos la información necesaria del contrato y dirección de entrega para calcular el precio
                List<Contract> listaContratos = [SELECT Id, Direccion_de_entrega__r.Precio_actual__c, Status
                                                FROM Contract 
                                                WHERE AccountId = :peticionconsultaPrecio.idCliente
                                                AND Direccion_de_entrega__r.Id_Navision__c = :peticionconsultaPrecio.idDirNav
                                                AND Status = 'Activado'];

                if(listaContratos == null || listaContratos.isEmpty())
                { //No se ha encontrado un contrato para esa cuenta y dirección de entrega
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_consulta_precio_contrato').get(idiomaEtiqueta));
                }
                else
                {
                    Contract contrato = listaContratos.get(0); //sólo se debería haber recuperado un contrato activo, asociado a ese cliente y dirección de entrega
                    String strCapacidadTanque = peticionconsultaPrecio.capacidadTanque.replace(',', '.');
                    Double capacidadTanque = Double.valueOf(strCapacidadTanque);

                    if(contrato.Direccion_de_entrega__r.Precio_actual__c == null || contrato.Direccion_de_entrega__r.Precio_actual__c == '0.0')
                    {
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_consulta_precio_actual').get(idiomaEtiqueta));
                    }
                    else if(String.isBlank(peticionconsultaPrecio.capacidadTanque) || Integer.valueOf(capacidadTanque) == 0)
                    {
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_consulta_precio_deposito').get(idiomaEtiqueta));
                    }
                    else
                    {
                        Double capacidadMaxLlenado = 0.85*capacidadTanque;
                        Double capacidadActual = (Double.valueOf(peticionconsultaPrecio.nivelActual)/100)*capacidadTanque;

                        Double costeLLenadoDevolver = ((capacidadMaxLlenado - capacidadActual) * Decimal.valueOf(contrato.Direccion_de_entrega__r.Precio_actual__c.replace(',', '.'))) * 0.515;
                        
                        Decimal coste = Decimal.valueOf(costeLLenadoDevolver).setScale(2);
                        
                        system.debug('Tengo coste str: ' + coste);
						
	                    respuesta.costeLlenado = Double.valueOf(coste);
                    }
                }
            }
        }
        catch(Exception e)
        {
            LogUtil.crearLog(' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'Errores WSWebClientes', 'WSWebClientes', 'Error', true);
            LogUtil.guardarLog();
            resultado = new Resultado('501', textosWebClientesMap.get('Error_consulta_precio_generico').get(idiomaEtiqueta));
        }
        respuesta.resultado = resultado;

        return respuesta;
    }   

    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente
    webservice static Resultado solicitarDuplicadoFactura(PeticionSolicitudDuplicadoFactura peticionSolicitudDuplicadoFactura)
    {
        Resultado resultado = new Resultado('501', '');
        Task tarea;
        Database.Saveresult sr;
        String idiomaEtiqueta;
        String asunto;

        try
        {
            System.debug('peticionSolicitudDuplicadoFactura: ' + peticionSolicitudDuplicadoFactura);
            if(peticionSolicitudDuplicadoFactura == null || String.isBlank(peticionSolicitudDuplicadoFactura.cliente))
            { // la petición está vacía o faltan parámetros obligatorios, se devuelve error
                if(peticionSolicitudDuplicadoFactura == null)
                    idiomaEtiqueta = getIdioma(null);
                else
                    idiomaEtiqueta = getIdioma(peticionSolicitudDuplicadoFactura.idioma);
                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionSolicitudDuplicadoFactura.idioma);

                // crear nueva tarea con los datos recibidos en la petición
                // el usuario al que se asocia esta tarea siempre es Util.idUserSolicitudDuplicadoFactura
                // el asunto es 'Solicitud de duplicado de factura' (en el idioma que corresponda)
                // la descripción es la indicada por el usuario
                // la tarea se asocia al cliente recibido en la petición
                // la tarea no es recurrente
                // el tipo de la tarea es 'Otros'
                tarea = new Task(OwnerID = Util.idUserSolicitudDuplicadoFactura,
                                 Subject = textosWebClientesMap.get('Tarea_solicitud_duplicado_factura').get(idiomaEtiqueta),
                                 Description = peticionSolicitudDuplicadoFactura.comentarios,
                                 WhatId = peticionSolicitudDuplicadoFactura.cliente,
                                 IsRecurrence = false,
                                 Type = 'Otros');

                try
                {
                    // insertar la tarea
                    sr = Database.insert( tarea );
                    if( sr != null )
                    {
                        if( sr.isSuccess() )
                        {  // la inserción se ha realizado correctamente, se devuelve resultado correcto
                            resultado = new Resultado('200', '');
                            system.debug('Id tarea creada: ' + tarea.Id);
                        }
                        else
                        { // ha ocurrido algún error en la inserción, se devuelve error
                            system.debug( 'Error al guardar tarea de solicitud de duplicado de factura: ' + sr.getErrors()[0] );
                            resultado = new Resultado('501', textosWebClientesMap.get('Error_guardar_duplicado_factura').get(idiomaEtiqueta));
                        }
                    }
                    else
                    { // la inserción no se ha realizado correctamente (no se ha obtenido su resultado), se devuelve error
                        system.debug( 'Error al guardar tarea de solicitud de duplicado de factura.' );
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_guardar_duplicado_factura').get(idiomaEtiqueta));
                    }
                }
                catch( Exception ei )
                {// ha ocurrido una excepción durante la inserción, se devuelve error
                    System.debug( 'Excepción al guardar tarea de solicitud de duplicado de factura: ' + ei.getMessage() );
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_guardar_duplicado_factura').get(idiomaEtiqueta));
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('solicitarDuplicadoFactura-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('Error_duplicado_factura').get(idiomaEtiqueta));
        }
        System.debug('RespuestaSolicitudDuplicadoFactura: ' + resultado);
        return resultado;
    }

    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente
    webservice static RespuestaObtenerPromociones getPromociones(PeticionObtenerPromociones peticionObtenerPromociones)
    {
        Resultado resultado = new Resultado('501', '');
        RespuestaObtenerPromociones respuesta = new RespuestaObtenerPromociones();
        List<Campaign> listaCampanyas;
        List<Attachment> listAttachment;
        Map<Id, Blob> mapCampanyaImagen;
        List<Promocion> listaPromociones;
        Set<Id> idsCampanyas;
        List<Account> listaCuentas;
        Account cuenta;
        Date fechaHoy;
        String mes;
        String dia;
        String anyo;
        String fechainicio;
        String fechaFin;
        Boolean inscrito;
        String idiomaEtiqueta;
        Blob img;

        try
        {
            System.debug('peticionObtenerPromociones: ' + peticionObtenerPromociones);
            if(peticionObtenerPromociones == null || String.isBlank(peticionObtenerPromociones.cliente))
            { // la petición está vacía o faltan parámetros obligatorios, se devuelve error
                if(peticionObtenerPromociones == null)
                    idiomaEtiqueta = getIdioma(null);
                else
                    idiomaEtiqueta = getIdioma(peticionObtenerPromociones.idioma);
                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionObtenerPromociones.idioma);

                // recuperar el cliente cuyo Id coincide con el recibido en la petición
                listaCuentas = [select Id, Campa_a_relacionada__c from Account where Id = :PeticionObtenerPromociones.cliente];
                if(listaCuentas == null || listaCuentas.isEmpty())
                { // no se ha recuperado ninguna cuenta con el Id recibido en la petición, se devuelve error
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_no_existe_usuario').get(idiomaEtiqueta));
                }
                else
                {
                    cuenta = listaCuentas.get(0); // sólo se debería haber recuperado una cuenta, así que se toma la primera

                    mapCampanyaImagen = new Map<Id, Blob>();
                    fechaHoy = Date.today();

                    // recuperar campañas activas (IsActive = true, estado = en curso, fecha de inicio anterior o igual a la actual, fecha de fin posterior o igual a la actual) y que tenga URL de enlace a la promoción
                    listaCampanyas = [select Id, Name, StartDate, EndDate, Type, URL_campa_a__c from Campaign 
                                        where IsActive = true and Status = 'En curso' and (StartDate = null or StartDate <= :fechaHoy) 
                                        and (EndDate = null or EndDate >= :fechaHoy) and URL_campa_a__c != null];
                    //system.debug('listaCampanyas: ' + listaCampanyas);
                    if(listaCampanyas == null || listaCampanyas.isEmpty())
                    {// no se han recuperado campañas activas, se devuelve error
                        System.debug('No se han encontrado campañas activas');
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_sin_promociones_activas').get(idiomaEtiqueta));       
                    }
                    else
                    { // se ha recuperado al menos una campaña activa
                        // recuperar los identificadores de las campañas recuperadas
                        idsCampanyas = new Set<Id>();
                        for(Campaign campanya : listaCampanyas)
                        {
                            idsCampanyas.add(campanya.Id);
                        }

                        // recuperar las imágenes de las campañas de los adjuntos de éstas
                        String nombre = WSWebClientes.NOMBRE_IMAGEN_PROMOCION + '%'; // el nombre del adjunto que corresponde al banner de la promoción tiene un nombre prefijado
                        listAttachment = [select ParentId, Body, Name from Attachment where Name LIKE :nombre and ParentId =:idsCampanyas];
                        //system.debug('listAttachment: ' + listAttachment);
                        if(listAttachment != null)
                        { // guardar en un mapa cada imagen recuperada asociándola con el identificador de su campaña
                            for(Attachment att : listAttachment)
                            {
                                if(att != null && att.Body != null)
                                {
                                    if(!mapCampanyaImagen.containsKey(att.ParentId))
                                    {
                                        mapCampanyaImagen.put(att.ParentId, att.Body);
                                    }
                                }
                            }
                        }

                        listaPromociones = new List<Promocion>();
                        // para cada campaña recuperada se genenera un objeto Promocion que se incluirán en la respuesta
                        for(Campaign camp : listaCampanyas)
                        {
                            // comprobar si la campaña tiene URL de enlace a la promoción
                            if(!String.isBlank(camp.URL_campa_a__c))
                            { // la campaña tiene URL de enlace a la promoción
                                // comprobar si la campaña tiene imagen para el banner
                                if(mapCampanyaImagen.containsKey(camp.Id))
                                {
                                    img = mapCampanyaImagen.get(camp.Id);
                                    if(img != null)
                                    { // la campaña tiene imagen para el banner
                                        // formatear la fecha de inicio de la campaña
                                        if(camp.StartDate == null )
                                        {
                                            fechainicio = '';
                                        }
                                        else
                                        {
                                            dia = String.valueOf(camp.StartDate.day());
                                            while( dia.length() < 2 )
                                                dia = '0' + dia;
                                            mes = String.valueOf(camp.StartDate.month());
                                            while( mes.length() < 2 )
                                                mes = '0' + mes;
                                            anyo = String.valueOf(camp.StartDate.year());
                                            while(anyo.length() < 4)
                                                anyo = '0' + anyo;
                                            fechainicio = anyo + mes + dia;
                                        }
                                        // formatear la fecha de fin de la campaña
                                        if(camp.EndDate == null )
                                        {
                                            fechaFin = '';
                                        }
                                        else
                                        {
                                            dia = String.valueOf(camp.EndDate.day());
                                            while( dia.length() < 2 )
                                                dia = '0' + dia;
                                            mes = String.valueOf(camp.EndDate.month());
                                            while( mes.length() < 2 )
                                                mes = '0' + mes;
                                            anyo = String.valueOf(camp.EndDate.year());
                                            while(anyo.length() < 4)
                                                anyo = '0' + anyo;
                                            fechaFin = anyo + mes + dia;
                                        }
                                        // comprobar si el cliente está inscrito a la campara, comprobando si el identificador de la campaña coincide con el del campo Campa_a_relacionada__c de la cuenta
                                        inscrito = (cuenta.Campa_a_relacionada__c != null && camp.Id.equals(cuenta.Campa_a_relacionada__c));

                                        listaPromociones.add(new Promocion(String.valueOf(camp.Id), Camp.Name, fechainicio, fechaFin, camp.Type, camp.URL_campa_a__c, inscrito, img));
                                    }
                                }
                            }
                        }
                        if(listaPromociones.isEmpty())
                        { // finalmente la lista de promociones a devolver en la repuesta está vacía, se devuelve error
                            System.debug('No se han encontrado promociones con imagen y url entre las campañas activas recuperadas');
                            resultado = new Resultado('501', textosWebClientesMap.get('Error_sin_promociones_activas').get(idiomaEtiqueta));       
                        }
                        else
                        { // finalmente existe alguna promoción a devolver en la respueta, se devuelve respuesta correcta incluyendo la lista de estas promociones
                            respuesta.promociones = new List<Promocion>(listaPromociones);
                            resultado = new Resultado('200', '');
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('getPromociones-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('Error_get_promociones').get(idiomaEtiqueta));
        }
        respuesta.resultado = resultado;
        System.debug('RespuestaObtenerPromociones: ' + respuesta);
        return respuesta;
    }

    //Cambios rfernandez (17/02/2017) Se van a crear todos los casos de tipo Consulta y ahora se recupera el tema que envien
    //Cambios rfernandez (13/09/2017) Descomentar lo comentado asi //*** para implementar los cambios de febrero
    //Cambios rcastanos (04/06/2019) Se modifica el sistema de traducciones de los textos web cliente
    webservice static Resultado enviarIncidencia(PeticionEnviarIncidencia peticionEnviarIncidencia)
    {
        //***String tipoDelCaso = 'Consulta';
        Resultado resultado = new Resultado('501', '');
        Case caso;
        Database.Saveresult sr;
        String idiomaEtiqueta;
        Map<String,List<String>> pickValueMap;
        String tipoDependiente;
        //***List<TemasWebClientes__c> listTiposIncidencias;
        List<TiposIncidencias__c> listTiposIncidencias;
        //***TemasWebClientes__c ti;
        TiposIncidencias__c ti;
        String tema;

        try
        {
            System.debug('peticionEnviarIncidencia: ' + peticionEnviarIncidencia);
            if(peticionEnviarIncidencia == null || String.isBlank(peticionEnviarIncidencia.tipoCaso) || String.isBlank(peticionEnviarIncidencia.cliente))
            { // la petición está vacía o faltan parámetros obligatorios, se devuelve error
                if(peticionEnviarIncidencia == null)
                    idiomaEtiqueta = getIdioma(null);
                else
                    idiomaEtiqueta = getIdioma(peticionEnviarIncidencia.idioma);
                resultado = new Resultado('501', textosWebClientesMap.get('Error_peticion_datos_insuficientes').get(idiomaEtiqueta));
            }
            else
            {
                idiomaEtiqueta = getIdioma(peticionEnviarIncidencia.idioma);

                /*if(codIdioma == ConstantesTextosWebClientes.COD_IDIOMA_ES)
                { // el idioma es castellano, así que el valor para el campo Tema del objeto Case será el recibido
                    tema = peticionEnviarIncidencia.tipoCaso;
                }
                else
                { // el idioma recibido no es castellano, hay que buscar el texto en castellano para cargarlo correctamente en el campo Tema del Case
                    // recuperar los tipos de incidencias de la custom setting TiposIncidencias__c, cuyo Texto coincida con el recibido
                    listTiposIncidencias = [select Name_Texto_ES__c from TiposIncidencias__c where Texto__c = :peticionEnviarIncidencia.tipoCaso];
                    if(listTiposIncidencias != null && !listTiposIncidencias.isEmpty() && !String.isBlank(listTiposIncidencias.get(0).Name_Texto_ES__c))
                    {
                        // recuperar el tipo de incidencia de la custom setting TiposIncidencias__c, cuyo Name coincide con el Name_Texto_ES__c cdel tipo de incidencia recuperada antes
                        ti = TiposIncidencias__c.getValues(listTiposIncidencias.get(0).Name_Texto_ES__c);
                        if(ti == null || String.isBlank(ti.Texto__c))
                        { // no se ha recuperado ningún tipo de incidencia, se considera que el Tema del objeto Case será el recibido 
                            tema = peticionEnviarIncidencia.tipoCaso;
                        }
                        else
                        { // se ha recuperado un tipo de incidencia, se considera como Tema del objeto Case el campo Texto__c de este tipo de incidencia
                            tema = ti.Texto__c;
                        }
                    }
                    else
                    {
                        // si no ha recuperado ningún tipo de incidencia, se considera que el Tema del objeto Case será el recibido
                        tema = peticionEnviarIncidencia.tipoCaso;
                    }
                }
                
                // obtener tipo (Campo Type del objeto Case) dependiente del tema seleccionado
                pickValueMap = DependentPickListValueController.getDependentOptions('Case','Type','Tema__c');
                if(pickValueMap != null && pickValueMap.keySet() != null)
                {
                    for(String tipo : pickValueMap.keySet())
                    {
                        for(String temaAux : pickValueMap.get(tipo))
                        {
                            if(tema.equals(temaAux))
                            {
                                tipoDependiente = tipo;
                                break;
                            }
                        }
                    }
                }*/

                if(idiomaEtiqueta == IDIOMA_ES_SALIDA)
                { // el idioma es castellano, así que el valor para el campo Tipo del objeto Case será el recibido
                    tipoDependiente = peticionEnviarIncidencia.tipoCaso;
                }
                else
                { // el idioma recibido no es castellano, hay que buscar el texto en castellano para cargarlo correctamente en el campo Tipo del Case
                    // recuperar los tipos de incidencias de la custom setting TiposIncidencias__c, cuyo Texto coincida con el recibido
                    //***listTiposIncidencias = [select Name_Texto_ES__c from TemasWebClientes__c where Texto__c = :peticionEnviarIncidencia.tipoCaso];
                    listTiposIncidencias = [select Name_Texto_ES__c from TiposIncidencias__c where Texto__c = :peticionEnviarIncidencia.tipoCaso];
                    if(listTiposIncidencias != null && !listTiposIncidencias.isEmpty() && !String.isBlank(listTiposIncidencias.get(0).Name_Texto_ES__c))
                    {
                        // recuperar el tipo de incidencia de la custom setting TiposIncidencias__c, cuyo Name coincide con el Name_Texto_ES__c cdel tipo de incidencia recuperada antes
                        //***ti = TemasWebClientes__c.getValues(listTiposIncidencias.get(0).Name_Texto_ES__c);
                        ti = TiposIncidencias__c.getValues(listTiposIncidencias.get(0).Name_Texto_ES__c);
                        if(ti == null || String.isBlank(ti.Texto__c))
                        { // no se ha recuperado ningún tipo de incidencia
                            System.debug('No se ha recuperado ningún tipo de incidencia en castellano relacionada con la seleccionada');
                            resultado = new Resultado('501', textosWebClientesMap.get('ERROR_GENERICO_GUARDAR_INCIDENCIA').get(idiomaEtiqueta));
                            return resultado;
                        }
                        else
                        { // se ha recuperado un tipo de incidencia, se considera como Tipo del objeto Case el campo Texto__c de este tipo de incidencia
                            tipoDependiente = ti.Texto__c;
                        }
                    }
                    else
                    {
                        // si no ha recuperado ningún tipo de incidencia
                        System.debug('No se ha recuperado ningún tipo de incidencia en castellano relacionada con la seleccionada');
                        resultado = new Resultado('501', textosWebClientesMap.get('ERROR_GENERICO_GUARDAR_INCIDENCIA').get(idiomaEtiqueta));
                        return resultado;
                    }
                }

                // crear el caso
                // su tipo del caso será el tipo recibido en la petición
                // su descripción serán los comentarios recibidos en la petición
                // estará asocido al cliente (cuenta) recibido en la petición
                // su estado será 'Abierto'
                // su origen será 'Web'
                caso = new Case(//***Type = tipoDelCaso,
                                    Type = tipoDependiente,
                                    //***Tema__c = tipoDependiente,
                                    //***Subject = tipoDelCaso,
                                    Subject = peticionEnviarIncidencia.tipoCaso,
                                    Description = peticionEnviarIncidencia.comentarios,
                                    AccountId = peticionEnviarIncidencia.cliente,
                                    Status = 'Abierto',
                                    Origin = 'Web',
                                    OwnerId = Util.idUserIncidencia);
                try
                {
                    // insertar el caso
                    sr = Database.insert( caso );
                    if( sr != null )
                    {
                        if(sr.isSuccess())
                        { // la inserción del caso se ha realizado correctamente, se devuelve resultado correcto
                            resultado = new Resultado('200', '');

                            // se envía un correo al propietario del caso
                            List<User> usuario = [SELECT Id, Name, Email FROM User WHERE Id=: caso.OwnerId];
                            
                            if(usuario != null && usuario.size() > 0)
                            {
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                                String[] toAddresses = new List<String>{usuario[0].Email};
                                String subject = 'Nuevo caso asignado';
                                String body = 'Se le ha asignado el caso ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id + ' creado desde Web Clientes, cuyo tipo de incidencia es ' + caso.Subject;

                                email.setToAddresses(toAddresses);
                                email.setSubject(subject);                        
                                email.setPlainTextBody(body);
                                email.setReplyTo('sede@primagas.es');
                                email.setSenderDisplayName('Jennifer Abad');

                                Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                                System.debug('##SendEmailResult: ' + result);
                            }
                        }
                        else
                        { // ha ocurrido algún error en la inserción del caso, se devuelve error
                            system.debug( 'Error al guardar caso: ' + sr.getErrors()[0] );
                            resultado = new Resultado('501', textosWebClientesMap.get('Error_guardar_incidencia').get(idiomaEtiqueta));
                        }
                    }
                    else
                    { // la inserción del caso no se ha realizado correctamente (no se ha obtenido resultado de la inserción), se devuelve error
                        system.debug( 'Error al guardar caso.' );
                        resultado = new Resultado('501', textosWebClientesMap.get('Error_guardar_incidencia').get(idiomaEtiqueta));
                    }
                }
                catch( Exception ei )
                { // se ha producido una excepción durante la inserción, se devuelve error
                    System.debug( 'Excepción al guardar caso: ' + ei.getMessage() );
                    resultado = new Resultado('501', textosWebClientesMap.get('Error_guardar_incidencia').get(idiomaEtiqueta));
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('enviarIncidencia-Excepción: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber());
            resultado = new Resultado('501', textosWebClientesMap.get('ERROR_GENERICO_GUARDAR_INCIDENCIA').get(idiomaEtiqueta));
        }
        System.debug('RespuestaEnviarIncidencia: ' + resultado);
        return resultado;
    }

    /**
     * Método auxiliar que comprueba la existencia de una tarea en estado 'Revision interior pendiente'
     * 
     * @author pmartin
     * @date 19/02/2020
     */
    webservice static Integer existeSolicitudInteriorPendientePara(Direcci_n_de_entrega__c direccionEntrega, String contactId)
    {
        if(contactId != null && contactId != '' && direccionEntrega != null)
        {
            try
            {            
                if([select Id from Task where Status = 'Revisión interior pendiente' and Type = 'Otros' and WhatId =: direccionEntrega.Id and WhoId =: contactId].size() == 1)
                {
                    return 1;    // ya existe una solicitud previa para esta direccion y este cliente
                }
                else
                {
                    return 0;   // no existe ninguna revisión previa para esta direccion y este cliente
                }
            }
            catch (Exception e)
            {
                Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error al recuperar el dato. No se ha encontrado una Direccion de entrega para los datos especificados');
                insert log;
                return -1;
            }
        }
        else
        {
            return -1;       // error en los parámetros
        }             
    }

    /**
     * Método que crea una tarea en estado 'Revision interior pendiente' para el candidato o contacto especificado
     * 
     * @author pmartin
     * @date 19/02/2020
     */
    webservice static Resultado solicitarRevisionInterior(PeticionSolicitudRevisionInterior peticionSolicitudRevisionInterior) // string direccion -> numero serie depo || id -> id de cuenta de salesforce (18 -> 15)
    {    
        try
        {    
        
        // comprobamos los parámetros
            if(peticionSolicitudRevisionInterior.accountId != null && peticionSolicitudRevisionInterior.accountId != '' &&
             String.isNotBlank(peticionSolicitudRevisionInterior.numSerie) && String.isNotEmpty(peticionSolicitudRevisionInterior.numSerie))
            {
                /**
                 * MODIFICAR DIRECCION DE ENTREGA WHERE DEPOSITO =: numeroDeSerieDeposito
                 */
                String numSerieDepositoQuery = '%'+peticionSolicitudRevisionInterior.numSerie;
                //String shortAccountId = peticionSolicitudRevisionInterior.accountId.substring(0, 15);
                //System.debug(shortAccountId);
                List<Direcci_n_de_entrega__c> direccionDeEntregaQuery = [select Id from Direcci_n_de_entrega__c where Deposito__c LIKE :numSerieDepositoQuery and Estado__c = 'Active'];
                
                // sólo debería existir una Direccion de Entrega activa para esa dirección
                if(direccionDeEntregaQuery.size() == 1)
                {
                    // variable auxiliar que nos permite trabajar sin Listas
                    Direcci_n_de_entrega__c direccionDeEntrega = direccionDeEntregaQuery[0];

                    List<Contact> contacts = [select Id from Contact where AccountId =: peticionSolicitudRevisionInterior.accountId and Contacto_principal__c = true];

                    if(contacts.size() > 0 )
                    {
                        Contact contact = contacts[0];

                        Integer existe = existeSolicitudInteriorPendientePara(direccionDeEntrega, contact.Id);
                
                        // EXISTE -> hay una Tarea (Task) con Estado 'Revision interior pendiente' para la Dirección de entrega especificada (que esté activa) y el candidato/contacto especificado por Id
                        if(existe == 1)
                        {
                            Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='[previous_task] Existía una Solicitud de Revisión Interior previa para este Id');
                            insert log;
                            // no hacemos nada 
                            return new Resultado('501', '[previous_task] Existía una Solicitud de Revisión Interior previa para este Id');
                        }
                        // NO EXISTE -> no hay ninguna solicitud de revisión activa para la dirección especificada
                        else if(existe == 0 )
                        {
                            // comprobar contratos activos para la Direccion de Entrega activa que hemos consultado antes
                            List<Contract> contratosQuery = [select Id from Contract where Direccion_de_entrega__c =: direccionDeEntrega.Id and Status = 'Activado'];
    
                            // si existen contratos activos para esa Direccion de Entrega
                            if(contratosQuery.size() > 0)
                            {
                                // si existe solo uno
                                if(contratosQuery.size() == 1)
                                {
                                    // tenemos que crear una tarea -> consultar el metadato para asignar valores a la nueva tarea
                                    // List<Solicitud_de_revision__mdt> metadatoSolicitudRevision = Util.obtenerMetadatosRevisionInterior();
                                    List<Solicitud_de_revision__mdt> metadatoSolicitudRevision = [select Id, Asunto__c, Descripcion__c, Persona_asignada__c, Tipo_de_la_tarea__c from Solicitud_de_revision__mdt];
                                    // System.debug('Solicitud de Revision MDT encontrados : '+metadatoSolicitudRevision.size());
                                    if(metadatoSolicitudRevision.size() == 1)
                                    {
                                        List<User> usuario = [select Id, Email from User where Name =: metadatoSolicitudRevision[0].Persona_asignada__c];
    
                                        if(usuario.size() == 1)
                                        {
                                            // crea tarea y devuelve OK
                                            Task tareaSolicitudRevisionInterior = new Task(
                                                OwnerId = usuario[0].Id,
                                                Subject = metadatoSolicitudRevision[0].Asunto__c,
                                                Description = metadatoSolicitudRevision[0].Descripcion__c,
                                                Status = 'Revisión interior pendiente',
                                                WhatId = direccionDeEntrega.Id,
                                                WhoId = contact.Id, // viene desde el parámetro del método
                                                IsRecurrence = false,
                                                Type = metadatoSolicitudRevision[0].Tipo_de_la_tarea__c
                                            );

                                            Database.DMLOptions dmlo = new Database.DMLOptions();
                                            dmlo.EmailHeader.triggerUserEmail = true;
                                            database.insert(tareaSolicitudRevisionInterior, dmlo);

                            
                                            if(usuario != null && usuario.size() > 0)
                                            {
                                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                                                String[] toAddresses = new List<String>{usuario[0].Email};
                                                String subject = 'Nueva tarea asignada';
                                                String body = 'Se le ha asignado una nueva tarea ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tareaSolicitudRevisionInterior.Id + ' creada desde Web Clientes.';
                
                                                //email.setToAddresses(toAddresses);
                                                //toAddresses.clear();
                                                //toAddresses.add('iescalante@nts-solutions.com');
                                                email.setToAddresses(toAddresses);
                                                email.setSubject(subject);                        
                                                email.setPlainTextBody(body);
                                                email.setReplyTo('sede@primagas.es');
                                                email.setSenderDisplayName('Jennifer Abad');
                
                                                Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                                                System.debug('##SendEmailResult: ' + result);
                                            }

                                            //insert tareaSolicitudRevisionInterior;
                                            return new Resultado('200', 'OK');
                                        }
                                        else
                                        {
                                            Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='[user_not_found] Error en la creación de Tarea \'Solicitud de Revision interior\'. No se ha encontrado un usuario existente con el nombre de la Persona asignada en el Metadato.');
                                            insert log;
                                            // respuesta error en la consula de usuarios
                                            return new Resultado('501', '[user_not_found] Error en la creación de Tarea \'Solicitud de Revision interior\'. No se ha encontrado un usuario existente con el nombre de la Persona asignada en el Metadato.');
                                        }
                                    }
                                    else
                                    {
                                        //respuesta del tipo error en la consulta de metadatos
                                        Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error al recuperar el dato. No se ha encontrado el Metadato \'Solicitud de revision\'.');
                                        insert log;
                                        return new Resultado('501', '[metadata_not_found] Error en la creación de Tarea Solicitud de Revision interior. No se ha encontrado el Metadato \'Solicitud de revision\'.');
                                    }
                                }
                                else
                                {
                                    Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error al crear la tarea. Existen varios contratos activos para la misma dirección de entrega');
                                    insert log;
                                    return new Resultado('501', '[many_active_contracts] Error al crear la Tarea. Existe más de un contrato activo para la dirección de entrega especificada.');
                                }
                            }
                            else
                            {
                                Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='[no_active_contracts] Error al crear la Tarea. No existen contratos activos para la dirección de entrega especificada');
                                insert log;
                                return new Resultado('501', '[no_active_contracts] Error al crear la Tarea. No existen contratos activos para la dirección de entrega especificada');
                            }
                        }
                        else if(existe == -1)
                        {
                            //respuesta del tipo error en parametros
                            Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error en la creación de Tarea Solicitud de Revision interior. Error en los parámetros o los parámetros proporcionados no tienen registros de Direccion de entrega activos.');
                            insert log;
                            return new Resultado('501', '[no_location_for_param] Error en la creación de Tarea Solicitud de Revision interior. Error en los parámetros o los parámetros proporcionados no tienen registros de Direccion de entrega activos.');
                        }
                        else
                        {
                            Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error en la creación de Tarea Solicitud de Revision interior. Error no contemplado.');
                            insert log;
                            return new Resultado('501', '[unkown_error] Error en la creación de Tarea Solicitud de Revision interior. Error no contemplado.');
                        }
                    }
                    else
                    {
                        Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error en la creación de Tarea Solicitud de Revision interior. Error no contemplado.');
                        insert log;
                        return new Resultado('501', 'Error en la creación de Tarea Solicitud de Revision interior. Error no contemplado.');
                    }
                }
                else
                {
                    Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c = 'Error en la creación de Tarea Solicitud de Revisión Interior. Se han recuperado 0 o más de 1 dirección de entrega');
                    insert log;
                    return new Resultado('501', '[0_or_many_location] Error en la creación de Tarea Solicitud de Revisión Interior. Error en la consulta de dirección de entrega (0 o más de > 1 dirección de entrega encontradas)');
                }
            
            }
            else
            {
                Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error en la creación de Tarea Solicitud de Revision interior. Parámetros inválidos (nulos o vacíos).');
                insert log;
                return new Resultado('501', '[param_error] Error en la creación de Tarea Solicitud de Revision interior. Parámetros inválidos (nulos o vacíos).');
            }
        }
        catch (Exception e)
        {
            // respuesta -> error en las queries
            Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c =' Error en la creación de Tarea de Solicitud de Revisión interior : '+e.getMessage());
            insert log;
            return new Resultado('501', '[exception] Error al crear la Tarea de Solicitud de Revision interior. Error :'+e.getMessage());
        }
    }

    /**
     * Método que devuelve la URL de un PDF específico en función del tipo indicado
     * 
     * @author pmartin
     * @date 20/02/2020
     * @params String tipoDeDocumento : existen diferentes documentos por lo tanto identificamos el que queremos recuperar en función de este parametro
     */
    webservice static RespuestaUrlDescargaDocumentoPdf urlDescargaDocumentoPdf(PeticionUrlDescargaDocumento peticionUrlDescargaDocumento)
    {
        RespuestaUrlDescargaDocumentoPdf respuesta;

        if(String.isNotBlank(peticionUrlDescargaDocumento.tipoDeDocumento) && String.isNotEmpty(peticionUrlDescargaDocumento.tipoDeDocumento))
        {
            try
            {
                String url = [select Id, URL__c from URL_documentos_de_factura__mdt where Tipo__c =: peticionUrlDescargaDocumento.tipoDeDocumento].URL__c;
            
                if(String.isNotBlank(url) && String.isNotEmpty(url))
                {
                    respuesta = new RespuestaUrlDescargaDocumentoPdf(url, new Resultado('200', 'OK'));
                    return respuesta;
                }
                else
                {
                    respuesta = new RespuestaUrlDescargaDocumentoPdf('', new Resultado('501', 'Error al recuperar el dato. No se ha encontrado una URL para el Tipo especificado'));
                    Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error al recuperar el dato. No se ha encontrado una URL para el Tipo especificado');
                    insert log;
                    return respuesta;    
                }
            }
            catch(Exception e)
            {
                respuesta = new RespuestaUrlDescargaDocumentoPdf('', new Resultado('501', 'Error al recuperar el dato. No se ha encontrado el Tipo especificado'));
                Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c='Error al recuperar el dato. No se ha encontrado el Tipo especificado');
                insert log;
                return respuesta;
            }
        }
        else
        {
            respuesta = new RespuestaUrlDescargaDocumentoPdf('', new Resultado('501', 'Error al recuperar el dato. El parámetro no es correcto (está vacío o es nulo)'));
            return respuesta;    
        }   
    }

    /**
     * Método que asigna un IBAN a una cuenta en función de los parámetros recibidos por parámetro
     * 
     * @author pmartin
     * @date 20/02/2020
     * @params PeticionProcesarIBAN: contiene 2 atributos IBAN (String) y accountId (String)
     */
    webservice static Resultado procesarIBAN(PeticionProcesarIBAN peticionProcesarIBAN)
    {
        System.debug('peticionProcesarIBAN = '+peticionProcesarIBAN);
        if(String.isNotBlank(peticionProcesarIBAN.IBAN) && String.isNotEmpty(peticionProcesarIBAN.IBAN) && peticionProcesarIBAN.accountId != null && peticionProcesarIBAN.accountId != '')
        {
            List<Account> cuentas = [select Id, IBAN__c from Account where Id =: peticionProcesarIBAN.accountId];
            System.debug('CUENTA = '+cuentas);

            if(cuentas.size() == 1 )
            {
                Account cuenta = cuentas[0];
                
                cuenta.IBAN__c = peticionProcesarIBAN.IBAN;
                //cuenta.Cuenta_bloqueada_cambio__c = true;
                cuenta.Cuenta_actualizada_desde_codigo__c = false;
                cuenta.Origen_de_modificacion__c = 'Web';

                
                Database.SaveResult updateResult = Database.update(cuenta);

                if(updateResult.isSuccess())
                {
                    return new Resultado('200', 'OK');
                }
                else
                {
                    Log__c log = new Log__c(Name='WSWebClientes', Error__c = true, Descripcion__c= 'Error al actualizar el campo. Error en la acción de base de datos.');
                    insert log;
                    return new Resultado('501', 'Error al actualizar el campo. Error en la acción de base de datos.');
                    
                }
            }
            else
            {
                return new Resultado('501', 'Error al actualizar el campo. No se ha podido recuperar una cuenta con el Id proporcionado.');
            }
        }
        else
        {
            return new Resultado('501', 'Error al actualizar el campo. Los parámetros no son correctos');    
        }
    }

    // clases para peticiones
    global class PeticionAcceso
    {
        webservice String username;
        webservice String password;
        webservice String idioma;
    }
    
    global class PeticionRecuperarPassword
    {
        webservice String idioma;
        webservice String email;
    }

    global class PeticionGetTiposIncidencias
    {
        webservice String idioma;
    }

    global class PeticionBusquedaUsuarios
    {
        webservice String idioma;
        webservice List<Filtro> filtros;
    }

    global class Filtro
    {
        webservice String field;
        webservice String criteria;

        public Filtro()
        {}
        public Filtro(String pField, String pCriteria)
        {
            this.field = pField;
            this.criteria = pCriteria;
        }
    }

    global class PeticionGetDatosPersonales
    {
        webservice String idioma;
        webservice String id;
    }

    global class PeticionUpdateDatosPersonales
    {
        webservice String idioma;
        webservice String id;
        webservice String direccion;
        webservice String poblacion;
        webservice String cp;
        webservice String provincia;
        webservice String numTelefono;
        webservice String movil;
        webservice String email;
        webservice String cuentaBancaria;
        /*Cambios rfernandez (18/08/2018): Añadidos campos de preferencias*/
        webservice Boolean promociones;
        webservice Boolean encuestas;
        webservice String ip;
    }

    global class PeticionSolicitudDuplicadoFactura
    {
        webservice String idioma;
        webservice String comentarios;
        webservice String cliente;
    }

    global class PeticionObtenerPromociones
    {
        webservice String idioma;
        webservice String cliente;
    }

    global class PeticionAdicionAPromocion
    {
        webservice String idioma;
        webservice String cliente;
        webservice String idPromocion;
    }

    global class PeticionEnviarIncidencia
    {
        webservice String idioma;
        webservice String tipoCaso;
        webservice String comentarios;
        webservice String cliente;
    }

    global class PeticionConsultaPrecio
    {
        webservice String idioma;
        webservice String idCliente;
        webservice String idDirNav;
        webservice String nivelActual;
        webservice String capacidadTanque;
    }

    // TODO
    global class PeticionSolicitudRevisionInterior
    {
        webservice String numSerie;
        webservice String accountId;
    }

    global class PeticionUrlDescargaDocumento
    {
        webservice String tipoDeDocumento; 
        public PeticionUrlDescargaDocumento(String tipoDeDocumento){
            this.tipoDeDocumento = tipoDeDocumento;
        }
    }

    global class PeticionProcesarIBAN
    {
        webservice String IBAN;
        webservice String accountId;
        public PeticionProcesarIBAN (String IBAN, String accountId)
        {
            this.IBAN = IBAN;
            this.accountId = accountId;
        }
        public PeticionProcesarIBAN ()
        {}
    }

    // clases para respuestas
    global class Resultado
    {
        webservice String codigo;
        webservice String mensaje;
        
        public Resultado(String pCodigo, String pMensaje)
        {
            this.codigo = pCodigo;
            this.mensaje = pMensaje;
        }
    }
    
    global class RespuestaAcceso
    {
        webservice Resultado resultado;
        webservice DatosAcceso datosAcceso;
        
        public RespuestaAcceso()
        {
        }
        public RespuestaAcceso(Resultado pResultado)
        {
            this.resultado = pResultado;
        }
    }
    
    global class DatosAcceso
    {
        webservice String segmento;
        webservice Boolean bloqueado;
        webservice String idCliente;
        webservice String numero;
        /*Cambios rfernandez (18/08/2018): Añadidos campos de preferencias*/
        webservice Boolean promociones;
        webservice Boolean encuestas;
        webservice Boolean cuentaPersonal;
        webservice Boolean modificado;
    }

    global class RespuestaGetTiposIncidencias
    {
        webservice Resultado resultado;
        webservice List<String> tiposIncidencias;

        public RespuestaGetTiposIncidencias()
        {
        }
        public RespuestaGetTiposIncidencias(Resultado pResultado)
        {
            this.resultado = pResultado;
        }
    }

    global class Usuario
    {
        webservice String id;
        webservice String nombre;
        webservice String entrega;
        webservice Boolean bloqueado;
        webservice String segmento;
        webservice String numCanailzado;
        webservice String numero;

        public Usuario()
        {
        }
        public Usuario(String pId, String pNombre, String pEntrega, Boolean pBloqueado, String pSegmento, String pNumCanalizado, String numero)
        {
            this.id = pId;
            this.nombre = pNombre;
            this.entrega = pEntrega;
            this.bloqueado = pBloqueado;
            this.segmento = pSegmento;
            this.numCanailzado = pNumCanalizado;
            this.numero = numero;
        }
    }

    global class RespuestaBusquedaUsuarios
    {
        webservice Resultado resultado;
        webservice List<Usuario> usuarios;

        public RespuestaBusquedaUsuarios()
        {            
        }
        public RespuestaBusquedaUsuarios(Resultado pResultado)
        {
            this.resultado = pResultado;
        }
    }

    global class RespuestaDatosPersonales
    {
        webservice Resultado resultado;
        webservice DatosPersonales datosPersonales;

        public RespuestaDatosPersonales()
        {
        }
        public RespuestaDatosPersonales(Resultado pResultado)
        {
            this.resultado = pResultado;
        }
    }

    global class DatosPersonales
    {
        webservice String numero;
        webservice String nombre;
        webservice String direccion;
        webservice String poblacion;
        webservice String cp;
        webservice String provincia;
        webservice String formaPago;
        webservice String terminosPago;
        webservice String cuentaBancaria;
        webservice String tarifaActual;
        webservice String numTelefono;
        webservice String movil;
        webservice String email;
        webservice List<DireccionServicio> direccionesServicio;
        webservice List<Contrato> contratos;
        webservice String nifcif;
        /*Cambios rfernandez (18/08/2018): Añadidos campos de preferencias*/
        webservice Boolean promociones;
        webservice Boolean encuestas;
        webservice Boolean cuentaPersonal;
        webservice Boolean modificado;
        /*cambios pmartin (04/03/2020): añadido campo IBAN en la respuesta*/
        webservice String IBAN;

        public DatosPersonales()
        {}
        public DatosPersonales(String pNifcif, String pNum, String pNombre, String pDir, String pPoblacion, String pCp, String pProvincia, String pFormaPago, String pTermPago, 
                                String pCtaBancaria, String pTarifaAct, String pNumTfno, String pMovil, String pEmail, List<DireccionServicio> pDireccionesServicio,
                                List<Contrato> pContratos, String IBAN)
        {
            this.nifcif = pNifcif;
            this.numero = pNum;
            this.nombre = pNombre;
            this.direccion = pDir;
            this.poblacion = pPoblacion;
            this.cp = pCp;
            this.provincia = pProvincia;
            this.formaPago = pFormaPago;
            this.terminosPago = pTermPago;
            if(!String.isBlank(pCtaBancaria))
            {
                this.cuentaBancaria = pCtaBancaria.substring(0, pCtaBancaria.length()-4) + '****';
            }
            this.tarifaActual = pTarifaAct;
            this.numTelefono = pNumTfno;
            this.movil = pMovil;
            this.email = pEmail;
            this.direccionesServicio = new List<DireccionServicio>(pDireccionesServicio);
            this.contratos = pContratos;
            this.IBAN = IBAN;
        }
    }

    global class RespuestaConsultaPrecio
    {
        webservice Resultado resultado;
        webservice Double costeLlenado;

        public RespuestaConsultaPrecio()
        {
        }
        public RespuestaConsultaPrecio(Resultado pResultado)
        {
            this.resultado = pResultado;
        }
    }

    global class Contrato
    {
        webservice String numContrato;
        webservice String vigencia;
        webservice String duracionContrato;
        webservice String fechaFinalizacionContrato; // formato yyyyMMdd

        public Contrato(String pNum, String pVigencia, String pDuracion, String pFechaFin)
        {
            this.numContrato = pNum;
            this.vigencia = pVigencia;
            this.duracionContrato = pDuracion;
            this.fechaFinalizacionContrato = pFechaFin;
        }
    }

    global class DireccionServicio
    {
        webservice String direccionServicio;
        webservice String direccionServicio2;
        webservice String provinciaServicio;
        webservice String cpServicio;
        webservice String poblacionServicio;
        webservice String tipoDeDireccion;

        public DireccionServicio(String pDirServicio, String pDirServicio2, String pProvinciaServicio, String pCpServicio, String pPoblacionServicio, String pTipoDeDireccion)
        {
            this.direccionServicio = pDirServicio;
            this.direccionServicio2 = pDirServicio2;
            this.provinciaServicio = pProvinciaServicio;
            this.cpServicio = pCpServicio;
            this.poblacionServicio = pPoblacionServicio;
            this.tipoDeDireccion = pTipoDeDireccion;
        }
    }

    global class RespuestaObtenerPromociones
    {
        webservice Resultado resultado;
        webservice List<Promocion> promociones;

        public RespuestaObtenerPromociones()
        {
        }
        public RespuestaObtenerPromociones(Resultado pResultado)
        {
            this.resultado = pResultado;
        }
    }

    global class Promocion
    {
        webservice String idPromocion;
        webservice String nombrePromocion;
        webservice String fInicio; // formato yyyyMMdd
        webservice String fFin; // formato yyyyMMdd
        webservice String tipo;
        webservice String link;
        webservice Boolean inscrito;
        webservice Blob bannerPromocion;

        public Promocion()
        {
        }
        public Promocion(String pId, String pNombre, String pFInicio, String pFFin, String pTipo, String pLink, Boolean pInscrito, Blob pBannerPromocion)
        {
            this.idPromocion = pId;
            this.nombrePromocion = pNombre;
            this.fInicio = pFInicio;
            this.fFin = pFFin;
            this.tipo = pTipo;
            this.link = pLink;
            this.inscrito = pInscrito;
            this.bannerPromocion = pBannerPromocion;
        }
    }

    global class RespuestaUrlDescargaDocumentoPdf
    {
        webservice String url;
        webservice Resultado resultado;

        public RespuestaUrlDescargaDocumentoPdf(String url, Resultado resultado)
        {
            this.url = url;
            this.resultado = resultado;
        }
    }
}