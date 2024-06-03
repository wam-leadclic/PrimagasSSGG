public inherited sharing class GasPriceRangeService {

    public static Map<String, GasPriceRange__c> getProvincePriceRanges(Set<String> selectedProvinces) {
        Map<String, GasPriceRange__c> gasPriceRangesByProvince = new Map<String, GasPriceRange__c>();
        for (GasPriceRange__c range : getGasPriceRangesByProvince(selectedProvinces)) {
            gasPriceRangesByProvince.put(range.County__c, range);
        }
        return gasPriceRangesByProvince;
    }

    private static List<GasPriceRange__c> getGasPriceRangesByProvince(Set<String> selectedProvinces) {
        return [
            SELECT
                Id, 
                County__c, 
                Range__c
            FROM
                GasPriceRange__c
            WHERE
                County__c IN :selectedProvinces
        ];
    }
}