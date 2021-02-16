({
	doInit : function(component, event, helper) {
        var action = component.get("c.CreateChangeControl");
        component.set("v.isVisible", false);
        action.setParams({
            "releaseId" : component.get('v.recordId') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var message = response.getReturnValue();
                if (message != null && message != '0') {
                    debugger;
                    component.set("v.spinner", false);
                    alert('Error: ' + message);
                    component.set("v.closeComp",true);
                } else {
                   component.set("v.closeComp",true);
                   $A.get('e.force:refreshView').fire(); 
                }
            }
         });
        $A.enqueueAction(action);
    },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner  
        component.set("v.spinner", false);
    },
    doneRendering: function(component, event, helper) {
        var spinnerVal = component.get("v.closeComp");
        if(spinnerVal== true) {
        	$A.get("e.force:closeQuickAction").fire();
        }
    }
})