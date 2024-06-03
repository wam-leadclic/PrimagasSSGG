@isTest
private class TEST_BatchCrearIndividualDesdeLead
{   
	private static Integer NUM_LEADS = 1;
	/*
        Prueba que se generan los registros persona
        Se actualizan los registros y se borran las personas ya que se crean inicialmente en el insert de cada trigger
    */
    @isTest 
    static void test_generarPersonas()
    {   
    	List<Lead> candidatosList = Util.generarCandidatos(NUM_LEADS, 0);
    	insert candidatosList;
    	
    	for(Lead candidato : candidatosList)
    	{
    		candidato.Individualid = null;
    	}

    	LeadHandler.semaforoLead = false;
    	update candidatosList;

    	List<Individual> personasList = [SELECT Id FROM Individual];
    	delete personasList;

    	Test.startTest();
    	LeadHandler.semaforoLead = false;
        Database.executeBatch(new BatchCrearIndividualDesdeLead(), 200);
        
        Test.stopTest();

		Map<Id, Individual> personasMap = new Map<Id, Individual>([SELECT Id, FirstName, LastName, Email__c, Hash__c FROM Individual]);
        System.assert(!personasMap.isEmpty());
        System.assertEquals(NUM_LEADS, personasMap.size());

        for(Lead candidato : [SELECT Id, IndividualId, FirstName, LastName, Email FROM Lead])
		{
			if(candidato.IndividualId != null && personasMap.containsKey(candidato.IndividualId))
			{
				System.assertEquals(personasMap.get(candidato.IndividualId).FirstName 	, candidato.FirstName);
				System.assertEquals(personasMap.get(candidato.IndividualId).LastName 	, candidato.LastName);
				System.assertEquals(personasMap.get(candidato.IndividualId).Email__c	, candidato.Email);
				System.assert(String.isNotBlank(personasMap.get(candidato.IndividualId).Hash__c));
			}else
			{
				System.assert(false, 'El candidato debería tener el lookup relleno');
			}
		}
    }

}