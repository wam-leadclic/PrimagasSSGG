@isTest
public class ApprovalProcessSkipManagerTest {
    
    @isTest
    public static void testApprovalProcessSkipManagerTest() {
        List<Integer> positions = new List<Integer> {3, 2, 1, null};
        Account account = ApprovalTestDataFactory.createAccount(null);
        insert account;
        Opportunity opportunity = ApprovalTestDataFactory.createOpportunity(account.Id, null);
        insert opportunity;
        SBQQ__Quote__c quote = ApprovalTestDataFactory.createQuote(opportunity.Id, new Map<String, Object> {
            'HasStretches__c' => true
        });
        insert quote;
        Test.startTest();
        ApprovalProcessSkipManager.skipApprovalProcess(new List<Id>{quote.Id});
        Test.stopTest();
        List<ApprovalRequest__c> requests = [SELECT Id, Quote__r.SBQQ__Status__c, Resolution__c FROM ApprovalRequest__c];
        System.assertEquals(1, requests.size());
        System.assertEquals(CPQ_QuoteConstants.STATUS_APPROVED, requests[0].Quote__r.SBQQ__Status__c);
        System.assertEquals(ApprovalRequestConstants.RESOLUTION_APPROVED, requests[0].Resolution__c);

    }
}