//Author: Sharma Nemani | W-013035 | Case:00296706 | Date: 09/06/2019
//Description: This Controller Class is used in 'SpecialCaseComponent'.
public class SpecialCaseComponentCtrl { 

    @AuraEnabled
    public static Case retrunCase(Id caseId){ //ACE 
		
        return [select id, Contact_Role__c  from case where Id =:caseId];
    }
}