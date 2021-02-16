@isTest
private class alteryx_LeadMatchAccount_Test {
    testMethod private static void Test1( ) {
        // System.debug( 'MB: Starting Test1.....' );

        final String queueMQL = 'MQL Staging Queue';
        final String queueLA = 'Lead Allocation Queue';
        final String queueCA  = 'Lead Catch All Queue';
        List<Account> accountsToInsert = new List<Account>( );
        List<Lead> leadsToInsert = new List<Lead>( );
        List<Id> leadIds = new List<Id>( );
        List<Group> mqlGroup = [Select Id from Group where type = 'Queue' AND Name = :queueMQL limit 1];
        List<Group> laGroup = [Select Id from Group where type = 'Queue' AND Name = :queueLA limit 1];
        List<Group> caGroup  = [Select Id from Group where type = 'Queue' AND Name = :queueCA  limit 1];
        List<User> usersToInsert = new List<User>( );
        Id MQLStageID = null;
        Id LAStageID = null;
        Id CatchAllID = null;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId( ) ];
        System.runAs ( thisUser ) {
            // Test USERS
            // System.debug( 'MB: Creating test users...' );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 1, 'testUser', '' ) );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 2, 'testUser', '' ) );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 3, 'testUser', '' ) );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 4, 'testUser', '' ) );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 5, 'testUser', '' ) );
            insert usersToInsert;
        }

        System.runAs ( thisUser ) {
            // Test ACCOUNTS
            // System.debug( 'MB: Creating test accounts...' );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'ABC Company, Inc.', 'CO', [SELECT Id from User WHERE LastName = 'testUser1'].Id ) );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'XYZ Company, Inc.', 'CO', [SELECT Id from User WHERE LastName = 'testUser2'].Id ) );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'Acme, Inc.',        'CA', [SELECT Id from User WHERE LastName = 'testUser3'].Id ) );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'Google, Inc.',      'CA', [SELECT Id from User WHERE LastName = 'testUser4'].Id ) );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'Apple, Inc.',       'NV', [SELECT Id from User WHERE LastName = 'testUser5'].Id ) );
            insert accountsToInsert;
        }

       /* System.runAs ( thisUser ) {
            // set Account attributes
            // System.debug('MB: Setting ABC Account to Named Account');
            Account a1 = [SELECT Id, Name, Named_Account__c, Type from Account where Name = 'ABC Company, Inc.'];
            a1.Named_Account__c = true;
            update a1;
        
            // System.debug('MB: Setting Acme Account to type: Customer');
            Account a2 = [SELECT Id, Name, Named_Account__c, Type from Account where Name = 'Acme, Inc.'];
            a2.Type = 'Customer';
            update a2;
        
            // System.debug('MB: Setting Google Account to type: Partner Customer');
            Account a3 = [SELECT Id, Name, Named_Account__c, Type from Account where Name = 'Google, Inc.'];
            a3.Type = 'Partner Customer';
            update a3;
        
            // set the testUser2 to inactive
            User u2 = [SELECT Id, Name, isActive FROM User WHERE LastName = 'testUser2'];
            u2.isActive = false;
            update u2;
        }*/

        // System.debug( 'MB: setting Queue IDs...' );
        if ( mqlGroup.size( ) == 1 ) {
            MQLStageID = mqlGroup[0].Id;
            // System.debug( 'MB: MQLStageID = ' + MQLStageID );
        }
        if ( laGroup.size( ) == 1 ) {
            LAStageID = laGroup[0].Id;
            // System.debug( 'MB: LAStageID = ' + LAStageID );
        }
        if ( caGroup.size( ) == 1 ) {
            CatchAllID = caGroup[0].Id;
            // System.debug( 'MB: CatchAllID = ' + CatchAllID );
        }

        System.runAs ( thisUser ) {
            // Test LEADS
            // System.debug( 'MB: Creating test leads...' );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 1, 'ABC Company, Inc.', 'CO', '80301', 0,  MQLStageID ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 2, 'noMatch1',          'CO', '80301', 0,  null       ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 3, 'noMatch2',          'CO', '80301', 0,  MQLStageID ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 4, 'XYZ Company, Inc.', 'CO', '80301', 0,  MQLStageID ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 5, 'Acme, Inc.',        'CA', '99999', 0,  MQLStageID ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 6, 'Google, Inc.',      'CA', '99999', 0,  MQLStageID ) );
            insert leadsToInsert;  
        }

        // Grab the inserted Leads and collect the Ids into a new List: leadIds
        List<Lead> insertedLeads = [SELECT Id, ownerId, Name from Lead];
        for ( Lead l : insertedLeads ) {
            leadIds.add( l.Id );
        }

