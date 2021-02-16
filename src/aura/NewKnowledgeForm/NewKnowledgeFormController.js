/**
 * Created by csalgado on 12/17/2019.
 */

({
    doInit : function (component, event, helper) {
        //Get Record Id
        let recordId = component.get("v.parentRecordId");
        //Get Apex class
        let getCase = component.get("c.getCase");
        //Set Parameters
        getCase.setParams({
            recordId : recordId
        });
        //Set Callback
        getCase.setCallback(this, function (response) {
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");

            if(state === "SUCCESS"){
                let currentCase = response.getReturnValue();
                component.set("v.currentCase", currentCase);
                let newKnowledge = {
                    Title: '',
                    UrlName: '',
                    Summary: currentCase.Close_Comments__c,
                    Environment_Details__c: currentCase.Description
                };
                component.set("v.newKnowledge", newKnowledge);
                console.log("SUCCESS" + this.recordId + response.getReturnValue());

                //** DEBUG TOAST **
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Case Query has been returned successfully."
                });
                //toastEvent.fire();
                //** END **
            }
            else if(state === "ERROR"){
                let error = response.getError();
                console.log("ERROR" + error);

                //** DEBUG TOAST **
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "The Case Query has failed."
                });
                toastEvent.fire();
                //** END **
            }
        });

        $A.enqueueAction(getCase);
    },

    createKnowledge : function (component, event, helper) {
        //Set the Knowledge Label
        let currentLabels = component.get("v.currentLabels");
        component.set("v.newKnowledge.Community_Labels__c", currentLabels.join(';'));

        //Get new Knowledge
        let newKnowledge = component.get("v.newKnowledge");
        console.log("Create Knowledge: " + JSON.stringify(newKnowledge));

        //Validate the Input
        //****

        //Add Case Id to Knowledge
        newKnowledge.Origin_Case__c = component.get("v.parentRecordId");

        //Get Apex class
        let action = component.get("c.insertKnowledge");
        //Set Parameters
        action.setParams({
            know: newKnowledge
        });
        //Set Callback
        action.setCallback(this, function (response) {
            let state = response.getState();
            let value = response.getReturnValue();
            console.log('Value :' + JSON.stringify(value));
            let toastEvent = $A.get("e.force:showToast");

            //if (state === "SUCCESS" && typeof(value) === 'object' && Object.entries(value).length !== 0) {
            if (state === "SUCCESS" && value === 'Success') {
                //component.set("v.newKnowledge", response.getReturnValue());
                console.log("SUCCESS" + JSON.stringify(value));

                //** DEBUG TOAST **
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Knowledge Article has been inserted successfully."
                });
                toastEvent.fire();
                //** END **

                //FIRE EVENT
                let fireEvent = component.getEvent("insertKnowledgeSuccess");
                fireEvent.setParams({"success": true});
                fireEvent.fire();

            //} else if (typeof(value) === 'object' && Object.entries(value).length === 0) {
            } else if (value === 'Duplicate') {

                //** DEBUG TOAST **
                toastEvent.setParams({
                    "title": "Duplicate Error!",
                    "message": "The Knowledge URL already exists."
                });
                toastEvent.fire();
                //** END **
            } else if (value === 'Missing Field') {

                 //** DEBUG TOAST **
                 toastEvent.setParams({
                    "title": "Missing Field Error!",
                    "message": "All fields are required."
                 });
                 toastEvent.fire();
                 //** END **
            } else if(value === 'Invalid'){

                 //** DEBUG TOAST **
                 toastEvent.setParams({
                    "title": "Invalid Character in URL Name field!",
                    "message": "Only alphanumeric characters and hyphens allowed in URL."
                 });
                 toastEvent.fire();
                 //** END **
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.log("ERROR " + errors[0].message);

                //** DEBUG TOAST **
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "The Knowledge Article insert has failed."
                });
                toastEvent.fire();
                //** END **
            } else {
                console.log('Error: no return value')
            }
        });
        //Queue Action
        $A.enqueueAction(action);
    },

    getTitle : function (component, event, helper) {
        let currentTitle = component.find("titleInput").get("v.value");
        let currentUrl = component.find("urlInput").get("v.value");

        //Check if URL is currently blank
        if(currentUrl === "") {
            currentTitle = currentTitle.replace(/ /g,"-");
            component.find("urlInput").set("v.value", currentTitle);
        }
    },

    setDependentPicklist : function (component, event, helper) {
        console.log('In setDependentPicklist');
        let communityBoard = component.find("khorosBoard").get("v.value");
        let controllingField = component.get("v.controllingFieldAPI");
        let dependentField = component.get("v.dependentFieldAPI");

        //Get Apex class
        let action = component.get("c.getFieldDependencyMap");
        //Set Parameters
        action.setParams({
            communityBoard: communityBoard,
            controllingField: controllingField,
            dependentField: dependentField
        });
        //Set Callback
        action.setCallback(this, function (response) {
            let state = response.getState();
            let value = response.getReturnValue();

            if(state === "SUCCESS") {
                component.set("v.disableDualListBox", false);
                //component.set("v.labelOptions", value);
                let labelList = [];
                for(let i = 0; i< value.length; i++){
                    let item = {};
                    item["label"] = value[i];
                    item["value"] = value[i];
                    labelList.push(item)
                }
                component.set("v.labelOptions", labelList);
            }
            else{
                console.log('ERROR - Labels get failed')
            }
        });
        //Queue Action
        $A.enqueueAction(action);
    }
});