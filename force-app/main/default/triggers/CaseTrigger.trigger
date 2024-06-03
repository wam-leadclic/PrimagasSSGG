/**
 * @description       : 
 * @author            : jgallaga
 * @group             : 
 * @last modified on  : 01/10/2020
 * @last modified by  : jgallaga
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   01/10/2020   jgallaga   Initial Version
**/
trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.createHandler(Case.sObjectType);
}