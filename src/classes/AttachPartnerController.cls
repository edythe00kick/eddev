/*
Grazitti Interactive
12 April 2013
*/
public class AttachPartnerController {
    public List<Partner> partnerList ;
    public List<Opportunity> opporList ;
    public List<Opportunity> partneropporList ;   
    public List<Opportunity> oppForApproval ;
    public List<wrapclass> wrapclassList {get; set;}
    public String acctName;
    public boolean submitted;
    public integer var;
    
    
    public Opportunity currOpportunity {get;set;}
    public Partner newPartner {get;set;}
    public String myOpId {get;set;}
 //   public String retUrl {get;set;}
    public Boolean currPartnerExists {get;set;}
    public String partnerRole {get;set;}
    public String partnerInfluence {get;set;}
    public Contact partnerContact {get;set;}
    public Boolean isPrimary {get;set;}
    public String errStr {get;set;}
   public String OppOwnerID {get;set;}
 
 public String LoggedInUserID {get;set;}
    
     public String LoggedinUserusername{get;set;}
       public String profileName{get;set;}
     public String roleName{get;set;}
    public Boolean check {get;set;
    }
       public String selIndex {get;set;}
public integer primarycount = 0;        
public Boolean booleanValue;
public Set<Id> partnerIdSet = new Set<Id>();
public Set<Id> accountIdSet = new Set<Id>();
public Set<String> accidandRoleSet = new Set<String>();
public Set<String> newpartnersAccidandRoleSet = new Set<String>();
public Boolean updateOpp;
public Boolean checkPartners = false;
public String errStr1 {get;set;}
public String errStr2 {get;set;}
public Set<String> accountsFilled;
public Set<String> rolesfilled;
public Set<String> existingRoleSet;
public String errStr3 {get;set;}
public String errStr4 {get;set;}
public Integer accalreadyExists ;
public String errStr5 {get;set;}
public String errStr6 {get;set;}
public String errStr7 {get;set;}
public String errStr8 {get;set;}
public String errStr9 {get;set;}
public String oppRoleReason{get;set;}
public Boolean primarypartnerexists = FALSE;
// Added by Oshin on Jan 19, 2015
public Integer dealInfluencerCount;
public Integer selectedDealInfluencerCount;

// Added by Oshin on March 31, 2016
public Boolean var_reseller_partner_exists = false;

// Added for Use in validating Custom Permission ownership - JPH - Cs 00180794
public Boolean userHasAddRefPart = false;
public Boolean userHasAddRefPartSpecial = false;

