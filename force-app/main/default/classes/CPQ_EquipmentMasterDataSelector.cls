public without sharing class CPQ_EquipmentMasterDataSelector {
    public static List<EquipmentMasterData__c> selectByIsIndoor(Boolean isIndoor) {
        return [
            SELECT SBQQProductCode__c
            FROM EquipmentMasterData__c
            WHERE IsIndoor__c = :isIndoor
        ];
    }

    public static List<EquipmentMasterData__c> selectByProductCodes(Set<String> productCodes) {
        return [
            SELECT SBQQProductCode__c, IsRecoverable__c, IsIndoor__c
            FROM EquipmentMasterData__c
            WHERE SBQQProductCode__c IN :productCodes
        ];
    }
}