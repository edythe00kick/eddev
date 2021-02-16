/* Author: Sharma Nemani | W-013090 | Case: 00293335 
 * Date: 09/11/2019
 * Description: This JS Helper Class is part of 'CustomCaseCloseComponent.cmp'
 */
({
	showCaseInfo : function(component, event) {
        var action = component.get("c.caseInfoToShow"); //"50018000009hCz2AAE"
        action.setParams({caseId:component.get("v.recordId")});// component.get("v.recordId")
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                 //alert(response.getReturnValue().caseType); 
                component.set("v.caseToBeClosed",response.getReturnValue());
                response.getReturnValue().cse.Products__c = 'Non - Product';
                component.set("v.caseRec",response.getReturnValue().cse);
                
                component.set("v.caseCat",JSON.stringify(response.getReturnValue().lstCaseCateGeory));
            }
        });       
        $A.enqueueAction(action);
	}
})