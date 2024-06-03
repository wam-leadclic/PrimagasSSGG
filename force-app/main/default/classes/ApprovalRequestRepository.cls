public without sharing class ApprovalRequestRepository {

    public static final String RESOLUTION_PENDING = 'Pending';
    public static final String RESOLUTION_APPROVED = 'Approved';
    public static final String RESOLUTION_REJECTED = 'Rejected';

    public static List<SBQQ__Quote__c> getQuotesWithStatusPendingRequests(Set<Id> quoteIds) {
        return [
            SELECT
                Id,
                SBQQ__Status__c,
                (
                    SELECT
                        Id,
                        Resolution__c,
                        Status__c,
                        Position__c
                    FROM
                        ApprovalRequests__r
                    WHERE
                        Status__c = :ApprovalRequestConstants.STATUS_PENDING
                    ORDER BY
                        Position__c ASC NULLS FIRST
                )
            FROM
                SBQQ__Quote__c
            WHERE
                Id IN :quoteIds
        ];
    }

    public static List<ApprovalRequest__c> getPendingResolutionRequests(Set<Id> quoteIds) {
        return [
            SELECT
                Id
            FROM
                ApprovalRequest__c
            WHERE
                Quote__c IN :quoteIds
            AND
                Resolution__c = :ApprovalRequestConstants.RESOLUTION_PENDING
        ];
    }
}