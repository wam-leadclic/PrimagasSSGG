trigger PresupuestoTrigger on Quote (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	System.Debug('**** Presupuesto Trigger ****');
	TriggerFactory.createHandler(Quote.sObjectType);
}