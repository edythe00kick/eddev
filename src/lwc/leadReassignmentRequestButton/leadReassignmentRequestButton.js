/**
 * Created by ewong on 10/20/2020.
 */

import {api, LightningElement, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import leadReassignemntEmailManager from '@salesforce/apex/LeadReassignmentController.leadReassignemntEmailManager';

export default class LeadReassignmentRequestButton extends LightningElement {
    @api parentRecordId;
    @api recordId;
    @track modalState = false;
    @track getError;
    @track getResult;
    //@track userId = Id;

    openModal() {
        this.modalState = true
    }

    closeModal() {
        this.modalState = false
    }

    emailMethod() {
        console.log("lead Id: ", this.parentRecordId);
        console.log("lead Id 2: ", this.recordId);
        //console.log("User Id: ", this.userId);

            leadReassignemntEmailManager({recordId: this.recordId})
                .then(result => {
                    console.log("Success: ", JSON.stringify(result));
                    this.getResult = result;
                })
                .catch(error => {
                    console.log("Error: ", JSON.stringify(error));
                    this.getError = error
                });
            this.closeModal();

    }

}