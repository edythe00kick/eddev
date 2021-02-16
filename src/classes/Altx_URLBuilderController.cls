public class Altx_URLBuilderController {
@AuraEnabled
    public static User getPartnerId(){
        List<User> profileUser = new List<User>();
        profileUser = [select Id, ContactId, Contact.Name from User where Id = :UserInfo.getUserId() LIMIT 1];
        if(!profileUser.isEmpty()){
            return profileUser[0];
        }
        else{
            return null;
        }
    }    
}