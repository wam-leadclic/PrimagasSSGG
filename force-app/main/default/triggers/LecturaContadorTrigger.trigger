trigger LecturaContadorTrigger on Lectura_contador__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
  System.Debug('**** Lectura de contador Trigger ****');
  TriggerFactory.createHandler(Lectura_contador__c.sObjectType);
}