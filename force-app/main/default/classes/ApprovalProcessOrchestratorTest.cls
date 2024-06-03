@isTest
public class ApprovalProcessOrchestratorTest {

    private static Map<String, Product2> products;
    private static Account account;
    private static Opportunity opportunity;
    private static SBQQ__Quote__c quote;

    @TestSetup
    private static void createSampleMasterData() {
        ApprovalTestDataFactory.createSampleMasterData();
    }

    private static void createTestRecords() {
        account = ApprovalTestDataFactory.createAccount(null);
        insert account;
        opportunity = ApprovalTestDataFactory.createOpportunity(account.Id, null);
        insert opportunity;
        quote = ApprovalTestDataFactory.createQuote(opportunity.Id, null);
        insert quote;
    }

}