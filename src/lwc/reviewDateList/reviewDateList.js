/**
 * Created by Ed on 12/27/19.
 */

import {api, LightningElement, track} from 'lwc';
import getCustomKnowledgeArticleId from '@salesforce/apex/ReviewDateController.getCustomKnowledgeArticleId';
const columns = [{label: 'Current Review Date', fieldName: 'Review_Date__c', type: 'date-local'}];

export default class ReviewDateList extends LightningElement {
@api recordId;
@track columns = columns;
@track reviewDate;
@track error;

    connectedCallback() {
        this.outerGetMethod();
    }
    outerGetMethod() {
        getCustomKnowledgeArticleId({recordId: this.recordId})
            .then(result => {
            console.log("Success: ", JSON.stringify(result));
            this.reviewDate = result;
    })
    .catch(error => {
            console.log("Error: ", error);
        this.error = error
    });
    }
    handleReviewDateInserted(event){
        console.log("handleReviewDateInserted: s",event.detail)
        this.outerGetMethod();
    }
}