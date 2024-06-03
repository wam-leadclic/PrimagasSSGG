public with sharing class PedidosDeGasPageController 
{
	public List<Pedido_de_gas__c> pedidosDeGas {get; set;}
	public Boolean hayPedidos {get; set;}
	public Boolean hayError {get; set;}

	public PedidosDeGasPageController() 
	{
		hayError = false;
		hayPedidos = false;

		pedidosDeGas = new List<Pedido_de_gas__c>();

		//Recuperar la informacion de la url para hacer la llamada al servicio web
		Id idDireccionEntrega = apexpages.currentpage().getparameters().get('id');

		//Al servicio web hay que mandarle el id de nav del cliente para que devuelva todos los pedidos, que vendran con el id de la direccion de entrega a la que hace referencia para filtrarlo
		List<Direcci_n_de_entrega__c> direccionEntrega = [SELECT Id, cuenta__r.Id, Id_navision__c, cuenta__r.Id_navision__c FROM Direcci_n_de_entrega__c  WHERE Id =: idDireccionEntrega];
		
		//Recuperar los pedidos de gas y parsear la respuesta
		List<Pedido_de_gas__c> pedidosDeGasNav = SyncNav.ConsultarPedidosDeGas(direccionEntrega[0].cuenta__r.Id_navision__c);
		
		//Obtener los pedidos de gas para mostrarlos en la vf (hay que filtrarlos segun los que pertenezca a esa direccion de entrega)
		if(pedidosDeGasNav != null)
		{
			for(Pedido_de_gas__c pedidoDeGas : pedidosDeGasNav)
			{	
				if(pedidoDeGas.Id_Navision_Direccion_de_entrega__c == direccionEntrega[0].Id_navision__c)
				{
					pedidosDeGas.add(pedidoDeGas);
				}
			}
		}else{
			hayError = true;
		}

		if(pedidosDeGas.size() > 0 && !hayError)
		{
			ordenarPedidosPorFecha();
			hayPedidos = true;
		}
	}

	// Ordenar los Pedidos de gas por Fecha__c
 	public void ordenarPedidosPorFecha() {
        Integer n = pedidosDeGas.size();
        // Variable temporal para almacenar los pedidos 
        Pedido_de_gas__c temp = new Pedido_de_gas__c();                   
        
        for (Integer i = 0; i < n; i++) {
            for (Integer j = 1; j < (n-i); j++) {   
                // Ordena por Fecha__c en orden descendente. Para hacerlo en orden ascendente cambiar "<" por ">"   
                if ((Date)pedidosDeGas[j-1].get('Fecha__c') < (Date)pedidosDeGas[j].get('Fecha__c')) {   
                     temp = pedidosDeGas[j-1];
                     pedidosDeGas[j-1] = pedidosDeGas[j];
                     pedidosDeGas[j] = temp;
                }            
            }
        }
    }
	
	@AuraEnabled
	public static  ActionResult getOrders(String recordId) {
		ActionResult result = new ActionResult();
		try {
			List<Pedido_de_gas__c> data = new List<Pedido_de_gas__c>();
			Direcci_n_de_entrega__c address = [
				SELECT 
					Id, cuenta__r.Id_navision__c,Id_navision__c 
				FROM Direcci_n_de_entrega__c  
				WHERE Id =: recordId
			];
			List<Pedido_de_gas__c> gasOrders = SyncNav.ConsultarPedidosDeGas(address.cuenta__r.Id_navision__c);
			for (Pedido_de_gas__c r : gasOrders) {
				if (r.Id_Navision_Direccion_de_entrega__c == address.Id_navision__c) {
					data.add(r);
				} 
			} 
			result.data = JSON.serialize(data);
		} catch( Exception ex) {
			result.hasError = true;
			result.message = ex.getMessage();
		}
		return result;	
	}
}