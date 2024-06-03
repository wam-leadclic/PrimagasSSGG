@RestResource(urlMapping='/VersionesNewSales/*')
global class WSVersionesNewSales
{
    public static final String VERSION_ANTERIOR = 'VERSION_ANTERIOR';
    public static final String VERSION_ULTIMA = 'VERSION_ULTIMA';

    @HttpPost
    webservice static String comprobarVersion(PeticionVersiones peticion)
    {
        System.debug('JSON: ' + peticion);
        Respuesta r = new Respuesta();
        String jRespuesta = '';

        try
        {
            if(peticion != null && String.isNotBlank(peticion.version) && String.isNotBlank(peticion.usuario))
            {
               List<User> usuario = [SELECT Name FROM User WHERE Username = :peticion.usuario];

               if(usuario != null && !usuario.isEmpty())
               {
                 r.resultado.nombreUsuario = usuario[0].Name;
               }

               ConfiguracionBase_NewSales__c versionAnterior = ConfiguracionBase_NewSales__c.getValues(VERSION_ANTERIOR);
               ConfiguracionBase_NewSales__c versionUltima = ConfiguracionBase_NewSales__c.getValues(VERSION_ULTIMA);
               if(versionAnterior != null && String.isNotBlank(versionAnterior.Valor__c) && versionUltima != null && String.isNotBlank(versionUltima.Valor__c))
               {
               		versionUltima.Valor__c = versionUltima.Valor__c.remove('.');
                  if(versionUltima.Valor__c.length() < 4) //formato original esperado X.XXX
                  {
                    while(versionUltima.Valor__c.length() < 4)
                    {
                      versionUltima.Valor__c += '0';
                    }
                  }

                  versionAnterior.Valor__c = versionAnterior.Valor__c.remove('.');
                  if(versionAnterior.Valor__c.length() < 4) //formato original esperado X.XXX
                  {
                    while(versionAnterior.Valor__c.length() < 4)
                    {
                      versionAnterior.Valor__c += '0';
                    }
                  }

                  peticion.version = peticion.version.remove('.');
                  if(peticion.version.length() < 4) //formato original esperado X.XXX
                  {
                    while(peticion.version.length() < 4)
                    {
                      peticion.version += '0';
                    }
                  }

                  if(peticion.version == versionUltima.Valor__c)
               		{
               			r.resultado.codigo = '900';
                        r.resultado.texto = Label.WSError_900;
               		}
               		else if(peticion.version.compareTo(versionUltima.Valor__c)<0 && peticion.version.compareTo(versionAnterior.Valor__c)>=0)
               		{
               			r.resultado.codigo = '904';
               			r.resultado.texto = Label.WSError_904;
                        LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSVersionesNewSales', 'Error', true);
               		}
               		else
               		{
               			r.resultado.codigo = '905';
                        r.resultado.texto = Label.WSError_905;
                        LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSVersionesNewSales', 'Error', true);
               		}
               }
               else
               {
	               	r.resultado.codigo = '903'; //Para que no sea bloqueante
                   	r.resultado.texto = Label.WSError_903;
                   	LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSVersionesNewSales', 'Error', true);
               }
            }
            else
            {
                r.resultado.codigo = '901'; //Para que no sea bloqueante
                r.resultado.texto = Label.WSError_901;
                LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSVersionesNewSales', 'Error', true);
            }
        }
        catch(Exception e)
        {
            r.resultado.codigo = '902'; //Para que no sea bloqueante
            r.resultado.texto = Label.WSError_902;
            LogUtil.crearLog(r.resultado.texto + ' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'Errores NewSales', 'WSVersionesNewSales', 'Error', true);
        }

        try
        {
            jRespuesta = (String)JSON.serialize(r);
        }
        catch(Exception e)
        {
            LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSVersionesNewSales', 'Error', true);
        }

        if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
        {
        	LogUtil.guardarLog();
        }
        
        return jRespuesta;
	}


	global class PeticionVersiones 
	{
		public String version {get;set;}
		public String usuario {get;set;}
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
        public String nombreUsuario {get;set;}
        public String codigo {get;set;}
        public String texto {get;set;}
    }
}