/**
 * Created by csalgado on 12/16/2019.
 */

import {api, LightningElement, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllKnowledgeComments from '@salesforce/apex/KnowledgeCommentController.getKnowledgeComments';
const columns = [
    {label: 'Flagged', fieldName: 'Active__c', type: 'boolean'},
    //{label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Comment', fieldName: 'Comment__c', type: 'text'},
    {label: 'Written By', fieldName: 'CreatedByName__c', type: 'text'},
    {label: 'Created Date', fieldName: 'CreatedDate', type:'date'}
];

export default class AllKnowledgeCommentList extends LightningElement {
    @api recordId;
    @track columns = columns;
    @track knowledgeComments;

    connectedCallback() {
        this.outerGetMethod();
    }
    outerGetMethod() {
        getAllKnowledgeComments({knowledgeArticleId: this.recordId})
            .then(result => {
                console.log("Success: ", JSON.stringify(result));
                this.knowledgeComments = result;
                //Toast Start
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Returned the Knowledge Comment List.',
                });
                //this.dispatchEvent(event);
                //Toast End
            })
            .catch(error => {
                console.log("Error: ", error);
                this.error = error
                //Toast Start
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'Issue with get Knowledge Comment List.',
                });
                this.dispatchEvent(event);
                //Toast End
            });
    }
    handleKCInserted(event){
            console.log("handleKCInserted: ",event.detail)
            this.outerGetMethod();
    }
}