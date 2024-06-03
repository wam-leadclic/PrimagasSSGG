public class ApprovalRequestHandler implements ITrigger {

    private ApprovalRequestResolutionHandler resolutionHandler;

    public ApprovalRequestHandler() {
        resolutionHandler = new ApprovalRequestResolutionHandler();
    }
 
    public void bulkBefore(List<SObject> newList,  Map<Id, SObject> oldMap) {
    }
    
    public void bulkAfter(List<SObject> newList,  Map<Id, SObject> oldMap) {
    }
    
    public void beforeInsert(List<SObject> newList) {
        for (ApprovalRequest__c approvalRequest : (List<ApprovalRequest__c>) newList) {
            resolutionHandler.setCompletedApprovalRequestsStatus(approvalRequest);
            ApprovalRequestService.setTimestamps(approvalRequest);
        }
    }
    
    public void beforeUpdate(List<SObject> newList,  Map<Id, SObject> oldMap) {
        for (ApprovalRequest__c approvalRequest : (List<ApprovalRequest__c>) newList) {
            resolutionHandler.setCompletedApprovalRequestsStatus(approvalRequest);
            ApprovalRequestService.setTimestamps(approvalRequest, (ApprovalRequest__c) oldMap.get(approvalRequest.Id));
        }
    }
    
    public void beforeDelete(Map<Id, SObject> oldMap) {
    }

    public void afterInsert(List<SObject> newList) {
        for (ApprovalRequest__c approvalRequest : (List<ApprovalRequest__c>) newList) {
            resolutionHandler.processResolution(approvalRequest);
        }
        resolutionHandler.completeApprovalRequests();
    }
     
    public void afterUpdate(List<SObject> newList,  Map<Id, SObject> oldMap) {
        for (ApprovalRequest__c approvalRequest : (List<ApprovalRequest__c>) newList) {
            resolutionHandler.processResolutionChanges(approvalRequest, (ApprovalRequest__c) oldMap.get(approvalRequest.Id));
        }
        resolutionHandler.completeApprovalRequests();
    }
     
    public void afterDelete(Map<Id, SObject> oldMap) {
    }
     
    public void andFinally() {
    }
}