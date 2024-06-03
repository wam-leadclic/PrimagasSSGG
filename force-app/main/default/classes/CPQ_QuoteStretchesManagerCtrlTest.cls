@isTest
public without sharing class CPQ_QuoteStretchesManagerCtrlTest {
    
    @TestSetup
    static void setup(){
        CPQ_TestDataFactory.LoadAllCSVTestDatasets();
        CPQ_TestDataFactory.FetchProductsByProductCode();

        Account account = new CPQ_TestDataFactory.AccountBuilder('TestAccount1').build();
        insert account;

        CPQ_TestDataFactory.buildTestQuoteA(account.Id);
    }

    @IsTest
    static void testDefaultStretchesCreation(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        CPQ_QuoteStretchesManagerCtrl.toggleStretchesForQuote(quote.Id, true);

        // Check the default stretches are created:
        Map<Decimal, Stretch__c> strechByFromPerc = new Map<Decimal, Stretch__c>();
        for(Stretch__c s : [SELECT Id, FromPercentage__c FROM Stretch__c WHERE Quote__c =: quote.Id]){
            strechByFromPerc.put(s.FromPercentage__c, s);
        }
        System.assertEquals(3, strechByFromPerc.size());
        System.assert(strechByFromPerc.containsKey(120));
        System.assert(strechByFromPerc.containsKey(80));
        System.assert(strechByFromPerc.containsKey(50));
        
        // Simulate end of transaction:
        CPQ_StretchTriggerHandler.clearManagedStretches();
        
        // Check the stretches are removed:
        CPQ_QuoteStretchesManagerCtrl.toggleStretchesForQuote(quote.Id, false);
        System.assertEquals(0, new List<Stretch__c>([SELECT Id FROM Stretch__c WHERE Quote__c =: quote.Id]).size());
        
    }
    
    @IsTest
    static void testDiscountAndNewStretchCreation(){
        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{quote.Id})[0];

        List<CPQ_QuoteStretchesManagerCtrl.StretchWrapper> stretches = CPQ_QuoteStretchesManagerCtrl.toggleStretchesForQuote(quote.Id, true);
        
        // Simulate end of transaction:
        CPQ_StretchTriggerHandler.clearManagedStretches();

        CPQ_QuoteStretchesManagerCtrl.StretchWrapper newStretchWrapper = CPQ_QuoteStretchesManagerCtrl.generateNewStretch(quote.Id);
        stretches.add(newStretchWrapper);

        // Check the new stretch got the values dumped from the quote:
        System.assertEquals(quote.Id,                       newStretchWrapper.stretch.Quote__c);
        System.assertEquals(quoteWrapper.PrimaServicios,    newStretchWrapper.Primaservicios);
        System.assertEquals(quoteWrapper.PriceTodayKG,      newStretchWrapper.priceToday_EurosXKG);

        // Check the stretch is not still commited to the db:
        System.assertEquals(3, new List<Stretch__c>([SELECT Id FROM Stretch__c WHERE Quote__c =: quote.Id]).size());

        newStretchWrapper.DTO_EurosXKG = 0.01;
        newStretchWrapper.FromValue = 110;
        newStretchWrapper.Primaservicios = 100;

        // Remove the 'attributes' key to prevent the save method from failing:
        List<Object> allStretchesJSON = (List<Object>)JSON.deserializeUntyped(JSON.serialize(stretches));
        for(Object o : allStretchesJSON){
            Map<String, Object> ob = (Map<String, Object>)o;
            ((Map<String,Object>)(ob.get('stretch'))).remove('attributes');
        }
        
        CPQ_QuoteStretchesManagerCtrl.save(Json.serialize(allStretchesJSON), quote.Id);
        
        // Simulate end of transaction:
        CPQ_StretchTriggerHandler.clearManagedStretches();

        // Check the stretch is commited to the db:
        System.assertEquals(4, new List<Stretch__c>([SELECT Id FROM Stretch__c WHERE Quote__c =: quote.Id]).size());

        // Check the input fields are properly stored:
        Stretch__c newStretch = [SELECT Id, DiscountKG__c, FromPercentage__c, PrimaServiciosA__c FROM Stretch__c WHERE FromPercentage__c = 110 LIMIT 1];
        System.assertEquals(0.01, newStretch.DiscountKG__c);
        System.assertEquals(100, newStretch.PrimaServiciosA__c);

        // Check the suggested discount for the specific stretch has changed
        CPQ_QuoteStretchesManagerCtrl.StretchWrapper stretchWithNewDiscount =
            CPQ_QuoteStretchesManagerCtrl.fillDiscountInputForStretch(Json.serialize(allStretchesJSON[3]), quote.Id);

        System.assertNotEquals(0.5, stretchWithNewDiscount.DTO_EurosXKG);

        Test.stopTest();
        
    }
}