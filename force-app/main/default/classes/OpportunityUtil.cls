public class OpportunityUtil
{
	public static Boolean semaforoCreacionFuncionesDeContacto = true;


	/*En la actualización o creación de una oportunidad, se comprueba que haya un presupuesto asociado a la 
	oportunidad si se va a cambiar el campo estado a "Negociación / Revisión". Si no hay un presupuesto relacionado, se 
	muestra el mensaje de error correspondiente. Se le llama desde el trigger beforeinsert y beforeupdate de oportunidad.*/
	/*public static void comprobarEstadoNegociacion(List<Opportunity> listaOportunidades)
	{
		List<Id> listaIdsOportunidadesComprobar = new List<Id>();
		List<Opportunity> listaOportunidadesComprobar = new List<Opportunity>();
		for(Opportunity oportunidad: listaOportunidades)
		{
			if(oportunidad.StageName=='Negociación / Revisión')
			{
				listaIdsOportunidadesComprobar.add(oportunidad.Id);
				listaOportunidadesComprobar.add(oportunidad);
			}
		}
		System.debug('listaOportunidadesComprobar: ' + listaOportunidadesComprobar);

		List<Quote> listaPresupuestos = [SELECT Id, Name, OpportunityId FROM Quote WHERE OpportunityId IN: listaIdsOportunidadesComprobar];
		System.debug('listaPresupuestos: ' + listaPresupuestos);
		Boolean encontrado;
		for(Opportunity oportunidad: listaOportunidadesComprobar)
		{
			encontrado = false;
			for(Quote presupuesto: listaPresupuestos)
			{
				if(oportunidad.Id == presupuesto.OpportunityId)
				{
					encontrado = true;
					break;
				}
			}
			if(!encontrado)
			{
				oportunidad.addError('La etapa de la oportunidad no puede ser "Negociación / Revisión", ya que no existe ningún presupuesto asociado a la oportunidad.');
			}
		}
	}*/


	/*En la actualización o creación de una oportunidad, se comprueba que haya un contrato firmado asociado a la 
	oportunidad si se va a cambiar el campo estado a “Cerrada ganada”. Si no lo hay, se muestra el mensaje de error 
	correspondiente. Se le llama desde el trigger beforeinsert y beforeupdate de oportunidad.*/
	/*public static void comprobarEstadoCerradaGanada(List<Opportunity> listaOportunidades)
	{
		List<Id> listaIdsOportunidadesComprobar = new List<Id>();
		List<Opportunity> listaOportunidadesComprobar = new List<Opportunity>();
		for(Opportunity oportunidad: listaOportunidades)
		{
			if(oportunidad.StageName=='Cerrada ganada')
			{
				listaIdsOportunidadesComprobar.add(oportunidad.Id);
				listaOportunidadesComprobar.add(oportunidad);
			}
		}
		System.debug('listaOportunidadesComprobar: ' + listaOportunidadesComprobar);

		List<Opportunity> listaOportunidadesConContrato = [SELECT Id, Name, Contract.CustomerSignedId, Contract.CompanySignedId FROM Opportunity WHERE Id IN: listaIdsOportunidadesComprobar
															and ContractId!=null and (Contract.CustomerSignedId != null or Contract.CompanySignedId != null)];
		System.debug('listaOportunidadesConContrato: ' + listaOportunidadesConContrato);
		Boolean encontrado;
		for(Opportunity oportunidadComprobar: listaOportunidadesComprobar)
		{
			encontrado = false;
			for(Opportunity oportunidadConContrato: listaOportunidadesConContrato)
			{
				if(oportunidadComprobar.Id == oportunidadConContrato.Id)
				{
					encontrado = true;
					break;
				}
			}
			if(!encontrado)
			{
				oportunidadComprobar.addError('La etapa de la oportunidad no puede ser "Cerrada ganada", ya que no existe ningún contrato firmado asociado a la oportunidad.');
			}
		}*/
		/*List<Contract> listaContratosDeOportunidades = [SELECT Id, Name, CustomerSignedId, CompanySignedId, Oportunidad__c FROM Contract WHERE Oportunidad__c IN: listaIdsOportunidadesComprobar];
		System.debug('listaContratosDeOportunidades: ' + listaContratosDeOportunidades);
		Boolean encontrado;
		for(Opportunity oportunidadComprobar: listaOportunidadesComprobar)
		{
			encontrado = false;
			for(Contract contratoDeOportundidad: listaContratosDeOportunidades)
			{
				if(contratoDeOportundidad.Oportunidad__c == oportunidadComprobar.Id && (contratoDeOportundidad.CustomerSignedId != null || contratoDeOportundidad.CompanySignedId !=  null))
				{
					encontrado = true;
					break;
				}
			}
			if(!encontrado)
			{
				oportunidadComprobar.addError('La etapa de la oportunidad no puede ser "Cerrada ganada", ya que no existe ningún contrato firmado asociado a la oportunidad.');
			}
		}*/
	//}

	/**
	* Metodo encargado de crear funciones de contacto para las oportunidades creadas desde Salesforce
	* @author rfernandez (16/02/2017)
	* @modificaciones 
	*/
	public static void crearFuncionesDeContacto(List<Opportunity> listaOportunidades)
	{
		/*¿Como funciona? Se pueden crear oportunidades desde WSDatosOfertas, al convertir un candidato o a mano
		En los dos primeros casos ya se crean funciones de contacto, por lo que solo queremos crear en el trigger cuando sea a mano

		Tenemos en Lead un campo checkbox Procede_de_conversion__c = true
		Tenemos en Cuenta un campo checkbox Procede_de_conversion__c mapeado con el anterior al convertir el Lead
			Cuando se convierte un candidato se pasa ese valor a cuenta
		Tenemos una variable de clase en opportunityUtil por defecto a true
		En el trigger de cuenta, before insert miramos si Procede_de_conversion__c es true. Si es asi, cambiamos la variable de clase de opportunity util a true
			al ser el mismo tiempo de ejecución para que no cree la función, que ya se crea alli
			La cambiamos tambien cuando hay una peticion a WSDatosOfertas
		Aquí comprobamos esa variable de clase para saber cuando se está creando a mano desde SF
		*/
		System.debug('##crearFuncionesDeContacto antes de semaforo');
		if(semaforoCreacionFuncionesDeContacto == true)
		{
			System.debug('##crearFuncionesDeContacto dentro de semaforo');
			List<Id> idCuentasList = new List<Id>();

			//Obtengo las cuantos a las que está asociada la oportunidad
			for(Opportunity oportunidad : listaOportunidades)
			{
				idCuentasList.add(oportunidad.AccountId);
			}

			
			//Obtengo un mapa con las cuentas y los contactos de la cuenta
			Map<Id,list<Contact>> cuentaConContactosMap = new Map<Id, list<Contact>>();
	        for(Contact contacto: [SELECT Id, AccountId FROM Contact WHERE AccountId IN: idCuentasList])
	        {            
	            if (!cuentaConContactosMap.containsKey(contacto.AccountId))
	            {
	                cuentaConContactosMap.put(contacto.AccountId, new list<Contact>());
	                cuentaConContactosMap.get(contacto.AccountId).add(contacto);
	            }
	            else
	            {
	                cuentaConContactosMap.get(contacto.AccountId).add(contacto);
	            }
	        }

	        List<OpportunityContactRole> funcionesDeContactoList = new List<OpportunityContactRole>();

	        //Recorremos las oportunidades y vamos relacionado la oportunidad con los contactos para crear opportunityContactRoles
	        for(Opportunity oportunidad : listaOportunidades)
			{
				Id idDeCuenta = oportunidad.AccountId;
				Id idOportunidad = oportunidad.Id;
				if(cuentaConContactosMap.containsKey(idDeCuenta))
				{
					for(Contact contactoRecuperado: cuentaConContactosMap.get(idDeCuenta))
					{
						funcionesDeContactoList.add(new OpportunityContactRole(ContactId = contactoRecuperado.Id, OpportunityId = idOportunidad, Role='Firmante de contrato'));
					}
				}
			}

			if(!funcionesDeContactoList.isEmpty()) 
			{
				insert funcionesDeContactoList;
			}           
		}
	}

	public static void setCountyGasRates(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities) {
		Set<Id> affectedOpportunityIds = new Set<Id>();
		for (Opportunity newOpportunity : newOpportunities) {
            if (needsCountyGasRateRecalculation(newOpportunity, oldOpportunities)) {
				affectedOpportunityIds.add(newOpportunity.Id);
			}
		}
		if (!affectedOpportunityIds.isEmpty()) {
			List<SBQQ__Quote__c> affectedQuotes = CPQ_QuoteRepository.getOpportunityDraftQuotes(affectedOpportunityIds);
			if (!affectedQuotes.isEmpty()) {
				CPQ_Quote.setCountyGasRates(affectedQuotes);
				update affectedQuotes;
			}
		}
	}

    private static Boolean needsCountyGasRateRecalculation(Opportunity newOpportunity, Map<Id, Opportunity> oldOpportunities) {
        return String.isNotBlank(newOpportunity.County__c) && oldOpportunities.get(newOpportunity.Id).County__c != newOpportunity.County__c;
    }
}