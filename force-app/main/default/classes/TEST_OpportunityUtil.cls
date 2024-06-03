@isTest
public class TEST_OpportunityUtil
{
	/*@isTest
	static void TEST_comprobarEstadoNegociacion_Individual()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		//Creo una oportunidad CON presupuesto
		Opportunity oportunidad1 = new Opportunity();
		oportunidad1.Name = 'Oportunidad prueba 1';
		oportunidad1.AccountId = cuenta.Id;
		oportunidad1.CloseDate = Date.today();
		oportunidad1.StageName = 'Identificada';
		oportunidad1.Estimaci_n_consumo_en_kilos__c = 10;
		insert oportunidad1;

		Quote presupuesto = new Quote();
		presupuesto.Name = 'Presupuesto prueba';
		presupuesto.OpportunityId = oportunidad1.Id;
		presupuesto.Origen__c = 'web';
		presupuesto.Origen_tipo_cliente__c = 'Cambio botellas';
		presupuesto.Provincia_env_o__c = 'VIZCAYA';
		presupuesto.NIF_CIF__c = '11111111A';
		insert presupuesto;

		//Creo una oportunidad SIN presupuesto
		Opportunity oportunidad2 = new Opportunity();
		oportunidad2.Name = 'Oportunidad prueba 2';
		oportunidad2.AccountId = cuenta.Id;
		oportunidad2.CloseDate = Date.today();
		oportunidad2.StageName = 'Identificada';
		oportunidad2.Estimaci_n_consumo_en_kilos__c = 10;
		insert oportunidad2;

		oportunidad1.StageName = 'Negociación / Revisión';
		oportunidad2.StageName = 'Negociación / Revisión';
		try
		{
			update oportunidad1;
		}
		catch(DmlException e)
		{
			System.debug('Error al actualizar el estado de la oportunidad 1: ' + e.getMessage());
		}
		try
		{
			update oportunidad2;
		}
		catch(DmlException e)
		{
			System.debug('Error al actualizar el estado de la oportunidad 2: ' + e.getMessage());
		}

		//Compruebo que la oportunidad con presupuesto se ha podido pasar al estado "Negociación / Revisión"
		//y la que no tiene presupuesto no
		List<Opportunity> listaOportunidades = [SELECT Id, Name, StageName FROM Opportunity WHERE Name=:'Oportunidad prueba 1' or Name=:'Oportunidad prueba 2'];
		System.assertEquals(listaOportunidades.size(),2);
		for(Opportunity o: listaOportunidades)
		{
			if(o.Name=='Oportunidad prueba 1')
			{
				System.assertEquals(o.StageName,'Negociación / Revisión');
			}
			else
			{
				System.assertEquals(o.StageName,'Identificada');
			}
		}
	}	

	@isTest
	static void TEST_comprobarEstadoNegociacion_Masivo()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		//Creo oportunidades SIN presupuesto
		List<Opportunity> listaOportunidades = new List<Opportunity>();
		for(Integer i=0; i<200; i++)
		{
			Opportunity oportunidad = new Opportunity();
			oportunidad.Name = 'Oportunidad prueba';
			oportunidad.AccountId = cuenta.Id;
			oportunidad.CloseDate = Date.today();
			oportunidad.StageName = 'Identificada';
			oportunidad.Estimaci_n_consumo_en_kilos__c = 10;
			listaOportunidades.add(oportunidad);
		}	
		insert listaOportunidades;

		for(Integer i=0; i<200; i++)
		{
			listaOportunidades[i].StageName = 'Negociación / Revisión';
		}
		Database.update(listaOportunidades,false);

		//Compruebo que no se ha podido pasar ninguna oportunidad al estado "Negociación / Revisión"
		listaOportunidades = [SELECT Id, Name, StageName FROM Opportunity WHERE Name=:'Oportunidad prueba'];
		System.assertEquals(listaOportunidades.size(),200);
		for(Integer i=0; i<200; i++)
		{
			System.assertEquals(listaOportunidades[i].StageName,'Identificada');
		}
	}*/	


