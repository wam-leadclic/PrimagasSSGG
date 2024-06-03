//gserrano 10/12/2018 ==> cambios relacionados con las custom settings imagenesOferta y opcionesOfertaSTD, 
//en los wrappers y constructores por la eliminacion y adición de campos respectivamente

@RestResource(urlMapping='/DatosMaestros/*')
global class WSDatosMaestros {

	@HttpPost
	webservice static String getDatosMaestros(PeticionDatosMaestros peticion)
	{
		System.debug('JSON: ' + peticion);
		Respuesta r = new Respuesta();
		String jRespuesta = '';

		DatosMaestros datosMaestros;
		String idioma;
		DateTime fechaUltimaDescarga;
		String provincia;
		String usuarioLogueado;
		List<ConfiguracionBase_NewSales__c> listaConfiguracionBase;
		List<Listas_de_seleccion__c> listasSeleccion;
		List<PreciosKE__c> listaPreciosKE;
		List<NivelesPB__c> listaNivelesPb;
		List<NivelesPbModular__c> listaNivelesPbModular;
		List<ServiciosActividad__c> listaServicioActividad;
		List<Pack__c> listaPacks;
		List<ServiciosPacks__c> listaServiciosPack;
		List<DepositosMaestros__c> listaDepositos;
		List<DepositosRecomendados__c> listaDepositosRecomendados;
		List<CambioRendimientoAsociado__c> listaCambiosRendimientoAsociados;
		List<EnergiaUnidades__c> listaEnergiaUnidades;
		List<OpcionesFinanciacion__c> listaOpcionesFinanciacion;
		List<ImagenesOferta__c> listaImagenesOferta;
		List<OpcionesOfertaSTD__c> listaOpcionesOfertaSTD;
		List<TextoOfertasEstandar__c> listaTextosOfertaEstandar;
		List<TarifasModulares__c> listaTarifasModulares;
		List<OpcionesPbiTramosC__c> listaOpcionesPbiTramosC;
		List<EquiposUsos__c> listaEquiposUsos;
		List<Account> listaColaboradores;
		List<LimiteInversionPb__c> listaLimiteInversionPb;
		String[] usos;
		List<Uso> listaUsos;
		List<CostesLegalizacionProvincia__c> listaCostesLegProvincia;
		List<CostesMantenimientoProvincia__c> listaCostesMtoProvincia;
		Map<Decimal, PackServicio> mapPacks;
		Map<Decimal, List<Servicio>> mapServiciosPack;
		List<Servicio> listaServiciosPackAux;
		List<CostesOtrosEquipos__c> listaCostesOtrosEquipos;
		List<ServicioCosteExtra__c> listaServiciosCosteExtra;
		List<ServicioCosteExtra> listaServiciosCosteExtraAux;
		Map<String, List<ServicioCosteExtra>> mapServiciosCosteExtra;
		Map<String, Boolean> mapCosteExtraActivo; // mapa para determinar si la agrupación de servicios de coste extra está activa o no
		List<Listas_de_seleccion__c> listProvincias;
		String nameProvincia;
		Set<Decimal> setNumPacks;
		PackServicio packServicioAux;
		Pack__c packAux;
		String idPack1;
		String idPack2;
		String idPack3;
		Integer anyo;
        Integer mes;
        Integer dia;
        Integer hora;
        Integer minuto;
        Integer segundo;
		try
		{
			if(peticion == null || peticion.datosMaestros == null )
			{
				fechaUltimaDescarga = DateTime.now().addYears(-100); // fecha muy antigua para asegurar la descarga de todo
				idioma = 'ES';
				provincia = '';
				usuarioLogueado = '';
			}
			else
			{
				datosMaestros = peticion.datosMaestros;

				if(String.isNotBlank(datosMaestros.timestamp) && datosMaestros.timestamp.length() >= 15)
				{
					anyo = Integer.valueOf(datosMaestros.timestamp.substring(0,4));
                    mes = Integer.valueOf(datosMaestros.timestamp.substring(4,6));
                    dia = Integer.valueOf(datosMaestros.timestamp.substring(6,8));
                    hora = Integer.valueOf(datosMaestros.timestamp.substring(9,11));
                    minuto = Integer.valueOf(datosMaestros.timestamp.substring(11,13));
                    segundo = Integer.valueOf(datosMaestros.timestamp.substring(13));
					fechaUltimaDescarga = DateTime.newInstance(anyo,mes,dia,hora,minuto,segundo);
				}
				else
					fechaUltimaDescarga = DateTime.now().addYears(-100); // fecha muy antigua para asegurar la descarga de todo

				System.debug('fechaUltimaDescarga: ' + fechaUltimaDescarga);

				provincia = datosMaestros.provincia;
				usuarioLogueado = datosMaestros.usuarioLogueado;

				idioma = datosMaestros.idioma;
				if(String.isBlank(idioma))
					idioma = 'ES';
				else
					idioma = idioma.toUpperCase();
 			}
 			if(String.isBlank(idioma) || fechaUltimaDescarga == null)
 			{
 				r.resultado.codigo = '401';
				r.resultado.texto = Label.WSError_401;
                LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSDatosMaestros', 'Error', true);
 			}
 			else
 			{
 				if(String.isBlank(provincia))
				{
					// recuperar datos maestros no relacionados con provincias
					// configuracionBase = ConfiguracionBase_NewSales__c
					listaConfiguracionBase = [select Id, Name, Valor__c from ConfiguracionBase_NewSales__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaConfiguracionBase != null)
					{
						for(ConfiguracionBase_NewSales__c conf : listaConfiguracionBase)
						{
							if(conf!=null)
							{
								r.configuracionBase.add(new ConfiguracionBase(String.valueOf(conf.Id), conf.Name, conf.Valor__c));
							}
						}
					}

					// desplegables = Listas_de_seleccion__c
					listasSeleccion = [select Name, Identificador__c, Activo__c, Valor__c from Listas_de_seleccion__c where Idioma__c = :idioma and LastModifiedDate > :fechaUltimaDescarga];
					if(listasSeleccion != null)
					{
						for(Listas_de_seleccion__c ls : listasSeleccion)
						{
							if(ls != null)
							{
								r.desplegables.add(new Desplegable(String.valueOf(ls.Name), ls.Identificador__c, ls.Valor__c, ls.Activo__c));
							}
						}
					}

					// preciosKE = PreciosKE__c
					listaPreciosKE = [select Id, Precio__c, K__c, Activo__c from PreciosKE__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaPreciosKE != null)
					{
						for(PreciosKE__c pke : listaPreciosKE)
						{
							if(pke != null )
							{
								r.preciosKE.add(new PreciosKE(String.valueOf(pke.Id), pke.Precio__c, pke.K__c, pke.Activo__c));
							}
						}
					}

					// tarifasModulares = TarifasModulares__c
					listaTarifasModulares = [select Id, K1__c, K2__c, K3__c, K4__c, TR__c, Provincia__c, Activo__c from TarifasModulares__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaTarifasModulares != null)
					{
						for(TarifasModulares__c tarifa : listaTarifasModulares)
						{
							if(tarifa != null)
							{
								r.tarifasModulares.add(new TarifaModular(String.valueOf(tarifa.Id), tarifa.Provincia__c, String.valueOf(tarifa.K1__c), String.valueOf(tarifa.K2__c), String.valueOf(tarifa.K3__c), String.valueOf(tarifa.K4__c), String.valueOf(tarifa.TR__c), tarifa.Activo__c));
							}
						}
					}

					// nivelesPB = NivelesPB__c
					listaNivelesPb = [select Id, Name, Valor__c, Activo__c from NivelesPB__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaNivelesPb != null)
					{
						for(NivelesPB__c nivel : listaNivelesPb)
						{
							if(nivel != null)
							{
								r.nivelesPB.add(new NivelPB(String.valueOf(nivel.Id), nivel.Name, String.valueOf(nivel.Valor__c), nivel.Activo__c));
							}
						}
					}

					// nivelesPBModular = NivelesPbModular__c
					listaNivelesPbModular = [select Id, Actividad__c, NombreTarifa__c, Origen__c, Precio_E_Kg__c, Precio_E_l__c, Activo__c from NivelesPbModular__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaNivelesPbModular != null)
					{
						for(NivelesPbModular__c nivel : listaNivelesPbModular )
						{
							if(nivel != null)
							{
								r.nivelesPBModular.add(new NivelPBModular(String.valueOf(nivel.Id), nivel.Origen__c, nivel.NombreTarifa__c, nivel.Actividad__c, String.valueOf(nivel.Precio_E_Kg__c), String.valueOf(nivel.Precio_E_l__c), nivel.Activo__c));
							}
						}
					}

					// packsActividad = ServiciosActividad__c
					listaServicioActividad = [select Id, Actividad__c, MOSTRAR1__c, MOSTRAR2__c, MOSTRAR3__c, Activo__c from ServiciosActividad__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaServicioActividad != null)
					{
						for(ServiciosActividad__c serAct : listaServicioActividad)
						{
							if(serAct != null)
							{
								r.packsActividad.add(new PackActividad(String.valueOf(serAct.Id), serAct.Actividad__c, serAct.MOSTRAR1__c, serAct.MOSTRAR2__c, serAct.MOSTRAR3__c, serAct.Activo__c));
							}
						}
					}

					//packsServicio = Pack__c y servicio = ServiciosPacks__c
					mapPacks = new Map<Decimal, PackServicio>();
					listaPacks = [select Id, ConsumoMax__c, ImporteMensual__c, Nombre__c, Numero_de_pack__c, Activo__c, Name from Pack__c where LastModifiedDate > :fechaUltimaDescarga];
					system.debug('listaPacks: ' + listaPacks);
					if(listaPacks != null)
					{
						for(Pack__c pack : listaPacks)
						{
							if(!mapPacks.containsKey(pack.Numero_de_pack__c))
							{
								mapPacks.put(pack.Numero_de_pack__c, new PackServicio(pack.Name, pack.Nombre__c, String.valueOf(pack.ConsumoMax__c), String.valueOf(pack.ImporteMensual__c), null, pack.Activo__c));
							}
						}
					}
					system.debug('mapPacks: ' + mapPacks);

					setNumPacks = new Set<Decimal>();//cambio rfernandez(23/01/2017) //Cascaba al intentar hacer a query, ya que se inicializaba mas tarde el set.
					if( mapPacks == null || mapPacks.keySet() == null )
					{
						System.debug('Caso 1');
						listaServiciosPack = [select Name, Nombre__c, Importe_mensual__c, Incluido__c, Equipos_instalar__c, Numero_de_pack__c, Orden_de_visualizacion__c from ServiciosPacks__c where LastModifiedDate > :fechaUltimaDescarga];
						//System.debug('Caso 1.1');
					}
					else
					{
						//cambio rfernandez(23/01/2017) Antes directamente en este else se hacia la segunda query sin comprobar setNumPacks
						System.debug('Caso 2: '+fechaUltimaDescarga);
						if(setNumPacks.isEmpty())
						{
							listaServiciosPack = [select Name, Nombre__c, Importe_mensual__c, Incluido__c, Equipos_instalar__c, Numero_de_pack__c, Orden_de_visualizacion__c from ServiciosPacks__c where LastModifiedDate > :fechaUltimaDescarga];
						}else{
							listaServiciosPack = [select Name, Nombre__c, Importe_mensual__c, Incluido__c, Equipos_instalar__c, Numero_de_pack__c, Orden_de_visualizacion__c from ServiciosPacks__c where LastModifiedDate > :fechaUltimaDescarga or Numero_de_pack__c = :setNumPacks];
						}
					}
					
					System.debug('listaServiciosPack: ' + listaServiciosPack);

					if(listaServiciosPack != null)
					{
						mapServiciosPack = new Map<Decimal, List<Servicio>>();
						//setNumPacks = new Set<Decimal>(); //cambio rfernandez(23/01/2017)
						for(ServiciosPacks__c serv : listaServiciosPack)
						{
							if(serv != null && serv.Numero_de_pack__c != null)
							{
								if(mapServiciosPack.containsKey(serv.Numero_de_pack__c))
								{
									listaServiciosPackAux = mapServiciosPack.remove(serv.Numero_de_pack__c);
									if(listaServiciosPackAux == null)
										listaServiciosPackAux = new List<Servicio>();
								}
								else
								{
									listaServiciosPackAux = new List<Servicio>();
								}
								listaServiciosPackAux.add(new Servicio(serv.Name, serv.Nombre__c, String.valueOf(serv.Importe_mensual__c), (serv.Incluido__c ? '1' : '0'), serv.Equipos_instalar__c, String.valueOf(serv.Orden_de_visualizacion__c)));
								mapServiciosPack.put(serv.Numero_de_pack__c, listaServiciosPackAux);

								// comprobar si en el map de packs existe pack par ese número_de_pack
								if(!mapPacks.containsKey(serv.Numero_de_pack__c))
								{
									setNumPacks.add(serv.Numero_de_pack__c);
								}
							}
						}
						
						if(setNumPacks != null && !setNumPacks.isEmpty() )
						{
							listaPacks = [select Id, ConsumoMax__c, ImporteMensual__c, Nombre__c, Numero_de_pack__c, Activo__c, Name from Pack__c where Numero_de_pack__c = :setNumPacks];
							if(listaPacks != null)
							{
								for(Pack__c pack : listaPacks)
								{
									if(!mapPacks.containsKey(pack.Numero_de_pack__c))
									{
										mapPacks.put(pack.Numero_de_pack__c, new PackServicio(pack.Name, pack.Nombre__c, String.valueOf(pack.ConsumoMax__c), String.valueOf(pack.ImporteMensual__c), null, pack.Activo__c));
									}
								}
							}
						}

						// asociar servicios a packs en entidad del protocolo
						if(mapPacks != null && mapPacks.keySet() != null)
						{
							for(Decimal numPack : mapPacks.keySet())
							{
								packServicioAux = mapPacks.get(numPack);
								if(packServicioAux != null)
								{
									packServicioAux.servicios = new List<Servicio>(mapServiciosPack.get(numPack));
									r.packsServicio.add(packServicioAux);
								}
							}
						}
					}

					// depositos = DepositosMaestros__c
					listaDepositos = [select Id, Capacidad__c, D__c, Deposito__c, Obra_civil__c, Vallado__c, Memoria__c, Proyecto__c, Instalacion_exterior__c, Desmantelamiento__c, Resolucion_anticipada__c, EsAereo__c, Activo__c from DepositosMaestros__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaDepositos != null)
					{
						for(DepositosMaestros__c depo : listaDepositos)
						{
							if(depo != null)
							{
								r.depositos.add(new Deposito(String.valueOf(depo.Id), depo.Deposito__c, String.valueOf(depo.D__c), String.valueOf(depo.Capacidad__c), String.valueOf(depo.Vallado__c), String.valueOf(depo.Obra_civil__c), String.valueOf(depo.Memoria__c), String.valueOf(depo.Proyecto__c), String.valueOf(depo.Instalacion_exterior__c), String.valueOf(depo.Resolucion_anticipada__c), depo.Desmantelamiento__c, (depo.EsAereo__c == true ? '1' : '0'), depo.Activo__c));
							}
						}
					}

					// depositoRecomendado = DepositosRecomendados__c
					listaDepositosRecomendados = [select Id, Deposito__c, Capacidad_maxima__c, Capacidad_minima__c, Potencia_maxima__c, Potencia_minima__c, Activo__c from DepositosRecomendados__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaDepositosRecomendados != null )
					{
						for(DepositosRecomendados__c depoRec : listaDepositosRecomendados )
						{
							if(depoRec != null )
							{
								r.depositoRecomendado.add(new DepositoRecomendado(String.valueOf(depoRec.Id), depoRec.Potencia_minima__c, depoRec.Potencia_maxima__c, depoRec.Capacidad_minima__c, depoRec.Capacidad_maxima__c, depoRec.Deposito__c, depoRec.Activo__c));
							}
						}
					}

					// cambioRendimientoAsociado = CambioRendimientoAsociado__c
					listaCambiosRendimientoAsociados = [select Id, Energia__c, Cambio__c, Rendimiento__c, Antiguedad_desde__c, Antiguedad_hasta__c, Activo__c from CambioRendimientoAsociado__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaCambiosRendimientoAsociados != null)
					{
						for(CambioRendimientoAsociado__c cambio : listaCambiosRendimientoAsociados)
						{
							if(cambio != null)
							{
								r.cambioRendimientoAsociado.add(new CambioRendimientoAsociado(String.valueOf(cambio.Id), cambio.Energia__c, cambio.Cambio__c, String.valueOf(cambio.Antiguedad_desde__c), String.valueOf(cambio.Antiguedad_hasta__c), String.valueOf(cambio.Rendimiento__c), cambio.Activo__c));
							}
						}
					}

					//energiaUnidades = EnergiaUnidades__c
					listaEnergiaUnidades = [select Id, CO2__c, 	C__c, Energia__c, PCI__c, Unidad_CO2__c, UnidadConsumo__c, Unidad_PCI__c, UnidadPrecio__c, Codigo_tarifa__c, Activo__c from EnergiaUnidades__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaEnergiaUnidades != null)
					{
						for(EnergiaUnidades__c eUnidad : listaEnergiaUnidades)
						{
							if(eUnidad != null)
							{
								r.energiaUnidades.add(new EnergiaUnidad(String.valueOf(eUnidad.Id), eUnidad.Energia__c, eUnidad.UnidadConsumo__c, String.valueOf(eUnidad.PCI__c), eUnidad.Unidad_PCI__c, String.valueOf(eUnidad.CO2__c), eUnidad.Unidad_CO2__c, eUnidad.UnidadPrecio__c, eUnidad.C__c, eUnidad.Codigo_tarifa__c, eUnidad.Activo__c));
							}
						}
					}

					// equiposUsos = EquiposUsos__c
					listaEquiposUsos = [select Id, Equipos__c, Usos__c, Activo__c from EquiposUsos__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaEquiposUsos != null)
					{
						for(EquiposUsos__c equipoUso : listaEquiposUsos)
						{
							if(equipoUso != null)
							{
								if(String.isBlank(equipoUso.Usos__c))
								{
									listaUsos = null;
								} 
								else
								{
									usos = equipoUso.Usos__c.split(';');
									listaUsos = new List<Uso>();
									for(String u : usos)
									{
										listaUsos.add(new Uso(u));
									}
								}
								r.equiposUsos.add( new EquipoUso(String.valueOf(equipoUso.Id), equipoUso.Equipos__c, listaUsos, equipoUso.Activo__c));
							}
						}
					}

					// opcionesFinanciacion = OpcionesFinanciacion__c
					listaOpcionesFinanciacion =[select Id, Cuotas__c, InteresAnual__c, Activo__c from OpcionesFinanciacion__c where LastModifiedDate > : fechaUltimaDescarga];
					if(listaOpcionesFinanciacion != null)
					{
						for(OpcionesFinanciacion__c opcion : listaOpcionesFinanciacion)
						{
							if(opcion != null)
							{
								r.opcionesFinanciacion.add(new OpcionFinanciacion(String.valueOf(opcion.Id), String.valueOf(opcion.Cuotas__c), String.valueOf(opcion.InteresAnual__c), opcion.Activo__c));
							}
						}
					}

					if(String.isNotBlank(usuarioLogueado))
					{
						// opcionesPbiTramosC = OpcionesPbiTramosC__c // limitesInversionPb = LimiteInversionPb__c
						/*Id perfilUsuarioId = UserInfo.getProfileId();
						if(perfilUsuarioId == Constantes.PERFIL_ADMINISTRADOR_SISTEMA) //para el administrador del sistema se descarga sin filtrar por usuario
						{
							listaOpcionesPbiTramosC = [select Id, Actividad__c, DuracionContrato__c, Provincia__c, PBI__c, T1__c, T2__c, T3__c, C__c, Activo__c from OpcionesPbiTramosC__c where LastModifiedDate > :fechaUltimaDescarga];
							listaLimiteInversionPb = [select Name, LimiteIR__c, LimitePB__c, Email__c, Mensaje__c, Activo__c from LimiteInversionPb__c where LastModifiedDate > :fechaUltimaDescarga];
						}
						else
						{*/
							listaOpcionesPbiTramosC = [select Id, Actividad__c, DuracionContrato__c, Provincia__c, PBI__c, T1__c, T2__c, T3__c, C__c, Activo__c from OpcionesPbiTramosC__c where Usuarios__c =:usuarioLogueado and LastModifiedDate > :fechaUltimaDescarga];
							listaLimiteInversionPb = [select Name, LimiteIR__c, LimitePB__c, Email__c, Mensaje__c, Activo__c from LimiteInversionPb__c where Usuario__c = :usuarioLogueado and LastModifiedDate > :fechaUltimaDescarga];
						//}						
						if(listaOpcionesPbiTramosC != null)
						{
							for(OpcionesPbiTramosC__c opc : listaOpcionesPbiTramosC)
							{
								if(opc != null)
								{
									r.opcionesPBiTramosC.add(new OpcionPBITramosC(String.valueOf(opc.Id), opc.Actividad__c, String.valueOf(opc.DuracionContrato__c), opc.Provincia__c, String.valueOf(opc.PBI__c), String.valueOf(opc.T1__c), String.valueOf(opc.T2__c), String.valueOf(opc.T3__c), String.valueOf(opc.C__c), opc.Activo__c));
								}
							}
						}
						if(listaLimiteInversionPb != null)
						{
							for(LimiteInversionPb__c lim : listaLimiteInversionPb)
							{
								if(lim != null)
								{
									r.limitesInversionPb.add(new LimiteInversionPb(String.valueOf(lim.Name), String.valueOf(lim.LimitePB__c), String.valueOf(lim.LimiteIR__c), String.valueOf(lim.Email__c), lim.Mensaje__c, lim.Activo__c));
								}
							}
						}
					}

					// imagenesOferta = ImagenesOferta__c
					listaImagenesOferta = [select Id, Oferta__c, ImagenBase64__c, TramoConsumo__c, Duracion__c, Activo__c from ImagenesOferta__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaImagenesOferta != null)
					{
						for(ImagenesOferta__c img : listaImagenesOferta)
						{
							if(img != null)
							{
								r.imagenesOferta.add(new ImagenOferta(String.valueOf(img.Id), img.Oferta__c, img.ImagenBase64__c, String.valueOf(img.TramoConsumo__c), String.valueOf(img.Duracion__c), img.Activo__c));
							}
						}
					}

					// opcionesOfertaSTD = OpcionesOfertaSTD__c
					listaOpcionesOfertaSTD = [select Id, Name, Oferta__c, CuotaMensual__c, Desde__c, Dto_E_Kg__c, DuracionDto__c, OpcExterior__c, OpcInterior__c, OpcServicio__c, Tarifa__c, PagoInicial__c, InversionSinDeposito__c, Deposito__c, 
												Caldera__c, Contador__c, Quemador__c, Telemedida__c, Nivel_a_distancia__c, Mantenimiento_estandar__c, Inspeccion_interiores_obligatoria_DOM__c, Inspeccion_interiores_obligatoria_PROF__c, Mantenimiento_bianual__c, Activo__c,
                                               //campo añadidos por gserrano 10/12/2018
                                               Imp_inst_ext__c, Imp_inst_int__c, Imp_obra_civil__c, Imp_proyectos__c, Imp_equipos__c, Resolucion_anticipada__c
												from OpcionesOfertaSTD__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaOpcionesOfertaSTD != null )
					{
						for(OpcionesOfertaSTD__c opcionOf : listaOpcionesOfertaSTD)
						{
							if(opcionOf != null)
							{
								r.opcionesOfertaSTD.add(new OpcionOfertaSTD(opcionOf.Name, opcionOf.Oferta__c, opcionOf.OpcInterior__c, opcionOf.OpcExterior__c, opcionOf.OpcServicio__c, opcionOf.Desde__c, opcionOf.Deposito__c, opcionOf.Tarifa__c, String.valueOf(opcionOf.Dto_E_Kg__c), opcionOf.DuracionDto__c, opcionOf.Imp_inst_ext__c, opcionOf.Imp_inst_int__c, opcionOf.Imp_obra_civil__c, opcionOf.Imp_proyectos__c, opcionOf.Imp_equipos__c, opcionOf.Resolucion_anticipada__c, String.valueOf(opcionOf.CuotaMensual__c), String.valueOf(opcionOf.PagoInicial__c), String.valueOf(opcionOf.InversionSinDeposito__c),
														opcionOf.Caldera__c, opcionOf.Contador__c, opcionOf.Quemador__c, opcionOf.Telemedida__c, opcionOf.Nivel_a_distancia__c, opcionOf.Mantenimiento_estandar__c, opcionOf.Inspeccion_interiores_obligatoria_DOM__c, opcionOf.Inspeccion_interiores_obligatoria_PROF__c, opcionOf.Mantenimiento_bianual__c, opcionOf.Activo__c));
							}
						}
					}

					// textosOfertaEstandar = TextoOfertasEstandar__c
					listaTextosOfertaEstandar = [select Id, Oferta__c, TextoOferta__c, Tipo__c, Activo__c from TextoOfertasEstandar__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaTextosOfertaEstandar != null)
					{
						for(TextoOfertasEstandar__c txt : listaTextosOfertaEstandar)
						{
							if( txt!=null)
							{
								r.textosOfertaEstandar.add(new TextoOfertaEstandar(String.valueOf(txt.Id), txt.Oferta__c, txt.Tipo__c, txt.TextoOferta__c, txt.Activo__c));
							}
						}
					}

					// costesLegalizacionProvincia = CostesLegalizacionProvincia__c
					listaCostesLegProvincia = [select Id, Coste__c, Provincia__c, Deposito__c, Activo__c from CostesLegalizacionProvincia__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaCostesLegProvincia != null)
					{
						for(CostesLegalizacionProvincia__c coste : listaCostesLegProvincia)
						{
							if(coste != null)
							{
								r.costesLegalizacionProvincia.add(new CosteLegalizacionProvincia(String.valueOf(coste.Id), coste.Deposito__c, coste.Coste__c, coste.Provincia__c, coste.Activo__c));
							}
						}
					}

					// costesMantenimientoProvincia = CostesMantenimientoProvincia__c
					listaCostesMtoProvincia = [select Id, Coste__c, Deposito__c, Provincia__c, Activo__c from CostesMantenimientoProvincia__c where LastModifiedDate > :fechaUltimaDescarga];
					if(listaCostesMtoProvincia != null )
					{
						for(CostesMantenimientoProvincia__c coste : listaCostesMtoProvincia)
						{
							if(coste != null)
							{
								r.costesMantenimientoProvincia.add(new CosteMantenimientoProvincia(String.valueOf(coste.Id), coste.Deposito__c, coste.Coste__c, coste.Provincia__c, coste.Activo__c));
							}
						}
					}

					// colaboradores = Account (Recordtype = 'Partner' o Recordtype = 'Competidor')
					listaColaboradores = [select Id, Name, Phone, Colaborador_activo__c, RecordTypeId from Account where (RecordTypeId = :Util.objectsRecordTypesMap.get('Account').get('Partner').Id or RecordTypeId = :Util.objectsRecordTypesMap.get('Account').get('Competidor').Id) and LastModifiedDate > :fechaUltimaDescarga];
					if(listaColaboradores != null)
					{
						for(Account acc : listaColaboradores)
						{
							if(acc != null)
							{
								r.colaboradores.add(new Colaborador(String.valueOf(acc.Id), acc.Name, acc.Phone, (acc.RecordTypeId == Util.objectsRecordTypesMap.get('Account').get('Partner').Id ? 'partner' : 'competidor'), acc.Colaborador_activo__c));
							}
						}
					}

					// costesOtrosEquipos = CostesOtrosEquipos__c
					listaCostesOtrosEquipos = [select Id, Name, Descripcion__c, Equipos_exterior__c, Equipos_interior__c, Instalacion_exterior__c, Instalacion_interior__c, Activo__c
													from CostesOtrosEquipos__c where LastModifiedDate >= :fechaUltimaDescarga];
					if(listaCostesOtrosEquipos != null)
					{
						for(CostesOtrosEquipos__c coste : listaCostesOtrosEquipos)
						{
							if(coste != null)
							{
								r.costesOtrosEquipos.add(new CostesOtrosEquipos(coste.Name, coste.Descripcion__c, String.valueOf(coste.Instalacion_exterior__c), String.valueOf(coste.Equipos_exterior__c), String.valueOf(coste.Equipos_interior__c), String.valueOf(coste.Instalacion_interior__c), coste.Activo__c));
							}
						}
					}
				}
				else
				{
					// recuperar customSetting para provincia
					listProvincias = [select Name from Listas_de_seleccion__c where Idioma__c = :idioma and Identificador__c = 'Provincia' and Valor__c = :provincia and LastModifiedDate > :fechaUltimaDescarga];
					if(listProvincias!=null && !listProvincias.isEmpty())
					{
						// sólo debería recuperar 1
						if(listProvincias.get(0) != null)
						{
							nameProvincia = listProvincias.get(0).Name;
						}
					}

					// recuperar datos maestros relacionados con provincias
					// tarifasModulares = TarifasModulares__c
					listaTarifasModulares = [select Id, K1__c,K2__c, K3__c, K4__c, TR__c, Provincia__c, Activo__c from TarifasModulares__c where Provincia__c = : provincia and LastModifiedDate > :fechaUltimaDescarga];
					if(listaTarifasModulares != null)
					{
						for(TarifasModulares__c tarifa : listaTarifasModulares)
						{
							if(tarifa != null)
							{
								r.tarifasModulares.add(new TarifaModular(String.valueOf(tarifa.Id), tarifa.Provincia__c, String.valueOf(tarifa.K1__c), String.valueOf(tarifa.K2__c), String.valueOf(tarifa.K3__c), String.valueOf(tarifa.K4__c), String.valueOf(tarifa.TR__c), tarifa.Activo__c));
							}
						}
					}

					// recuperar datos maestros también relacionados con usuarios
					if(String.isNotBlank(usuarioLogueado))
					{
						// opcionesPbiTramosC = OpcionesPbiTramosC__c
						listaOpcionesPbiTramosC = [select Id, Actividad__c, DuracionContrato__c, Provincia__c, PBI__c, T1__c, T2__c, T3__c, C__c, Activo__c from OpcionesPbiTramosC__c where Provincia__c = :provincia and Usuarios__c =:usuarioLogueado and LastModifiedDate > :fechaUltimaDescarga];
						if(listaOpcionesPbiTramosC != null)
						{
							for(OpcionesPbiTramosC__c opc : listaOpcionesPbiTramosC)
							{
								if(opc != null)
								{
									r.opcionesPBiTramosC.add(new OpcionPBITramosC(String.valueOf(opc.Id), opc.Actividad__c, String.valueOf(opc.DuracionContrato__c), opc.Provincia__c, String.valueOf(opc.PBI__c), String.valueOf(opc.T1__c), String.valueOf(opc.T2__c), String.valueOf(opc.T3__c), String.valueOf(opc.C__c), opc.Activo__c));
								}
							}
						}
					}

					// costesLegalizacionProvincia = CostesLegalizacionProvincia__c
					listaCostesLegProvincia = [select Id, Coste__c, Deposito__c, Provincia__c, Activo__c from CostesLegalizacionProvincia__c where Provincia__c = :provincia and LastModifiedDate > :fechaUltimaDescarga];
					if(listaCostesLegProvincia != null)
					{
						for(CostesLegalizacionProvincia__c coste : listaCostesLegProvincia)
						{
							if(coste != null)
							{
								r.costesLegalizacionProvincia.add(new CosteLegalizacionProvincia(String.valueOf(coste.Id), coste.Deposito__c, coste.Coste__c, coste.Provincia__c, coste.Activo__c));
							}
						}
					}

					// costesMantenimientoProvincia = CostesMantenimientoProvincia__c
					listaCostesMtoProvincia = [select Id, Coste__c, Deposito__c, Provincia__c, Activo__c from CostesMantenimientoProvincia__c where Provincia__c = :provincia and LastModifiedDate > :fechaUltimaDescarga];
					if(listaCostesMtoProvincia != null )
					{
						for(CostesMantenimientoProvincia__c coste : listaCostesMtoProvincia)
						{
							if(coste != null)
							{
								r.costesMantenimientoProvincia.add(new CosteMantenimientoProvincia(String.valueOf(coste.Id), coste.Deposito__c, coste.Coste__c, coste.Provincia__c, coste.Activo__c));
							}
						}
					}
				}

				// costeExtraServicios = ServicioCosteExtra__c
				// Se recupera tanto si se recibe provincia como si no
				if(!String.isBlank(nameProvincia))
				{
					listaServiciosCosteExtra = [select Name, Name_provincia__c, Tipo__c, Coste__c, Descripcion__c, Activo__c from ServicioCosteExtra__c where Name_provincia__c= :nameProvincia and LastModifiedDate > :fechaUltimaDescarga];
				}
				else
				{
					listaServiciosCosteExtra = [select Name, Name_provincia__c, Tipo__c, Coste__c, Descripcion__c, Activo__c from ServicioCosteExtra__c where LastModifiedDate > :fechaUltimaDescarga];
				}
				if(listaServiciosCosteExtra != null)
				{
					mapServiciosCosteExtra = new Map<String, List<ServicioCosteExtra>>();
					mapCosteExtraActivo = new Map<String, Boolean>();
					for(ServicioCosteExtra__c sce : listaServiciosCosteExtra)
					{
						if(!String.isBlank(sce.Name_provincia__c))
						{
							if(mapCosteExtraActivo.containsKey(sce.Name_provincia__c))
							{
								if(sce.Activo__c && !mapCosteExtraActivo.get(sce.Name_provincia__c))
								{
									mapCosteExtraActivo.remove(sce.Name_provincia__c);
									mapCosteExtraActivo.put(sce.Name_provincia__c, true);
								}
							}
							else
							{
								mapCosteExtraActivo.put(sce.Name_provincia__c, sce.Activo__c);
							}
							if(mapServiciosCosteExtra.containsKey(sce.Name_provincia__c))
							{
								listaServiciosCosteExtraAux = mapServiciosCosteExtra.get(sce.Name_provincia__c);
								if(listaServiciosCosteExtraAux == null)
									listaServiciosCosteExtraAux = new List<ServicioCosteExtra>();
							}
							else
							{
								listaServiciosCosteExtraAux = new List<ServicioCosteExtra>();
							}
							listaServiciosCosteExtraAux.add(new ServicioCosteExtra(sce.Name, String.valueOf(sce.Tipo__c), sce.Descripcion__c, String.valueOf(sce.Coste__c), sce.Activo__c));
							mapServiciosCosteExtra.put(sce.Name_provincia__c, listaServiciosCosteExtraAux);
						}
					}
					if(!mapServiciosCosteExtra.isEmpty())
					{
						for(String name : mapServiciosCosteExtra.keySet())
						{
							r.costeExtraServicios.add(new CosteExtraServicios(name, mapServiciosCosteExtra.get(name), mapCosteExtraActivo.get(name)));
						}
					}
				}				

				r.resultado.codigo = '400';
				r.resultado.texto = Label.WSError_400;
			}
		}
		catch(Exception e)
		{
			r.resultado.codigo = '402';
            r.resultado.texto = Label.WSError_402;
            LogUtil.crearLog(r.resultado.texto + ' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'Errores NewSales', 'WSDatosMaestros', 'Error', true);
		}

		try
		{
			jRespuesta = (String)JSON.serialize(r);
		}
		catch(Exception e)
		{
			LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSDatosMaestros', 'Error', true);
		}
		
		return jRespuesta;
	}

	global class PeticionDatosMaestros
	{
		public DatosMaestros datosMaestros {get;set;}
	}

	public class DatosMaestros
	{
		public String idioma {get;set;}
		public String timestamp {get;set;} // timestamp última descarga
		public String usuarioLogueado {get;set;}
		public String provincia {get;set;}
	}

	public class Respuesta
	{	
		public Resultado resultado {get;set;}
		public List<ConfiguracionBase> configuracionBase {get;set;}
		public List<Desplegable> desplegables {get;set;}
		public List<PreciosKE> preciosKE {get;set;}
		public List<TarifaModular> tarifasModulares {get;set;}
		public List<NivelPB> nivelesPB {get;set;}
		public List<NivelPBModular> nivelesPBModular {get;set;}
		public List<PackActividad> packsActividad {get;set;}
		public List<PackServicio> packsServicio {get;set;}
		public List<Deposito> depositos {get;set;}
		public List<DepositoRecomendado> depositoRecomendado {get;set;}
		public List<CambioRendimientoAsociado> cambioRendimientoAsociado {get;set;}
		public List<EnergiaUnidad> energiaUnidades {get;set;}
		public List<EquipoUso> equiposUsos {get;set;}
		public List<OpcionFinanciacion> opcionesFinanciacion {get;set;}
		public List<OpcionPBITramosC> opcionesPbiTramosC {get;set;}
		public List<CosteLegalizacionProvincia> costesLegalizacionProvincia {get;set;}
		public List<CosteMantenimientoProvincia> costesMantenimientoProvincia {get;set;}
		public List<ImagenOferta> imagenesOferta {get;set;}
		public List<OpcionOfertaSTD> opcionesOfertaSTD {get;set;}
		public List<TextoOfertaEstandar> textosOfertaEstandar {get;set;}
		public List<Colaborador> colaboradores {get;set;}
		public List<CostesOtrosEquipos> costesOtrosEquipos {get;set;}
		public List<CosteExtraServicios> costeExtraServicios {get;set;}
		public List<LimiteInversionPb> limitesInversionPb {get;set;}

		public Respuesta()
		{
			resultado = new Resultado();
			configuracionBase = new List<ConfiguracionBase>();
			desplegables = new List<Desplegable>();
			preciosKE = new List<PreciosKE>();
			tarifasModulares = new List<TarifaModular>();
			nivelesPB = new List<NivelPB>();
			nivelesPBModular = new List<NivelPBModular>();
			packsActividad = new List<PackActividad>();
			packsServicio = new List<PackServicio>();
			depositos = new List<Deposito>();
			depositoRecomendado = new List<DepositoRecomendado>();
			cambioRendimientoAsociado = new List<CambioRendimientoAsociado>();
			energiaUnidades = new List<EnergiaUnidad>();
			equiposUsos = new List<EquipoUso>();
			opcionesFinanciacion = new List<OpcionFinanciacion>();
			opcionesPbiTramosC = new List<OpcionPBITramosC>();
			costesLegalizacionProvincia = new List<CosteLegalizacionProvincia>();
			costesMantenimientoProvincia = new List<CosteMantenimientoProvincia>();
			imagenesOferta = new List<ImagenOferta>();
			opcionesOfertaSTD = new List<OpcionOfertaSTD>();
			textosOfertaEstandar = new List<TextoOfertaEstandar>();
			colaboradores = new List<Colaborador>();
			costesOtrosEquipos = new List<CostesOtrosEquipos>();
			costeExtraServicios = new List<CosteExtraServicios>();
			limitesInversionPb = new List<LimiteInversionPb>();
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

	public class ConfiguracionBase
	{
		public String idSalesforce {get;set;}
		public String valor {get;set;}
		public String descripcion {get;set;}		

		public ConfiguracionBase(String pId, String pDesc, String pValor)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.valor = (pValor == null ? '' : pValor);
		}
	}

	public class Desplegable
	{
		public String idSalesforce {get;set;}
		public String tipo {get;set;}
		public String valor {get;set;}
		public Boolean activo {get;set;}

		public Desplegable(String pId, String pTipo, String pValor, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.tipo = (pTipo == null ? '' : pTipo);
			this.valor = (pValor == null ? '' : pValor);
			this.activo = pActivo;
		}
	}

	public class PreciosKE
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public String k {get;set;}
		public Boolean activo {get;set;}

		public PreciosKE(String pId, String pDesc, String pK, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.k = (pK == null ? '' : pK);
			this.activo = pActivo;
		}
	}

	public class TarifaModular
	{
		public String idSalesforce {get;set;}
		public String provincia {get;set;}
		public String k1 {get;set;}
		public String k2 {get;set;}
		public String k3 {get;set;}
		public String k4 {get;set;}
		public String tR {get;set;}
		public Boolean activo {get;set;}

		public TarifaModular(String pId, String pProvincia, String pK1, String pK2, String pK3, String pK4, String pTR, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.provincia = (pProvincia == null ? '' : pProvincia);
			this.k1 = (pK1 == null ? '' : pK1);
			this.k2 = (pK2 == null ? '' : pK2);
			this.k3 = (pK3 == null ? '' : pK3);
			this.k4 = (pK4 == null ? '' : pK4);
			this.tR = (pTR == null ? '' : pTR);
			this.activo = pActivo;
		}
	}

	public class NivelPB
	{
		public String idSalesforce {get;set;}
		public String nivel {get;set;}
		public String valor {get; set;}
		public Boolean activo {get; set;}

		public NivelPB(String pId, String pNivel, String pValor, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.nivel = (pNivel == null ? '' : pNivel);
			this.valor = (pValor == null ? '' : pValor);
			this.activo = pActivo;
		}
	}

	public class NivelPBModular
	{
		public String idSalesforce {get;set;}
		public String origen {get;set;}
		public String nombreTarifa {get;set;}
		public String actividad {get;set;}
		public String precioKg {get;set;}
		public String precioL {get;set;}
		public Boolean activo {get;set;}

		public NivelPBModular(String pId, String pOrigen, String pNombreTarifa, String pActividad, String pPrecioKg, String pPrecioL, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.origen = (pOrigen == null ? '' : pOrigen);
			this.nombreTarifa = (pNombreTarifa == null ? '' : pNombreTarifa);
			this.actividad = (pActividad == null ? '' : pActividad);
			this.precioKg = (pPrecioKg == null ? '' : pPrecioKg);
			this.precioL = (pPrecioL == null ? '' : pPrecioL);
			this.activo = pActivo;
		}
	}

	public class PackActividad
	{
		public String idSalesforce {get;set;}
		public String actividad {get;set;}
		public String pack1 {get;set;} // id Salesforce para el pack1
		public String pack2 {get;set;} // id Salesforce para el pack2
		public String pack3 {get;set;} // id Salesforce para el pack3
		public Boolean activo {get;set;}

		public PackActividad(String pId, String pActividad, String pPack1, String pPack2, String pPack3, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.actividad = (pActividad == null ? '' : pActividad);
			this.pack1 = (pPack1 == null ? '' : pPack1);
			this.pack2 = (pPack2 == null ? '' : pPack2);
			this.pack3 = (pPack3 == null ? '' : pPack3);
			this.activo = pActivo;
		}
	}

	public class PackServicio
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public String consumoMax {get;set;}
		public String importeMes {get;set;}
		public List<Servicio> servicios {get;set;}
		public Boolean activo {get;set;}

		public PackServicio(String pName, String pDesc, String pConsumoMax, String pImporteMes, List<Servicio> pServicios, Boolean pActivo)
		{
			this.idSalesforce = (pName == null ? '' : pName);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.consumoMax = (pConsumoMax == null ? '' : pConsumoMax);
			this.importeMes = (pImporteMes == null ? '' : pImporteMes);
			this.servicios = new List<Servicio>(pServicios);
			this.activo = pActivo;
		}
	}

	public class Servicio
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public String importeMensual {get;set;}
		public String estaIncluido {get;set;}
		public String idEquiposInstalar {get;set;}
		public String ordenVisualizacion {get;set;}

		public Servicio(String pId, String pDesc, String pImporteM, String pEstaInc, String pIdEquiposInst, String pOrdenVisualizacion)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.importeMensual = (pImporteM == null ? '' : pImporteM);
			this.estaIncluido = (pEstaInc == null ? '' : pEstaInc);
			this.idEquiposInstalar = (pIdEquiposInst == null ? '' : pIdEquiposInst);
			this.ordenVisualizacion = (pOrdenVisualizacion == null ? '' : pOrdenVisualizacion);
		}
	}

	public class Deposito
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public String d {get;set;}
		public String capacidadMax {get;set;}
		public String vallado {get;set;}
		public String obraCivil {get;set;}
		public String memoria {get;set;}
		public String proyecto {get;set;}
		public String instalacionExterior {get;set;}
		public String resolucionAnticipada {get;set;}
		public String desmantelamiento {get;set;}
		public String esAereo {get;set;}
		public Boolean activo {get;set;}

		public Deposito(String pId, String pDesc, String pD, String pCapacidad, String pVallado, String pObraCivil, String pMemoria, String pProyecto, String pInstExterior, String pResolucionAnt, String pDesmantelamiento, String pEsAereo, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '': pId);
			this.descripcion = (pDesc == null ? '': pDesc);
			this.d = (pD == null ? '' : pD);
			this.capacidadMax = (pCapacidad == null ? '' : pCapacidad);
			this.vallado = (pVallado == null ? '' : pVallado);
			this.obraCivil = (pObraCivil == null ? '' : pObraCivil);
			this.memoria = (pMemoria == null ? '' : pMemoria);
			this.proyecto = (pProyecto == null ? '' : pProyecto);
			this.instalacionExterior = (pInstExterior == null ? '' : pInstExterior);
			this.resolucionAnticipada = (pResolucionAnt == null ? '' : pResolucionAnt);
			this.desmantelamiento = (pDesmantelamiento == null ? '' : pDesmantelamiento);
			this.esAereo = (pEsAereo == null ? '' : pEsAereo);
			this.activo = pActivo;
		}
	}

	public class DepositoRecomendado
	{
		public String idSalesforce {get;set;}
		public String rangoKW {get;set;}
		public String rangoLitros {get;set;}
		public String deposito {get;set;}
		public Boolean activo {get;set;}

		public DepositoRecomendado(String pId, String pPotenciaMin, String pPotenciaMax, String pCapacidadMin, String pCapacidadMax, String pDeposito, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '': pId);
			this.rangoKW = (pPotenciaMin == null ? '' : pPotenciaMin) + '/' + (pPotenciaMax == null ? '' : pPotenciaMax);
			this.rangoLitros = (pCapacidadMin == null ? '': pCapacidadMin) + '/' + (pCapacidadMax == null ? '' : pCapacidadMax);
			this.deposito = (pDeposito == null ? '': pDeposito);
			this.activo = pActivo;
		}
	}

	public class CambioRendimientoAsociado
	{
		public String idSalesforce {get;set;}
		public String energia {get;set;}
		public String cambio {get; set;}
		public String desde {get;set;}
		public String hasta {get;set;}
		public String rendimiento {get;set;}
		public Boolean activo {get;set;}

		public CambioRendimientoAsociado( String pId, String pEnergia, String pCambio, String pDesde, String pHasta, String pRendimiento, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.energia = (pEnergia == null ? '' : pEnergia);
			this.cambio = (pCambio == null ? '' : pCambio);
			this.desde = (pDesde == null ? '' : pDesde);
			this.hasta = (pHasta == null ? '' : pHasta);
			this.rendimiento = (pRendimiento == null ? '' : pRendimiento);
			this.activo = pActivo;
		}
	}

	public class EnergiaUnidad
	{
		public String idSalesforce {get;set;}
		public String energia {get;set;}
		public String unidadConsumo {get;set;}
		public String pci {get;set;}
		public String unidadPCI {get;set;}
		public String co2 {get;set;}
		public String unidadCO2 {get;set;}
		public String unidadPrecio {get;set;}
		public String c {get;set;}
		public String codigoTarifa {get;set;}
		public Boolean activo {get;set;}

		public EnergiaUnidad( String pId, String pEnergia, String pUnidadConsumo, String pPCI, String pUnidadPCI, String pCO2, String pUnidadCO2, String pUnidadPrecio, String pC, String pCodTarifa, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.energia = (pEnergia == null ? '' : pEnergia);
			this.unidadConsumo = (pUnidadConsumo == null ? '' : pUnidadConsumo);
			this.pci = (pPCI == null ? '' : pPCI);
			this.unidadPCI = (pUnidadPCI == null ? '' : pUnidadPCI);
			this.co2 = (pCO2 == null ? '' : pCO2);
			this.unidadCO2 = (pUnidadCO2 == null ? '' : pUnidadCO2);
			this.unidadPrecio = (pUnidadPrecio == null ? '' : pUnidadPrecio);
			this.c = (pC == null ? '' : pC);
			this.codigoTarifa = (pCodTarifa == null ? '' : pCodTarifa);
			this.activo = pActivo;
		}
	}

	public class EquipoUso
	{
		public String idSalesforce {get;set;}
		public String equipo {get;set;}
		public List<Uso> usos {get;set;}
		public Boolean activo {get;set;}

		public EquipoUso(String pId, String pEquipo, List<Uso> pUsos, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '':  pId);
			this.equipo = (pEquipo == null ? '' : pEquipo);
			this.usos = new List<Uso>(pUsos);
			this.activo = pActivo;
		}
	}
	public class Uso
	{
		public String descripcion {get;set;}

		public Uso(String pDesc)
		{
			this.descripcion = (pDesc == null ? '' :  pDesc);
		}
	}
	public class OpcionFinanciacion
	{
		public String idSalesforce {get;set;}
		public String cuota {get;set;}
		public String interes {get;set;}
		public Boolean activo {get;set;}

		public OpcionFinanciacion(String pId, String pCuota, String pInteres, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' :  pId);
			this.cuota = (pCuota == null ? '' : pCuota);
			this.interes = (pInteres == null ? '' : pInteres);
			this.activo = pActivo;
		}
	}

	public class OpcionPBITramosC
	{
		public String idSalesforce {get;set;}
		public String actividad {get;set;}
		public String duracion {get;set;}
		public String provincia {get; set;}
		public String pbi {get;set;}
		public String t1 {get;set;}
		public String t2 {get;set;}
		public String t3 {get;set;}
		public String c {get;set;}
		public Boolean activo {get;set;}

		public OpcionPBITramosC(String pId, String pActividad, String pDuracion, String pProvincia, String pPBI, String pT1, String pT2, String pT3, String pC, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.actividad = (pActividad == null ? '' : pActividad);
			this.duracion = (pDuracion == null ? '' : pDuracion);
			this.provincia = (pProvincia == null ? '' : pProvincia);
			this.pbi = (pPBI == null ? '' : pPBI);
			this.t1 = (pT1 == null ? '' : pT1);
			this.t2 = (pT2 == null ? '' : pT2);
			this.t3 = (pT3 == null ? '' : pT3);
			this.c = (pC == null ? '' : pC);
			this.activo = pActivo;
		}
	}

	public class CosteLegalizacionProvincia
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public Decimal valor {get;set;}
		public String provincia {get;set;}
		public Boolean activo {get;set;}

		public CosteLegalizacionProvincia(String pId, String pDesc, Decimal pValor, String pProvincia, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' :  pId);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.valor = (pValor == null ? 0 : pValor);
			this.provincia = (pProvincia == null ? '' : pProvincia);
			this.activo = pActivo;
		}
	}

	public class CosteMantenimientoProvincia
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public Decimal valor {get;set;}
		public String provincia {get;set;}
		public Boolean activo {get;set;}

		public CosteMantenimientoProvincia(String pId, String pDesc, Decimal pValor, String pProvincia, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.valor = (pValor == null ? 0 : pValor) ;
			this.provincia = (pProvincia == null ? '' : pProvincia);
			this.activo = pActivo;
		}
	}

	public class ImagenOferta
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public String imagenBase64 {get;set;}
		public String tramoConsumo {get; set;}
		public String resolucionAnticipada {get;set;}
		public String duracion {get;set;}
		public Boolean activo {get;set;}

		public ImagenOferta(String pId, String pDesc, String pImg, String pTramo, String pDuracion, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.tramoConsumo = (pTramo == null ? '' : pTramo);
			this.duracion = (pDuracion == null ? '' : pDuracion);
			this.imagenBase64 = (pImg == null ? '' : pImg);
			this.activo = pActivo;
		}
	}

	public class OpcionOfertaSTD
	{
		public String idSalesforce {get;set;}
		public String oferta {get;set;}
		public String opInterior {get;set;}
		public String opExterior {get;set;}
		public String opServicio {get;set;}
		public String desde {get;set;}
		public String deposito {get;set;}
		public String pagoInicial {get;set;}
		public String inversionSinDeposito {get;set;}
		public String tarifa {get;set;}
		public String dtoKg {get;set;}
		public Decimal duracionDto {get;set;}
		public Decimal importeInstalacionExterior {get;set;}
        public Decimal importeInstalacionInterior {get;set;}
    	public Decimal importeObraCivil {get;set;}
		public Decimal importeProyectos {get;set;}
		public Decimal importeEquipos {get;set;}
		public Decimal resolucionAnticipada {get;set;}
		public String cuotaMensual {get;set;}
		public String caldera {get;set;}
		public String contador {get;set;}
		public String quemador {get;set;}
		public String telemedida {get;set;}
		public String nivelDistancia {get;set;}
		public String mtoEstandar {get;set;}
		public String inspInterioresDOM {get;set;}
		public String inspInterioresPRO {get;set;}
		public String mtoBianual {get;set;}
		public Boolean activo {get;set;}

		public OpcionOfertaSTD(String pId, String pOferta, String pOpInterior, String pOpExterior, String pOpServicio, String pDesde, String pDeposito, String pTarifa, String pDtoKg, Decimal pDuracionDto, Decimal pimporteInstalacionExterior, Decimal pimporteInstalacionInterior, Decimal pimporteObraCivil, Decimal pimporteProyectos, Decimal pimporteEquipos, Decimal presolucionAnticipada, String pCuotaMensual, String pPagoIni, String pInversionSinDep, 
								Boolean pCaldera, Boolean pContador, Boolean pQuemador, Boolean pTelemedida, Boolean pNivelDistancia, Boolean pMtoEstandar, Boolean pInspIntDOM, Boolean pInspIntPRO, Boolean pMtoBianual, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.oferta = (pOferta == null ? '' : pOferta);
			this.opInterior = (pOpInterior == null ? '' : pOpInterior);
			this.opExterior = (pOpExterior == null ? '' : pOpExterior);
			this.opServicio = (pOpServicio == null ? '' : pOpServicio);
			this.desde = (pDesde == null ? '' : pDesde);
			this.tarifa = (pTarifa == null ? '' : pTarifa);
			this.dtoKg = (pDtoKg == null ? '' : pDtoKg);
			this.duracionDto = (pDuracionDto == null ? 0 : pDuracionDto);
			this.importeInstalacionExterior = (pimporteInstalacionExterior == null ? 0 : pimporteInstalacionExterior);
			this.importeInstalacionInterior = (pimporteInstalacionInterior == null ? 0 : pimporteInstalacionInterior);
			this.importeObraCivil = (pimporteObraCivil == null ? 0 : pimporteObraCivil);
			this.importeProyectos = (pimporteProyectos == null ? 0 : pimporteProyectos);
			this.importeEquipos = (pimporteEquipos == null ? 0 : pimporteEquipos);
			this.resolucionAnticipada = (presolucionAnticipada == null ? 0 : presolucionAnticipada);
			this.cuotaMensual = (pCuotaMensual == null ? '' : pCuotaMensual);
			this.pagoInicial = (pPagoIni == null ? '' : pPagoIni);
			this.inversionSinDeposito = (pInversionSinDep == null ? '' : pInversionSinDep);
			this.deposito = (pDeposito == null ? '' : pDeposito);
			this.caldera = (pCaldera ? '1' : '0');
			this.contador = (pContador ? '1' : '0');
			this.quemador = (pQuemador ? '1' : '0');
			this.telemedida = (pTelemedida ? '1' : '0');
			this.nivelDistancia = (pNivelDistancia ? '1' : '0');
			this.mtoEstandar = (pMtoEstandar ? '1' : '0');
			this.inspInterioresDOM = (pInspIntDOM ? '1' : '0');
			this.inspInterioresPRO = (pInspIntPRO ? '1' : '0');
			this.mtoBianual = (pMtoBianual ? '1' : '0');
			this.activo = pActivo;
		}
	}

	public class TextoOfertaEstandar
	{
		public String idSalesforce {get;set;}
		public String oferta {get;set;}
		public String tipo {get;set;}
		public String descripcion {get;set;}
		public Boolean activo {get;set;}

		public TextoOfertaEstandar(String pId, String pOferta, String pTipo, String pDesc, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.oferta = (pOferta == null ? '' : pOferta);
			this.tipo = (pTipo == null ? '' : pTipo);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.activo = pActivo;
		}
	}

	public class Colaborador
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public String contacto {get;set;}
		public String tipo {get;set;}
		public Boolean activo {get;set;}

		public Colaborador(String pId, String pDesc, String pContacto, String pTipo, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.contacto = (pContacto == null ? '' : pContacto);
			this.tipo = (pTipo == null ? '' : pTipo);
			this.activo = pActivo;
		}
	}

	public class CostesOtrosEquipos
	{
		public String idSalesforce {get;set;}
		public String descripcion {get;set;}
		public String instalacionExterior {get;set;}
		public String equiposExterior {get;set;}
		public String equiposInterior {get;set;}
		public String instalacionInterior {get;set;}
		public Boolean activo {get;set;}

		public CostesOtrosEquipos(String pId, String pDesc, String pInstExt, String pEquiposExt, String pEquiposInt, String pInstInt, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.instalacionExterior = (pInstExt == null ? '' : pInstExt);
			this.equiposExterior = (pEquiposExt == null ? '' : pEquiposExt);
			this.equiposInterior = (pEquiposInt == null ? '' : pEquiposInt);
			this.instalacionInterior = (pInstInt == null ? '' : pInstInt);
			this.activo = pActivo;
		}
	}

	public class CosteExtraServicios
	{
		public String idSalesforce {get;set;} // como en SF no existe una customSetting para este objeto, se envía también el idProvincia para este idSalesforce
		public String idSalesforceProvincia {get;set;}
		public List<ServicioCosteExtra> servicios {get;set;}
		public Boolean activo {get;set;} // si todos sus servicios tienen activo = false, este campo tendrá valor false, en cualquier otro caso true
        
        public CosteExtraServicios(String pIdProvincia, List<ServicioCosteExtra> pServicios, Boolean pActivo)
        {
        	this.idSalesforce = (pIdProvincia == null ? '' : pIdProvincia);
        	this.idSalesforceProvincia = (pIdProvincia == null ? '' : pIdProvincia);
        	if(pServicios == null)
        		this.servicios = new List<ServicioCosteExtra>();
        	else
        		this.servicios = new List<ServicioCosteExtra>(pServicios);
        	this.activo = pActivo;
        }
	}

	public class ServicioCosteExtra
	{
		public String idSalesforce {get;set;}
		public String tipo {get;set;}
		public String descripcion {get;set;}
		public String coste {get;set;}
		public Boolean activo {get;set;}

		public ServicioCosteExtra(String pId, String pTipo, String pDesc, String pCoste, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.tipo = (pTipo == null ? '' : pTipo);
			this.descripcion = (pDesc == null ? '' : pDesc);
			this.coste = (pCoste == null ? '' : pCoste);
			this.activo = pActivo;
		}
	}

	public class LimiteInversionPb
	{
		public String idSalesforce {get;set;}
		public String limitePb {get;set;}
		public String limiteIr {get;set;}
		public String email {get;set;}
		public String mensaje {get;set;}
		public Boolean activo {get;set;}

		public LimiteInversionPb(String pId, String pLimPb, String pLimIr, String pEmail, String pMensaje, Boolean pActivo)
		{
			this.idSalesforce = (pId == null ? '' : pId);
			this.limitePb = (pLimPb == null ? '' : pLimPb);
			this.limiteIr = (pLimIr == null ? '' : pLimIr);
			this.email = (pEmail == null ? '' : pEmail);
			this.mensaje = (pMensaje == null ? '' : pMensaje);
			this.activo = pActivo;
		}
	}
}