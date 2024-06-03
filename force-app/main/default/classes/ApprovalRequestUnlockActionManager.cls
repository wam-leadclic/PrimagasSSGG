public without sharing class ApprovalRequestUnlockActionManager {
    
    @InvocableMethod(label='Unlock Quote for edition' description='Returns the quote to status draft and stops any current approval process')
    public static void unlockQuoteForEdition(List<Id> quoteIds) {
        for (Id quoteId : quoteIds) {
            ApprovalRequestService.unlockQuoteForEdition(quoteId);
        }
    }
}