public without sharing class ApprovalProcessOrchestrator {

    @InvocableMethod(label='Submit Quotes for Approval' description='Create Approval Request records and locks the Quote for edit.')
    public static void submitQuoteToApproval(List<Id> quoteIds) {
        for (Id quoteId : quoteIds) {
            ApprovalProcessOrchestrator orchestrator = new ApprovalProcessOrchestrator(quoteId);
            orchestrator.submitToApproval();
        }
    }

    private static Map<Id, User> delegatedApprovers {	
        get {	
            if (delegatedApprovers == null) {	
                Map<Id, User> approvers;	
                Map<Id, Id> delegatedApproverIds = new Map<Id, Id>();	
                for (User user : UserRepository.getUsersWithDelegatedApprovers()) {	
                    delegatedApproverIds.put(user.Id, user.DelegatedApproverId);	
                }	
                approvers = new Map<Id, User>(UserRepository.getUsersByIds(delegatedApproverIds.values()));	
                delegatedApprovers = new Map<Id, User>();	
                for (Id userId : delegatedApproverIds.keySet()) {	
                    delegatedApprovers.put(userId, approvers.get(delegatedApproverIds.get(userId)));	
                }	
            }	
            return delegatedApprovers;	
        }	
        set;	
    }

    private SBQQ__Quote__c quote;
    private Map<Id, ApprovalRequest__c> approvalRequests;
    private List<SortableApprovalRequest> sortableRequests;

    public ApprovalProcessOrchestrator(Id quoteId) {
        this.quote = this.getQuoteById(quoteId);
        this.approvalRequests = new Map<Id, ApprovalRequest__c>();
        this.sortableRequests = new List<SortableApprovalRequest>();
    }

    private SBQQ__Quote__c getQuoteById(Id quoteId) {
        return ((List<SBQQ__Quote__c>) Database.query(buildQuoteQuery(quoteId)))[0];
    }

    private String buildQuoteQuery(Id quoteId) {
        String query = 'SELECT Id, OwnerId, Owner.UserRoleId, Owner.UserRole.ParentRoleId';
        Set<String> requestedFields = new Set<String>();
        for (ApprovalMetric__mdt metric : ApprovalMetricRepository.getActiveApprovalMetrics()) {
            if (String.isNotBlank(metric.QuoteField__c) && requestedFields.add(metric.QuoteField__c)) {
                query += ', ' + metric.QuoteField__c;
            }
            if (String.isNotBlank(metric.RelativeValueField__c) && requestedFields.add(metric.RelativeValueField__c)) {
                query += ', ' + metric.RelativeValueField__c;
            }
            if (String.isNotBlank(metric.SkipApprovalField__c) && requestedFields.add(metric.SkipApprovalField__c)) {
                query += ', ' + metric.SkipApprovalField__c;
            }
        }
        query += ' FROM SBQQ__Quote__c WHERE Id = \'' + quoteId + '\'';
        return query;
    }

    public void submitToApproval() {
        generateApprovalRequests();
        if (!this.approvalRequests.isEmpty()) {
            sortApprovalRequests();
            setApprovalRequestsInitialStatus();
            insertApprovalRequests();
            if (hasPendingRequests()) {
                lockQuote();
            } else {
                approveQuote();
            }
        } else {
            approveQuote();
        }
    }

    private void generateApprovalRequests() {
        Decimal quoteMetricValue;
        for (ApprovalMetric__mdt metric : ApprovalMetricRepository.getActiveApprovalMetrics()) {
            if (!quoteHasValidMetrics(metric) || mustBeSkipped(metric)) {
                continue;
            }
            quoteMetricValue = formatQuoteMetricValue(metric);
            for (ApprovalMetricStretch__mdt stretch : metric.Stretches__r) {
                if (stretch.MinValue__c <= quoteMetricValue && quoteMetricValue < stretch.MaxValue__c) {
                    generateApprovalRequest(metric, stretch);
                }
            }
        }
    }

    private Boolean quoteHasValidMetrics(ApprovalMetric__mdt metric) {
        return this.quote.get(metric.QuoteField__c) != null && (metric.StretchType__c != ApprovalMetricConstants.STRETCH_TYPE_RELATIVE 
                || this.quote.get(metric.RelativeValueField__c) != null);
    }

    private Boolean mustBeSkipped(ApprovalMetric__mdt metric) {
        return String.isNotBlank(metric.SkipApprovalField__c) && ((Boolean) this.quote.get(metric.SkipApprovalField__c) == true);
    }

    private Decimal formatQuoteMetricValue(ApprovalMetric__mdt metric) {
        if (metric.StretchType__c == ApprovalMetricConstants.STRETCH_TYPE_ABSOLUTE) {
            return (Decimal) this.quote.get(metric.QuoteField__c);
        } else if (metric.StretchType__c == ApprovalMetricConstants.STRETCH_TYPE_RELATIVE) {
            return (Decimal) this.quote.get(metric.QuoteField__c) / (Decimal) this.quote.get(metric.RelativeValueField__c) * 100;
        }
        return null;
    }

    private void generateApprovalRequest(ApprovalMetric__mdt metric, ApprovalMetricStretch__mdt stretch) {
        User approver = getApprover(stretch);
        if (approver == null) {
            return;
        }
        if (!this.approvalRequests.containsKey(approver.Id)) {
            this.approvalRequests.put(approver.Id, new ApprovalRequest__c(
                Approver__c = approver.Id,
                Quote__c = quote.Id,
                PBA__c = quote.PBA__c,
                GasPriceRange__c = quote.GasPriceRange__c,
                Credit__c = quote.Credit__c,
                Investment__c = quote.Investment__c,
                NonRecoveryInvestment__c = quote.NonRecoveryInvestment__c,
                Position__c = getUserRoleDepth(approver.UserRoleId)
            ));
        }
        if (String.isNotBlank(metric.ControllerField__c)) {
            this.approvalRequests.get(approver.Id).put(metric.ControllerField__c, true);
        }
    }

    private Integer getUserRoleDepth(Id userRoleId) {
        Integer depth = UserRoleService.getUserRoleDepth(userRoleId)?.depth;
        return depth;
    }

    private User getApprover(ApprovalMetricStretch__mdt stretch) {
        User approver;
        if (stretch.Approver__c == ApprovalMetricConstants.APPROVER_TYPE_SELF) {
            approver = new User (	
                Id = this.quote.OwnerId,	
                UserRoleId = this.quote.Owner.UserRoleId	
            );	
        } else if (stretch.Approver__c == ApprovalMetricConstants.APPROVER_TYPE_MANAGER) {
            approver = UserRoleService.getSampleUserByUserRoleId(this.quote.Owner.UserRole.ParentRoleId);
        } else if (stretch.Approver__c == ApprovalMetricConstants.APPROVER_TYPE_USERROLE) {
            if (UserRoleService.userRolesByDeveloperName.containsKey(stretch.ApprovalRoleName__c)) {
                approver = UserRoleService.getSampleUserByUserRoleId(
                    UserRoleService.userRolesByDeveloperName.get(stretch.ApprovalRoleName__c).Id
                );    
            }
        }
        if (approver != null && delegatedApprovers.containsKey(approver.Id)) {	
            approver = delegatedApprovers.get(approver.Id);	
        }	
        return approver;	
    }

    private void sortApprovalRequests() {
        Integer orderedPosition = 1;
        for (ApprovalRequest__c request: this.approvalRequests.values()) {
            sortableRequests.add(new SortableApprovalRequest(request));
        }
        sortableRequests.sort();
        for (SortableApprovalRequest sortableRequest : sortableRequests) {
            sortableRequest.request.Position__c = orderedPosition++;
        }
    }

    private void setApprovalRequestsInitialStatus() {
        for (SortableApprovalRequest sortableRequest: sortableRequests) {
            if (sortableRequest.request.Approver__c ==  UserInfo.getUserId()) {
                sortableRequest.request.Resolution__c = ApprovalRequestConstants.RESOLUTION_APPROVED;
            } else {
                sortableRequest.request.Status__c = ApprovalRequestConstants.STATUS_REVIEWING;
            }
            break;
        }
    }

    private void insertApprovalRequests() {
        insert this.approvalRequests.values();
    }

    private Boolean hasPendingRequests() {
        for (ApprovalRequest__c request : this.approvalRequests.values()) {
            if (request.Resolution__c != ApprovalRequestConstants.RESOLUTION_APPROVED) {
                return true;
            }
        }
        return false;
    }

    private void lockQuote() {
        this.quote.SBQQ__Status__c = CPQ_QuoteConstants.STATUS_PENDING_APPROVAL;
        update this.quote;
        System.Approval.lock(this.quote.Id);
    }

    private void approveQuote() {
        this.quote.SBQQ__Status__c = CPQ_QuoteConstants.STATUS_APPROVED;
        update this.quote;
    }

    public class SortableApprovalRequest implements Comparable {

        private ApprovalRequest__c request;
        
        public SortableApprovalRequest(ApprovalRequest__c request) {
            this.request = request;
        }

        public Integer compareTo(Object compareTo) {
            SortableApprovalRequest requestToCompare = (SortableApprovalRequest) compareTo;
            if (this.request.Approver__c == UserInfo.getUserId()) {
                if (requestToCompare.request.Approver__c == this.request.Approver__c) {
                    return 0;
                }
                return -1;
            }
            if (requestToCompare.request.Approver__c == UserInfo.getUserId()) {
                return 1;
            }
            if (this.request.Position__c == requestToCompare.request.Position__c) {
                return 0;
            }
            if (this.request.Position__c == null || this.request.Position__c > requestToCompare.request.Position__c) {
                return -1;
            } 
            return 1;
        }        
    }
}