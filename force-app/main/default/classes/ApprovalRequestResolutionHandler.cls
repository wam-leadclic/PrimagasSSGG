public class ApprovalRequestResolutionHandler {

    private Map<Id, SBQQ__Quote__c> relatedQuotes;
    private List<ApprovalRequest__c> completedRequests;
    private Map<Id, SBQQ__Quote__c> quotesToUpdate;
    private Map<Id, ApprovalRequest__c> requestsToUpdate;

    public ApprovalRequestResolutionHandler() {
        this.relatedQuotes = new Map<Id, SBQQ__Quote__c>();
        this.completedRequests = new List<ApprovalRequest__c>();
        this.requestsToUpdate = new Map<Id, ApprovalRequest__c>();
        this.quotesToUpdate = new Map<Id, SBQQ__Quote__c>();
    }

    public void setCompletedApprovalRequestsStatus(ApprovalRequest__c approvalRequest) {
        if (hasBeenCompleted(approvalRequest)) {
            approvalRequest.Status__c = ApprovalRequestConstants.STATUS_COMPLETED;
        }
    }
    
    private Boolean hasBeenCompleted(ApprovalRequest__c approvalRequest) {
        return approvalRequest.Resolution__c == ApprovalRequestConstants.RESOLUTION_APPROVED || 
                approvalRequest.Resolution__c == ApprovalRequestConstants.RESOLUTION_REJECTED;
    }

    public void processResolutionChanges(ApprovalRequest__c newApproval, ApprovalRequest__c oldApproval) {
        if (oldApproval.Resolution__c != newApproval.Resolution__c) {
            processResolution(newApproval);
        }
    }

    public void processResolution(ApprovalRequest__c approvalRequest) {
        if (hasBeenCompleted(approvalRequest)) {
            this.relatedQuotes.put(approvalRequest.Quote__c, null);
            this.completedRequests.add(approvalRequest);
        }
    }

    public void completeApprovalRequests() {
        this.relatedQuotes = new Map<Id, SBQQ__Quote__c>(ApprovalRequestRepository.getQuotesWithStatusPendingRequests(this.relatedQuotes.keySet()));
        for (ApprovalRequest__c request : completedRequests) {
            if (request.Resolution__c == ApprovalRequestConstants.RESOLUTION_APPROVED) {
                approveApprovalRequest(request);
            } else if (request.Resolution__c == ApprovalRequestConstants.RESOLUTION_REJECTED) {
                rejectApprovalRequest(request);
            }
        }
        update quotesToUpdate.values();
        update requestsToUpdate.values();
    }

    private void approveApprovalRequest(ApprovalRequest__c approvalRequest) {
        SBQQ__Quote__c relatedQuote = relatedQuotes.get(approvalRequest.Quote__c);
        if (relatedQuote.ApprovalRequests__r.isEmpty()) {
            relatedQuote.SBQQ__Status__c = CPQ_QuoteConstants.STATUS_APPROVED;
            this.quotesToUpdate.put(relatedQuote.Id, relatedQuote);
        } else {
            ApprovalRequest__c nextRequestToApprove = relatedQuote.ApprovalRequests__r[0];
            nextRequestToApprove.Status__c = ApprovalRequestConstants.STATUS_REVIEWING;
            this.requestsToUpdate.put(nextRequestToApprove.Id, nextRequestToApprove);
        }
    }

    private void rejectApprovalRequest(ApprovalRequest__c approvalRequest) {
        SBQQ__Quote__c relatedQuote = relatedQuotes.get(approvalRequest.Quote__c);
        relatedQuote.SBQQ__Status__c = CPQ_QuoteConstants.STATUS_REJECTED;
        this.quotesToUpdate.put(relatedQuote.Id, relatedQuote);
        for (ApprovalRequest__c request : relatedQuote.ApprovalRequests__r) {
            request.Status__c = ApprovalRequestConstants.STATUS_DISMISSED;
            this.requestsToUpdate.put(request.Id, request);
        }
    }
}