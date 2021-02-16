/* Author: Sharma Nemani | W-011959
 * Date: 05/14/2019
 * Description: This class creates Rip & Replace Opportunity from Contract and creates new Junction Object
 * records (Related Contracts) .
*/
global class RipAndReplaceCtrl { 
    webservice static String createNewOpportunity(String contractId,String oppId) {
        //Restricting the 'Rip&Replace" button to all other users other than Deal Desk users.
        Profile prf =    [select Name from profile where id =:userinfo.getProfileId()];
        if(!Test.isRunningTest() && !(prf.Name.equalsignorecase('Alteryx - Sales - Deal Desk') || prf.Name.equalsignorecase('System Administrator'))){
            return 'You are not allowed to create Rip & Replace Opportunity';
        }
        List<Opportunity> opp = [select id,name from Opportunity where Id =:oppId];
        
        if(opp.size() == 0){
            return 'There is no opportunity associated with the contract';
        }
        Contract contract = [select enddate, Status, SBQQ__RenewalOpportunity__c  from Contract where id =:contractId];
        
        if(contract.Status == 'Terminated'){
            return 'Cannot create Rip & Replace Opportunity on a Terminated Contract';
        }
        Opportunity oppToCreate = new Opportunity();
        oppToCreate.Name = opp[0].Name+' (Rip & Replace)';
        oppToCreate.ContractId  = contractId;
        oppToCreate.Type = 'NBEC';
        oppToCreate.stageName = '1 - Demo';
        oppToCreate.closedate = Test.isRunningTest()?system.today():contract.enddate;
        Savepoint sp = Database.setSavepoint();	
        
        try{
            insert oppToCreate;
            createJunctionObject(oppToCreate.Id,contractId);
            return oppToCreate.Id;
        }catch(Exception ee){
            Database.rollback(sp);
            return ee.getMessage();
        }
    } //Creating Related Contracts (Junction Object)
    public static void createJunctionObject(Id oppId,Id contractId){
        Related_Contract__c  rc = new Related_Contract__c();
        rc.Contract__c  = contractId;
        rc.Opportunity__c  = oppId;
		insert rc;
    }  
}