/** 
* Clase Constantes
**
* @Funcionalidad: Clase encargada de guardar los Logs que se hayan ido creando.
**
* @Autor: Rubén Goitia García (12/03/2014)
**
**/

public class LogUtil 
{
	public static List<Log__c> errores;

	public static Map<String, String> mapaTiposRegistro;
	
	public static void crearLog(String descripcion, String metodo, String objeto, String tipoError, Boolean isError)	
	{
		if (errores == null)
		{
			errores = new List<Log__c>();
		}
        
		if (mapaTiposRegistro == null)
		{
			mapaTiposRegistro = new Map<String, String>();
			List<RecordType> rts = new List<RecordType>([Select Id, Name, DeveloperName from Recordtype where SobjectType = 'Log__c']);
			for (RecordType rt:rts)
			{
				mapaTiposRegistro.put(rt.DeveloperName, rt.Id);
			}
		}	
        
        descripcion = descripcion.abbreviate(130000);
        
		Log__c error = new Log__c(Error__c = isError, Descripcion__c = descripcion, Metodo__c = metodo, Objeto__c = objeto, RecordTypeId = mapaTiposRegistro.get(tipoError), Enviado_a_Navision__c = false);
		//////
		if(Test.isRunningTest())
        {
        	error.CreatedDate = System.today().addDays(-60);
        }
		////// 
		errores.add(error);
	}
    
    public static void crearLog(String descripcion, String metodo, String objeto, String tipoError, Boolean isError, String identificador)	
	{
		if (errores == null)
		{
			errores = new List<Log__c>();
		}
        
		if (mapaTiposRegistro == null)
		{
			mapaTiposRegistro = new Map<String, String>();
			List<RecordType> rts = new List<RecordType>([Select Id, Name, DeveloperName from Recordtype where SobjectType = 'Log__c']);
			for (RecordType rt:rts)
			{
				mapaTiposRegistro.put(rt.DeveloperName, rt.Id);
			}
		}	
        
        descripcion = descripcion.abbreviate(130000);
        
		Log__c error = new Log__c(Error__c = isError, Descripcion__c = descripcion, Metodo__c = metodo, Objeto__c = objeto, RecordTypeId = mapaTiposRegistro.get(tipoError), Enviado_a_Navision__c = false, Id_NewSales__c = identificador);
		//////
		if(Test.isRunningTest())
        {
        	error.CreatedDate = System.today().addDays(-60);
        }
		//////
		errores.add(error);
	}
	
	public static void guardarLog()
	{
		system.debug('Logs de errores a insertar: ' + errores);
		if (errores != null)
		{
			insert errores;
			errores = new List<Log__c>();
		}
	}

	
}