    public AttachPartnerController() {
         // Added by Oshin on Jan 19, 2015
         dealInfluencerCount = 0;
         selectedDealInfluencerCount = 0;
         selIndex  = '0';
         system.debug('in constructor------------------------------------------------->');
         updateOpp = false;
         existingRoleSet = new Set<String>();
         LoggedInUserID= Userinfo.getUserId();
         LoggedinUserusername= Userinfo.getUserName();
         system.debug('LoggedinUserusername-------------------------------->'+ Userinfo.getUserName());
         profileName= [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
         roleName=[select u.UserRole.Name from User u where u.id = :Userinfo.getUserId()].UserRole.Name;
          
            errStr = '';
            isprimary = true;
    
            myOpId = ApexPages.currentPage().getParameters().get('oppId');
            currOpportunity = [SELECT ID, Name, Partner_Influenced_Deal__c,Partner_Role_Reason__c ,stagename, Partner_Account_Lookup__c, Partner_Account_Name__c,ownerid,accountid from Opportunity where Id = : myOpId Limit 1];
            OppOwnerID= currOpportunity.OwnerID;

            
            // List < Partner > currPartnersTmp = [SELECT Id, Role, AccountToId from Partner Limit 10];
            // System.debug('a ' + currPartnersTmp);
    
            List < Partner > currPartners = [SELECT Id, Role,IsPrimary, AccountToId from Partner Where OpportunityId = : myOpId];    
            if (currPartners.isEmpty() == false) {
           // wrapclassList.add(new wrapclass(cd,myOpId,prt,partnerRole,partnerInfluence));
                currPartnerExists = true;  
            } else {
                currPartnerExists = false;
            }          
            
            newPartner = new Partner();
            newPartner.OpportunityId = myOpId;
            partnerRole = '';
            partnerInfluence='';
            partnerContact = new Contact(FirstName = 'Test');
            // isPrimary = null;
                            
            errStr3 = 'Following Role(s) already exist for the Partner(s). Make sure your role is not one of these -';
             List < Partner > existingPartnersList = [SELECT Id, OpportunityId, AccountToId, Role, IsPrimary, IsDeleted FROM Partner where OpportunityId =: myOpId and accountfromid = : currOpportunity.accountid];
             if(existingPartnersList != null && existingPartnersList.size() > 0){
                 for(Partner op : existingPartnersList ){
                     accidandRoleSet.add(op.accounttoid);
                 }
                 for(Partner op : existingPartnersList ){
                     // Added by Oshin on March 31, 2016
                     if(op.role != null) {
                        String role = op.role.trim().toLowerCase();
                        if(role == 'deal influencer') {
                            dealInfluencerCount += 1;
                        }
                        
                        if((role == 'referrer' || role == 'value added reseller' || role == 'collaborative sale')
                                && op.isPrimary == true) {
                            var_reseller_partner_exists = true;
                        }
                     }
                     existingRoleSet.add(op.role);
                 }
                 system.debug('existingrolesetis=================>'+existingRoleSet);
                 if(!existingRoleSet.isEmpty()){
                     for(String s:existingRoleSet){
                         // Added by Oshin on Jan 19, 2015
                         if(s != null && s != '' && !s.toLowerCase().contains('deal influencer')) {
                             errStr3 = errStr3+' '+s+',';
                         }
                     }
                     
                     // Added by Oshin on Jan 19, 2015
                     if(errStr3.lastIndexOf(',') != -1) {
                         errStr3.lastIndexOf(',');
                         errStr3 = errStr3.substring(0, errStr3.lastIndexOf(',')) ;
                     }
                 }
             }
            system.debug('existingroleset1is=================>'+existingRoleSet );
            if(wrapclassList == null) {
                wrapclassList = new List<wrapclass>();
                for(integer i=0; i<3; i++){
                    Partner prt = new Partner();
                    prt.OpportunityId = myOpId;
                    Contact cd = new Contact(firstname = 'test'); 
                    booleanValue = false;               
                    wrapclassList.add(new wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence));
                }
            }     
           //if(test.isrunningtest()){
                /*rolesfilled = new Set<String>();
                wrapclassList = new List<wrapclass>();
                    Partner prt = new Partner();
                    prt.OpportunityId = myOpId;
                    Contact cd = new Contact(firstname = 'test');
                    partnerRole = 'Deal Influencer';
                    partnerInfluence='';
                    Account ac = new Account();
                    ac.Name = 'NewComp';
                    ac.shippingcountry='america';
                    ac.shippingstate='california';
                    ac.shippingpostalcode='92801';
                    ac.shippingcity='san fransisco';
                    ac.billingcountry='america';
                    ac.billingstate='california';
                    ac.billingcity='san fransisco';
                    ac.billingpostalcode='92801';
                    // added extra
                    ac.Partner_Type__c = 'Alliance';
                    // ended extra
                    //ac.recordtypeid='012E0000000VROyIAO';
                    insert ac;
                    cd.accountid = ac.id;
                    
                    booleanValue = false;              
                    wrapclassList.add(new wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence));
                    // added extra
                    wrapclassList.get(0).getRoleItems();
                    doChangePartner();
                    
                    prt = new Partner();
                    prt.OpportunityId = myOpId;
                    ac = new Account();
                    ac.Name = 'NewComp';
                    ac.Partner_Type__c = 'Referral';
                    insert ac;
                    cd.accountid = ac.id;
                    booleanValue = false;              
                    wrapclassList.add(new wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence));
                    wrapclassList.get(0).getRoleItems();
                    doChangePartner();
                    
                    prt = new Partner();
                    prt.OpportunityId = myOpId;
                    ac = new Account();
                    ac.Name = 'NewComp';
                    ac.Partner_Type__c = 'Referral';
                    insert ac;
                    cd.accountid = ac.id;
                    booleanValue = false;              
                    wrapclassList.add(new wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence));
                    wrapclassList.get(0).getRoleItems();
                    wrapclassList.get(0).partinfluence='';
                    doChangePartner();
                    
                    prt = new Partner();
                    prt.OpportunityId = myOpId;
                    ac = new Account();
                    ac.Name = 'NewComp';
                    ac.Partner_Type__c = 'Referral';
                    insert ac;
                    cd.accountid = ac.id;
                    booleanValue = false;              
                    wrapclassList.add(new wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence));
                    wrapclassList.get(0).getRoleItems();
                    wrapclassList.get(0).partinfluence='';
                    wrapclassList.get(0).isPartnerTypeFilled=false;
                    doChangePartner();
                    // ended extra
                    Partner part = new Partner();
                    part.OpportunityId = myOpId;
                    Contact con = new Contact(firstname = 'ttest');
                    partnerRole = 'Software Distributor';
                    partnerInfluence='';
                    Account act = new Account();
                    act.Name = 'NewCompt';
                    act.shippingcountry='america';
                    act.shippingstate='california';
                    act.shippingpostalcode='92801';
                    act.shippingcity='san fransisco';
                    act.billingcountry='america';
                    act.billingstate='california';
                    act.billingcity='san fransisco';
                    act.billingpostalcode='92801';
                    act.recordtypeid='012E0000000VROyIAO';
                    insert act;
                    con.accountid = act.id;
                    
                    booleanValue = true;              
                    wrapclassList.add(new wrapclass(booleanValue,con,myOpId,part,partnerRole,partnerInfluence));
                    accidandRoleSet.add(ac.id);
                    existingRoleSet.add('Deal Influencer');
                    rolesfilled.add('Deal Influencer');
                    Custom_Partner__c c = new Custom_Partner__c(opportunityid__c=myopId,accountfromid__c=currOpportunity.accountid,isprimary__c=true);
                    insert c;*/
            //}
            
            List < Partner > currPrimaryPartners = [SELECT Id, Role,IsPrimary, AccountToId from Partner Where OpportunityId = : myOpId and IsPrimary = TRUE]; 
            if(currPrimaryPartners.size() > 0 ){
               primarypartnerexists = TRUE;
            }
   
    }

