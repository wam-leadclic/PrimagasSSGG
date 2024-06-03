@isTest
public class CPQ_MetricsServiceTest {
    
    @TestSetup
    static void setup() {
        CPQ_TestDataFactory.LoadAllCSVTestDatasets();
        CPQ_TestDataFactory.FetchProductsByProductCode();

        Account account = new CPQ_TestDataFactory.AccountBuilder('TestAccount1').build();
        insert account;

        CPQ_TestDataFactory.buildTestQuoteA(account.Id);
    }

    @IsTest
    static void testMetrics() {
        CPQ_TestDataFactory.setDefaultSettings();

        SBQQ__Quote__c quote1 = [SELECT Id, EstimatedConsumption__c FROM SBQQ__Quote__c LIMIT 1];

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        CPQ_MetricsService.OutputMetricsWrapper metrics = CPQ_MetricsService.calculateREST(quoteWrapper.Quote, quoteWrapper.Lines);

        // Test PBA
        System.assertEquals(2.77, (Decimal)Math.round(metrics.PBA*100)/(Decimal)100);
        // Test CLV5
        System.assertEquals(3393.3, (Decimal)Math.round(metrics.CLV5*10)/(Decimal)10);
        // Test CLV10
        System.assertEquals(9369.3, (Decimal)Math.round(metrics.CLV10*10)/(Decimal)10);
    }

    @IsTest
    static void testMetricsError() {
        SBQQ__Quote__c quote1 = [SELECT Id, EstimatedConsumption__c FROM SBQQ__Quote__c LIMIT 1];

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        CPQ_MetricsService.OutputMetricsWrapper metrics = CPQ_MetricsService.calculateREST(null, null);

        // Test error found
        System.assert(String.isNotBlank(metrics.error));
    }

}