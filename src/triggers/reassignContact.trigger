//<Addition> By Pankaj [Dated: 5/19/2014]
//<Reason> Reassigns Contact to Account Owner

trigger reassignContact on Contact (before insert, before update) {

    //if(UserInfo.getUserName() == 'sfdcadmin@alteryx.com') { return; }
    
   try {

        Set<Id> accountIds = new Set<Id>();
        Map<Id, Id> accountOwnerIdMap = new Map<Id, Id>();
   
        // all the accounts whose owner ids to look up
        for ( Contact c : Trigger.new ) {
            if(c.accountId <> null){
             accountIds.add( c.accountId );
            }
        }
       
        // look up each account owner id
        for ( Account acct : [ SELECT id, ownerId FROM account WHERE id IN :accountIds ] ) {
            accountOwnerIdMap.put( acct.id, acct.ownerId );
        }
       
        // change contact owner to its account owner
        for ( Contact c : Trigger.new ) {
            if(c.AccountId <> null && accountOwnerIdMap.containsKey(c.accountId)){
             c.ownerId = accountOwnerIdMap.get( c.accountId );
            }
        }
        
        if(Test.isRunningTest()){
            //insert new Lead();
        }
    } catch(Exception e) { //catch errors
        System.Debug('reassignContacts failure: '+e.getMessage()); //write error to the debug log
    }

}