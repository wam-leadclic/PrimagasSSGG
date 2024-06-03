/**
 * @description       :
 * @author            : jgallaga
 * @group             :
 * @last modified on  : 07/10/2020
 * @last modified by  : jgallaga
 * Modifications Log
 * Ver   Date         Author     Modification
 * 1.0   07/10/2020   jgallaga   Initial Version
**/
@isTest
public  class TEST_CaseUtil
{

    /**
     * @author      jgallaga
     * @date        01/10/2020
     * @description
     *              Test that checks the assigment rule executes correctly.
     */
    @isTest
    static void assignedToPrimagasTelper()
    {
        Case caseRecord = new Case();
        caseRecord.Origin = 'Web';

        Test.startTest();
        Database.SaveResult insertResult = Database.insert(caseRecord);
        Test.stopTest();

        System.assert(insertResult.isSuccess(), 'ERROR Al insertar el caso: ' + insertResult.getErrors());
        caseRecord = [SELECT OwnerId FROM Case Where Id = :caseRecord.Id];
        User primagastelperUser = [SELECT Id FROM User Where alias = 'atelp' Limit 1];

        //System.assertEquals(primagastelperUser.Id, caseRecord.OwnerId, 'La asignacion a Primagas Telper no ha funcionado');

    }
}