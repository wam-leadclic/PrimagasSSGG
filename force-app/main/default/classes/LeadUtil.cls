public class LeadUtil
{
    private static Map<Id, Individual> personasMap
    {
        get
        {
            if(personasMap == null)
            {
                personasMap = new Map<Id, Individual>();
            }
            return personasMap;
        }
        set;
    }
    
    private static Map<Id, Individual> personasToUpdate
    {
        get
        {
            if(personasToUpdate == null)
            {
                personasToUpdate = new Map<Id, Individual>();
            }
            return personasToUpdate;
        }
        set;
    }
    
    private static Map<Id, Individual> personasToDelete
    {
        get
        {
            if(personasToDelete == null)
            {
                personasToDelete = new Map<Id, Individual>();
            }
            return personasToDelete;
        }
        set;
    }
    
    /*Después de la actualización de un candidato, si se ha convertido, se almacena la información de los socios de candidato, 
energías actuales y equipos actuales en mapas. Después, para cada cuenta creada de la conversión se le crean los socios que tenía
el candidato origen como socios de candidato, y para cada oportunidad creada de la conversión se le crean las energías actuales 
y equipos actuales que tenía el candidato origen. Se le llama desde el trigger afterupdate de candidato.

@19/09/2016: Se ha añadido el tipo de direccion de envío */
    @future
    public static void insertarDatosConversionCuentaYOportunidad(List<Id> listaIdsCandidatos)
    {
        List<Lead> listaCandidatos = [SELECT Id, Name, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Contato_alt1__c, Tel_fono_contacto_alt_1__c, 
                                      Contact_Address__c, Codigo_Postal__c, Contact_City__c, Contact_State__c, PaisContacto__c, Actividad__c, Sub_actividad__c,recordtypeid
                                      FROM Lead WHERE Id IN: listaIdsCandidatos];
        List<Id> listaIdsCandidatosConvertidos = new List<Id>();
        List<Lead> listaCandidatosConvertidos = new List<Lead>();
        Set<String> setCuentasConversionIds = new Set<String>();
        Database.SaveResult[] res;
        for(Lead candidato: listaCandidatos)
        {
            //Solo se hace para candidatos convertidos
            if(candidato.IsConverted)
            {
                listaIdsCandidatosConvertidos.add(candidato.Id);
                listaCandidatosConvertidos.add(candidato);
                setCuentasConversionIds.add(candidato.ConvertedAccountId);
            }   
        }
        
        
        if( listaCandidatosConvertidos!=null && listaCandidatosConvertidos.size()>0 )
        {
            //////////////////////////////////////////////GUARDO INFORMACION DE CANDIDATOS/////////////////////////////////////////////////
            Map<Id,List<Socio_de_candidato__c>> mapaIdsOportunidadesDeConversionListaSociosCandidato = new Map<Id,List<Socio_de_candidato__c>>();
            Map<Id,List<Energia_actual__c>> mapaIdsOportunidadesDeconversionListaEnergiasActuales = new Map<Id,List<Energia_actual__c>>();
            Map<String,Lead> mapaIdCuentaDeConversionCandidatoConContacto = new Map<String,Lead>();
            Map<String,Lead> mapaIdCuentaDeConversionCandidatoConDireccion = new Map<String,Lead>();
            //Map<Id,List<Equipo_actual__c>> mapaIdsOportunidadesDeconversionListaEquiposActuales = new Map<Id,List<Equipo_actual__c>>();
            
            //Guardo los socios de candidato
            List<Socio_de_candidato__c> listaSociosDeCandidato = [SELECT Id, Candidato__c, Socio__c, Funcion__c FROM Socio_de_candidato__c WHERE Candidato__c IN: listaIdsCandidatosConvertidos];
            if(listaSociosDeCandidato!=null && listaSociosDeCandidato.size()>0)
            {
                for(Lead candidato: listaCandidatosConvertidos)
                {
                    List<Socio_de_candidato__c> listaSociosAnadirAMapa = new List<Socio_de_candidato__c>();
                    for(Socio_de_candidato__c socio: listaSociosDeCandidato)
                    {
                        if(candidato.Id==socio.Candidato__c)
                        {
                            listaSociosAnadirAMapa.add(socio);
                        }                       
                    }
                    mapaIdsOportunidadesDeConversionListaSociosCandidato.put(candidato.ConvertedOpportunityId,listaSociosAnadirAMapa);
                }
            }   
            System.debug('mapaIdsOportunidadesDeConversionListaSociosCandidato: ' + mapaIdsOportunidadesDeConversionListaSociosCandidato);
            
            //Guardo las energías actuales
            List<Energia_actual__c> listaEnergiasActuales = [SELECT Id, Candidato__c FROM Energia_actual__c WHERE Candidato__c IN: listaIdsCandidatosConvertidos];
            if(listaEnergiasActuales!=null && listaEnergiasActuales.size()>0)
            {
                for(Lead candidato: listaCandidatosConvertidos)
                {
                    List<Energia_actual__c> listaEnergiasAnadirAMapa = new List<Energia_actual__c>();
                    for(Energia_actual__c energia: listaEnergiasActuales)
                    {
                        if(candidato.Id==energia.Candidato__c)
                        {
                            listaEnergiasAnadirAMapa.add(energia);                          
                        }
                    }
                    mapaIdsOportunidadesDeconversionListaEnergiasActuales.put(candidato.ConvertedOpportunityId,listaEnergiasAnadirAMapa);
                }
            }
            System.debug('mapaIdsOportunidadesDeconversionListaEnergiasActuales: ' + mapaIdsOportunidadesDeconversionListaEnergiasActuales);
            
            //Asocio la cuenta de la conversión al candidato para crear a partir de él un contacto alternativo asociado a la cuenta
            Map<String,Account> mapaCuentasConversion = new Map<String,Account>([SELECT Id, Name, IsPersonAccount FROM Account WHERE Id =: setCuentasConversionIds]);
            String IDRT_CT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('cambio_titular_canalizado').getRecordTypeId();
            if(mapaCuentasConversion!=null && mapaCuentasConversion.size()>0)
            {
                for(Lead candidato: listaCandidatosConvertidos)
                {
                    // solo para las cuentas empresariales
                    if(mapaCuentasConversion.containsKey(candidato.ConvertedAccountId) && !mapaCuentasConversion.get(candidato.ConvertedAccountId).IsPersonAccount &&
                       String.isNotBlank(candidato.Contato_alt1__c) && String.isNotBlank(candidato.Tel_fono_contacto_alt_1__c))
                    {
                        mapaIdCuentaDeConversionCandidatoConContacto.put(candidato.ConvertedAccountId, candidato);
                    }
                    System.debug('IDRT_CT ' + IDRT_CT );
                    System.debug('candidato.RecordTypeId' + candidato.RecordTypeId);
                    if(IDRT_CT != candidato.RecordTypeId ){
                        if(mapaCuentasConversion.containsKey(candidato.ConvertedAccountId) && (String.isNotBlank(candidato.Contact_Address__c) || 
                                                                                               String.isNotBlank(candidato.Contact_City__c) || String.isNotBlank(candidato.Contact_State__c) || String.isNotBlank(candidato.Codigo_Postal__c) || 
                                                                                               String.isNotBlank(candidato.PaisContacto__c) || String.isNotBlank(candidato.Actividad__c) || String.isNotBlank(candidato.Sub_actividad__c)) )
                        {
                            System.debug('ENTRO AQUI @@@@@');
                            mapaIdCuentaDeConversionCandidatoConDireccion.put(candidato.ConvertedAccountId, candidato);
                        }
                    }
                }
            }
            System.debug('##mapaIdCuentaDeConversionCandidatoConContacto: ' + mapaIdCuentaDeConversionCandidatoConContacto);
            System.debug('##mapaIdCuentaDeConversionCandidatoConDireccion: ' + mapaIdCuentaDeConversionCandidatoConDireccion);
            
            /*//Guardo los equipos actuales
List<Equipo_actual__c> listaEquiposActuales = [SELECT Id, Candidato__c FROM Equipo_actual__c WHERE Candidato__c IN: listaIdsCandidatosConvertidos];
if(listaEquiposActuales!=null && listaEquiposActuales.size()>0)
{
for(Lead candidato: listaCandidatosConvertidos)
{
List<Equipo_actual__c> listaEquiposAnadirAMapa = new List<Equipo_actual__c>();
for(Equipo_actual__c equipo: listaEquiposActuales)
{
if(candidato.Id==equipo.Candidato__c)
{                           
listaEquiposAnadirAMapa.add(equipo);
}
}
mapaIdsOportunidadesDeconversionListaEquiposActuales.put(candidato.ConvertedOpportunityId,listaEquiposAnadirAMapa);
}
}
System.debug('mapaIdsOportunidadesDeconversionListaEquiposActuales: ' + mapaIdsOportunidadesDeconversionListaEquiposActuales);      
*/
            
            /////////////////////////////////////////////////INSERTO INFORMACION DE CUENTA////////////////////////////////////////////////////  
            /*Para cada cuenta creada de una conversión, se le crea un contacto alternativo asociado en caso de que estén rellenos los campos correspondiententes*/
            Lead candidato;
            List<Contact> listaContactosInsert = new List<Contact>();
            if(mapaIdCuentaDeConversionCandidatoConContacto!=null && mapaIdCuentaDeConversionCandidatoConContacto.size()>0)
            {
                for(String cuentaId: mapaIdCuentaDeConversionCandidatoConContacto.keySet())
                {
                    candidato = mapaIdCuentaDeConversionCandidatoConContacto.get(cuentaId);
                    Contact contacto = new Contact();
                    contacto.AccountId = cuentaId;
                    contacto.LastName = candidato.Contato_alt1__c;
                    contacto.Phone = candidato.Tel_fono_contacto_alt_1__c;
                    contacto.Permitir_duplicado__c = true;
                    listaContactosInsert.add(contacto);
                }
                
                if(listaContactosInsert!= null && listaContactosInsert.size()>0)
                {
                    res = Database.insert(listaContactosInsert, false);
                    for(Database.SaveResult r: res)
                    {
                        if(!r.isSuccess())
                        {
                            Database.Error error = r.getErrors()[0];
                            LogUtil.crearLog('Error al crear el contacto alternativo de la cuenta en la conversión - Message: '+ error.getMessage(), 'insertarDatosConversionCuentaYOportunidad', 'Contacto (Cuenta)', 'Insert', true);
                            //Parametros crearLog: String descripcion, String metodo, String objeto, String tipoError, Boolean isError
                        }
                    }
                }
                System.debug('##listaContactosInsert: ' + listaContactosInsert);
            }
            
            //Se comprueban las direcciones de entrega de las cuentas
            Map<String,list<Direcci_n_de_entrega__c>> cuentasConDireccionesEntrega = new Map<String, list<Direcci_n_de_entrega__c>>();
            for(Direcci_n_de_entrega__c direccionEntrega: [SELECT Codigo_Postal__c, Cuenta__c,Direccion__c,Pais__c,Poblacion__c,Provincia__c FROM Direcci_n_de_entrega__c 
                                                           WHERE Cuenta__c IN :setCuentasConversionIds])
            {            
                if (!cuentasConDireccionesEntrega.containsKey(String.valueOf(direccionEntrega.Cuenta__c)))
                {
                    cuentasConDireccionesEntrega.put(String.valueOf(direccionEntrega.Cuenta__c), new list<Direcci_n_de_entrega__c>());
                    cuentasConDireccionesEntrega.get(String.valueOf(direccionEntrega.Cuenta__c)).add(direccionEntrega);
                }
                else
                {
                    cuentasConDireccionesEntrega.get(String.valueOf(direccionEntrega.Cuenta__c)).add(direccionEntrega);
                }            
            }
            /*Para cada cuenta creada de una conversión, se le crea una dirección de entrega asociada*/
            List<Direcci_n_de_entrega__c> listaDireccionesInsert = new List<Direcci_n_de_entrega__c>();
            if(mapaIdCuentaDeConversionCandidatoConDireccion!=null && mapaIdCuentaDeConversionCandidatoConDireccion.size()>0)
            {
                for(String cuentaId: mapaIdCuentaDeConversionCandidatoConDireccion.keySet())
                {
                    candidato = mapaIdCuentaDeConversionCandidatoConDireccion.get(cuentaId);
                    
                    Direcci_n_de_entrega__c direccion = new Direcci_n_de_entrega__c();
                    direccion.Cuenta__c = cuentaId;
                    direccion.Direccion__c = candidato.Contact_Address__c;
                    direccion.Codigo_Postal__c = candidato.Codigo_Postal__c;
                    direccion.Poblacion__c = candidato.Contact_City__c;
                    direccion.Provincia__c = candidato.Contact_State__c;
                    direccion.Pais__c = candidato.PaisContacto__c;
                    direccion.Actividad_1__c = candidato.Actividad__c;
                    direccion.Actividad_2__c = candidato.Sub_actividad__c;
                    direccion.Tipo_de_direccion_de_envio__c = 'BULK';
                    
                    //listaDireccionesInsert.add(direccion);
                    
                    Direcci_n_de_entrega__c direccionEntregaAux = null;
                    if (cuentasConDireccionesEntrega.size() > 0 && cuentasConDireccionesEntrega.containsKey(cuentaId))
                    {
                        for(Direcci_n_de_entrega__c dir : cuentasConDireccionesEntrega.get(cuentaId))
                        {
                            System.debug('##Comprobando direccion entrega');
                            direccionEntregaAux = WSDatosOfertas.gestionarDirecciones(dir, direccion);
                            if(direccionEntregaAux != null)
                            {
                                System.debug('##Existe una direccion');
                                DireccionEnvioUtil.semaforoUpdate = false;
                                
                                direccionEntregaAux.cuenta__c = cuentaId;
                                direccionEntregaAux.Id = dir.Id;
                                update direccionEntregaAux;
                                
                                DireccionEnvioUtil.semaforoUpdate = true;
                                
                                break;
                            }
                        }
                        
                        // si después del for, direccionEntrega sigue siendo null es que no se ha encontrado ninguna que coincida y habrá que insertarla
                        if(direccionEntregaAux == null)
                        {
                            listaDireccionesInsert.add(direccion);
                            System.debug('##Ninguna coincidencia');
                            
                        }
                    }else{
                        listaDireccionesInsert.add(direccion);
                        System.debug('##No tiene direcciones de entrega');
                    }
                    
                }
                
                
                
                if(listaDireccionesInsert!= null && listaDireccionesInsert.size()>0)
                {
                    DireccionEnvioUtil.semaforoUpdate = false;
                    res = Database.insert(listaDireccionesInsert, false);
                    System.debug('##Insertando direccion');
                    
                    DireccionEnvioUtil.semaforoUpdate = true;
                    
                    for(Database.SaveResult r: res)
                    {
                        if(!r.isSuccess())
                        {
                            Database.Error error = r.getErrors()[0];
                            LogUtil.crearLog('Error al crear la dirección de entrega de la cuenta en la conversión - Message: '+ error.getMessage(), 'insertarDatosConversionCuentaYOportunidad', 'Dirección de entrega (Cuenta)', 'Insert', true);
                            //Parametros crearLog: String descripcion, String metodo, String objeto, String tipoError, Boolean isError
                        }
                    }
                }
                System.debug('##listaDireccionesInsert: ' + listaDireccionesInsert);
            }
            
            /*Para cada cuenta creada de una conversión, se le crean en la lista estándar de socios los socios de candidato del candidato origen.*/
            /*if(mapaIdsCuentasDeConversionListaSociosCandidato!=null && mapaIdsCuentasDeConversionListaSociosCandidato.size()>0)
{
List<Partner> listaSociosEstandar = new List<Partner>();
for(Id idCuentaConvertida : mapaIdsCuentasDeConversionListaSociosCandidato.keySet())
{
for(Socio_de_candidato__c socioCandidato : mapaIdsCuentasDeConversionListaSociosCandidato.get(idCuentaConvertida))
{
Partner socio = new Partner();
socio.AccountFromId = idCuentaConvertida; //Id de la cuenta principal en la relacion de partner
socio.AccountToId = socioCandidato.Socio__c; //Id del socio en la relacion de partner
socio.Role = socioCandidato.Funcion__c; //Rol del socio hacia la cuenta principal
listaSociosEstandar.add(socio);
}               
}
System.debug('listaSociosEstandar a insertar: ' + listaSociosEstandar);

if(listaSociosEstandar!= null && listaSociosEstandar.size()>0)
{
Database.SaveResult[] res1 = Database.insert(listaSociosEstandar, false);
for(Database.SaveResult r: res1)
{
if(!r.isSuccess())
{
Database.Error error = r.getErrors()[0];
LogUtil.crearLog('Error al crear el socio de la cuenta '+ r.getId() +' en la conversión - Message: '+ error.getMessage(), 'insertarDatosConversionCuentaYOportunidad', 'Partner (Cuenta)', 'Insert', true);
//Parametros crearLog: String descripcion, String metodo, String objeto, String tipoError, Boolean isError
}
}
}
}*/
            
            ///////////////////////////////////////////////INSERTO INFORMACION DE OPORTUNIDAD///////////////////////////////////////////////////
            /*Para cada oportunidad creada de una conversión, se le crean las energías actuales del candidato origen.*/
            if(mapaIdsOportunidadesDeconversionListaEnergiasActuales!=null && mapaIdsOportunidadesDeconversionListaEnergiasActuales.size()>0)
            {
                //Recorro todas las energias de cada oportunidad convertida y relleno su campo oportunidad con la oportunidad convertida
                List<Energia_actual__c> listaEnergiasActualizar = new List<Energia_actual__c>();
                for(Id idOportunidadConvertida : mapaIdsOportunidadesDeconversionListaEnergiasActuales.keySet())
                {
                    for(Energia_actual__c energia: mapaIdsOportunidadesDeconversionListaEnergiasActuales.get(idOportunidadConvertida))
                    {
                        energia.Oportunidad__c = idOportunidadConvertida;
                        listaEnergiasActualizar.add(energia);
                    }
                }
                
                if(listaEnergiasActualizar!= null && listaEnergiasActualizar.size()>0)
                {
                    res = Database.update(listaEnergiasActualizar, false);
                    for(Database.SaveResult r: res)
                    {
                        if(!r.isSuccess())
                        {
                            Database.Error error = r.getErrors()[0];
                            LogUtil.crearLog('Error al actualizar el campo oportunidad de la Energía Actual '+ r.getId() +' - Message: '+ error.getMessage(), 'insertarDatosConversionCuentaYOportunidad', 'Energía Actual', 'Update', true);
                            //Parametros crearLog: String descripcion, String metodo, String objeto, String tipoError, Boolean isError
                        }
                    }
                }
            }
            
            /*Para cada oportunidad creada de una conversión, se le crean los equipos actuales del candidato origen.*/
            /*if(mapaIdsOportunidadesDeconversionListaEquiposActuales!=null && mapaIdsOportunidadesDeconversionListaEquiposActuales.size()>0)
{
//Recorro todos los equipos de cada oportunidad convertida y relleno su campo oportunidad con la oportunidad convertida
List<Equipo_actual__c> listaEquiposActualizar = new List<Equipo_actual__c>();
for(Id idOportunidadConvertida : mapaIdsOportunidadesDeconversionListaEquiposActuales.keySet())
{
for(Equipo_actual__c equipo: mapaIdsOportunidadesDeconversionListaEquiposActuales.get(idOportunidadConvertida))
{
equipo.Oportunidad__c = idOportunidadConvertida;
listaEquiposActualizar.add(equipo);
}
}

if(listaEquiposActualizar!= null && listaEquiposActualizar.size()>0)
{
Database.SaveResult[] res3 = Database.update(listaEquiposActualizar, false);
for(Database.SaveResult r: res3)
{
if(!r.isSuccess())
{
Database.Error error = r.getErrors()[0];
LogUtil.crearLog('Error al actualizar el campo oportunidad del Equipo Actual '+ r.getId() +' - Message: '+ error.getMessage(), 'insertarDatosConversionCuentaYOportunidad', 'Equipo Actual', 'Update', true);
//Parametros crearLog: String descripcion, String metodo, String objeto, String tipoError, Boolean isError
}
}
}
}*/ 
            
            /*Para cada oportunidad creada de una conversión, se le crean en la lista estándar de socios los socios de candidato del candidato origen.*/
            if(mapaIdsOportunidadesDeConversionListaSociosCandidato!=null && mapaIdsOportunidadesDeConversionListaSociosCandidato.size()>0)
            {
                List<Partner> listaSocios = new List<Partner>();
                for(Id idOportunidadConvertida : mapaIdsOportunidadesDeConversionListaSociosCandidato.keySet())
                {
                    for(Socio_de_candidato__c socioCandidato : mapaIdsOportunidadesDeConversionListaSociosCandidato.get(idOportunidadConvertida))
                    {
                        Partner socio = new Partner();
                        socio.OpportunityId = idOportunidadConvertida;
                        socio.AccountToId = socioCandidato.Socio__c;
                        socio.Role = socioCandidato.Funcion__c;
                        listaSocios.add(socio);
                    }               
                }
                System.debug('listaSocios a insertar: ' + listaSocios);
                
                if(listaSocios!= null && listaSocios.size()>0)
                {
                    res = Database.insert(listaSocios, false);
                    for(Database.SaveResult r: res)
                    {
                        if(!r.isSuccess())
                        {
                            Database.Error error = r.getErrors()[0];
                            LogUtil.crearLog('Error al crear el socio de la oportunidad '+ r.getId() +' en la conversión - Message: '+ error.getMessage(), 'insertarDatosConversionCuentaYOportunidad', 'Partner (Oportunidad)', 'Insert', true);
                            //Parametros crearLog: String descripcion, String metodo, String objeto, String tipoError, Boolean isError
                        }
                    }
                }
            }
        }   
    }
    
    
    /**
*   Recupera los registros Persona a los que estan asociados los candidatos
**
*  @author rfernandez
*  @date 15/05/2018
*  @param list<Lead> leadList - Lista de leads
*  @where Bulk after 
*/
    public static void recuperarPersonas(List<Lead> leadList, Map<Id, Lead> oldMap)
    {
        Set<Id> personasByIdList = new Set<Id>();
        
        if(leadList != null)
        {
            for(Lead candidato : leadList)
            {
                if(candidato.IndividualId != null)
                {
                    personasByIdList.add(candidato.IndividualId);
                }
            }
        }else//Para el after delete
        {
            for(Lead candidato : oldMap.values())
            {
                if(candidato.IndividualId != null)
                {
                    personasByIdList.add(candidato.IndividualId);
                }
            }
        }
        
        for(Individual persona : [SELECT Id, Email__c, FirstName, LastName FROM Individual WHERE Id IN: personasByIdList])
        {
            personasMap.put(persona.Id, persona);
        }
    }
    
    /**
*   Crea un nuevo registro persona en caso de no existir y asigna el candidato a este registro
**
*  @author rfernandez
*  @date 15/05/2018
*  @param list<Lead> leadList - Lista de leads
*  @where Before insert 
*/
    public static void crearRegistrosPersona(List<Lead> leadList)
    {
        Map<Lead, Individual> candidatoPersonaMap = new Map<Lead, Individual>();
        Set<Id> personasIdsList = new Set<Id>();
        
        Individual nuevaPersona;
        for(Lead candidato : leadList)
        {
            if(candidato.IndividualId == null)
            {
                nuevaPersona = new Individual(
                    FirstName   = candidato.FirstName, 
                    LastName    = candidato.LastName, 
                    Salutation  = candidato.Salutation, 
                    Email__c    = candidato.Email); 
                candidatoPersonaMap.put(candidato, nuevaPersona);
            }
        }
        
        //Insercion de nuevas personas
        if(!candidatoPersonaMap.isEmpty())
        {
            insert candidatoPersonaMap.values();
        }
        
        //Generamos el hash para cada persona. Necesitamos el Id de la persona para generar el hash.
        for(Individual persona : candidatoPersonaMap.values())
        {
            personasIdsList.add(persona.Id);
        }
        
        Map<Id, String> idHashMap = Util.calcularHashMasivo(personasIdsList);
        
        for(Individual persona : candidatoPersonaMap.values())
        {
            if(idHashMap.containsKey(persona.Id))
            {
                persona.Hash__c = idHashMap.get(persona.Id);
            }
        }
        
        //Actualizamos las personas para generar el hash
        if(!candidatoPersonaMap.isEmpty())
        {
            update candidatoPersonaMap.values();
        }
        
        //Volvemos a recorrer los candidatos para asignarle la persona correspondiente
        for(Lead candidato : leadList)
        {
            if(candidatoPersonaMap.containsKey(candidato))
            {
                candidato.IndividualId = candidatoPersonaMap.get(candidato).Id;
            }
        }
    }
    
    /**
*   Si los datos entre el candidato y la persona no coinciden, se actualiza la persona.
**
*  @author rfernandez
*  @date 15/05/2018
*  @param list<Lead> leadList - Lista de leads
*  @where Before insert 
*/
    public static void actualizarRegistrosPersona(List<Lead> leadList)
    {
        for(Lead candidato : leadList)
        {
            if(candidato.IndividualId != null && personasMap.containsKey(candidato.IndividualId) && 
               (       candidato.FirstName != personasMap.get(candidato.IndividualId).FirstName 
                ||  candidato.LastName  != personasMap.get(candidato.IndividualId).LastName 
                ||  candidato.Email     != personasMap.get(candidato.IndividualId).Email__c)
              )
            {
                Individual persona = personasMap.get(candidato.IndividualId);
                persona.FirstName   = candidato.FirstName;
                persona.LastName    = candidato.LastName; 
                persona.Email__c    = candidato.Email; 
                personasToUpdate.put(persona.Id, persona);
            }
        }
    }
    
    /**
*   Borra los registros persona siempre y cuando no exista un registro asociado a ellos.
**
*  @author rfernandez
*  @date 15/05/2018
*  @param list<Lead> leadList - Lista de leads
*  @where After delete 
*/
    public static void eliminarRegistroPersona(Map<Id, Lead> oldMap)
    {
        if(!personasMap.isEmpty())
        {
            Set<Id> personasNoEliminables = new Set<Id>();
            
            //recuperamos personas que siguen referenciadas por otros candidatos, cuentas o contactos
            personasNoEliminables = Util.recuperarRegistrosQueApuntenAPersonas('Lead', 'IndividualId', personasNoEliminables, personasMap);
            personasNoEliminables = Util.recuperarRegistrosQueApuntenAPersonas('Account', 'PersonIndividualId', personasNoEliminables, personasMap);
            personasNoEliminables = Util.recuperarRegistrosQueApuntenAPersonas('Contact', 'IndividualId', personasNoEliminables, personasMap);
            
            //personasMap contiene todas las personas a las que estaba asociados los leads
            for(Lead candidato : oldMap.values())
            {
                if(!personasNoEliminables.contains(candidato.IndividualId) && personasMap.containsKey(candidato.IndividualId))
                {
                    personasToDelete.put(personasMap.get(candidato.IndividualId).Id, personasMap.get(candidato.IndividualId));
                }
            }
        }
    }
    
    /**
*   Execute DMLs after data process
**
*  @author rfernandez
*  @date 17/05/2018    
*  @where andFinally
*/
    public static void insertUpdateDeleteRecords()
    {
        
        if(!personasToUpdate.isEmpty())
        {   
            update personasToUpdate.values();
        }
        
        if(!personasToDelete.isEmpty())
        {   
            delete personasToDelete.values();
        }
        
        personasToUpdate.clear();
        personasToDelete.clear();
    }
}