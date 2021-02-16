@isTest
public class TestAccountTeamMember{
    static testmethod void AddAccountTeamMembers(){
        Account a = new Account(name='TestAccountt',recordtypeid='012E0000000VROtIAO',phone='9876543201',CurrencyIsoCode='USD' );
        insert a; 
        //AccountTeamMember atm = new AccountTeamMember(accountId= a.id,TeamMemberRole='Client Services Representative',UserId='005E0000004Kjeg'  );
        AccountTeamMember atm = new AccountTeamMember(accountId= a.id,TeamMemberRole='Client Services Representative',UserId='005E0000002xHXz'  );
        insert atm;
       UpdateAccountWithTeamMemberRolesNew obj = new UpdateAccountWithTeamMemberRolesNew();
       Database.ExecuteBatch(obj);
    }
}