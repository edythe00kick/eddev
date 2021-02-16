@isTest
public class alteryxTestFactory 
{
    
    /* Returns a valid mock User.
    *  Update to pass all validation rule and field requirements.
    *    i: an integer to make each mock User unique. 
    *    profilename: the name of the profile to assign the user, required.
    */
    public static User buildTestUser( Integer i, String profilename, String userRoleName ) {
        User newuser = new User( );
        Profile p = [SELECT Id FROM Profile WHERE Id = :UserInfo.getProfileid() Limit 1];
        //Profile p = [SELECT Id FROM Profile WHERE Name = 'Alteryx Sales User'];//'Alteryx Sales User'];
        newuser.LastName = profilename + i;
        newuser.Alias = 'user' + i;
        newuser.Email = 'testuser@alteryx.com';
        newuser.Username = 'test_' + i + '@alteryx.com';
        newuser.CommunityNickname = 'test_' + i + '@alteryx.com';
        newuser.ProfileId = p.Id;
        newuser.TimeZoneSidKey = 'America/Los_Angeles';
        newuser.LocaleSidKey = 'en_US';
        newuser.EmailEncodingKey = 'UTF-8';
        newuser.LanguageLocaleKey = 'en_US';
        if ( userRoleName != null && userRoleName.length() > 0 ) {
            newuser.UserRoleId = [SELECT u.Id FROM UserRole u where u.Name = :userRoleName LIMIT 1].Id;
        }
        newuser.isActive = true;

        return newuser;
    }

    public static Lead buildTestLead( Integer i, String companyName, String state, String zipCode, Double revenue )
    {
        return buildTestLeadWithOwner( i, companyName, state, zipCode, revenue, null );
    }

    public static Lead buildTestLeadWithOwner( Integer i, String companyName, String state, String zipCode, Double revenue, Id owner )
    {
        Map<Integer, String> ASCIIMap = new Map<Integer, String> ();
        ASCIIMap.put(0,'A');
        ASCIIMap.put(1,'B');
        ASCIIMap.put(2,'C');
        ASCIIMap.put(3,'D');
        ASCIIMap.put(4,'E');
        ASCIIMap.put(5,'F');
        ASCIIMap.put(6,'G');
        ASCIIMap.put(7,'H');
        ASCIIMap.put(8,'I');
        ASCIIMap.put(9,'J');
        ASCIIMap.put(10,'K');
        ASCIIMap.put(11,'L');
        ASCIIMap.put(12,'M');
        ASCIIMap.put(13,'N');
        ASCIIMap.put(14,'O');
        ASCIIMap.put(15,'P');
        ASCIIMap.put(16,'Q');
        ASCIIMap.put(17,'R');
        ASCIIMap.put(18,'S');
        ASCIIMap.put(19,'T');
        ASCIIMap.put(20,'U');
        ASCIIMap.put(21,'V');
        ASCIIMap.put(22,'W');
        ASCIIMap.put(23,'X');
        ASCIIMap.put(24,'Y');
        ASCIIMap.put(25,'Z');
        ASCIIMap.put(26,'AA');
        ASCIIMap.put(27,'AB');
        ASCIIMap.put(28,'AC');
        ASCIIMap.put(29,'AD');
        ASCIIMap.put(30,'AE');
        ASCIIMap.put(31,'AF');
        ASCIIMap.put(32,'AG');
        ASCIIMap.put(33,'AH');
        ASCIIMap.put(34,'AI');
        ASCIIMap.put(35,'AJ');
        ASCIIMap.put(36,'AK');
        ASCIIMap.put(37,'AL');
        ASCIIMap.put(38,'AM');
        ASCIIMap.put(39,'AN');
        ASCIIMap.put(40,'AO');
        ASCIIMap.put(41,'AP');
        ASCIIMap.put(42,'AQ');
        ASCIIMap.put(43,'AR');
        ASCIIMap.put(44,'AS');
        ASCIIMap.put(45,'AT');
        ASCIIMap.put(46,'AU');
        ASCIIMap.put(47,'AV');
        ASCIIMap.put(48,'AW');
        ASCIIMap.put(49,'AX');
        ASCIIMap.put(50,'AY');
        ASCIIMap.put(51,'AZ');
        String s = ASCIIMap.get(i);

        Lead newLead = new Lead( );
        newLead.LastName = 'TestLead' + s;
        newLead.FirstName = 'Sam';
        newLead.Address_State__c = state;
        newLead.PostalCode = zipCode;
        newLead.Company = companyName;
        newLead.Email = 'test_' + s + '@alteryx.com';
        newLead.LeadSource = 'Web Referral';
        if ( revenue != null && revenue > 0 ) {
            newLead.AnnualRevenue = revenue;
        }
        if (owner != null) {
            newLead.ownerId = owner;
        }
        return newLead;
    }

    public static void assignLeadsToQueue( List<Lead> theLeads, String queueName )
    {
        // first check to see if our queue exists, if not create it
        List<Group> groupIDs = [Select Id from Group where type = 'Queue' AND Name = :queueName];
        if ( groupIDs.size( ) == 0 )
        {
            Group groupObj = new Group( Name=queueName, Type='Queue' );
            insert groupObj;

            QueueSobject aQueue = new QueueSobject( QueueId = groupObj.Id, SobjectType = 'Lead' );
            System.runAs( new User( Id = UserInfo.getUserId( ) ) )
            {
                insert aQueue;
            }

            for ( Lead l : theLeads )
            {
                l.OwnerId = groupObj.Id;
            }
        } else if ( groupIDs.size( ) == 1 ) {
            for ( Lead l : theLeads )
            {
                l.OwnerId = groupIDs[0].Id;
            }
        } else {
            System.debug( 'MB: ERROR - we got back more than one group ID: ' + groupIDs.size( ) );
        }

        update theLeads;
    }

    public static Account buildTestAccount( String accountName, String hqState, Id ownerId )
    {
        Account newAccount = new Account( );
        newAccount.Name = accountName;
        newAccount.State__c = hqState;
        newAccount.Type = 'Prospect';
        newAccount.OwnerId = ownerId;
        return newAccount;
    }
    
    public static Territory_Zip_Code__c buildTerritory( String zipCode, Id directRep, Id insideRep, Id webRep, String HQState  )
    {
        Territory_Zip_Code__c tzCode = new Territory_Zip_Code__c( );
        tzCode.Name = zipCode;
        tzCode.NAD__c = directRep;
        tzCode.SaaS__c = insideRep;
        tzCode.Alteryx_Web_Account_Exec__c = webRep;
        tzCode.HQ_State__c = HQState;
        return tzCode;
    }
}