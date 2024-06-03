//26/09/2016
//Se ha eliminado la comprobacion para los campos de las direcciones. Ahora solo se tiene en cuenta los campos de direccion para actualiar o crear una nueva direccion de entrega
//Solo se comprueba ahora si los nuevos campos no estan vacios para actualizar en caso de existir la direccion de entrega
@RestResource(urlMapping='/DatosContrato/*')
global class WSDatosContrato
{
    public static final String RESP_PROYECTO_EXTERIOR = 'proyecto_exterior';
    public static final String RESP_OBRA_CIVIL_DEPOSITO = 'obra_civil_deposito';
    public static final String RESP_OBRA_CIVIL_TUBERIA = 'obra_civil_tuberia';
    public static final String RESP_ENTREGA = 'entrega';
    public static final String RESP_VALLADO = 'vallado';
    public static final String RESP_INSTALACION_INTERIOR = 'instalacion_interior';
    public static final String RESP_INSTALACION_EXTERIOR = 'instalacion_exterior';
    public static final String RESP_PRESENTACION_AYUNTAMIENTO = 'presentacion_ayuntamiento';
    public static final String RESP_PROYECTO_INTERIOR = 'proyecto_interior';
    public static final String RESP_OTROS = 'otros';

    @HttpPost
    webservice static String enviar(PeticionDatosContrato peticion)
    {
        LogUtil.crearLog(JSON.serialize(peticion), 'Peticiones NewSales', 'WSDatosContrato', 'Error', false);
        
        Respuesta r = new Respuesta();
        String jRespuesta = '';
        
        Boolean error = false;
        Savepoint sp = Database.setSavepoint();

        DatosContrato datosContrato;
        EntidadesWSClientesYOfertas.DatosCliente datosCliente;
        DatosOferta datosOferta;
        String esBorrador = '';
        try
        {
            if(peticion != null && peticion.datosContrato != null && peticion.datosCliente != null && peticion.datosOferta != null)
            {
                datosContrato = peticion.datosContrato;
                datosCliente = peticion.datosCliente;
                datosOferta = peticion.datosOferta;
                r.resultado.texto = '';
                List<Account> cuenta;
                List<Contact> contacto;
                List<Quote> presupuesto;
                List<Opportunity> oportunidad;
                List<Pricebook2> tarifa;
                Direcci_n_de_entrega__c dirEntrega;
                Boolean idClienteIncorrecto = false;
                Database.SaveResult sr;
                Database.Error err;
                Boolean borrador = false;

                //Permitir duplicados
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;

                if(datosCliente.identificador != null && datosCliente.identificador != '')
                {
                    cuenta = [SELECT Id, Id_Fiscal__c, PersonContactId FROM Account WHERE Id=: datosCliente.identificador];
                    if(cuenta!=null && cuenta.size()>0)
                    {                                            
                        if(datosContrato.idOfertaSF != null && datosContrato.idOfertaSF != '')
                        {
                            presupuesto = [SELECT Id, OpportunityId FROM Quote WHERE Id=: datosContrato.idOfertaSF];
                            if(presupuesto.size()>0)
                            {
                                List<OpportunityContactRole> contactoRol = [SELECT ContactId, OpportunityId, Role FROM OpportunityContactRole WHERE OpportunityId=: presupuesto[0].OpportunityId];
                                if(contactoRol.size()>0)
                                {                   
                                    OpportunityContactRole contactoRolFirmante;
                                    for(OpportunityContactRole cr : contactoRol)
                                    {
                                        if(cr.Role=='Firmante de contrato')
                                        {
                                            contactoRolFirmante = cr;
                                            break;
                                        }
                                    }
                                    if(contactoRolFirmante == null)
                                    {
                                        contactoRolFirmante = contactoRol[0];
                                    }

                                    contacto = [SELECT Id, DNI__C FROM Contact WHERE Id=: contactoRolFirmante.ContactId];

                                    //Actualizo los datos del contacto
                                    contacto[0].FirstName = datosCliente.nombre;
                                    contacto[0].LastName = datosCliente.apellidos;
                                    contacto[0].Phone = datosCliente.telefono;
                                    contacto[0].MobilePhone =datosCliente.telefonoMovil;
                                    contacto[0].Fax = datosCliente.fax;
                                    if(String.isNotBlank(datosContrato.directorio_pdf))
                                    {
                                        contacto[0].Email = datosCliente.email;
                                    }
                                    contacto[0].DNI__c = datosCliente.dni;

                                    contacto[0].setOptions(dml);
                                    sr = Database.update(contacto[0], false);
                                    if(!sr.isSuccess())
                                    {
                                        err = sr.getErrors()[0];
                                        r.resultado.codigo = '803';
                                        r.resultado.texto += Label.WSError_803 + ' ' + contacto[0].Id;
                                        LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                                        error = true;
                                    }                          
                                }
                                else
                                {
                                    r.resultado.codigo = '804';
                                    r.resultado.texto += Label.WSError_804 + ' ' + presupuesto[0].OpportunityId;
                                    LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                                    error = true;
                                }
                            }                              
                        }

                        //Actualizo los datos de la cuenta
                        if(String.isNotBlank(datosCliente.compania))
                        {
                            cuenta[0].Name = datosCliente.compania; 
                        }
                        
                        cuenta[0].Id_fiscal__c = (String.isBlank(datosCliente.cif) && !String.isBlank(datosCliente.dni)) ? datosCliente.dni : datosCliente.cif;
                        cuenta[0].ShippingStreet = datosCliente.calle;
                        cuenta[0].ShippingPostalCode = datosCliente.cp;
                        cuenta[0].ShippingState = datosCliente.provincia;
                        cuenta[0].ShippingCity = datosCliente.poblacion;
                        cuenta[0].Actividad__c = datosCliente.actividad;
                        cuenta[0].Sub_actividad__c = datosCliente.subactividad;
                        cuenta[0].Calle_Facturacion__c = datosCliente.calleFacturacion;
                        cuenta[0].Poblacion_Facturacion__c = datosCliente.poblacionFacturacion;
                        cuenta[0].Codigo_Postal__c = datosCliente.cpFacturacion;
                        cuenta[0].Provincia__c = datosCliente.provinciaFacturacion;   
                        if(datosContrato.uso != 'Otros') //para que no salte regla de validación
                        {
                            cuenta[0].Uso__c = datosContrato.uso;   
                        }            
                        

                        cuenta[0].setOptions(dml);
                        sr = Database.update(cuenta[0], false);
                        if(!sr.isSuccess())
                        {
                            err = sr.getErrors()[0];
                            r.resultado.codigo = '805';
                            r.resultado.texto += Label.WSError_805 + ' ' + cuenta[0].Id;
                            LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage() + ' ' + err.getFields(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                            error = true;
                        }

                        Map<String, String> mapeoTipoCamion = new Map<String, String>{'' => '', '7' => 'PEQUEÑO', '11' => 'MEDIANO', '19' => 'GRANDE'};
                        //Dirección de entrega
                        dirEntrega = new Direcci_n_de_entrega__c();
                        if(datosCliente.calle.length() <= 50)
                        {
                            dirEntrega.Direccion__c = datosCliente.calle;
                        }
                        else 
                        {
                            dirEntrega.Direccion__c = datosCliente.calle.substring(0, 50);
                            dirEntrega.Direccion_2__c = datosCliente.calle.substring(50, datosCliente.calle.length());
                        }
                        dirEntrega.Codigo_Postal__c = datosCliente.cp;
                        dirEntrega.Poblacion__c = datosCliente.poblacion;
                        dirEntrega.Provincia__c = datosCliente.provincia;
                        dirEntrega.Pais__c = 'ES';
                        dirEntrega.Tipo_de_direccion_de_envio__c = 'BULK';
                        dirEntrega.Actividad_1__c = datosCliente.actividad;
                        dirEntrega.Actividad_2__c = datosCliente.subactividad; 
                        String tipoCamionPeticion = mapeoTipoCamion.get(datosContrato.tipoCamion); //En el Json se envía un numero y en SF tiene que aparecer el nombre
                        dirEntrega.Tipo_de_camion__c = tipoCamionPeticion;                       
                        if(!String.IsEmpty(datosOferta.tarifa_de_gas))
                        {
                            tarifa = [SELECT Id FROM Pricebook2 where Name=: datosOferta.tarifa_de_gas];
                            if(tarifa.size()>0)
                            {
                                dirEntrega.C_digo_tarifa__c = tarifa[0].Id;
                            }
                            else
                            {
                                r.resultado.codigo = '807';
                                r.resultado.texto += Label.WSError_807 + ' ' + datosOferta.tarifa_de_gas;
                                LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                                error = true;
                            }   
                        }
                        dirEntrega.Cuenta__c = cuenta[0].Id;
                        
                        List<Direcci_n_de_entrega__c> direccionesExistentesCliente = [SELECT Id, Direccion__c, Codigo_Postal__c, Poblacion__c, Provincia__c, Pais__c, Actividad_1__c, Actividad_2__c, C_digo_tarifa__c, 
                        Cuenta__c, Tipo_de_camion__c, Tipo_de_direccion_de_envio__c FROM Direcci_n_de_entrega__c WHERE Cuenta__c=: dirEntrega.Cuenta__c];
                        if(direccionesExistentesCliente.size()<=0) //si no tiene ninguna dirección, la creo
                        {

                            sr = Database.insert(dirEntrega, false);
                            if(!sr.isSuccess())
                            {
                                err = sr.getErrors()[0];
                                r.resultado.codigo = '808';
                                r.resultado.texto += Label.WSError_808;
                                LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage() + ' ' + err.getFields(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                                error = true;
                            }
                        }
                        else //si tiene alguna dirección, compruebo si alguna coincide con los datos especificados
                        {
                            Boolean coincideDireccion;
                            for(Direcci_n_de_entrega__c dir: direccionesExistentesCliente)
                            {

                                coincideDireccion = true;
                                if(!String.isEmpty(dir.Direccion__c) && !String.isEmpty(dirEntrega.Direccion__c) && dir.Direccion__c != dirEntrega.Direccion__c)
                                {
                                    coincideDireccion = false;
                                }
                                else
                                {
                                    if(!String.isEmpty(dir.Codigo_Postal__c) && !String.isEmpty(dirEntrega.Codigo_Postal__c) && dir.Codigo_Postal__c != dirEntrega.Codigo_Postal__c)
                                    {
                                        coincideDireccion = false;
                                    }
                                    else
                                    {
                                        if(!String.isEmpty(dir.Poblacion__c) && !String.isEmpty(dirEntrega.Poblacion__c) && dir.Poblacion__c != dirEntrega.Poblacion__c)
                                        {
                                            coincideDireccion = false;
                                        }
                                        else
                                        {
                                            if(!String.isEmpty(dir.Provincia__c) && !String.isEmpty(dirEntrega.Provincia__c) && dir.Provincia__c != dirEntrega.Provincia__c)
                                            {
                                                coincideDireccion = false;
                                            }
                                            else
                                            {
                                                if(!String.isEmpty(dir.Pais__c) && !String.isEmpty(dirEntrega.Pais__c) && dir.Pais__c != 'ES' && dir.Pais__c != 'España')
                                                {
                                                    coincideDireccion = false;
                                                }/*
                                                else
                                                {
                                                    if(!String.isEmpty(dir.Actividad_1__c) && !String.isEmpty(dirEntrega.Actividad_1__c) && dir.Actividad_1__c != dirEntrega.Actividad_1__c)
                                                    {
                                                        coincideDireccion = false;
                                                        System.debug('##No coincide la actividad1');
                                                    }
                                                    else
                                                    {
                                                        if(!String.isEmpty(dir.Actividad_2__c) && !String.isEmpty(dirEntrega.Actividad_2__c) && dir.Actividad_2__c != dirEntrega.Actividad_2__c)
                                                        {
                                                            coincideDireccion = false;
                                                            System.debug('##No coincide la actividad2');
                                                        }
                                                        else
                                                        {
                                                            if(!String.isEmpty(dir.C_digo_tarifa__c) && !String.isEmpty(dirEntrega.C_digo_tarifa__c) && dir.C_digo_tarifa__c != dirEntrega.C_digo_tarifa__c)
                                                            {
                                                                coincideDireccion = false;
                                                                System.debug('##No coincide la tarifa');
                                                            }
                                                            else
                                                            {
                                                                if(!String.isEmpty(dir.Tipo_de_camion__c) && !String.isEmpty(dirEntrega.Tipo_de_camion__c) && dir.Tipo_de_camion__c != dirEntrega.Tipo_de_camion__c)
                                                                {
                                                                    coincideDireccion = false;
                                                                    System.debug('##No coincide el tipo de camión');
                                                                }
                                                            }
                                                        }
                                                    }
                                                }*/
                                            }
                                        }
                                    }
                                }

                                //Si he encontrado una dirección que coincide, miro a ver si tiene algún campo vacío que deba actualizar
                                if(coincideDireccion)
                                {

                                    Boolean actualizarDireccion = false;

                                    if(!String.isEmpty(dirEntrega.Direccion__c))
                                    {
                                        dir.Direccion__c = dirEntrega.Direccion__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.Codigo_Postal__c))
                                    {
                                        dir.Codigo_Postal__c = dirEntrega.Codigo_Postal__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.Poblacion__c))
                                    {
                                        dir.Poblacion__c = dirEntrega.Poblacion__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.Provincia__c))
                                    {
                                        dir.Provincia__c = dirEntrega.Provincia__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.Pais__c))
                                    {
                                        dir.Pais__c = dirEntrega.Pais__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.Actividad_1__c))
                                    {
                                        dir.Actividad_1__c = dirEntrega.Actividad_1__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.Actividad_2__c))
                                    {
                                        dir.Actividad_2__c = dirEntrega.Actividad_2__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.C_digo_tarifa__c))
                                    {
                                        dir.C_digo_tarifa__c = dirEntrega.C_digo_tarifa__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.Tipo_de_camion__c))
                                    {
                                        dir.Tipo_de_camion__c = dirEntrega.Tipo_de_camion__c;
                                        actualizarDireccion = true;
                                    }
                                    if(!String.isEmpty(dirEntrega.Tipo_de_direccion_de_envio__c))
                                    {
                                        dir.Tipo_de_direccion_de_envio__c = dirEntrega.Tipo_de_direccion_de_envio__c;
                                        actualizarDireccion = true;
                                    }


                                    if(actualizarDireccion)
                                    {
                                        sr = Database.update(dir, false);
                                        if(!sr.isSuccess())
                                        {
                                            err = sr.getErrors()[0];
                                            r.resultado.codigo = '809';
                                            r.resultado.texto += Label.WSError_809;
                                            LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage() + ' ' + err.getFields(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                                            error = true;
                                        }
                                    }

                                    dirEntrega = dir;

                                    break; //No recorro el resto de direcciones porque ya he encontrado la que coindice
                                }
                            }
                            if(!coincideDireccion) //si no se ha encontrado una dirección que coincide, se crea
                            {                               

                                sr = Database.insert(dirEntrega, false);
                                if(!sr.isSuccess())
                                {
                                    err = sr.getErrors()[0];
                                    r.resultado.codigo = '808';
                                    r.resultado.texto += Label.WSError_808;
                                    LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage() + ' ' + err.getFields(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                                    error = true;
                                }
                            }
                        }
                    }                    
                    else
                    {
                        idClienteIncorrecto = true;
                        r.resultado.codigo = '806';
                        r.resultado.texto += Label.WSError_806 + ' ';
                        r.resultado.texto += datosCliente != null ? datosCliente.identificador : 'datosCliente no existe.';
                        LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage() + ' ' + err.getFields(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                        error = true;
                    }                
                }
                else
                {
                    idClienteIncorrecto = true;
                    r.resultado.codigo = '810';
                    r.resultado.texto += Label.WSError_810 + ' ' + datosCliente.identificador;
                    LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage() + ' ' + err.getFields(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                    error = true;
                }   

                if(datosContrato.idOfertaSF != null && datosContrato.idOfertaSF != '' && !idClienteIncorrecto && !error)
                {
                    Contract contrato = new Contract();                    

                    //Tipo de registro GLP, estado borrador
                    contrato.RecordTypeId = Util.objectsRecordTypesMap.get('Contract').get('GLP').Id;   
                    contrato.Status = 'Borrador';       

                    //Se recupera presupuesto y oferta asociada
                    presupuesto = [SELECT Id, ContractId, OpportunityId, Coste_equipo_interior__c, Coste_instalacion_interior__c, Coste_instalacion_exterior__c, Coste_obra_civil__c, Coste_proyectos__c, Resolucion_anticipada__c, RecordTypeId, 
                                    (SELECT Id, Equipos_exterior__c, Instalacion_exterior__c, Obra_civil_vallado__c, Proyectos__c FROM Depositos__r), 
                                    (SELECT Id, Equipos_interior__c, Instalacion_interior__c FROM Equipos_Ajuste__r), 
                                    (SELECT Id, Consumo__c, Tipo_energia__c, Proveedor__c, Proveedor__r.Name FROM Energias_Actuales__r) 
                                    FROM Quote WHERE Id=: datosContrato.idOfertaSF];
                    if(presupuesto != null && presupuesto.size() > 0)
                    {
                    	oportunidad = [SELECT Id, AccountId, ContractId, LeadSource, (SELECT Id, AccountToId from partners) FROM Opportunity WHERE Id=: presupuesto[0].OpportunityId];
                    }

                    //Si el campo directorio_pdf viene vacío significa que es un contrato borrador
                    if(String.isBlank(datosContrato.directorio_pdf))
                    {
                        borrador = true;
                    }
                                                    
                    //Firma del contrato 
                    if(!borrador)    
                    {                             
                        contrato.CustomerSignedId = contacto[0].Id;
                    }                              
                    
                    //datosCliente
                    if(!String.isEmpty(datosCliente.telefono))
                    {
                        contrato.N_telefono__c = datosCliente.telefono;
                    }
                    else
                    {
                        contrato.N_telefono__c = datosCliente.telefonoMovil;
                    }
                    contrato.N_fax__c           = datosCliente.fax;
                    contrato.E_mail__c          = datosCliente.email;
                    contrato.CIF__c             = datosCliente.cif;
                    contrato.BillingStreet      = datosCliente.calleFacturacion;
                    contrato.BillingCity        = datosCliente.poblacionFacturacion;
                    contrato.BillingPostalCode  = datosCliente.cpFacturacion;
                    contrato.BillingState       = datosCliente.provinciaFacturacion;
                    contrato.Segmento_1__c      = datosCliente.actividad;
                    contrato.Segmento_2__c      = datosCliente.subactividad;
                    contrato.IBAN__c            = datosContrato.iban;
                    if(dirEntrega != null && !String.isEmpty(dirEntrega.Id))
                    {
                        contrato.Direccion_de_entrega__c = dirEntrega.Id;
                    }
                    else
                    {
                        r.resultado.codigo = '811';
                        r.resultado.texto = Label.WSError_811 + ' ' + dirEntrega.Id;
                        LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                        error = true;
                    }
                    

                    //datosOferta
                    contrato.Cod_dia_de_pago__c = datosOferta.plazo_de_cuota;
                    if(!String.isEmpty(datosOferta.capacidad_litros))
                    {
                        contrato.Capacidad_tanque__c = Integer.valueOf(datosOferta.capacidad_litros);
                    }
                    if(tarifa != null && tarifa.size()>0) //Se controla si no existe al crear la dirección de entrega
                    {
                        contrato.Tarifa__c = tarifa[0].Id;
                    }                                            
                    if(!String.isEmpty(datosOferta.consumo_contratado))
                    {
                        contrato.Consumo_previsto_tons__c = Integer.valueOf(Double.valueOf(datosOferta.consumo_contratado));
                    }
                    if(!String.isEmpty(datosOferta.primaservicios))
                    {
                        //contrato.Importe_servicios__c = Double.valueOf(datosOferta.primaservicios)*12;

                        //Es necesario ordenar los tramos que se envía desde la aplicación para quedarnos con el mayor ya que ahora el mayor no es el que se envía en el campo
                        //primaservicios del JSON
                        List<Double> tramosOrdenadosMayorMenor = new List<Double>();
                        if(!String.isEmpty(datosOferta.tramo1_primaservicios))
                        {
                            tramosOrdenadosMayorMenor.add(Double.valueOf(datosOferta.tramo1_primaservicios));
                        }
                        if(!String.isEmpty(datosOferta.tramo2_primaservicios))
                        {
                            tramosOrdenadosMayorMenor.add(Double.valueOf(datosOferta.tramo2_primaservicios));
                        } if(!String.isEmpty(datosOferta.tramo3_primaservicios))
                        {
                            tramosOrdenadosMayorMenor.add(Double.valueOf(datosOferta.tramo3_primaservicios));
                        } if(!String.isEmpty(datosOferta.tramo4_primaservicios))
                        {
                            tramosOrdenadosMayorMenor.add(Double.valueOf(datosOferta.tramo4_primaservicios));
                        }

                        for(Integer i = 0 ; i < tramosOrdenadosMayorMenor.size() ; i ++) 
                        {
                            for(integer j = i+1 ; j <= tramosOrdenadosMayorMenor.size() -1 ; j ++ )
                            {
                                Double x = 0.0 ;
                                if(tramosOrdenadosMayorMenor[i] <  tramosOrdenadosMayorMenor[j])
                                {
                                   x = tramosOrdenadosMayorMenor[i]  ;
                                   tramosOrdenadosMayorMenor[i] = tramosOrdenadosMayorMenor[j]  ;
                                   tramosOrdenadosMayorMenor[j]  = x;
                                }
                            }
                        }

                        if(tramosOrdenadosMayorMenor.size() > 0)
                        {
                            contrato.Importe_servicios__c = Double.valueOf(tramosOrdenadosMayorMenor[0])*12;                   

                            if(contrato.Importe_servicios__c != null && contrato.Importe_servicios__c != 0)
                            {
                                if(!String.isEmpty(datosOferta.tramo1_primaservicios))
                                {
                                    contrato.dto_a_o_1__c = (( contrato.Importe_servicios__c - (Double.valueOf(datosOferta.tramo1_primaservicios)*12) ) / contrato.Importe_servicios__c)*100; 
                                    //System.debug('##Tramo1|| Total: '+contrato.dto_a_o_1__c );   
                                }
                                if(!String.isEmpty(datosOferta.tramo2_primaservicios))
                                {
                                    contrato.dto_a_o_2__c = (( contrato.Importe_servicios__c -(Double.valueOf(datosOferta.tramo2_primaservicios)*12) ) / contrato.Importe_servicios__c)*100;
                                    //System.debug('##Tramo2|| Total: '+contrato.dto_a_o_2__c );
                                }
                                if(!String.isEmpty(datosOferta.tramo3_primaservicios))
                                {
                                    contrato.dto_a_o_3__c = (( contrato.Importe_servicios__c - (Double.valueOf(datosOferta.tramo3_primaservicios)*12) ) / contrato.Importe_servicios__c)*100;
                                    //System.debug('##Tramo3|| Total: '+contrato.dto_a_o_3__c );
                                }
                                if(!String.isEmpty(datosOferta.tramo4_primaservicios))
                                {
                                    contrato.dto_a_o_4__c = (( contrato.Importe_servicios__c - (Double.valueOf(datosOferta.tramo4_primaservicios)*12) ) / contrato.Importe_servicios__c)*100;
                                } 
                            }
                        }
                    }
                    if(datosOferta.aereo == '1')
                    {
                        contrato.Tipo_de_tanque__c = 'Aereo';
                    }
                    else if(datosOferta.enterrado == '1')
                    {
                        contrato.Tipo_de_tanque__c = 'Enterrado';
                    }

                    Integer contadorDeTramos = 0;

                    if(!String.isEmpty(datosOferta.tramo1_consumo))
                    {
                        contadorDeTramos++;
                        contrato.dp_cad_min1__c = Double.valueOf(datosOferta.tramo1_consumo);
                    }
                    if(!String.isEmpty(datosOferta.tramo2_consumo))
                    {
                        contadorDeTramos++;
                        contrato.dp_cad_min2__c = Double.valueOf(datosOferta.tramo2_consumo);
                    }
                    if(!String.isEmpty(datosOferta.tramo3_consumo))
                    {
                        contadorDeTramos++;
                        contrato.dp_cad_min3__c = Double.valueOf(datosOferta.tramo3_consumo);
                    }
                    if(!String.isEmpty(datosOferta.tramo4_consumo))
                    {
                        contadorDeTramos++;
                        contrato.dp_cad_min4__c = Double.valueOf(datosOferta.tramo4_consumo);
                    }
                    if(!String.isEmpty(datosOferta.tramo5_consumo))
                    {
                        contadorDeTramos++;
                        contrato.dp_cad_min5__c = Double.valueOf(datosOferta.tramo5_consumo);
                    }

                    if(!String.isEmpty(datosOferta.tramo1_consumo))
                    {
                        contrato.dcm_propano1__c = Double.valueOf(datosOferta.tramo1_consumo);
                    }
                    if(!String.isEmpty(datosOferta.tramo2_consumo))
                    {
                        contrato.dcm_propano2__c = Double.valueOf(datosOferta.tramo2_consumo);
                    }
                    if(!String.isEmpty(datosOferta.tramo3_consumo))
                    {
                        contrato.dcm_propano3__c = Double.valueOf(datosOferta.tramo3_consumo);
                    }
                    if(!String.isEmpty(datosOferta.tramo4_consumo))
                    {
                        contrato.dcm_propano4__c = Double.valueOf(datosOferta.tramo4_consumo);
                    }

                    //Cambios rfernandez (16/02/2017)
                    if(contadorDeTramos > 0)
                    {
                        contrato.Tipo_de_descuento__c = 'Por volumen';
                    }else{
                        contrato.Tipo_de_descuento__c = 'Fijo';
                    }
                    //Fin cambios rfernandez

                    if(!String.isEmpty(datosOferta.tramo1_dto))
                    {
                        contrato.dto_Kg_1__c = -1*Double.valueOf(datosOferta.tramo1_dto);
                        /*if(presupuesto[0].RecordTypeId==Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id)
                        {
                            
                        }else{
                            contrato.dto_Kg_1__c = Double.valueOf(datosOferta.tramo1_dto);
                        }*/
                    }
                    if(!String.isEmpty(datosOferta.tramo2_dto))
                    {
                        contrato.dto_Kg_2__c = -1*Double.valueOf(datosOferta.tramo2_dto);
                    }
                    if(!String.isEmpty(datosOferta.tramo3_dto))
                    {
                       contrato.dto_Kg_3__c = -1*Double.valueOf(datosOferta.tramo3_dto);
                    }
                    if(!String.isEmpty(datosOferta.tramo4_dto))
                    {
                        contrato.dto_Kg_4__c = -1*Double.valueOf(datosOferta.tramo4_dto);
                    }
                    if(!String.isEmpty(datosOferta.tramo5_dto))
                    {
                        contrato.dto_Kg_5__c = -1*Double.valueOf(datosOferta.tramo5_dto);
                    }
                   
                    //Sección "Inversión en instalación" y campo Origen tipo de cliente
                    if(presupuesto!=null && presupuesto.size()>0 && presupuesto[0]!=null)
                    {
                        //gserrano 25/04/2019
                        //se pregunta si la oferta es estandar, en ese caso los campos se 
                        //mapean desde la tabla maestra de opcionesOfertaSTD correspondiente
                        //en caso contrario se queda como estaba
                        //hay que intentar también mapear la resolucion anticipada con la tabla, 
                        //aunque no esté dando problemas
                        //hay que intentar tambien ven si hay corrspondencia de mapea ccon la 
                        //tabla para el campo dep_sito__c
                        if(presupuesto[0].RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id)
                        {
                            //No está muy claro que hacer con este campo
                            //contrato.Importe_dep_sito__c = 
                            
                            contrato.Importe_instalaci_n_exterior__c = presupuesto[0].Coste_instalacion_exterior__c;
                            contrato.Importe_obra_Civil__c = presupuesto[0].Coste_obra_civil__c;
                            contrato.Importe_proyectos__c = presupuesto[0].Coste_proyectos__c;
                            contrato.Importe_instalaci_n_interior__c = presupuesto[0].Coste_instalacion_interior__c;
                            contrato.Importe_equipos__c = presupuesto[0].Coste_equipo_interior__c;
                            contrato.Coste_resolucion_anticipada__c = presupuesto[0].Resolucion_anticipada__c;
                        }
                        
                        //Sección Inversión
                        else 
                        {
                            if(presupuesto[0].Depositos__r.size()>0)
                            {
                                contrato.Importe_dep_sito__c = 0;
                                contrato.Importe_instalaci_n_exterior__c = 0;
                                contrato.Importe_obra_Civil__c = 0;
                                contrato.Importe_proyectos__c = 0;
                                for(Deposito__c d : presupuesto[0].Depositos__r)
                                {
                                    contrato.Importe_dep_sito__c += d.Equipos_exterior__c;
                                    contrato.Importe_instalaci_n_exterior__c += d.Instalacion_exterior__c;
                                    contrato.Importe_obra_Civil__c += d.Obra_civil_vallado__c;
                                    contrato.Importe_proyectos__c += d.Proyectos__c;
                                }     
                            }

                            if(presupuesto[0].RecordTypeId== Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id)
                            {
                                contrato.Importe_instalaci_n_interior__c = presupuesto[0].Coste_instalacion_interior__c;
                                contrato.Importe_equipos__c = presupuesto[0].Coste_equipo_interior__c;
                            }   
                            else if(presupuesto[0].RecordTypeId == Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id)
                            {
                                if(presupuesto[0].Equipos_ajuste__r.size()>0)
                                {
                                    contrato.Importe_instalaci_n_interior__c = 0;
                                    contrato.Importe_equipos__c = 0;
                                    for(Equipo_Ajuste__c ea : presupuesto[0].Equipos_ajuste__r)
                                    {
                                        contrato.Importe_instalaci_n_interior__c += ea.Instalacion_interior__c;
                                        contrato.Importe_equipos__c += ea.Equipos_interior__c;
                                    }
                                }
                            }
                        }

                        //Origen tipo de cliente
                        System.debug('***'+presupuesto[0].Energias_Actuales__r.size()); 
                        System.debug('***'+presupuesto[0].Energias_Actuales__r); 
                        
                        if(presupuesto[0].Energias_Actuales__r.size()>0)
                        {
                            Decimal consumoMayor = 0;
                            Energia_Actual__c energiaPrincipal = null;
                            for(Energia_Actual__c e : presupuesto[0].Energias_Actuales__r)
                            {
                                System.debug('***'+e.consumo__c);                               
                                System.debug('***'+consumomayor);
                                if(e.Consumo__c != null && e.Consumo__c > consumoMayor)
                                {
                                    consumoMayor = e.Consumo__c;
                                    energiaPrincipal = e;
                                    System.debug('***'+energiaPrincipal.Id);
                                    System.debug('***'+energiaPrincipal.tipo_energia__c);
                                }
                            }
                            //Modificado por gserrano 10/12/2018
                            Map<String, String> mapTiposEnergiaConOrigen = new Map<String,String>
                            {
                                'Gasóleo' => 'Cambio Energía Gasóleo',
                                'Propano Granel Repsol' => 'Cambio Depósito REPSOL',
                                'Propano Granel Cepsa' => 'Cambio Depósito CEPSA',
                                'Propano Granel Vitogas' => 'Cambio Depósito VITOGAS',
                                'Propano Botellas' => 'Cambio Botellas',
                                'Butano' => 'Cambio Botellas',
                                'Fuel' => 'Cambio Energía Fuel'         
                            };
                             
                            System.debug('***'+energiaPrincipal.tipo_energia__c);    
                            if(energiaPrincipal != null && String.isNotBlank(energiaPrincipal.Tipo_energia__c)) 
                            {     
                                System.debug('***1');    
                                if(mapTiposEnergiaConOrigen.containsKey(energiaPrincipal.Tipo_energia__c))
                                {
                                    System.debug('***2');    
                                    contrato.Origen_tipo_de_cliente__c = mapTiposEnergiaConOrigen.get(energiaPrincipal.Tipo_energia__c);
                                }
                                else if(energiaPrincipal.Tipo_energia__c == 'Propano Granel') 
                                {
                                    System.debug('***3');    
                                    if(String.isNotBlank(energiaPrincipal.Proveedor__c))
                                    {
                                        System.debug('***4');    
                                        if(mapTiposEnergiaConOrigen.containsKey(energiaPrincipal.Tipo_energia__c + ' ' + energiaPrincipal.Proveedor__r.Name))
                                        {
                                            System.debug('***5');    
                                            contrato.Origen_tipo_de_cliente__c = mapTiposEnergiaConOrigen.get(energiaPrincipal.Tipo_energia__c + ' ' + energiaPrincipal.Proveedor__r.Name);
                                        }
                                        else
                                        {
                                            System.debug('**6');    
                                            contrato.Origen_tipo_de_cliente__c = 'Cambio Depósito OTRO';
                                        }
                                    }
                                    else
                                    {
                                        System.debug('***7');    
                                        contrato.Origen_tipo_de_cliente__c = 'Nueva Creación';
                                    }                                       
                                }
                                else
                                {
                                    System.debug('***8');    
                                    contrato.Origen_tipo_de_cliente__c = 'Cambio Energía Electricidad';
                                }
                                
                            } 
                            System.debug('***9');
                            System.debug('***10' + contrato.Origen_tipo_de_cliente__c);
                            //Modificado por gserrano 10/12/2018 Hasta aquí
                        
                        }              
                    }

                    if(datosOferta.contadorservicio == '1' && datosOferta.suministro_de_gas_automatico == '1')
                    {
                        contrato.Primaconta__c = true;
                    }   
                    else
                    {
                        contrato.Primaconta__c = false;
                    }
                    if(datosOferta.suministro_de_gas_automatico == '1')
                    {
                        contrato.Entrega_de_producto__c = 'Automática';
                    }
                    else
                    {
                        contrato.Entrega_de_producto__c = 'Bajo pedido';
                    } 
                    if(String.isNotBlank(datosOferta.duracion_del_contrato))
                    {
                        contrato.Duraci_n_del_contrato_a_os__c = String.valueOf(Integer.valueOf(datosOferta.duracion_del_contrato)); 
                        if(String.isNotBlank(datosOferta.consumo_contratado))
                        { 
                            contrato.Duracion_contrato_en_toneladas__c = Integer.valueOf(datosOferta.duracion_del_contrato) * Double.valueOf(datosOferta.consumo_contratado)/1000;  
                        }   
                    }      


                    //datos restantes para Navision
                    List<Product2> producto = [SELECT Id FROM Product2 WHERE Name=:'GLP1'];
                    if(producto.size()>0)
                    {
                        contrato.Producto_contratado__c = producto[0].Id;
                    }


                    //datosContrato
                    contrato.Numero_de_contrato_app__c = datosContrato.numContrato;                    
                    contrato.AccountId = cuenta[0].Id;         
                    contrato.Plazo_de_pagos__c = datosContrato.plazoPago;  
                    if(!String.isEmpty(datosContrato.numTramoDto))
                    {   
                        //Cambios rfernandez (06/03/2017)            
                        //contrato.Tramo_con_descuento__c = Integer.valueOf(datosContrato.numTramoDto);
                        contrato.Tramo_con_descuento__c = datosContrato.numTramoDto;
                        //Fin cambios rfernandez
                    }                  
                    if(datosContrato.pagoFraccionado == '1')
                    {
                        contrato.Pago_fraccionado__c = true;
                    }
                    else
                    {
                        contrato.Pago_fraccionado__c = false;
                    }                   
                    if(!String.isEmpty(datosContrato.compraventaMinima))
                    {
                        contrato.Compraventa_minima_en_kg__c = Integer.valueOf(datosContrato.compraventaMinima);
                    }
                    contrato.Observaciones_equipos__c = datosContrato.observacionesEquipos;
                    //Cambios rfernandez (16/02/2017)
                    if(!String.isEmpty(datosContrato.observacionesGenerales))
                    {
                        contrato.Observaciones_generales__c = datosContrato.observacionesGenerales;
                    }
                    
                    //Fin cambios rfernandez
                    contrato.Tipo_camion__c = datosContrato.tipoCamion;

                    if(!String.isEmpty(datosContrato.coordenadasGPS) && datosContrato.coordenadasGPS != ',')
                    {
                        String[] coordenadas = datosContrato.coordenadasGPS.split(',');
                        if( !String.isEmpty(coordenadas[0])  && !String.isEmpty(coordenadas[1]))
                        {
                            contrato.Coordenadas_GPS__Latitude__s = Double.valueof(coordenadas[0]);
                            contrato.Coordenadas_GPS__Longitude__s  = Double.valueof(coordenadas[1]);
                        }
                        
                    }
                    contrato.Cod_terminos_de_pago__c = datosContrato.terminos_pago;
                    contrato.Cod_terminos_pago_servicios__c = datosContrato.terminos_pago;
                    contrato.Cod_forma_de_pago__c = datosContrato.forma_pago;
                    contrato.Cod_forma_pago_servicios__c = datosContrato.forma_pago;

                    String dia;
                    String mes;
                    String anyo;
                    if(datosContrato.fecha_prevista_obra_civil.length()==8)
                    {
                        anyo = datosContrato.fecha_prevista_obra_civil.substring(0,4);
                        mes = datosContrato.fecha_prevista_obra_civil.substring(4,6);
                        dia = datosContrato.fecha_prevista_obra_civil.substring(6,8);                  
                        Date fecha_prevista_obra_civil =Date.newInstance(Integer.valueOf(anyo), Integer.valueOf(mes), Integer.valueOf(dia));
                        contrato.Fecha_prevista_obra_civil__c = fecha_prevista_obra_civil;
                    }

                    if(datosContrato.fecha_firma_cliente.length()==8 && !borrador)
                    {
                        anyo = datosContrato.fecha_firma_cliente.substring(0,4);
                        mes = datosContrato.fecha_firma_cliente.substring(4,6);
                        dia = datosContrato.fecha_firma_cliente.substring(6,8);                
                        Date fecha_firma_cliente =Date.newInstance(Integer.valueOf(anyo), Integer.valueOf(mes), Integer.valueOf(dia));
                        contrato.CustomerSignedDate = fecha_firma_cliente;
                        contrato.StartDate = fecha_firma_cliente;
                    }

                    if(datosContrato.fecha_prevista_1er_llenado.length()==8)
                    {
                        anyo = datosContrato.fecha_prevista_1er_llenado.substring(0,4);
                        mes = datosContrato.fecha_prevista_1er_llenado.substring(4,6);
                        dia = datosContrato.fecha_prevista_1er_llenado.substring(6,8);     
                        Date fecha_prevista_1er_llenado =Date.newInstance(Integer.valueOf(anyo), Integer.valueOf(mes), Integer.valueOf(dia));
                        contrato.Fecha_prevista_1er_llenado__c = fecha_prevista_1er_llenado;
                    }
                    //gserrano 25/04/2019 añadida comporbacion de oferta estandar
                    if(!String.isEmpty(datosContrato.coste_resolucion_anticipada_toneladas) && presupuesto[0].RecordTypeId != Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id)
                    {
                        contrato.Coste_resolucion_anticipada__c = Double.valueOf(datosContrato.coste_resolucion_anticipada_toneladas);
                    }
                    if(!String.isEmpty(datosContrato.instalador))
                    {
                        contrato.Instalador__c = datosContrato.instalador;
                    }
                    contrato.Uso__c = datosContrato.uso;
                    contrato.Perfil_de_consumo__c = datosContrato.ritmoConsumo;
                    contrato.Derechos_de_titular__c = datosContrato.titularDerechos;                   
                    if(datosContrato.toma_agua_15_m=='1')
                    {
                        contrato.Toma_agua_15_m__c = true;
                    }
                    else
                    {
                        contrato.Toma_agua_15_m__c = false;
                    }   
                    if(!String.isEmpty(datosContrato.proyectista))
                    {
                        contrato.Proyectista__c = datosContrato.proyectista;
                    }
                    contrato.Ubicacion_deposito__c = datosContrato.descripcionUbicacionDeposito;
                    contrato.Equipos_instalacion__c = datosContrato.equiposInstalacion;

                    //Tratamiento de la información recibida en responsabilidad_cliente
                    String responsabilidad_cliente = datosContrato.responsabilidad_cliente;      
                    List<String> responsabilidad_cliente_lista = responsabilidad_cliente.split(';');
                    System.debug('responsabilidad_cliente_lista: ' + responsabilidad_cliente_lista); 
                    for(String responsabilidad: responsabilidad_cliente_lista)
                    {
                        if(responsabilidad==RESP_PROYECTO_EXTERIOR)
                        {
                            contrato.Proyecto_exterior_memoria__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_OBRA_CIVIL_DEPOSITO) 
                        {
                            contrato.Obra_civil_deposito__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_OBRA_CIVIL_TUBERIA) 
                        {
                            contrato.Obra_civil_tuberia__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_ENTREGA) 
                        {
                            contrato.Entrega_y_colocacion_deposito__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_VALLADO) 
                        {
                            contrato.Vallado__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_INSTALACION_INTERIOR) 
                        {
                            contrato.Instalacion_y_certificado_interior__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_INSTALACION_EXTERIOR) 
                        {
                            contrato.Instalacion_exterior__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_PRESENTACION_AYUNTAMIENTO)
                        {
                            contrato.Presentacion_en_ayuntamiento__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_PROYECTO_INTERIOR) 
                        {
                            contrato.Proyecto_interior__c = 'CLIENTE';
                        }
                        else if(responsabilidad==RESP_OTROS)
                        {
                            contrato.Otros_cliente__c = datosContrato.otros;
                        }
                    }          
                    
                    //Tratamiento de la información recibida en responsabilidad_primagas
                    String responsabilidad_primagas = datosContrato.responsabilidad_primagas;
                    List<String> responsabilidad_primagas_lista = responsabilidad_primagas.split(';');
                    System.debug('responsabilidad_primagas_lista: ' + responsabilidad_primagas_lista); 
                    for(String responsabilidad: responsabilidad_primagas_lista)
                    {
                        if(responsabilidad==RESP_PROYECTO_EXTERIOR)
                        {
                            contrato.Proyecto_exterior_memoria__c = 'PRIMAGAS';
                        }                    
                        else if(responsabilidad==RESP_OBRA_CIVIL_DEPOSITO)
                        {
                            contrato.Obra_civil_deposito__c = 'PRIMAGAS';
                        }                    
                        else if(responsabilidad==RESP_OBRA_CIVIL_TUBERIA)
                        {
                            contrato.Obra_civil_tuberia__c = 'PRIMAGAS';
                        }                    
                        else if(responsabilidad==RESP_ENTREGA)
                        {
                            contrato.Entrega_y_colocacion_deposito__c = 'PRIMAGAS';
                        }
                        else if(responsabilidad==RESP_VALLADO)
                        {
                            contrato.Vallado__c = 'PRIMAGAS';
                        }                    
                        else if(responsabilidad==RESP_INSTALACION_INTERIOR)
                        {
                            contrato.Instalacion_y_certificado_interior__c = 'PRIMAGAS';
                        }                    
                        else if(responsabilidad==RESP_INSTALACION_EXTERIOR)
                        {
                            contrato.Instalacion_exterior__c = 'PRIMAGAS';
                        }                    
                        else if(responsabilidad==RESP_PRESENTACION_AYUNTAMIENTO)
                        {
                            contrato.Presentacion_en_ayuntamiento__c = 'PRIMAGAS';
                        }                    
                        else if(responsabilidad==RESP_PROYECTO_INTERIOR)
                        {
                            contrato.Proyecto_interior__c = 'PRIMAGAS';
                        }
                        else if(responsabilidad==RESP_OTROS)
                        {
                            contrato.Otros_primagas__c = datosContrato.otros;
                        }
                    }

                    if(String.isNotBlank(datosContrato.directorio_pdf))
                    {
                        contrato.Directorio_pdf__c = datosContrato.directorio_pdf;
                    }
                    
                    if(datosContrato.coberturaMovil=='1')
                    {
                        contrato.Cobertura_movil__c = true;
                    }
                    else
                    {
                        contrato.Cobertura_movil__c = false;
                    }

                    system.debug('***' + oportunidad);
                    
                    if(oportunidad != null && oportunidad.size() > 0)
                    {
                        //Para que el contrato aparezca en la lista relacionada de la oportunidad
                        contrato.Oportunidad__c = oportunidad[0].Id;
                        
                        // Añadido por gserrano 10/12/2018
                        system.debug('***' + oportunidad[0].Id);
                        system.debug('***' + oportunidad[0].LeadSource);
                        system.debug('***' + oportunidad[0].partners.size());
                        if((oportunidad[0].LeadSource == 'Prescriptor' || oportunidad[0].LeadSource == 'Instalador') && oportunidad[0].partners.size() > 0 )
                        {
                            system.debug('*** cambio prescritor');
                            contrato.prescriptor__c =  [SELECT Prescriptor__c from account where Id =: oportunidad[0].partners[0].AccountToId][0].Prescriptor__c;
                        }
                        system.debug('***' + contrato.prescriptor__c);
                        // Añadido por gserrano 10/12/2018 HASTA AQUÍ
    
                        contrato.Origen__c = oportunidad[0].LeadSource;

                    }

                    //Cambios rfernandez (18/04/2017) Nuevo campo para guardar el email del destinatario cuando el contrato es borrador
                    if(String.isNotBlank(datosContrato.emailDestinatarioBorrador))
                    {
                        contrato.emailDestinatarioBorrador__c = datosContrato.emailDestinatarioBorrador;
                    }
                    //Fin cambios rfernandez
                    //Inserto el contrato
                    sr = Database.insert(contrato, false);
                    if(!sr.isSuccess())
                    {
                        err = sr.getErrors()[0];
                        r.resultado.codigo = '812';
                        r.resultado.texto += Label.WSError_812;
                        LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage() + ' ' + err.getFields(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                        error = true;
                    }
                    else
                    {

                        if(borrador && String.isNotBlank(datosOferta.pdfBase64))
                        {                       
                            Blob pdfBorrador = EncodingUtil.base64Decode(datosOferta.pdfBase64);
                            /*//Añado el pdf del contrato borrador como adjunto
                            Attachment attach = new Attachment();
                            attach.Name = 'Borrador ' + datosContrato.numContrato + '.pdf';
                            attach.ParentId = contrato.Id;
                            attach.Body = pdfBorrador;

                            sr = Database.insert(attach, false);
                            if(!sr.isSuccess())
                            {
                                err = sr.getErrors()[0];
                                r.resultado.codigo = '801';
                                r.resultado.texto += 'Error al insertar el pdf del borrador del contrato como adjunto --> ' + err.getMessage() + ' ' + err.getFields();
                                System.debug('##Error: ' + r.resultado.texto);
                                error = true;
                            }*/

                            //Se envía un email al cliente con copia al comercial con el pdf del contrato borrador
                            String correoCliente;
                            //Cambios rfernandez (18/04/2017)
                            if(String.isNotBlank(datosContrato.emailDestinatarioBorrador))//Va a ser contrato borrador por lo que se manda a esta direccion
                            {
                                correoCliente = datosContrato.emailDestinatarioBorrador;
                                System.debug('##CorreoCliente: '+correoCliente);
                            }
                            else
                            {
                                correoCliente = cuenta[0].E_mail__c;
                                System.debug('##CorreoCliente: '+correoCliente);
                            }
                            //Fin cambios rfernandez                            
                            if(String.isNotBlank(correoCliente))
                            {
                                String usuarioId = UserInfo.getUserId();
                                List<User> usuario = [SELECT Id, Name, MobilePhone FROM User WHERE Id=: usuarioId];

                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName('Borrador ' + datosContrato.numContrato + '.pdf');
                                efa.setBody(pdfBorrador);

                                String[] toAddresses = new List<String>{correoCliente};
                                System.debug('##Se envía el contrato borrador a ' + toAddresses);
                                String[] bccAddresses = new List<String>{UserInfo.getUserEmail()};
                                String subject = 'Su contrato borrador de Primagas Energía';
                                String body = 'En primer lugar, muchas gracias por su atención.\n' + 
                                'Le adjunto su contrato borrador, por favor recuerde que es necesario que nos lo reenvíe firmado lo antes posible.\n' + 
                                'No dude en contactarme para cualquier cuestión.\n' + 
                                'Quedo a la espera de su respuesta, reciba un saludo cordial,\n\n' + 
                                UserInfo.getName() + '\n' + 
                                'Delegado de Zona \n' + 
                                (String.isEmpty(usuario[0].MobilePhone) ? '' : 'Telf: (+34) ' + usuario[0].MobilePhone + '\n') +  
                                'Email: ' + UserInfo.getUserEmail();

                                email.setToAddresses(toAddresses);
                                email.setBccAddresses(bccAddresses);
                                email.setReplyTo(UserInfo.getUserEmail());
                                email.setSenderDisplayName(UserInfo.getName());
                                email.setSubject(subject);                        
                                email.setPlainTextBody(body);
                                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

                                Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                                System.debug('##SendEmailResult: ' + result);
                            }                           
                        }else
                        {
                            System.debug('Borrador: '+borrador);
                        }

                        //Asocio el contrato al presupuesto correspondiente
                        presupuesto[0].ContractId = contrato.Id; 
                        sr = Database.update(presupuesto[0], false);
                        if(!sr.isSuccess())
                        {
                            err = sr.getErrors()[0];
                            r.resultado.codigo = '813';
							r.resultado.texto += Label.WSError_813;
                        	LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                            error = true;
                        }

                        //Asocio el contrato a la oportunidad
                        oportunidad[0].ContractId = contrato.Id;
                        //Sincronizo el presupuesto en la oportunidad
                        oportunidad[0].SyncedQuoteId = presupuesto[0].Id;
                        sr = Database.update(oportunidad[0], false);
                        if(!sr.isSuccess())
                        {
                            err = sr.getErrors()[0];
                            r.resultado.codigo = '814';
                            r.resultado.texto += Label.WSError_814;
                        	LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                            error = true;
                        }                       

                        if(String.isEmpty(r.resultado.texto))
                        {
                            if(!borrador)
                            {
                                //Envío el contrato a aprobación (solo si no ha habido errores)
                                Approval.ProcessSubmitRequest apReq = new Approval.ProcessSubmitRequest();
                                apReq.setObjectId(contrato.Id);
                                Approval.ProcessResult result = Approval.process(apReq);
                                if(!result.isSuccess())
                                {
                                    err = result.getErrors()[0];
                                    r.resultado.codigo = '815';
                                    r.resultado.texto += Label.WSError_815;
                        			LogUtil.crearLog(r.resultado.texto + '. Error: ' + err.getMessage(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                                    error = true;
                                }
                                else
                                {
                                    r.resultado.codigo = '800';
                                    r.resultado.texto += Label.WSError_800;
                                } 
                            } 
                            else
                            {
                                r.resultado.codigo = '800';
                                r.resultado.texto += Label.WSError_800;
                            }                                  
                        }                     
                    }

                    if(borrador)
                    {
                        esBorrador = 'Es Borrador';
                    }else
                    {
                        esBorrador = 'No es Borrador';
                    }
                }
                else
                {
                    if(!error)
                    {
                        r.resultado.codigo = '816';
                        if(!idClienteIncorrecto)
                        {
                             r.resultado.texto = Label.WSError_816;
               				 LogUtil.crearLog(r.resultado.texto + ' ' + datosContrato.idOfertaSF, 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                        }
                        error = true; 
                    }
                }

            }
            else
            {
                r.resultado.codigo = '801';
                r.resultado.texto = Label.WSError_801;
                LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSDatosContrato', 'Error', true);
                error = true;
            }
        }
        catch(Exception e)
        {
            r.resultado.codigo = '802';
            r.resultado.texto = Label.WSError_802;
			LogUtil.crearLog(r.resultado.texto + ' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);            error = true;
        }

        //Si salta alguna excepción, se hace rollback para que quede como antes
        if(error)
        {
            Database.rollback(sp);
        }

        try
        {
            r.resultado.texto += ' Tipo de contrato: ' + esBorrador + ' Fecha de ejecución:'+String.valueOf(System.now());
            jRespuesta = (String)JSON.serialize(r);
            System.debug('##Respuesta para la app'+r);

        }
        catch(Exception e)
        {
			LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSDatosContrato', 'Error', true);
        }

        if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
        {
        	LogUtil.guardarLog();
        }

        return jRespuesta;
    }

    global class PeticionDatosContrato
    {
        public DatosContrato datosContrato {get;set;}
        public EntidadesWSClientesYOfertas.DatosCliente datosCliente {get;set;}
        public DatosOferta datosOferta {get;set;}
    }

    public class DatosContrato
    {
        public String idOfertaSF {get;set;}
        public String numContrato {get;set;}
        public String plazoPago {get;set;}
        public String numTramoDto {get;set;}
        public String pagoFraccionado {get;set;}
        public String compraventaMinima {get;set;}
        public String observacionesEquipos {get;set;}
        public String tipoCamion {get;set;}
        public String coordenadasGPS {get;set;}
        public String terminos_pago {get;set;}
        public String forma_pago {get;set;}
        public String fecha_prevista_obra_civil {get;set;}
        public String fecha_firma_cliente {get;set;}
        public String iban {get;set;}
        public String fecha_prevista_1er_llenado {get;set;}
        public String coste_resolucion_anticipada_toneladas {get;set;}
        public String instalador {get;set;}
        public String uso {get;set;}
        public String ritmoConsumo {get;set;}
        public String titularDerechos {get;set;}
        public String toma_agua_15_m {get;set;}       
        public String proyectista {get;set;}
        public String descripcionUbicacionDeposito {get;set;}
        public String equiposInstalacion {get;set;}
        public String responsabilidad_cliente {get;set;}
        public String responsabilidad_primagas {get;set;}
        public String directorio_pdf {get;set;}
        public String otros {get;set;}
        public String coberturaMovil {get;set;}
        public String observacionesGenerales {get;set;}
        public String emailDestinatarioBorrador {get;set;}
    }

    public class DatosOferta
    {
        public String duracion_del_contrato {get;set;}
        public String total {get;set;}
        public String pago_inicial_por_cliente {get;set;} //sin mapeo necesario por el momento
        public String plazo_de_cuota {get;set;}
        public String capacidad_litros {get;set;}
        public String tarifa_de_gas {get;set;}
        public String consumo_contratado {get;set;}
        public String primaservicios {get;set;}
        public String aereo {get;set;}
        public String enterrado {get;set;}
        public String dto_gas {get;set;} //sin mapeo necesario por el momento
        public String tramo1_consumo {get;set;}
        public String tramo2_consumo {get;set;}
        public String tramo3_consumo {get;set;}
        public String tramo4_consumo {get;set;}
        public String tramo5_consumo {get;set;}
        public String tramo1_dto {get;set;}
        public String tramo2_dto {get;set;}
        public String tramo3_dto {get;set;}
        public String tramo4_dto {get;set;}
        public String tramo5_dto {get;set;}
        public String tramo1_primaservicios {get;set;}
        public String tramo2_primaservicios {get;set;}
        public String tramo3_primaservicios {get;set;}
        public String tramo4_primaservicios {get;set;}
        public String tramo5_primaservicios {get;set;} //sin mapeo necesario por el momento
        public String duracion_del_dto {get;set;} //sin mapeo necesario por el momento
        public String tramo_primaservicios {get;set;} //sin mapeo necesario por el momento
        public String cantidad_anyo {get;set;} //sin mapeo necesario por el momento
        public String cuota_mensual {get;set;} //sin mapeo necesario por el momento
        public String coste_instalacion_interior {get;set;}
        public String coste_exterior {get;set;}
        public String proyectos {get;set;}
        public String obra_civil {get;set;}
        public String importe_equipos {get;set;}
        public String contadorservicio {get;set;}
        public String suministro_de_gas_automatico {get;set;}
        public String pdfBase64 {get;set;}
    }

    public class Respuesta
    {   
        public Resultado resultado {get;set;}

        public Respuesta()
        {
            resultado = new Resultado();
        }
    }

    public class Resultado 
    {
        public String codigo {get;set;}
        public String texto {get;set;}
    }
}