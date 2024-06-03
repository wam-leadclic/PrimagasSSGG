trigger DireccionEnvioTrigger on Direcci_n_de_entrega__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	System.Debug('**** DireccionEnvio Trigger ****');
	TriggerFactory.createHandler(Direcci_n_de_entrega__c.sObjectType);
}