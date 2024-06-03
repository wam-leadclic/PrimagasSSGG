public with sharing class CPQ_TankMasterData {
    
    public static TankMasterDataByName getForQuoteWrappers(CPQ_Quote.QuoteWrapper quoteWrapper){
        return getForQuoteWrappers(new List<CPQ_Quote.QuoteWrapper>{quoteWrapper});
    }

    public static TankMasterDataByName getForQuoteWrappers(List<CPQ_Quote.QuoteWrapper> quoteWrappers){
        Set<String> tankNames = new Set<String>();

        for(CPQ_Quote.QuoteWrapper w : quoteWrappers){
            String tankName = w.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.TankName__c;
            if(string.isNotBlank(tankName)){
                tankNames.add(tankName);
            }
        }
        return new TankMasterDataByName(CPQ_TankMasterDataSelector.selectByName(tankNames));
    }

    public class TankMasterDataByName {
        private Map<String, List<TankMasterData__c>> tmdByName = new Map<String, List<TankMasterData__c>>();

        public TankMasterDataByName(List<TankMasterData__c> tmds){
            for(TankMasterData__c t : tmds){
                if(!tmdByName.containsKey(t.Name)){
                    tmdByName.put(t.Name, new List<TankMasterData__c>());
                }
                tmdByName.get(t.Name).add(t);
            }
        }

        public TankMasterData__c getFirstForName(String name){
            if(tmdByName.containsKey(name)){
                return tmdByName.get(name)[0];
            }
            return null;
        }

    }

}