trigger ApprovalRequestTrigger on ApprovalRequest__c(after delete, after insert, after undelete, after update, 
        before delete, before insert, before update) {
	TriggerFactory.createHandler(ApprovalRequest__c.sObjectType);
}