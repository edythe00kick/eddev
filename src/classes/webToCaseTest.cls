@isTest
public class webToCaseTest{
    
    Public static testmethod void scenario1(){
        Account Acc = new Account(name = 'Test Account');
        Insert Acc;
        
        Contact con = new Contact(AccountId=acc.id,Firstname='Contact',LastName='Test contact',email='testcontact@alteryx.com',Phone='9878158495');
        Insert con;
        System.debug('@@@Contact' + con);
        
        Case cas = new case(Subject='Test this Code',Description='This Description',Products__c ='Data',Business_System_Category__c='Feature Enhancement',Business_System__c='SFDC',Requested_Completion_Date__c=Date.today().AddDays(7),Case_Category__c='SDK',Severity__c='SEV 1');
        Insert cas;  
        
        PageReference pageRef = Page.WebToCase;
        pageRef.getParameters().put('contactEmail','testcontact@alteryx.com');
        pageRef.getParameters().put('BusinessSystem', 'Business System');
        pageRef.getParameters().put('BusinessSystemCateg', 'Business System Category');
        pageRef.getParameters().put('caseId',cas.id);
        
        Test.setCurrentPageReference(pageRef);
        WebToCaseController cont = New WebToCaseController();
        Cont.contactPhone = con.phone;
        Cont.contactName = con.Name;
        Cont.contactEmail = con.email;
        Cont.c.id=cas.id;
        cont.caseId = cas.id;
        cont.SearchContact();
        Blob b1 = Blob.valueOf( 'Test Data' );
        Attachment testAttachment1 = new Attachment();
        testAttachment1.Name = 'Test Project Issue Attachment';
        testAttachment1.Body = b1;
        testattachment1.parentId = cas.Id;
        insert testAttachment1;
        cont.anAttachment= testAttachment1;
        Cont.c.subject = 'Test';
        Cont.c.description= 'Test';
        Cont.c.Business_System__c = 'SFDC';
        Cont.c.Requested_Completion_Date__c = system.today().addDays(2);
        Cont.c.Business_System_Category__c = 'Feature Enhancement';
        //String srt = WebToCaseController.saveattach(cas.id,null,'Test3','Test4','Test1');
        cont.userAgent = 'test';
        cont.isIe = false;
        Cont.attachment();
        Cont.save();
        Cont.attachment();
        Cont.Reset();
        Cont.cancel();
        system.debug('@@@1 cont.contactEmail ' + Cont.contactEmail + 'Phone ' + Cont.contactPhone + 'Name ' + Cont.contactName + '  ' + cas );
   
    }
    
    Public static testmethod void scenario2(){
        Account Acc = new Account(name = 'Test Account');
        Insert Acc;
        
        Contact con = new Contact(AccountId=acc.id,Firstname='Contact',LastName='Test contact',email='testcontact@alteryx.com',Phone='9878158495');
        Insert con;
        
        Contact con1 = new Contact(AccountId=acc.id,Firstname='Contact',LastName='Test contact',email='testcontact@alteryx.com',Phone='9878158495');
        Insert con1;
        
        Contact con2 = new Contact(AccountId=acc.id,Firstname='Contact',LastName='Test contact',email='testcontact@yahoo.com',Phone='9878158495');
        Insert con2;
        
        Case cas = new case(Subject='Test this Code',Description='This Description',Products__c ='Data',Business_System_Category__c='',Business_System__c='',Requested_Completion_Date__c=null,Case_Category__c='SDK',Severity__c='SEV 1');
        Insert cas;  
        
        Case cas1 = new case(Subject='Test Subject',Description='Test Subject',Business_System_Category__c='Feature Enhancement',Business_System__c='SFDC',Requested_Completion_Date__c=System.today(),Case_Category__c='SDK',Severity__c='SEV 1',Products__c ='Data');
        Insert cas1;  
        
        
        PageReference pageRef1 = Page.WebToCase;
        pageRef1.getParameters().put('contactEmail','testcontact@alteryx.com');
        pageRef1.getParameters().put('BusinessSystem', 'Business System');
        pageRef1.getParameters().put('BusinessSystemCateg', 'Business System Category');
        pageRef1.getParameters().put('caseId',cas1.id);
        Test.setCurrentPageReference(pageRef1);
        
        WebToCaseController cont1 = New WebToCaseController();
        Blob b1 = Blob.valueOf( 'Test Data' );
        Attachment testAttachment1 = new Attachment();
        testAttachment1.parentId=cas1.id;
        testAttachment1.Name = 'Test Project Issue Attachment';
        testAttachment1.Body = b1;
        insert testAttachment1;
        cont1.anAttachment= testAttachment1;
        //String srt = WebToCaseController.saveattach('','x','Test3','Test4','Test1');
        Cont1.save();
        Cont1.searchContact();
        Cont1.attachment();
        Cont1.reset();
        Cont1.cancel();
        
        
        PageReference pageRef = Page.WebToCase;
        pageRef.getParameters().put('contactEmail','testcontact@gmail.com');
        Test.setCurrentPageReference(pageRef);
        
        WebToCaseController cont = New WebToCaseController();
        Cont.c = cas1;
        Cont.save();
        Cont.searchContact();
        Cont.attachment();
        
        PageReference pageRef2 = Page.WebToCase;
        pageRef2.getParameters().put('contactEmail','testcontact@yahoo.com');
        Test.setCurrentPageReference(pageRef2);
        
        WebToCaseController cont2 = New WebToCaseController();
        Cont2.c = cas1;
        Cont2.contactEmail = 'testcontact@yahoo.com';
        Cont2.save();
        Cont2.searchContact();
        Cont2.attachment();
    }  
    
    Public static testmethod void scenario3(){
        Account Acc = new Account(name = 'Test Account');
        Insert Acc;
        
        Contact con = new Contact(AccountId=acc.id,Firstname='Contact',LastName='Test contact',email='testcontact@alteryx.com',Phone='9878158495');
        Insert con;
        System.debug('@@@Contact' + con);
        
        Case cas = new case(Subject='Test this Code',Description='This Description',Products__c ='Data',Business_System_Category__c='Feature Enhancement',Business_System__c='SFDC',Requested_Completion_Date__c=Date.today().AddDays(7),Case_Category__c='SDK',Severity__c='SEV 1');
        Insert cas;  
        
        PageReference pageRef = Page.WebToCase;
        pageRef.getParameters().put('contactEmail','testcontact@alteryx.com');
        pageRef.getParameters().put('BusinessSystem', '');
        pageRef.getParameters().put('BusinessSystemCateg', '');
        
        Test.setCurrentPageReference(pageRef);
        WebToCaseController cont = New WebToCaseController();
        cont.contactEmail = 'testcontact@alteryx.com';
        cont.caseId = cas.id;
        Cont.save();
        /*
        PageReference pageRef1 = Page.WebToCase;
        pageRef1.getParameters().put('contactEmail','');
        pageRef1.getParameters().put('BusinessSystem', '');
        pageRef1.getParameters().put('BusinessSystemCateg', '');
        
        Test.setCurrentPageReference(pageRef);
        WebToCaseController cont1 = New WebToCaseController();
        cont1.email_error = false;
        cont1.caseId = cas.id;
        Cont1.save();*/
   
    }  
}