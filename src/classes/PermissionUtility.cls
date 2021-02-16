/*
*
* @author : JP Horton <jhorton@alteryx.com>
* @description : Utility class which checks for custom permissions granted to users
* @date : 20171027
* @testclass : PermissionUtilityTest.cls
*
*/
public without sharing class PermissionUtility {
    
    /*
    * @author : JP Horton <jhorton@alteryx.com>
    * @name : checkUsersCustPerm
    * @params : String permName - Name of custom permission we are searching for
    *           Id UserId - Id of user we care about
    * @description : Utility class which checks for custom permissions granted to users
    * @date : 20171027
    */
    public static boolean checkUsersCustPerm(String permName, Id UserId){
        boolean IsAssigned = false;
        list<Id> CheckAssign = new list<Id>();
        //Grab Custom Permission ID
        list<CustomPermission> CPerm = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName =: permName LIMIT 1];

        //Find Whether a Particular User is Assigned the Custom Permission
        if(CPerm.size() > 0){
            list<SetupEntityAccess> loopList = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId =: CPerm[0].Id AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: UserId)];
            for(SetupEntityAccess S : loopList){
                CheckAssign.add(S.Id);
            }   
        }
        
    
        if(!CheckAssign.IsEmpty()){
            IsAssigned = true;
            return IsAssigned;
        }
        else{return IsAssigned;}
    }
}