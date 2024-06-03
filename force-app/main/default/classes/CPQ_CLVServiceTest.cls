@isTest
public class CPQ_CLVServiceTest {
    
    @TestSetup
    static void setup() {
        CPQ_TestDataFactory.LoadAllCSVTestDatasets();
        CPQ_TestDataFactory.FetchProductsByProductCode();

        Account account = new CPQ_TestDataFactory.AccountBuilder('TestAccount1').build();
        insert account;

        CPQ_TestDataFactory.buildTestQuoteA(account.Id);
    }

    @IsTest
    static void testCLV() {
        CPQ_TestDataFactory.setDefaultSettings();

        SBQQ__Quote__c quote1 = [SELECT Id, EstimatedConsumption__c FROM SBQQ__Quote__c LIMIT 1];

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        // Test CLV5
        System.assertEquals(3393.3, (Decimal)Math.round(CPQ_CLVService.calculateResult(5, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef)*10)/(Decimal)10);
        // Test CLV10
        System.assertEquals(9369.3, (Decimal)Math.round(CPQ_CLVService.calculateResult(10, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef)*10)/(Decimal)10);
    }

    @IsTest
    static void testCLVWithDifferentSettings() {

        CPQ_Settings.setTestSetting(new CPQ_Settings__mdt(DiscountRatePercentage__c = 8,
                                                            DepRate5Years__c = 10,
                                                            DepRate10Years__c = 5,
                                                            DepYears__c = 15,
                                                            DefaultPBAEstimatedConsPerc__c = 80,
                                                            LogsEnabled__c = true));

        SBQQ__Quote__c quote1 = [SELECT Id, EstimatedConsumption__c FROM SBQQ__Quote__c LIMIT 1];

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        // Test CLV5
        System.assertEquals(4219.5, (Decimal)Math.round(CPQ_CLVService.calculateResult(5, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef)*10)/(Decimal)10);
        // Test CLV10
        System.assertEquals(11717.0, (Decimal)Math.round(CPQ_CLVService.calculateResult(10, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef)*10)/(Decimal)10);
    }
}