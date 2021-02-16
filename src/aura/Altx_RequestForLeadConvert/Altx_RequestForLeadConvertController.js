({
	doInit : function(component, event, helper) {
		console.log('hello');
        var leadId = component.get("v.recordId");
        var action= component.get("c.getstringOfName");
        action.setParams({
            "LeadId" : leadId
        });
        action.setCallback(this,function(a){
            var result = a.getReturnValue();
            console.log('result  ',result);
        });
        $A.enqueueAction(action);
	}
    
})