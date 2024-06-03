public with sharing class OfertaEstandarPDFController
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
    public String listNombresEnergias {get;set;}
    public String consumoContratado {get;set;}
    public List<String> textosOfertasEstandar {get;set;}
    public String urlImagen {get;set;}

    public Integer alturaRellenoKwh {get;set;}
    public Integer alturaRellenoKgCO2 {get;set;}

    public Integer altoBarraGrafico {get;set;}
    public Integer altoBarraPrimagasGrafico {get;set;}
    public Integer posYBarraGrafico {get;set;}
    public Integer posYBarraPrimagasGrafico {get;set;}

    public String comercialNombre {get;set;}
    public String comercialTelefono {get;set;}
    public String comercialEmail {get;set;}

    public String tramosEstandar {get;set;}

    public Boolean hayObservaciones {get;set;}
    public List<String> tramosEstandarList {get;set;}
    public String tramoCorrespondiente {get;set;}
    public String poblacionProvincia {get;set;}
    public Boolean hayPoblacionProvincia {get;set;}
    public String fechaFormateada {get;set;}
    public String fechaVigencia {get;set;}

    public List<OpcionesOfertaSTD__c> listaOfertasCoincidentes {get;set;}
    public List<OpcionesOfertaSTD__c> listadoTramos {get;set;}
    public Integer numTextos {get;set;}
    public Integer numTramos {get;set;}

    public String tramoCorrespondienteTest {get;set;}
    public Decimal precioActual {get;set;}

    public OfertaEstandarPDFController()
    {
        Id idOferta;
        List<Quote> listOfertas;
        Decimal mayorValor;
        List<Energia_actual__c> listEnergiasSF;
        Integer alturaTotalKwh;
        Integer alturaTotalPrimagasKwh;
        Integer alturaTotalKgCO2;
        Integer alturaTotalPrimagasKgCO2;
        EnergiaPDF energiaPDF;

        try
        {
            System.debug('Controller');
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
                                    KWh__c, Litros__c, KgCO2_Primagas__c, KWh_Primagas__c, Diferencia_kgCO2__c, Diferencia_kWh__c, Fecha_vigencia__c, Importe_total__c,
                                    Importe_total_primagas__c, Diferencia_importes_totales__c, Texto_servicio_estandar__c, Pago_inicial__c, Consumo_contratado_kg__c,
                                    Consumo_contratado_L__c, Duracion_contratado__c, Duracion_descuento__c, Dto_Estandar__c, Precio_fecha__c, Precio_Kg__c, Precio_L__c,
                                    Valor_del_servicio_estandar__c, CreatedDate,
                                    Opportunity.Owner.Name, Opportunity.Owner.Phone, Opportunity.Owner.Email,
                                    Importe_total_numeric__c,Diferencia_importes_totales_numeric__c,Importe_total_primagas_numeric__c, Precio_L_numeric__c, Precio_Kg_numeric__c, 
                                    Resolucion_anticipada__c, Tarifa_estandar__c, Status, Observaciones__c, Account.Poblacion_Facturacion__c, Account.Provincia__c,
                                    Account.ShippingCity, Account.ShippingState    
                                     from Quote where Id = :idOferta and RecordTypeId = :Util.objectsRecordTypesMap.get('Quote').get('Oferta_estandar').Id];
                if(listOfertas != null && !listOfertas.isEmpty())
                {
                    oferta = listOfertas.get(0);
                    
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

                    tramosEstandarList = new List<String>();
                    //Fin cambios rfernandez

                    consumoContratado = (oferta.Consumo_contratado_L__c == null ? '' : (String.valueOf(oferta.Consumo_contratado_L__c.format()) + ' l' ) ) 
                                        + ' (' + (oferta.Consumo_contratado_kg__c == null ? '' : (String.valueOf(oferta.Consumo_contratado_kg__c.format()) + ' kg' ) ) + ')';

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

                        listNombresEnergias = '';
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

                            if(energia != null && energia.Tipo_energia__c != null)
                            {
                                listNombresEnergias += energia.Tipo_energia__c + ', ';
                            }

                            energiaPDF = new EnergiaPDF(energia, mayorValor);
                            alturaTotalKwh += energiaPDF.alturaKWH;
                            alturaTotalPrimagasKwh += energiaPDF.alturaKWHPrimagas;
                            alturaTotalKgCO2 += energiaPDF.alturaKgCO2;
                            alturaTotalPrimagasKgCO2 += energiaPDF.alturaKgCO2Primagas;
                            listEnergias.add(energiaPDF);
                        }

                        if(listNombresEnergias.trim().endsWith(','))
                        {
                            listNombresEnergias = listNombresEnergias.substring(0, listNombresEnergias.length() -2);
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
                    numTextos = obtenerTextoOfertasEstandar();

                    // recuperar la imagen a mostrar en el PDF
                    if(oferta != null)
                    {
                        obtenerImagenOferta(oferta.Name);

                        //tramos oferta estandar
                        List<OpcionesOfertaSTD__c> listaOfertasEstandarMaestras = OpcionesOfertaSTD__c.getAll().values();
                        System.debug('##listaOfertasEstandarMaestras: ' + listaOfertasEstandarMaestras);
                        if(listaOfertasEstandarMaestras!=null && listaOfertasEstandarMaestras.size()>0)
                        {
                            listaOfertasCoincidentes = new List<OpcionesOfertaSTD__c>();
                            for(OpcionesOfertaSTD__c oe: listaOfertasEstandarMaestras)
                            {
                                if(oe.Oferta__c==oferta.Name && oe.OpcInterior__c==oferta.Interior_estandar__c && oe.OpcExterior__c==oferta.Exterior_estandar__c && oe.OpcServicio__c==oferta.Servicio_estandar__c)
                                {
                                    listaOfertasCoincidentes.add(oe);
                                }
                            }
                            System.debug('##listaOfertasCoincidentes: ' + listaOfertasCoincidentes);
                            if(listaOfertasCoincidentes!=null && listaOfertasCoincidentes.size()>0)
                            {
                                List<String> listaTramosEstandar = new List<String>();
                                //cambios rfernandez
                                //Obtengo una lista ordenada de los valores Desde__c 
                                List<Integer> valoresDesde = new List<Integer>();

                                for(OpcionesOfertaSTD__c oe : listaOfertasCoincidentes)
                                {
                                    valoresDesde.add(Integer.valueOf(oe.Desde__c));
                                }
                                System.debug('Valores desde: '+valoresDesde);
                                for(Integer i = 0 ; i < valoresDesde.size() ; i ++) 
                                {
                                    for(integer j = i+1 ; j <= valoresDesde.size() -1 ; j ++ )
                                    {
                                        integer x = 0 ;
                                        if(valoresDesde[i] >  valoresDesde[j])
                                        {
                                            x = valoresDesde[i]  ;
                                            valoresDesde[i] = valoresDesde[j]  ;
                                            valoresDesde[j]  = x;
                                        }
                                    }
                                }
                                System.debug('Valores desde: '+valoresDesde);
                                
                                //Cambios rfernandez (21/02/2017)
                                //Calculo del tramo que corresponde al cliente para ser marcado en negrita
                                Decimal kilosContratados = oferta.Kg__c;
                                tramoCorrespondiente = '';
                                //Fin cambios rfernandez
                                
                                String tramoReserva = '';
                                String tramoReserva2 = ''; 
                                String nombreTarifa = '';    
                                for(Integer integ: valoresDesde) //Todo esto hay que limpiarlo para los nuevos pdf. No he tenido tiempo
                                {
                                    System.debug('##integ: '+integ);
                                    for(OpcionesOfertaSTD__c oe : listaOfertasCoincidentes)
                                    {
                                        System.debug('##oe: '+oe.Desde__c);
                                        
                                        if(oe.Desde__c.equals(String.valueOf(integ)))
                                        {
                                            nombreTarifa = oe.Tarifa__c;
                                            listaTramosEstandar.add('Desde ' + oe.Desde__c + ' kg/año, Tarifa ' + oe.Tarifa__c + ' con DTO ' + String.valueOf(oe.Dto_E_Kg__c).replace('.',',') 
                                        + ' €/kg durante ' + oe.DuracionDto__c.intValue() + ' años, Cuota de ' + String.valueOf(oe.CuotaMensual__c).replace('.',',')  + ' €/mes.\n');

                                            if(kilosContratados >= Decimal.valueOf(oe.Desde__c))
                                            {
                                                tramoCorrespondiente = 'Desde ' + oe.Desde__c + ' kg/año, Tarifa ' + oe.Tarifa__c + ' con DTO ' + String.valueOf(oe.Dto_E_Kg__c).replace('.',',') 
                                        + ' €/kg durante ' + oe.DuracionDto__c.intValue() + ' años, Cuota de ' + String.valueOf(oe.CuotaMensual__c).replace('.',',')  + ' €/mes.\n';

                                                tramoCorrespondienteTest = oe.Desde__c;
                                            }else if((kilosContratados < Decimal.valueOf(oe.Desde__c)) && String.isBlank(tramoReserva))
                                            {
                                                tramoReserva = 'Desde ' + oe.Desde__c + ' kg/año, Tarifa ' + oe.Tarifa__c + ' con DTO ' + String.valueOf(oe.Dto_E_Kg__c).replace('.',',') 
                                        + ' €/kg durante ' + oe.DuracionDto__c.intValue() + ' años, Cuota de ' + String.valueOf(oe.CuotaMensual__c).replace('.',',')  + ' €/mes.\n';
                                                 tramoReserva2 = oe.Desde__c;
                                            }
                                            break;
                                        }
                                        System.debug('##listaTramosEstandar: '+listaTramosEstandar);
                                    }   
                                }

                                List<NivelesPbModular__c> preciosActuales = [Select Precio_E_Kg__c from NivelesPbModular__c Where NombreTarifa__c =: nombreTarifa];
                                precioActual = preciosActuales[0].Precio_E_Kg__c;

                                if(String.isBlank(tramoCorrespondiente))
                                {
                                    tramoCorrespondiente = tramoReserva;
                                    tramoCorrespondienteTest = tramoReserva2;
                                }
                                System.debug('##listaTramosEstandar: '+listaTramosEstandar);
                                tramosEstandarList = listaTramosEstandar;//Cambios rfernandez (20/02/2017) Para poder meterlos 1 por línea
                                //listaTramosEstandar.sort(); //Lo he comentado para que salga ordenado
                                //System.debug('##listaTramosEstandar: ' + listaTramosEstandar);
                                tramosEstandar = '';
                                for(Integer i=listaTramosEstandar.size()-1; i>=0; i--)
                                {
                                    tramosEstandar += listaTramosEstandar[i];
                                }
                                System.debug('##tramosEstandar: ' + tramosEstandar);

                                listadoTramos = new List<OpcionesOfertaSTD__c>();
                                for(Integer integ: valoresDesde) 
                                {
                                    for(OpcionesOfertaSTD__c oe : listaOfertasCoincidentes)
                                    {
                                        if(oe.Desde__c.equals(String.valueOf(integ)))
                                        {
                                            listadoTramos.add(oe);
                                        }
                                    }   
                                }



                            }





                        }

                         if(numTotalEnergias == 1)
                        {
                            alturaEspacioTabla = 0;
                        }else if (numTotalEnergias == 2)
                        {
                            alturaEspacioTabla = 140;
                        }else {
                             alturaEspacioTabla = 0;
                        }
                        

                        numTramos = (listaOfertasCoincidentes.size() * 34) + 10;

                        // cálculos para el gráfico final
                        if(oferta.Importe_total_primagas_numeric__c != null && oferta.Importe_total_numeric__c != null)
                        {
                            altoBarraGrafico = OfertaEstandarPDFController.ALTO_MAXIMO_BARRA_GRAFICO;

                            //(jivalle) 23/12/2019 - Si el importe de la oferta viene a 0, no realizamos la división
                            if(oferta.Importe_total_numeric__c == 0)
                            {
                                altoBarraPrimagasGrafico = Integer.valueOf((oferta.Importe_total_primagas_numeric__c * altoBarraGrafico));
                            }
                            else
                            {
                                altoBarraPrimagasGrafico = Integer.valueOf((oferta.Importe_total_primagas_numeric__c * altoBarraGrafico) / oferta.Importe_total_numeric__c);
                            }
                            //altoBarraPrimagasGrafico = Integer.valueOf((oferta.Importe_total_primagas_numeric__c * altoBarraGrafico) / oferta.Importe_total_numeric__c);
                            if(altoBarraPrimagasGrafico < OfertaEstandarPDFController.ALTO_MINIMO_BARRA_GRAFICO)
                            {
                                altoBarraPrimagasGrafico = OfertaEstandarPDFController.ALTO_MINIMO_BARRA_GRAFICO;
                            }
                            else
                            {
                                if(altoBarraPrimagasGrafico > altoBarraGrafico -38)
                                    altoBarraPrimagasGrafico = altoBarraGrafico-38;
                            }
                            
                            posYBarraGrafico = OfertaEstandarPDFController.ALTURA_DISPONIBLE_BARRAS_GRAFICOS - altoBarraGrafico;
                            posYBarraPrimagasGrafico = OfertaEstandarPDFController.ALTURA_DISPONIBLE_BARRAS_GRAFICOS - altoBarraPrimagasGrafico;
                        }

                        
                    }
                    
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción en OfertaEstandarPDF: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber() );
        }
    }

    private Integer obtenerTextoOfertasEstandar(){
        textosOfertasEstandar = new List<String>();
        for(TextoOfertasEstandar__c customSetting:TextoOfertasEstandar__c.getAll().values())
        {
            if(customSetting.Activo__c && oferta.Name.equals(customSetting.Oferta__c) &&
             (oferta.Servicio_estandar__c == customSetting.Tipo__c ||
              oferta.Interior_estandar__c == customSetting.Tipo__c ||
               oferta.Exterior_estandar__c == customSetting.Tipo__c))
            {
                textosOfertasEstandar.add(customSetting.TextoOferta__c);
            }
        }

        return textosOfertasEstandar.size();
    }

    private void obtenerImagenOferta(String nombreOferta)
    {
        List<ImagenesOferta__c> listImagenesOferta;
        List<Document> listDocumentos;
        ImagenesOferta__c imgOferta;
        Document documento;
        String documentoId;
        try
        {
            if(!String.isBlank(nombreOferta))
            {
                listImagenesOferta = [select ImagenBase64__c from ImagenesOferta__c where Oferta__c = :nombreOferta];
                System.debug('##listImagenesOferta: '+listImagenesOferta);
                if(listImagenesOferta != null && !listImagenesOferta.isEmpty())
                {
                    imgOferta = listImagenesOferta.get(0);
                    if(imgOferta != null && !String.isBlank(imgOferta.ImagenBase64__c))
                    {
                        listDocumentos = [select Id from Document where DeveloperName =:imgOferta.ImagenBase64__c];
                        System.debug('##listDocumentos: '+listDocumentos);

                        if(listDocumentos == null || listDocumentos.isEmpty())
                        {
                            System.debug('OfertaEstandarPDF.obtenerImagenOferta: No se ha recuperado documento para el nombre: ' + imgOferta.ImagenBase64__c );
                        }
                        else
                        {
                            documento = listDocumentos.get(0);
                            documentoId = String.valueOf(documento.Id).substring(0,15);
                            urlImagen = '/servlet/servlet.FileDownload?file=' + documentoId;
                            System.debug('Nombre: ' + imgOferta.ImagenBase64__c + ' - urlImagen: ' + urlImagen );
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.debug('Excepción en OfertaEstandarPDF.obtenerImagenOferta: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber() );
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
                altura = OfertaEstandarPDFController.ALTURA_MINIMA;
                if(valor != null)
                {
                    altura = Integer.valueOf((valor * OfertaEstandarPDFController.ALTURA_MAXIMA) / mayorValor);
                    if(altura < OfertaEstandarPDFController.ALTURA_MINIMA)
                        altura = OfertaEstandarPDFController.ALTURA_MINIMA;
                }
            }
            catch(Exception ex)
            {
                altura = OfertaEstandarPDFController.ALTURA_MINIMA;
                System.debug('Excepción en OfertaEstandarPDF.EnergiaPDF.calcularAltura: ' + ex.getMessage() + ' - Line: ' + ex.getLineNumber() );
            }

            return altura;
        }
    }
}