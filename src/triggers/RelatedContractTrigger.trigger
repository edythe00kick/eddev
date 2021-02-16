/* Author: Sharma Nemani | W-011617
 * Date: 06/10/2019
 * Description: Trigger for the RelatedContracts Object.
 */
trigger RelatedContractTrigger on Related_Contract__c (After Insert,After Update,before delete) {

    //Eddie Wong
    //Date: 03/12/2020
    //W-004742
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Related_Contract_Trigger_Admin_Bypass__c == false) {
        if(RelatedContractHandler.runOnce && trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            RelatedContractHandler.runOnce();
            RelatedContractHandler.afterInsertUpdateRC(trigger.newMap);
        }else if(RelatedContractHandler.runOnce && trigger.isBefore && trigger.isDelete){
            RelatedContractHandler.runOnce();
            RelatedContractHandler.afterDeleteRC(trigger.oldMap);
        }

    }

}