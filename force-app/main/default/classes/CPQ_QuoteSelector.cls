public without sharing class CPQ_QuoteSelector {

    public static SBQQ__Quote__c selectById(Id quoteId){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_QuoteSelector] selectById');

        return [SELECT  Id,
                        FeeAmount__c,
                        SBQQ__StartDate__c,
                        County__c,
                        EstimatedConsumption__c,
                        SBQQ__Status__c,
                        ClientTank__c,
                        HasStretches__c,
                        NStretches__c,
                        Duration__c,
                        SBQQ__Opportunity2__r.Dimension3__c
                FROM SBQQ__Quote__c
                WHERE Id =: quoteId LIMIT 1];
    }

    public static SBQQ__Quote__c selectByIdForPDF(Id quoteId){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_QuoteSelector] selectByIdForPDF');
        return [SELECT  Id,
                        SBQQ__Account__r.Name,
                        SBQQ__StartDate__c,
                        FeeAmount__c,
                        County__c,
                        EstimatedConsumption__c,
                        SBQQ__Status__c,
                        ClientTank__c,
                        HasStretches__c,
                        NStretches__c,
                        Duration__c,
                        AdditionalConditions__c,
                        SBQQ__Opportunity2__r.Dimension3__c,
                        PaymentTerm__c,
                        (SELECT Id,
                                SBQQ__ProductCode__c,
                                SBQQ__ProductFamily__c,
                                DiscountDuration__c,
                                SBQQ__Product__c,
                                SBQQ__Product__r.Name,
                                SBQQ__Product__r.ProductCode,
                                SBQQ__Product__r.Family,
                                TankName__c,
                                SBQQ__NetTotal__c,
                                SBQQ__Quantity__c,
                                SBQQ__NetPrice__c
                        FROM SBQQ__LineItems__r)
                FROM SBQQ__Quote__c
                WHERE Id =: quoteId LIMIT 1];
    }

    public static List<SBQQ__Quote__c> selectById(Set<Id> quotesId){
        CPQ_LogUtil.debug('*SELECTOR* [CPQ_QuoteSelector] selectById set');
        return [SELECT  Id,
                        FeeAmount__c,
                        SBQQ__StartDate__c,
                        County__c,
                        EstimatedConsumption__c,
                        SBQQ__Status__c,
                        ClientTank__c,
                        HasStretches__c,
                        NStretches__c,
                        Duration__c,
                        SBQQ__Notes__c,
                        SBQQ__Opportunity2__r.Dimension3__c
                FROM SBQQ__Quote__c
                WHERE Id =: quotesId];
    }
/*
    public static List<SBQQ__Quote__c> selectByIdWithOpportunities(Set<Id> quotesId){
        return [SELECT  Id,
                        FeeAmount__c,
                        County__c,
                        EstimatedConsumption__c,
                        SBQQ__Status__c,
                        ClientTank__c,
                        HasStretches__c,
                        NStretches__c,
                        (SELECT Id,
                                Name,
                                Cliente_propietario_del_tanque__c
                        FROM SBQQ__PrimaryOpportunities__r)
                FROM SBQQ__Quote__c
                WHERE Id =: quotesId];
    }*/

    public static List<SBQQ__Quote__c> selectByIdWithQuoteLineItems(Set<Id> quotesId){
        CPQ_LogUtil.debug('*SELECTOR* before [CPQ_QuoteSelector] selectByIdWithQuoteLineItems '+Limits.getQueries());
        List<SBQQ__Quote__c> output = [SELECT  Id,
                FeeAmount__c,
                SBQQ__StartDate__c,
                County__c,
                EstimatedConsumption__c,
                SBQQ__Status__c,
                ClientTank__c,
                HasStretches__c,
                NStretches__c,
                Duration__c,
                SBQQ__Notes__c,
                SBQQ__Opportunity2__r.Dimension3__c,
                (SELECT Id,
                        SBQQ__ProductCode__c,
                        SBQQ__ProductFamily__c,
                        DiscountDuration__c,
                        SBQQ__Product__c,
                        SBQQ__Product__r.ProductCode,
                        SBQQ__Product__r.Family,
                        TankName__c,
                        SBQQ__NetTotal__c,
                        SBQQ__Quantity__c,
                        SBQQ__NetPrice__c
                FROM SBQQ__LineItems__r)
        FROM SBQQ__Quote__c
        WHERE Id =: quotesId];
        CPQ_LogUtil.debug('*SELECTOR* after [CPQ_QuoteSelector] selectByIdWithQuoteLineItems '+Limits.getQueries());
        return output;
    }
}