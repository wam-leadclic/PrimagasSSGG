public without sharing class CPQ_TankMasterDataSelector {
    
    public static List<TankMasterData__c> selectByName(Set<String> names){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_TankMasterDataSelector] selectByName');
        return [SELECT  Id,
                        Name,
                        Dismantle__c,
                        EarlyTermination__c,
                        Capacity__c,
                        IsAerial__c
                FROM TankMasterData__c
                WHERE Name IN: names];
    }
}