trigger AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	System.Debug('**** Account Trigger ****');
	TriggerFactory.createHandler(Account.sObjectType);
}