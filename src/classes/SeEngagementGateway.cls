public class SeEngagementGateway {

    //Author: Sergio Flores
    //Date: 10-12-2018
    //Work: W-010107
    public static void createOpportunityTeamMember(List<SE_Engagement__c> engagmentList)
    {
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
        OpportunityTeamMember oppTeamMember;
        
        //Create map of Opportunities to Engagments Owner
        Map<Id, Id> opportunityToEngagmentOwnerMap = new Map<Id, Id>();
        
        for(SE_Engagement__c engagment : engagmentList)
        {
            
            if(engagment.Opportunity__c != null)
            {
                system.debug('Inside Opportunity Share');
                
                opportunityToEngagmentOwnerMap.put(engagment.Opportunity__c, engagment.OwnerId);
                system.debug('opportunityToEngagmentOwnerMap ' + opportunityToEngagmentOwnerMap);
                
                oppTeamMember = new OpportunityTeamMember();
                oppTeamMember.OpportunityId = engagment.Opportunity__c;
                oppTeamMember.OpportunityAccessLevel = 'edit'; 
                oppTeamMember.UserId = engagment.OwnerId;
                oppTeamMember.TeamMemberRole = 'SE Engagement Rep';
                oppTeamMember.Opportunity_Owner__c = null;
                
                //Add Each member to the list
                oppTeamMemberList.add(oppTeamMember);
            }
        }
        
        //Here we want to the opportunities that relate to the engagments
        //Commented By: Sharma Nemani | W-012840 | Case: 00295058 | Date: 08/20/2019 -- > START
      /*  List<Opportunity> opportunities = [Select Id, Sales_Engineer_LookUp__c From Opportunity Where Id IN : opportunityToEngagmentOwnerMap.keySet()];
        List<Opportunity> opportunitiesToUpdateList = new List<Opportunity>();
        
        //For every opportunity, check to see if they have a missing Sales Engineer, if they do then update the opportunity with the engagement owner, in a bulk load,
        //only the first engagement owner will be populated, once the opportunity has a Sales Engineer, then nothing else should happen.
        for(Opportunity opp : opportunities)
        {
            if(opp.Sales_Engineer_LookUp__c ==null)
            {
                system.debug('Inside Sales Engineer Opp Update');
                Id engagmentOwner = opportunityToEngagmentOwnerMap.get(opp.Id);
                opp.Sales_Engineer_LookUp__c = engagmentOwner;
                opportunitiesToUpdateList.add(opp);
            }
        }
       */  //Commented By: Sharma Nemani | W-012840 | Case: 00295058 | Date: 08/20/2019 -- > END
        try
        {
            //Add the opportunityTeamMember
            Database.insert(oppTeamMemberList,false);
            //Update the opportunities with SE Owner.
          //  Database.update(opportunitiesToUpdateList,false); Commented By: Sharma Nemani | W-012840 | Case: 00295058 | Date: 08/20/2019
        }
        catch(Exception ex) 
        {
            system.debug('inside catch exception');
            trigger.new[0].addError(ex.getMessage());
        }
    }

}