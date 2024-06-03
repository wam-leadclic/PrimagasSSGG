@isTest
public without sharing class CPQ_PBAServiceTest {
    
    @TestSetup
    static void setup() {
        CPQ_TestDataFactory.LoadAllCSVTestDatasets();
        CPQ_TestDataFactory.FetchProductsByProductCode();

        Account account = new CPQ_TestDataFactory.AccountBuilder('TestAccount1').build();
        insert account;
    }

    public class MyException extends Exception {
        
    }

    @IsTest
    static void testPBA1() {
        CPQ_TestDataFactory.FetchProductsByProductCode();
        CPQ_TestDataFactory.setDefaultSettings();
        
        Test.startTest();
        CPQ_TestDataFactory.buildTestQuoteA([SELECT Id FROM Account WHERE Name = 'TestAccount1' LIMIT 1].Id);
        Test.stopTest();

        SBQQ__Quote__c quote1 = [SELECT Id, EstimatedConsumption__c FROM SBQQ__Quote__c LIMIT 1];

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        CPQ_PBAService.PBAParams pba = CPQ_PBAService.build(quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef);

        System.assertEquals(23, quoteWrapper.Lines.size());
        System.assertEquals('Barcelona', quoteWrapper.Quote.County__c);
        System.assert(quoteWrapper.IsDomestic, 'The quote should be set as domestic.');

        // ========================= Values taken from Quote + Quote related records ============================= //
        System.assertEquals(quote1.EstimatedConsumption__c, pba.AnnualConsumptionKG);
        System.assertEquals(400, pba.InitialPayment);
        System.assertEquals(300, pba.Projects);
        System.assertEquals(2250, pba.TankCost);
        System.assertEquals(24, pba.RentFeeDurationMonths);
        System.assertEquals(20, pba.RentFeeEuroMonth);
        System.assertEquals(15, pba.FeeDuration);
        System.assertEquals(30, pba.InvestmentFeeEuroMonth);
        System.assertEquals(0.050, pba.DiscountEuroKG);
        System.assertEquals(3, pba.DiscountDurationInYears);
        System.assertEquals(0.790, pba.FeeAmount);
        // (ETERNELLA - Barcelona) Cost: 131.57
        System.assertEquals(131.572, pba.TankMaintenanceCost);
        System.assertEquals(500, pba.FirstFillDiscount);
        System.assertEquals(19.85, pba.Primaservicios);
        // (Barcelona) Cost: 0.3768
        System.assertEquals(0.3768, pba.GasCost);
        System.assertEquals(168.63, pba.ServicesCost);
        // (Barcelona) TransportationCost: 0.0361
        System.assertEquals(0.0361, pba.TransportationCost);
        System.assertEquals(3000, pba.OtherEquipment);
        System.assertEquals(500, pba.OtherEquipmentInstallation);
        System.assertEquals(750, pba.CivilWorksAndFencing);

        // ========================= Values calculated from previous ones ============================= //
        System.assertEquals(pba.TotalInvestment - pba.TankCost - pba.RecoverableAmount, pba.NonRecoveryInvestment);
        System.assertEquals(pba.TankCost + pba.TankInstallation + pba.Projects + pba.CivilWorksAndFencing, pba.TankTotal);
        System.assertEquals(pba.OtherEquipment + pba.OtherEquipmentInstallation, pba.EquipmentTotal);
        System.assertEquals(pba.GasMarginEuroKG * pba.AnnualConsumptionKG * pba.GasMarginCoef, pba.GasMargin);
        System.assertEquals(pba.Primaservicios * 12, pba.PrimaserviciosAnnual);
        System.assertEquals(
            pba.GasMargin + pba.AnnualInvestmentFeeIncome + pba.AnnualRentFeeIncome + pba.PrimaserviciosAnnual
                            - pba.ServicesCost - pba.TankMaintenanceCost - pba.FirstFillDiscount, 
            pba.TotalMargin
        );

        // The decimal values for the PBA value are large, so round it to 2 digits:
        System.assertEquals(2.77, (Decimal)Math.round(pba.calculateResult()*100)/(Decimal)100);
    }
    
    @IsTest
    static void testRecoverableAmount() {
        CPQ_TestDataFactory.FetchProductsByProductCode();
        CPQ_TestDataFactory.setDefaultSettings();
        
        Test.startTest();
        CPQ_TestDataFactory.buildTestQuoteB([SELECT Id FROM Account WHERE Name = 'TestAccount1' LIMIT 1].Id);
        Test.stopTest();

        SBQQ__Quote__c quote1 = [SELECT Id, EstimatedConsumption__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Name = 'Opp2' LIMIT 1];

        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{ quote1.Id })[0];
        CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

        CPQ_PBAService.PBAParams pba = CPQ_PBAService.build(quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef);

        System.assertEquals(800, pba.RecoverableAmount);
        System.assertEquals(pba.TotalInvestment - pba.TankCost - pba.RecoverableAmount, pba.NonRecoveryInvestment);
    }
}