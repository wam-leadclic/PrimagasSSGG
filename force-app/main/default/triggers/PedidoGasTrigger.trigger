trigger PedidoGasTrigger on Pedido_de_gas__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
  System.Debug('**** Pedidos de gas Trigger ****');
  TriggerFactory.createHandler(Pedido_de_gas__c.sObjectType);
}