@RestResource(urlMapping='/EnviarImagenes/*')
global class WSEnviarImagenes
{
	@HttpPost
    webservice static String enviar(PeticionImagen peticion)
    {
    	System.debug('JSON: ' + peticion);
        Respuesta r = new Respuesta();
        String jRespuesta = '';
        
        Datos imagenSolicitada;
        try
        {
            if(peticion != null && peticion.datos != null && String.isNotBlank(peticion.datos.idSalesForce))
            {
                imagenSolicitada = peticion.datos;

                List<ImagenesOferta__c> imagenSolicitadaMaestros = [SELECT ImagenBase64__c FROM ImagenesOferta__c WHERE Id=: imagenSolicitada.idSalesForce];
                if(imagenSolicitadaMaestros != null && imagenSolicitadaMaestros.size() > 0)
                {
                    String nombreImagen = imagenSolicitadaMaestros[0].ImagenBase64__c;

                    List<Document> imagenRecogida = [SELECT Body FROM Document where DeveloperName =: nombreImagen];
                    if(imagenRecogida == null || imagenRecogida.size()==0)
                    {
                        //NOMBRE DE IMAGEN NO ENCONTRADO
                    	r.resultado.codigo = '103';
    	                r.resultado.texto = Label.WSError_103 + ' ' + nombreImagen;
                        LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSEnviarImagenes', 'Error', true);
                    }
                    else
                    {
                    	String imagenBase64Recogida = EncodingUtil.base64Encode(imagenRecogida[0].Body);
                    	if( !String.isEmpty(imagenBase64Recogida) )
                    	{
                            //TODO CORRECTO
                    		r.imagen.imagenBase64 = imagenBase64Recogida;
                    		r.resultado.codigo = '100';
                            r.resultado.texto = Label.WSError_100;
                    	}
                    	else
                    	{
                            //CUERPO DE LA IMAGEN VACÍO
    	                	r.resultado.codigo = '105';
    		                r.resultado.texto = Label.WSError_105;
                            LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSEnviarImagenes', 'Error', true);
    	                }
                    }
                }
                else
                {
                    //ID DE IMAGEN NO ENCONTRADO
                    r.resultado.codigo = '104';
                    r.resultado.texto = Label.WSError_105 + ' ' + imagenSolicitada.idSalesForce;
                    LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSEnviarImagenes', 'Error', true);
                }
            }
            else
            {
                //DATOS DE LA PETICIÓN INCORRECTOS
                r.resultado.codigo = '101';
                r.resultado.texto = Label.WSError_101;
                LogUtil.crearLog(r.resultado.texto, 'Errores NewSales', 'WSEnviarImagenes', 'Error', true);
            }
        }
        catch(Exception e)
        {
            r.resultado.codigo = '102';
            r.resultado.texto = Label.WSError_102;
            LogUtil.crearLog(r.resultado.texto + ' LÍNEA ERROR: '+ e.getLineNumber() + ' MENSAJE ERROR: ' + e.getMessage(), 'Errores NewSales', 'WSEnviarImagenes', 'Error', true);
        }

        try
        {
            jRespuesta = (String)JSON.serialize(r);
        }
        catch(Exception e)
        {
            LogUtil.crearLog(Label.JSON_SERIALIZE_ERROR + ' Línea de error: '+ e.getLineNumber() + ' Mensaje de error: ' + e.getMessage(), 'Errores NewSales', 'WSEnviarImagenes', 'Error', true);
        }

        if(LogUtil.errores != null && !LogUtil.errores.isEmpty())
        {
        	LogUtil.guardarLog();
        }
        
        return jRespuesta;
    }

    global class PeticionImagen
    {
        public Datos datos {get;set;}
    }

    public class Datos
    {
        public String idSalesForce {get;set;} //id del registro de la tabla de maestros ImagenesOferta__c       
    }

    public class Respuesta
    {   
        public Resultado resultado {get;set;}
        public Imagen imagen {get;set;}

        public Respuesta()
        {
            resultado = new Resultado();
            imagen = new Imagen();
        }
    }

    public class Resultado 
    {
        public String codigo {get;set;}
        public String texto {get;set;}
    }

    public class Imagen 
    {
        public String imagenBase64 {get;set;}
    }
}