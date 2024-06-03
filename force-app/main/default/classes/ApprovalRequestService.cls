public class ApprovalRequestService {

    private static final Map<String, String> TIMESTAMPS = new Map<String, String> {
        ApprovalRequestConstants.STATUS_REVIEWING => 'TimestampReviewing__c',
        ApprovalRequestConstants.STATUS_COMPLETED => 'TimestampCompleted__c'
    };

    public static void setTimestamps(ApprovalRequest__c request) {
        if (TIMESTAMPS.containsKey(request.Status__c)) {
            request.put(TIMESTAMPS.get(request.Status__c), System.now());
        }
    }

    public static void setTimestamps(ApprovalRequest__c newRequest, ApprovalRequest__c oldRequest) {
        if (newRequest.Status__c != oldRequest.Status__c) {
            setTimestamps(newRequest);
        }
    }

    public static void unlockQuoteForEdition(Id quoteId) {
        System.Approval.unlock(quoteId);
        update new SBQQ__Quote__c(
            Id = quoteId,
            SBQQ__Status__c = CPQ_QuoteConstants.STATUS_DRAFT
        );
        delete ApprovalRequestRepository.getPendingResolutionRequests(new Set<Id> {quoteId});
    }
}