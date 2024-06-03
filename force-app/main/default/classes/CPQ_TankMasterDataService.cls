public with sharing class CPQ_TankMasterDataService {
    
    
    public static List<TankMasterData__c> getDataByNames(Set<String> names){
        return CPQ_TankMasterDataSelector.selectByName(names);
    }
}