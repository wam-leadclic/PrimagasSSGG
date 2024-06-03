public with sharing class CPQ_ServiceCost {

    public static ServiceCostsByCounty getserviceCostsForQuotes(CPQ_Quote.QuoteWrapper quoteWrapper){
        return getserviceCostsForQuotes(new List<CPQ_Quote.QuoteWrapper>{quoteWrapper});
    }

    public static ServiceCostsByCounty getserviceCostsForQuotes(List<CPQ_Quote.QuoteWrapper> quoteWrappers){
        // 1.- Find service cost records related to the quotes:
        Set<String> provinces = new Set<String>();
        for(CPQ_Quote.QuoteWrapper q : quoteWrappers){
            provinces.add(q.Quote.County__c);
        }

        return new ServiceCostsByCounty(CPQ_ServiceCostSelector.selectByProvinces(provinces));
    }

    public class ServiceCostsByCounty {
        private Map<String, Map<Id, ServiceCost__c>> serviceCostByCountyAndProductId = new Map<String, Map<Id, ServiceCost__c>>();

        public ServiceCostsByCounty(List<ServiceCost__c> serviceCosts){
            for(ServiceCost__c c : serviceCosts){
                if(!serviceCostByCountyAndProductId.containsKey(c.County__c))
                    serviceCostByCountyAndProductId.put(c.County__c, new Map<Id, ServiceCost__c>());

                serviceCostByCountyAndProductId.get(c.County__c).put(c.Service__c, c);
            }
        }

        public List<ServiceCost__c> getForCountyAndProducts(String county, Set<Id> productsId){
            List<ServiceCost__c> output = new List<ServiceCost__c>();

            for(Id productId : productsId){
                if(serviceCostByCountyAndProductId.containsKey(county) && serviceCostByCountyAndProductId.get(county).containsKey(productId)){
                    output.add(serviceCostByCountyAndProductId.get(county).get(productId));
                }
            }
            return output;
        }

    }

    public class ServiceCostForCountyNotFoundException extends Exception {
        
    }
}