public without sharing class PreferenciasController 
{
 	public List<Individual> personasList{get;set;}
 	public Individual persona{get;set;}

    public Boolean info1{get;set;}
    public Boolean info2{get;set;}
    public Boolean info3{get;set;}

    public Boolean promocionesAntes{get;set;}
    public Boolean encuestasAntes{get;set;}

    public Boolean promocionesDespues{get;set;}
    public Boolean encuestasDespues{get;set;}

    public static String redireccion
    {
        get
        {
            if(redireccion == null)
            {
                redireccion = String.valueOf([SELECT Valor__c FROM Parametros__mdt WHERE DeveloperName = 'Web_Primagas' LIMIT 1].Valor__c);
            }
            return redireccion;
        }
        set;
    }

    public PreferenciasController()
    {
    	String hashId = ApexPages.currentPage().getParameters().get('hashId');

        if(String.isNotBlank(hashId))
        {
            personasList = [SELECT Id, Email__c, Hash__c, IP__c, Modificado__c, Modificado_desde__c, Encuestas_satisfaccion__c, Promociones__c, Fecha_encuestas__c, Fecha_promociones__c 
                            FROM Individual 
                            WHERE Hash__c =: hashId];

            if(!personasList.isEmpty())
            {
                persona             = personasList[0];
                promocionesAntes    = personasList[0].Promociones__c;
                encuestasAntes      = personasList[0].Encuestas_satisfaccion__c;

                promocionesDespues  = personasList[0].Promociones__c;
                encuestasDespues    = personasList[0].Encuestas_satisfaccion__c;
            }else{
                persona = null;
            }
        }else{
            persona = null;
        }

        info1 = false;
        info2 = false;
        info3 = false;
    }

    public void showInfo1()
    {
        info1 = (info1) ? false : true;
    }

    public void showInfo2()
    {
        info2 = (info2) ? false : true;
    }

    public void showInfo3()
    {
        info3 = (info3) ? false : true;
    }

    public PageReference actualizarDatosCliente() 
    {
    	try
    	{
	        persona.Hash__c 					= '';
	        persona.IP__c 						= Util.obtenerIP();
	        persona.Modificado__c              	= true;
            persona.Modificado_desde__c         = 'Site';
            if(promocionesDespues != promocionesAntes)
            {
                persona.Fecha_promociones__c    = System.now();
                persona.Promociones__c          = promocionesDespues;
            }
            if(encuestasDespues != encuestasAntes)
            {
                persona.Fecha_encuestas__c          = System.now();
                persona.Encuestas_satisfaccion__c   = encuestasDespues;
            }   

	        update persona;

	        PageReference pageRef = new PageReference(redireccion);
	        pageRef.setRedirect(true);
	        return pageRef;
        }catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                'Ha habido algún problema actualizando sus preferencias'));
            LogUtil.crearLog('Ha habido algún problema actualizando las preferencias de esta persona: '+persona.Id +' Error: '+ e, 'PreferenciasController', 'Individual', 'Error', true);
            LogUtil.guardarLog();
            return null;
        }
    }
}