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
public with sharing class CaseHandler implements ITrigger
{
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)
    {}
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)
    {}
    public void beforeInsert(list<SObject> newList)
    {}
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {}
    public void beforeDelete(map<Id,SObject> oldMap)
    {}
    public void afterInsert(list<SObject> newList)
    {
        CaseUtil.setAssigmentRule(newList);
    }
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)
    {}
    public void afterDelete(map<Id,SObject> oldMap)
    {}
    public void andFinally()
    {}
}