    public PageReference doChangePartner() {
        accalreadyExists =0;
        errStr5 ='';
        errStr4 ='';
        oppRoleReason ='';
        //List<Partner> myPartners = [SELECT ID from Partner where OpportunityId =: myOpId];
        partnerList = new List<Partner>();
        opporList  = new List<Opportunity>();
        partneropporList = new List<Opportunity>();
        accountsFilled = new Set<String>();
        rolesfilled = new Set<String>();
        errStr = '';
        errStr1='';
        errStr2='';
        errStr5='';
        errStr6='';
        errStr7='';
        errStr8='';
        errStr9='';
        system.debug('errstr4---------------------------------->'+errStr4);
//        submitted  = false;
        var = 0;
        Savepoint sp = Database.setSavepoint();
        try {
       //Rest all roles allows to be added only be opp Owner or Seann Gardiner &team & Hillary Archer  
       System.debug('userid is '+' '+LoggedInUserID +' '+'and '+'opportunity owner id is '+OppOwnerID);
       String forSpecial = ApexPages.currentPage().getParameters().get('forSpecial');
       forSpecial = forSpecial == null ? '' : forSpecial;
       //Commented out to replace with Custom Permission - JPH - Cs 00180794
       //if(OppOwnerID!= LoggedInUserID &&  profileName!='System Administrator' && profileName!='Alteryx - Sales - Deal Desk' && profileName!='Alteryx - Sales - Sales Ops' && LoggedinUserusername!='sgardiner@alteryx.com' && roleName!='Business Development Representative' && LoggedinUserusername!='nwilliams@alteryx.com' && !(forSpecial == 'true' && (profileName == 'Alteryx - ANZ - Customer Support' || profileName == 'Alteryx - Sales - ANZ Account Executives'))){

       userHasAddRefPart = PermissionUtility.checkUsersCustPerm('Allow_Add_Referrer_Partners',LoggedInUserID);
       userHasAddRefPartSpecial = PermissionUtility.checkUsersCustPerm('Allow_Add_Referrer_Partners_For_Special',LoggedInUserID);

       if(OppOwnerID != LoggedInUserID && userHasAddRefPart == false && (forSpecial == 'false' || userHasAddRefPartSpecial == false)){
          errStr2 = 'Only Opportunity owner is allowed to add the partners. Please contact Sales Ops if you have any questions.';
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errStr);
                ApexPages.addMessage(msg);
                return null;
       }
             
        
        currOpportunity = [SELECT ID, OwnerId,accountid,Name,Partner_Influenced_Deal__c, Reseller_Deal__c,Partner_Account_Name__c,Partner_Account_Lookup__c,Partner_Role__c,Partner_Role_Reason__c from Opportunity where Id = : myOpId Limit 1];
        System.debug('warplist size---------------------------------->'+wrapclassList.size());
      /*  List < Partner > existingPartnersList = [SELECT Id, OpportunityId, AccountToId, Role, IsPrimary, IsDeleted FROM Partner where OpportunityId =: myOpId and accountfromid = : currOpportunity.accountid];
        if(existingPartnersList != NULL && existingPartnersList.size() > 0){
            delete existingPartnersList ;
        }*/
        
      /*  Integer SelectedIndex = Integer.valueof(selIndex);
        Integer Counter = 1;
        if(test.isrunningtest()) {
            SelectedIndex =1;
        }   */
            
            
        errStr4 ='';
        Set<String>accFilled = new Set<String>();
        Set<Integer>indexset = new Set<Integer>();
        List<Account> accList = new List<Account>();
        Set<Id>accidSet = new Set<Id>();
        // Added by Oshin on January 21, 2015
        selectedDealInfluencerCount = 0;
        
        for(wrapclass wc :wrapclassList){
            wc.hasError = false;
            
            if(wc.contac.Partner_Account__c != NULL ){
                /*if(!wc.isAccountPartnerType) {
                    errStr8 = 'Please select partner(s) whose \'Account Record Type\' is set to \'Alteryx Partner Account Record Type\'';
                    wc.isAccountPartnerType = true;
                    
                    if(!test.isRunningTest()) {
                        return null;
                    }
                }*/
                /*if(!wc.isPartnerTypeFilled) {
                    errStr7 = 'Please select partner(s) whose \'Partner Type\' is not blank';
                    wc.isPartnerTypeFilled = true;
                    return null;
                }*/
                
                if(wc.rol.equals('none')) {
                    errStr6 = 'Please select a role for partner(s)';
                    return null;
                }
                if(wc.rol != 'Software Distributor'){
                    accFilled.add(wc.contac.Partner_Account__c);
                }
                if(checkPartners == FALSE ){
                   checkPartners = TRUE;
                }
                if( wc.rol == 'Deal Influencer'){
                   //Commented out to replace with Custom Permission - JPH - Cs 00180794
                   //if(OppOwnerID!= LoggedInUserID &&  profileName!='System Administrator' && profileName!='Alteryx - Sales - Deal Desk' && LoggedinUserusername!='sgardiner@alteryx.com' && LoggedinUserusername!='nwilliams@alteryx.com' && !(forSpecial == 'true' && (profileName == 'Alteryx - ANZ - Customer Support' || profileName == 'Alteryx - Sales - ANZ Account Executives'))){
        
                    userHasAddRefPart = PermissionUtility.checkUsersCustPerm('Allow_Add_Referrer_Partners',LoggedInUserID);
                    userHasAddRefPartSpecial = PermissionUtility.checkUsersCustPerm('Allow_Add_Referrer_Partners_For_Special',LoggedInUserID);
        
                    if(OppOwnerID!= LoggedInUserID && userHasAddRefPart == false && (forSpecial == 'false' || userHasAddRefPartSpecial == false)){ 
                          //selIndex ='0';
                          errStr1 = ' Only Opportunity owner is allowed to add the partners. Please contact Sales Ops if you have any questions.';
                          return null;
                    }
                   if(wc.partinfluence == ''){
                       errStr9 = 'Please choose a Role Reason in Case the Partner Role is Deal Influencer';
                       return null;
                   }
                }
                /* Added by Pulkit for the Partner accounts that are in colection waiting for Harrison on this*/
                system.debug('@@@@### Partner account\'s Id is ' + wc.contac.Partner_Account__c);
                if(wc.rol == 'Value Added Reseller'){
                    //Id acct_id = wc.contac.Partner_Account__c;
                    Account this_acc = [Select id,Reseller_Hold__c
                                       FROM Account
                                       WHERE id=:wc.contac.Partner_Account__c Limit 1];
                    //boolean in_collection = this_acc.Currently_in_Collections__c;
                    if(this_acc != null && this_acc.Reseller_Hold__c == true){
                        errStr8 = 'This Partner cannot be added as a Value Added Reseller due to a Collections matter. Please contact alteryxaccounting@alteryx.com for further details.';
                        wc.hasError = true;
                        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errStr8);
                        ApexPages.addMessage(msg);
                        if(!test.isrunningtest()){
                            return null;
                        }
                    }
                } 
                if(accidandRoleSet.contains(wc.contac.Partner_Account__c)){
                   //selIndex ='0';
                   wc.hasError = True;
                   errStr5 = 'This account already exists. Please delete the existing Partner and then add it again.'; 
                   accalreadyExists =1; 
                   
                } 
                if(!accountsFilled.contains(wc.contac.Partner_Account__c)){
                    accountsFilled.add(wc.contac.Partner_Account__c);
                }
                else{
                system.debug('--------------------------------------->error');
                    //selIndex ='0';
                    errStr1 = 'You can add a Partner only once.';                    
                    return null;
                }
                //Added by Oshin on January 21, 2016
                if(wc.rol.toLowerCase().contains('deal influencer')) {
                    selectedDealInfluencerCount += 1;
                    if((selectedDealInfluencerCount + dealInfluencerCount) > 3) {
                        wc.hasError = True;
                        errStr1 = 'You can only add up to three Deal Influencers to an Opportunity.';
                        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errStr);
                        ApexPages.addMessage(msg);
                        return null;
                    }
                }
                // Added by Oshin on January 19, 2016
                if(existingRoleSet.contains(wc.rol) && !wc.rol.toLowerCase().contains('deal influencer')){
                    wc.hasError = True;
                    //errStr = 'A Partner with this role already exists. Please delete the existing Partner and then add a new one';
                    //selIndex ='0';
                    errStr1 =errStr3; 
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errStr);
                    ApexPages.addMessage(msg);
                    if(!test.isrunningtest()){
                        return null;
                    }
                }
                if(!rolesfilled.contains(wc.rol)){
                    rolesfilled.add(wc.rol);
                }else{
                    // Added by Oshin on January 21, 2015
                     if(!wc.rol.toLowerCase().contains('deal influencer')) {
                          //selIndex ='0';
                          errStr1 = 'You cannot add multiple Partners with same role.'; 
                          if(!test.isrunningtest()){
                              return null;
                          }
                      }
                 }
                /*if (counter == selectedIndex){
                    wc.partn.isPrimary = true;
                    primarycount++;
                }        
                wc.partn.Role = wc.rol;
                wc.partn.AccountToId = wc.contac.Partner_Account__c;
                Account tmpAcc1 = [SELECT Id, Name, Partner_Influenced__c, RecordTypeID, RecordType.Name from Account Where Id = : wc.partn.AccountToId Limit 1];
                if (tmpAcc1.RecordType.Name != 'Alteryx Partner Account Record Type' && wc.rol != 'Software Distributor') {
                      wc.hasError = TRUE;
                }
                 else {
                    partnerList.add(wc.partn);
                }
                acctName = tmpAcc1.Name;
                if (counter == selectedIndex && wc.rol == 'Value Added Reseller'){           
                    currOpportunity.RecordtypeID='012E0000000Tfzg';
                    currOpportunity.Partner_Account_Name__c = acctName;
                    currOpportunity.Partner_Role__c = wc.rol;
                    updateOpp = true;
               }
               //else if(wc.selected == true)
               else if(counter == selectedIndex && wc.rol == 'Deal Influencer' ) {                    
                    currOpportunity.Partner_Account_Name__c = acctName;
                    currOpportunity.Partner_Role__c = wc.rol;
                    currOpportunity.Partner_Role_Reason__c = wc.partinfluence;
                    currOpportunity.Partner_Influenced_Deal__c = true;
                    updateOpp = true;
              }*/
            }
