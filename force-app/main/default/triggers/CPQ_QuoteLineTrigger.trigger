trigger CPQ_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    CPQ_QuoteLineTriggerHandler handler = new CPQ_QuoteLineTriggerHandler(Trigger.isExecuting, Trigger.size);

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when BEFORE_DELETE {
            handler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_INSERT {
            handler.afterInsert(Trigger.new, Trigger.newMap);
        }
        when AFTER_UPDATE {
            handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_DELETE {
            handler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            handler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
}