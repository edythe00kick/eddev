({
    doInit : function(component, event, helper) {
        var action = component.get("c.getPartnerId");
        action.setCallback(this, function(a){
            var result = a.getReturnValue();
            component.set("v.currentUser", result);
            component.set("v.partnerName", result.Contact.Name);
            component.set("v.partnerId", result.ContactId);
        });
        $A.enqueueAction(action);
    },
    generateUrl : function(component, event, helper) {
        var finalurl ='';
        var regExpEmailformat = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/; 
        var partnerId = component.get("v.partnerId");
        if(partnerId != '' && partnerId !=null){
            partnerId = partnerId.replace('&', '%26amp%3B');
        }
        var partnerName = component.get("v.partnerName");
        var pageUrl = component.get("v.pageUrl").toLowerCase();
        if(pageUrl == '' || partnerName ==''){
            component.set("v.requiredUrl", "Please Fill The Required Fields (*)");
        }
        else{
            component.set("v.requiredUrl", "");            
            if(! pageUrl.match(regExpEmailformat)){
                component.set('v.validUrl','Please Enter Valid Url');
            }else{
                component.set('v.validUrl','');
                partnerName = partnerName.replace('&', '%26amp%3B');
                partnerName = partnerName.replace(',', '%2C');
                partnerName = partnerName.replace(/ /g, '_').toLowerCase();
                if(pageUrl.indexOf('?') > -1){
                    finalurl =   pageUrl + '&utm_source=partner_generated&utm_medium=' + partnerName + '&prid=' + partnerId + '&crp=' + partnerId;
                }else{
                    finalurl =   pageUrl + '?utm_source=partner_generated&utm_medium=' + partnerName + '&prid=' + partnerId + '&crp=' + partnerId;
                }
            }
        }
        component.set("v.finalUrl", finalurl);
    },
    copyText : function(component, event, helper) {
        document.getElementById("urlField").select();
         document.execCommand("Copy");
    }
})