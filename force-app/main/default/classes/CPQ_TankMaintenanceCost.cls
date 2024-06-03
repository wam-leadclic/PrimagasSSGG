public with sharing class CPQ_TankMaintenanceCost {
    
    public static TMCByCounty getTMCForQuoteWrappers(CPQ_Quote.QuoteWrapper quoteWrappers){
        return getTMCForQuoteWrappers(new List<CPQ_Quote.QuoteWrapper>{quoteWrappers});
    }

    public static TMCByCounty getTMCForQuoteWrappers(List<CPQ_Quote.QuoteWrapper> quoteWrappers){
        // 1.- Find gas cost records related to the quotes:
        Set<String> counties = new Set<String>();
        Set<String> tankNames = new Set<String>();

        for(CPQ_Quote.QuoteWrapper w : quoteWrappers){
            counties.add(w.Quote.County__c);
            for(SBQQ__QuoteLine__c l : w.getLinesByProductCode(CPQ_ProductCodes.DEPOSITO)){
                if(string.isNotBlank(l.TankName__c)){
                    tankNames.add(l.TankName__c);
                }
            }
        }

        return new TMCByCounty(CPQ_TankMaintenanceCostSelector.selectByCountyAndName(counties, tankNames));
    }

    public class TMCByCounty {
        //      Map<County, Map<Name, List<TankMaintenanceCost__c>>
        private Map<String, Map<String, List<TankMaintenanceCost__c>>> tmcByCountyAndName = new Map<String, Map<String, List<TankMaintenanceCost__c>>>();

        public TMCByCounty(List<TankMaintenanceCost__c> tmcs){
            for(TankMaintenanceCost__c t : tmcs){
                if(!tmcByCountyAndName.containsKey(t.County__c)){
                    tmcByCountyAndName.put(t.County__c, new Map<String, List<TankMaintenanceCost__c>>());
                }
                if(!tmcByCountyAndName.get(t.County__c).containsKey(t.Tank__r.Name)){
                    tmcByCountyAndName.get(t.County__c).put(t.Tank__r.Name, new List<TankMaintenanceCost__c>());
                }
                tmcByCountyAndName.get(t.County__c).get(t.Tank__r.Name).add(t);
            }
        }

        public TankMaintenanceCost__c getFirstForCountyAndTankName(String county, String name){
            if(tmcByCountyAndName.containsKey(county) && tmcByCountyAndName.get(county).containsKey(name)){
                return tmcByCountyAndName.get(county).get(name)[0];
            }
            return null;
        }

    }

}