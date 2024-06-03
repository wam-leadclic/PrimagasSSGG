public with sharing class CPQ_GasCost {

    public static GasCostsByCounty getGasCostsForQuotes(CPQ_Quote.QuoteWrapper quoteWrapper){
        return getGasCostsForQuotes(new List<CPQ_Quote.QuoteWrapper>{quoteWrapper});
    }

    public static GasCostsByCounty getGasCostsForQuotes(List<CPQ_Quote.QuoteWrapper> quoteWrappers){
        // 1.- Find gas cost records related to the quotes:
        Set<String> provinces = new Set<String>();
        for(CPQ_Quote.QuoteWrapper q : quoteWrappers){
            provinces.add(q.Quote.County__c);
        }

        return new GasCostsByCounty(CPQ_GasCostSelector.selectByProvinces(provinces));
    }

    public class GasCostsByCounty {
        private Map<String, GasCost__c> gasCostByCounty = new Map<String, GasCost__c>();

        public GasCostsByCounty(List<GasCost__c> gasCosts){
            for(GasCost__c c : gasCosts){
                gasCostByCounty.put(c.County__c, c);
            }
        }

        public GasCost__c getForCounty(String county){
            if(gasCostByCounty.containsKey(county)){
                return gasCostByCounty.get(county);
            }
            System.debug(LoggingLevel.ERROR, 'GasCostForCountyNotFound');
            //throw new GasCostForCountyNotFoundException(county);
            return null;
        }

    }

    public class GasCostForCountyNotFoundException extends Exception {
        
    }
}