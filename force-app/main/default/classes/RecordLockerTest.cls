@isTest
public class RecordLockerTest {

    @isTest
    public static void testRecordLocking() {
        Contact contact = new Contact(
            FirstName = 'Paco',
            LastName = 'Fruta',
            Email = 'pacofruta@primagas.test'
        );
        insert contact;
        Test.startTest();
            System.assert(System.Approval.isLocked(contact.Id) == false, 'Record should be unlocked when is created.');

            RecordLocker.RecordLockRequest lockRequest = new RecordLocker.RecordLockRequest();
            lockRequest.action = 'LOCK';
            lockRequest.recordIds = new List<String> {contact.Id};
            RecordLocker.RecordLockResponse response = RecordLocker.performLockingAction(new List<RecordLocker.RecordLockRequest>{lockRequest})[0];

            System.assert(response.isSuccess, 'The locking action should be processed successfully');
            System.assert(System.Approval.isLocked(contact.Id) == true, 'Record should be locked after the locking action');

            RecordLocker.RecordLockRequest unlockRequest = new RecordLocker.RecordLockRequest();
            unlockRequest.action = 'UNLOCK';
            unlockRequest.recordIds = new List<String> {contact.Id};
            response = RecordLocker.performLockingAction(new List<RecordLocker.RecordLockRequest>{unlockRequest})[0];

            System.assert(response.isSuccess, 'The unlocking action should be processed successfully');
            System.assert(System.Approval.isLocked(contact.Id) == false, 'Record should be unlocked after the unlocking action');
        Test.stopTest();
    }
}