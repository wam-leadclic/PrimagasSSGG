@isTest
public class CPQ_TankMasterDataTest {
    
    @TestSetup
    static void setup(){
        
        CPQ_TestDataFactory.LoadTankMasterData();
        CPQ_TestDataFactory.LoadProducts();
        CPQ_TestDataFactory.FetchProductsByProductCode();

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

        
        List<SBQQ__QuoteLine__c> qlis = new List<SBQQ__QuoteLine__c>{
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DEPOSITO).Id)
                .withNetPrice(20)
                .withQuantity(2)
                .withTankName('LP13000A')
                .build()
        };

        insert qlis;
    }

    @IsTest
    static void testGetTankDataForQuote(){
        
        SBQQ__Quote__c quote1 = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        
        CPQ_TankMasterData.TankMasterDataByName tmd = CPQ_TankMasterData.getForQuoteWrappers(quoteWrapper);

        System.assertNotEquals(null, tmd.getFirstForName('LP13000A'));
        System.assertEquals(2065, tmd.getFirstForName('LP13000A').Dismantle__c);

    }
}