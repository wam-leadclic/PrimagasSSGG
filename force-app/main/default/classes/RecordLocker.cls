public class RecordLocker {

    @InvocableMethod(label='Lock/Unlock Record' description='Lock or unlock Salesforce records for approval.')
    public static List<RecordLockResponse> performLockingAction(List<RecordLockRequest> recordLockRequests) {
        List<RecordLockResponse> responses = new List<RecordLockResponse>();
        for (RecordLockRequest recordLockRequest : recordLockRequests) {
            responses.add(recordLockRequest.processLockRequest());
        }
        return responses;
    }

    public enum RecordLockAction {LOCK, UNLOCK}

    public class RecordLockRequest {

        @InvocableVariable(label='Locking Action' description='Specify your locking action. Accepted values are LOCK or UNLOCK.' required='true')
        public String action;

        @InvocableVariable(label='Record Ids' description='Salesforce Ids of the records to be updated.' required='true')
        public List<String> recordIds;

        @InvocableVariable(label='All or Nothing' description='Set it to true to enable partial success (default=false).' required='false')
        public Boolean allOrNothing;

        private RecordLockResponse processLockRequest() {
            RecordLockResponse response;
            try {
                RecordLockAction requestedAction = RecordLockAction.valueOf(this.action);
                if (requestedAction == RecordLockAction.LOCK) {
                    response = new RecordLockResponse(System.Approval.lock(recordIds, allOrNothing == true));
                } else if (requestedAction == RecordLockAction.UNLOCK) {
                    response = new RecordLockResponse(System.Approval.unlock(recordIds, allOrNothing == true));
                }    
            } catch(DMLException dmle) {
                response = new RecordLockResponse(dmle.getDmlMessage(0), dmle.getDmlId(0));
            } catch(Exception e) {
                response = new RecordLockResponse(e.getMessage(), null);
            }
            return response;
        }
    }

    public class RecordLockResponse {

        @InvocableVariable(label='Operation Result')
        public Boolean isSuccess;

        @InvocableVariable(label='Errors')
        public List<RecordLockError> errors;

        public RecordLockResponse(List<Approval.LockResult> lockResults) {
            this.errors = new List<RecordLockError>();
            for (Approval.LockResult lockResult : lockResults) {
                if (!lockResult.isSuccess()) {
                    this.errors.add(new RecordLockError(
                        lockResult.getErrors()[0].getMessage(), 
                        lockResult.getId())
                    );
                }
            }
            this.isSuccess = this.errors.isEmpty();
        }

        public RecordLockResponse(List<Approval.UnlockResult> unlockResults) {
            this.errors = new List<RecordLockError>();
            for (Approval.UnlockResult unlockResult : unlockResults) {
                if (!unlockResult.isSuccess()) {
                    this.errors.add(new RecordLockError(
                        unlockResult.getErrors()[0].getMessage(), 
                        unlockResult.getId())
                    );
                }
            }
            this.isSuccess = this.errors.isEmpty();
        }

        public RecordLockResponse(String errorMessage, Id recordId) {
            this.isSuccess = false;
            this.errors = new List<RecordLockError> {new RecordLockError(errorMessage, recordId)};
        } 
    }

    public class RecordLockError {
        
        @InvocableVariable(label='Error Message')
        public String message;

        @InvocableVariable(label='Record Id')
        public String recordId;

        public RecordLockError(String message, String recordId) {
            this.message = message;
            this.recordId = recordId;
        }
    }
}