	/*@isTest
	static void TEST_comprobarEstadoCerradaGanada_Individual()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		Contact contacto = new Contact();
		contacto.LastName = 'Prueba contacto';
		contacto.AccountId = cuenta.Id;
		contacto.Email = 'ejemplo@ejemplo.com';
		insert contacto;

		//Creo una oportunidad con contrato firmado
		Opportunity oportunidad1 = new Opportunity();
		oportunidad1.Name = 'Oportunidad prueba 1';
		oportunidad1.AccountId = cuenta.Id;
		oportunidad1.CloseDate = Date.today();
		oportunidad1.StageName = 'Identificada';
		oportunidad1.Estimaci_n_consumo_en_kilos__c = 10;
		insert oportunidad1;

		Proveedor__c proveedor = new Proveedor__c();
		proveedor.Name = 'Proveedor prueba';
		insert proveedor;

		Contract contrato1 = new Contract();
		contrato1.Status = 'Borrador';
		contrato1.AccountId = cuenta.Id;
		contrato1.CIF__c = '11111111A';
		contrato1.N_telefono_movil__c = '666666666';
		contrato1.CustomerSignedDate = Date.today();
		contrato1.StartDate = Date.today();
		contrato1.Duraci_n_del_contrato_a_os__c = '1';
		contrato1.Consumo_previsto_tons__c = 1;
		contrato1.Cod_forma_de_pago__c = 'CHEQUE';
		contrato1.Cod_terminos_de_pago__c = '005';
		contrato1.Cod_forma_pago_servicios__c = 'CHEQUE';
		contrato1.Cod_terminos_pago_servicios__c = '005';
		contrato1.Modalidad_de_instalaci_n__c = 'Modular';
		contrato1.Fecha_prevista_obra_civil__c = Date.today();
		contrato1.Fecha_prevista_1er_llenado__c = Date.today();
		contrato1.Subcontratista__c = proveedor.Id;
		contrato1.Capacidad_tanque__c = 1;
		contrato1.Tipo_de_tanque__c = 'Aereo';
		contrato1.Origen__c = 'Web';
		contrato1.Origen_tipo_de_cliente__c = 'Cambio Botellas';
		contrato1.CustomerSignedId = contacto.Id; //Firmado
		contrato1.Oportunidad__c = oportunidad1.Id;
		insert contrato1;

		oportunidad1.ContractId = contrato1.Id;
		update oportunidad1;

		//Creo una oportunidad con contrato SIN firmar
		Opportunity oportunidad2 = new Opportunity();
		oportunidad2.Name = 'Oportunidad prueba 2';
		oportunidad2.AccountId = cuenta.Id;
		oportunidad2.CloseDate = Date.today();
		oportunidad2.StageName = 'Identificada';
		oportunidad2.Estimaci_n_consumo_en_kilos__c = 10;
		insert oportunidad2;

		Contract contrato2 = new Contract();
		contrato2.Status = 'Borrador';
		contrato2.AccountId = cuenta.Id;
		contrato2.CIF__c = '11111111A';
		contrato2.N_telefono_movil__c = '666666666';
		contrato2.CustomerSignedDate = Date.today();
		contrato2.StartDate = Date.today();
		contrato2.Duraci_n_del_contrato_a_os__c = '1';
		contrato2.Consumo_previsto_tons__c = 1;
		contrato2.Cod_forma_de_pago__c = 'CHEQUE';
		contrato2.Cod_terminos_de_pago__c = '005';
		contrato2.Cod_forma_pago_servicios__c = 'CHEQUE';
		contrato2.Cod_terminos_pago_servicios__c = '005';
		contrato2.Modalidad_de_instalaci_n__c = 'Modular';
		contrato2.Fecha_prevista_obra_civil__c = Date.today();
		contrato2.Fecha_prevista_1er_llenado__c = Date.today();
		contrato2.Subcontratista__c = proveedor.Id;
		contrato2.Capacidad_tanque__c = 1;
		contrato2.Tipo_de_tanque__c = 'Aereo';
		contrato2.Origen__c = 'Web';
		contrato2.Origen_tipo_de_cliente__c = 'Cambio Botellas';
		contrato2.Oportunidad__c = oportunidad2.Id;
		insert contrato2;

		oportunidad2.ContractId = contrato2.Id;
		update oportunidad2;

		oportunidad1.StageName = 'Cerrada ganada';
		oportunidad2.StageName = 'Cerrada ganada';
		try
		{
			update oportunidad1;
		}
		catch(DmlException e)
		{
			System.debug('Error al actualizar el estado de la oportunidad 1: ' + e.getMessage());
		}
		try
		{
			update oportunidad2;
		}
		catch(DmlException e)
		{
			System.debug('Error al actualizar el estado de la oportunidad 2: ' + e.getMessage());
		}

		//Compruebo que la oportunidad con contrato firmado se ha podido pasar al estado "Cerrada ganada"
		//y la que no lo tiene no
		List<Opportunity> listaOportunidades = [SELECT Id, Name, StageName FROM Opportunity WHERE Name=:'Oportunidad prueba 1' or Name=:'Oportunidad prueba 2'];
		System.assertEquals(listaOportunidades.size(),2);
		for(Opportunity o: listaOportunidades)
		{
			if(o.Name=='Oportunidad prueba 1')
			{
				System.assertEquals(o.StageName,'Cerrada ganada');
			}
			else
			{
				System.assertEquals(o.StageName,'Identificada');
			}
		}
	}	

	@isTest
	static void TEST_comprobarEstadoCerradaGanada_Masivo()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		Contact contacto = new Contact();
		contacto.LastName = 'Prueba contacto';
		contacto.AccountId = cuenta.Id;
		contacto.Email = 'ejemplo@ejemplo.com';
		insert contacto;

		//Creo oportunidades con contrato SIN firmar
		List<Opportunity> listaOportunidades = new List<Opportunity>();
		for(Integer i=0; i<200; i++)
		{
			Opportunity oportunidad = new Opportunity();
			oportunidad.Name = 'Oportunidad prueba';
			oportunidad.AccountId = cuenta.Id;
			oportunidad.CloseDate = Date.today();
			oportunidad.StageName = 'Identificada';
			oportunidad.Estimaci_n_consumo_en_kilos__c = 10;
			listaOportunidades.add(oportunidad);
		}
		insert listaOportunidades;

		Proveedor__c proveedor = new Proveedor__c();
		proveedor.Name = 'Proveedor prueba';
		insert proveedor;

		List<Contract> listaContratos = new List<Contract>();
		for(Integer i=0; i<200; i++)
		{
			Contract contrato = new Contract();
			contrato.Status = 'Borrador';
			contrato.AccountId = cuenta.Id;
			contrato.CIF__c = '11111111A';
			contrato.N_telefono_movil__c = '666666666';
			contrato.CustomerSignedDate = Date.today();
			contrato.StartDate = Date.today();
			contrato.Duraci_n_del_contrato_a_os__c = '1';
			contrato.Consumo_previsto_tons__c = 1;
			contrato.Cod_forma_de_pago__c = 'CHEQUE';
			contrato.Cod_terminos_de_pago__c = '005';
			contrato.Cod_forma_pago_servicios__c = 'CHEQUE';
			contrato.Cod_terminos_pago_servicios__c = '005';
			contrato.Modalidad_de_instalaci_n__c = 'Modular';
			contrato.Fecha_prevista_obra_civil__c = Date.today();
			contrato.Fecha_prevista_1er_llenado__c = Date.today();
			contrato.Subcontratista__c = proveedor.Id;
			contrato.Capacidad_tanque__c = 1;
			contrato.Tipo_de_tanque__c = 'Aereo';
			contrato.Origen__c = 'Web';
			contrato.Origen_tipo_de_cliente__c = 'Cambio Botellas';
			contrato.Oportunidad__c = listaOportunidades[i].Id;
			listaContratos.add(contrato);
		}
		insert listaContratos;

		for(Integer i=0; i<200; i++)
		{
			listaOportunidades[i].ContractId = listaContratos[i].Id;
		}		
		update listaOportunidades;

		for(Integer i=0; i<200; i++)
		{
			listaOportunidades[i].StageName = 'Cerrada ganada';
		}		
		Database.update(listaOportunidades,false);

		//Compruebo que no se ha podido pasar ninguna oportunidad al estado "Cerrada ganada"
		listaOportunidades = [SELECT Id, Name, StageName FROM Opportunity WHERE Name=:'Oportunidad prueba'];
		System.assertEquals(listaOportunidades.size(),200);
		for(Integer i=0; i<200; i++)
		{
			System.assertEquals(listaOportunidades[i].StageName,'Identificada');
		}
	}*/	

