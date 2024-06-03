public inherited sharing class CPQ_QuoteRepository {

    public static List<SBQQ__Quote__c> getOpportunityDraftQuotes(Set<Id> opportunityIds) {
        return [
            SELECT
                Id,
                County__c,
                SBQQ__Status__c
            FROM
                SBQQ__Quote__c
            WHERE
                SBQQ__Opportunity2__c IN :opportunityIds
            AND 
                SBQQ__Status__c = :CPQ_QuoteConstants.STATUS_DRAFT
        ];
    }

    public static SBQQ__Quote__c getQuoteById(Id quoteId) {
        return [
            SELECT 
                Id,
                PBA__c,
                GasPriceRange__c,
                Credit__c,
                Investment__c,
                NonRecoveryInvestment__c
            FROM
                SBQQ__Quote__c
            WHERE
                Id = :quoteId
        ][0];
    }

}