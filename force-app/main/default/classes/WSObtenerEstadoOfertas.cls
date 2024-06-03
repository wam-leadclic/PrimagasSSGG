@RestResource(urlMapping='/EstadoOfertas/*')
global class WSObtenerEstadoOfertas {

	@HttpPost
	webservice static String getEstadosOfertas(PeticionOfertas peticion)
	{
		System.debug('JSON: ' + peticion);
		Respuesta r = new Respuesta();
		String jRespuesta = '';

		Set<Id> setIdsOfertas;
		Set<String> setIdsOfertasSoloApp;
		List<Quote> listaOfertas;
		try
		{
			if(peticion != null && peticion.ofertas != null)
			{
				setIdsOfertas = new Set<Id>();
				setIdsOfertasSoloApp = new Set<String>();
				for(OfertaId ofId : peticion.ofertas)
				{
					if(ofId != null && ofId.identificador.length()>10) //Para que no se tengan en cuenta los ids generados por la app
					{	
						setIdsOfertas.add(ofId.identificador);
					}
					else if(ofId.identificador.length()==10)
					{
						setIdsOfertasSoloApp.add(ofId.identificador);
					}
				}
				if( setIdsOfertas.size() > 0 )
				{
					listaOfertas = [select Id, Status from Quote where Id = :setIdsOfertas];
					if(listaOfertas == null ||listaOfertas.size() <= 0 )
					{
						r.resultado.codigo = '603';
						r.resultado.texto = Label.WSError_603 + ' ' + String.join(new List<Id>(setIdsOfertas), ', ');
                        LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSObtenerEstadoOfertas', 'Error', true);
					}
					else
					{
						r.resultado.codigo = '600';
						r.resultado.texto = Label.WSError_600_1;

						for(Quote quo : listaOfertas)
						{
							if(quo != null )
							{
								r.ofertas.add(new OfertaEstado(quo.Id, quo.Status));
							}
						}
					}
				}
				else
				{
					r.resultado.codigo = '600';
					r.resultado.texto = Label.WSError_600_2;				
                }
				if( setIdsOfertasSoloApp.size() > 0 && r.resultado.codigo == '600')
				{
					for(String idApp : setIdsOfertasSoloApp)
					{
						r.ofertas.add(new OfertaEstado(idApp, ''));
					}
				}
			}
			else
			{
				r.resultado.codigo = '601';
				r.resultado.texto = Label.WSError_601;	
                LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSObtenerEstadoOfertas', 'Error', true);
			}
		}
		catch(Exception e)
		{
			r.resultado.codigo = '602';
			r.resultado.texto = Label.WSError_602;	
        	LogUtil.crearLog(r.resultado.texto + ' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'Errores NewSales', 'WSObtenerEstadoOfertas', 'Error', true);
        }
		try
		{
			jRespuesta = (String)JSON.serialize(r);
		}  
		catch(Exception e) 
		{
			LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSObtenerEstadoOfertas', 'Error', true);
		}
		
        if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
        {
        	LogUtil.guardarLog();
        }
        
		return jRespuesta;
	}

	global class PeticionOfertas 
	{
		public List<OfertaId> ofertas {get;set;}
	}

	public class OfertaId
	{
		public String identificador {get;set;}
	}

	public class Respuesta
	{	
		public Resultado resultado {get;set;}
		public List<OfertaEstado> ofertas {get;set;}

		public Respuesta()
		{
			resultado = new Resultado();
			ofertas = new List<OfertaEstado>();
		}
	}

	public class Resultado 
	{
		public String codigo {get;set;}
		public String texto {get;set;}
	}

	public class OfertaEstado
	{
		public String id {get;set;} // identificador de la oferta
		public String estado {get;set;} // estado actual de la oferta

		public OfertaEstado(String idO, String estadoO)
		{
			id = idO;
			estado = estadoO;
		}
	}
}