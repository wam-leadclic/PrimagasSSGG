@isTest
public class TEST_PresupuestoUtil
{	
	@isTest
	static void TEST_actualizarFechaUltimaModificacionDePresupuestosEnOportunidad_Individual()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		Opportunity oportunidad = new Opportunity();
		oportunidad.Name = 'Oportunidad prueba';
		oportunidad.AccountId = cuenta.Id;
		oportunidad.CloseDate = Date.today();
		oportunidad.StageName = 'Identificada';
		oportunidad.Estimaci_n_consumo_en_kilos__c = 10;
		insert oportunidad;

		Quote presupuesto = new Quote();
		presupuesto.Name = 'Presupuesto prueba';
		presupuesto.OpportunityId = oportunidad.Id;
		presupuesto.Status = 'Preparando';
		presupuesto.Origen__c = 'web';
		presupuesto.Origen_tipo_cliente__c = 'Cambio botellas';
		presupuesto.Provincia_env_o__c = 'VIZCAYA';
		presupuesto.NIF_CIF__c = '11111111A';
		insert presupuesto;

		oportunidad = [SELECT Id, Name, Fecha_ultima_modificacion_presupuestos__c FROM Opportunity WHERE Name=:'Oportunidad prueba'];
		Boolean comp = false;
		if(oportunidad.Fecha_ultima_modificacion_presupuestos__c > System.now().addMinutes(-5) && oportunidad.Fecha_ultima_modificacion_presupuestos__c < System.now().addMinutes(5))
		{
			comp = true;
		}
		System.assertEquals(comp, true);
	}

	@isTest
	static void TEST_actualizarFechaUltimaModificacionDePresupuestosEnOportunidad_Masivo()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		List<Opportunity> listaOportunidades = new List<Opportunity>();
		for(integer i=0; i<200; i++)
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
		for(integer i=0; i<200; i++)
		{
			Quote presupuesto = new Quote();
			presupuesto.Name = 'Presupuesto prueba';
			presupuesto.OpportunityId = listaOportunidades[i].Id;
			presupuesto.Status = 'Preparando';
			presupuesto.Origen__c = 'web';
			presupuesto.Origen_tipo_cliente__c = 'Cambio botellas';
			presupuesto.Provincia_env_o__c = 'VIZCAYA';
			presupuesto.NIF_CIF__c = '11111111A';
			listaPresupuestos.add(presupuesto);
		}
		insert listaPresupuestos;

		listaOportunidades = [SELECT Id, Name, Fecha_ultima_modificacion_presupuestos__c FROM Opportunity WHERE Name=:'Oportunidad prueba'];
		System.assertEquals(listaOportunidades.size(),200);
		Boolean comp;
		for(Opportunity o: listaOportunidades)
		{
			comp = false;
			if(o.Fecha_ultima_modificacion_presupuestos__c > System.now().addMinutes(-5) && o.Fecha_ultima_modificacion_presupuestos__c < System.now().addMinutes(5))
			{
				comp = true;
			}
			System.assertEquals(comp, true);
		}	
	}

	@isTest
	static void TEST_cambiarEstadoNegociacion_Individual()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		Opportunity oportunidad = new Opportunity();
		oportunidad.Name = 'Oportunidad prueba';
		oportunidad.AccountId = cuenta.Id;
		oportunidad.CloseDate = Date.today();
		oportunidad.StageName = 'Identificada';
		oportunidad.Estimaci_n_consumo_en_kilos__c = 10;
		insert oportunidad;

		Quote presupuesto = new Quote();
		presupuesto.Name = 'Presupuesto prueba';
		presupuesto.OpportunityId = oportunidad.Id;
		presupuesto.Status = 'Preparando';
		presupuesto.Origen__c = 'web';
		presupuesto.Origen_tipo_cliente__c = 'Cambio botellas';
		presupuesto.Provincia_env_o__c = 'VIZCAYA';
		presupuesto.NIF_CIF__c = '11111111A';
		insert presupuesto;

		oportunidad = [SELECT Id, Name, StageName FROM Opportunity WHERE Name=:'Oportunidad prueba'];
		System.assertEquals(oportunidad.StageName,'Negociación / Revisión');
	}

	@isTest
	static void TEST_cambiarEstadoNegociacion_Masivo()
	{
		Account cuenta = new Account();
		cuenta.Name = 'Cuenta prueba';
		cuenta.Id_Fiscal__c = '11111111A';
		insert cuenta;

		List<Opportunity> listaOportunidades = new List<Opportunity>();
		for(integer i=0; i<200; i++)
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
		for(integer i=0; i<200; i++)
		{
			Quote presupuesto = new Quote();
			presupuesto.Name = 'Presupuesto prueba';
			presupuesto.OpportunityId = listaOportunidades[i].Id;
			presupuesto.Status = 'Preparando';
			presupuesto.Origen__c = 'web';
			presupuesto.Origen_tipo_cliente__c = 'Cambio botellas';
			presupuesto.Provincia_env_o__c = 'VIZCAYA';
			presupuesto.NIF_CIF__c = '11111111A';
			listaPresupuestos.add(presupuesto);
		}
		insert listaPresupuestos;

		listaOportunidades = [SELECT Id, Name, StageName FROM Opportunity WHERE Name=:'Oportunidad prueba'];
		System.assertEquals(listaOportunidades.size(),200);
		for(Opportunity o: listaOportunidades)
		{
			System.assertEquals(o.StageName,'Negociación / Revisión');
		}	
	}
}