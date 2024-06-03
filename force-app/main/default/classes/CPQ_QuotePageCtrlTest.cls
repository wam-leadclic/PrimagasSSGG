@IsTest
private with sharing class CPQ_QuotePageCtrlTest {

    @isTest
    static void testCPQ_QuotePageCtrl() {
        CPQ_TestDataFactory.LoadAllCSVTestDatasets();
        CPQ_TestDataFactory.setDefaultSettings();
        CPQ_TestDataFactory.FetchProductsByProductCode();
        CPQ_TestDataFactory.FetchTankMaintenanceCostByTankName();
        CPQ_TestDataFactory.FetchTankMasterDataByTankName();

        Account acc = new CPQ_TestDataFactory.AccountBuilder('test').build();
        insert acc;

        CPQ_TestDataFactory.buildTestQuoteA(acc.Id);
        String quoteId = [SELECT Id FROM SBQQ__Quote__c].Id;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', quoteId);
        CPQ_QuotePageCtrl controller = new CPQ_QuotePageCtrl();
        Test.stopTest();

        System.assertEquals(controller.q.accountName, 'test');

    }



}