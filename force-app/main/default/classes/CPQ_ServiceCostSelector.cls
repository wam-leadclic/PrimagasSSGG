public with sharing class CPQ_ServiceCostSelector {
    
    public static List<ServiceCost__c> selectByProvinces(Set<String> provinces){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_ServiceCostSelector] selectByProvinces');
        return [SELECT  Id,
                        DomesticCost__c,
                        ProfessionalCost__c,
                        County__c,
                        Service__c
                FROM ServiceCost__c
                WHERE County__c IN :provinces];
    }
}