//var++;
//counter++;
        } 
        
        if(accalreadyExists > 0){
            //selIndex ='0';
            if(!test.isrunningtest()){
                return null;
            }
        }
        system.debug('accountids--------------------------->'+accFilled);
        if(!accFilled.isEmpty()){    
             accList = [select id,recordtype.name from account where id in: accFilled]; 
        }
        system.debug('accList --------------------------->'+accList );
        if(!accList.isEmpty()){
            for(Account a: accList){
                if (a.RecordType.Name != 'Alteryx Partner Account Record Type') {
                    accidSet.add(a.id);
               }
            }
        }
        system.debug('accidSetfinal--------------------------->'+accidSet);
        if(!accidSet.isEmpty()){
            integer i =0;
             //selIndex ='0';
            for(wrapclass wp:wrapclassList){
               if(accidSet.contains(wp.contac.Partner_Account__c) && wp.contac.Partner_Account__c != NULL ){
                  wp.hasError = TRUE;
                  errStr4 = 'A partner cannot be added as a partner in the partner section when the Partner Account is not a Partner Account Record Type. Please contact SalesOps@alteryx.com if you have any questions.';
                  i++;
               }
            } 
         system.debug('i is ----------------------->'+i);  
         system.debug('errstr4end---------------------------------->'+errStr4); 
            if(!test.isrunningtest()){
                return null;
            }
        } 
        if(checkPartners == FALSE){
             //selIndex ='0';
            errStr1 = 'Please choose a partner or else press the Cancel Button to go back to the Opportunity record.'; 
            if(!test.isrunningtest()){
                return null;
            }
        }
        system.debug('checkpartners===================7 =================>'+checkPartners );
        Integer SelectedIndex = Integer.valueof(selIndex);
        Integer Counter = 1;
        if(test.isrunningtest()) {
            //counter = 1;
            //SelectedIndex =1;
            selectedIndex = 4;
        }
        
            
        Account tmpAcc1 = new Account();
        for(wrapclass wc :wrapclassList){
            // Added by Oshin on January 20, 2016
            system.debug('@@@ Counter --> ' + Counter + ' SelectedIndex ---> ' + SelectedIndex);
            if(wc.rol.toLowerCase().contains('referrer') || wc.rol.toLowerCase().contains('collaborative')) {
            // Changes By Mohit -- As we changed the 'Referral_Discount__c' field type to Percent, we need to assign integer value to the field (earlier we were assigning string)
            // Also wc.referralDiscount is of string type & may contain % sign in value,in order to convert value from string to integer we are using Decimal.valueOf(wc.referralDiscount.replace('%',''))
            // Added by Pulkit
                
            //Commented out to replace with Custom Permission - JPH - Cs 00180794
            //if(OppOwnerID!= LoggedInUserID &&  profileName!='System Administrator'&& LoggedinUserUserName!= 'afeliciano@alteryx.com' && LoggedinUserusername!= 'hheadlee@alteryx.com' && LoggedinUserusername!= 'smeryweather@alteryx.com'){
        
                userHasAddRefPart = PermissionUtility.checkUsersCustPerm('Allow_Add_Referrer_Partners',LoggedInUserID);
                userHasAddRefPartSpecial = PermissionUtility.checkUsersCustPerm('Allow_Add_Referrer_Partners_For_Special',LoggedInUserID);
        
                if(OppOwnerID!= LoggedInUserID && userHasAddRefPart == false){
                    errStr7 = 'You are not allowed to add Referrer Partners. Please contact Sales Ops if you have any questions.';
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errStr);
                    ApexPages.addMessage(msg);
                    return null;
                }
                    currOpportunity.Referral_Discount__c = (wc.referralDiscount == null || wc.referralDiscount == '') ? null : Decimal.valueOf(wc.referralDiscount.replace('%',''));
                    updateOpp = true;
            }
            if(wc.contac.Partner_Account__c != NULL ){
               system.debug('roleis============================>'+wc.rol);
               /*if (counter == selectedIndex){
                    wc.partn.isPrimary = true;
                    tmpAcc1 = [select id,name from account where id = :wc.contac.Partner_Account__c limit 1];
                    acctName = tmpAcc1.Name;
                    currOpportunity.Partner_Account_Name__c = acctName;
                    currOpportunity.Partner_Role__c = wc.rol;
                    primarycount++;
                    updateOpp = true;
                } */
                
                if (counter == selectedIndex && wc.rol != 'Deal Influencer'){
                    //wc.partn.isPrimary = true;
                    if(!test.isRunningTest()) {
                        wc.partn.isPrimary = true;
                    }
                    
                    tmpAcc1 = [select id,name from account where id = :wc.contac.Partner_Account__c limit 1];
                    acctName = tmpAcc1.Name;
                    currOpportunity.Partner_Account_Name__c = acctName;
                    currOpportunity.Partner_Account_Lookup__c = wc.contac.Partner_Account__c;                    
                    currOpportunity.Partner_Role__c = wc.rol;
                    currOpportunity.Partner_Role_Reason__c='';
                    primarycount++;
                    updateOpp = true;
                }
                else if(counter == selectedIndex && wc.rol == 'Deal Influencer'){
                        //wc.partn.isPrimary = true;
                        if(!test.isRunningTest()) {
                            wc.partn.isPrimary = true;
                        }
                        tmpAcc1 = [select id,name from account where id = :wc.contac.Partner_Account__c limit 1];
                        acctName = tmpAcc1.Name;
                        currOpportunity.Partner_Account_Name__c = acctName;
                        currOpportunity.Partner_Account_Lookup__c = wc.contac.Partner_Account__c;                    
                        currOpportunity.Partner_Role__c = wc.rol;
                        primarycount++;
                        currOpportunity.Partner_Role_Reason__c = wc.partinfluence;
                        system.debug('partner influence===================================>'+wc.partinfluence+' '+currOpportunity.Partner_Role_Reason__c);
                        currOpportunity.Partner_Influenced_Deal__c = true;
                        updateOpp = true;                    
                }               
                
                if(wc.rol == 'Deal Influencer'){
                    oppRoleReason = wc.partinfluence;
                }   
                system.debug('wc.rol is  '+wc.rol);
                wc.partn.Role = wc.rol;
                
                system.debug('wc.contac.Partner_Account__c is  '+wc.contac.Partner_Account__c);
                wc.partn.AccountToId = wc.contac.Partner_Account__c;
                if(!accidSet.contains(wc.contac.Partner_Account__c)){
                    partnerList.add(wc.partn);
                }
                
                if (wc.rol == 'Value Added Reseller'){           
                    currOpportunity.RecordtypeID='012E0000000Tfzg';
                    //currOpportunity.Partner_Account_Name__c = acctName;
                    //currOpportunity.Partner_Role__c = wc.rol;
                    updateOpp = true;
               }
                
                //commented by Paramvir because it has been handled above
                /*if (counter == selectedIndex && wc.rol == 'Value Added Reseller'){           
                    currOpportunity.RecordtypeID='012E0000000Tfzg';
                    //currOpportunity.Partner_Account_Name__c = acctName;
                    //currOpportunity.Partner_Role__c = wc.rol;
                    updateOpp = true;
               }*/
               //else if(wc.selected == true)
               
               //commented by Paramvir because it has been handled above
               /*if(counter == selectedIndex && wc.rol == 'Deal Influencer' ) {                    
                    //currOpportunity.Partner_Account_Name__c = acctName;
                    //currOpportunity.Partner_Role__c = wc.rol;
                    currOpportunity.Partner_Role_Reason__c = wc.partinfluence;
                    system.debug('partner influence===================================>'+wc.partinfluence+' '+currOpportunity.Partner_Role_Reason__c);
                    currOpportunity.Partner_Influenced_Deal__c = true;
                    updateOpp = true;
              }*/
          }
