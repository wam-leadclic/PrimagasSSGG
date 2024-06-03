public with sharing class CPQ_Quote {
    public static final String STATUS_IN_DRAFT = 'Draft';
    public static final String STATUS_PENDING_APPROVAL = 'Pendiente de aprobación';

    public static void fillComputedFieldsForQuotes(
        List<SBQQ__Quote__c> newQuotes,
        Map<Id, SBQQ__Quote__c> oldQuotesMap
    ) {
        for (SBQQ__Quote__c newQuote : newQuotes) {
            if (isQuoteBeingPrepared(newQuote)) {
                fillComputedQuoteFields(
                    newQuote,
                    oldQuotesMap.containsKey(newQuote.Id) ? oldQuotesMap.get(newQuote.Id) : null
                );
            }
        }
    }

    private static void fillComputedQuoteFields(SBQQ__Quote__c newQuote, SBQQ__Quote__c oldQuote) {
        // PCPQ-54
        if (oldQuote == null || newQuote.ClientTank__c != oldQuote.ClientTank__c) {
            newQuote.HasStretches__c = !newQuote.ClientTank__c;
        }
    }
/*
    public static void updateControlMetricsForQuotes(Set<Id> quotesId) {
        updateControlMetricsForQuotes(CPQ_QuoteService.buildWrappersFromQuotesId(quotesId));
    }

    public static void updateControlMetricsForQuotes(List<CPQ_Quote.QuoteWrapper> quoteWrappers) {
        update fillControlMetricsForQuotes(quoteWrappers, CPQ_Settings.DefaultPBAEstimatedConsCoef);
    }*/

    public static List<SBQQ__Quote__c> fillControlMetricsForQuotes(List<CPQ_Quote.QuoteWrapper> quoteWrappers, Decimal estimatedConsumptionCoef) {
        List<SBQQ__Quote__c> output = new List<SBQQ__Quote__c>();

        CPQ_TablesDataWrapper tablesData = null;

        // 1.- Check it the tablesData will be needed for the calculation:
        for (CPQ_Quote.QuoteWrapper w : quoteWrappers) {
            if (isQuoteBeingPrepared(w.Quote)) {
                tablesData = CPQ_TablesDataWrapper.generate(quoteWrappers);
                break;
            }
        }

        // 2.- Perform the checking:
        for (CPQ_Quote.QuoteWrapper w : quoteWrappers) {
            if (isQuoteBeingPrepared(w.Quote)) {
                fillSingleQuoteControlMetrics(w, tablesData, estimatedConsumptionCoef);
                output.add(w.Quote);
            }
        }

        return output;
    }

    public static void fillSingleQuoteControlMetrics(
        CPQ_Quote.QuoteWrapper quoteWrapper,
        CPQ_TablesDataWrapper tablesData,
        Decimal estimatedConsumptionCoef
    ) {

        // PCPQ-37
        if(quoteWrapper.hasLines()){
            CPQ_PBAService.PBAParams pba = CPQ_PBAService.build(quoteWrapper, tablesData, estimatedConsumptionCoef);
            quoteWrapper.Quote.GasPriceRange__c = pba.MargenDeGas;
            quoteWrapper.Quote.PBA__c = pba.calculateResult();
            quoteWrapper.Quote.Credit__c = pba.Credit;
            quoteWrapper.Quote.Investment__c = pba.TotalInvestment;
            quoteWrapper.Quote.NonRecoveryInvestment__c = pba.NonRecoveryInvestment;

            quoteWrapper.Quote.CLV5__c = CPQ_CLVService.calculateResult(5, quoteWrapper, null, tablesData, estimatedConsumptionCoef);
            quoteWrapper.Quote.CLV10__c = CPQ_CLVService.calculateResult(10, quoteWrapper, null, tablesData, estimatedConsumptionCoef);
        }else{
            // Empty fields:
            quoteWrapper.Quote.PBA__c = null;
            quoteWrapper.Quote.Credit__c = null;
            quoteWrapper.Quote.Investment__c = null;
            quoteWrapper.Quote.NonRecoveryInvestment__c = null;
            quoteWrapper.Quote.GasPriceRange__c = null;
            
            quoteWrapper.Quote.CLV5__c = null;
            quoteWrapper.Quote.CLV10__c = null;
        }
    }

    /**
     * Creates default stretches for the quote if the Quote doesn't have any and is set
     * to have stretches.
     * @param quoteWrappers 
     */
    public static void manageStretches(List<CPQ_Quote.QuoteWrapper> quoteWrappers) {
        // PCPQ-54
        List<Stretch__c> stretchesToDelete = new List<Stretch__c>();
        List<Stretch__c> stretchesToCreate = new List<Stretch__c>();
        List<Stretch__c> stretchesToUpdate = new List<Stretch__c>();

        Set<Id> quotesId = extractQuotesId(quoteWrappers);

        Map<Id, List<Stretch__c>> existingStretchesByQuoteId = CPQ_StretchService.getStretchesByQuoteId(quotesId);
        CPQ_TablesDataWrapper tablesData = null;

        // 1.- Check if there's a quote that will need default stretches. If so, load the tablesData:
        for (CPQ_Quote.QuoteWrapper quoteWrapper : quoteWrappers) {
            if(quoteWrapper.Quote.HasStretches__c){
                tablesData = CPQ_TablesDataWrapper.generate(quoteWrappers);
                break;
            }
        }

        // 2.- Find the stretches to create / delete:
        for (CPQ_Quote.QuoteWrapper quoteWrapper : quoteWrappers) {
            if (isQuoteBeingPrepared(quoteWrapper.Quote)) {
                if (quoteWrapper.Quote.HasStretches__c) {
                    if (quoteWrapper.Quote.NStretches__c == 0) {
                        // Create default stretches
                        stretchesToCreate.addAll(
                            CPQ_StretchService.buildDefaultStretchesForQuote(quoteWrapper, tablesData)
                        );
                    }else{
                        // The existing stretches need to refresh their computed values:
                        for(Stretch__c t : existingStretchesByQuoteId.get(quoteWrapper.Quote.Id)){
                            // We just want to update the stretches that haven't been created/updated in the same transaction,
                            // as there's a dependency between Quote and Stretch:
                            // insert quote -> insert stretch -> update quote (rollup) -> update stretch

                            if(!CPQ_StretchTriggerHandler.isStretchAlreadyManaged(t.Id)){
                                CPQ_Stretch.fillComputedValues(t, quoteWrapper, tablesData, true);
                                CPQ_Stretch.fillMetrics(t, quoteWrapper, tablesData);
                                stretchesToUpdate.add(t);
                            }
                        }
                    }
                } else {
                    // Remove existing stretches
                    if (existingStretchesByQuoteId.containsKey(quoteWrapper.Quote.Id)) {
                        stretchesToDelete.addAll(existingStretchesByQuoteId.get(quoteWrapper.Quote.Id));
                    }
                }
            }
        }

        if (!stretchesToCreate.isEmpty())
            insert stretchesToCreate;

        if (!stretchesToDelete.isEmpty())
            delete stretchesToDelete;
            
        if (!stretchesToUpdate.isEmpty())
            update stretchesToUpdate;

    }

    public static Boolean isQuoteBeingPrepared(SBQQ__Quote__c quote) {
        return quote.SBQQ__Status__c == STATUS_IN_DRAFT;
    }

    public static void setCountyGasRates(List<SBQQ__Quote__c> quotes) {
        Map<String, GasPriceRange__c> gasPriceRangeMasterData = new Map<String, GasPriceRange__c>();
        List<SBQQ__Quote__c> affectedQuotes = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c quote : quotes) {
            if (needsCountyGasRateRecalculation(quote)) {
                affectedQuotes.add(quote);
                gasPriceRangeMasterData.put(quote.County__c, null);
            }
        }
        gasPriceRangeMasterData = GasPriceRangeService.getProvincePriceRanges(gasPriceRangeMasterData.keySet());
        for (SBQQ__Quote__c quote : affectedQuotes) {
            quote.MinGasPriceRange__c = gasPriceRangeMasterData.get(quote.County__c)?.Range__c;
        }
    }

    private static Boolean needsCountyGasRateRecalculation(SBQQ__Quote__c quote) {
        return quote.SBQQ__Status__c == CPQ_QuoteConstants.STATUS_DRAFT && String.isNotBlank(quote.County__c);
    }

    public class QuoteWrapper {
        private SBQQ__Quote__c quoteRecord;
        private List<SBQQ__QuoteLine__c> qliRecords = new List<SBQQ__QuoteLine__c>();
        private Map<String, List<SBQQ__QuoteLine__c>> quoteLinesByProductCode = new Map<String, List<SBQQ__QuoteLine__c>>();
        private Map<String, List<SBQQ__QuoteLine__c>> quoteLinesByProductFamily = new Map<String, List<SBQQ__QuoteLine__c>>();

        //      Map<Code,   Map<Family, List<SBQQ__QuoteLine__c>>>
        private Map<String, Map<String, List<SBQQ__QuoteLine__c>>> quoteLinesByProductCodeAndFamily = new Map<String, Map<String, List<SBQQ__QuoteLine__c>>>();

        public SBQQ__Quote__c Quote {
            get {
                return quoteRecord;
            }
        }

        public List<SBQQ__QuoteLine__c> Lines {
            get{
                return qliRecords;
            }
        }

        public Boolean IsDomestic {
            get{
                return CPQ_Opportunity.isDomestic(quoteRecord.SBQQ__Opportunity2__r.Dimension3__c);
            }
        }

        public Decimal Rate {
            get{
                return CPQ_AggregateUtil.convertToZeroIfNull(getFirstLineByProductFamilyExcludingProductCodes(CPQ_ProductFamilies.TARIFAS,
                    new Set<String>{CPQ_ProductCodes.TARIFA})?.SBQQ__NetPrice__c);
            }
        }

        public Decimal PriceTodayKG {
            get{
                return CPQ_AggregateUtil.convertToZeroIfNull(getFirstLineByProductFamilyExcludingProductCodes(CPQ_ProductFamilies.TARIFAS,
                    new Set<String>{CPQ_ProductCodes.TARIFA})?.SBQQ__NetTotal__c);
            }
        }

        public Decimal DiscountDurationInYears {
            get{
                return CPQ_AggregateUtil.convertToZeroIfNull(
                    getFirstLineByProductCode(CPQ_ProductCodes.DESCTARIFA)?.DiscountDuration__c
                );
            }
        }

        public Decimal Primaservicios {
            get{
                return CPQ_AggregateUtil.convertToZeroIfNull(
                    CPQ_AggregateUtil.sumFieldForRecords(getLinesByProductFamily(CPQ_ProductFamilies.PRIMASERVICIOS),
                        SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c));
            }
        }

        public Decimal DiscountEuroKG {
            get{
                return CPQ_AggregateUtil.convertToZeroIfNull(CPQ_AggregateUtil.convertToZeroIfNull(
                    getFirstLineByProductCode(CPQ_ProductCodes.DESCTARIFA)?.SBQQ__NetPrice__c
                ));
            }
        }

        public Decimal EstimatedConsumption {
            get{
                return CPQ_AggregateUtil.convertToZeroIfNull(Quote.EstimatedConsumption__c);
            }
        }

        public Boolean hasLines(){
            return !qliRecords.isEmpty();
        }

        private Set<String> sUniqueProductCodes = new Set<String>();
        public Set<String> UniqueProductCodes {
            get{
                return sUniqueProductCodes;
            }
        }

        public QuoteWrapper(SBQQ__Quote__c quoteRecord, List<SBQQ__QuoteLine__c> quoteLines) {
            this.quoteRecord = quoteRecord;

            for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
                qliRecords.add(quoteLine);

                String productCode = quoteLine.SBQQ__ProductCode__c;
                String family = quoteLine.SBQQ__ProductFamily__c;

                sUniqueProductCodes.add(productCode);

                // By product code:
                if (String.isNotBlank(productCode)) {
                    if (!quoteLinesByProductCode.containsKey(productCode)) {
                        quoteLinesByProductCode.put(productCode, new List<SBQQ__QuoteLine__c>());
                    }
                    quoteLinesByProductCode.get(productCode).add(quoteLine);
                }

                // By product family:
                if (String.isNotBlank(family)) {
                    if (!quoteLinesByProductFamily.containsKey(family)) {
                        quoteLinesByProductFamily.put(family, new List<SBQQ__QuoteLine__c>());
                    }
                    quoteLinesByProductFamily.get(family).add(quoteLine);
                }

                // By product code and family
                if (String.isNotBlank(productCode) && String.isNotBlank(family)) {
                    if (!quoteLinesByProductCodeAndFamily.containsKey(productCode)) {
                        quoteLinesByProductCodeAndFamily.put(productCode, new Map<String, List<SBQQ__QuoteLine__c>>());
                    }
                    if (!quoteLinesByProductCodeAndFamily.get(productCode).containsKey(family)) {
                        quoteLinesByProductCodeAndFamily.get(productCode)
                            .put(family, new List<SBQQ__QuoteLine__c>());
                    }
                    quoteLinesByProductCodeAndFamily.get(productCode).get(family).add(quoteLine);
                }
            }
        }

        public List<SBQQ__QuoteLine__c> getLinesByProductCode(String code) {
            if (quoteLinesByProductCode.containsKey(code)) {
                return quoteLinesByProductCode.get(code);
            } else {
                return new List<SBQQ__QuoteLine__c>();
            }
        }

        public List<SBQQ__QuoteLine__c> getLinesForMultipleProductCodes(List<String> codes) {
            Set<SBQQ__QuoteLine__c> output = new Set<SBQQ__QuoteLine__c>();

            for (String code : codes) {
                if (quoteLinesByProductCode.containsKey(code)) {
                    output.addAll(quoteLinesByProductCode.get(code));
                }
            }
            return new List<SBQQ__QuoteLine__c>(output);
        }

        public SBQQ__QuoteLine__c getFirstLineByProductCode(String code) {
            if (quoteLinesByProductCode.containsKey(code)) {
                return quoteLinesByProductCode.get(code)[0];
            } else {
                return null;
            }
        }

        public List<SBQQ__QuoteLine__c> getLinesByProductFamily(String family) {
            if (quoteLinesByProductFamily.containsKey(family)) {
                return quoteLinesByProductFamily.get(family);
            } else {
                return new List<SBQQ__QuoteLine__c>();
            }
        }

        public SBQQ__QuoteLine__c getFirstLineByProductFamily(String productFamily) {
            if (quoteLinesByProductFamily.containsKey(productFamily)) {
                return quoteLinesByProductFamily.get(productFamily)[0];
            } else {
                return null;
            }
        }

        public List<SBQQ__QuoteLine__c> getLinesByProductCodeAndProductFamily(String code, String family) {
            List<SBQQ__QuoteLine__c> output = new List<SBQQ__QuoteLine__c>();

            if (
                quoteLinesByProductCodeAndFamily.containsKey(code) &&
                quoteLinesByProductCodeAndFamily.get(code).containsKey(family)
            ) {
                return quoteLinesByProductCodeAndFamily.get(code).get(family);
            } else {
                return new List<SBQQ__QuoteLine__c>();
            }
        }
        public SBQQ__QuoteLine__c getFirstLineByProductFamilyExcludingProductCodes(String family, Set<String> codesToExclude) {
            if (quoteLinesByProductFamily.containsKey(family)) {
                for(SBQQ__QuoteLine__c ql : quoteLinesByProductFamily.get(family)){
                    if(!codesToExclude.contains(ql.SBQQ__ProductCode__c)){
                        return ql;
                    }
                }
                return null;
            } else {
                return null;
            }
        }
        /*
        public void deleteQLIsForProductCodeAndAdd(SBQQ__QuoteLine__c qli){
            // quoteLinesByProductCode
            quoteLinesByProductCode.remove(qli.SBQQ__ProductCode__c);
            quoteLinesByProductCode.put(qli.SBQQ__ProductCode__c, new List<SBQQ__QuoteLine__c>{qli});

            // quoteLinesByProductFamily
            if(quoteLinesByProductFamily.containsKey(qli.BundleFamily__c)){
                List<SBQQ__QuoteLine__c> toInclude = new List<SBQQ__QuoteLine__c>();
                for(SBQQ__QuoteLine__c q : quoteLinesByProductFamily.get(qli.BundleFamily__c)){
                    if(q.SBQQ__ProductCode__c != qli.SBQQ__ProductCode__c){
                        toInclude.add(q);
                    }
                }
                quoteLinesByProductFamily.put(qli.BundleFamily__c, toInclude);
                quoteLinesByProductFamily.get(qli.BundleFamily__c).add(qli);
            }

            // quoteLinesByProductCodeAndFamily
            quoteLinesByProductCodeAndFamily.remove(qli.SBQQ__ProductCode__c);
            quoteLinesByProductCodeAndFamily.put(qli.SBQQ__ProductCode__c, new Map<String, List<SBQQ__QuoteLine__c>>{
                qli.BundleFamily__c => new List<SBQQ__QuoteLine__c>{qli}
            });
        }*/
    }

    public static Set<Id> extractQuotesId(List<CPQ_Quote.QuoteWrapper> quoteWrappers) {
        Set<Id> quotesId = new Set<Id>();
        for (CPQ_Quote.QuoteWrapper w : quoteWrappers) {
            quotesId.add(w.Quote.Id);
        }
        return quotesId;
    }

    public class QuoteLineNotFoundByProductCodeException extends Exception {
    }

    public class QuoteLineNotFoundByProductFamilyException extends Exception {
    }

    public class QuoteLineNotFoundByProductCodeAndFamilyException extends Exception {
    }
}