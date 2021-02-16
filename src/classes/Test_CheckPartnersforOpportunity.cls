@isTest
public class Test_CheckPartnersforOpportunity{


public static testMethod void testPartnersforOpportunity(){
     List<Account> accList = new List<Account>();
     Account ac = new Account();
     ac.Name = 'NewComp';
     accList.add(ac);
     
     Account acc = new Account();
     acc.Name = 'NewComp';
     accList.add(acc);
     
     insert accList;
     
     Opportunity myOp = new Opportunity();
     myOp.accountid = accList[0].id;
     myOp.Name = 'Test Opp';
     myOp.StageName = System.label.StageName_B;
     myOp.CloseDate = Date.today() + 3;
     insert myOp;
         
     Partner prt = new Partner();
     prt.OpportunityId = myOp.Id;
     prt.Role='Deal Influencer';
     prt.accountToId=accList[1].id;
     insert prt;
     
     CheckPartnersforOpportunity.findPartners(new List<String>{myOp.id});
}

}