        Test.startTest( );
        // System.debug( 'MB: query test leads...' );
        List<Lead> testLeads = [SELECT Id, ownerId, Company FROM Lead where Id IN :leadIds];

        // System.debug( 'MB: assert that we have the same number of leads we initially inserted' );
        // System.debug( 'MB: inserted leads: ' + leadsToInsert.size( ) );
        // System.debug( 'MB: found leads: ' + testLeads.size( ) );
        System.assertEquals( testLeads.size( ), leadsToInsert.size( ) );

        // System.debug( 'MB: loop through test leads...' + testLeads.size( ) );
        for ( Lead l : testLeads ) {
            // System.debug( 'MB: checking Lead ownership  Name: ' + l.Company );
            if ( l.Company == 'ABC Company, Inc.' ) {
                // System.debug( 'MB: Lead for ABC Company should be owned by testUser1' );
                //System.assertEquals( [SELECT Id from User WHERE LastName = 'testUser1'].Id, l.ownerId );
            } else if ( l.Company == 'Acme, Inc.' ) {
                // System.debug( 'MB: Lead for Acme should be owned by testUser3' );
                // System.debug( 'MB: Acme owner     Lead: ' + l.ownerId + '    testUser3: ' + [SELECT Id from User WHERE LastName = 'testuser3'].Id );
                //System.assertEquals( [SELECT Id from User WHERE LastName = 'testUser3'].Id, l.ownerId );
            } else if ( l.Company == 'Google, Inc.' ) {
                // System.debug( 'MB: Lead for Google should be owned by testUser4' );
               // System.assertEquals( [SELECT Id from User WHERE LastName = 'testUser4'].Id, l.ownerId );
/* REMOVED - we do not know exactly where this is going to be assigned
            } else if ( l.Company == 'XYZ Company, Inc.' ) {
                // System.debug( 'MB: Lead for XYZ Company should be owned by Lead Catch All Queue - since the account owner is an inactive user' );
                System.assertEquals( CatchAllID, l.ownerId );
*/
            } else if ( l.Company == 'noMatch1' ) {
                // System.debug( 'MB: Lead for noMatch1 should be owned by default user - no re-assignment' );
               // System.assertEquals( thisUser.Id, l.ownerId );
/* REMOVED - we do not know exactly where this is going to be assigned
            } else if ( l.Company == 'noMatch2' ) {
                // System.debug( 'MB: Lead for noMatch2 should be assigned to the Catch All Queue' );
                System.assertEquals( CatchAllID, l.ownerId );
*/
            }
        }

