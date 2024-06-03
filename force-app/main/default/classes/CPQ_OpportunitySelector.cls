public without sharing class CPQ_OpportunitySelector {
    
    public static List<Opportunity> selectByIds(Set<Id> oppId){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_OpportunitySelector] selectByIds');
        return [SELECT Id, Dimension3__c FROM Opportunity WHERE Id IN: oppId];
    }
}