public with sharing class CPQ_StretchSelector {
    
    public static List<Stretch__c> selectByQuotesId(Set<Id> quotesId){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_StretchSelector] selectByQuotesId');
        return [SELECT  Id,
                        Name,
                        Quote__c,
                        FromPercentage__c,
                        FromConsumptionKG__c,
                        DiscountL__c,
                        DiscountKG__c,
                        PriceTodayL__c,
                        PriceTodayKG__c,
                        PrimaServiciosA__c,
                        PBA__c,
                        CLV5__c,
                        CLV10__c
                FROM Stretch__c
                WHERE Quote__c =: quotesId
                ORDER BY FromPercentage__c DESC];
    }
}