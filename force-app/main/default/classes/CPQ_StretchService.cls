public without sharing class CPQ_StretchService {
 /*
    public static List<Stretch__c> insertDefaultStretchesForQuote(Id quoteId){
        System.debug('[CPQ_StretchService] insertDefaultStretchesForQuote '+quoteId);
        CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesWithQuoteLineItems(
                                                CPQ_QuoteSelector.selectByIdWithQuoteLineItems(new Set<Id>{quoteId}))[0];

        List<Stretch__c> defaultStretches = buildDefaultStretchesForQuote(quoteWrapper, CPQ_TablesDataWrapper.generate(quoteWrapper));
        insert defaultStretches;

        return defaultStretches;
    }*/
    
    public static void deleteStretchesForQuote(Id quoteId){
        delete [SELECT Id FROM Stretch__c WHERE Quote__c =: quoteId];
    }

    public static Map<Id, List<Stretch__c>> getStretchesByQuoteId(Set<Id> quotesId){
        Map<Id, List<Stretch__c>> output = new Map<Id, List<Stretch__c>>();

        for(Stretch__c stretch : CPQ_StretchSelector.selectByQuotesId(quotesId)){
            if(!output.containsKey(stretch.Quote__c)){
                output.put(stretch.Quote__c, new List<Stretch__c>());
            }
            output.get(stretch.Quote__c).add(stretch);
        }
        return output;
    }
    
    public static Stretch__c buildNewStretch(Decimal fromPerc, CPQ_Quote.QuoteWrapper quoteWrapper){
        return new Stretch__c(Quote__c = quoteWrapper.Quote.Id,
                              FromPercentage__c = fromPerc,
                              PriceTodayKG__c = quoteWrapper.PriceTodayKG,
                              FromConsumptionKG__c = quoteWrapper.EstimatedConsumption,
                              DiscountKG__c = quoteWrapper.DiscountEuroKG,
                              PrimaServiciosA__c = quoteWrapper.Primaservicios);
    }

    public static List<Stretch__c> buildDefaultStretchesForQuote(CPQ_Quote.QuoteWrapper quoteWrapper,
                                                                CPQ_TablesDataWrapper tablesData){

        Decimal discount = CPQ_AggregateUtil.convertToZeroIfNull(quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DESCTARIFA)?.SBQQ__NetPrice__c);
        Decimal primaservicios = quoteWrapper.Primaservicios;

        List<Stretch__c> tramos = new List<Stretch__c>{
            buildNewStretch(120, quoteWrapper),
            buildNewStretch(80, quoteWrapper),
            buildNewStretch(50, quoteWrapper)
        }; 

        for(Stretch__c t : tramos){
            CPQ_Stretch.fillComputedValues(t, quoteWrapper, tablesData, true);
            //CPQ_Stretch.fillSuggestedDiscount(t, quoteWrapper, tablesData);
            CPQ_Stretch.fillMetrics(t, quoteWrapper, tablesData);
        }

        return tramos;
    }

/*
    public static void RefreshStretchFields(StretchWrapper stretch){
        stretch.PBA = CPQ_PBAService.calculate();
        stretch.CLV5 = ((Decimal)Math.round(Math.random() * 1000000))/100;
        stretch.CLV10 = ((Decimal)Math.round(Math.random() * 1000000))/100;
    }*/

}