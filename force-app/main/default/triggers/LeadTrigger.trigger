trigger LeadTrigger on Lead (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	System.Debug('**** Lead Trigger ****');
	TriggerFactory.createHandler(Lead.sObjectType);
}