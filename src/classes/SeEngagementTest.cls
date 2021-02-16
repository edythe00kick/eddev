@isTest
public class SeEngagementTest {
    
    //Need to create Account, Contact, Opportunity, SE Engagement, then make sure that the SE Engagement Owner
    //is added to Opportunity as an opportunity team owner with read/write access and role 'SE Engagement Rep'
    static testMethod void testOpportunityTeamMemberCreation()
    {
        //Create Account
        Account acc = OrgWideTestUtil.createAccount(true);
        //Create Contact
        Contact cont = OrgWideTestUtil.createContact(true,acc.Id);

        List<Opportunity> opps = new List<Opportunity>();
        //Create Opp
        Opportunity opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp.Primary_Contact__c = cont.Id;
        opps.add(opp);

        Opportunity opp2 = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp2.Primary_Contact__c = cont.Id;
        opps.add(opp2);

        insert opps;

        //Here we create the SE Engagement and relate it to the opportunity created
        //After the SE Engagement is created, we would have to query for the opportunity and opportunity team 
        //member and make sure that the Primary SE is the owner of the SE Engagement that was newly
        //created and make sure the opportunity team member was created and popualated with the correct values.
        SE_Engagement__c engagement = new SE_Engagement__c();

        engagement.Opportunity__c = opp.Id;
        insert engagement;


        test.StartTest();

        //Opportunity oppo = [Select Id, Name, Sales_Engineer_LookUp__c, (Select OpportunityId, UserId, TeamMemberRole, OpportunityAccessLevel From OpportunityTeamMembers) From Opportunity Where Id = '0064400000nxs9h'];
        OpportunityTeamMember otm = [Select OpportunityId, UserId, TeamMemberRole, OpportunityAccessLevel, Opportunity.Sales_Engineer_LookUp__c From OpportunityTeamMember Where OpportunityId =: opp.Id ];
        System.debug('Opportunity Team Member ' + otm);

        SE_Engagement__c seEngagement = [Select OwnerId From SE_Engagement__c Where Id =: engagement.Id];


        //Check to see if the all correct values where assigned to the newly created Opportunity Team Member as well as the Primary Sales Engineer
     //   System.assertEquals(seEngagement.OwnerId, otm.Opportunity.Sales_Engineer_LookUp__c);
        System.assertEquals('SE Engagement Rep', otm.TeamMemberRole);
        System.assertEquals(seEngagement.OwnerId, otm.UserId);
        System.assertEquals('All', otm.OpportunityAccessLevel);

        //Now update that SE Engagement to a different Opportunity to test the AfterUpdate part of the code
        seEngagement.Opportunity__c = opp2.Id;
        update seEngagement;

        OpportunityTeamMember otm2 = [Select OpportunityId, UserId, TeamMemberRole, OpportunityAccessLevel, Opportunity.Sales_Engineer_LookUp__c From OpportunityTeamMember Where OpportunityId =: opp2.Id ];
       // System.assertEquals(seEngagement.OwnerId, otm2.Opportunity.Sales_Engineer_LookUp__c);
        System.assertEquals('SE Engagement Rep', otm2.TeamMemberRole);
        System.assertEquals(seEngagement.OwnerId, otm2.UserId);
        System.assertEquals('All', otm2.OpportunityAccessLevel);

        test.StopTest();

    }

}