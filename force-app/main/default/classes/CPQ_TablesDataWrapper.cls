public class CPQ_TablesDataWrapper {

    // To prevent querying the same data every time it's required, we use the variable below:
    public static CPQ_TablesDataWrapper instance;
    public static Set<Id> quoteIds = new Set<Id>();

    public CPQ_GasCost.GasCostsByCounty gc;
    public CPQ_TankMaintenanceCost.TMCByCounty tmc;
    public CPQ_TankMasterData.TankMasterDataByName tmd;
    public CPQ_ServiceCost.ServiceCostsByCounty sc;
    public CPQ_EquipmentMasterData.EquipmentMasterData emd;
/*
    public CPQ_TablesDataWrapper(
        CPQ_GasCost.GasCostsByCounty gc,
        CPQ_TankMaintenanceCost.TMCByCounty tmc,
        CPQ_TankMasterData.TankMasterDataByName tmd,
        CPQ_ServiceCost.ServiceCostsByCounty sc,
        CPQ_EquipmentMasterData.EquipmentMasterData emd
    ) {
        this.gc = gc;
        this.tmc = tmc;
        this.tmd = tmd;
        this.sc = sc;
        this.emd = emd;
    }*/

    public CPQ_TablesDataWrapper(CPQ_Quote.QuoteWrapper quoteWrapper) {
        gc = CPQ_GasCost.getGasCostsForQuotes(quoteWrapper);
        tmc = CPQ_TankMaintenanceCost.getTMCForQuoteWrappers(quoteWrapper);
        tmd = CPQ_TankMasterData.getForQuoteWrappers(quoteWrapper);
        sc = CPQ_ServiceCost.getServiceCostsForQuotes(quoteWrapper);
        emd = CPQ_EquipmentMasterData.getForQuoteWrappers(quoteWrapper);
    }
    
    public CPQ_TablesDataWrapper(List<CPQ_Quote.QuoteWrapper> quoteWrappers) {
        gc = CPQ_GasCost.getGasCostsForQuotes(quoteWrappers);
        tmc = CPQ_TankMaintenanceCost.getTMCForQuoteWrappers(quoteWrappers);
        tmd = CPQ_TankMasterData.getForQuoteWrappers(quoteWrappers);
        sc = CPQ_ServiceCost.getServiceCostsForQuotes(quoteWrappers);
        emd = CPQ_EquipmentMasterData.getForQuoteWrappers(quoteWrappers);
    }

    public static CPQ_TablesDataWrapper generate(CPQ_Quote.QuoteWrapper quoteWrapper){
        return generate(new List<CPQ_Quote.QuoteWrapper>{quoteWrapper});
    }
    
    public static CPQ_TablesDataWrapper generate(List<CPQ_Quote.QuoteWrapper> quoteWrappers){
        Boolean recalculate = false;

        for(CPQ_Quote.QuoteWrapper w : quoteWrappers){
            if(!quoteIds.contains(w.Quote.Id)){
                recalculate = true;
            }
            quoteIds.add(w.Quote.Id);
        }

        if(recalculate)
            instance = new CPQ_TablesDataWrapper(quoteWrappers);

        return instance;
    }

    public static void clearQuoteFromCache(Id quoteId){
        quoteIds.remove(quoteId);
    }

    public static void clearQuotesFromCache(List<CPQ_Quote.QuoteWrapper> qws){
        for(CPQ_Quote.QuoteWrapper w : qws)
            quoteIds.remove(w.Quote.Id);
    }
}