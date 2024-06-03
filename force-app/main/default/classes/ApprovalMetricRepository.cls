public without sharing class ApprovalMetricRepository {

    private static List<ApprovalMetric__mdt> activeApprovalMetrics {
        get {
            if (activeApprovalMetrics == null) {
                activeApprovalMetrics = [
                    SELECT
                        IsActive__c,
                        ControllerField__c,
                        QuoteField__c,
                        StretchType__c,
                        RelativeValueField__c,
                        SkipApprovalField__c,
                        (
                            SELECT
                                ApprovalRoleName__c,
                                ApprovalMetric__c,
                                Approver__c,
                                MaxValue__c,
                                MinValue__c
                            FROM
                                Stretches__r
                        )
                    FROM
                        ApprovalMetric__mdt
                    WHERE
                        IsActive__c = true
                ];
            }
            return activeApprovalMetrics;
        }
        set;
    }

    public static List<ApprovalMetric__mdt> getActiveApprovalMetrics() {
        return activeApprovalMetrics;
    }
}