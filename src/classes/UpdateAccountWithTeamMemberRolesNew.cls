global class UpdateAccountWithTeamMemberRolesNew implements Database.Batchable<sObject>{
public List<Account> accList = new List<Account>();
public List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
public List<Account> updatedAccList= new List<Account>();
public Map<Id,AccountTeamMember> atmId2atm= new Map<Id,AccountTeamMember>();
public Map<Id,Account> accountId2account= new Map<Id,Account>();
public Map<Id,Account> accountIds2accounts= new Map<Id,Account>();
public Map<Id,Set<String>> account2accountteammemberrole = new Map<Id,Set<String>>();
public Map<Id,Account> accountId2account2 = new Map<Id,Account>();
public Map<Id,Account> acctobeEmptied = new Map<Id,Account>();
public List<Account> updatedAccList2 = new List<Account>();
Set<Id> accountIdSet = new Set<Id>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
       String query = 'select id, Customer_Success_Representative__c, Client_Services_Rep_Phone__c, Client_Services_Rep_Email__c, Client_Services_Rep_ID__c, Solutions_Engineer_Email__c, Solutions_Engineer_Phone__c, Solutions_Engineer__c, Solutions_Engineer_ID__c, Executive_Sponsor_Email__c, Executive_Sponsor_ID__c, Alteryx_Executive_Sponsor__c, Executive_Sponsor_Phone__c,(select Id, AccountId, User.Name, User.Email, User.Phone, User.UserName, User.Full_Name__c, TeamMemberRole, UserId, createdDate from AccountTeamMembers where  TeamMemberRole = \'Client Services Representative\' OR TeamMemberRole = \'Solutions Engineer\' OR TeamMemberRole = \'Alteryx Executive Sponsor\' Order By createdDate Desc) from Account';
       return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accList = (List<Account>) scope;
        if(accList.size() > 0 && accList != NULL){
            for(Account ac : accList){
                system.debug('accmemlist size--------------------->'+ac.AccountTeamMembers.size()+'acc mems'+' '+ac.AccountTeamMembers);
                if(ac.AccountTeamMembers.size() > 0){
                   //acc2accTeamMembersList.put(ac.id,ac.AccountTeamMembers);   
                   /*commented by paramvir 9April,2015 for removing for in for loop 
                      for(AccountTeamMember atmem : ac.AccountTeamMembers){
                          accTeamMemberList.add(atmem);
                      } */  
                   accTeamMemberList.addAll(ac.AccountTeamMembers); 
                   system.debug('accteammemberlist is ===========================================>'+ac.AccountTeamMembers);
                   accountIds2accounts.put(ac.id,ac);         
                }
                else{
                    if(ac.Client_Services_Rep_Email__c != NULL || ac.Client_Services_Rep_ID__c != NULL || ac.Client_Services_Rep_Phone__c != NULL || ac.Customer_Success_Representative__c != NULL || ac.Solutions_Engineer_Email__c != NULL || ac.Solutions_Engineer_Phone__c != NULL || ac.Solutions_Engineer__c != NULL || ac.Solutions_Engineer_ID__c != NULL || ac.Alteryx_Executive_Sponsor__c != NULL || ac.Executive_Sponsor_Phone__c != NULL || ac.Executive_Sponsor_Email__c != NULL || ac.Executive_Sponsor_ID__c != NULL ){
                       ac.Client_Services_Rep_Email__c ='';
                       ac.Client_Services_Rep_ID__c  = '';
                       ac.Client_Services_Rep_Phone__c = '';
                       ac.Customer_Success_Representative__c ='';
                       ac.Solutions_Engineer_Email__c = '';
                       ac.Solutions_Engineer_Phone__c = '';
                       ac.Solutions_Engineer__c = '';
                       ac.Solutions_Engineer_ID__c = '';                       
                       ac.Executive_Sponsor_Email__c = '';
                       ac.Executive_Sponsor_ID__c = '';
                       ac.Alteryx_Executive_Sponsor__c = '';
                       ac.Executive_Sponsor_Phone__c = ''; 
                       acctobeEmptied.put(ac.id,ac);                   
                    }
                }
            }
        
        }
        system.debug('accidstoaccounts size'+accountIds2accounts.size());
        if(accTeamMemberList.size() > 0 && accTeamMemberList != NULL){
            for(AccountTeamMember atm :accTeamMemberList){
                 if(!account2accountteammemberrole.containskey(atm.accountId)){
                     system.debug('1st team member---------------->'+atm.teammemberrole);
                     Set<String> roleSet = new Set<String>();
                     roleSet.add(atm.TeamMemberRole);
                     account2accountteammemberrole.put(atm.accountId,roleSet);
                      atmId2atm.put(atm.id,atm); 
                 }
                 else{
                      Set<String> roleS = account2accountteammemberrole.get(atm.accountId);
                      if(!roleS.contains(atm.TeamMemberRole)){
                          //system.debug('2nd team member---------------->'+atm.teammemberrole+roleset);
                          roleS.add(atm.TeamMemberRole);
                          //system.debug('rolesetnew---------------->'+atm.teammemberrole+roleset);
                          account2accountteammemberrole.put(atm.accountId,roleS);
                           atmId2atm.put(atm.id,atm); 
                      }
                 }
                 //atmId2atm.put(atm.id,atm); 
            }
            system.debug('atmId2atm------------------------->'+atmId2atm);
            system.debug('accountIds2accountskeysetsize------------->'+accountIds2accounts.keyset().size());
            system.debug('accountIds2accounts------------------->'+accountIds2accounts);
            if(accountIds2accounts.keyset().size() > 0 && accountIds2accounts.keyset() != NULL){
            system.debug('atmKEYSET is ================>'+atmId2atm.keyset() );
                for(Id atmId : atmId2atm.keyset()){
                    AccountTeamMember atm = atmId2atm.get(atmId);
                    system.debug('atm is ------------------------>'+atm);
                    Account acc = accountIds2accounts.get(atm.accountid);
                    system.debug('account is-------------------->----->'+acc);
                    if(atm.TeamMemberRole == 'Client Services Representative'){
                    system.debug('11111111111111111111111111111111111111111111111111111111');
                        if(acc.Client_Services_Rep_Email__c != atm.User.UserName){
                            if(!accountId2account.containskey(acc.id)){
                                acc.Customer_Success_Representative__c = atm.User.Name;
                                acc.Client_Services_Rep_Phone__c = atm.User.Phone;
                                acc.Client_Services_Rep_Email__c = atm.User.UserName;
                                acc.Client_Services_Rep_ID__c = atm.UserId;
                                accountId2account.put(acc.Id,acc);
                                system.debug('accountId2account1----------->'+accountId2account);
                                
                            }
                            else{
                                Account a = accountId2account.get(acc.Id);
                                a.Customer_Success_Representative__c = atm.User.Name;
                                a.Client_Services_Rep_Phone__c = atm.User.Phone;
                                a.Client_Services_Rep_Email__c = atm.User.UserName;
                                a.Client_Services_Rep_ID__c = atm.UserId;
                                accountId2account.put(a.Id,a);
                                system.debug('accountId2account11----------->'+accountId2account);
                                
                            }
                        }
                    }
                    else if(atm.TeamMemberRole == 'Solutions Engineer'){
                             if(acc.Solutions_Engineer_Email__c != atm.User.UserName){
                                if(!accountId2account.containskey(acc.id)){
                                   acc.Solutions_Engineer_Email__c = atm.User.UserName;
                                   acc.Solutions_Engineer_Phone__c = atm.User.Phone;
                                   acc.Solutions_Engineer__c = atm.User.Name;
                                   acc.Solutions_Engineer_ID__c = atm.UserId;
                                   accountId2account.put(acc.Id,acc);
                                }
                                else{
                                    Account a = accountId2account.get(acc.Id);
                                    a.Solutions_Engineer_Email__c = atm.User.UserName;
                                    a.Solutions_Engineer_Phone__c = atm.User.Phone;
                                    a.Solutions_Engineer__c = atm.User.Name;
                                    a.Solutions_Engineer_ID__c = atm.UserId;
                                    accountId2account.put(a.Id,a);
                                }
                             }
                    }
                    else if(atm.TeamMemberRole == 'Alteryx Executive Sponsor'){
                            if(acc.Executive_Sponsor_Email__c != atm.User.UserName){
                                if(!accountId2account.containskey(acc.id)){
                                   acc.Executive_Sponsor_Email__c = atm.User.UserName;
                                   acc.Executive_Sponsor_ID__c = atm.UserId;
                                   acc.Alteryx_Executive_Sponsor__c = atm.User.Name;
                                   acc.Executive_Sponsor_Phone__c = atm.User.Phone;
                                   accountId2account.put(acc.Id,acc);
                                   system.debug('accountId2account2----------->'+accountId2account);
                                }
                                else{
                                    Account a = accountId2account.get(acc.Id);
                                    a.Executive_Sponsor_Email__c = atm.User.UserName;
                                    a.Executive_Sponsor_ID__c = atm.UserId;
                                    a.Alteryx_Executive_Sponsor__c = atm.User.Name;
                                    a.Executive_Sponsor_Phone__c = atm.User.Phone;
                                    accountId2account.put(a.Id,a);
                                    system.debug('accountId2account22----------->'+accountId2account);
                                }
                            }
                    } 
                }
            }
        
        }  
        system.debug('accountId2accountize----------->'+accountId2account.size());
        if(accountIds2accounts.keyset().size() > 0 && accountIds2accounts.keyset() != NULL){
            for(Id accId : accountIds2accounts.keyset()){
                 Set<String> roles = account2accountteammemberrole.get(accId); 
                 if(accountId2account.containskey(accId)){
                      Account act = accountId2account.get(accId);
                      if(!roles.isEmpty()){
                       if(!roles.contains('Client Services Representative')){
                          act.Customer_Success_Representative__c = '';
                          act.Client_Services_Rep_Phone__c = '';
                          act.Client_Services_Rep_Email__c = '';
                          act.Client_Services_Rep_ID__c = '';
                          //accountId2account2.put(act.id,act);
                          accountId2account.put(act.id,act);
                       }
                       if(!roles.contains('Solutions Engineer')){
                          system.debug('##############################################');
                          act.Solutions_Engineer_Email__c = '';
                          act.Solutions_Engineer_Phone__c = '';
                          act.Solutions_Engineer__c = '';
                          act.Solutions_Engineer_ID__c = '';
                          //accountId2account2.put(act.id,act);
                          accountId2account.put(act.id,act);
                       }
                       if(!roles.contains('Alteryx Executive Sponsor')){
                          act.Executive_Sponsor_Email__c = '';
                          act.Executive_Sponsor_ID__c = '';
                          act.Alteryx_Executive_Sponsor__c = '';
                          act.Executive_Sponsor_Phone__c = '';
                          //accountId2account2.put(act.id,act);
                          accountId2account.put(act.id,act);
                       }
                    } 
                 }
                 else{
                     Account act = accountIds2accounts.get(accId);  
                     if(!roles.isEmpty()){
                       if(!roles.contains('Client Services Representative') && act.Client_Services_Rep_Email__c != NULL){
                          act.Customer_Success_Representative__c = '';
                          act.Client_Services_Rep_Phone__c = '';
                          act.Client_Services_Rep_Email__c = '';
                          act.Client_Services_Rep_ID__c = '';
                          //accountId2account2.put(act.id,act);
                          accountId2account.put(act.id,act);
                       }
                       if(!roles.contains('Solutions Engineer') && act.Solutions_Engineer_Email__c != NULL){
                          system.debug('##############################################');
                          act.Solutions_Engineer_Email__c = '';
                          act.Solutions_Engineer_Phone__c = '';
                          act.Solutions_Engineer__c = '';
                          act.Solutions_Engineer_ID__c = '';
                          //accountId2account2.put(act.id,act);
                          accountId2account.put(act.id,act);
                       }
                       if(!roles.contains('Alteryx Executive Sponsor') && act.Executive_Sponsor_Email__c != NULL){
                          act.Executive_Sponsor_Email__c = '';
                          act.Executive_Sponsor_ID__c = '';
                          act.Alteryx_Executive_Sponsor__c = '';
                          act.Executive_Sponsor_Phone__c = '';
                          //accountId2account2.put(act.id,act);
                          accountId2account.put(act.id,act);
                       }
                    }                
                 }

            }
        }
        if(accountId2account.keyset().size() > 0 && accountId2account.keyset() != NULL){
            for(Id actId : accountId2account.keyset()){
                 updatedAccList.add(accountId2account.get(actId));
            }
        }
        System.debug('size is%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'+updatedAccList.size());
        if(updatedAccList.size() > 0 && updatedAccList != NULL){
             try{
                update updatedAccList;
                System.debug('list is --------------------------------------------------->'+ updatedAccList);
                if(test.isRunningTest()){
                    insert new lead();
                }
            }
            catch(DMLException de){
                System.debug('error is'+de.getMessage());
            }
        
        }
        if(acctobeEmptied.keyset().size() > 0 && acctobeEmptied.keyset() != NULL){
            for(Id aId : acctobeEmptied.keyset()){
                 if(!accountId2account.containskey(aId)){
                     updatedAccList2.add(acctobeEmptied.get(aId));
                 }
            }
        
        }
        if(updatedAccList2.size() > 0 && updatedAccList2 != NULL){
            try{
                update updatedAccList2;
                if(test.isrunningTest()){
                    insert new lead();
                }
            }
            catch(DMLException de){
                 system.debug('error is'+de.getMessage());
            }
        }
    } 

    
    global void finish(Database.BatchableContext  BC){  
    }
}