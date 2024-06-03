@RestResource(urlMapping='/CPQ/metrics/*')
global without sharing class CPQ_MetricsService {
    /**
     * IMPORTANT
     * The data provided to this endpoint must contain the required fields for the calculations.
     * If a new field is included in the calculation process, please check the custom script (for the lines editor)
     * and include the new fields in the request for both the Quote line items and the Quote.
     * @return  `OutputMetricsWrapper`
     */
    @HttpPost
    global static OutputMetricsWrapper calculateREST(SBQQ__Quote__c quote, List<SBQQ__QuoteLine__c> qlis) {
        // If the opportunity info is not retrieved fetch it:
        try{
            CPQ_Opportunity.fillOpportunityDataForQuotes(new List<SBQQ__Quote__c>{quote});

            if (qlis.size() > 0) {
                CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrapperFromQuote(quote, qlis);

                CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

                try {
                    return new OutputMetricsWrapper(
                        CPQ_PBAService.build(quoteWrapper, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef).calculateResult(),
                        CPQ_CLVService.calculateResult(5, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef),
                        CPQ_CLVService.calculateResult(10, quoteWrapper, null, tablesData, CPQ_Settings.DefaultPBAEstimatedConsCoef)
                    );
                } catch (CPQ_Settings.SettingsNotFoundException e) {
                    System.debug(LoggingLevel.ERROR, e.getMessage() + e.getStackTraceString());
                    return new OutputMetricsWrapper(Label.CPQ_MissingSettings);
                } catch (CPQ_MetricException e){
                    System.debug(LoggingLevel.ERROR, e.getMessage() + e.getStackTraceString());
                    return new OutputMetricsWrapper(e.getMessage() + e.getStackTraceString());
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage() + e.getStackTraceString());
            return new OutputMetricsWrapper(e.getMessage() + e.getStackTraceString());
        }
        return new OutputMetricsWrapper(-999999, -999999, -999999);
    }

    global class OutputMetricsWrapper {
        public Decimal PBA;
        public Decimal CLV5;
        public Decimal CLV10;
        public String developerError;
        public String error;

        public OutputMetricsWrapper(Decimal PBA, Decimal CLV5, Decimal CLV10) {
            this.PBA = PBA;
            this.CLV5 = CLV5;
            this.CLV10 = CLV10;
        }

        public OutputMetricsWrapper(String error){
            this.developerError = error;
            this.error = Label.CPQ_ErrorOccurred;
        }
    }

    public class MetricsCalculationException extends Exception {
    }
}