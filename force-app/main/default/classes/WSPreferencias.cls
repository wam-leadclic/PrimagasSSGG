@RestResource(urlMapping='/Preferencias/*')
global class WSPreferencias 
{
    @HttpPost
    webservice static String getCliente(Cliente peticion)
    {
		Respuesta r = new Respuesta();
		String correoRecibido;
    	try
    	{
    		correoRecibido = peticion.email;
    		if(String.isNotBlank(correoRecibido) && validarEmail(correoRecibido))
    		{
	    		String correo = limpiarCorreo(correoRecibido);
    			//Recuperamos los posibles contactos y leads que puedan tener ese correo en algun campo de correo y que esten asociados a un registro persona
    			String query = 'FIND {'+correo+'} IN EMAIL FIELDS RETURNING Contact(IndividualId WHERE IndividualId != null), Lead(IndividualId WHERE IsConverted=false AND IndividualId != null)';
				
				List<List<sObject>> results = Search.query(query);
				System.debug(results);
				//Recorremos el resultado para sacar las listas de contactos y candidatos
				List<Contact> contactsList = new List<Contact>();
				List<Lead> leadsList = new List<Lead>();
				for(List<SObject> listaElementos : results)
                {
                    if(listaElementos != null && !listaElementos.isEmpty())
                    {
                        if(listaElementos[0].getSObjectType() == Contact.sObjectType)
                        {
                            contactsList 	= listaElementos;
                        }
                        if(listaElementos[0].getSObjectType() == Lead.sObjectType)
                        {
                    		leadsList		= listaElementos;
                        }
                    }
                }
                
                /*
                	Comprobamos el número de registros recuperados. Solo se van a enviar mails en dos casos
                		-No se encuentran registros: Email indicando que no hay registros con ese email
                		-Se encuentra un unico registro: Email con el hash para acceder a las preferencias
            		En el resto de casos se devuelve un codigo de error y un mensaje
                */
                Id idPersona;
                Contact contacto;
                Lead candidato;
                if( contactsList.size() > 1 || leadsList.size() > 1 || (contactsList.size() == 1 && leadsList.size() == 1))
                {
                	r.resultado.codigo = '300';
					r.resultado.texto = 'Se han encontrado varios registros con el mismo email';
                }
                else if(contactsList.size() == 0 && leadsList.size() == 0)
                {
                	Boolean error = enviarEmail(null, null, null, correoRecibido);
	    			r.resultado.codigo = '404';
					r.resultado.texto = 'No se ha encontrado ningun registro con ese email.';

                }
                else if(contactsList.size() == 1 && leadsList.size() == 0)
                {
                	idPersona = contactsList[0].IndividualId;
                	contacto  = contactsList[0];
                }
                else if(contactsList.size() == 0 && leadsList.size() == 1)
                {
                	idPersona = leadsList[0].IndividualId;
                	candidato = leadsList[0];
                }
                
                //Si hemos recuperado un id, recuperamos la persona para regenerar el hash__c
	    		if(idPersona != null)
	    		{
	                Individual persona = [SELECT Id, Hash__c FROM Individual WHERE Id =: idPersona LIMIT 1];
	                System.debug(persona);
	    			persona.Hash__c =  Util.calcularHash(persona.Id);
	    			update persona;

	    			Boolean error;
	    			if(contacto != null)
	    			{
	    				error = enviarEmail('PreferenciasOK', contacto, null, correoRecibido);
	    			}else
	    			{
	    				error = enviarEmail('PreferenciasOK', null, candidato, correoRecibido);
	    			}

	    			if(!error)
	    			{
	    				r.resultado.codigo 	= '200';
						r.resultado.texto 	= 'Email enviado';
	    			}else
	    			{
	    				r.resultado.codigo 	= '400';
						r.resultado.texto 	= 'Se ha producido algún error al enviar el email';
	    			}
	    		}
			}else
			{
				r.resultado.codigo 	= '400';
				r.resultado.texto 	= 'El email no es correcto';
			}
    	}catch(Exception e)
    	{
    		r.resultado.codigo 	= '400';
			r.resultado.texto 	= 'Se ha producido algún error al buscar el cliente';
			
			LogUtil.crearLog('Ha habido algún problema al buscar el cliente con correo: '+correoRecibido+' Error: '+ e.getMessage()+' Linea: '+ e.getLineNumber(), 'PreferenciasController', 'Individual', 'Error', true);
    	}
        LogUtil.guardarLog();

        return (String)JSON.serialize(r);
    }


	private static Boolean enviarEmail(String nombrePlantilla, Contact contacto, Lead candidato, String correo)
    {
    	Boolean error = false;

    	OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'privacidad@primagas.es'];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    mail.setToAddresses(new List<String>{correo});
	    mail.setOrgWideEmailAddressId(owea[0].Id);
        if(contacto == null && candidato == null)
        {
            //Puesto que no vamos a especificar el TargetObjectId y es obligatorio para usar plantillas, metemos la plantilla directamente en el cuerpo
            //TODO  ELIMINAR HARDCODE
            mail.setHtmlBody('<html> <head>  <title></title>   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">   <style type="text/css">     @media screen and (max-width: 650px){      .mainTable{        width:100% !important;        max-width:600px !important;          }      .fullWidthInMbl{        width:100%  !important;          clear:both  !important;      }     }   </style> </head>  <body bgcolor="#DDDDDD" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">   <table width="100%" align="center" cellpadding="0" cellspacing="0">    <tr>    <td align="center" valign="top">      <table width="600" align="center" cellpadding="0" cellspacing="0" bgcolor="#ffffff" class="mainTable">                      <tr>          <td align="center" valign="top">            <table width="100%" cellpadding="0" cellspacing="0" align="center">                          <tr>                <td><img src="https://primagas.my.salesforce.com/servlet/servlet.ImageServer?id=01557000004hAxY&oid=00DD0000000qW2D" width="100%" alt="Primagas" align="top" style="display:block;" border="0"/></td>              </tr>            </table>          </td>        </tr>                                    <tr>          <td align="center" valign="top">            <table width="79%" cellpadding="0" cellspacing="0" align="center">                          <tr>                <td style="font-family:Arial, Helvetica, sans-serif; text-align: left; font-size: 14px; color: #333333; line-height: 18px"><br>Apreciad@ cliente,<br><br>El correo electr&oacute;nico que has introducido no coincide con el que tenemos en nuestra base de datos. Para poder acceder a tus preferencias de privacidad necesitamos actualizar tus datos de contacto.<br><br>Por favor cont&aacute;ctanos a trav&eacute;s de uno de nuestros canales.</td>                             </tr>            </table>          </td>        </tr>         <tr>           <td align="center" valign="top" >&nbsp;</td>         </tr>         <tr>           <td valign="top" ><table width="320" border="0" cellspacing="0" cellpadding="0" align="center">             <tbody>               <tr>                 <td><table width="90" border="0" cellspacing="0" cellpadding="0" align="left" >                   <tbody>                     <tr>                       <td align="center"><img src="https://primagas.my.salesforce.com/servlet/servlet.ImageServer?id=01557000004hAxO&oid=00DD0000000qW2D" width="55" alt="Icono telefono" align="top" border="0"/></td>                     </tr>                     <tr>                       <td style="font-family:Arial, Helvetica, sans-serif; text-align:center; font-size: 14px; color: #333333; line-height: 17px"><strong  style="font-family:Arial, Helvetica, sans-serif; text-align:center; font-size: 14px; color: #333333; line-height: 17px">900 878 750</strong></td>                     </tr>                     <tr>                       <td style="font-family:Arial, Helvetica, sans-serif; text-align:center; font-size: 16px; color: #333333; line-height: 17px">&nbsp;</td>                     </tr>                   </tbody>                 </table>                   <table width="130" border="0" cellspacing="0" cellpadding="0" align="left">                     <tbody>                       <tr>                         <td align="center"><img src="https://primagas.my.salesforce.com/servlet/servlet.ImageServer?id=01557000004hAwk&oid=00DD0000000qW2D" width="55" alt="Icono email" align="top" border="0"/></td>                       </tr>                       <tr>                         <td align="center"><a href="mailto:hola@primagas.es" target="_blank" style="font-family:Arial, Helvetica, sans-serif; text-align:center; font-size: 13px; color: #333333; line-height: 17px; text-decoration: none                      "><strong style="font-family:Arial, Helvetica, sans-serif; text-align:center; font-size: 13px; color: #333333; line-height: 17px; text-decoration: none                      ">hola@primagas.es</strong></a></td>                       </tr>                       <tr>                         <td style="font-family:Arial, Helvetica, sans-serif; text-align:center; font-size: 16px; color: #333333; line-height: 17px">&nbsp;</td>                       </tr>                     </tbody>                   </table>                   <table width="90" border="0" cellspacing="0" cellpadding="0" align="left">                     <tbody>                       <tr>                         <td align="center"><img src="https://primagas.my.salesforce.com/servlet/servlet.ImageServer?id=01557000004hAxT&oid=00DD0000000qW2D" width="55" alt="Icono Whatsapp" align="top" border="0"/></td>                       </tr>                       <tr>                         <td style="font-family:Arial, Helvetica, sans-serif; text-align:center; font-size: 14px; color: #333333; line-height: 17px"><strong>629 313 567</strong></td>                       </tr>                       <tr>                         <td style="font-family:Arial, Helvetica, sans-serif; text-align:center; font-size: 16px; color: #333333; line-height: 17px">&nbsp;</td>                       </tr>                     </tbody>                   </table></td>               </tr>             </tbody>           </table></td>         </tr>                                             <tr>            <td align="center" valign="top" >&nbsp;</td>          </tr>         <tr>          <td align="center" valign="top">            <table width="79%" cellpadding="0" cellspacing="0" align="center">                          <tr>                <td style="font-family:Arial, Helvetica, sans-serif; text-align: left; font-size: 14px; color: #333333; line-height: 18px"> Hasta pronto.</td>                             </tr>            </table>          </td>        </tr>                  <tr>            <td align="center" valign="top" >&nbsp;</td>          </tr>          <tr>          <td align="center" valign="top" >&nbsp;</td>        </tr>                         <tr >           <td align="center" valign="top">                                  <table width="85%" cellpadding="0" cellspacing="0" align="center">                          <tr style="font-size:2px; line-height:2px" bgcolor="#df2b2a">                <td>&nbsp; </td>              </tr>            </table>                                    </td>         </tr>                          <tr style="line-height:10px; font-size:10px">          <td>&nbsp;</td>        </tr>                    <tr>          <td align="center" valign="top">            <table width="85%" cellpadding="0" cellspacing="0" align="center">                          <tr>                <td align="center" style="font-family:Arial, Helvetica, sans-serif; text-align: center; font-size: 11px; color: #333333;" ><em>Primagas Energ&iacute;a SAU - C/ Beethoven 15, 7&ordm; 3&ordf; &middot; 08021 Barcelona &bull; <a href="http://www.primagas.es" target="_blank" style="font-family:Arial, Helvetica, sans-serif; text-align: left; font-size: 13px; color: #333333;  text-decoration:none">www.primagas.es</a></em></td>                             </tr>            </table>          </td>        </tr>                      <tr>            <td align="center" valign="top" >&nbsp;</td>        </tr>      </table>    </td>   </tr>   </table> </body></html>');
            mail.setSubject('Contáctanos para actualizar tus datos');
    	}else
    	{
            EmailTemplate et = [SELECT Id FROM  EmailTemplate WHERE DeveloperName =: nombrePlantilla];
            mail.setTemplateId(et.Id);
		    if(contacto != null)
		    {
			    mail.setTargetObjectId(contacto.Id);
		    }else{
	    	    mail.setTargetObjectId(candidato.Id);
		    }
    	}
	    mail.setSaveAsActivity(false);
	    mail.setUseSignature(false); 

	    if(!Test.isRunningTest())
	    {
    		Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail},false);
    		for (Messaging.SendEmailResult result : results)
            {
                if(!result.isSuccess())
                {
                	error = true;
                    for(Database.Error err : result.getErrors())
                    {
            			LogUtil.crearLog('Ha habido algún problema al enviar el mail: '+correo+' Error: '+ err.getMessage(), 'PreferenciasController', 'Messaging.SendEmailResult', 'Error', true);
                    }
                }
            }
	    }
	    return error;
    }

    private static String limpiarCorreo(String correo)
    {
    	Set<String> caracteresLimitados = new Set<String>{'?', '&', '|', '!', '{', '}', '[', ']', '^', '~', '*', ':', '\\', '"', '\'', '+', '-'};

    	for(String caracter : correo.split(''))
    	{
    		if(caracteresLimitados.contains(caracter))
    		{
    			correo = correo.replace(caracter, '\\'+caracter);
    		}
    	}
    	return correo;
    }

    public static Boolean validarEmail(String email) 
    {
        Boolean res = false;
        
        if(email != null)
        {
            String emailRegex = '^[a-zA-ZñÑ0-9_|\\\\%#~`=?&/$^*!}{+-][a-zA-ZñÑ0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.[^-]][a-zA-Z0-9.-]*[a-zA-Z0-9[^-.]]\\.[a-zA-Z]{2,4}$'; 
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(email);

            if (MyMatcher.matches())
            {
                res = true;
            } 
        }
        
        return res; 
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

	global class Cliente
	{
		public String email {get;set;}
	}
}