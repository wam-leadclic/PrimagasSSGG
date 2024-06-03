@isTest
public class TEST_Nav2sfdc_Clientes {
	
	static testMethod void testPeticionWSConsultarClientesActualizacion()
	{
		//Esta lista de precios no se corresponde con la respuesta del servidor
		Pricebook2 listaPrecios = new Pricebook2();
		listaPrecios.Name = 'IdNav2';
		listaPrecios.Id_Navision__c = 'IdNav2';
		insert listaPrecios;
		
		//Simulamos que la lista de precios existía de antemano en SF
		//Esta se corresponde con la respuesta del servidor
		Pricebook2 listaPrecios2 = new Pricebook2();
		listaPrecios2.Name = 'IdNav';
		listaPrecios2.Id_Navision__c = 'IdNav';
		insert listaPrecios2;
		
		//List<RecordType> clienteExistenteRecordType = new List<RecordType>([Select Id, DeveloperName from RecordType where DeveloperName = 'Cliente_existente' and SObjectType = 'Account']);
		List<RecordType> clienteExistenteRecordType_personal =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Cliente_existente' and SObjectType = 'Account' and IsPersonType = true];
		List<RecordType> clienteExistenteRecordType_empresa =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Cliente_existente' and SObjectType = 'Account' and IsPersonType = false];	

		//System.debug('Tipo cuenta personal: '+clienteExistenteRecordType[0].Id);
		
		Account cuenta1 = new Account();
		cuenta1.Name = 'NombreEmpresa1';
		cuenta1.City__c = 'Bilbao';
		cuenta1.E_mail__c = 'Josdel2323@hotmail.com';
		cuenta1.Email2__c = '1rudelg22@msn.com';
		cuenta1.Email3__c = 'Josde233@msn.com';
		cuenta1.RecordTypeId = clienteExistenteRecordType_empresa[0].Id;
		cuenta1.Id_Navision__c = '90000000';
		insert cuenta1;  
		
		Account cuenta2 = new Account();
		cuenta2.Name = 'NombreEmpresa2';
		cuenta2.RecordTypeId = clienteExistenteRecordType_empresa[0].Id;
		cuenta2.Id_Navision__c = '90000002';
		insert cuenta2;
		
		Direcci_n_de_entrega__c direccion1 = new Direcci_n_de_entrega__c();
		direccion1.cuenta__c = cuenta1.Id;
		insert direccion1;
		
		Direcci_n_de_entrega__c direccion2 = new Direcci_n_de_entrega__c();
		direccion2.cuenta__c = cuenta2.Id;
		insert direccion2;
		
		Test.startTest();
		//En esta ocasión le pasamos los Ids de salesforce tanto de las direcciones como de las cuentas - Actualicación
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(direccion1.Id,cuenta1.Id ,direccion2.Id, cuenta2.Id));
		Nav2sfdc_Clientes batchClientes = new Nav2sfdc_Clientes();
    	batchClientes.execute(null);
    	Test.stopTest();
		
		List<Account> listaCuentas = [select Pendiente_de_confirmar__c, Id_Navision__c, Name, Id, City__c, RecordTypeId from Account];
		System.debug('##listaCuentas: '+listaCuentas);
		//Se verifica que se han actualizado las cuentas
		System.assertEquals(listaCuentas.size(),2);
		Integer cont = 0;
		
		for(Account cuenta : listaCuentas)
		{
			//El XML contiene 2 etCustomers, uno con Id de Navisio 90000000 y otro 90000002, cuyo nombre en los dos casos contiene la palabra ALMACENES
			if(cuenta.Name.contains('ALMACENES') && (cuenta.Id_Navision__c == '90000000' || cuenta.Id_Navision__c == '90000002'))
			{
				cont++;
			}
			
			//Comprobamos que se ha puesto pendiente de confirmar, posteriormente son procesados por el Batch Nav2sfdc_Clientes_Confirmacion
			System.assertEquals(cuenta.Pendiente_de_confirmar__c,true);

			//Comprobamos que no se ha cambiado el tipo de registro
			System.assertEquals(clienteExistenteRecordType_empresa[0].Id,cuenta.RecordTypeId);
			
		}
		 
		System.assertEquals(cont,2);
		
		List<Direcci_n_de_entrega__c> listaDirecciones = [select Id, Id_Navision__c, cuenta__c from Direcci_n_de_entrega__c];
		//Se verifica que se han actualizado las direcciones
		System.assertEquals(listaDirecciones.size(),2);
		boolean encontrado1 = false;
		boolean encontrado2 = false;
		
		//Comprobamos que se han actualizado correctamente las direcciones
		for(Direcci_n_de_entrega__c direccion : listaDirecciones)
		{
			System.debug('Direcciones recuperadas: ' + direccion.Id_Navision__c + ' - ' + direccion.Id);
			if(direccion.Id_Navision__c == '31' && direccion.cuenta__c == cuenta1.Id)
				encontrado1 = true;
			else if(direccion.Id_Navision__c == '32' && direccion.cuenta__c == cuenta2.Id)
				encontrado2 = true;
		}
		