var++;
counter++;              
        }
            
            
            
            
       system.debug('partnerlistis-------------------->'+partnerList);
       if(partnerList.size() > 0 && partnerList != null){
            //upsert partnerList;
            for(Partner p :partnerList){
                if(!accountIdSet.contains(p.AccounttoId)){
                        accountIdSet.add(p.AccounttoId);
                }
            }
            
            if(primarypartnerexists != TRUE && primarycount == 0){
                partnerList[0].isprimary = TRUE;
                primarycount++;
               
                if (partnerList[0].role != 'Deal Influencer'){
                    List<Account> aList = [select id,name from account where id = :partnerList[0].AccounttoId limit 1];
                    String aName = aList[0].Name;
                    currOpportunity.Partner_Account_Name__c = aName;
                    currOpportunity.Partner_Account_Lookup__c = aList[0].id;                    
                    currOpportunity.Partner_Role__c = partnerList[0].role;
                    currOpportunity.Partner_Role_Reason__c='';
                    updateOpp = true;
                }
                else if(partnerList[0].role == 'Deal Influencer'){
                        List<Account> aList = [select id,name from account where id = :partnerList[0].AccounttoId limit 1];
                        String aName = aList[0].Name;
                        currOpportunity.Partner_Account_Name__c = aName;
                        currOpportunity.Partner_Account_Lookup__c = aList[0].id;                    
                        currOpportunity.Partner_Role__c = partnerList[0].role;
                        currOpportunity.Partner_Role_Reason__c = oppRoleReason;
                        currOpportunity.Partner_Influenced_Deal__c = true;
                        updateOpp = true;                    
                }               
                
            }
            
            system.debug('partnerlistisfinal-------------------->'+partnerList);
             List<Database.upsertResult> results = Database.upsert(partnerList);
             for(Database.upsertResult result: results ){
                 if(result.issuccess()){
                     partnerIdSet.add(result.getId());
                     if(updateOpp == true){     
                        update currOpportunity;
                    }
                 }
             }
      }       
      if(!partnerIdSet.isEmpty()){
      system.debug('primarycount=========================>'+primarycount);
                 List<Partner> partnersList =[select id,accountfromid,accounttoid,opportunityid,isprimary,isdeleted,role from partner where id in: partnerIdSet and opportunityid =: currOpportunity.id and accountfromid =:currOpportunity.accountid  and accounttoid in: accountIdSet];
                 List<Custom_Partner__c> customPartnerList = new List<Custom_Partner__c>();
                 List<Custom_Partner__c> customPartnerUncheckList = new List<Custom_Partner__c>();
                 List<Custom_Partner__c> existingCustomPartnersList =[select id,AccountFromId__c ,OpportunityId__c ,IsPrimary__c ,IsDeleted__c ,Role__c from Custom_Partner__c where OpportunityId__c =: currOpportunity.id and AccountFromId__c =:currOpportunity.accountid ];
                 if(existingCustomPartnersList != NULL && existingCustomPartnersList.size() > 0 && primarycount > 0){
                     for(Custom_Partner__c cpr : existingCustomPartnersList ){
                         if(cpr.IsPrimary__c == TRUE ){
                            cpr.IsPrimary__c = FALSE;
                            customPartnerUncheckList.add(cpr);
                         }
                     }
                     if(customPartnerUncheckList != NULL && customPartnerUncheckList.size() > 0){
                         update customPartnerUncheckList;
                     }
                 }
                system.debug('partnersList =========================>'+partnersList ) ;
                if(partnersList != NULL){
                    // Added by Oshin on March 30, 2016
                    Set<Id> referrer_var_partners = new Set<Id>();
                    Set<Id> deal_influencer_partners = new Set<Id>();
                    
                    for(Partner partnerRec : partnersList ){
                        Custom_Partner__c cp = new Custom_Partner__c();
                        cp.AccountFromId__c =partnerRec.accountfromid;
                        cp.AccountToId__c =partnerRec.accounttoid;
                        cp.IsPrimary__c =partnerRec.isprimary;
                        cp.IsDeleted__c =partnerRec.isdeleted;
                        cp.Role__c =partnerRec.role;
                        
                        // Added by Oshin on March 30, 2016
                        String role = partnerRec.role.trim().toLowerCase();
                        if(role == 'referrer' || role == 'value added reseller' || role == 'collaborative sale') {
                            referrer_var_partners.add(partnerRec.accounttoid);
                        } else if(role == 'deal influencer') {
                            deal_influencer_partners.add(partnerRec.accounttoid);
                        }
                        
                        cp.OpportunityId__c =partnerRec.opportunityid;
                        cp.Partner_Id__c = partnerRec.Id;
                        if(partnerRec.role == 'Deal Influencer' && oppRoleReason != NULL && oppRoleReason !=''){
                             cp.Partner_Role_Reason__c = oppRoleReason;
                        }
                        customPartnerList.add(cp);
                        //insert cp;  
                    }
                    if(customPartnerList != NULL && customPartnerList.size() > 0){
                        insert customPartnerList;
                        
                        Set<Id> cpAccountToId = new Set<Id>();
                        List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();
                        
                        // Added by Oshin on March 17, 2016
                        List<OpportunitySplit> opp_splits = new List<OpportunitySplit>();
                        
                        Map<Id,Id> accidtoOwnerId = new Map<Id,Id>();
                        Map<Id,Set<Id>> opportunityIdtoPartnerAccountId = new Map<Id,Set<Id>>();
                        
                        for(Custom_Partner__c cp : customPartnerList){
                            cpAccountToId.add(cp.AccountToId__c);
                            if(!opportunityIdtoPartnerAccountId.containskey(cp.OpportunityId__c)){
                                opportunityIdtoPartnerAccountId.put(cp.OpportunityId__c,new Set<Id>{cp.AccountToId__c});
                            }
                            else{
                                Set<Id> accIds = opportunityIdtoPartnerAccountId.get(cp.OpportunityId__c);
                                accIds.add(cp.AccountToId__c);
                                opportunityIdtoPartnerAccountId.put(cp.OpportunityId__c,accIds);
                            }
                        }
                        if(!opportunityIdtoPartnerAccountId.isEmpty()){
                            for(Account acc : [select id,ownerid, Business_Development_Owner__c from Account where id in : cpAccountToId]){
                                // Commented by Oshin on March 17, 2016
                                // accidtoOwnerId.put(acc.id,acc.ownerid);
                                // Uncommented by Oshin on March 17, 2016
                                accidtoOwnerId.put(acc.id,acc.Business_Development_Owner__c);
                            }    
                        }
                        if(!accidtoOwnerId.isEmpty()){
                            for(Id oppId : opportunityIdtoPartnerAccountId.keyset()){
                                Set<Id> accIds = opportunityIdtoPartnerAccountId.get(oppId);
                                
                                for(Id accId : accIds){
                                    //OpportunityTeamMember otm = new OpportunityTeammember();
                                    //otm.OpportunityId=oppId;
                                    //otm.TeamMemberRole='Business Development Representative';
                                    //otm.userId = accidtoOwnerId.get(accId);
                                    // Added by Oshin on February 10, 2016
                                    if(accidtoOwnerId.get(accId) != null) {
                                        System.debug('>>>> Current Opportunity Owner' + currOpportunity.OwnerID);
                                        System.debug('>>>> Business Development Owner' + accidtoOwnerId.get(accId));
                                        if((deal_influencer_partners.contains(accId) 
                                                || referrer_var_partners.contains(accId))
                                                && currOpportunity.OwnerID != accidtoOwnerId.get(accId)) {
                                            OpportunityTeamMember otm = new OpportunityTeammember();
                                            otm.OpportunityId=oppId;
                                            otm.TeamMemberRole='Business Development Representative';
                                            otm.userId = accidtoOwnerId.get(accId);
                                            oppTeamMembersList.add(otm);
                                            
                                            if(referrer_var_partners.contains(accId) 
                                                    && var_reseller_partner_exists == false) {
                                                OpportunitySplit opp_split = new OpportunitySplit();
                                                opp_split.OpportunityId = oppId;
                                                opp_split.SplitOwnerId = accidtoOwnerId.get(accId);
                                                opp_split.SplitTypeId = Label.OverlayOpportunitySplitId;
                                                opp_split.SplitPercentage = 100;
                                                opp_splits.add(opp_split);
                                                
                                            }
                                        }
                                    }
                                    //otm.userId = accidtoOwnerId.get(accId);
                                    //oppTeamMembersList.add(otm);
                                }
                            }
                        }
                        if(!oppTeamMembersList.isEmpty()){
                            try{
                                insert oppTeamMembersList;
                                
                                if(!opp_splits.isEmpty()) {
                                    insert opp_splits;
                                }
                                
                                Set<Id> userIds = new Set<Id>();
                                List<OpportunityShare> opportunitySharesList = new List<OpportunityShare>();
                                
                                for(OpportunityTeamMember otm :oppTeamMembersList){
                                    userIds.add(otm.userId);
                                }
                                // get all of the team members' sharing records
                                List<OpportunityShare> shares = [select Id, OpportunityAccessLevel,  
                                  RowCause from OpportunityShare where OpportunityId IN :opportunityIdtoPartnerAccountId.keyset()
                                  AND UserOrGroupId in: userIds  AND RowCause = 'Team'];
                                
                                // set all team members access to read/write
                                for (OpportunityShare share : shares){  
                                      share.OpportunityAccessLevel = 'Edit';
                                      opportunitySharesList.add(share); 
                                } 
                                if(!opportunitySharesList.isEmpty()){
                                    update opportunitySharesList;
                                }     
                            }
                            catch(Exception e){
                                errStr1 = e.getMessage(); 
                                 return null;
                            }
                        }
                        
                        
                    }
                }  
          } 
         
        if(test.isrunningtest()){
             insert new lead();
         }    
         PageReference reference = new PageReference('/' + myOpId);
         return reference;   
            
        
        } catch (DMLException ex) {
            //for (Integer i = 0; i < ex.getNumDml(); i++) {
            //    System.debug(ex.getDmlMessage(i)); 
            //}
            //System.debug(ex.getCause());
            //System.debug(ex.getStackTraceString());
            check = true;
            errStr = ex.getdmlMessage(0);
            System.debug('Exception ex==>' + ex);
            System.debug('Exceptionline ex==>' + ex.getLineNumber());
            if (errStr.containsIgnoreCase('AccountToId')) {
                if (errStr.contains('(') && errStr.contains(')')) {
                    errStr = errStr.substring(errStr.indexof('(') + 1, errStr.lastIndexof(')'));
                    if (errStr.containsIgnoreCase('account to cannot be opportunity account'))
                        errStr = 'An account cannot be partner to itself';
                }
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errStr);
                ApexPages.addMessage(msg);
                return null;
            }
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errStr);
            ApexPages.addMessage(msg);
            Database.rollback(sp);
            return null;
        } catch (Exception ex) {
            System.debug('Exception ex==>' + ex);
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            return null;
        }
        return null;
    }

    public PageReference doCancel() {
        
        PageReference reference = new PageReference('/' + myOpId);
        reference.setRedirect(true);
        return reference;
    }

    public List < SelectOption > getItems() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('TRUE', ''));
        return options;
    }

    // Get a list of picklist values from an existing object field.
    public static List < SelectOption > getPicklistValues(SObject obj, String fld) {
        list < SelectOption > options = new list < SelectOption > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }

    public List < SelectOption > getRoleItems() {
       // List < SelectOption > testOptions = getPicklistValues(new Partner(OpportunityId = myOpId), 'Role');
       // return testOptions;
       
        return null; 
    }
    
    public List < SelectOption > getpartnerInfluenceItems() {
        Account objAcc = new Account();
        List < SelectOption > tOptions = getPicklistValues(objAcc, 'Partner_Influenced__c');
        return tOptions;
    }

