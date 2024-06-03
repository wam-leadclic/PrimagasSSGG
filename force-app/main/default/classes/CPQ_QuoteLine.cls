public with sharing class CPQ_QuoteLine {
    /*
    public static SBQQ__QuoteLine__c generateFakeQLI(String productCode, Decimal netPrice){
        JSONGenerator gen = JSON.createGenerator(false);

        gen.writeStartObject();
        gen.writeStringField(SBQQ__QuoteLine__c.SBQQ__ProductCode__c.getDescribe().getName(), productCode);
        gen.writeNumberField(SBQQ__QuoteLine__c.SBQQ__NetPrice__c.getDescribe().getName(), netPrice);
        gen.writeEndObject();

        return (SBQQ__QuoteLine__c)JSON.deserialize(gen.getAsString(), SBQQ__QuoteLine__c.class);
    }*/
}