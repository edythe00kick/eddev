({
    hidepopup : function(component, event, helper) {
        component.set("v.lead.FirstName", "");
        component.set("v.lead.LastName", "");
        component.set("v.lead.Email", "");
        component.set("v.lead.Country", "");
        component.set("v.lead.Company", "");
        component.set("v.lead.Phone", "");
        component.set("v.validationMsgOnRegistration", "");
    },
    openLink : function(component, event, helper) {    
        console.log('testtt');
        window.open($A.get("$Label.c.IOCommunityUrlForVisualforcePage"), '_blank', 'width=800, height=500, top=50px,scrollbars=yes');
    },
    saveleadRecord : function(component, event, helper) {
        var loadDiv = component.find('pleaseWaitBlock');
        $A.util.removeClass(loadDiv, 'hidePleaseWaitBlock');
        var firstName = component.find("fname").get("v.value");
        var trimmedFirstName = firstName.trim();
        var lastName = component.find("lname").get("v.value");
        var trimmedLastName = lastName.trim();
        var Email = component.find("email").get("v.value");
        var trimmedEmail = Email.trim();
        var Company = component.find("cname").get("v.value");
        var trimmedCompany = Company.trim();
        var City = component.find("city").get("v.value");
        var trimmedCity = City.trim();
        var State = component.find("state").get("v.value");
        var trimmedState = State.trim();
        var Postalcode = component.find("postalcode").get("v.value");
        var trimmedPostalcode = Postalcode.trim();
        var PhoneNumber = component.find("phone");
        var Phone = component.find("phone").get("v.value");
        var Country = component.find("country").get("v.value");
        var trimmedCountry = Country.trim();
        var error='';
        console.log('=========>   ' + Phone);
        if (isNaN(Phone)) {
            PhoneNumber.set("v.errors", [{message:"Not a valid Phone Number: " + Phone}]);
        }
        if(trimmedFirstName == '' || trimmedLastName == '' || trimmedEmail == '' || trimmedCompany == '' || 
           	trimmedCountry=='' || trimmedCity == '' || trimmedPostalcode =='' || 
           	(Phone!='' && Phone.length < 10)){
            if(trimmedFirstName =='' || trimmedFirstName == null){
                error +='Please Enter the First Name</br>';
            }
            if(trimmedLastName =='' || trimmedLastName == null){
                error +='Please Enter the Last Name </br>';
            }
            if(trimmedCompany =='' || trimmedCompany == null){
                error +='Please Enter the Company Name </br>';
            }
            if(trimmedEmail =='' || trimmedEmail == null){
                error +='Please Enter the Email </br>';
            }                
            if(trimmedCountry =='' || trimmedCountry == null){
                error +='Please Enter a Company Name </br>';
            }
            if(trimmedCity =='' || trimmedCity == null){
                error +='Please Enter a City Name </br>';
            }
            if(trimmedPostalcode =='' || trimmedPostalcode == null){
                error +='Please Enter a Postal Code </br>';
            }
            if(Phone!='' && Phone.length < 10){
                error +='Please Enter a Valid Phone Number </br>';
            }
            component.set("v.validationMsgOnRegistration", error);            
            if(error != ''){
            	 $A.util.addClass(loadDiv, 'hidePleaseWaitBlock');
           	}
        }
        else{
            component.set("v.validationMsgOnRegistration", "");
            document.getElementById('backdrop').classList.add('slds-backdrop_open');
            document.getElementById('backdrop').classList.remove('slds-hide');
            helper.CreateRecord(component);
        }
    },
    hideModal : function(component, event, helper) {
        document.getElementById('confirmBox').classList.add('slds-hide');
        document.getElementById('confirmBox').classList.remove('slds-fade-in-open');
        document.getElementById('backdrop').classList.add('slds-hide');
        document.getElementById('backdrop').classList.remove('slds-backdrop_open'); 
        window.location = '/AlteryxPartner/s/login';
    },
    LoadStart: function(component, event, helper){
        var loadDiv = component.find('pleaseWaitBlock');
        $A.util.removeClass(loadDiv, 'hidePleaseWaitBlock');
    },
    LoadEnd: function(component, event, helper){
        var loadDiv = component.find('pleaseWaitBlock');
        $A.util.addClass(loadDiv, 'hidePleaseWaitBlock');
    }
})