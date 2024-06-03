/**
 * @description       :
 * @author            : jgallaga
 * @group             :
 * @last modified on  : 07/10/2020
 * @last modified by  : jgallaga
 * Modifications Log
 * Ver   Date         Author     Modification
 * 1.0   01/10/2020   jgallaga   Initial Version
**/
public with sharing class CaseUtil
{

    /**
     *  @author         jgallaga
     *  @date           01/10/2020
     *  @description    Obtain the Case assigment rule
     *
     */
    public static Database.DMLOptions dmlOpts
    {
        get
        {
            if(dmlOpts == null)
            {
                //Fetching the assignment rules on case
                AssignmentRule AR = new AssignmentRule();
                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true and Name = 'De Joan a Primagas Telper' limit 1];

                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                dmlOpts = new Database.DMLOptions();
                //dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            }
            return dmlOpts;
        }
        set;
    }


    /**
     * @author      jgallaga
     * @date        01/10/2020
     * @description
     *              To be able to execute the assgiment rules when a new Case is inserted with the webservice,
     *              the rule ID must be set to the record
     * @when
     *              After Insert
     */
    public static void setAssigmentRule(List<Case> newList)
    {
        if(newList != null)
        {
            List<Case> assigmentCases = new List<Case>();
            for(Case nextC : newList)
            {
                if(true) // Cambiar si hace falta meter algún filtro para que solo se haga a ciertos tipos de casos nuevos
                {
                    assigmentCases.add
                    (
                        new Case
                        (
                            id = nextC.Id
                        )
                    );
                }
            }
            //Setting the DMLOption on Case instance
            Database.update (assigmentCases,dmlOpts);
        }
    }

}