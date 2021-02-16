global without sharing class CheckPartnersforOpportunity{
    
   @InvocableMethod
    public static List<String> findPartners(List<String> oppIds) {
      List<String> partnerIdList = new List<String>();
      system.debug('oppIds==>'+oppIds);
      if(oppIds != NULL && oppIds.size() > 0){ 
            String referrer = System.Label.Referrer; 

            Set<String> referrerValues = new Set<String>();
            for(String r : referrer.split(',')) 
            {
                referrerValues.add(r);
            }   

          List <Partner>partnerList = [select id,opportunityid,role from Partner where opportunityId in: oppIds AND (Role = 'Value Added Reseller' OR Role = 'Deal Influencer' OR Role IN : referrerValues) limit 1];
          if(partnerList.size() > 0){
              partnerIdList.add(partnerList[0].id);
          }
      }
      system.debug('partnerIdList==>'+partnerIdList);
      return partnerIdList;
      
   }
   
    /*@InvocableMethod
    public static List<Partner> findPartners(List<String> oppIds) {
      List<Partner> partnerList = new List<Partner>();
      
      if(oppIds != NULL && oppIds.size() > 0){    
          partnerList = [select id,opportunityid,role from Partner where opportunityId in: oppIds AND (Role = 'Value Added Reseller' OR Role = 'Deal Influencer' OR Role = 'Referrer') limit 1];
      }
      return partnerList;
      
   }*/
}