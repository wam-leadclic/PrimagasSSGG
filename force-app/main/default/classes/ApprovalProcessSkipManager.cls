public with sharing class ApprovalProcessSkipManager {

    private static final Integer DEFAULT_POSITION = 1;

    @InvocableMethod(label='Skip Approval Process' description='Automatically approves the quote and deletes pending approval requests if any')
    public static void skipApprovalProcess(List<Id> quoteIds) {
        for (Id quoteId : quoteIds) {
            System.Approval.unlock(quoteId);
            delete ApprovalRequestRepository.getPendingResolutionRequests(new Set<Id> {quoteId});
            SBQQ__Quote__c quote = CPQ_QuoteRepository.getQuoteById(quoteId);
            insert new ApprovalRequest__c(
                Approver__c = UserInfo.getUserId(),
                Quote__c = quote.Id,
                PBA__c = quote.PBA__c,
                GasPriceRange__c = quote.GasPriceRange__c,
                Credit__c = quote.Credit__c,
                Investment__c = quote.Investment__c,
                NonRecoveryInvestment__c = quote.NonRecoveryInvestment__c,
                Position__c = DEFAULT_POSITION,
                Resolution__c = ApprovalRequestConstants.RESOLUTION_APPROVED
            );
        }
    }
}