public class Altx_ChatterFeedController {
    @AuraEnabled
    public static string getUserProfileInfo(string recordId){
        String objectName='';
        String recordOwnerId='';
        String displayChatter='';
        String labelProfileId = System.Label.ProfileIdForChatterOnOppDetail;
        system.debug('recordId @@ '+recordId);
        string firstThreeChar = recordId.left(3);
        system.debug('firstThreeChar @@ '+firstThreeChar);
        if(firstThreeChar == '006'){
            objectName='Opportunity';
        }
        else if(firstThreeChar == '00Q'){
            objectName='Lead';
        }
        String query = 'SELECT id, ownerId FROM '+ objectName+' where id =\''+recordId+'\'';
        system.debug('query is '+query);
        List<sObject> recordList = Database.query(query);
        if(objectName =='Opportunity'){
            Opportunity opp = (Opportunity)recordList[0];
            recordOwnerId = opp.OwnerId;
        }
        if(objectName =='Lead'){
            Lead ld = (Lead)recordList[0];
            recordOwnerId=ld.OwnerId;
        }
        
        List<User> userList = [select id, Name, Profile.Name, ProfileId 
                               FROM User where id =: UserInfo.getUserId()];
        if((recordOwnerId == userList[0].Id) || (userList[0].ProfileId == labelProfileId)){
            displayChatter='Yes';
        }
        return displayChatter;
    }
}