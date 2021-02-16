/* Author: Sharma Nemani | W-013035 | Case: 00296706
 * Date: 09/06/2019
 * Description: This JavaScript Controller is used in "SpecialCaseComponent" Lightning Component.
 * 				This controller basically displays the toast message by fetching the Case ID that
 * 				contains Contact Role = ACE.
 */
({
	doInit : function(component, event, helper) {
		var act = component.get("c.retrunCase");
        act.setParams({"caseId":component.get("v.recordId")});
        act.setCallback(this,function(response){
            var state = response.getState(); // get the response state
            if(state == 'SUCCESS') {
                component.set('v.caseRec', response.getReturnValue());
                var msg = 'Check that template is included then assign to appropriate Resolution Team.' //+response.getReturnValue().Contact_Role__c;
                
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ACE Case",
                        "message": msg,
                        "type":"error",
                        "mode":"sticky"
                    });
                    toastEvent.fire();
                
            }
        });       
        $A.enqueueAction(act);
	}
})