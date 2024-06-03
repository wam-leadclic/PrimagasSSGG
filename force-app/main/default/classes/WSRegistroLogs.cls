@RestResource(urlMapping='/RegistroLogs/*')
global class WSRegistroLogs 
{
	@HttpPost
	global static String registrarLogs(PeticionLogs peticion)
	{
		System.debug('JSON: ' + peticion);
        List<String> IdsLogsErrores; 
        
		Respuesta r = new Respuesta();
        String jrespuesta = '';
        
		List<Log> logs;
		try
		{
			if(peticion != null && peticion.Logs != null)
			{
				for(Log log : peticion.logs) 
				{
                    //esError en el futuro será boolean
                    //&& log.esError != null
                    //&& String.isNotBlank(log.esError)
					if(log != null 
                       && String.isNotBlank(log.descripcion) 
                       && String.isNotBlank(log.esError)
                       && String.isNotBlank(log.clase)
                       && String.isNotBlank(log.metodo)
                       && String.isNotBlank(log.identificador)
                      ) 
					{	
						LogUtil.crearLog(log.descripcion, log.metodo, log.clase, 'Error', Boolean.valueOf(log.esError), log.identificador);
					}
                    else
                    {
                        if(IdsLogsErrores == null)
                        {
                            IdsLogsErrores = new List<String>();
                        }
                        
                        IdsLogsErrores.add(log.identificador);
                    }
                   
                    if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
                    {
                        r.resultado.codigo = '200';
                        
                        if(IdsLogsErrores == null)
                        {
                            r.resultado.texto = label.WSError_200_1;
                        }
                        else
                        {
                            //r.resultado.texto = label.WSError_200_2; //PENDIENTE DE IDENTIFICAR
                            r.resultado.texto = LogUtil.Errores.size()
                                				+ (LogUtil.Errores.size() == 1 ? ' log insertado correctamente. Ha fallado ' : ' logs insertados correctamente. Han fallado ')
                                				+ IdsLogsErrores.size() 
                                                + (IdsLogsErrores.size() == 1 ? ' log al insertarse porque le falta algún campo. Id del log que ha fallado: ' : ' logs al insertarse porque les falta algún campo. Ids de los logs que han fallado: ')
                                				+ String.join(IdsLogsErrores, ', ');   
                        }
                    }
                    else
                    {
                    	r.resultado.codigo = '203';
                        r.resultado.texto = label.WSError_203;
                    }
				}
			}
			else
			{
                r.resultado.codigo = '201';
                r.resultado.texto = label.WSError_201;
				LogUtil.crearLog(r.resultado.texto, 'registrarLogs', 'WSRegistroLogs', 'Error', true);
			}
		}
		catch(Exception e)
		{	
            r.resultado.codigo = '202';
            r.resultado.texto = label.WSError_202;
        	LogUtil.crearLog(r.resultado.texto + ' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'registrarLogs', 'WSRegistroLogs', 'Error', true);
        }
		
		try
		{
			jRespuesta = (String)JSON.serialize(r);
		}  
		catch(Exception e) 
		{
			LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'registrarLogs', 'WSRegistroLogs', 'Error', true);
		}
		
        if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
        {
        	LogUtil.guardarLog();
        }
        
		return jRespuesta;

	}

	global class PeticionLogs 
	{
		public List<Log> Logs {get;set;}
	}

	public class Log
	{
        public String descripcion {get;set;}
        //En el futuro sera boolean
        public String esError {get;set;}
        //public Boolean esError {get;set;}
        public String clase {get;set;}
        public String metodo {get;set;}
		public String identificador {get;set;}
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