		System.assertEquals(encontrado1,true);
		System.assertEquals(encontrado2,true);
		
		//Comprobamos que no se ha creado una nueva lista de precios, se ha simulado que ya estaba en SF
		List<Pricebook2> listaPricebooks = [select IsActive, Id_Navision__c, Name from Pricebook2];
		System.assertEquals(listaPricebooks.size(),2);
		
		boolean encontrado = false;
		for(Pricebook2 pb : listaPricebooks)
		{
			if(pb.Id_Navision__c == 'IdNav')
			{
				encontrado = true;
				//Esta lista de precios encontrada no es activa ya que solo tenemos el id de navision de la tarifa
				//Se crea en Salesforce solo para mantener la relación con el cliente. Posteriormente se completarán
				//el resto de campos de esta tarifa gracias al Job Nav2sfdc_Tarifas y se pasará a activa
				System.assertEquals(pb.IsActive,false);
			}
			else
			{
				//Esta lista de precios encontrada no es activa ya que no se ha recibido desde Navision y no se ha actualizado
				System.assertEquals(pb.IsActive,false);
			}
		}
		
		System.assertEquals(encontrado,true);
		
	}
	
	static testMethod void testPeticionWSConsultarClientesInsercion()
	{
		//List<RecordType> clienteExistenteRecordType =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Cliente_existente' and SObjectType = 'Account'];
		List<RecordType> clienteExistenteRecordType_personal =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Cliente_existente' and SObjectType = 'Account' and IsPersonType = true];
		List<RecordType> clienteExistenteRecordType_empresa =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Cliente_existente' and SObjectType = 'Account' and IsPersonType = false];	
		//System.debug('Tipo cuenta personal: ' + clienteExistenteRecordType[0].Id);
		
		Test.startTest();
		//En esta ocasión el XML viene sin los Ids de SF - Inserción
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl('','' ,'', ''));
		Nav2sfdc_Clientes batchClientes = new Nav2sfdc_Clientes();
    	batchClientes.execute(null);
    	Test.stopTest();
		
		List<Account> listaCuentas = [select Pendiente_de_confirmar__c, Id_Navision__c, Name, Id from Account];
		//Se verifica que se han insertado las cuentas
		System.assertEquals(listaCuentas.size(),2);
		
		boolean encontrado90000000 = false;
		boolean encontrado90000002 = false;
		String id90000000 = '';
		String id90000002 = '';
		
		for(Account cuenta : listaCuentas)
		{
			System.debug('Cuentas recuperadas ' + cuenta.Name + ' - ' +cuenta.Id_Navision__c);
			if(cuenta.Name.contains('ALMACENES') && cuenta.Id_Navision__c == '90000000')
			{
				encontrado90000000 = true;
				id90000000 = cuenta.Id;
				System.assertEquals(cuenta.Pendiente_de_confirmar__c,true);
			}
			else if(cuenta.Name.contains('ALMACENES') && cuenta.Id_Navision__c == '90000002')
			{
				encontrado90000002 = true;
				id90000002 = cuenta.Id;
				System.assertEquals(cuenta.Pendiente_de_confirmar__c,true);
			}
		}
		 
		System.assertEquals(encontrado90000000,true);
		System.assertEquals(encontrado90000002,true);
		
		List<Direcci_n_de_entrega__c> listaDirecciones = [select Id, Id_Navision__c, cuenta__c from Direcci_n_de_entrega__c];
		//Se verifica que se han actualizado las cuentas
		System.assertEquals(listaDirecciones.size(),2);
		encontrado90000000 = false;
		encontrado90000002 = false;
		
		//Comprobamos que se han actualizado correctamente las direcciones
		for(Direcci_n_de_entrega__c direccion : listaDirecciones)
		{
			System.debug('Direcciones recuperadas: ' + direccion.Id_Navision__c + ' - ' + direccion.Id);
			if(direccion.Id_Navision__c == '31' && direccion.cuenta__c == id90000000)
				encontrado90000000 = true;
			else if(direccion.Id_Navision__c == '32' && direccion.cuenta__c == id90000002)
				encontrado90000002 = true;
		}
		
		System.assertEquals(encontrado90000000,true);
		System.assertEquals(encontrado90000002,true);
		
		//Probamos que se ha insertado correctamente la nueva lista de precios
		List<Pricebook2> listaPricebooks = [select IsActive, Id_Navision__c, Name from Pricebook2 where Id_Navision__c='IdNav'];
		System.assertEquals(listaPricebooks.size(),1);
		
		System.assertEquals(listaPricebooks[0].Id_Navision__c,'IdNav');
		
		//No es activa porque se ha creado en Salesforce para mantener la relación entre el cliente y 
		//la tarifa (Solo tenemos el id de Navision de la tarifa) pero todavía falta de completar
		//el resto de campos, esto se hará la próxima vez que se consulte esta tarifa y en ese
		//momento pasará a activa (Visible para los usuarios a la hora de crear un contrato)
		System.assertEquals(listaPricebooks[0].IsActive,false);
	}

	//////
	static testMethod void testPeticionWSConsultarClientesComprobarConfirmacionDireccionesActualizadas()
	{
		//Esta lista de precios no se corresponde con la respuesta del servidor
		Pricebook2 listaPrecios = new Pricebook2();
		listaPrecios.Name = 'IdNav2';
		listaPrecios.Id_Navision__c = 'IdNav2';
		insert listaPrecios;
		
		//Simulamos que la lista de precios existía de antemano en SF
		//Esta se corresponde con la respuesta del servidor
		Pricebook2 listaPrecios2 = new Pricebook2();
		listaPrecios2.Name = 'IdNav';
		listaPrecios2.Id_Navision__c = 'IdNav';
		insert listaPrecios2;
		
		List<RecordType> clienteExistenteRecordType = new List<RecordType>([Select Id, DeveloperName from RecordType where DeveloperName = 'Cliente_existente' and SObjectType = 'Account']);
		
		System.debug('Tipo cuenta personal: '+clienteExistenteRecordType[0].Id);
		
		Account cuenta1 = new Account();
		cuenta1.Name = 'NombreEmpresa1';
		cuenta1.City__c = 'Bilbao';
		cuenta1.E_mail__c = 'Josdel2323@hotmail.com';
		cuenta1.Email2__c = '1rudelg22@msn.com';
		cuenta1.Email3__c = 'Josde233@msn.com';
		cuenta1.RecordTypeId = clienteExistenteRecordType[0].Id;
		cuenta1.Id_Navision__c = '90000000';
		insert cuenta1;  
		
		Account cuenta2 = new Account();
		cuenta2.Name = 'NombreEmpresa2';
		cuenta2.RecordTypeId = clienteExistenteRecordType[0].Id;
		cuenta2.Id_Navision__c = '90000002';
		insert cuenta2;
		
		Direcci_n_de_entrega__c direccion1 = new Direcci_n_de_entrega__c();
		direccion1.cuenta__c = cuenta1.Id;
		insert direccion1;
		
		Direcci_n_de_entrega__c direccion2 = new Direcci_n_de_entrega__c();
		direccion2.cuenta__c = cuenta2.Id;
		insert direccion2;

		Direcci_n_de_entrega__c direccion3 = new Direcci_n_de_entrega__c();
		direccion3.cuenta__c = cuenta2.Id;
		insert direccion3;
		
		Test.startTest();
		//En esta ocasión le pasamos los Ids de salesforce tanto de las direcciones como de las cuentas - Actualicación
        Test.setMock(HttpCalloutMock.class, new NTLMHttpCalloutMockImpl(direccion1.Id,cuenta1.Id ,direccion2.Id, cuenta2.Id));
		Nav2sfdc_Clientes batchClientes = new Nav2sfdc_Clientes();
    	batchClientes.execute(null);
    	Test.stopTest();
		
		List<Account> listaCuentas = [select Pendiente_de_confirmar__c, Id_Navision__c, Name, Id, City__c from Account];
		//Se verifica que se han actualizado las cuentas
		System.assertEquals(listaCuentas.size(),2);
		Integer cont = 0;
		
		for(Account cuenta : listaCuentas)
		{
			System.debug('Cuentas recuperadas ' + cuenta.Name + ' - ' +cuenta.Id_Navision__c);
			//El XML contiene 2 etCustomers, uno con Id de Navisio 90000000 y otro 90000002, cuyo nombre en los dos casos contiene la palabra ALMACENES
			if(cuenta.Name.contains('ALMACENES') && (cuenta.Id_Navision__c == '90000000' || cuenta.Id_Navision__c == '90000002'))
				cont++;
			
			//Comprobamos que se ha puesto pendiente de confirmar, posteriormente son procesados por el Batch Nav2sfdc_Clientes_Confirmacion
			System.assertEquals(cuenta.Pendiente_de_confirmar__c,true);
		}
		 
		System.assertEquals(cont,2);
		
		List<Direcci_n_de_entrega__c> listaDirecciones = [select Id, Id_Navision__c, cuenta__c, Pendiente_de_confirmar__c from Direcci_n_de_entrega__c];
		//Se verifica que se han actualizado las direcciones
		System.assertEquals(listaDirecciones.size(),3);
		Integer direccionesActualizar = 0;
		
		//Comprobamos que se ha puesto pendiente de confirmar, posteriormente son procesados por el Batch Nav2sfdc_Clientes_Confirmacion
		for(Direcci_n_de_entrega__c direccion : listaDirecciones)
		{
			System.debug('Direcciones recuperadas: ' + direccion.Id_Navision__c + ' - ' + direccion.Id);
			if(direccion.Pendiente_de_confirmar__c)
				direccionesActualizar++;
		}
		System.assertEquals(direccionesActualizar,2);		
	}
}