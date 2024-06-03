@isTest
public class CPQ_GasCostTest {

    @TestSetup
    static void setup(){
        CPQ_TestDataFactory.LoadGasCosts();

        Account account1 = new CPQ_TestDataFactory.AccountBuilder('TestAccount1').build();
        insert account1;

        Opportunity opp1 = new CPQ_TestDataFactory.OpportunityBuilder('Opp1')
            .withCounty('Barcelona')
            .withCloseDate(Date.today())
            .withStageName('Closed')
            .build();
        insert opp1;

        SBQQ__Quote__c quote1 = new CPQ_TestDataFactory.QuoteBuilder()
            .withOpportunity(opp1.Id)
            .withAccount(account1.Id)
            .withEstimatedConsumption(123)
            .build();
        insert quote1;
        
        Account account2 = new CPQ_TestDataFactory.AccountBuilder('TestAccount2').build();
        insert account2;

        Opportunity opp2 = new CPQ_TestDataFactory.OpportunityBuilder('Opp1')
            .withCounty('Madrid')
            .withCloseDate(Date.today())
            .withStageName('Closed')
            .build();
        insert opp2;

        SBQQ__Quote__c quote2 = new CPQ_TestDataFactory.QuoteBuilder()
            .withOpportunity(opp2.Id)
            .withAccount(account2.Id)
            .withEstimatedConsumption(123)
            .build();
        insert quote2;
    }

    @IsTest
    static void testGetGasCostForSingleQuote(){

        SBQQ__Quote__c quote1 = [SELECT Id, County__c FROM SBQQ__Quote__c LIMIT 1];
        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        
        CPQ_GasCost.GasCostsByCounty gc = CPQ_GasCost.getGasCostsForQuotes(quoteWrapper);

        System.assertNotEquals(null, gc.getForCounty(quoteWrapper.Quote.County__c));
        System.assertEquals(0.3768, gc.getForCounty(quoteWrapper.Quote.County__c).Cost__c);

    }

    @IsTest
    static void testGetGasCostForMultipleQuotes(){

        SBQQ__Quote__c quote1 = [SELECT Id, County__c FROM SBQQ__Quote__c WHERE County__c = 'Barcelona' LIMIT 1];
        SBQQ__Quote__c quote2 = [SELECT Id, County__c FROM SBQQ__Quote__c WHERE County__c = 'Madrid' LIMIT 1];
        
        Map<String, CPQ_Quote.QuoteWrapper> quoteWrappersByCounty = new Map<String, CPQ_Quote.QuoteWrapper>();
        for(CPQ_Quote.QuoteWrapper w : CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id , quote2.Id })){
            quoteWrappersByCounty.put(w.Quote.County__c, w);
        }

        CPQ_GasCost.GasCostsByCounty gc = CPQ_GasCost.getGasCostsForQuotes(quoteWrappersByCounty.values());

        System.assertNotEquals(null, gc.getForCounty(quoteWrappersByCounty.get('Barcelona').Quote.County__c));
        System.assertEquals(0.3768, gc.getForCounty(quoteWrappersByCounty.get('Barcelona').Quote.County__c).Cost__c);

        System.assertNotEquals(null, gc.getForCounty(quoteWrappersByCounty.get('Madrid').Quote.County__c));
        System.assertEquals(0.433, gc.getForCounty(quoteWrappersByCounty.get('Madrid').Quote.County__c).Cost__c);

        // Test the data is not found for a county different from the quote's:
        System.assertEquals(null, gc.getForCounty('Cuenca'));

    }

}