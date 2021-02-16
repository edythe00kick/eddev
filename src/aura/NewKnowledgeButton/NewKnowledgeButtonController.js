/**
 * Created by csalgado on 12/17/2019.
 */

({
    openModal: function(component, event, helper){
        component.set("v.modalState", true);
        let modalBack = component.find("knowledgeModal-back");
        $A.util.addClass(modalBack, 'slds-fade-in-open');
    },
    closeModal: function(component, event, helper){
        component.set("v.modalState", false);
        let modalBack = component.find("knowledgeModal-back");
        $A.util.removeClass(modalBack, 'slds-fade-in-open');
    },

    saveKnowledge: function(component,event, helper){
        console.log('Save In Progress..');
        let knowledgeForm = component.find('knowledgeForm');
        knowledgeForm.createKnowledge();
    }
});