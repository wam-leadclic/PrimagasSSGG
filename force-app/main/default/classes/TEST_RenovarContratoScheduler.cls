@isTest
public class TEST_RenovarContratoScheduler {
	
	static testMethod void RenovarContratoSchedulerTest(){
		System.Debug('## before RenovarContratoSchedulerTest');

		Account cuenta = new Account();
		cuenta.Name = 'Test';
		insert cuenta;

		Direcci_n_de_Entrega__c direccion = new Direcci_n_de_Entrega__c();
		direccion.cuenta__c = cuenta.Id;
		insert direccion;	

		Datetime fechaInicioContrato = System.now();
		fechaInicioContrato = fechaInicioContrato.addDays(-32);

		Contract contrato = new Contract();
		contrato.AccountId = cuenta.Id;
		contrato.StartDate = date.newinstance(fechaInicioContrato.year(), fechaInicioContrato.month(), fechaInicioContrato.day());
		contrato.ContractTerm = 1;
		contrato.Servicios__c = 'Prueba;Test';
		contrato.Direccion_de_entrega__c = direccion.Id;
		insert contrato;

		Test.startTest();
		
		SchedulableContext SC;
		RenovarContratoScheduler j = new RenovarContratoScheduler();
		j.execute(SC);

		Test.stopTest();

		List<Contract> contratos = new List<Contract>([Select Id, Status, Contrato_anterior__c from Contract]);

		System.assertEquals(2, contratos.size());

		Contract contratoNuevo;

		for (Contract c:contratos)
		{
			if (c.Id == contrato.Id)
			{
				contrato = c;
			}
			else
			{
				contratoNuevo = c;
			}
		}

		System.assertEquals(false, contratoNuevo == null);
		System.assertEquals('Anulado', contrato.Status);
		System.assertEquals(contrato.Id, contratoNuevo.Contrato_anterior__c);
		System.assertEquals('Pendiente de registrar', contratoNuevo.Status);

		/*List<Contrato_de_servicio__c> contratosServicio = new List<Contrato_de_servicio__c>([Select Id from Contrato_de_servicio__c]);
		System.assertEquals(4, contratosServicio.size());*/

		update direccion;
		delete contratos;
		delete direccion;

		System.Debug('## after RenovarContratoSchedulerTest');
	}

}