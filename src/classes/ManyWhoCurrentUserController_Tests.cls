@istest
public class ManyWhoCurrentUserController_Tests {

    private static testmethod void ManyWhoCurrentUserController() {
        ManyWhoCurrentUserController.getUserInfo();
    
        // Create a dummy manywho flow to check against        
        ManyWhoFlow__c flow = new ManyWhoFlow__c();
        flow.Name = 'Test';
        flow.JoinUri__c = 'https://flow.manywho.com?join=abcd';
        insert flow;

        ManyWhoCurrentUserController.getStateId(flow.id);
    }

}