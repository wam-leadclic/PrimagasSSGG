@isTest
public without sharing class CPQ_GPCAPEXServiceTest {
    
    @TestSetup
    static void setup() {
        CPQ_TestDataFactory.LoadAllCSVTestDatasets();
        CPQ_TestDataFactory.FetchProductsByProductCode();

        Account account = new CPQ_TestDataFactory.AccountBuilder('TestAccount1').build();
        insert account;

        CPQ_TestDataFactory.buildTestQuoteA(account.Id);
    }

    @IsTest
    static void testGPCAPEX() {
        CPQ_TestDataFactory.setDefaultSettings();

        SBQQ__Quote__c quote1 = [SELECT Id, EstimatedConsumption__c FROM SBQQ__Quote__c LIMIT 1];

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        // Test with 5 years contact duration
        System.assertEquals(1.867, (Decimal)Math.round(CPQ_GPCAPEXService.calculateResult(quoteWrapper, tablesData)*1000)/(Decimal)1000);

        // Test with 7 years contact duration
        quote1.Duration__c = 7;
        update quote1;
        
        quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        System.assertEquals(2.655, (Decimal)Math.round(CPQ_GPCAPEXService.calculateResult(quoteWrapper, tablesData)*1000)/(Decimal)1000);
    }
}