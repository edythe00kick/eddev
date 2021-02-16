({
    doInit: function(component, event, helper)  {
        
        var recordId = component.get("v.recordId");
        
        component.set("v.amountSelected", true);
        
        
        var subscriptionSchedules = component.get("c.getSubscriptionSchedules");
        
        subscriptionSchedules.setParams({
            recordId : recordId
        });
        
        
        subscriptionSchedules.setCallback(this,function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.subscriptionSchedulesList",response.getReturnValue());
                component.set("v.recordId", recordId);
                console.log("success" + recordId + response.getReturnValue())
                
            }
            else if(state === "error")
            {
                var error = response.getError();
                console.log("error" + error);
            }
            
        });
        
        var mainQuote = component.get("c.getQuote");
        
        mainQuote.setParams({
            recordId : recordId
        });
        
        
        mainQuote.setCallback(this,function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.mainQuote",response.getReturnValue());
                component.set("v.amountEditable",true);
                console.log("success" + recordId + response.getReturnValue())
                
            }
            else if(state === "error")
            {
                var error = response.getError();
                console.log("error" + error);
            }
            
        });
        
        $A.enqueueAction(subscriptionSchedules);
        $A.enqueueAction(mainQuote);
        
    },
    
    calculateAmount: function(component, event, helper) {
        component.set("v.validated", false);
        
        var index = event.getSource().get('v.name');
        var value = event.getSource().get('v.value');
        var mainQuote = component.get("v.mainQuote");
        var amountPercentList = component.get("v.amountPercentList");
        var percentValue;
        
        if(value == '')
            value = 0;
        
        console.log('index '+ index);
        console.log('value '+ value);
        
        
        var amountList = component.get("v.amountList");
        console.log("amountLenght" + amountList.length);
        
        console.log("before amountList " + amountList);
        
        
        
        if(amountList.length == '')
        {
            console.log("inside first");
            amountList.push(value);
            percentValue = (value/mainQuote.SBQQ__NetAmount__c);
            amountPercentList.push(percentValue);
        }
        else if(amountList.length == (index + 1 ))
        {
            console.log("inside second");
            amountList[index] = value;
			amountPercentList[index] = (amountList[index]/mainQuote.SBQQ__NetAmount__c);            
        }
        else if(amountList.length >= index)
        {
            console.log("inside third");
            amountList[index] = value;
            amountPercentList[index] = (amountList[index]/mainQuote.SBQQ__NetAmount__c);
        }
        else
        {
            console.log("inside fourth");
            amountList.push(value);
            percentValue = (value/mainQuote.SBQQ__NetAmount__c);
            amountPercentList.push(percentValue);
        }
        
        component.set("v.amountList",amountList);
        console.log("amountList after the push " + amountList);
        
        //here we add to the amountPercentList list to display the percentage of the amount
        component.set("v.amountPercentList",amountPercentList);
        console.log("amountPercentList after the push " + amountPercentList);
        
        var currentTCV = component.get("v.currentTCV");
        console.log("currentTCV before the push " + currentTCV);
        
        var total =  0;
        
        for(var i=0;i<amountList.length;i++)
        {
            total += Number.parseFloat((amountList[i]));
        }
        
        total = parseFloat(total.toFixed(2));
        
        component.set("v.currentTCV",total);
        
        var mainQuote = component.get("v.mainQuote");
        var difference = component.get("v.difference");
        
        difference = mainQuote.SBQQ__NetAmount__c - total;
        
        component.set("v.difference",difference);
        
        console.log("currentTCV after the push " + total);
        console.log("difference after the push " + difference);
        
    },
    
    calculatePercent: function(component, event, helper) {
        component.set("v.validated", false);
        
        var index = event.getSource().get('v.name');
        var value = event.getSource().get('v.value');
        
        var mainQuote = component.get("v.mainQuote");
        
        console.log('index '+ index);
        console.log('value '+ value);
        
        
        var percentList = component.get("v.percentList");
        console.log("percentList" + percentList.length);
        
        console.log("before percentList " + percentList);
        
        
        
        if(percentList.length == '')
        {
            value = mainQuote.SBQQ__NetAmount__c * (value/100);
            percentList.push(value);
        }
        else if(percentList.length == (index + 1 ))
        {
            value = mainQuote.SBQQ__NetAmount__c * (value/100);
            percentList[index] = value;            
        }
        else if(percentList.length >= index)
        {
            value = mainQuote.SBQQ__NetAmount__c * (value/100);
            percentList[index] = value;
        }
        else
        {
             value = mainQuote.SBQQ__NetAmount__c * (value/100);
             percentList.push(value);
        }
        
        component.set("v.percentList",percentList);
        component.set("v.amountEditable", false);
        console.log("percentList after the push " + percentList);
        
        var currentTCV = component.get("v.currentTCV");
        console.log("currentTCV before the push " + currentTCV);
        
        var total =  0;
        
        for(var i=0;i<percentList.length;i++)
        {
            total += Number.parseFloat((percentList[i]));
        }
        
        total = parseFloat(total.toFixed(2));
        
        component.set("v.currentTCV",total);
        
        
        var difference = component.get("v.difference");
        
        difference = mainQuote.SBQQ__NetAmount__c - total;
        
        component.set("v.difference",difference);
        
        console.log("currentTCV after the push " + total);
        console.log("difference after the push " + difference);
        
    },
    
    overrideSelected: function(component, event, helper) {
        var selectedValue = component.find("overrideSelected").get("v.value");
        
        if(selectedValue == "Amount Override")
        {
            component.set("v.amountSelected", true);
        }
        else
        {
            component.set("v.amountSelected", false);
        }
    },
    
    validate: function(component, event, helper) {
        component.set("v.errorMessage", false);
        component.set("v.oneTimePaymentError", false);
        
        var selectedValue = component.find("overrideSelected").get("v.value");
        var allValid = false;
        var list;
        
        if(selectedValue == "Amount Override")
        {           
            //Need to handle validation
            allValid = component.find('amountOverride').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
            if (!allValid) {
                component.set("v.errorMessage", true);
            }
            
            //Need to check that there are no 0 inputs
            list = component.get("v.amountList");
            for(var i=0;i<list.length;i++)
            {
                
                if(list[i] == 0)
                {
                    component.set("v.errorMessage", true);
                }
            }
            
        }
        else
        {
            //Need to handle validation
            allValid = component.find('percentOverride').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
            if (!allValid) {
                component.set("v.errorMessage", true);
            }
            
            //Need to check that there are no 0 inputs
            list = component.get("v.percentList");
            for(var i=0;i<list.length;i++)
            {
                if(list[i] == 0)
                {
                    component.set("v.errorMessage", true);
                }
            }
        }
        var quote = component.get("v.mainQuote"); 
        var difference = component.get("v.difference");
        
        if(quote.Purchase_Type__c == 'Upsell Rip & Replace' && !(quote.SBQQ__NetAmount__c >= component.get("v.currentTCV")) )
        {
            component.set("v.errorMessage", true);            
        }
        //Need to confirm that Difference = 0 except for rip and replace
        else if(difference != 0 && quote.Purchase_Type__c != 'Upsell Rip & Replace')
        {
            component.set("v.errorMessage", true);
        }
        
        if(!component.get("v.errorMessage"))
        {
            component.set("v.validated", true);
        }
        
        
        //We need to display 
        var subScheduleList = component.get("v.subscriptionSchedulesList");
        var amountList = component.get("v.amountList");
        var percentList = component.get("v.percentList");
        
        //We need to display validation rule if the first year total is less than the one time amount
        		var subScheduleList = component.get("v.subscriptionSchedulesList");
                
                if(Math.floor(amountList[0]) < Math.floor(subScheduleList[0].Non_Recurring_Total__c) )
                {
                    console.log('amountList is over non recurring ' + amountList[0] + 'sub schedule non recurring total ' + subScheduleList[0].Non_Recurring_Total__c);
                    component.set("v.oneTimePaymentError", true);
                    component.set("v.validated", false);
                    
                }
        		if ( Math.floor(percentList[0]) < Math.floor(subScheduleList[0].Non_Recurring_Total__c))
                {
                    console.log('percentList is over non recurring ' + percentList[0]+ 'sub schedule non recurring total ' + subScheduleList[0].Non_Recurring_Total__c);
                    component.set("v.oneTimePaymentError", true);
                    component.set("v.validated", false);
                }
        
        
    },
    
    cancel: function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        console.log('record id ' + recordId);
        window.location.href = '/' + recordId;
    },
    
    save: function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var selectedValue = component.find("overrideSelected").get("v.value");
        
        var list;
        
        if(selectedValue == "Amount Override")
        {
            list = component.get("v.amountList");
            for(var i=0;i<list.length;i++)
            {
                list[i] = Number.parseFloat((list[i]));
            }
        }
        else
        {
            list = component.get("v.percentList");
            
        }
        
        //Need to confirm that Difference = 0
        var difference = component.get("v.difference");
        
        
        console.log("validate list " + list);
        
        var subScheduleList = component.get("v.subscriptionSchedulesList");
        
        var updateLineItemSubSchedule = component.get("c.updateLineItemSubSchedule");
        
        updateLineItemSubSchedule.setParams({
            amountList : list,
            subSchedules: subScheduleList
        });
        
        updateLineItemSubSchedule.setCallback(this,function(response){
            console.log("State " + response.getState());
            console.log("Return Value " + response.getReturnValue());
            var state = response.getState();
            
            if (state === "SUCCESS") {
                console.log("success");
                component.set("v.saved", true);
                // 
                window.setTimeout(function(){
                    
                    // Move to a new location or you can do something else
                    window.location.href = '/' + recordId;
                    
                }, 5000);
                
            }
            else if(state === "error")
            {
                var error = response.getError();
                console.log("error" + error);
            }
            
        });
        
        $A.enqueueAction(updateLineItemSubSchedule);
        
        
    }
    
    
})