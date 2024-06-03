public class PresupuestoUtil
{
	/*Actualiza el campo “Fecha última modificación presupuestos” de la oportunidad cada vez que se modifica 
	un presupuesto asociado a esa oportunidad. Se le llama desde el trigger afterinsert y afterupdate de presupuesto.
	*/
	public static void actualizarFechaUltimaModificacionDePresupuestosEnOportunidad(List<Quote> listaPresupuestos)
	{
		List<Id> listaIdsOportunidades = new List<Id>();
		for(Quote p: listaPresupuestos)
		{
			listaIdsOportunidades.add(p.OpportunityId);
		}
		List<Opportunity> listaOportunidadesActualizar = [SELECT Id, Fecha_ultima_modificacion_presupuestos__c FROM Opportunity WHERE Id IN: listaIdsOportunidades];
		System.debug('listaOportunidadesActualizar: ' + listaOportunidadesActualizar);
		System.debug('listaPresupuestos: ' + listaPresupuestos);

		for(Opportunity o: listaOportunidadesActualizar)
		{
			for(Quote p: listaPresupuestos)
			{
				if(o.Id==p.OpportunityId && p.Status!='Caducado')
				{
					o.Fecha_ultima_modificacion_presupuestos__c = System.now();
					break;
				}
			}
		}

		if(listaOportunidadesActualizar!=null && listaOportunidadesActualizar.size()>0)
		{
			Database.SaveResult[] res = Database.update(listaOportunidadesActualizar, false);
			for(Database.SaveResult r: res)
			{
				if(!r.isSuccess())
	            {
	                Database.Error error = r.getErrors()[0];
	                LogUtil.crearLog('Error al actualizar el campo Fecha_ultima_modificacion_presupuestos__c en la oportunidad '+ r.getId() +' - Message: '+ error.getMessage(), 'actualizarFechaUltimaModificacionDePresupuestosEnOportunidad', 'Presupuesto', 'Update', true);
	                //Parametros crearLog: String descripcion, String metodo, String objeto, String tipoError, Boolean isError
	            }
			}
		}
	}


	/*En la actualización o creación de un presupuesto relacionado con una oportunidad, se modifica el estado de la 
	oportunidad relacionada a “Negociación”. Se le llama desde el trigger afterinsert y afterupdate de presupuesto.
	*/
	public static void cambiarEstadoNegociacion(List<Quote> listaPresupuestos)
	{
		List<Id> listaIdsOportunidades = new List<Id>();
		for(Quote presupuesto: listaPresupuestos)
		{
			listaIdsOportunidades.add(presupuesto.OpportunityId);
		}

		List<Opportunity> listaOportunidades = [SELECT Id, Name, StageName FROM Opportunity WHERE Id IN: listaIdsOportunidades];
		List<Opportunity> listaOportunidadesUpdate = new List<Opportunity>();

		for(Opportunity o: listaOportunidades)
		{
			for(Quote p: listaPresupuestos)
			{
				if(o.Id==p.OpportunityId && p.Status!='Caducado' && o.StageName != 'Negociación / Revisión')
				{
					o.StageName = 'Negociación / Revisión';
					listaOportunidadesUpdate.add(o);
					break;
				}
			}
		}

		Database.SaveResult[] res = Database.update(listaOportunidadesUpdate, false);
		for(Database.SaveResult r: res)
		{
			if(!r.isSuccess())
            {
                Database.Error error = r.getErrors()[0];
                LogUtil.crearLog('Error al actualizar el estado de la oportunidad '+ r.getId() +' a "Negociación / Revisión" - Message: '+ error.getMessage(), 'cambiarEstadoNegociacion', 'Oportunidad', 'Update', true);
                //Parametros crearLog: String descripcion, String metodo, String objeto, String tipoError, Boolean isError
            }
		}
	}

	/**
	* @author: rfernandez
	* @date: 24/01/2017
	* @description: Metodo para calcular el total de inversion de los presupuestos en base a los depositos y los equipos de ajuste 
	*	Se llama desde WSDatosOfertas despues de hacer la insercion de los equipos y los depositos
	**/
	public static void calcularTotalInversionOfertaPersonalizada(List<Quote> newList)
	{
		System.debug('###calcularTotalInversionOfertaPersonalizada NewList: '+newList);
		Id tipoRegistroOferta = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Oferta personalizada').getRecordTypeId();

		Decimal inversionTotal = 0; //Total_inversion__c

		Map<Id, Quote> ofertasMap = new Map<Id, Quote>();
		Map<Id, List<Deposito__c>> depositosMap = new Map<Id, List<Deposito__c>>();
		Map<Id, List<Equipo_Ajuste__c>> equiposAjusteMap = new Map<Id, List<Equipo_Ajuste__c>>();

		List<Id> idsOfertas = new List<Id>();
		for(Quote oferta: newList)
		{
			if(oferta.RecordTypeId == tipoRegistroOferta)
			{
				idsOfertas.add(oferta.Id);
				ofertasMap.put(oferta.Id, oferta);
			}	
		}

		//Sacamos todos los depositos y los agrupamos en un mapa por ofertas
		for (Deposito__c deposito : [select Id, Name, Cantidad__c, Proyectos__c, Obra_civil_vallado__c, Instalacion_exterior__c, Equipos_exterior__c, Presupuesto__c, Credito_divisa__c 
                  from Deposito__c Where Presupuesto__c IN: idsOfertas order by Cantidad__c]) 
		{
			if (!depositosMap.containsKey(deposito.Presupuesto__c))
			{
			    depositosMap.put(deposito.Presupuesto__c, new list<Deposito__c>());
			    depositosMap.get(deposito.Presupuesto__c).add(deposito);
			}
			else
			{
			    depositosMap.get(deposito.Presupuesto__c).add(deposito);
			}
		}
		System.debug('depositosMap: '+depositosMap);

		//Sacamos todos los equipos y los agrupamos en un mapa por ofertas
		for (Equipo_ajuste__c equipoDeAjuste : [select Id, Name, Equipos_exterior__c, Equipos_interior__c, Instalacion_exterior__c, Instalacion_interior__c, Cantidad__c, Presupuesto__c 
	                                from Equipo_ajuste__c Where Presupuesto__c IN: idsOfertas]) 
		{
			if (!equiposAjusteMap.containsKey(equipoDeAjuste.Presupuesto__c))
			{
			    equiposAjusteMap.put(equipoDeAjuste.Presupuesto__c, new list<Equipo_ajuste__c>());
			    equiposAjusteMap.get(equipoDeAjuste.Presupuesto__c).add(equipoDeAjuste);
			}
			else
			{
			    equiposAjusteMap.get(equipoDeAjuste.Presupuesto__c).add(equipoDeAjuste);
			}
		}
		System.debug('equiposAjusteMap: '+equiposAjusteMap);

		//Recorremos las ofertas para ir obteniendo el coste total de instalacion
		for(Id idOferta: idsOfertas)
		{
			Integer costeTotalInstalacionAux = 0;
			Integer costeDepositos = 0;

			if(depositosMap.containsKey(idOferta))
			{
				for(Deposito__c dep : depositosMap.get(idOferta))
		        {	//Cambios rfernandez (20/09/2017) ahora se multplica proyectos, obra e instalacion por la cantidad
		            if(dep.Proyectos__c != null)
		                costeTotalInstalacionAux += (Integer.valueOf(dep.Proyectos__c) * Integer.valueOf(dep.Cantidad__c));
		            if(dep.Obra_civil_vallado__c != null)
		                costeTotalInstalacionAux += (Integer.valueOf(dep.Obra_civil_vallado__c) * Integer.valueOf(dep.Cantidad__c));
		            if(dep.Instalacion_exterior__c != null)
		                costeTotalInstalacionAux += (Integer.valueOf(dep.Instalacion_exterior__c) * Integer.valueOf(dep.Cantidad__c));
		            if(dep.Equipos_exterior__c != null)
		            {
		            	costeTotalInstalacionAux += (Integer.valueOf(dep.Equipos_exterior__c) * Integer.valueOf(dep.Cantidad__c));
		                costeDepositos += (Integer.valueOf(dep.Equipos_exterior__c) * Integer.valueOf(dep.Cantidad__c));
		            }
		        }
			}
 

	      	if(equiposAjusteMap.containsKey(idOferta))
			{
		        for(Equipo_ajuste__c eq: equiposAjusteMap.get(idOferta))
		        {
		            if( eq.Equipos_interior__c != null && eq.Cantidad__c != null)
		                costeTotalInstalacionAux += Integer.valueOf(eq.Equipos_interior__c) * Integer.valueOf(eq.Cantidad__c);
	                if( eq.Equipos_exterior__c != null && eq.Cantidad__c != null)
		                costeTotalInstalacionAux += Integer.valueOf(eq.Equipos_exterior__c) * Integer.valueOf(eq.Cantidad__c);
		            if(eq.Instalacion_exterior__c != null && eq.Cantidad__c != null)
		                costeTotalInstalacionAux += Integer.valueOf(eq.Instalacion_exterior__c) * Integer.valueOf(eq.Cantidad__c);
		            if(eq.Instalacion_interior__c != null && eq.Cantidad__c != null)
		                costeTotalInstalacionAux += Integer.valueOf(eq.Instalacion_interior__c) * Integer.valueOf(eq.Cantidad__c);
		        }
		    }

	        String costeTotalInstalacion = costeTotalInstalacionAux.format();
	        System.debug('###costeTotalInstalacion '+costeTotalInstalacion);

	        Integer inversionPrimagasAux = costeTotalInstalacionAux;
	        
	        Integer cuota = 0;
	        if(ofertasMap.get(idOferta).Pago_inicial_inversion__c != null)
	        {
	            inversionPrimagasAux -= Integer.valueOf(ofertasMap.get(idOferta).Pago_inicial_inversion__c);
	        }

	        if(ofertasMap.get(idOferta).Duracion_cuota_inversion__c != null && ofertasMap.get(idOferta).Cuota_inversion__c != null)
	        {
	            //inversionPrimagasAux += Integer.valueOf((ofertasMap.get(idOferta).Duracion_cuota_inversion__c * ofertasMap.get(idOferta).Cuota_inversion__c));
	            cuota = Integer.valueOf((ofertasMap.get(idOferta).Duracion_cuota_inversion__c * ofertasMap.get(idOferta).Cuota_inversion__c));
	        }
	        System.debug('Duracion cuota: '+ofertasMap.get(idOferta).Duracion_cuota_inversion__c + ' Cuota inversion'+ ofertasMap.get(idOferta).Cuota_inversion__c);

	        String inversionPrimagas = inversionPrimagasAux.format();

	        if (inversionPrimagasAux < 0)
	        {
	            inversionPrimagas = '0';
	        }
	        ofertasMap.get(idOferta).Total_Inversion_con_deposito__c = inversionPrimagasAux;
	        ofertasMap.get(idOferta).Total_inversion__c = inversionPrimagasAux - costeDepositos + ofertasMap.get(idOferta).Pago_inicial_inversion__c;// - cuota;
	        System.debug('costeDepositos: '+costeDepositos+' Cuota: '+ cuota+' Total_Inversion_con_deposito__c: '+ ofertasMap.get(idOferta).Total_Inversion_con_deposito__c+' Total_inversion__c: '+ ofertasMap.get(idOferta).Total_inversion__c);
		}

		System.debug('###NewList actualizado: '+newList);
		update newList;

		//Cambios rfernandez (21/02/2017) Actualizacion de campo Credito divisa de los depositos
		List<Deposito__c> depositosActualizarList = new List<Deposito__c>();
		for(Quote oferta: newList)
		{
			if(depositosMap.containsKey(oferta.Id))
			{
				for(Deposito__c dep : depositosMap.get(oferta.Id))
		        {
		        	dep.Credito_divisa__c += oferta.Total_inversion__c;
		        	depositosActualizarList.add(dep);
		        }
	        }
        }
        update depositosActualizarList;
        //Fin cambios rfernandez (21/02/2017)			
	}

	/**
	* @author: rfernandez
	* @date: 18/04/2017
	* @description: Metodo para añadir a los tramos de la oferta modular el importe primaservicios que se guardar en el packservicios
	**/
	public static void actualizarPrimaserviciosParaTramosModular(List<Quote> ofertas)
	{
		Id tipoRegistroOferta = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Oferta modular').getRecordTypeId();

		List<Id> idsOfertas = new List<Id>();

		for(Quote oferta : ofertas)
		{
			if(oferta.RecordTypeId == tipoRegistroOferta)
			{
				idsOfertas.add(oferta.Id);
			}		
		}

		Map<Id, Decimal> packsServicios = new Map<Id, Decimal>();

		for(Pack_de_servicio__c pack : [SELECT id, Total_importe__c, Presupuesto__c FROM Pack_de_servicio__c WHERE Presupuesto__c IN: idsOfertas])
		{
			packsServicios.put(pack.Presupuesto__c, pack.Total_importe__c);
		}

		Map<Id, List<Tramo__c>> tramos = new Map<Id, List<Tramo__c>>();

		for(Tramo__c tramo : [SELECT id, Presupuesto__c, Prima_servicios_A__c FROM Tramo__c WHERE Presupuesto__c IN: idsOfertas])
		{
			if (!tramos.containsKey(tramo.Presupuesto__c))
            {
                tramos.put(tramo.Presupuesto__c, new list<Tramo__c>());
                tramos.get(tramo.Presupuesto__c).add(tramo);
            }
            else
            {
                tramos.get(tramo.Presupuesto__c).add(tramo);
            }
		}

		List<Tramo__c> tramosActualizar = new List<Tramo__c>();

		for (Id idOferta : tramos.keySet()) 
		{
			List<Tramo__c> tramosObtenidos = tramos.get(idOferta);

			for(Tramo__c tramo : tramosObtenidos)
			{
				if(packsServicios.containsKey(idOferta))
				{
					tramo.Prima_servicios_A__c = packsServicios.get(idOferta);
					tramosActualizar.add(tramo);
				}
			}	
		}

		if(!tramosActualizar.isEmpty())
		{
			update tramosActualizar;
		}
	}

	/**
	* @author: rfernandez
	* @date: 21/02/2017
	* @description: Método encargado de actualizar el campo Credito_divisa__c sumandole el total inversión, ya que en la formula de Credito__c ese valor todavía no se ha 
	*				calculado
	**/
	/*public static void actualizarCreditoDepositoOfertaModular(List<Quote> newList)
	{
		System.debug('###actualizarCreditoDepositoOfertaModular NewList: '+newList);
		Id tipoRegistroOferta = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Oferta modular').getRecordTypeId();

		Decimal inversionTotal = 0; 

		Map<Id, List<Deposito__c>> depositosMap = new Map<Id, List<Deposito__c>>();

		List<Id> idsOfertas = new List<Id>();
		for(Quote oferta: newList)
		{
			if(oferta.RecordTypeId == tipoRegistroOferta)
			{
				idsOfertas.add(oferta.Id);
			}	
		}

		//Sacamos todos los depositos y los agrupamos en un mapa por ofertas
		for (Deposito__c deposito : [select Id, Name, Cantidad__c, Proyectos__c, Obra_civil_vallado__c, Instalacion_exterior__c, Equipos_exterior__c, Presupuesto__c, Credito_divisa__c 
                  from Deposito__c Where Presupuesto__c IN: idsOfertas order by Cantidad__c]) 
		{
			if (!depositosMap.containsKey(deposito.Presupuesto__c))
			{
			    depositosMap.put(deposito.Presupuesto__c, new list<Deposito__c>());
			    depositosMap.get(deposito.Presupuesto__c).add(deposito);
			}
			else
			{
			    depositosMap.get(deposito.Presupuesto__c).add(deposito);
			}
		}
		System.debug('depositosMap: '+depositosMap);

		List<Deposito__c> depositosActualizarList = new List<Deposito__c>();
		for(Quote oferta: newList)
		{
			if(depositosMap.containsKey(oferta.Id))
			{
				for(Deposito__c dep : depositosMap.get(oferta.Id))
		        {
		        	dep.Credito_divisa__c += oferta.Total_inversion__c;
		        	depositosActualizarList.add(dep);
		        }
	        }
        }
        update depositosActualizarList;

	}*/



	/**
	* @author: rfernandez
	* @date: 21/02/2017
	* @description: Método encargado de obtener las energias asociadas a la oferta y añadirlas o actualizarlas en la oportunidad
	**/
	/*public static void crearEnergiasEnOportunidad(List<Quote> newList)
	{
		List<Energia_Actual__c> energiasAInsertarList = new List<Energia_Actual__c>();
		List<Energia_Actual__c> energiasActualizarList = new List<Energia_Actual__c>();
		List<Id> idOfertas = new List<Id>();
		Set<Id> idOportunidades = new Set<Id>();
		for(Quote oferta : newList)
		{
			idOfertas.add(oferta.Id);
			
			idOportunidades.add(oferta.OpportunityId);	
			
		}

		//Guardamos en un mapa los id de la oferta con las energías asociadas
		Map<Id,list<Energia_Actual__c>> energiasDePresupuestoMap = new Map<Id, list<Energia_Actual__c>>();
        for(Energia_Actual__c energiaP: [SELECT Id, Presupuesto__c, Tipo_energia__c, Consumo__c, Consumo_KWH__c, Consumo_KgCo2__c, Consumo_L_Primagas__c, 
        										Consumo_KWH_Primagas__c, Consumo_Kg_Primagas__c, Consumo_KgCO2_Primagas__c, Unidad_consumo__c, Precio__c, 
        										Unidad_precio__c, Proveedor__c, Rendimiento__c, Cambio__c, Importe_situacion_actual__c, Oportunidad__c 
    									FROM Energia_Actual__c 
    									WHERE Presupuesto__c IN :idOfertas])
        {            
            if (!energiasDePresupuestoMap.containsKey(energiaP.Presupuesto__c))
            {
                energiasDePresupuestoMap.put(energiaP.Presupuesto__c, new list<Energia_Actual__c>());
                energiasDePresupuestoMap.get(energiaP.Presupuesto__c).add(energiaP);
            }
            else
            {
                energiasDePresupuestoMap.get(energiaP.Presupuesto__c).add(energiaP);
            }
        }

		//Oportunidades de las ofertas
		List<Opportunity> oportunidadesDeOfertas = [SELECT id, Name FROM Opportunity Where Id IN: idOportunidades];

        //Guardamos en un mapa las oportunidades y sus energías asociadas
		Map<Id,list<Energia_Actual__c>> energiasDeOportunidadMap = new Map<Id, list<Energia_Actual__c>>();
        for(Energia_Actual__c energiaO: [SELECT Id, Presupuesto__c, Tipo_energia__c, Consumo__c, Consumo_KWH__c, Consumo_KgCo2__c, Consumo_L_Primagas__c, 
        										Consumo_KWH_Primagas__c, Consumo_Kg_Primagas__c, Consumo_KgCO2_Primagas__c, Unidad_consumo__c, Precio__c, 
        										Unidad_precio__c, Proveedor__c, Rendimiento__c, Cambio__c, Importe_situacion_actual__c, Oportunidad__c 
    									FROM Energia_Actual__c 
    									WHERE Oportunidad__c IN :idOportunidades])
        {            
            if (!energiasDeOportunidadMap.containsKey(energiaO.Oportunidad__c))
            {
                energiasDeOportunidadMap.put(energiaO.Oportunidad__c, new list<Energia_Actual__c>());
                energiasDeOportunidadMap.get(energiaO.Oportunidad__c).add(energiaO);
            }
            else
            {
                energiasDeOportunidadMap.get(energiaO.Oportunidad__c).add(energiaO);
            }
        }
		for(Quote oferta : newList)
		{
			//Comprobamos que sea solo para las ofertas que vengan de la app
			if(!String.isBlank(oferta.IdNewSales__c))
			{
				//Comprobamos si esa oferta tiene energías
				if(energiasDePresupuestoMap.containsKey(oferta.Id))
				{
					//Por lo menos va a tener una energía asociada
					List<Energia_Actual__c> energiasDePresupuestoExtraidas = energiasDePresupuestoMap.get(oferta.Id);

					//Obtenemos las energías que tiene la oportunidad de la oferta
					if(energiasDeOportunidadMap.containsKey(oferta.OpportunityId))
					{
						//Por lo menos va a tener una energía asociada, sino no estaría en el mapa
						List<Energia_Actual__c> energiasDeoportunidadExtraidas = energiasDeOportunidadMap.get(oferta.OpportunityId);

						//Hay que comparar las energias que estaban asociadas a la oportunidad con la energia nueva que viene con el presupuesto
					}else{
						//Si la oportunidad no tiene energías simplemente se asocia la energia del presupuesto a la oportunidad
						for(Energia_Actual__c energiaDePresupuestoExtraida: energiasDePresupuestoExtraidas)
						{	
							System.debug('#####Dentro del for de energias: '+oferta.OpportunityId+' '+oferta.Opportunity);
							energiaDePresupuestoExtraida.Oportunidad__c = oferta.OpportunityId;
							energiasAInsertarList.add(energiaDePresupuestoExtraida);
						}
					}
					
				}
			}
		}
		if(!energiasAInsertarList.isEmpty())
		{
			//update energiasAInsertarList;
		}	
	}*/

	/*(21/02/2017) Ahora mismo siempre que se pasan ofertas desde la app, se crea su energía en la oportunidad (No se esta creando, en el momento que 
	pilla la oferta puede que no este insertada la energía)
	 Hay que comparar las energías que ya existen en la oportunidad para actualizarlas, borrarlas o lo que sea...               

	(07/03/2017) Problema: Se inserta el presupuesto (saltaria el trigger) y despues se estan insertando las energías asociadas al presupuesto
	(07/03/2017) Solucion: Llamar a esta funcion despues de la insercion de las energías en vez de que salte en el trigger. Cuando se hace un insert
							se ejecuta todo el trigger, se hace comit contra la base de datos, y sigue el flujo de ejecucion normal.
	(07/03/2017) Parece que se ha enlazado la energia del presupuesto a la oportunidad. Faltaria mirar que pasa cuando la oportunidad tiene energias
				ya que habría que compararlas y actualizarlas o enlazar las del presupuesto
	  */
}