@isTest
private class TEST_JSButtonsHelper 
{
	
	@isTest 
	static void generateHash() 
	{
		List<Lead> candidatosList = Util.generarCandidatos(1, 0);
		insert candidatosList;

		List<Lead> candidatosInsertadosList = [SELECT Id, IndividualId FROM Lead];

		Test.startTest();
		JSButtonsHelper.generarHash(candidatosInsertadosList[0].IndividualId);
		Test.stopTest();

		Individual persona = [SELECT Id, Hash__c FROM Individual WHERE Id =: candidatosInsertadosList[0].IndividualId];
		System.assert(String.isNotBlank(persona.Hash__c));
	}	
}