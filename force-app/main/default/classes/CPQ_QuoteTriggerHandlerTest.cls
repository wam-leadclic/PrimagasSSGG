@isTest
public without sharing class CPQ_QuoteTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
        List<Integer> nQueriesConsumed = new List<Integer>();

        CPQ_TestDataFactory.LoadGasCosts();
        CPQ_TestDataFactory.LoadProducts();
        CPQ_TestDataFactory.LoadTankMasterData();
        CPQ_TestDataFactory.LoadTankMaintenanceCosts();

        CPQ_TestDataFactory.FetchProductsByProductCode();

        nQueriesConsumed.add(Limits.getQueries());

        Account account = new CPQ_TestDataFactory.AccountBuilder('TestAccount1').build();
        insert account;

        Opportunity opp1 = new CPQ_TestDataFactory.OpportunityBuilder('Opp1')
            .withCounty('Barcelona')
            .withCloseDate(Date.today())
            .withStageName('Closed')
            .build();
        insert opp1;

        SBQQ__Quote__c quote1 = new CPQ_TestDataFactory.QuoteBuilder()
            .withOpportunity(opp1.Id)
            .withStatus(CPQ_Quote.STATUS_IN_DRAFT)
            .withAccount(account.Id)
            .withEstimatedConsumption(123)
            .withClientTank(true)
            .build();

        SBQQ__Quote__c quote2 = new CPQ_TestDataFactory.QuoteBuilder()
            .withOpportunity(opp1.Id)
            .withStatus(CPQ_Quote.STATUS_IN_DRAFT)
            .withAccount(account.Id)
            .withEstimatedConsumption(123)
            .withClientTank(true)
            .build();

        SBQQ__Quote__c quote3 = new CPQ_TestDataFactory.QuoteBuilder()
            .withOpportunity(opp1.Id)
            .withStatus(CPQ_Quote.STATUS_IN_DRAFT)
            .withAccount(account.Id)
            .withEstimatedConsumption(123)
            .withClientTank(true)
            .build();

        nQueriesConsumed.add(Limits.getQueries());

        insert new List<SBQQ__Quote__c>{quote1, quote2, quote3};

        List<SBQQ__QuoteLine__c> qlis = new List<SBQQ__QuoteLine__c>{
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DEPOSITO).Id)
                .withNetPrice(20)
                .withQuantity(2)
                .withTankName('LP13000A')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.OBRACIVIL).Id)
                .withNetPrice(20)
                .withQuantity(4)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.VALLADO).Id)
                .withNetPrice(76)
                .withQuantity(5)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.CUOTASALQUILER).Id)
                .withNetPrice(123)
                .withQuantity(7)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PROYECTOMEMORIA).Id)
                .withNetPrice(100)
                .withQuantity(2)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.CUOTASINVERSION).Id)
                .withNetPrice(44)
                .withQuantity(6)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DESCTARIFA).Id)
                .withNetPrice(2)
                .withDiscountDuration(2)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                // Family = 'Tarifas'
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PSADAINT).Id)
                .withNetPrice(3)
                .withQuantity(6)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DESC1LLENADO).Id)
                .withNetPrice(18)
                .withQuantity(3)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                // Family = 'Primaservicios'
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PAGOINICIAL).Id)
                .withNetPrice(10)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                // Family = 'Primaservicios'
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PUESTAAPUNTO).Id)
                .withNetPrice(20)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                // Family = 'Primaservicios'
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.AUTOGAS).Id)
                .withNetPrice(33)
                .withQuantity(2)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.OTROSEQUIPOS).Id)
                .withNetPrice(55)
                .withQuantity(5)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.OTROSEQUIPOS).Id)
                .withNetPrice(99)
                .withQuantity(2)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSTALACION).Id)
                .withNetPrice(100)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSTALACION).Id)
                .withTankName('LP24450A')
                .withNetPrice(234)
                .withQuantity(3)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSTALACION).Id)
                .withTankName('SM1000A')
                .withNetPrice(567)
                .withQuantity(2)
                .build()
        };

        nQueriesConsumed.add(Limits.getQueries());
        insert qlis;
        nQueriesConsumed.add(Limits.getQueries());

        System.debug('TEST SETUP Queries: '+nQueriesConsumed);
    }

    @IsTest
    static void testComputedFieldsForQuotes(){
        List<SBQQ__Quote__c> quotes = [SELECT Id, HasStretches__c, ClientTank__c FROM SBQQ__Quote__c ORDER BY Id ASC];
        
        System.assertEquals(false, quotes[0].HasStretches__c);
        System.assertEquals(false, quotes[1].HasStretches__c);
        System.assertEquals(false, quotes[2].HasStretches__c);
        System.assertEquals(!quotes[0].ClientTank__c, quotes[0].HasStretches__c);
        System.assertEquals(!quotes[1].ClientTank__c, quotes[1].HasStretches__c);
        System.assertEquals(!quotes[2].ClientTank__c, quotes[2].HasStretches__c);

        CPQ_LogUtil.debug('Test Queries A: '+Limits.getQueries());
        // Check the HasStretches__c changes when the ClientTank__c changes:
        quotes[0].ClientTank__c = false;
        update quotes;

        CPQ_LogUtil.debug('Test Queries B: '+Limits.getQueries());

        quotes = [SELECT Id, HasStretches__c, ClientTank__c FROM SBQQ__Quote__c ORDER BY Id ASC];

        System.assertEquals(!quotes[0].ClientTank__c, quotes[0].HasStretches__c);
        System.assertEquals(!quotes[1].ClientTank__c, quotes[1].HasStretches__c);
        System.assertEquals(!quotes[2].ClientTank__c, quotes[2].HasStretches__c);

        System.assertEquals(true, quotes[0].HasStretches__c);
        System.assertEquals(false, quotes[1].HasStretches__c);
        System.assertEquals(false, quotes[2].HasStretches__c);

        // Check the default stretches were created for the quote:
        List<Stretch__c> stretches = [SELECT Id, FromPercentage__c FROM Stretch__c WHERE Quote__c =: quotes[0].Id];

        System.assertEquals(3, stretches.size());
        System.assertEquals(stretches[0].FromPercentage__c, 120);
        System.assertEquals(stretches[1].FromPercentage__c, 80);
        System.assertEquals(stretches[2].FromPercentage__c, 50);

        // Simulate end of transaction:
        CPQ_StretchTriggerHandler.clearManagedStretches();

        // Check the stretches are removed:
        quotes[0].HasStretches__c = false;

        CPQ_LogUtil.debug('Test Queries C: '+Limits.getQueries());
        update quotes;
        CPQ_LogUtil.debug('Test Queries D: '+Limits.getQueries());
        
        stretches = [SELECT Id, FromPercentage__c FROM Stretch__c WHERE Quote__c =: quotes[0].Id];
        System.assertEquals(0, stretches.size());

    }
}