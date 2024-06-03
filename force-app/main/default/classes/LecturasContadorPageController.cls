public with sharing class LecturasContadorPageController {
	
	public List<Lectura_contador__c> lecturasContador {get; set;}
	public Boolean hayLecturas {get; set;}
	public Boolean hayError {get; set;}

	public LecturasContadorPageController() 
	{
		hayError = false;
		hayLecturas = false;

		lecturasContador = new List<Lectura_contador__c>();

		//Recuperar la informacion de la url para hacer la llamada al servicio web
		Id idDireccionEntrega = apexpages.currentpage().getparameters().get('id');

		//Al servicio web hay que mandarle el id de nav del cliente para que devuelva todos los pedidos, que vendran con el id de la direccion de entrega a la que hace referencia para filtrarlo
		List<Direcci_n_de_entrega__c> direccionEntrega = [SELECT Id_navision__c, cuenta__r.Id_navision__c FROM Direcci_n_de_entrega__c  WHERE Id =: idDireccionEntrega];
		
		//Recuperar los pedidos de gas y parsear la respuesta
		List<Lectura_contador__c> lecturasContadorNav = SyncNav.ConsultarLecturasContador(direccionEntrega[0].cuenta__r.Id_navision__c);

		//Obtener los pedidos de gas para mostrarlos en la vf (hay que filtrarlos segun los que pertenezca a esa direccion de entrega)
		if(lecturasContadorNav != null)
		{
			for(Lectura_contador__c lecturaContador : lecturasContadorNav)
			{	
				if(lecturaContador.Id_Navision_Direccion_de_entrega__c == direccionEntrega[0].Id_navision__c && lecturaContador.Lectura__c != 0)
				{
					lecturasContador.add(lecturaContador);
				}
			}
		}else{
			hayError = true;
		}

		if(lecturasContador.size() > 0 && !hayError)
		{
			ordenarLecturasPorFecha();
			hayLecturas = true;
		}
	}

	// Ordena las Lecturas Contador por Fecha__c. 
 	public void ordenarLecturasPorFecha() {
        Integer n = lecturasContador.size();
        //Variable temporal para almacenar lecturas
        Lectura_contador__c temp = new Lectura_contador__c();                   
        
        for (Integer i = 0; i < n; i++) {
            for (Integer j = 1; j < (n-i); j++) {   
                // Ordena por Fecha__c en orden descendente. Para hacerlo en orden ascendente cambiar "<" por ">"   
                if ((Date)lecturasContador[j-1].get('Fecha__c') < (Date)lecturasContador[j].get('Fecha__c')) {   
                     temp = lecturasContador[j-1];
                     lecturasContador[j-1] = lecturasContador[j];
                     lecturasContador[j] = temp;
                }            
            }
        }
    }  

	@AuraEnabled
	public static  ActionResult getReads(String recordId) {
		ActionResult result = new ActionResult();
		try {
			List<Lectura_contador__c> data = new List<Lectura_contador__c>();
			Direcci_n_de_entrega__c address = [
				SELECT 
					Id, cuenta__r.Id_navision__c,Id_navision__c 
				FROM Direcci_n_de_entrega__c  
				WHERE Id =: recordId
			];
			List<Lectura_contador__c> reads = SyncNav.ConsultarLecturasContador(address.cuenta__r.Id_navision__c);
			for (Lectura_contador__c r : reads) {
				if (r.Id_Navision_Direccion_de_entrega__c == address.Id_navision__c && r.Lectura__c != 0) {
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