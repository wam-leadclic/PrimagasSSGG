public without sharing class CPQ_GPCAPEXService {

    public static Decimal calculateResult(CPQ_Quote.QuoteWrapper quoteWrapper, CPQ_TablesDataWrapper tablesData) {
        // Calculate the pba for as much years as the contract lasts.
        // Get the latest pba calculated:
        List<CPQ_PBAService.PBAParams> pbas = CPQ_PBAService.generateParamsForYears(
            (Integer)quoteWrapper.Quote.Duration__c,
            quoteWrapper,
            null,
            tablesData,
            CPQ_Settings.DefaultPBAEstimatedConsCoef
        );

        Decimal gp = 0;

        for(Integer i=0;i<quoteWrapper.Quote.Duration__c;i++){
            pbas[i].calculateFields();
            gp += pbas[i].TotalMargin;
            CPQ_LogUtil.debug('[CPQ_GPCAPEXService] Year '+i+': '+pbas[i].TotalMargin);
        }

        Decimal gpApexResult = gp / pbas[0].TotalInvestment;
        CPQ_LogUtil.debug('[CPQ_GPCAPEXService] GPAPEX is '+gpApexResult +' = '+gp + ' / ' + pbas[0].TotalInvestment);
        return gpApexResult;
    }
}