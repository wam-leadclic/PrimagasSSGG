public with sharing class CPQ_QuoteService {
    /*
    public static Map<SBQQ__Quote__c, List<Opportunity>> getOpportunitiesByQuote(Set<Id> quotesId) {
        List<SBQQ__Quote__c> quotes = CPQ_QuoteSelector.selectByIdWithOpportunities(quotesId);

        Map<SBQQ__Quote__c, List<Opportunity>> output = new Map<SBQQ__Quote__c, List<Opportunity>>();

        for (SBQQ__Quote__c quote : quotes) {
            output.put(quote, new List<Opportunity>());

            for (Opportunity o : quote.SBQQ__PrimaryOpportunities__r) {
                output.get(quote).add(o);
            }
        }

        return output;
    }*/

    public static CPQ_Quote.QuoteWrapper buildWrapperForPDFQuote(Id quoteId) {
        return buildWrappersFromQuotesWithQuoteLineItems(new List<SBQQ__Quote__c>{CPQ_QuoteSelector.selectByIdForPDF(quoteId)})[0];
    }

    public static List<CPQ_Quote.QuoteWrapper> buildWrappersFromQuotesId(Set<Id> quotesId) {
        return buildWrappersFromQuotesWithQuoteLineItems(CPQ_QuoteSelector.selectByIdWithQuoteLineItems(quotesId));
    }

    /**
     * This method is used when SBQQ__Quote__c records (whose reference must be kept) have not fetched the QLIs.
     * @param quotes 
     * @return  `List<CPQ_Quote.QuoteWrapper>`
     */
    public static List<CPQ_Quote.QuoteWrapper> buildWrappersFromQuotesWithoutQLIs(List<SBQQ__Quote__c> quotes) {
        Set<Id> quotesId = new Set<Id>();
        for (SBQQ__Quote__c q : quotes) {
            quotesId.add(q.Id);
        }

        CPQ_Opportunity.fillOpportunityDataForQuotes(quotes);

        Map<Id, SBQQ__Quote__c> queriedQuotesWithQLI = new Map<Id, SBQQ__Quote__c>(
            CPQ_QuoteSelector.selectByIdWithQuoteLineItems(quotesId)
        );

        // As the argument quotes do not contain the QLI records, fill them:
        List<CPQ_Quote.QuoteWrapper> wrappers = new List<CPQ_Quote.QuoteWrapper>();

        //

        for (SBQQ__Quote__c q : quotes) {
            wrappers.add(
                buildWrapperFromQuote(
                    q,
                    queriedQuotesWithQLI.containsKey(q.Id)
                        ? queriedQuotesWithQLI.get(q.Id).SBQQ__LineItems__r
                        : new List<SBQQ__QuoteLine__c>()
                )
            );
        }

        return wrappers;
    }

    public static List<CPQ_Quote.QuoteWrapper> buildWrappersFromQuotesWithQuoteLineItems(List<SBQQ__Quote__c> quotes) {
        List<CPQ_Quote.QuoteWrapper> output = new List<CPQ_Quote.QuoteWrapper>();
        for (SBQQ__Quote__c quote : quotes) {
            output.add(buildWrapperFromQuote(quote, quote.SBQQ__LineItems__r));
        }
        return output;
    }

    public static CPQ_Quote.QuoteWrapper buildWrapperFromQuote(SBQQ__Quote__c quote, List<SBQQ__QuoteLine__c> qlis) {
        return new CPQ_Quote.QuoteWrapper(quote, qlis);
    }
}