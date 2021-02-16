/**
 * Created by csalgado on 12/16/2019.
 */

import {api, track,LightningElement} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertKnowledgeComment from '@salesforce/apex/KnowledgeCommentController.insertKnowledgeComment';

export default class NewKnowledgeCommentButton extends LightningElement {
    @api parentRecordId;
    @track modalState = false;
    @track comment;
    @track flagged = false;

    fieldOnChange(event){
        let fieldName = event.target.name;
        if(fieldName == 'commentTextArea')
        {
            this.comment = event.target.value;
        }
        else if(fieldName == 'flagCheckbox') {
            this.flagged = event.target.value;
        }
        else{
            console.log("Error: fieldName not recognized")
        }
    }
    openModal() {
        this.modalState = true
    }
    closeModal() {
        this.modalState = false
    }
    saveMethod() {
        console.log("Save Comment: ", this.comment);
        insertKnowledgeComment({knowledgeArticleId: this.parentRecordId, commentString: this.comment, active: this.flagged})
            .then(result => {
                if(result){
                    console.log("Success: ", JSON.stringify(result));
                    //Refresh the comment list
                    const newKCEvent = new CustomEvent('kcinserted',{
                        detail: true,
                    });
                    this.dispatchEvent(newKCEvent);
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Knowledge Comment saved.',
                    });
                    this.dispatchEvent(event);
                    //Toast End
                }
                else{
                    console.log("Error: ", result);
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'Unknown Error.',
                    });
                    this.dispatchEvent(event);
                    //Toast End
                }
            })
            .catch(error => {
                console.log("Error: ", JSON.stringify(error));
                this.error = error;
                //Toast Start
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'Unable to save Knowledge Comment.',
                });
                this.dispatchEvent(event);
                //Toast End
            });
        this.closeModal();
    }
}