trigger CompleteFirstResponseEmail on EmailMessage (after insert) {
    if (UserInfo.getUserType() == 'Standard'){
    DateTime completionDate = System.now();
    Map<Id, String> emIds = new Map<Id, String>();
    for (EmailMessage em : Trigger.new){
        if(em.Incoming == false)
        emIds.put(em.ParentId, em.ToAddress);
    }
    if (!emIds.isEmpty()){
        Set <Id> emCaseIds = new Set<Id>();
        emCaseIds = emIds.keySet();
        
        List<Case> caseList = [Select c.Id, c.ContactId,c.Contact.Email,
                                c.OwnerId, c.Status,
                                c.EntitlementId,RecordTypeId,
                                c.SlaStartDate, c.SlaExitDate
                                From Case c 
                                where c.Id IN :emCaseIds AND
                                c.RecordType.name = 'Alteryx Standard Case'];
        if (!caseList.isEmpty()){
            List<Id> updateCases = new List<Id>();
            for (Case caseObj:caseList) {
                String contact_email = caseObj.Contact.Email;
                String from_address = emIds.get(caseObj.Id);
                if( !(String.ISBLANK(contact_email)) &&
                    !(String.ISBLANK(from_address )) &&
                    (emIds.get(caseObj.Id).Contains(caseObj.Contact.Email)) &&
                    (caseObj.EntitlementId != null)&&
                    (caseObj.SlaStartDate != null)&&
                    (caseObj.SlaExitDate == null)&&
                    (caseObj.SlaStartDate <= completionDate))
                    
                updateCases.add(caseObj.Id);
            }
            
            if(!updateCases.isEmpty())
            milestoneUtils.completeMilestone(updateCases,
            'Response Time', completionDate);
            }
        }
    }
}