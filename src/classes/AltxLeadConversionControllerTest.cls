@isTest public class AltxLeadConversionControllerTest {
    
    public static testMethod void getLeadTest(){
        Profile profileId = [SELECT Id FROM Profile Limit 1]; 
        User u = new User(Alias = '9a8d0j', Email='956478test@altrrrrr.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = profileId.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='956478test@altrrrrr.com');
        
        insert u;
        List<Lead> leadList = new List<Lead>();
        for(integer i=0; i<=5; i++){
            Lead lead = new Lead();
            lead.LastName='test'+i;
            lead.Company='test company'+i;
            lead.OwnerId=u.Id;
            leadList.add(lead);
        }
        
        insert leadList;
        AltxLeadConversionController.getstringOfName(leadList[0].Id);
    }
}