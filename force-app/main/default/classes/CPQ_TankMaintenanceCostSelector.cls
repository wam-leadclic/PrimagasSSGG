public with sharing class CPQ_TankMaintenanceCostSelector {
   
    public static List<TankMaintenanceCost__c> selectByCountyAndName(Set<String> counties, Set<String> names){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_TankMaintenanceCostSelector] selectByCountyAndName');
        return [SELECT Id,
                       Cost__c,
                       County__c,
                       Tank__r.Name
                FROM TankMaintenanceCost__c
                WHERE County__c IN : counties
                  AND Tank__r.Name IN : names];
    }
}