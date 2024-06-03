public class CPQ_Opportunity {

    // DOMESTIC
    public static final String DIMENSION3_1000_DU = '1000-DU';
    public static final String DIMENSION3_1100_CV = '1100-CV';
    public static final String DIMENSION3_1800_PC = '1800-PC';
    public static final String DIMENSION3_1850_PM = '1850-PM';

    // PROFESSIONAL
    public static final String DIMESION3_1200_AGRI = '1200-AGRI';
    public static final String DIMESION3_1300_IND = '1300-IND';
    public static final String DIMESION3_1400_HRO = '1400-HRO';
    public static final String DIMESION3_1500_COL = '1500-COL';
    public static final String DIMESION3_1900_FLT = '1900-FLT';
    public static final String DIMESION3_2000_OP = '2000-OP';
    public static final String DIMESION3_2100_DIGR = '2100-DIGR';
    public static final String DIMESION3_2200_DIPC = '2200-DIPC';

    private static final Set<String> DOMESTIC_DIMENSION3 = new Set<String>{
        DIMENSION3_1000_DU,
        DIMENSION3_1100_CV,
        DIMENSION3_1800_PC,
        DIMENSION3_1850_PM
    };

    public static Boolean isDomestic(String dimension3){
        return DOMESTIC_DIMENSION3.contains(dimension3);
    }

    public static Boolean doesQuoteContainRequiredOppData(SBQQ__Quote__c quote){
        return quote.SBQQ__Opportunity2__r.Dimension3__c != null;
    }

    /**
     * Fills the quote with the related opportunity data.
     * It's used in the metrics calculation.
     * @param quotes 
     */
    public static void fillOpportunityDataForQuotes(List<SBQQ__Quote__c> quotes){
        List<Id> oppsId = CPQ_AggregateUtil.getFieldOfTypeIdForRecords(quotes, SBQQ__Quote__c.Fields.SBQQ__Opportunity2__c);

        Map<Id, Opportunity> opportunitiesById = new Map<Id, Opportunity>(CPQ_OpportunitySelector.selectByIds(new Set<Id>(oppsId)));
        for(SBQQ__Quote__c q : quotes){
            if(q.SBQQ__Opportunity2__c != null)
                q.SBQQ__Opportunity2__r = opportunitiesById.get(q.SBQQ__Opportunity2__c);
        }
    }
}