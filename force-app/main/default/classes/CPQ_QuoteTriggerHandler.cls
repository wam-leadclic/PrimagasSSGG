public without sharing class CPQ_QuoteTriggerHandler implements ITriggerHandler {

    private boolean triggerIsExecuting;
    private integer triggerSize;

    public CPQ_QuoteTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
    }
    
    public void beforeInsert(List<SBQQ__Quote__c> newQuotes) {
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] beforeInsert START '+Limits.getQueries());
        CPQ_Quote.fillComputedFieldsForQuotes(newQuotes, new Map<Id, SBQQ__Quote__c>());
        CPQ_Quote.setCountyGasRates(newQuotes);
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] beforeInsert END '+Limits.getQueries());
    }

    public void beforeUpdate(List<SBQQ__Quote__c> oldQuotes, List<SBQQ__Quote__c> newQuotes, Map<ID, SObject> oldQuotesMap, Map<ID, SObject> newQuotesMap) {
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] beforeUpdate START '+Limits.getQueries());
        CPQ_Quote.fillComputedFieldsForQuotes(newQuotes, (Map<Id, SBQQ__Quote__c>)oldQuotesMap);
        // PCPQ-37
        CPQ_Quote.fillControlMetricsForQuotes(CPQ_QuoteService.buildWrappersFromQuotesWithoutQLIs(newQuotes), CPQ_Settings.DefaultPBAEstimatedConsCoef);
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] beforeUpdate END '+Limits.getQueries());
    }

    public void beforeDelete(List<SBQQ__Quote__c> oldQuotes, Map<ID, SObject> oldQuotesMap) {
        
    }
    public void afterInsert(List<SBQQ__Quote__c> newQuotes, Map<ID, SObject> newQuotesMap) {
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] afterInsert START '+Limits.getQueries());
        // PCPQ-54
        CPQ_Quote.manageStretches(CPQ_QuoteService.buildWrappersFromQuotesId(newQuotesMap.keySet()));
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] afterInsert END '+Limits.getQueries());
    }
    public void afterUpdate(List<SBQQ__Quote__c> oldQuotes, List<SBQQ__Quote__c> newQuotes, Map<ID, SObject> oldQuotesMap, Map<ID, SObject> newQuotesMap) {
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] afterUpdate START '+Limits.getQueries());
        // PCPQ-54
        CPQ_Quote.manageStretches(CPQ_QuoteService.buildWrappersFromQuotesId(newQuotesMap.keySet()));
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] afterUpdate END '+Limits.getQueries());
    }
    public void afterDelete(List<SBQQ__Quote__c> oldQuotes, Map<ID, SObject> oldQuotesMap) {
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] afterDelete START '+Limits.getQueries());
        // PCPQ-54
        CPQ_Quote.manageStretches(CPQ_QuoteService.buildWrappersFromQuotesId(oldQuotesMap.keySet()));
        CPQ_LogUtil.debug('********* [CPQ_QuoteTriggerHandler] afterDelete END '+Limits.getQueries());
    }
    public void afterUndelete(List<SBQQ__Quote__c> newQuotes, Map<ID, SObject> newQuotesMap) {
        
    }
}