@isTest
public class ApprovalRequestResolutionTest {

    @TestSetup
    private static void createDataBackground() {
        List<Integer> positions = new List<Integer> {3, 2, 1, null};
        List<ApprovalRequest__c> requests = new List<ApprovalRequest__c>();
        Account account = ApprovalTestDataFactory.createAccount(null);
        insert account;
        Opportunity opportunity = ApprovalTestDataFactory.createOpportunity(account.Id, null);
        insert opportunity;
        SBQQ__Quote__c quote = ApprovalTestDataFactory.createQuote(opportunity.Id, new Map<String, Object> {
            'SBQQ__Status__c' => CPQ_QuoteConstants.STATUS_PENDING_APPROVAL,
            'HasStretches__c' => true
        });
        insert quote;
        for (Integer position : positions) {
            requests.add(new ApprovalRequest__c(
                Position__c = position,
                Approver__c = UserInfo.getUserId(),
                Quote__c = quote.Id
            ));
        }
        requests[0].Status__c = ApprovalRequestConstants.STATUS_REVIEWING;
        insert requests;
    }

    @isTest
    public static void testQuoteApproval() {
        Map<Integer, ApprovalRequest__c> requests = retrieveApprovalRequestsByPosition();
        ApprovalRequest__c request;

        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(null).Status__c, 'It should be set as pending since it is the default value');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(1).Status__c, 'It should be set as pending since it is the default value');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(2).Status__c, 'It should be set as pending since it is the default value');
        System.assertEquals(ApprovalRequestConstants.STATUS_REVIEWING, requests.get(3).Status__c, 'Set in test setup');

        Test.startTest();

        request = requests.get(3);
        request.Resolution__c = ApprovalRequestConstants.RESOLUTION_APPROVED;
        update request;
        
        requests = retrieveApprovalRequestsByPosition();
        System.assertEquals(ApprovalRequestConstants.STATUS_REVIEWING, requests.get(null).Status__c, 'First null values are evaluated');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(1).Status__c, 'It is not its turn yet');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(2).Status__c, 'It is not its turn yet');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(3).Status__c, 'The request has been fulfilled');
        System.assertEquals(CPQ_QuoteConstants.STATUS_PENDING_APPROVAL, requests.get(3).Quote__r.SBQQ__Status__c, 'The quote still has pending requests to be reviewed');

        request = requests.get(null);
        request.Resolution__c = ApprovalRequestConstants.RESOLUTION_APPROVED;
        update request;
        
        requests = retrieveApprovalRequestsByPosition();
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(null).Status__c, 'The request has been fulfilled');
        System.assertEquals(ApprovalRequestConstants.STATUS_REVIEWING, requests.get(1).Status__c, 'Position is evaluated in ascending order, so 1 is next');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(2).Status__c, 'It is not its turn yet');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(3).Status__c, 'The request has been fulfilled');
        System.assertEquals(CPQ_QuoteConstants.STATUS_PENDING_APPROVAL, requests.get(3).Quote__r.SBQQ__Status__c, 'The quote still has pending requests to be reviewed');

        request = requests.get(1);
        request.Resolution__c = ApprovalRequestConstants.RESOLUTION_APPROVED;
        update request;
        
        requests = retrieveApprovalRequestsByPosition();
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(null).Status__c, 'The request has been fulfilled');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(1).Status__c, 'The request has been fulfilled');
        System.assertEquals(ApprovalRequestConstants.STATUS_REVIEWING, requests.get(2).Status__c, 'Position is evaluated in ascending order, so 2 is next');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(3).Status__c, 'The request has been fulfilled');
        System.assertEquals(CPQ_QuoteConstants.STATUS_PENDING_APPROVAL, requests.get(3).Quote__r.SBQQ__Status__c, 'The quote still has pending requests to be reviewed');

        request = requests.get(2);
        request.Resolution__c = ApprovalRequestConstants.RESOLUTION_APPROVED;
        update request;
        
        requests = retrieveApprovalRequestsByPosition();
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(null).Status__c, 'The request has been fulfilled');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(1).Status__c, 'The request has been fulfilled');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(2).Status__c, 'The request has been fulfilled');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(3).Status__c, 'The request has been fulfilled');
        System.assertEquals(CPQ_QuoteConstants.STATUS_APPROVED, requests.get(3).Quote__r.SBQQ__Status__c, 'All requests have been approved');

        Test.stopTest();
    }

    private static Map<Integer, ApprovalRequest__c> retrieveApprovalRequestsByPosition() {
        Map<Integer, ApprovalRequest__c> requests = new Map<Integer, ApprovalRequest__c>();
        for (ApprovalRequest__c request : [SELECT Id, Status__c, Position__c, Resolution__c, Quote__r.SBQQ__Status__c, Quote__c FROM ApprovalRequest__c]) {
            requests.put((Integer) request.Position__c, request);
        }
        return requests;
    }

    @isTest
    public static void testQuoteRejection() {
        Map<Integer, ApprovalRequest__c> requests = retrieveApprovalRequestsByPosition();
        ApprovalRequest__c request;

        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(null).Status__c, 'It should be set as pending since it is the default value');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(1).Status__c, 'It should be set as pending since it is the default value');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(2).Status__c, 'It should be set as pending since it is the default value');
        System.assertEquals(ApprovalRequestConstants.STATUS_REVIEWING, requests.get(3).Status__c, 'Set in test setup');

        Test.startTest();

        request = requests.get(3);
        request.Resolution__c = ApprovalRequestConstants.RESOLUTION_REJECTED;
        update request;
        
        requests = retrieveApprovalRequestsByPosition();
        System.assertEquals(ApprovalRequestConstants.STATUS_DISMISSED, requests.get(null).Status__c, 'First null values are evaluated');
        System.assertEquals(ApprovalRequestConstants.STATUS_DISMISSED, requests.get(1).Status__c, 'It is not its turn yet');
        System.assertEquals(ApprovalRequestConstants.STATUS_DISMISSED, requests.get(2).Status__c, 'It is not its turn yet');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(3).Status__c, 'The request has been fulfilled');
        System.assertEquals(CPQ_QuoteConstants.STATUS_REJECTED, requests.get(3).Quote__r.SBQQ__Status__c, 'The quote still has pending requests to be reviewed');

        Test.stopTest();
    }

    @isTest
    public static void testClaimQuoteForEdition() {
        Map<Integer, ApprovalRequest__c> requests = retrieveApprovalRequestsByPosition();
        ApprovalRequest__c request;

        Test.startTest();

        request = requests.get(3);
        request.Resolution__c = ApprovalRequestConstants.RESOLUTION_APPROVED;
        update request;
        
        requests = retrieveApprovalRequestsByPosition();
        System.assertEquals(ApprovalRequestConstants.STATUS_REVIEWING, requests.get(null).Status__c, 'First null values are evaluated');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(1).Status__c, 'It is not its turn yet');
        System.assertEquals(ApprovalRequestConstants.STATUS_PENDING, requests.get(2).Status__c, 'It is not its turn yet');
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(3).Status__c, 'The request has been fulfilled');
        System.assertEquals(CPQ_QuoteConstants.STATUS_PENDING_APPROVAL, requests.get(3).Quote__r.SBQQ__Status__c, 'The quote still has pending requests to be reviewed');

        ApprovalRequestService.unlockQuoteForEdition(request.Quote__c);
        requests = retrieveApprovalRequestsByPosition();
        System.assertEquals(ApprovalRequestConstants.STATUS_COMPLETED, requests.get(3).Status__c, 'The request has been fulfilled');
        System.assertEquals(CPQ_QuoteConstants.STATUS_DRAFT, requests.get(3).Quote__r.SBQQ__Status__c, 'The quote has returned to draft');

        System.assertEquals(requests.size(), 1, 'Only completed requests should remain');

        Test.stopTest();

    }

}