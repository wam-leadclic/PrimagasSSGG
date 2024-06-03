public with sharing class PedidoGasUtil {

	//Metodo encargado de enviar a Navision los pedidos de gas que se generen en SF
	public static void SincronizarPedidoDeGas(list<Pedido_de_gas__c> newList)
	{
		//Ids de los pedidos de gas que van a ser enviados a Navision
		List<String> pedidosGasSync = new List<String>();
		
		for(Pedido_de_gas__c pedidoGas : newList)
		{
			pedidosGasSync.add(pedidoGas.Id);
		}
		SyncNav.SincronizarPedidosDeGasFuture(pedidosGasSync);
	}
}