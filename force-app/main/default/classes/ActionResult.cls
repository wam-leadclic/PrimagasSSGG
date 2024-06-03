public class ActionResult {
    @AuraEnabled public String message;
    @AuraEnabled public Boolean hasError;
    @AuraEnabled public Object data;

    public ActionResult() {
        this.hasError = false;
    }
}