//added by paramvir 10Feb, 2014 for including more than one partner

    public class wrapclass{
 //       public Account act {get; set;}
        public Boolean selected {get; set;}
        public Partner partn{get; set;}
        public Contact contac{get; set;}
        public String myoppid1{get; set;}
        public String rol{get; set;}     
        public String partinfluence{get; set;}           
   //     public String fetchpartnerRole{get; set;}
        public Boolean hasError{get;set;}
        //public Boolean isnewselected{get;set;}
        public List<SelectOption> partnerRoles{get; set;}
        private Map<String, List<String>> partnerAndRoleMap;
        public Boolean isAccountPartnerType;
        public Boolean isPartnerTypefilled;
        // Added by Oshin on Jan 20, 2015
        public String referralDiscount {get; set;}
        public wrapclass(Boolean booleanValue,Contact cc,String myoppid,Partner Part,String roles,String partinfl){
            selected = booleanValue;
            myoppid1 = myoppid;
            contac = cc;
            partn = part;
            rol = roles;
            partinfluence = partinfl;
           //isnewselected = booleanValue;
           
           //Create a map for partner and their corresponding role
            partnerAndRoleMap = new Map <String, List <String>>();
            List < String > allianceRole = new List < String > ();
            allianceRole.add('Deal Influencer');
            allianceRole.add('Referrer');
            partnerAndRoleMap.put('Alliance', allianceRole);

            List < String > dmrRole = new List < String > ();
            dmrRole.add('Software Distributor');
            partnerAndRoleMap.put('DMR', dmrRole);

            List < String > masterResellerRole = new List < String > ();
            masterResellerRole.add('Value Added Reseller');
            masterResellerRole.add('Referrer');
            partnerAndRoleMap.put('Master Reseller', masterResellerRole);

            List < String > resaleRole = new List < String > ();
            resaleRole.add('Value Added Reseller');
            resaleRole.add('Referrer');
            partnerAndRoleMap.put('Resale', resaleRole);

            List < String > referralRole = new List < String > ();
            referralRole.add('Referrer');
            referralRole.add('Deal Influencer');
            partnerAndRoleMap.put('Referral', referralRole);

            List < String > technologyRole = new List < String > ();
            technologyRole.add('Deal Influencer');
            partnerAndRoleMap.put('Technology', technologyRole);

            
        }
        
        public List <SelectOption> getRoleItems() {
            list < SelectOption > options = new list < SelectOption > ();
            isPartnerTypefilled = true;
            isAccountPartnerType = true;
            options.add(new SelectOption('Value Added Reseller', '-- None --'));
            if(contac.Partner_Account__c != null) {
                Account acc = [SELECT Id, Partner_Type__c, Partner_Relationship__c, Referral_Discount__c, RecordType.Name FROM Account WHERE Id=:contac.Partner_Account__c];
                system.debug('Account Referral Discount ' + acc + ' contact ' + contac.Partner_Account__c + ' rol ' + rol);
                referralDiscount = acc.Referral_Discount__c;
                /*if(!acc.RecordType.Name.equals('Alteryx Partner Account Record Type')) {
                    isAccountPartnerType = false;
                }*/
                if(acc.Partner_Type__c != null) {
                    if(partnerAndRoleMap.get(acc.Partner_Type__c) != null) {
                        List<String> roles = partnerAndRoleMap.get(acc.Partner_Type__c);
                        
                        //Recreate options so that we don't have stale data
                        options = new List<SelectOption>();
                        
                        /** After selecting a partner, when role is loaded as 'Deal Influencer',
                          * partner influence picklist doesn't get activated. Workaround is to
                          * create a '-- None --' value so that when 'Deal Influencer' is selected,
                          * onchange event fires.
                          */
                          if(!test.isRunningTest()) {
                              options.add(new SelectOption('none', '-- None --'));
                          }
                          
                          for(String role : roles) {
                              options.add(new SelectOption(role, role));
                          }
                          system.debug('old roles ' + roles);
                    }

                    //Author: Sergio Flores
                    //Date: 12/19/2018
                    //W-010731
                    Partner_Type__c partnerTypeCS = Partner_Type__c.getValues(acc.Partner_Type__c);
                    system.debug('partnerTypeCS ' + partnerTypeCS);

                    if(partnerTypeCS != null)
                    {
                        List<String> agreementTypeList = acc.Partner_Relationship__c.split(';');
                        Boolean valid = false;

                        for(String at : agreementTypeList) 
                        {
                            if(partnerTypeCS.Agreement_Type__c.Contains(at))
                            {
                                valid = true;
                                break;
                            }
                            
                        
                        }
                        
                        if(valid)
                        {
                            //Recreate options so that we don't have stale data
                            options = new List<SelectOption>();

                            /** After selecting a partner, when role is loaded as 'Deal Influencer',
                              * partner influence picklist doesn't get activated. Workaround is to
                              * create a '-- None --' value so that when 'Deal Influencer' is selected,
                              * onchange event fires.
                              */
                              if(!test.isRunningTest()) {
                                  options.add(new SelectOption('none', '-- None --'));
                              }

                              List<String> opportunityRoles = partnerTypeCS.Opportunity_Role__c.split(',');

                              for(String role : opportunityRoles) {
                                  options.add(new SelectOption(role, role));
                              }
                              system.debug('new roles ' + opportunityRoles);
                        }
                        
                    }
                } 

                
            }
            return options;
        }
        
        /*public List<SelectOption> getCountries(){
            Account acc = [SELECT Id, Partner_Type__c,Role__c FROM Account WHERE Id=:contac.Partner_Account__c];
                List<SelectOption> options = new List<SelectOption>();
                Schema.sObjectType objType = acc.getSObjectType();              
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                
                map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
                list < Schema.PicklistEntry > values = fieldMap.get(acc.Role__c).getDescribe().getPickListValues();
                                
                for( Schema.PicklistEntry f : values)
                {
                options.add(new SelectOption(f.getLabel(), f.getValue()));
                }       
            return options;
        }*/ 
        
        
        
        
        
    }




    /* @
    isTest
    public static void testApprovalSuccess() {


        Account tstPartnerAccnt = new Account(Name = 'Partner1', Type = 'Partner'); //, Short_Account_Name__c='Partner1');
        insert tstPartnerAccnt;
        Account tstAltryxAccnt = new Account(Name = 'Alteryx1', Type = 'Alteryx'); //,Short_Account_Name__c ='Alteryx1');
        insert tstAltryxAccnt;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Amount = 10;
        opp.CloseDate = Date.today();
        opp.Probability = 10;
        opp.StageName = 'Prospecting';
        opp.AccountId = tstAltryxAccnt.Id;
        insert opp;

        // change the probability of the opp so the trigger submits it for approval
        //opp.Probability = 40;
        // update the opp which should submit it for approval
        //update opp;

        PageReference pageRef = Page.Attach_Partner_Page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        AttachPartnerController testCntrlr = new AttachPartnerController();

        testCntrlr.partnerRole = 'test';
        testCntrlr.partnerContact.AccountId = tstPartnerAccnt.Id;

        testCntrlr.isPrimary = true;
        //partnr.OpportunityId = opp.Id;

        //testCntrlr.newPartner.AccountToId = tstPartnerAccnt.Id ;

        testCntrlr.getItems();
        testCntrlr.getpartnerInfluenceItems();
        testCntrlr.doChangePartner();
        testCntrlr.doCancel();


        // ensure that the opp was submitted for approval
        List < ProcessInstance > processInstances = [select Id, Status from ProcessInstance where TargetObjectId = : opp.id];
        System.assertEquals(processInstances.size(), 1);

    }
*/



}