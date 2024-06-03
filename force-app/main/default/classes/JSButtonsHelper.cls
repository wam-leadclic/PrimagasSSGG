global with sharing class JSButtonsHelper 
{
	webservice static void generarHash(Id identificador)
    {
    	Individual persona = [SELECT Id, Hash__c FROM Individual WHERE Id =: identificador];
        persona.Hash__c = Util.calcularHash(identificador);
        update persona;
    }
}