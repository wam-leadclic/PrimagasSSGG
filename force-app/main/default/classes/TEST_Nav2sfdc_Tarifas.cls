@isTest
public class TEST_Nav2sfdc_Tarifas {

	static testMethod void testPeticionWSConsultarTarifasInsercion()
	{
		Test.startTest();
		//En esta ocasión el XML viene sin los Ids de SF - Inserción
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl('', '', true));
		Nav2sfdc_Tarifas batchTarifas = new Nav2sfdc_Tarifas();
    	batchTarifas.execute(null);
    	Test.stopTest();
		
		List<Pricebook2> listaPrecios = [select IsActive, Pendiente_de_confirmar__c, Id_Navision__c, Name, Description, Id from Pricebook2];
		//Se verifica que se han insertado las cuentas
		System.assertEquals(listaPrecios.size(),2);
		
		//Comprobamos que se han insertado correctamente los campos
		boolean encontradoTarifa1 = false;
		boolean encontradoTarifa2 = false;
		
		for(Pricebook2 pb : listaPrecios)
		{
			if(pb.Description == 'Descripcion tarifa 2' && pb.Id_Navision__c == '90000013' && pb.Name == pb.Description)
				encontradoTarifa2 = true;
			else if(pb.Description == 'Descripcion tarifa 1' && pb.Id_Navision__c == '90000012' && pb.Name == pb.Description)
				encontradoTarifa1 = true;
				
			//Comprobamos que se ha puesto pendiente de confirmar, posteriormente son procesados por el Batch Nav2sfdc_Tarifas_Confirmacion
			System.assertEquals(pb.Pendiente_de_confirmar__c,true);
			
			//Comprobamos que se ha insertado como activa, todas las que se reciben en este job son activas
			//con lo que pueden ser seleccionadas por el usuario cuando se crea un contrato
			System.assertEquals(pb.IsActive,true);
		}
		
		//Comprobamos que se ha creado correctamente la primera tarifa en SF con el XML simulado del servidor
		System.assertEquals(true,encontradoTarifa1);
		
		//Comprobamos que se ha creado correctamente la segunda tarifa en SF con el XML simulado del servidor
		System.assertEquals(true,encontradoTarifa2);
	}
	
	static testMethod void testPeticionWSConsultarTarifasActualizacion()
	{
		List<Pricebook2> listaPrecios = new List<Pricebook2>();
		Pricebook2 pb1 = new Pricebook2();
		pb1.Name = 'Desc1';
		pb1.Id_Navision__c = 'IdNav1';
		pb1.Description = 'Desc1';
		pb1.IsActive = false;
		
		listaPrecios.add(pb1);
		
		Pricebook2 pb2 = new Pricebook2();
		pb2.Name = 'Desc2';
		pb2.Id_Navision__c = 'IdNav2';
		pb2.Description = 'Desc2';
		pb2.IsActive = false;
		
		listaPrecios.add(pb2);
		
		insert listaPrecios;
		
		boolean encontradoTarifa1 = false;
		boolean encontradoTarifa2 = false;
		
		for(Pricebook2 pb : listaPrecios)
		{
			if(pb.Description == 'Desc2' && pb.Id_Navision__c == 'IdNav2' && pb.Name == pb.Description)
				encontradoTarifa2 = true;
			else if(pb.Description == 'Desc1' && pb.Id_Navision__c == 'IdNav1' && pb.Name == pb.Description)
				encontradoTarifa1 = true;
				
				System.assertEquals(pb.IsActive,false);
		}
		
		//Comprobamos que se ha creado correctamente la primera tarifa en SF
		System.assertEquals(true,encontradoTarifa1);
		
		//Comprobamos que se ha creado correctamente la segunda tarifa en SF
		System.assertEquals(true,encontradoTarifa2);
		
		Test.startTest();
		//En esta ocasión el XML viene con los Ids de SF - Actualización
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(pb1.Id, pb2.Id, true));
		Nav2sfdc_Tarifas batchTarifas = new Nav2sfdc_Tarifas();
    	batchTarifas.execute(null);
    	Test.stopTest();
		
		listaPrecios = [select IsActive, Pendiente_de_confirmar__c, Id_Navision__c, Name, Description, Id from Pricebook2];
		System.assertEquals(listaPrecios.size(),2);
		
		//Comprobamos que se han actualizado correctamente los campos
		encontradoTarifa1 = false;
		encontradoTarifa2 = false;
		
		for(Pricebook2 pb : listaPrecios)
		{
			if(pb.Description == 'Descripcion tarifa 2' && pb.Id_Navision__c == '90000013' && pb.Name == pb.Description)
				encontradoTarifa2 = true;
			else if(pb.Description == 'Descripcion tarifa 1' && pb.Id_Navision__c == '90000012' && pb.Name == pb.Description)
				encontradoTarifa1 = true;
				
			//Comprobamos que se ha puesto pendiente de confirmar, posteriormente son procesados por el Batch Nav2sfdc_Tarifas_Confirmacion
			System.assertEquals(pb.Pendiente_de_confirmar__c,true);
			
			//Comprobamos que se ha actualizado como activa
			System.assertEquals(pb.IsActive,true);
		}
		
		//Comprobamos que se ha actualizado correctamente la primera tarifa en SF con el XML simulado del servidor
		System.assertEquals(true,encontradoTarifa1);
		
		//Comprobamos que se ha actualizado correctamente la segunda tarifa en SF con el XML simulado del servidor
		System.assertEquals(true,encontradoTarifa2);
	}
}