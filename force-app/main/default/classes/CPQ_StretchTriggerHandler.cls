public without sharing class CPQ_StretchTriggerHandler implements ITriggerHandler {

    private static Set<Id> managedStretches = new Set<Id>();
    private static Map<Id, Set<Id>> managedStretchesByQuoteId = new Map<Id, Set<Id>>();

    private boolean triggerIsExecuting;
    private integer triggerSize;

    public CPQ_StretchTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
    }
    
    public void beforeInsert(List<Stretch__c> newStretches) {
        
    }
    public void beforeUpdate(List<Stretch__c> oldStretches, List<Stretch__c> newStretches, Map<ID, SObject> oldStretchMap, Map<ID, SObject> newStretchMap) {

    }
    public void beforeDelete(List<Stretch__c> oldStretches, Map<ID, SObject> oldStretchMap) {

    }
    public void afterInsert(List<Stretch__c> newStretches, Map<ID, SObject> newStretchMap) {
        for(Stretch__c s : newStretches){
            setAsManaged(s);
        }
    }
    public void afterUpdate(List<Stretch__c> oldStretches, List<Stretch__c> newStretches, Map<ID, SObject> oldStretchMap, Map<ID, SObject> newStretchMap) {
        for(Stretch__c s : newStretches){
            setAsManaged(s);
        }
    }
    public void afterDelete(List<Stretch__c> oldStretches, Map<ID, SObject> oldStretchMap) {
        
    }
    public void afterUndelete(List<Stretch__c> newStretches, Map<ID, SObject> newStretchMap) {
        
    }

    private static void setAsManaged(Stretch__c s){
        if(!managedStretchesByQuoteId.containsKey(s.Quote__c)){
            managedStretchesByQuoteId.put(s.Quote__c, new Set<Id>());
        }
        managedStretchesByQuoteId.get(s.Quote__c).add(s.Id);
        managedStretches.add(s.Id);
    }

    public static Boolean isStretchAlreadyManaged(Id id){
        return managedStretches.contains(id);
    }

    public static void clearManagedStretchesForQuote(Id quoteId){
        if(managedStretchesByQuoteId.containsKey(quoteId)){
            for(Id stretchId : managedStretchesByQuoteId.get(quoteId)){
                managedStretches.remove(stretchId);
            }
            managedStretchesByQuoteId.get(quoteId).clear();
        }
    }

    public static void clearManagedStretchesForQuoteWrappers(List<CPQ_Quote.QuoteWrapper> qws){
        for(CPQ_Quote.QuoteWrapper w : qws){
            if(managedStretchesByQuoteId.containsKey(w.Quote.Id)){
                for(Id stretchId : managedStretchesByQuoteId.get(w.Quote.Id)){
                    managedStretches.remove(stretchId);
                }
                managedStretchesByQuoteId.get(w.Quote.Id).clear();
            }
        }
    }

    public static void clearManagedStretches(){
        managedStretchesByQuoteId.clear();
        managedStretches.clear();
    }
}