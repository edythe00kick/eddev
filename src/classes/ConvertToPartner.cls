public with Sharing Class ConvertToPartner {
    Public List<Lead> SelectedItems {Get;Set;}
    Public List<lead> LeadsToupdate;
    Public Lead ld {get;Set;}
    Public Boolean IsEditable {Get;Set;}
    Public Id profileId=userinfo.getProfileId();
    Public String ProfileName;
        
    Public ConvertToPartner(ApexPages.StandardSetController Controller){
        SelectedItems = controller.getSelected();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        LeadsToupdate = new List<Lead>();
        ld = New Lead();
        If(ProfileName !='Alteryx - Sales - Business Development' && ProfileName !='Alteryx - Sales - Sales Ops'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' <br>You are not allowed to perform this operation. <br> Please contact Sales Ops if you have any questions. '));            
            IsEditable=False;
            }
        Else{    
            If(SelectedItems.size()<=0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Kindly ensure that atleast one lead is selected.'));
                IsEditable = false;
            }Else{
                IsEditable = true;
            }
        }
    }    
       
    Public Pagereference Convert(){
        String LeadRep = ld.Partner_Representative__c;
        String LeadType = ld.Partner_Lead_Type__c;
        For(Lead l : SelectedItems){
        l.recordtypeid = Lead.sObjectType.getDescribe().getRecordTypeInfosByName().get('Partner Lead Record Type').getRecordTypeId();
        l.Partner_Representative__c = Leadrep;
        l.Partner_Lead_Type__c = LeadType;
        LeadsToupdate.Add(l);
        }
        If(LeadsToUpdate.Size()>0){
            Try{
                Update LeadsToUpdate;
            }
            Catch(Exception Ex){
                ApexPages.addMessages(ex);          
                return null;
            }
        }
        Return New Pagereference('/00Q');
    }
    public PageReference cancel(){
        return New Pagereference('/00Q'); 
    }        
}