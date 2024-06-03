public without sharing class CPQ_Stretch {

    public static final Decimal DEFAUT_QUOTE_STRETCH_FROM_PERCENTAGE = 80;
    private static final Integer N_ATTEMPTS_FIND_PBA_DISCOUNT = CPQ_Settings.MaxSuggestedDiscountIterations;
    private static final Decimal DISCOUNT_AMOUNT_PER_ITERATION = CPQ_Settings.SuggestedDiscountIterationIncrement;
    
    public static void fillComputedValues(Stretch__c stretch,
                                          CPQ_Quote.QuoteWrapper quoteWrapper,
                                          CPQ_TablesDataWrapper tablesData,
                                          Boolean includePrimaservicios){

        // Desde (l/año) = Consumo anual (campo en quote) * Desde (%) / 100
        stretch.FromConsumptionKG__c = quoteWrapper.Quote.EstimatedConsumption__c * stretch.FromPercentage__c / 100;
        // Precio HOY €/kg = precio de la tarifa seleccionada en el quote
        stretch.PriceTodayKG__c = quoteWrapper.PriceTodayKG;

        if(includePrimaservicios){
            stretch.PrimaServiciosA__c = quoteWrapper.Primaservicios;
        }
    }

    public static void fillMetrics(Stretch__c stretch,
                                          CPQ_Quote.QuoteWrapper quoteWrapper,
                                          CPQ_TablesDataWrapper tablesData){
        
        stretch.PBA__c = CPQ_PBAService.build(quoteWrapper, stretch, tablesData, CPQ_PBAService.FULL_ESTIMATED_CONSUMPTION_COEF).calculateResult();
        stretch.CLV5__c = CPQ_CLVService.calculateResult(5, quoteWrapper, stretch, tablesData, CPQ_PBAService.FULL_ESTIMATED_CONSUMPTION_COEF);
        stretch.CLV10__c = CPQ_CLVService.calculateResult(10, quoteWrapper, stretch, tablesData, CPQ_PBAService.FULL_ESTIMATED_CONSUMPTION_COEF);
    }

    public static void fillSuggestedDiscount(Stretch__c stretch,
                                            CPQ_Quote.QuoteWrapper quoteWrapper,
                                            CPQ_TablesDataWrapper tablesData){
        
        stretch.DiscountKG__c = calculateSuggestedDiscount(stretch, quoteWrapper, tablesData);
    }

    /**
     * Finds the discount that results in a PBA value close to the 80% stretch and returns it.
     * The process is not the most performant as it iterates for a max number of
     * times or until the target value is reached, but it's the quickest to implement.
     * @param stretch 
     * @param quoteWrapper 
     * @param tablesData 
     */
    public static Decimal calculateSuggestedDiscount(Stretch__c stretch,
                                            CPQ_Quote.QuoteWrapper quoteWrapper,
                                            CPQ_TablesDataWrapper tablesData){
        
        Decimal originalDiscount = stretch.DiscountKG__c;
        Decimal REFERENCE_FROM_PERCENTAGE = 80;
                                                
        Stretch__c stretch100 = CPQ_StretchService.buildNewStretch(REFERENCE_FROM_PERCENTAGE, quoteWrapper);
        CPQ_Stretch.fillComputedValues(stretch100, quoteWrapper, tablesData, false);
        // Set the reference stretch100 PrimaserviciosA with the value in the provided stretch (to calculate the PBA taking it into account):
        stretch100.PrimaServiciosA__c = stretch.PrimaServiciosA__c;

        Decimal pba100 = CPQ_PBAService.build(quoteWrapper, stretch100, tablesData, CPQ_PBAService.FULL_ESTIMATED_CONSUMPTION_COEF).calculateResult();

        CPQ_LogUtil.debug('[CPQ_PBAService] calculateSuggestedDiscount Target PBA: '+pba100);

        Decimal discountOperationSign = (stretch.FromPercentage__c > REFERENCE_FROM_PERCENTAGE) ? 1 : -1;

        for(Integer i=0;i<N_ATTEMPTS_FIND_PBA_DISCOUNT;i++){
            Decimal foundPBA = CPQ_PBAService.build(quoteWrapper, stretch, tablesData, CPQ_PBAService.FULL_ESTIMATED_CONSUMPTION_COEF).calculateResult();
            if(foundPBA == null){
                // If PBA is null it means it cannot be calculated:
                CPQ_LogUtil.debug('[CPQ_PBASErvice] calculateSuggestedDiscount: PBA is null, skipping calculation.');
                break;
            }
            CPQ_LogUtil.debug('[CPQ_PBASErvice] calculateSuggestedDiscount: ('+foundPBA+' vs ' + pba100+') Discount: '+stretch.DiscountKG__c+ ' - '+stretch.FromPercentage__c);
            
            if(discountOperationSign > 0 && foundPBA >= pba100
            || discountOperationSign < 0 && foundPBA <= pba100){
                CPQ_LogUtil.debug('[CPQ_PBASErvice] calculateSuggestedDiscount: discount found for target PBA.');
                break;
            }
            stretch.DiscountKG__c += DISCOUNT_AMOUNT_PER_ITERATION * discountOperationSign;
        }
        Decimal calculatedDiscount = stretch.DiscountKG__c;
        stretch.DiscountKG__c = originalDiscount;
        return calculatedDiscount;
    }

    public static void deleteQuotesStretches(List<Id> quotesId){
        delete [SELECT Id FROM Stretch__c WHERE Quote__c IN :quotesId];
    }
}