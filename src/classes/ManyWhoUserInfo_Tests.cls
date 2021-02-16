@istest
public class ManyWhoUserInfo_Tests {

    private static testmethod void ManyWhoUserInfo() {
        ManyWhoUserInfo user = new ManyWhoUserInfo('id', 'url', 'tenant', 'user');
        String sessionId = user.sessionId;
        String sessionUrl = user.sessionUrl;
        String tenantId = user.tenantId;
        String userId = user.userId;
    }

}