   	/**
	* Metodo encargado de crear nuevas funciones de contacto cuando se crea una oportunidad para una cuenta que tenga contactos en SF
	* @author rfernandez (17/02/2017)
	* @modificaciones 
	*/
	
    static testMethod void testCrearFuncionesDeContactoConCuentaSinConvertir()
	{
		Account cuenta = new Account();

		cuenta.Name = 'Test';
		/*cuenta.FirstName = 'Test';
		cuenta.LastName = 'Conversion';*/
		cuenta.BillingStreet = 'Crta Nacional N-232 Km. 373';
		cuenta.City__c = 'QUINTO';
		cuenta.Codigo_Postal__c = '50770';
		cuenta.Provincia__c = 'Vizcaya';
		cuenta.Pais__c = 'ES';
		cuenta.Phone = '695724132';
		cuenta.Fax = '944422342';
		cuenta.E_mail__c = 'test@primagas.es';

		insert cuenta;

		List<Contact> listaContactos = new List<Contact>();
		
		for(Integer i = 0 ; i < 2 ; i++)
		{
			Contact contacto = new Contact();
			contacto.LastName = 'Prueba contacto'+i;
			contacto.AccountId = cuenta.Id;
			contacto.Email = 'contacto'+i+'@ejemplo.com';
			listaContactos.add(contacto);
		}

		insert listaContactos;
		
		Opportunity oportunidad = new Opportunity();
		oportunidad.Name = 'Oportunidad prueba';
		oportunidad.AccountId = cuenta.Id;
		oportunidad.CloseDate = Date.today();
		oportunidad.StageName = 'Identificada';
		
		Test.startTest();

		insert oportunidad;

		Test.stopTest();

		Integer numeroDeOportunidades = [SELECT COUNT() FROM Opportunity ];
		System.assertEquals(1, numeroDeOportunidades);

		List<OpportunityContactRole> funcionesInsertadas = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole];
		System.assertEquals(2, funcionesInsertadas.size());
		for(OpportunityContactRole funcion: funcionesInsertadas)
		{
			System.assertEquals(oportunidad.Id, funcion.OpportunityId);
		}
	}

	//Cuando la cuenta esta marcada como convertida no se crean funciones de contacto
    static testMethod void testCrearFuncionesDeContactoConCuentasConvertidas()
	{
		Account cuenta = new Account();

		cuenta.Name = 'Test';
		/*cuenta.FirstName = 'Test';
		cuenta.LastName = 'Conversion';*/
		cuenta.BillingStreet = 'Crta Nacional N-232 Km. 373';
		cuenta.City__c = 'QUINTO';
		cuenta.Codigo_Postal__c = '50770';
		cuenta.Provincia__c = 'Vizcaya';
		cuenta.Pais__c = 'ES';
		cuenta.Phone = '695724132';
		cuenta.Fax = '944422342';
		cuenta.E_mail__c = 'test@primagas.es';
		cuenta.Procede_de_conversion__c = true;
		insert cuenta;

		List<Contact> listaContactos = new List<Contact>();
		
		for(Integer i = 0 ; i < 2 ; i++)
		{
			Contact contacto = new Contact();
			contacto.LastName = 'Prueba contacto'+i;
			contacto.AccountId = cuenta.Id;
			contacto.Email = 'contacto'+i+'@ejemplo.com';
			listaContactos.add(contacto);
		}

		insert listaContactos;
		
		Opportunity oportunidad = new Opportunity();
		oportunidad.Name = 'Oportunidad prueba';
		oportunidad.AccountId = cuenta.Id;
		oportunidad.CloseDate = Date.today();
		oportunidad.StageName = 'Identificada';
		
		Test.startTest();

		insert oportunidad;

		Test.stopTest();

		Integer numeroDeOportunidades = [SELECT COUNT() FROM Opportunity ];
		System.assertEquals(1, numeroDeOportunidades);

		List<OpportunityContactRole> funcionesInsertadas = [SELECT Id, OpportunityId, ContactId FROM OpportunityContactRole];
		System.assertEquals(0, funcionesInsertadas.size());

	}
}