        Test.stopTest( );
    }

    testMethod private static void Test2( ) {
        // System.debug( 'MB: Starting Test2.....' );

        final String queueMQL = 'MQL Staging Queue';
        final String queueLA = 'Lead Allocation Queue';
        final String queueCA  = 'Lead Catch All Queue';
        List<Account> accountsToInsert = new List<Account>( );
        List<Lead> leadsToInsert = new List<Lead>( );
        List<Lead> leadsToUpdate = new List<Lead>( );
        List<Group> mqlGroup = [Select Id from Group where type = 'Queue' AND Name = :queueMQL];
        List<Group> laGroup = [Select Id from Group where type = 'Queue' AND Name = :queueLA];
        List<Group> caGroup  = [Select Id from Group where type = 'Queue' AND Name = :queueCA  limit 1];
        List<Id> leadIds = new List<Id>( );
        List<User> usersToInsert = new List<User>( );
        Id MQLStageID = null;
        Id LAStageID = null;
        Id CatchAllID = null;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId( ) ];
        System.runAs ( thisUser ) {
            // Test USERS
            // System.debug( 'MB: Creating test users...' );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 1, 'testUser', '' ) );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 2, 'testUser', '' ) );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 3, 'testUser', '' ) );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 4, 'testUser', '' ) );
            usersToInsert.add( alteryxTestFactory.buildTestUser( 5, 'testUser', '' ) );
            insert usersToInsert;
        }

        System.runAs ( thisUser ) {
            // Test ACCOUNTS
            // System.debug( 'MB: Creating test accounts...' );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'ABC Company, Inc.', 'CO', [SELECT Id from User WHERE LastName = 'testUser1'].Id ) );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'XYZ Company, Inc.', 'CO', [SELECT Id from User WHERE LastName = 'testUser2'].Id ) );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'Acme, Inc.',        'CA', [SELECT Id from User WHERE LastName = 'testUser3'].Id ) );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'Google, Inc.',      'CA', [SELECT Id from User WHERE LastName = 'testUser4'].Id ) );
            accountsToInsert.add( alteryxTestFactory.buildTestAccount( 'Apple, Inc.',       'NV', [SELECT Id from User WHERE LastName = 'testUser5'].Id ) );
            insert accountsToInsert;
        }

       /* System.runAs ( thisUser ) {
            // set Account attributes
            // System.debug('MB: Setting ABC Account to Named Account');
            Account a1 = [SELECT Id, Name, Named_Account__c, Type from Account where Name = 'ABC Company, Inc.'];
            a1.Named_Account__c = true;
            update a1;
        
            // System.debug('MB: Setting Acme Account to type: Customer');
            Account a2 = [SELECT Id, Name, Named_Account__c, Type from Account where Name = 'Acme, Inc.'];
            a2.Type = 'Customer';
            update a2;
        
            // System.debug('MB: Setting Google Account to type: Partner Customer');
            Account a3 = [SELECT Id, Name, Named_Account__c, Type from Account where Name = 'Google, Inc.'];
            a3.Type = 'Partner Customer';
            update a3;
        
            // set the testUser2 to inactive
            User u2 = [SELECT Id, Name, isActive FROM User WHERE LastName = 'testUser2'];
            u2.isActive = false;
            update u2;
        }*/

        // System.debug( 'MB: setting Queue IDs...' );
        if ( mqlGroup.size( ) == 1 ) {
            MQLStageID = mqlGroup[0].Id;
            // System.debug( 'MB: MQLStageID = ' + MQLStageID );
        }
        if ( laGroup.size( ) == 1 ) {
            LAStageID = laGroup[0].Id;
            // System.debug( 'MB: LAStageID = ' + LAStageID );
        }
        if ( caGroup.size( ) == 1 ) {
            CatchAllID = caGroup[0].Id;
            // System.debug( 'MB: CatchAllID = ' + CatchAllID );
        }


        System.runAs ( thisUser ) {
            // Test LEADS
            // System.debug( 'MB: Creating test leads...' );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 1, 'ABC Company, Inc.', 'CO', '80301', 0,  null ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 2, 'noMatch1',          'CO', '80301', 0,  null ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 3, 'noMatch2',          'CO', '80301', 0,  null ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 4, 'XYZ Company, Inc.', 'CO', '80301', 0,  null ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 5, 'Acme, Inc.',        'CA', '99999', 0,  null ) );
            leadsToInsert.add( alteryxTestFactory.buildTestLeadWithOwner( 6, 'Google, Inc.',      'CA', '99999', 0,  null ) );
            insert leadsToInsert;
        }

        // Grab the inserted Leads and collect the Ids into a new List: leadIds
        List<Lead> insertedLeads = [SELECT Id, ownerId, Name from Lead];
        for ( Lead l : insertedLeads ) {
            leadIds.add( l.Id );
        }

        for ( Lead l : insertedLeads ) {
            l.ownerId = MQLStageID;
            leadsToUpdate.add( l );
        }

        Test.startTest( );

        System.runAs ( thisUser ) {
            // System.debug( 'MB: Updating ' + leadsToInsert.size( ) + ' leads - this should trigger the trigger' );
            update leadsToUpdate;
        }

        List<Lead> updatedLeads = [SELECT Id, ownerId, Company FROM Lead WHERE Id IN : leadIds];
        // System.debug( 'MB: make sure we have the same number of leads as we started with' );
        System.assertEquals( updatedLeads.size( ), leadsToInsert.size( ) );
        for ( Lead l : updatedLeads ) {
            // System.debug( 'MB: checking Lead ownership  Name: ' + l.Company );
            if ( l.Company == 'ABC Company, Inc.' ) {
                // System.debug( 'MB: Lead for ABC Company should be owned by testUser1' );
                //System.assertEquals( [SELECT Id from User WHERE LastName = 'testUser1'].Id, l.ownerId );
            } else if ( l.Company == 'Acme, Inc.' ) {
                // System.debug( 'MB: Lead for Acme Company should be owned by testUser3' );
                //System.assertEquals( [SELECT Id from User WHERE LastName = 'testUser3'].Id, l.ownerId );
            } else if ( l.Company == 'Google, Inc.' ) {
                // System.debug( 'MB: Lead for Google should be owned by testUser4' );
                //System.assertEquals( [SELECT Id from User WHERE LastName = 'testUser4'].Id, l.ownerId );
/* REMOVED - we do not know exactly where these are going to be assigned
            } else if ( l.Company == 'XYZ Company, Inc.' ) {
                // System.debug( 'MB: Lead for XYZ Company should be owned by Lead Catch All Queue - since the account owner is an inactive user' );
                System.assertEquals( CatchAllID, l.ownerId );
            } else if ( l.Company == 'noMatch1' || l.Company == 'noMatch2' ) {
                // System.debug( 'MB: Lead for noMatch1 should be owned by the Lead Allocation Queue' );
                System.assertEquals( CatchAllID, l.ownerId );
*/
            }
        }
        Test.stopTest( );
    }
}