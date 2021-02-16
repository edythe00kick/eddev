public class MilestoneUtils {
    public static void completeMilestone(List<Id> caseIds,
                                         String milestoneName, DateTime complDate) {
                                             List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                                                                from CaseMilestone cm
                                                                                where caseId in :caseIds and cm.MilestoneType.Name != :milestoneName // Added "!=" :milestoneName by: Sharma Nemani | W-011382 | Case: 00263848 | Date: 09/09/2019
                                                                                and completionDate = null limit 1];
                                             system.debug('milestone ---'+ cmsToUpdate);
                                             system.debug('milestone name ---'+ milestoneName);
                                             system.debug('case ids ---'+ caseIds);


                                             if (cmsToUpdate.isEmpty() == false){
                                                 for (CaseMilestone cm : cmsToUpdate){
                                                     cm.completionDate = complDate;
                                                 }
                                                 update cmsToUpdate;
                                             }
                                         }
}