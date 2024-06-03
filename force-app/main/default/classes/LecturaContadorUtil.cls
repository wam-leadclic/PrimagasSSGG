public with sharing class LecturaContadorUtil {

	//Metodo encargado de enviar a Navision las lecturas contador que se generen en SF
	public static void SincronizarLecturasContador(list<Lectura_contador__c> newList)
	{
		//Ids de los pedidos de gas que van a ser enviados a Navision
		List<String> lecturasContadorSync = new List<String>();
		
		for(Lectura_contador__c lecturaContador : newList)
		{
			lecturasContadorSync.add(lecturaContador.Id);
		}
		SyncNav.SincronizarLecturasContadorFuture(lecturasContadorSync);
	}
}