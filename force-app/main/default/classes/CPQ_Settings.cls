public without sharing class CPQ_Settings {
    private static CPQ_Settings__mdt setting;

    private static CPQ_Settings__mdt settings {
        get {
            if (setting == null) {
                try {
                    setting = [
                        SELECT
                            Id,
                            DiscountRatePercentage__c,
                            DepRate5Years__c,
                            DepRate10Years__c,
                            DepYears__c,
                            DefaultPBAEstimatedConsPerc__c,
                            LogsEnabled__c,
                            SuggestDiscountOnOpenStretchManager__c,
                            MaxSuggestedDiscountIterations__c,
                            SuggestedDiscountIterationIncrement__c
                        FROM CPQ_Settings__mdt
                        WHERE Sandbox__c = :runningInASandbox
                    ];
                } catch (QueryException e) {
                    if (e.getMessage().startsWith('List has no rows')) {
                        throw new SettingsNotFoundException(e.getMessage());
                    } else {
                        throw e;
                    }
                }
            }

            return setting;
        }
    }

    public static void setTestSetting(CPQ_Settings__mdt s){
        setting = s;
    }

    public static Boolean runningInASandbox {
        get {
            if (runningInASandbox == null) {
                System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());
                runningInASandbox = domain.getSandboxName() == null ? false : true;
            }
            return runningInASandbox;
        }
        set;
    }

    public static Integer MaxSuggestedDiscountIterations {
        get {
            return (Integer)settings.MaxSuggestedDiscountIterations__c;
        }
    }

    public static Decimal SuggestedDiscountIterationIncrement {
        get {
            return settings.SuggestedDiscountIterationIncrement__c;
        }
    }

    public static Boolean SuggestDiscountOnOpenStretchManager {
        get {
            return settings.SuggestDiscountOnOpenStretchManager__c;
        }
    }

    public static Decimal DefaultPBAEstimatedConsCoef {
        get {
            return settings.DefaultPBAEstimatedConsPerc__c / 100;
        }
    }

    public static Decimal DiscountRateCoef {
        get {
            // Value is '11', returned as '0.11':
            return (Decimal) settings.DiscountRatePercentage__c / 100;
        }
    }

    public static Integer DiscountRate {
        get {
            return (Integer) settings.DiscountRatePercentage__c;
        }
    }

    public static Integer DepYears {
        get {
            return (Integer) settings.DepYears__c;
        }
    }

    public static Decimal DepRate5Years {
        get {
            return settings.DepRate5Years__c;
        }
    }

    public static Decimal DepRate10Years {
        get {
            return settings.DepRate10Years__c;
        }
    }

    public static Boolean AreLogsEnabled {
        get {
            return settings.LogsEnabled__c;
        }
    }

    public class SettingsNotFoundException extends Exception {
    }

    public static Boolean isDMLExceptionSettingNotFound(DMLException e) {
        return e.getMessage().contains('CPQ_Settings.SettingsNotFoundException');
    }
}