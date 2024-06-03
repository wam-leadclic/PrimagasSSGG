public without sharing class CPQ_QuoteLineTriggerHandler implements ITriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;

    public CPQ_QuoteLineTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
    }

    public void beforeInsert(List<SBQQ__QuoteLine__c> newQuoteLines) {
    }

    public void beforeUpdate(
        List<SBQQ__QuoteLine__c> oldQuoteLines,
        List<SBQQ__QuoteLine__c> newQuoteLines,
        Map<ID, SObject> oldQuoteLineMap,
        Map<ID, SObject> newQuoteLineMap
    ) {
    }

    public void beforeDelete(List<SBQQ__QuoteLine__c> oldQuoteLines, Map<ID, SObject> oldQuoteLineMap) {
    }

    public void afterInsert(List<SBQQ__QuoteLine__c> newQuoteLines, Map<ID, SObject> newQuoteLineMap) {
        CPQ_LogUtil.debug('********* [CPQ_QuoteLineTriggerHandler] afterInsert START '+Limits.getQueries());
    
        List<CPQ_Quote.QuoteWrapper> quoteWrappers = CPQ_QuoteService.buildWrappersFromQuotesId(
                                                        CPQ_QuoteLineService.extractQuoteIdFromQuoteLines(newQuoteLines));
        // PCPQ-37
        CPQ_StretchTriggerHandler.clearManagedStretchesForQuoteWrappers(quoteWrappers);
        CPQ_TablesDataWrapper.clearQuotesFromCache(quoteWrappers);
        update CPQ_Quote.fillControlMetricsForQuotes(quoteWrappers, CPQ_Settings.DefaultPBAEstimatedConsCoef);
        // PCPQ-72
        //CPQ_Quote.manageStretches(quoteWrappers);
        CPQ_LogUtil.debug('********* [CPQ_QuoteLineTriggerHandler] afterInsert END '+Limits.getQueries());
    }

    public void afterUpdate(
        List<SBQQ__QuoteLine__c> oldQuoteLines,
        List<SBQQ__QuoteLine__c> newQuoteLines,
        Map<ID, SObject> oldQuoteLineMap,
        Map<ID, SObject> newQuoteLineMap
    ) {
        CPQ_LogUtil.debug('********* [CPQ_QuoteLineTriggerHandler] afterUpdate START '+Limits.getQueries());
        List<CPQ_Quote.QuoteWrapper> quoteWrappers = CPQ_QuoteService.buildWrappersFromQuotesId(
                                                        CPQ_QuoteLineService.extractQuoteIdFromQuoteLines(newQuoteLines));
        // PCPQ-37
        CPQ_StretchTriggerHandler.clearManagedStretchesForQuoteWrappers(quoteWrappers);
        CPQ_TablesDataWrapper.clearQuotesFromCache(quoteWrappers);
        update CPQ_Quote.fillControlMetricsForQuotes(quoteWrappers, CPQ_Settings.DefaultPBAEstimatedConsCoef);
        
        // PCPQ-72
        //CPQ_Quote.manageStretches(quoteWrappers);
        CPQ_LogUtil.debug('********* [CPQ_QuoteLineTriggerHandler] afterUpdate END '+Limits.getQueries());
    }

    public void afterDelete(List<SBQQ__QuoteLine__c> oldQuoteLines, Map<ID, SObject> oldQuoteLineMap) {
        List<CPQ_Quote.QuoteWrapper> quoteWrappers = CPQ_QuoteService.buildWrappersFromQuotesId(
                                                        CPQ_QuoteLineService.extractQuoteIdFromQuoteLines(oldQuoteLines));
        // PCPQ-37
        CPQ_StretchTriggerHandler.clearManagedStretchesForQuoteWrappers(quoteWrappers);
        CPQ_TablesDataWrapper.clearQuotesFromCache(quoteWrappers);
        update CPQ_Quote.fillControlMetricsForQuotes(quoteWrappers, CPQ_Settings.DefaultPBAEstimatedConsCoef);
        // PCPQ-72
        //CPQ_Quote.manageStretches(quoteWrappers);
    }

    public void afterUndelete(List<SBQQ__QuoteLine__c> newQuoteLines, Map<ID, SObject> newQuoteLineMap) {
        List<CPQ_Quote.QuoteWrapper> quoteWrappers = CPQ_QuoteService.buildWrappersFromQuotesId(
                                                        CPQ_QuoteLineService.extractQuoteIdFromQuoteLines(newQuoteLines));
                                     
        CPQ_StretchTriggerHandler.clearManagedStretchesForQuoteWrappers(quoteWrappers);   
        CPQ_TablesDataWrapper.clearQuotesFromCache(quoteWrappers);                
        update CPQ_Quote.fillControlMetricsForQuotes(quoteWrappers, CPQ_Settings.DefaultPBAEstimatedConsCoef);
        // PCPQ-72
        //CPQ_Quote.manageStretches(quoteWrappers);
    }
}