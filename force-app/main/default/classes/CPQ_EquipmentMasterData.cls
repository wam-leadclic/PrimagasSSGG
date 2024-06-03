public without sharing class CPQ_EquipmentMasterData {
    
    public static EquipmentMasterData getForQuoteWrappers(CPQ_Quote.QuoteWrapper quoteWrapper){
        return getForQuoteWrappers(new List<CPQ_Quote.QuoteWrapper>{quoteWrapper});
    }

    public static EquipmentMasterData getForQuoteWrappers(List<CPQ_Quote.QuoteWrapper> quoteWrappers){
        Set<String> productCodes = new Set<String>();

        for(CPQ_Quote.QuoteWrapper w : quoteWrappers){
            for(SBQQ__QuoteLine__c l : w.Lines){
                if(String.isNotBlank(l.SBQQ__ProductCode__c))
                    productCodes.add(l.SBQQ__ProductCode__c);
            }
        }
        return new EquipmentMasterData(CPQ_EquipmentMasterDataSelector.selectByProductCodes(productCodes));
    }

    public class EquipmentMasterData {
        private Map<String, EquipmentMasterData__c> emdByProductCode = new Map<String, EquipmentMasterData__c>();

        public EquipmentMasterData(List<EquipmentMasterData__c> tmds){
            for(EquipmentMasterData__c e : tmds){
                emdByProductCode.put(e.SBQQProductCode__c, e);
            }
        }

        public Set<String> filterProductCodesRecoverable(Set<String> productCodesToFilter){
            Set<String> output = new Set<String>();

            if(productCodesToFilter != null && productCodesToFilter.size() > 0){
                for(String code : productCodesToFilter){
                    if(emdByProductCode.containsKey(code) && emdByProductCode.get(code).IsRecoverable__c){
                        output.add(code);
                    }
                }
            }
            return output;
        }
        
        public List<String> filterProductCodesByIsIndoor(Boolean isIndoor, Set<String> productCodesToFilter){
            List<String> output = new List<String>();

            if(productCodesToFilter != null && productCodesToFilter.size() > 0){
                for(String code : productCodesToFilter){
                    if(emdByProductCode.containsKey(code) && emdByProductCode.get(code).IsIndoor__c == isIndoor){
                        output.add(code);
                    }
                }
            }
            return output;
        }

    }
}