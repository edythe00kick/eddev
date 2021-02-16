/* Author: Sharma Nemani | W-013090 | Case: 00293335 
 * Date: 09/11/2019
 * Description: This JS Controller is part of 'CustomCaseCloseComponent.cmp'
 */
({
	doInit : function(component, event, helper) {
		var action = component.get("c.isValidUser");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                if(response.getReturnValue() == true){
                    helper.showCaseInfo(component, event);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'You are not allowed to view this component.',
                        type : 'warning',
                        title:'Warning'
                    });
                    toastEvent.fire();
                }
            }
        });       
        $A.enqueueAction(action);
	},
    changeCaseCategeory : function(component, event, helper) {
        var allCC = JSON.parse(component.get("v.caseCat"));
        var cc = component.get("v.caseRec.Case_Category__c");
        if(cc == 'Choose'){
            component.set("v.caseReason",[]);
            return;
        }
        for(var i=0;i<allCC.length;i++){
            //alert(allCC[i].ccName);
            if(allCC[i].ccName == cc){
				//alert(allCC[i].caseReason); 
                component.set("v.caseReason",allCC[i].caseReason);
            }
        }
    },
    save : function(component, event, helper) { 
        var action = component.get("c.saveCase");
        action.setParams({cse:component.get("v.caseRec")});// component.get("v.recordId")
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS' && response.getReturnValue() == 'success'){
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissible',
                    message: 'Case updated',
                    type : 'success',
                    duration:5000,
                    title:'Info Message'
                });
                toastEvent.fire();
            }else{
                alert(response.getReturnValue());
            }
        });       
        $A.enqueueAction(action);                                
    },
    handleKeyUp : function(component, event, helper) {
        var kw = component.find("enter-search");
        console.log(kw);
        if(kw.get("v.value")==null || kw.get("v.value")=='' || kw.get("v.value")==undefined){
			component.set("v.acc",null);
            return;
        }
        var action = component.get("c.searchAcc");
        action.setParams({accName:kw.get("v.value")});// component.get("v.recordId")
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                component.set("v.acc",response.getReturnValue());
            }else{
                alert(response.getReturnValue());
            }
        });       
        $A.enqueueAction(action);  
    },
    selectedAcc : function(component, event, helper) {
        var rectarget = event.currentTarget;
        var idstr = rectarget.getAttribute("data-id");
        component.set("v.caseRec.AccountId",idstr);
        component.find("enter-search").set("v.value",rectarget.getAttribute("data-name"));
        component.set("v.acc",null);
        //alert(idstr);
    }
})