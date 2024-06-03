@isTest
public with sharing class CPQ_QuoteLineTriggerHandlerTest {

    @TestSetup
    static void setup() {
        CPQ_TestDataFactory.LoadAllCSVTestDatasets();
        CPQ_TestDataFactory.FetchProductsByProductCode();

        Account account = new CPQ_TestDataFactory.AccountBuilder('TestAccount1').build();
        insert account;

        CPQ_TestDataFactory.buildTestQuoteA(account.Id);
    }

    @IsTest
    static void testMetricsRecalculatedForQuote() {
        CPQ_TestDataFactory.setDefaultSettings();

        SBQQ__Quote__c quote1 = [
            SELECT Id, PBA__c, CLV5__c, CLV10__c, EstimatedConsumption__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        Test.startTest();

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        CPQ_PBAService.PBAParams pba = CPQ_PBAService.build(quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef);

        // 1.- Test the saved metrics in the quote are initially calculated:
        // The decimal values for the PBA value are large, so round it to 2 digits:
        System.assertEquals(2.77, (Decimal) Math.round(pba.calculateResult() * 100) / (Decimal) 100);
        System.assertEquals(2.77, (Decimal) Math.round(quote1.PBA__c * 100) / (Decimal) 100);

        // Test CLV5
        System.assertEquals(
            3393.3,
            (Decimal) Math.round(CPQ_CLVService.calculateResult(5, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef) * 10) / (Decimal) 10
        );
        System.assertEquals(3393.3, (Decimal) Math.round(quote1.CLV5__c * 10) / (Decimal) 10);
        // Test CLV10
        System.assertEquals(
            9369.3,
            (Decimal) Math.round(CPQ_CLVService.calculateResult(10, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef) * 10) / (Decimal) 10
        );
        System.assertEquals(9369.3, (Decimal) Math.round(quote1.CLV10__c * 10) / (Decimal) 10);

        // 2.- Check the metrics are recalculated if a line item is modified:
        SBQQ__QuoteLine__c proyectoMemoriaQLI = null;
        List<SBQQ__QuoteLine__c> lines = [SELECT Id, SBQQ__ProductCode__c
                                   FROM SBQQ__QuoteLine__c
                                   WHERE SBQQ__Quote__c =: quoteWrapper.Quote.Id
                                     AND SBQQ__ProductCode__c IN :new List<String>{CPQ_ProductCodes.PROYECTOMEMORIA, CPQ_ProductCodes.CUOTASALQUILER}];

        // 3.- Change the lines values:
        for(SBQQ__QuoteLine__c l : lines){
            if(l.SBQQ__ProductCode__c == CPQ_ProductCodes.PROYECTOMEMORIA){
                l.SBQQ__NetPrice__c = 600;
                proyectoMemoriaQLI = l;
            }else if(l.SBQQ__ProductCode__c == CPQ_ProductCodes.CUOTASALQUILER){
                l.SBQQ__Quantity__c = 26;
            }
        }

        update lines;

        quote1 = [
            SELECT Id, PBA__c, CLV5__c, CLV10__c, EstimatedConsumption__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];
        quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];

        // 4.- Check the metrics have changed:
        System.assertEquals(2.87, (Decimal) Math.round(quote1.PBA__c * 100) / (Decimal) 100);
        // Test CLV5
        System.assertEquals(
            3122.6,
            (Decimal) Math.round(CPQ_CLVService.calculateResult(5, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef) * 10) / (Decimal) 10            
            );
        System.assertEquals(3122.58, (Decimal) Math.round(quote1.CLV5__c * 100) / (Decimal) 100);
        // Test CLV10
        System.assertEquals(9098.52, (Decimal) Math.round(quote1.CLV10__c * 100) / (Decimal) 100);

        Test.stopTest();

    }
    
    @IsTest
    static void testMetricsRecalculatedForQuoteUndelete() {
        CPQ_TestDataFactory.setDefaultSettings();

        SBQQ__Quote__c quote1 = [
            SELECT Id, PBA__c, CLV5__c, CLV10__c, EstimatedConsumption__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        Test.startTest();

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        CPQ_PBAService.PBAParams pba = CPQ_PBAService.build(quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef);

        // 1.- Test the saved metrics in the quote are initially calculated:
        // The decimal values for the PBA value are large, so round it to 2 digits:
        System.assertEquals(2.77, (Decimal) Math.round(pba.calculateResult() * 100) / (Decimal) 100);
        System.assertEquals(2.77, (Decimal) Math.round(quote1.PBA__c * 100) / (Decimal) 100);

        // Test CLV5
        System.assertEquals(
            3393.3,
            (Decimal) Math.round(CPQ_CLVService.calculateResult(5, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef) * 10) / (Decimal) 10
        );
        System.assertEquals(3393.3, (Decimal) Math.round(quote1.CLV5__c * 10) / (Decimal) 10);
        // Test CLV10
        System.assertEquals(
            9369.3,
            (Decimal) Math.round(CPQ_CLVService.calculateResult(10, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef) * 10) / (Decimal) 10
        );
        System.assertEquals(9369.3, (Decimal) Math.round(quote1.CLV10__c * 10) / (Decimal) 10);

        // 2.- Check the metrics are recalculated if a line item is modified:
        SBQQ__QuoteLine__c proyectoMemoriaQLI =  [SELECT Id, SBQQ__ProductCode__c
                FROM SBQQ__QuoteLine__c
                WHERE SBQQ__Quote__c =: quoteWrapper.Quote.Id
                AND SBQQ__ProductCode__c =: CPQ_ProductCodes.PROYECTOMEMORIA];

        // 3.- Delete and check the metrics again:
        delete proyectoMemoriaQLI;

        quote1 = [
            SELECT Id, PBA__c, CLV5__c, CLV10__c, EstimatedConsumption__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];
        // Test PBA
        System.assertEquals(2.65, (Decimal) Math.round(quote1.PBA__c * 100) / (Decimal) 100);
        // Test CLV5
        System.assertEquals(3693.33, (Decimal) Math.round(quote1.CLV5__c * 100) / (Decimal) 100);
        // Test CLV10
        System.assertEquals(9669.27, (Decimal) Math.round(quote1.CLV10__c * 100) / (Decimal) 100);
        
        // 4.- Undelete and check the metrics again:
        undelete proyectoMemoriaQLI;

        quote1 = [
            SELECT Id, PBA__c, CLV5__c, CLV10__c, EstimatedConsumption__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];
        // Test PBA
        System.assertEquals(2.77, (Decimal) Math.round(quote1.PBA__c * 100) / (Decimal) 100);
        // Test CLV5
        System.assertEquals(3393.3, (Decimal) Math.round(quote1.CLV5__c * 10) / (Decimal) 10);
        // Test CLV10
        System.assertEquals(9369.3, (Decimal) Math.round(quote1.CLV10__c * 10) / (Decimal) 10);
        
        Test.stopTest();

    }
}