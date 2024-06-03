public without sharing class CPQ_QuoteStretchesManagerCtrl {

    private static final Integer MIN_STRETCHES = 3;
    /**
     * Toggles the Quote's hasStretches value and returns the found stretched records.
     * @param quoteId
     * @param hasStretches
     * @return  `List<StretchWrapper>`
     * @exception
     */
    @AuraEnabled
    public static List<StretchWrapper> toggleStretchesForQuote(Id quoteId, Boolean hasStretches) {
        try {
            SBQQ__Quote__c quote = CPQ_QuoteSelector.selectByIdWithQuoteLineItems(new Set<Id>{ quoteId })[0];
            quote.HasStretches__c = hasStretches;
            update quote;

            return hasStretches ? getStretchesForQuote(quoteId, null, true, true) : new List<StretchWrapper>();
        } catch (CPQ_Settings.SettingsNotFoundException e) {
            throw new AuraHandledException(Label.CPQ_MissingSettings);
        } catch (DMLException e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            if (CPQ_Settings.SettingsNotFoundException.isDMLExceptionSettingNotFound(e)) {
                throw new AuraHandledException(Label.CPQ_MissingSettings);
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static StretchWrapper fillDiscountInputForStretch(String stretchJSON, Id quoteId){
        try {
            StretchWrapper originalStretch = (StretchWrapper)Json.deserialize(stretchJSON, StretchWrapper.class);
            StretchWrapper tempStretch = (StretchWrapper)Json.deserialize(stretchJSON, StretchWrapper.class);

            CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{quoteId})[0];
            CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

            // Apply the discount to the stretch which will be used for the calculation:
            tempStretch.stretch.DiscountKG__c = tempStretch.DTO_EurosXKG;
            tempStretch.stretch.FromPercentage__c = tempStretch.FromValue;
            tempStretch.stretch.PrimaServiciosA__c = tempStretch.Primaservicios;
            // Set the calculated discount to the input field:
            originalStretch.DTO_EurosXKG = CPQ_Stretch.calculateSuggestedDiscount(tempStretch.stretch, quoteWrapper, tablesData);
            // Refresh the values for the computed fields:
            originalStretch.RefreshValues(quoteWrapper, tablesData, false, true);

            return originalStretch;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static StretchWrapper generateNewStretch(Id quoteId) {
        try {
            SBQQ__Quote__c quote = CPQ_QuoteSelector.selectByIdWithQuoteLineItems(new Set<Id>{ quoteId })[0];
            CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrapperFromQuote(
                quote,
                quote.SBQQ__LineItems__r
            );

            Stretch__c newStretch = CPQ_StretchService.buildNewStretch(0, quoteWrapper);

            return new StretchWrapper(quoteWrapper, newStretch, CPQ_TablesDataWrapper.generate(quoteWrapper), true, true);
        } catch (CPQ_Settings.SettingsNotFoundException e) {
            throw new AuraHandledException(Label.CPQ_MissingSettings);
        } catch (DMLException e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            if (CPQ_Settings.SettingsNotFoundException.isDMLExceptionSettingNotFound(e)) {
                throw new AuraHandledException(Label.CPQ_MissingSettings);
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Saves the current state of the stretches manager.
     * @param stretchesListJSON 
     * @exception 
     */
    @AuraEnabled
    public static List<StretchWrapper> save(String stretchesListJSON, Id quoteId) {
        System.debug('stretchesListJSON '+stretchesListJSON);
        try {
            List<StretchWrapper> stretchWrapperList = String.isBlank(stretchesListJSON)
                ? null
                : (List<StretchWrapper>) Json.deserialize(stretchesListJSON, List<StretchWrapper>.class);

            if(stretchWrapperList.size() < MIN_STRETCHES){
                throw new MinimumStretchesException(Label.CPQ_MinimumStretchesNumberError);
            }

            List<Stretch__c> stretchesToUpsert = new List<Stretch__c>();
            List<Stretch__c> stretchesToDelete = new List<Stretch__c>();
            
            CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrappersFromQuotesId(new Set<Id>{quoteId})[0];
            CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

            // Find new/edited stretches and fetch by id:
            Set<Id> managerStretchesId = new Set<Id>();
            for (StretchWrapper w : stretchWrapperList) {
                // Dump the data into the stretch record:
                w.RefreshValues(quoteWrapper, tablesData, true, true);

                if(w.stretch.Id != null){
                    managerStretchesId.add(w.stretch.Id);
                }
                stretchesToUpsert.add(w.stretch);
            }

            // Find deleted rows
            for(StretchWrapper existingStretchWrapper : getStretchesForQuote(quoteId, null, false, false)){
                if(!managerStretchesId.contains(existingStretchWrapper.stretch.Id)){
                    // The stretch was removed, delete it:
                    stretchesToDelete.add(existingStretchWrapper.stretch);
                }
            }

            upsert stretchesToUpsert;
            delete stretchesToDelete;

            return getStretchesForQuote(quoteId, null, false, false);
        } catch (CPQ_Settings.SettingsNotFoundException e) {
            throw new AuraHandledException(Label.CPQ_MissingSettings);
        } catch (DMLException e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            if (CPQ_Settings.SettingsNotFoundException.isDMLExceptionSettingNotFound(e)) {
                throw new AuraHandledException(Label.CPQ_MissingSettings);
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Returns the Quote's stretches & recalculates the values if parameters are modified in the
     * front end (without commiting the changes into the db).
     * @param quoteId
     * @param stretchesListJSON
     * @return  `List<StretchWrapper>`
     * @exception
     */
    @AuraEnabled
    public static List<StretchWrapper> getStretchesForQuote(Id quoteId, String stretchesListJSON, Boolean suggestDiscount, Boolean firstOpening) {
        System.debug('getStretchesForQuote '+suggestDiscount);
        try {
            List<StretchWrapper> stretchWrapperList = String.isBlank(stretchesListJSON)
                ? null
                : (List<StretchWrapper>) Json.deserialize(stretchesListJSON, List<StretchWrapper>.class);

            SBQQ__Quote__c quote = CPQ_QuoteSelector.selectByIdWithQuoteLineItems(new Set<Id>{ quoteId })[0];
            CPQ_Quote.QuoteWrapper quoteWrapper = CPQ_QuoteService.buildWrapperFromQuote(
                quote,
                quote.SBQQ__LineItems__r
            );

            CPQ_TablesDataWrapper tablesData = CPQ_TablesDataWrapper.generate(quoteWrapper);

            if (stretchWrapperList != null && stretchWrapperList.size() > 0) {
                for (StretchWrapper s : stretchWrapperList) {
                    s.RefreshValues(quoteWrapper, tablesData, false, true);
                }
            } else {
                // Retrieve the stretches in the DB:
                stretchWrapperList = new List<StretchWrapper>();
                for (Stretch__c t : CPQ_StretchSelector.selectByQuotesId(new Set<Id>{ quoteId })) {
                    stretchWrapperList.add(new StretchWrapper(quoteWrapper, t, tablesData, false, false));
                }
            }

            // Apply a suggested discount if:
            // - First time retrieving the records for the manager or suggestedDiscount = true
            // - A setting is enabled (for the open manager sugestion feature).
            // - The quote is being prepared
            if(suggestDiscount && stretchWrapperList != null && CPQ_Quote.isQuoteBeingPrepared(quoteWrapper.Quote)
               && (!firstOpening || (firstOpening && CPQ_Settings.SuggestDiscountOnOpenStretchManager))){
                
                for (StretchWrapper s : stretchWrapperList) {
                    s.DTO_EurosXKG = CPQ_Stretch.calculateSuggestedDiscount(s.stretch, quoteWrapper, tablesData);
                    s.RefreshValues(quoteWrapper, tablesData, false, true);
                }
            }
            return stretchWrapperList;
        } catch (CPQ_Settings.SettingsNotFoundException e) {
            throw new AuraHandledException(Label.CPQ_MissingSettings);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class StretchWrapper {
        @AuraEnabled
        public Stretch__c stretch;

        @AuraEnabled
        public String Id {
            get {
                return stretch.Id;
            }
        }

        private Decimal dFromValue = 0;

        @AuraEnabled
        public Decimal FromValue {
            get {
                return dFromValue;
            }
            set {
                dFromValue = value;
            }
        }

        @AuraEnabled
        public Decimal from_KGXYear {
            get {
                return estimatedConsumption * FromValue / 100;
            }
        }

        private Decimal dDiscountEuroKG = 0;
        @AuraEnabled
        public Decimal DTO_EurosXKG {
            get {
                return dDiscountEuroKG;
            }
            set {
                this.dDiscountEuroKG = value;
            }
        }

        @AuraEnabled
        public Decimal priceToday_EurosXKG_with_discount {
            get{
                return priceToday_EurosXKG - DTO_EurosXKG;
            }
        }

        @AuraEnabled
        public Decimal priceToday_EurosXKG {
            get {
                return stretch.PriceTodayKG__c;
            }
        }

        private Decimal dPrimaservicios = 0;
        @AuraEnabled
        public Decimal Primaservicios {
            get {
                return dPrimaservicios;
            }
            set {
                this.dPrimaservicios = value;
            }
        }

        @AuraEnabled
        public Decimal PBA {
            get {
                return this.stretch.PBA__c;
            }
        }

        @AuraEnabled
        public Decimal CLV5 {
            get {
                return this.stretch.CLV5__c;
            }
        }

        @AuraEnabled
        public Decimal CLV10 {
            get {
                return this.stretch.CLV10__c;
            }
        }

        @AuraEnabled
        public Boolean isDiscountNotSaved {
            get{
                return DTO_EurosXKG != stretch.DiscountKG__c;
            }
        }

        @AuraEnabled
        public Boolean isFromValueNotSaved {
            get{
                return FromValue != stretch.FromPercentage__c;
            }
        }

        @AuraEnabled
        public Boolean isPrimaserviciosNotSaved {
            get{
                return Primaservicios != stretch.PrimaServiciosA__c;
            }
        }

        @AuraEnabled
        public Boolean isDiscountDurationSet;

        @AuraEnabled
        public Decimal estimatedConsumption = 0;

        public StretchWrapper(
            CPQ_Quote.QuoteWrapper quoteWrapper,
            Stretch__c stretch,
            CPQ_TablesDataWrapper tablesData,
            Boolean applyInputValuesToStretchRecord,
            Boolean refreshMetrics
        ) {
            this.stretch = stretch;
            
            if(stretch.DiscountKG__c != null)
                DTO_EurosXKG = stretch.DiscountKG__c;

            if(stretch.FromPercentage__c != null)
                dFromValue = stretch.FromPercentage__c;

            if(stretch.PrimaServiciosA__c != null)
                dPrimaservicios = stretch.PrimaServiciosA__c;

            estimatedConsumption = quoteWrapper.Quote.EstimatedConsumption__c;
            isDiscountDurationSet = quoteWrapper.DiscountDurationInYears != 0;

            RefreshValues(quoteWrapper, tablesData, applyInputValuesToStretchRecord, refreshMetrics);
        }

        public void RefreshValues(
            CPQ_Quote.QuoteWrapper quoteWrapper,
            CPQ_TablesDataWrapper tablesData,
            Boolean applyInputValuesToStretchRecord,
            Boolean refreshMetrics
        ) {
            Decimal originalDiscount = stretch.DiscountKG__c;
            Decimal originalFromValue = stretch.FromPercentage__c;
            Decimal originalPrimaservicios = stretch.PrimaServiciosA__c;

            if (estimatedConsumption == null) {
                throw new CPQ_MissingFieldException('Quote with no EstimatedConsumption__c.');
            }

            stretch.DiscountKG__c = DTO_EurosXKG;
            stretch.FromPercentage__c = dFromValue;
            stretch.FromConsumptionKG__c = from_KGXYear;
            stretch.PrimaServiciosA__c = dPrimaservicios;

            if(refreshMetrics){
                stretch.PBA__c = CPQ_PBAService.build(quoteWrapper, stretch, tablesData, CPQ_PBAService.FULL_ESTIMATED_CONSUMPTION_COEF).calculateResult();
                stretch.CLV5__c = CPQ_CLVService.calculateResult(5, quoteWrapper, stretch, tablesData, CPQ_PBAService.FULL_ESTIMATED_CONSUMPTION_COEF);
                stretch.CLV10__c = CPQ_CLVService.calculateResult(10, quoteWrapper, stretch, tablesData, CPQ_PBAService.FULL_ESTIMATED_CONSUMPTION_COEF);
            }

            if(!applyInputValuesToStretchRecord){
                // Revert the record's values after calculations:
                stretch.DiscountKG__c = originalDiscount;
                stretch.FromPercentage__c = originalFromValue;
                stretch.PrimaServiciosA__c = originalPrimaservicios;
            }
        }
    }

    public class MinimumStretchesException extends Exception {
        
    }
}