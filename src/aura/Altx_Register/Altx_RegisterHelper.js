({
    CreateRecord : function(component) {
        var record = component.get("v.Lead");
        var loadDiv = component.find('pleaseWaitBlock');
        console.log('Lead is ', record);
        var action = component.get("c.save");
        action.setParams({myLead:record});
        action.setCallback(this, function(a){
            if(component.isValid() && a.getState().toLowerCase() == 'success'){
                var result = a.getReturnValue();
                if(result!='' && result!=null){
                    component.set("v.validationMsgOnRegistration", result);
                    $A.util.addClass(loadDiv, 'hidePleaseWaitBlock');
                    document.getElementById('confirmBox').classList.add('slds-hide');
                    document.getElementById('confirmBox').classList.remove('slds-fade-in-open');
                    document.getElementById('backdrop').classList.add('slds-hide');
                    document.getElementById('backdrop').classList.remove('slds-backdrop_open');
                }
                if(result=='' || result == null){
                    $A.util.addClass(loadDiv, 'hidePleaseWaitBlock');
                    component.set("v.Lead.FirstName", "");
                    component.set("v.Lead.LastName", "");
                    component.set("v.Lead.Email", "");
                    component.set("v.Lead.Country", "");
                    component.set("v.Lead.Phone", "");
                    component.set("v.Lead.Company", "");
                    component.set("v.Lead.State", "");
                    component.set("v.Lead.City", "");
                    component.set("v.Lead.PostalCode", "");
                    //component.set("v.validationMsgOnRegistration", "");
                    //component.set("v.validationMsgOnRegistration", result);
                    document.getElementById('confirmBox').classList.remove('slds-hide');
                    document.getElementById('backdrop').classList.remove('slds-hide');   
			        document.getElementById('confirmBox').classList.add('slds-fade-in-open');
        			document.getElementById('backdrop').classList.add('slds-backdrop_open');
                    //window.location='/AlteryxPartner/s/login';
                }
            }
        });
        $A.enqueueAction(action);
    }    
})