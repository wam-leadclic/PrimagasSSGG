public with sharing class CPQ_QuoteLineService {
    
    public static Set<Id> extractQuoteIdFromQuoteLines(List<SBQQ__QuoteLine__c> quoteLines){
        Set<Id> output = new Set<Id>();

        for(SBQQ__QuoteLine__c quoteLine : quoteLines){
            output.add(quoteLine.SBQQ__Quote__c);
        }
        
        return output;
    }

    public static List<SBQQ__QuoteLine__c> filterQLIsWithNoTankName(List<SBQQ__QuoteLine__c> qlis) {
        List<SBQQ__QuoteLine__c> output = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c qli : qlis) {
            if (string.isBlank(qli.TankName__c)) {
                output.add(qli);
            }
        }
        return output;
    }
    
    public static List<SBQQ__QuoteLine__c> filterQLIsWithTankName(List<SBQQ__QuoteLine__c> qlis) {
        List<SBQQ__QuoteLine__c> output = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c qli : qlis) {
            if (string.isNotBlank(qli.TankName__c)) {
                output.add(qli);
            }
        }
        return output;
    }

    public static List<SBQQ__QuoteLine__c> filterQLIsWithIndoorEquipment(List<SBQQ__QuoteLine__c> qlis) {
        Set<String> indoorProductCodes = new Set<String>();
        List<SBQQ__QuoteLine__c> output = new List<SBQQ__QuoteLine__c>();
        for (EquipmentMasterData__c indoorEq: CPQ_EquipmentMasterDataSelector.selectByIsIndoor(true)){
            indoorProductCodes.add(indoorEq.SBQQProductCode__c);
        }
        for (SBQQ__QuoteLine__c qli : qlis) {
            if (indoorProductCodes.contains(qli.SBQQ__ProductCode__c)) {
                output.add(qli);
            }
        }
        return output;
    }

    public static List<String> getProductCodesForLines(List<SBQQ__QuoteLine__c> qlis){
        List<String> output = new List<String>();

        for (SBQQ__QuoteLine__c qli : qlis) {
            output.add(qli.SBQQ__ProductCode__c);
        }
        return output;
    }
}