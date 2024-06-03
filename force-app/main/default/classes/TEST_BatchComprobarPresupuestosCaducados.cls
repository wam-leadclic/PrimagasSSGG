@isTest
private class TEST_BatchComprobarPresupuestosCaducados
{
	@isTest
	static void TEST_comprobarPresupuestosCaducados_Individual()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		//Creo un presupuesto que tenga la fecha de vigencia mayor que la actual
		Opportunity oportunidad1 = new Opportunity();
		oportunidad1.Name = 'Oportunidad prueba';
		oportunidad1.AccountId = cuenta.Id;
		oportunidad1.CloseDate = Date.today();
		oportunidad1.StageName = 'Identificada';
		oportunidad1.Estimaci_n_consumo_en_kilos__c = 10;
		insert oportunidad1;

		Quote presupuesto1 = new Quote();
		presupuesto1.Name = 'Presupuesto prueba 1';
		presupuesto1.OpportunityId = oportunidad1.Id;
		presupuesto1.Origen__c = 'web';
		presupuesto1.Origen_tipo_cliente__c = 'Cambio botellas';
		presupuesto1.Provincia_env_o__c = 'VIZCAYA';
		presupuesto1.NIF_CIF__c = '11111111A';
		presupuesto1.Status = 'Preparando';
		presupuesto1.Fecha_vigencia__c = System.today().addDays(1);
		insert presupuesto1;

		//Creo un presupuesto que NO tenga la fecha de vigencia mayor que la actual
		Opportunity oportunidad2 = new Opportunity();
		oportunidad2.Name = 'Oportunidad prueba';
		oportunidad2.AccountId = cuenta.Id;
		oportunidad2.CloseDate = Date.today();
		oportunidad2.StageName = 'Identificada';
		oportunidad2.Estimaci_n_consumo_en_kilos__c = 10;
		insert oportunidad2;

		Quote presupuesto2 = new Quote();
		presupuesto2.Name = 'Presupuesto prueba 2';
		presupuesto2.OpportunityId = oportunidad2.Id;
		presupuesto2.Origen__c = 'web';
		presupuesto2.Origen_tipo_cliente__c = 'Cambio botellas';
		presupuesto2.Provincia_env_o__c = 'VIZCAYA';
		presupuesto2.NIF_CIF__c = '11111111A';
		presupuesto2.Status = 'Preparando';
		presupuesto2.Fecha_vigencia__c = System.today().addDays(-1);
		insert presupuesto2;

		//Ejecuto el batch
        Test.StartTest();
        BatchComprobarPresupuestosCaducados batch = new BatchComprobarPresupuestosCaducados();
		Database.executeBatch(batch);     
        Test.StopTest();  

        //Compruebo que el primer presupuesto sigue en estado "Preparando" y que el segundo se
        //ha pasado a estado "Caducado"
        presupuesto1 = [SELECT Id, Name, Status FROM Quote WHERE Name=:'Presupuesto prueba 1'];
        presupuesto2 = [SELECT Id, Name, Status FROM Quote WHERE Name=:'Presupuesto prueba 2'];
        System.assertEquals(presupuesto1.Status, 'Preparando');
        System.assertEquals(presupuesto2.Status, 'Caducado');
	}	

	@isTest
	static void TEST_comprobarPresupuestosCaducados_Masivo()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		//Creo presupuestos que NO tenga la fecha de validez mayor que la actual
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

		List<Quote> listaPresupuestos = new List<Quote>();
		for(Integer i=0; i<200; i++)
		{
			Quote presupuesto = new Quote();
			presupuesto.Name = 'Presupuesto prueba';
			presupuesto.OpportunityId = listaOportunidades[i].Id;
			presupuesto.Origen__c = 'web';
			presupuesto.Origen_tipo_cliente__c = 'Cambio botellas';
			presupuesto.Provincia_env_o__c = 'VIZCAYA';
			presupuesto.NIF_CIF__c = '11111111A';
			presupuesto.Status = 'Preparando';
			presupuesto.Fecha_vigencia__c = System.today().addDays(-1);
			listaPresupuestos.add(presupuesto);
		}
		insert listaPresupuestos;

		//Ejecuto el batch
        Test.StartTest();
        BatchComprobarPresupuestosCaducados batch = new BatchComprobarPresupuestosCaducados();
		Database.executeBatch(batch);     
        Test.StopTest();  

        //Compruebo que se han pasado todos los presupuestos a estado "Caducado"
        listaPresupuestos = [SELECT Id, Name, Status FROM Quote WHERE Name=:'Presupuesto prueba'];
        System.assertEquals(listaPresupuestos.size(),200);
        for(Integer i=0; i<200; i++)
		{
			System.assertEquals(listaPresupuestos[i].Status, 'Caducado');
		}        
	}	
}