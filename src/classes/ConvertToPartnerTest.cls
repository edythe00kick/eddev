@Istest
Public Class ConvertToPartnerTest{
    Public static TestMethod Void  converttopartnerTestmethod(){
        List<Lead> LdList = New List<Lead>();
        Lead ld = New Lead(LastName='Test',Company='Alteryx',LeadSource='Leadspace',CurrencyIsoCode='USD',Status='1 - Not Contacted',Recordtypeid=Lead.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Lead Record Type').getRecordTypeId());
        Ldlist.add(ld);
        Lead ld1 = New Lead(LastName='Test1',Company='Alteryx',LeadSource='Leadspace',CurrencyIsoCode='USD',Status='1 - Not Contacted',Recordtypeid=Lead.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Lead Record Type').getRecordTypeId());
        Ldlist.add(ld1);
        Insert ldlist;
        ApexPages.StandardSetController sc = New Apexpages.StandardSetController(Ldlist);
        sc.SetSelected(ldlist);
        ConvertToPartner Ext = New ConvertToPartner(Sc);
        Ext.Convert();
        Ext.Cancel();
    }
    Public Static testMethod Void COnverttoPartnerElseTest(){
        List<Lead> LdList = New List<Lead>();
        Insert ldlist;
        Profile p = [Select id from profile where Name = 'Alteryx - Sales - Business Development'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='stasddr@testorg.com');
        System.runAs(u) {
        ApexPages.StandardSetController sc = New Apexpages.StandardSetController(Ldlist);
        sc.SetSelected(ldlist);
        ConvertToPartner Ext = New ConvertToPartner(Sc);
        Ext.Convert();
        Ext.Cancel();
        }
    }
}