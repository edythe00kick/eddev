({
    doInit : function(component, event, helper) {
        var action = component.get("c.createNewAgileWork");
        action.setParams({
            "caseId" : component.get('v.recordId') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var message = response.getReturnValue();
                if (message != '0') {
                    alert('Error: ' + message);
                } else {
                    $A.get('e.force:refreshView').fire();
                }
            }
         });

        $A.enqueueAction(action);
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner  
        component.set("v.spinner", false);
    }
})