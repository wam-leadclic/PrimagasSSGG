public with sharing class CPQ_GasCostSelector {
    
    public static List<GasCost__c> selectByProvinces(Set<String> provinces){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_GasCostSelector] selectByProvinces');
        
        return [SELECT  Id,
                        County__c,
                        Cost__c,
                        TransportationCost__c
                FROM GasCost__c
                WHERE County__c IN :provinces];
    }
}