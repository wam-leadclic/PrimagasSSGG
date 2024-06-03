public with sharing class DireccionEnvioUtil {
	
	public static Map<String, String> mapaTiposRegistro;

	// Añadimos una variable semáforo para evitar las llamadas en bucle a sincronización de registros con Navision dado que tras
	// la sincronización se actualiza el ID de Navision y la última fecha de sincronización
	public static Boolean semaforoUpdate = true;

	public static void loadData(list<Direcci_n_de_entrega__c> newList, map<String, Account> mapaClientes /*, map<String, String> mapaRecordTypeIDs*/ )
	{
		System.Debug('## before loadData mapaCLientes: ' + mapaClientes);
		if (newList != null)
		{
			List<String> clienteIDs = new List<String>();
			for (Direcci_n_de_entrega__c de:newList)
			{
				clienteIDs.add(de.cuenta__c); 
			}

			List<Account> clientes = new List<Account>([Select Id, Name, Id_Navision__c, Recordtype.DeveloperName from Account where Id in :clienteIDs]);

			for (Account cliente:clientes)
			{
				mapaClientes.put(cliente.Id, cliente);
			}
		}
		System.Debug('## after loadData mapaClientes: ' + mapaClientes);
	}
    

	public static void SincronizarClientes(list<Direcci_n_de_entrega__c> newList, Map<String, Account> mapaClientes)
	{
		System.Debug('## before SincronizarClientes semaforoUpdate: ' + semaforoUpdate);
		if (semaforoUpdate)
		{
			List<Account> listaCuentas = new List<Account>();
			
			for(Id idCuentaTemp : mapaClientes.KeySet())
			{
				listaCuentas.add(mapaClientes.get(idCuentaTemp));
			}
			
			// Recuperamos el tipo de registro "Cliente existente"
			RecordType rts = Util.objectsRecordTypesMap.get('Account').get('Cliente_existente');
			
			if (listaCuentas != null && listaCuentas.size()>0)
			{
				List<String> clientesSync = new List<String>();
				
				for (Account cliente:listaCuentas)
				{
					// Se hace doble validación, se comprueba que sea de tipo de registro Cliente existente y que tenga algún contrato Activado
					if ( cliente.RecordTypeId == rts.Id  && !String.IsEmpty(cliente.Id_Navision__c))
					{
						clientesSync.add(cliente.Id);
					}
				}
				// Enviamos los clientes correspondientes a sincronizar
				System.debug('Clientes a sincronizar -> ' + clientesSync);
				if(clientesSync.size() > 0)
				{
					SyncNav.SincronizarClientesFuture(clientesSync);
				}
			}
		}		 
		System.Debug('## after SincronizarClientes semaforoUpdate: ' + semaforoUpdate);
	}
    
    public static void ComprobarContratos(List<Direcci_n_de_entrega__c> Direcciones){
        List<Contract> ContrRel = [Select id,DateFirstFilled__c,Duraci_n_del_contrato_a_os__c,Estado_2__c,ActivatedDate from Contract Where Direccion_de_entrega__c =: Direcciones];
        ContractUtil.populateContractEndDate(ContrRel);
    }
    
}