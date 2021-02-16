@isTest public class Altx_ChatterFeedControllerTest {
    
    public static testMethod void getUserProfileTest(){
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=0; i<=5; i++){
            Opportunity opp = new Opportunity();
            opp.Name='test oppo';
            opp.StageName='Closed';
            opp.CloseDate=system.today();
            oppList.add(opp);
        }        
        insert oppList;
        Altx_ChatterFeedController.getUserProfileInfo(oppList[0].Id);
    }
}