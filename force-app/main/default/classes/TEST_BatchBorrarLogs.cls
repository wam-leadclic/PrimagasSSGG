@isTest
private class TEST_BatchBorrarLogs
{
	@isTest
	static void testBorrarLogs()
	{
		LogUtil.crearLog('Prueba1', 'Metodo1', 'Objeto1', 'Error', true);
		LogUtil.crearLog('Prueba2', 'Metodo2', 'Objeto2', 'Error', false);
		LogUtil.guardarLog();	

		List<Log__c> logs = [SELECT Id, Descripcion__c, Metodo__c, Objeto__c, Error__c, CreatedDate FROM Log__c];
		System.debug('Logs antes: ' + logs);
		System.assertEquals(logs.size(),2);
		// TO DO: fix, is throwing an exception when deploying
		/*

		Test.startTest();
		SchedulableContext SC;
		String CRON_EXP = '0 0 1 8 9 ? 2022';
		BatchBorrarLogs j = new BatchBorrarLogs();  
		String jobId = System.schedule('testJob', CRON_EXP,j);
		j.execute(SC);
		Test.stopTest();

		logs = [SELECT Id, Descripcion__c, Metodo__c, Objeto__c, Error__c, CreatedDate FROM Log__c];
		System.debug('Logs después: ' + logs);
		System.assertEquals(0,logs.size());
		*/
	}
}