public with sharing class OfertaModularController
 {
    private static Integer ALTURA_MAXIMA = 90;
    private static Integer ALTURA_MINIMA = 35;
    private static Integer ALTO_MAXIMO_BARRA_GRAFICO = 130;
    private static Integer ALTO_MINIMO_BARRA_GRAFICO = 52;
    private static Integer ALTURA_DISPONIBLE_BARRAS_GRAFICOS = 155;

    public Quote oferta {get; set;}
    public List<EnergiaPDF> listEnergias {get;set;}
    public Integer numTotalEnergias {get;set;}
    public Integer alturaEspacioTabla {get;set;}
    public Integer alturaSeparador {get;set;}
    public LIst<Tramo__c> listTramos {get;set;}
    public Boolean existenTramos {get;set;}
    public Pack_de_servicio__c packServicio {get;set;} 
    public Pack__c packCol1 {get;set;}
    public Pack__c packCol2 {get;set;}
    public Pack__c packCol3 {get;set;}
    public Integer numPacks {get;set;}
    public List<EntidadServicio> listEntidadesServicios {get;set;}
    public Integer columnaPackSeleccionado {get;set;}
    public Integer numTotalServiciosPack {get;set;}

    //Listas con los nombres de cada cuadro, ya que el mapa no permite un orden de inserción
    public List<String> preciosGasList {get;set;}
    //Nombre del cuadro,datos del cuadro
    public Map<String,String> preciosGas {get;set;}
    public String opcionSeleccionadaGas {get;set;}
    public String precioOpcionSeleccionadaGas {get;set;}
    public String precioSuma1Mas2 {get;set;}
    public String elementosInstalacionDepositos {get;set;}
    public String elementosInstalacionEquipos {get;set;}
    public Boolean hayEquipos {get;set;}
    public Boolean hayDepositos {get;set;}

    public Integer alturaRellenoKwh {get;set;}
    public Integer alturaRellenoKgCO2 {get;set;}

    public Integer altoBarraGrafico {get;set;}
    public Integer altoBarraPrimagasGrafico {get;set;}
    public Integer posYBarraGrafico {get;set;}
    public Integer posYBarraPrimagasGrafico {get;set;}

    // lista de servicios seleccionados no incluidos en el pack seleccionado
    public String serviciosExtra {get;set;}

    public String comercialNombre {get;set;}
    public String comercialTelefono {get;set;}
    public String comercialEmail {get;set;}
    
    public String poblacionProvincia {get;set;}

    public Boolean hayObservaciones {get;set;}
    public String fechaFormateada {get;set;}
    public String fechaVigencia {get;set;}
    public Boolean financiaGas {get;set;}

    public Decimal tramoCorrespondiente {get;set;}

    public Integer numTramos {get;set;}

    public OfertaModularController()
    {
        //System.debug('##OfertaModularController inicio');
        Id idOferta;
        List<Quote> listOfertas;
        List<Pack_de_servicio__c> listPackServicios;
        List<Energia_actual__c> listEnergiasSF;
        Decimal mayorValor;
        Integer alturaTotalKwh;
        Integer alturaTotalPrimagasKwh;
        Integer alturaTotalKgCO2;
        Integer alturaTotalPrimagasKgCO2;
        EnergiaPDF energiaPDF;
        
        try
        {
            mayorValor = 0;
            alturaTotalKwh = 0;
            alturaTotalPrimagasKwh = 0;
            alturaRellenoKwh = 0;
            alturaTotalKgCO2 = 0;
            alturaTotalPrimagasKgCO2 = 0;
            alturaRellenoKgCO2 = 0;

            numTotalServiciosPack = 0;
            numPacks = 0;
            // recuperar el id de la oferta
            idOferta = ApexPages.currentPage().getParameters().get('idOferta');
            //System.debug('##OfertaModularController idOferta: ' + idOferta);
            if(idOferta != null)
            {
                listOfertas = [select Id, Name, Account.Name, Account.Actividad__c, Exterior_estandar__c, Interior_estandar__c, Servicio_estandar__c, Kg__c, KgCO2__c, 
                                    KWh__c, Litros__c, KgCO2_Primagas__c, KWh_Primagas__c, Diferencia_kgCO2__c, Diferencia_kWh__c,Fecha_vigencia__c, Importe_total__c,
                                    Importe_total_primagas__c, Diferencia_importes_totales__c,
                                    Opportunity.Owner.Name, Opportunity.Owner.Phone, Opportunity.Owner.Email,
                                    Importe_total_numeric__c,Diferencia_importes_totales_numeric__c,Importe_total_primagas_numeric__c, Precio_L_numeric__c, Precio_Kg_numeric__c,
                                    Total_inversion__c,Pago_inicial__c,Importe_12_cuotas_numeric__c,Importe_de_cuotas_numeric__c,Numero_de_cuotas__c,Tipo_de_interes__c,Importe_en_gas_en_E_L_numeric__c,
                                    Importe_en_gas_en_E_Kg_numeric__c,Financiacion_seleccionada__c, Deposito_nombre__c, Total_Inversion_con_deposito__c,
                                    Duracion_contratado__c,Resolucion_anticipada__c  ,CreatedDate, Aplica_tramos__c,
                                    Precio_mensual_L_numeric__c,Precio_mensual_Kg_numeric__c,Precio_fijo_anual_Kg_numeric__c, 
                                     Contador_L__c,Contador_Kg__c,Precio_fijo_anual_L_numeric__c,Tarifa_plana_L__c,Tarifa_plana_Kg__c,
                                     Precio_fijo_anual_L__c,Precio_mensual_L__c,Precio_mensual_Kg__c,Precio_fijo_anual_Kg__c, 
                                     Opcion_seleccionada_producto__c, Texto_fecha_producto__c, Equipo_interior__c, Interior__c, Exterior__c, 
                                     Proyectos__c, Vallado__c, Obra_civil__c, Status , Observaciones__c, Account.Provincia__c, Account.Poblacion_Facturacion__c,
                                     Account.ShippingCity, Account.ShippingState, Total_financiable__c 
                                     from Quote where Id = :idOferta and RecordTypeId = :Util.objectsRecordTypesMap.get('Quote').get('Oferta_modular').Id];
                //System.debug('##OfertaModularController listOfertas: ' + listOfertas);
                if(listOfertas != null && !listOfertas.isEmpty())
                {
                    oferta = listOfertas.get(0);

                    poblacionProvincia = '';
                    if(!String.isBlank(oferta.Account.ShippingCity) && !String.isBlank(oferta.Account.ShippingState))
                    {
                        poblacionProvincia = oferta.Account.ShippingCity+', '+oferta.Account.ShippingState;
                    }else if (String.isBlank(oferta.Account.ShippingCity) && !String.isBlank(oferta.Account.ShippingState))
                    {
                        poblacionProvincia = oferta.Account.ShippingState;
                    }else if(!String.isBlank(oferta.Account.ShippingCity) && String.isBlank(oferta.Account.ShippingState))
                    {
                        poblacionProvincia = oferta.Account.ShippingCity;
                    }
                    //System.debug('##OfertaModularController oferta: ' + oferta);
                    fechaFormateada = oferta.CreatedDate.format('dd-MM-YYYY');

                    Date orig = oferta.Fecha_vigencia__c;
                    DateTime dtConverted = Datetime.newInstance(orig.year(), orig.month(),orig.day(),0,0,0); 
                    fechaVigencia = dtConverted.format('dd-MM-YYYY');
                    //Cambios rfernandez (07/02/2017)
                    List<DepositosMaestros__c> costesDepositos = [Select D__c From DepositosMaestros__c Where Deposito__c =: oferta.Deposito_nombre__c];
                    Decimal costeDeposito;
                    if(costesDepositos.size() > 0)
                    {
                        costeDeposito = costesDepositos[0].D__c;
                    }else{
                        costeDeposito = 0.0;
                    }
                    System.debug('Coste Deposito: '+costeDeposito);
                    //Fin cambios rfernandez (07/02/2017)


                    //Datos del comercial
                    String usuarioId = UserInfo.getUserId();
                    List<User> usuario = [SELECT Id, Name, Email, Phone FROM User WHERE Id=: usuarioId];
                    if(usuario!=null && usuario.size()>0)
                    {
                        comercialNombre = String.isBlank(usuario[0].Name) ? '' : usuario[0].Name;
                        comercialTelefono = String.isBlank(usuario[0].Phone) ? '' : usuario[0].Phone;
                        comercialEmail = String.isBlank(usuario[0].Email) ? '' : usuario[0].Email;
                    }

                    //Cambios rfernandez (16/02/2017)
                    
                    if(!String.isBlank(oferta.Observaciones__c))
                    {
                        hayObservaciones = true;
                    }else{
                        hayObservaciones = false;
                    }
                    //Fin cambios rfernandez
                    
                    listEnergiasSF = [select Id, Consumo__c, Consumo_KgCO2__c, Consumo_KgCO2_Primagas__c, Consumo_Kg_Primagas__c, Consumo_KWH__c, Consumo_KWH_Primagas__c,
                                    Consumo_L_Primagas__c, Tipo_energia__c, Unidad_consumo__c, Unidad_consumo_abreviada__c
                                    from Energia_actual__c where Presupuesto__c = :idOferta order by Consumo_L_Primagas__c desc];
                    if(listEnergiasSF == null)
                    {
                        numTotalEnergias = 0;
                    }
                    else
                    {
                        numTotalEnergias = listEnergiasSF.size();

                        List<String> listUnidadesConsumo = new List<String>();
                        for(Energia_Actual__c energia: listEnergiasSF)
                        {
                            listUnidadesConsumo.add(energia.Unidad_consumo__c);
                            // Obtener el mayor de los valores para las energías mostradas en el cuadro inicial del PDF cuyas barras tienen altura dinámica
                            if(energia.Consumo_KWH__c > mayorValor)
                            {
                                mayorValor = energia.Consumo_KWH__c;
                            }
                            if(energia.Consumo_KWH_Primagas__c > mayorValor)
                            {
                                mayorValor = energia.Consumo_KWH_Primagas__c;
                            }
                            if(energia.Consumo_KgCO2__c > mayorValor)
                            {
                                mayorValor = energia.Consumo_KgCO2__c;
                            }
                            if(energia.Consumo_KgCO2_Primagas__c > mayorValor)
                            {
                                mayorValor = energia.Consumo_KgCO2_Primagas__c;
                            }
                        }
                        //System.debug('mayorValor: ' + mayorValor);

                        List<EnergiaUnidades__c> listEnergiasUnidades = [SELECT Id, UnidadConsumo__c, Abreviatura_unidad_consumo__c FROM EnergiaUnidades__c WHERE UnidadConsumo__c IN: listUnidadesConsumo];

                        listEnergias = new List<EnergiaPDF>();
                        for(Energia_actual__c energia: listEnergiasSF)
                        {
                            for(EnergiaUnidades__c energiaUnidad: listEnergiasUnidades)
                            {
                                if(energia.Unidad_consumo__c == energiaUnidad.UnidadConsumo__c)
                                {
                                    energia.Unidad_consumo_abreviada__c = energiaUnidad.Abreviatura_unidad_consumo__c;
                                    break;
                                }
                            }

                            energiaPDF = new EnergiaPDF(energia, mayorValor);
                            alturaTotalKwh += energiaPDF.alturaKWH;
                            alturaTotalPrimagasKwh += energiaPDF.alturaKWHPrimagas;
                            alturaTotalKgCO2 += energiaPDF.alturaKgCO2;
                            alturaTotalPrimagasKgCO2 += energiaPDF.alturaKgCO2Primagas;
                            listEnergias.add(energiaPDF);
                        }

                        // calcular relleno necesario en las columnas de primagas
                        if(alturaTotalKwh > alturaTotalPrimagasKwh)
                        {
                            alturaRellenoKwh = alturaTotalKwh - alturaTotalPrimagasKwh;
                        }
                        //System.debug('alturaRelleno kwh: ' + alturaTotalKwh + ' - ' + alturaTotalPrimagasKwh +  ' = ' + alturaRellenoKwh);
                        if(alturaTotalKgCO2 > alturaTotalPrimagasKgCO2)
                        {
                            alturaRellenoKgCO2 = alturaTotalKgCO2 - alturaTotalPrimagasKgCO2;
                        }
                        //System.debug('alturaRelleno kwh: ' + alturaTotalKgCO2 + ' - ' + alturaTotalPrimagasKgCO2 +  ' = ' + alturaRellenoKgCO2);
                    }
                    if(numTotalEnergias == 1)
                    {
                        alturaEspacioTabla = 0;
                        alturaSeparador = 160;
                    }else if (numTotalEnergias == 2)
                    {
                        alturaEspacioTabla = 140;
                        alturaSeparador = 260;
                    }else {
                        alturaEspacioTabla = 0;
                        alturaSeparador = 480;
                    }
                    System.debug('##numTotalEnergias: '+numTotalEnergias);
                    listTramos = [select Id, Name, Consumo_desde_Kg__c, Consumo_desde_L__c, Financiacion_en_gas_en_E_Kg__c, Financiacion_en_gas_en_E_L__c
                                         from Tramo__c where Presupuesto__c = :idOferta and RecordTypeId = :Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_normal').Id order by Name];
                    existenTramos = (listTramos != null && !listTramos.isEmpty());
                    numTramos = listTramos.size();

                    tramoCorrespondiente = 0.0;
                    if(existenTramos)
                    {
                        for(Tramo__c tramo: listTramos)
                        {
                            if((oferta.Kg__c > tramo.Consumo_desde_Kg__c) && (tramo.Consumo_desde_Kg__c > tramoCorrespondiente)) 
                            {
                                tramoCorrespondiente = tramo.Consumo_desde_Kg__c;
                            }
                        }

                        
                    }

                    List<Tramo__c> listTramosCuandoNoAplica = new List<Tramo__c>();
                    if(!oferta.Aplica_tramos__c)
                    {
                        for(Tramo__c tramo: listTramos)
                        {
                            if(tramo.Consumo_desde_Kg__c == tramoCorrespondiente)
                            {
                                listTramosCuandoNoAplica.add(tramo);
                            }
                        }
                        listTramos.clear();
                        listTramos = listTramosCuandoNoAplica;
                    }

                    System.debug('tramoCorrespondiente:'+tramoCorrespondiente);


                    listPackServicios = [select Id, Name, Total_importe__c FROM Pack_de_servicio__c WHERE Presupuesto__c =:idOferta];
                    if(listPackServicios != null && !listPackServicios.isEmpty())
                    {
                        packServicio = listPackServicios.get(0);
                    }
                    //system.debug('packServicio: ' + packServicio);

                    //Relleno la lista de elementos de instalación
                    elementosInstalacionEquipos = '';
                    elementosInstalacionDepositos = '';

                    List<Equipo_Ajuste__c> equiposAjuste = [select Id, Name, Cantidad__c FROM Equipo_Ajuste__c WHERE Presupuesto__c =:idOferta];

                    /*if(!String.isBlank(oferta.Equipo_interior__c))
                    {
                       elementosInstalacionEquipos += oferta.Equipo_interior__c; 
                    }*/
                    if(!equiposAjuste.isEmpty())
                    {
                        for(Equipo_Ajuste__c equipo: equiposAjuste)
                        {
                            elementosInstalacionEquipos += equipo.Cantidad__c+' x '+equipo.Name + ', ';
                        }
                    }

                    if(oferta.Interior__c)
                    {
                        elementosInstalacionDepositos += 'instalación de depósito interior, ';
                    }
                    else if(oferta.Exterior__c)
                    {
                        elementosInstalacionDepositos += 'instalación de depósito exterior, ';
                    }   
                    if(!String.isEmpty(oferta.Deposito_nombre__c))
                    {
                        elementosInstalacionDepositos += oferta.Deposito_nombre__c + ', ';
                    }               
                    if(oferta.Proyectos__c=='Proyecto')
                    {
                        elementosInstalacionDepositos += 'proyecto, ';
                    }
                    else if(oferta.Proyectos__c=='Memoria')
                    {
                        elementosInstalacionDepositos += 'memoria, ';
                    }
                    if(oferta.Vallado__c)
                    {
                        elementosInstalacionDepositos += 'vallado, ';
                    }
                    if(oferta.Obra_civil__c)
                    {
                        elementosInstalacionDepositos += 'obra civil, ';
                    }

                    if(!String.isBlank(elementosInstalacionDepositos))
                    {
                        hayDepositos = true;
                        
                    }
                    if(!String.isBlank(elementosInstalacionEquipos))
                    {
                        hayEquipos = true;
                    }
                    
                    if(elementosInstalacionDepositos.endsWith(', '))
                    {
                        elementosInstalacionDepositos = elementosInstalacionDepositos.substringBeforeLast(', ');
                    }
                    if(elementosInstalacionEquipos.endsWith(', '))
                    {
                        elementosInstalacionEquipos = elementosInstalacionEquipos.substringBeforeLast(', ');
                    }

                    cargarDatosDinamicosGas();

                    cargarDatosDinamicosServicios();

                    // cálculos para el gráfico final
                    if(oferta.Importe_total_primagas_numeric__c != null && oferta.Importe_total_numeric__c != null)
                    {
                        altoBarraGrafico = OfertaModularController.ALTO_MAXIMO_BARRA_GRAFICO;
                        altoBarraPrimagasGrafico = Integer.valueOf((oferta.Importe_total_primagas_numeric__c * altoBarraGrafico) / oferta.Importe_total_numeric__c);
                        if(altoBarraPrimagasGrafico < OfertaModularController.ALTO_MINIMO_BARRA_GRAFICO)
                        {
                            altoBarraPrimagasGrafico = OfertaModularController.ALTO_MINIMO_BARRA_GRAFICO;
                        }
                        else
                        {
                            if(altoBarraPrimagasGrafico > altoBarraGrafico -38)
                                altoBarraPrimagasGrafico = altoBarraGrafico-38;
                        }
                        posYBarraGrafico = OfertaModularController.ALTURA_DISPONIBLE_BARRAS_GRAFICOS - altoBarraGrafico;
                        posYBarraPrimagasGrafico = OfertaModularController.ALTURA_DISPONIBLE_BARRAS_GRAFICOS - altoBarraPrimagasGrafico;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción en OfertaModularPDF: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber() );
        }
        //System.debug('##OfertaModularController fin');
    }

    private void cargarDatosDinamicosGas()
    {
        String anyo;
        preciosGas = new Map<String,String>();
        preciosGasList = new List<String>();
        Decimal precioLGasSelecc = 0;
        Decimal precioKgGasSelecc = 0;
        Decimal precioLSuma1Mas2;
        Decimal precioKgSuma1Mas2;

        opcionSeleccionadaGas = '';
        precioOpcionSeleccionadaGas = '';
        if(oferta.Opcion_seleccionada_producto__c == 'Mensual')
        {
            opcionSeleccionadaGas = Label.OfertaPDF_Precio_Mensual;
            precioOpcionSeleccionadaGas = transformNumber(oferta.Precio_mensual_L_numeric__c+'')+' '+Label.OfertaPDF_EurosLitro + ' ('+ transformNumber(oferta.Precio_mensual_Kg_numeric__c+'')+' '+Label.OfertaPDF_Euros_Kg + ')';
            precioLGasSelecc = oferta.Precio_mensual_L_numeric__c;
            precioKgGasSelecc = oferta.Precio_mensual_Kg_numeric__c;
        }
        else
        {
            if(oferta.Opcion_seleccionada_producto__c == 'Contador')
            {
                opcionSeleccionadaGas = Label.OfertaPDF_Contador;
                precioOpcionSeleccionadaGas = transformNumber(oferta.Contador_L__c+'')+' '+Label.OfertaPDF_EurosLitro + ' (' + transformNumber(oferta.Contador_Kg__c+'')+' '+Label.OfertaPDF_Euros_Kg +')';
                precioLGasSelecc = oferta.Contador_Kg__c;
                precioKgGasSelecc = oferta.Contador_L__c;
            }
            else
            {
                if(oferta.Opcion_seleccionada_producto__c == 'Fijo')
                {
                    opcionSeleccionadaGas = Label.OfertaPDF_Precio_Fijo_Anual;
                    precioOpcionSeleccionadaGas = transformNumber(oferta.Precio_fijo_anual_L_numeric__c+'')+' '+Label.OfertaPDF_EurosLitro + ' (' +transformNumber(oferta.Precio_fijo_anual_Kg_numeric__c+'')+' '+Label.OfertaPDF_Euros_Kg + ')';
                    precioLGasSelecc = oferta.Precio_fijo_anual_Kg_numeric__c;
                    precioKgGasSelecc = oferta.Precio_fijo_anual_L_numeric__c;
                }
                else
                {
                    if(oferta.Opcion_seleccionada_producto__c == 'Plana')
                    {
                        opcionSeleccionadaGas = Label.OfertaPDF_Tarifa_Plana;
                        precioOpcionSeleccionadaGas = transformNumber(oferta.Tarifa_plana_L__c+'')+' '+Label.OfertaPDF_EurosLitro +' (' + transformNumber(oferta.Tarifa_plana_Kg__c+'')+' '+Label.OfertaPDF_Euros_Kg + ')';
                        precioLGasSelecc = oferta.Tarifa_plana_L__c;
                        precioKgGasSelecc = oferta.Tarifa_plana_Kg__c;
                    }
                }
            }
        }

        if(oferta.Precio_mensual_L__c != null && oferta.Precio_mensual_Kg__c != null)
        {
            preciosGas.put(Label.OfertaPDF_Precio_Mensual,' <br/><span style="font-size:24px;color:#E83129;"><strong>'+transformNumber(oferta.Precio_mensual_Kg_numeric__c+'')+' '+Label.OfertaPDF_Euros_Kg+'</strong></span><br/>'+oferta.Texto_fecha_producto__c);
            preciosGasList.add(Label.OfertaPDF_Precio_Mensual);
        }

        if(oferta.Contador_L__c != null && oferta.Contador_Kg__c != null)
        {
            preciosGas.put(Label.OfertaPDF_Contador, ' <br/><span style="font-size:24px;color:#E83129;"><strong>'+transformNumber(oferta.Contador_Kg__c+'')+' '+Label.OfertaPDF_Euros_Kg+'</strong></span><br/>'+oferta.Texto_fecha_producto__c);
            preciosGasList.add(Label.OfertaPDF_Contador);
        }

        if(oferta.Precio_fijo_anual_L__c != null && oferta.Precio_fijo_anual_Kg__c != null)
        {
            if(oferta.CreatedDate == null)
                anyo = '';
            else
                anyo = String.valueOf(oferta.CreatedDate.year());
            preciosGas.put(Label.OfertaPDF_Precio_Fijo_Anual,' <br/><span style="font-size:24px;color:#E83129;"><strong>'+transformNumber(oferta.Precio_fijo_anual_Kg_numeric__c+'')+' '+Label.OfertaPDF_Euros_Kg+'</strong></span><br/>'+Label.OfertaPDF_precio_para + ' ' + anyo);
            preciosGasList.add(Label.OfertaPDF_Precio_Fijo_Anual);
        }
        if(oferta.Tarifa_plana_L__c != null && oferta.Tarifa_plana_Kg__c != null)
        {
            preciosGas.put(Label.OfertaPDF_Tarifa_Plana,' <br/><span style="font-size:24px;color:#E83129;"><strong>'+transformNumber(oferta.Tarifa_plana_Kg__c+'')+' '+Label.OfertaPDF_Euros_Kg+'</strong></span><br/>'+oferta.Texto_fecha_producto__c);
            preciosGasList.add(Label.OfertaPDF_Tarifa_Plana);
        }
        /*system.debug('Preciogas size'+preciosGas.size());
        system.debug('Preciogas '+preciosGas);
        system.debug('preciosGasLis: ' + preciosGasList);*/

        if(oferta.Financiacion_seleccionada__c == 'FinanciaGas')
        {
            precioLSuma1Mas2 = oferta.Importe_en_gas_en_E_L_numeric__c + precioLGasSelecc; 
            precioKgSuma1Mas2 = oferta.Importe_en_gas_en_E_Kg_numeric__c + precioKgGasSelecc;
            precioSuma1Mas2 = transformNumber(precioKgSuma1Mas2+'')+Label.OfertaPDF_Euros_Kg ;
            financiaGas = true;
        }
    }

    private void cargarDatosDinamicosServicios()
    {
        List<ServiciosActividad__c> listServiciosActividad;
        ServiciosActividad__c servicioActividad;
        List<ServiciosPacks__c> listServiciosPacks; // lista para todos los servicios de packs de maestros
        List<Servicio__c> listServicios; // lista de servicios seleccionados en el pack seleccionado
        Map<String, Servicio__c> mapServicios; // mapa para identificar cada servicio del pack seleccionado por su Id_Servicio_pack_maestro__c
        Map<String, EntidadServicio> mapEntidadesServicios; // mapa para identificar cada entidad por el nombre del servicio
        EntidadServicio entServicioAux;

        listServiciosActividad = ServiciosActividad__c.getAll().values();
        //System.debug('##listServiciosActividad: ' + listServiciosActividad);
        //System.debug('##oferta.Account.Actividad__c: ' + oferta.Account.Actividad__c);
        if(listServiciosActividad!=null)
        {
            for(ServiciosActividad__c sa : listServiciosActividad)
            {
                System.debug('##sa.Activo__c: ' + sa.Activo__c);
                System.debug('##sa.Actividad__c: ' + sa.Actividad__c);
                System.debug('##oferta.Account.Actividad__c: ' + oferta.Account.Actividad__c);

//Lo siguiente se hace porque (no sabemos por qué) hay un caracter raro que no es un espacio en blanco y hace que la comparacion no de true
                String saActividad =  sa.Actividad__c;
                String cuentaActividad =  oferta.Account.Actividad__c;

                saActividad = saActividad.trim();
                saActividad = saActividad.replaceAll('[^\\x00-\\x7F]', '');
                saActividad = saActividad.replaceAll(' ', '');

                cuentaActividad = cuentaActividad.trim();
                cuentaActividad = cuentaActividad.replaceAll('[^\\x00-\\x7F]', '');
                cuentaActividad = cuentaActividad.replaceAll(' ', '');

                if(sa.Activo__c && saActividad == cuentaActividad)
                {
                    servicioActividad = sa;
                    break;
                }
                /*if(sa.Activo__c && sa.Actividad__c == oferta.Account.Actividad__c)
                {
                    servicioActividad = sa;
                    break;
                }*/
            }
            //System.debug('##servicioActividad: ' + servicioActividad);
            if(servicioActividad != null)
            {
                if(servicioActividad.MOSTRAR1__c != null)
                {
                    packCol1 = Pack__c.getValues(servicioActividad.MOSTRAR1__c);
                    if(packServicio != null && packServicio.Name != null && packServicio.Name.Equals(packCol1.Nombre__c))
                    {
                        packCol1.ImporteMensual__c = packServicio.Total_importe__c;
                        columnaPackSeleccionado = 1;
                    }
                    numPacks++;
                }
                if(servicioActividad.MOSTRAR2__c != null)
                {
                    if(packCol1 == null)
                    {
                        packCol1 = Pack__c.getValues(servicioActividad.MOSTRAR2__c);
                        if(packServicio != null && packServicio.Name != null && packServicio.Name.Equals(packCol1.Nombre__c))
                        {
                            packCol1.ImporteMensual__c = packServicio.Total_importe__c;
                            columnaPackSeleccionado = 1;
                        }
                        numPacks++;
                    }
                    else
                    {
                        packCol2 = Pack__c.getValues(servicioActividad.MOSTRAR2__c);
                        if(packServicio != null && packServicio.Name != null && packServicio.Name.Equals(packCol2.Nombre__c))
                        {
                            packCol2.ImporteMensual__c = packServicio.Total_importe__c;
                            columnaPackSeleccionado = 2;
                        }
                        numPacks++;
                    }
                }
                if(servicioActividad.MOSTRAR3__c != null)
                {
                    if(packCol1 == null)
                    {
                        packCol1 = Pack__c.getValues(servicioActividad.MOSTRAR3__c);
                        if(packServicio != null && packServicio.Name != null && packServicio.Name.Equals(packCol1.Nombre__c))
                        {
                            packCol1.ImporteMensual__c = packServicio.Total_importe__c;
                            columnaPackSeleccionado = 1;
                        }
                        numPacks++;
                    }
                    else
                    {
                        if(packCol2 == null)
                        {
                            packCol2 = Pack__c.getValues(servicioActividad.MOSTRAR3__c);
                            if(packServicio != null && packServicio.Name != null && packServicio.Name.Equals(packCol2.Nombre__c))
                            {
                                packCol2.ImporteMensual__c = packServicio.Total_importe__c;
                                columnaPackSeleccionado = 2;
                            }
                            numPacks++;
                        }
                        else
                        {
                            packCol3 = Pack__c.getValues(servicioActividad.MOSTRAR3__c);
                            if(packServicio != null && packServicio.Name != null && packServicio.Name.Equals(packCol3.Nombre__c))
                            {
                                packCol3.ImporteMensual__c = packServicio.Total_importe__c;
                                columnaPackSeleccionado = 3;
                            }
                            numPacks++;
                        }
                    }
                }
                            //System.debug('##numPacks: ' + numPacks);
                            //System.debug('##columnaPackSeleccionado: ' + columnaPackSeleccionado);
                            //System.debug('##packCol1: ' + packCol1);
                            //System.debug('##packCol2: ' + packCol2);
                            //System.debug('##packCol3: ' + packCol3);

                mapServicios = new Map<String, Servicio__c>();
                serviciosExtra = '';
                if(packServicio != null)
                {
                    listServicios = [select Name, Name_Servicio_pack_maestro__c, Pack_de_servicio__c, Importe_mensual__c,Incluido__c from Servicio__c where Pack_de_servicio__c =: packServicio.Id];
                    //system.debug('listServicios: ' + listServicios);
                    if(listServicios != null && !listServicios.isEmpty())
                    {
                        for(Servicio__c s : listServicios)
                        {
                            if(s.Name_Servicio_pack_maestro__c != null && !mapServicios.containsKey(s.Name_Servicio_pack_maestro__c))
                            {
                                mapServicios.put(s.Name_Servicio_pack_maestro__c, s);
                            }
                            if(!s.Incluido__c)
                            {
                                serviciosExtra += ', ' + s.Name;
                            }
                        }
                    }
                }
                //System.debug('##mapServicios: ' + mapServicios);

                // recuperar servicios para cada pack
                listServiciosPacks = ServiciosPacks__c.getAll().values();
                //System.debug('##listServiciosPacks: ' + listServiciosPacks);

                if(listServiciosPacks != null)
                {
                    mapEntidadesServicios = new Map<String, EntidadServicio>();
                    for(ServiciosPacks__c sp : listServiciosPacks)
                    {
                        if(sp.Numero_de_pack__c == packCol1.Numero_de_pack__c )
                        {
                            entServicioAux = mapEntidadesServicios.remove(sp.Nombre__c);
                            if(entServicioAux == null )
                            {
                                entServicioAux = new EntidadServicio();
                                entServicioAux.nombre = sp.Nombre__c;
                            }
                            if(mapServicios.containsKey(sp.Name))
                            {
                                entServicioAux.importeCol1 = ((mapServicios.get(sp.Name)).Importe_mensual__c == null ? null : String.valueOf((mapServicios.get(sp.Name)).Importe_mensual__c));
                                entServicioAux.incluidoCol1 = true;
                            }
                            else
                            {
                                entServicioAux.importeCol1 = (sp.Importe_mensual__c == null ? null : String.valueOf(sp.Importe_mensual__c));
                                entServicioAux.incluidoCol1 = sp.Incluido__c;
                            }
                            entServicioAux.importeCol1 = transformNumber(entServicioAux.importeCol1);
                            mapEntidadesServicios.put(entServicioAux.nombre, entServicioAux);
                        }
                        if(sp.Numero_de_pack__c == packCol2.Numero_de_pack__c )
                        {
                            entServicioAux = mapEntidadesServicios.remove(sp.Nombre__c);
                            if(entServicioAux == null )
                            {
                                entServicioAux = new EntidadServicio();
                                entServicioAux.nombre = sp.Nombre__c;
                            }
                            if(mapServicios.containsKey(sp.Name))
                            {
                                entServicioAux.importeCol2 = ((mapServicios.get(sp.Name)).Importe_mensual__c == null ? null : String.valueOf((mapServicios.get(sp.Name)).Importe_mensual__c));
                                entServicioAux.incluidoCol2 = true;
                            }
                            else
                            {
                                entServicioAux.importeCol2 = (sp.Importe_mensual__c == null ? null : String.valueOf(sp.Importe_mensual__c));
                                entServicioAux.incluidoCol2 = sp.Incluido__c;
                            }
                            entServicioAux.importeCol2 = transformNumber(entServicioAux.importeCol2);
                            mapEntidadesServicios.put(entServicioAux.nombre, entServicioAux);
                        }
                        if(sp.Numero_de_pack__c == packCol3.Numero_de_pack__c )
                        {
                            entServicioAux = mapEntidadesServicios.remove(sp.Nombre__c);
                            if(entServicioAux == null )
                            {
                                entServicioAux = new EntidadServicio();
                                entServicioAux.nombre = sp.Nombre__c;
                            }
                            if(mapServicios.containsKey(sp.Name))
                            {
                                entServicioAux.importeCol3 = ((mapServicios.get(sp.Name)).Importe_mensual__c == null ? null : String.valueOf((mapServicios.get(sp.Name)).Importe_mensual__c));
                                entServicioAux.incluidoCol3 = true;
                            }
                            else
                            {
                                entServicioAux.importeCol3 = (sp.Importe_mensual__c == null ? null : String.valueOf(sp.Importe_mensual__c));
                                entServicioAux.incluidoCol3 = sp.Incluido__c;
                            }
                            entServicioAux.importeCol3 = transformNumber(entServicioAux.importeCol3);
                            mapEntidadesServicios.put(entServicioAux.nombre, entServicioAux);
                        }
                    }
                    //System.debug('##mapEntidadesServicios: ' + mapEntidadesServicios);
                    if(mapEntidadesServicios != null)
                    {
                        listEntidadesServicios = new List<EntidadServicio>(mapEntidadesServicios.values());
                        listEntidadesServicios.sort();
                        numTotalServiciosPack = listEntidadesServicios.size();
                        //System.debug('##listEntidadesServicios: ' + listEntidadesServicios);
                        //System.debug('##numTotalServiciosPack: ' + numTotalServiciosPack);
                    }
                }
            }
        }
    }

    /*
    Metodo que cambia los puntos por comas y 
    las comas por puntos, para pasar de un formato EEUU a europeo
    */
    private String transformNumber(String param)
    {
        String punto = '#';
        String coma = '@';
        if(!String.isBlank(param))
        {
            param = param.replace('.',punto);
            param = param.replace(',',coma);
            param = param.replace(punto,',');
            param = param.replace(coma,'.');
        }
        return param;
    }

    public class EntidadServicio implements Comparable
    {
        public String nombre {get;set;}
        public Boolean incluidoCol1 {get;set;}
        public String importeCol1 {get;set;}
        public Boolean incluidoCol2 {get;set;}
        public String importeCol2 {get;set;}
        public Boolean incluidoCol3 {get;set;}
        public String importeCol3 {get;set;}

        public EntidadServicio()
        {
            incluidoCol1 = false;
            incluidoCol2 = false;
            incluidoCol3 = false;
        }

        public Integer compareTo(Object obj)
        {
            Integer resultado;
            Boolean comparar2 = false;
            Boolean comparar3 = false;
            Boolean compararNombre = false;
            // cast
            EntidadServicio entS = (EntidadServicio)obj;

            if(this.incluidoCol1)
            {
                if(!entS.incluidoCol1)
                {
                    resultado = -1;
                }
                else
                {
                    if(this.importeCol1 == null)
                    {
                        if(entS.importeCol1 == null)
                        {
                            comparar2 = true;
                        }
                        else
                        {
                            resultado = -1;
                        }
                    }
                    else
                    {
                        if(entS.importeCol1 == null)
                        {
                            resultado = 1;
                        }
                        else
                        {
                            comparar2 = true;
                        }
                    }
                }
            }
            else
            {
                if(entS.incluidoCol1)
                {
                    resultado = 1;
                }
                else
                {
                   comparar2 = true;
                }
            }

            if(comparar2)
            {
                if(this.incluidoCol2)
                {
                    if(!entS.incluidoCol2)
                    {
                        resultado = -1;
                    }
                    else
                    {
                        if(this.importeCol2 == null)
                        {
                            if(entS.importeCol2 == null)
                            {
                                comparar3 = true;
                            }
                            else
                            {
                                resultado = -1;
                            }
                        }
                        else
                        {
                            if(entS.importeCol2 == null)
                            {
                                resultado = 1;
                            }
                            else
                            {
                                comparar3 = true;
                            }
                        }
                    }
                }
                else
                {
                    if(entS.incluidoCol2)
                    {
                        resultado = 1;
                    }
                    else
                    {
                       comparar3 = true;
                    }
                }
            }

            if(comparar3)
            {
                if(this.incluidoCol3)
                {
                    if(!entS.incluidoCol3)
                    {
                        resultado = -1;
                    }
                    else
                    {
                        if(this.importeCol3 == null)
                        {
                            if(entS.importeCol3 == null)
                            {
                                compararNombre = true;
                            }
                            else
                            {
                                resultado = -1;
                            }
                        }
                        else
                        {
                            if(entS.importeCol3 == null)
                            {
                                resultado = 1;
                            }
                            else
                            {
                                compararNombre = true;
                            }
                        }
                    }
                }
                else
                {
                    if(entS.incluidoCol3)
                    {
                        resultado = 1;
                    }
                    else
                    {
                       compararNombre = true;
                    }
                }
            }

            if(compararNombre)
            {
                resultado = this.nombre.compareTo(entS.nombre);
            }
            return resultado;
        }
    }

    public class EnergiaPDF
    {
        public Energia_actual__c energia {get;set;}
        public Integer alturaKWH {get; set;}
        public Integer alturaKWHPrimagas {get; set;}
        public Integer alturaKgCO2 {get;set;}
        public Integer alturaKgCO2Primagas {get;set;}

        public EnergiaPDF( Energia_actual__c pEnergia, Decimal pMayorValor)
        {
            this.energia = pEnergia;
            this.alturaKWH = calcularAltura(this.energia.Consumo_KWH__c, pMayorValor);
            this.alturaKWHPrimagas = calcularAltura(this.energia.Consumo_KWH_Primagas__c, pMayorValor);
            this.alturaKgCO2 = calcularAltura(this.energia.Consumo_KgCO2__c, pMayorValor);
            this.alturaKgCO2Primagas = calcularAltura(this.energia.Consumo_KgCO2_Primagas__c, pMayorValor);

            //System.debug('Alturas energia - Kwh=' + this.alturaKWH + ' / Kwh Primagas=' + this.alturaKWHPrimagas + ' / KgCO2=' + this.alturaKgCO2 + ' / KgCO2 Primagas=' + this.alturaKgCO2Primagas);
        }

        public Integer calcularAltura(Decimal valor, Decimal mayorValor)
        {
            Integer altura;
            try
            {
                altura = OfertaModularController.ALTURA_MINIMA;
                if(valor != null)
                {
                    altura = Integer.valueOf((valor * OfertaModularController.ALTURA_MAXIMA) / mayorValor);
                    if(altura < OfertaModularController.ALTURA_MINIMA)
                        altura = OfertaModularController.ALTURA_MINIMA;
                }
            }
            catch(Exception ex)
            {
                altura = OfertaModularController.ALTURA_MINIMA;
                System.debug('Excepción en OfertaModularPDF.EnergiaPDF.calcularAltura: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber() );
            }

            return altura;
        }
    }
}