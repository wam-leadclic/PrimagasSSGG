public with sharing class OfertaPersonalizadaPDFController
{
    private static Integer ALTURA_MAXIMA = 90;
    private static Integer ALTURA_MINIMA = 35;
    private static Integer ALTO_MAXIMO_BARRA_GRAFICO = 130;
    private static Integer ALTO_MINIMO_BARRA_GRAFICO = 52;
    private static Integer ALTURA_DISPONIBLE_BARRAS_GRAFICOS = 155;

    public Decimal tramoMedio {get; set;}
    public String nombreTramoMedio {get; set;}

    public Quote oferta {get; set;}
    public List<EnergiaPDF> listEnergias {get;set;}
    public Integer numTotalEnergias {get;set;}
    public Integer alturaEspacioTabla {get;set;}
    public Integer alturaSeparador {get;set;}
    public List<Deposito__c> listDepositos {get;set;}
    public List<Tramo__c> listTramos {get;set;}
    public List<Equipo_ajuste__c> listEquiposAjuste {get;set;}
    public Boolean existenTramos {get;set;}
    public Date fechaHoy {get; set;}
    public List<String> listServiciosIncluidos {get;set;}
    public Decimal costeTotalInstalacion {get;set;}
    public Decimal inversionPrimagas {get;set;}
    private String equiposAjusteNombres = '';
    public String depositosNombres = '';

    public Integer alturaRellenoKwh {get;set;}
    public Integer alturaRellenoKgCO2 {get;set;}

    public Integer altoBarraGrafico {get;set;}
    public Integer altoBarraPrimagasGrafico {get;set;}
    public Integer posYBarraGrafico {get;set;}
    public Integer posYBarraPrimagasGrafico {get;set;}

    public String getEquiposAjusteNombres(){
        return equiposAjusteNombres;
    }
    public String getDepositosNombres(){
        return depositosNombres;
    }

    public String comercialNombre {get;set;}
    public String comercialTelefono {get;set;}
    public String comercialEmail {get;set;}

    public Boolean hayObservaciones {get;set;}

    public Boolean hayPoblacionProvincia {get;set;}
    public String fechaFormateada {get;set;}
    public String fechaVigencia {get;set;}
    public String poblacionProvincia {get;set;}

    public String pagoEnCuotas {get;set;}
    public Integer costeCliente {get;set;}
    public Boolean hayCosteCliente {get;set;}
    public String alturaPrimaservicios {get;set;}

    public Integer numTramos {get;set;}
    public Integer numTramos2 {get;set;}

  public OfertaPersonalizadaPDFController()
  {
    Id idOferta;
        List<Quote> listOfertas;
        List<Pack__c> listPacks;
        List<ServiciosPacks__c> listServiciosPack;
        Decimal mayorValor;
        List<Energia_actual__c> listEnergiasSF;
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
            
            // recuperar el id de la oferta
            idOferta = ApexPages.currentPage().getParameters().get('idOferta');
            if(idOferta != null)
            {
                listOfertas = [select Id, Name, Account.Name, Account.Actividad__c, Exterior_estandar__c, Interior_estandar__c, Servicio_estandar__c, Kg__c, KgCO2__c, 
                          KWh__c, Litros__c, Tipo_de_tarifa__c, Dto_Producto_gas__c, Duracion_descuento__c, Precio_Kg__c, Cuota_inversion__c,
                                    KgCO2_Primagas__c, KWh_Primagas__c, Diferencia_kgCO2__c, Diferencia_kWh__c, Fecha_vigencia__c, Importe_total__c, Duracion_cuota_inversion__c,
                                    Importe_total_primagas__c, Diferencia_importes_totales__c, Tipo_producto_gas__c, Precio_producto_gas__c, Pago_inicial_inversion__c,
                          Opportunity.Owner.Name, Opportunity.Owner.Phone, Opportunity.Owner.Email, Duracion_contratado__c, Resolucion_anticipada__c,
                                    Importe_total_numeric__c,Diferencia_importes_totales_numeric__c,Importe_total_primagas_numeric__c, Precio_L_numeric__c, Precio_Kg_numeric__c,
                                    Tipo_Primaservicios__c, Precio_Primaservicios__c, Status, Tramo_escalado_a_aplicar__c, Aplica_tramos__c,
                                    Total_inversion__c, Total_Inversion_con_deposito__c, Observaciones__c, Account.Poblacion_Facturacion__c, Account.Provincia__c, CreatedDate,
                                    Account.ShippingCity, Account.ShippingState        
                                    from Quote where Id = :idOferta and RecordTypeId = :Util.objectsRecordTypesMap.get('Quote').get('Oferta_personalizada').Id];
                if(listOfertas != null && !listOfertas.isEmpty())
                {
                    oferta = listOfertas.get(0);
                    System.debug('###oferta.Precio_Primaservicios__c: '+oferta.Precio_Primaservicios__c +' entre /12,2: '+(oferta.Precio_Primaservicios__c/12));

                    poblacionProvincia = '';
                    hayPoblacionProvincia = false;
                    if(!String.isBlank(oferta.Account.ShippingCity) && !String.isBlank(oferta.Account.ShippingState))
                    {
                        poblacionProvincia = oferta.Account.ShippingCity+', '+oferta.Account.ShippingState;
                        hayPoblacionProvincia = true;
                    }else if (String.isBlank(oferta.Account.ShippingCity) && !String.isBlank(oferta.Account.ShippingState))
                    {
                        poblacionProvincia = oferta.Account.ShippingState;
                        hayPoblacionProvincia = true;
                    }else if(!String.isBlank(oferta.Account.ShippingCity) && String.isBlank(oferta.Account.ShippingState))
                    {
                        poblacionProvincia = oferta.Account.ShippingCity;
                        hayPoblacionProvincia = true;
                    }
                    fechaFormateada = oferta.CreatedDate.format('dd-MM-YYYY');
                    Date orig = oferta.Fecha_vigencia__c;
                    DateTime dtConverted = Datetime.newInstance(orig.year(), orig.month(),orig.day(),0,0,0); 
                    fechaVigencia = dtConverted.format('dd-MM-YYYY');
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

                    /*Integer costeTotalInstalacionAux = 0;
                    Integer costeDepositos = 0;

                    listDepositos = [select Id, Name, Cantidad__c, Proyectos__c, Obra_civil_vallado__c, Instalacion_exterior__c, Equipos_exterior__c 
                              from Deposito__c where Presupuesto__c = :idOferta order by Cantidad__c];
                    for(Deposito__c dep : listDepositos)
                    {
                        if(dep.Proyectos__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(dep.Proyectos__c);
                        if(dep.Obra_civil_vallado__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(dep.Obra_civil_vallado__c);
                        if(dep.Instalacion_exterior__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(dep.Instalacion_exterior__c);
                        if(dep.Equipos_exterior__c != null)
                            costeDepositos += Integer.valueOf(dep.Equipos_exterior__c);
                    }*/

                    listDepositos = [select Id, Name, Cantidad__c, Proyectos__c, Obra_civil_vallado__c, Instalacion_exterior__c, Equipos_exterior__c 
                              from Deposito__c where Presupuesto__c = :idOferta order by Cantidad__c];
                    for(Deposito__c dep : listDepositos)
                    {
                        depositosNombres += dep.Cantidad__c+' x '+ dep.Name + ', ';
                        /*if( eq.Equipos_interior__c != null && eq.Cantidad__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(eq.Equipos_interior__c) * Integer.valueOf(eq.Cantidad__c);
                        if(eq.Instalacion_exterior__c != null && eq.Cantidad__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(eq.Instalacion_exterior__c) * Integer.valueOf(eq.Cantidad__c);
                        if(eq.Instalacion_interior__c != null && eq.Cantidad__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(eq.Instalacion_interior__c) * Integer.valueOf(eq.Cantidad__c);*/
                    }
                    if(String.isNotBlank(depositosNombres))
                    {
                        depositosNombres = depositosNombres.substring(0, depositosNombres.length()-2);
                    }


                    if(String.isBlank(oferta.Tramo_escalado_a_aplicar__c))
                    {
                        listTramos = [select Id, Name, Porcentaje_desde__c, Porcentaje_hasta__c, Consumo_desde_Kg__c, Dto_Kg__c, Precio_HOY_Kg__c, Prima_servicios_A__c 
                                from Tramo__c where Presupuesto__c = :idOferta and RecordTypeId = :Util.objectsRecordTypesMap.get('Tramo__c').get('Tramo_escalado').Id order by Porcentaje_desde__c desc];          
                    }
                    else
                    {
                        listTramos = [select Id, Name, Porcentaje_desde__c, Porcentaje_hasta__c, Consumo_desde_Kg__c, Dto_Kg__c, Precio_HOY_Kg__c, Prima_servicios_A__c 
                                        from Tramo__c where Id=: oferta.Tramo_escalado_a_aplicar__c];
                    }
                    //Cambios rfernandez (20/01/2017)
                    System.debug('Lista de tramos: '+listTramos);
                    numTramos = (listTramos.size() * 34) + 42;
                    numTramos2 = listTramos.size();
                    for(Tramo__c tramo: listTramos)
                    {
                        System.debug('Tramo: '+tramo);
                        if((tramo.Porcentaje_desde__c != null && Integer.valueOf(tramo.Porcentaje_desde__c )<= 100) && 
                            (tramo.Porcentaje_hasta__c != null && Integer.valueOf(tramo.Porcentaje_hasta__c ) >= 100))
                        {
                            tramoMedio = tramo.Prima_servicios_A__c/12;
                            nombreTramoMedio = tramo.Name;
                            System.debug('Tramo medio: '+tramoMedio);
                        }
                    }

                    //Fin cambios rfernandez (20/01/2017)
                    existenTramos = (listTramos != null && !listTramos.isEmpty());
                   
                    fechaHoy = Date.today();

                    listEquiposAjuste = [select Id, Name, Equipos_interior__c, Instalacion_exterior__c, Instalacion_interior__c, Cantidad__c 
                                            from Equipo_ajuste__c where Presupuesto__c = :idOferta];
                    for(Equipo_ajuste__c eq: listEquiposAjuste)
                    {
                        equiposAjusteNombres += eq.Cantidad__c+' x '+ eq.Name + ', ';
                        /*if( eq.Equipos_interior__c != null && eq.Cantidad__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(eq.Equipos_interior__c) * Integer.valueOf(eq.Cantidad__c);
                        if(eq.Instalacion_exterior__c != null && eq.Cantidad__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(eq.Instalacion_exterior__c) * Integer.valueOf(eq.Cantidad__c);
                        if(eq.Instalacion_interior__c != null && eq.Cantidad__c != null)
                            costeTotalInstalacionAux += Integer.valueOf(eq.Instalacion_interior__c) * Integer.valueOf(eq.Cantidad__c);*/
                    }
                    if(String.isNotBlank(equiposAjusteNombres))
                    {
                        equiposAjusteNombres = equiposAjusteNombres.substring(0, equiposAjusteNombres.length()-2);
                    }

                    //costeTotalInstalacion = costeTotalInstalacionAux.format();
                    System.debug('##costeTotalInstalacion '+costeTotalInstalacion);

                    //Integer inversionPrimagasAux = costeTotalInstalacionAux;
                    
                    Integer pagoInicial = 0;
                    Integer cuota = 0;
                    pagoEnCuotas = '';
                    if(oferta.Pago_inicial_inversion__c != null)
                    {
                        pagoInicial = Integer.valueOf(oferta.Pago_inicial_inversion__c);
                    }

                    if(oferta.Duracion_cuota_inversion__c != null && oferta.Cuota_inversion__c != null)
                    {
                        cuota = Integer.valueOf((oferta.Duracion_cuota_inversion__c * oferta.Cuota_inversion__c));
                    }

                    pagoEnCuotas = (oferta.Cuota_inversion__c/12).setScale(2)+' €/mes x '+oferta.Duracion_cuota_inversion__c*12+' meses';
                    costeCliente = cuota + pagoInicial;

                    if(costeCliente != 0)
                    {
                        hayCosteCliente = true;
                    }
                    //Cambios rfernandez (26/01/2017)
                    //A la inversion que asume primagas, se le suma el coste de los depositos asociados a la oferta
                    //Cambios rfernandez (07/02/2017)
                    //Ahora han pedido que no se sume el coste del depósito
                    /*inversionPrimagasAux = inversionPrimagasAux;// + costeDepositos;
                    inversionPrimagas = inversionPrimagasAux.format();
                    System.debug('##InversionPrimagas '+inversionPrimagas);
                    if (inversionPrimagasAux < 0)
                    {
                        inversionPrimagas = '0';
                    }*/
                    //Decimal inversionPrimagasDec =  oferta.Total_inversion__c - pagoInicial - cuota;
                    

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

                    inversionPrimagas = oferta.Total_inversion__c - costeCliente;
                    costeTotalInstalacion = oferta.Total_inversion__c;

                    if(inversionPrimagas < 0)
                    {
                        inversionPrimagas = 0;
                    }

                    listPacks = Pack__c.getAll().values();
                    if(listPacks != null)
                    {
                        listServiciosIncluidos = new List<String>();
                        for(Pack__c p : listPacks)
                        {
                            if(p.Activo__c && p.Nombre__c == oferta.Tipo_Primaservicios__c)
                            {
                                listServiciosPack = ServiciosPacks__c.getAll().values();
                                for(ServiciosPacks__c sp : listServiciosPack)
                                {
                                    if(sp.Numero_de_pack__c == p.Numero_de_pack__c && sp.Incluido__c)
                                    {
                                        listServiciosIncluidos.add(sp.Nombre__c);
                                    }
                                }
                                break;
                            }
                        }
                        Integer numeroServicios = listServiciosIncluidos.size();
                        Integer alturaServicios = 27*numeroServicios;
                        alturaPrimaservicios = String.valueOf(alturaServicios)+'px';
                        System.debug('##listServiciosIncluidos: ' + listServiciosIncluidos);
                    }

                    // cálculos para el gráfico final
                    if(oferta.Importe_total_primagas_numeric__c != null && oferta.Importe_total_numeric__c != null && 
                        Integer.valueOf(oferta.Importe_total_numeric__c) != 0)
                    {
                        System.debug('##Dentro de calculos del gráfico');

                        altoBarraGrafico = OfertaPersonalizadaPDFController.ALTO_MAXIMO_BARRA_GRAFICO;
                        altoBarraPrimagasGrafico = Integer.valueOf((oferta.Importe_total_primagas_numeric__c * altoBarraGrafico) / oferta.Importe_total_numeric__c);
                        if(altoBarraPrimagasGrafico < OfertaPersonalizadaPDFController.ALTO_MINIMO_BARRA_GRAFICO)
                        {
                            altoBarraPrimagasGrafico = OfertaPersonalizadaPDFController.ALTO_MINIMO_BARRA_GRAFICO;
                        }
                        else
                        {
                            if(altoBarraPrimagasGrafico > altoBarraGrafico -38)
                                altoBarraPrimagasGrafico = altoBarraGrafico-38;
                        }
                        
                        posYBarraGrafico = OfertaPersonalizadaPDFController.ALTURA_DISPONIBLE_BARRAS_GRAFICOS - altoBarraGrafico;
                        posYBarraPrimagasGrafico = OfertaPersonalizadaPDFController.ALTURA_DISPONIBLE_BARRAS_GRAFICOS - altoBarraPrimagasGrafico;
                    }
                    System.debug('##Fin controlador');
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción en OfertaPersonalizadaPDF: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber() );
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
                altura = OfertaPersonalizadaPDFController.ALTURA_MINIMA;
                if(valor != null)
                {
                    altura = Integer.valueOf((valor * OfertaPersonalizadaPDFController.ALTURA_MAXIMA) / mayorValor);
                    if(altura < OfertaPersonalizadaPDFController.ALTURA_MINIMA)
                        altura = OfertaPersonalizadaPDFController.ALTURA_MINIMA;
                }
            }
            catch(Exception ex)
            {
                altura = OfertaPersonalizadaPDFController.ALTURA_MINIMA;
                System.debug('Excepción en OfertaEstandarPDF.EnergiaPDF.calcularAltura: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber() );
            }

            return altura;
        }
    }
}