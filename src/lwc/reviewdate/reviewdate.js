/**
 * Created by ewong on 12/23/2019.
 */

import {api, track,LightningElement} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertReviewDate from '@salesforce/apex/ReviewDateController.insertReviewDate';
import removeReviewDateDB from '@salesforce/apex/ReviewDateController.removeReviewDateDB';
import getCurrentReviewDate from '@salesforce/apex/ReviewDateController.getCurrentReviewDate';

export default class Reviewdate extends LightningElement {
    @api parentRecordId;
    @track modalState = false;
    @track reviewDate;

    dateOnChange(event){
        this.reviewDate = event.target.value;
        console.log("Date Change: ", this.reviewDate);
        console.log("recordId = ", this.recordId);
    }
    openModal() {
        //Name: Chris Salgado Date: 1/27/20 Purpose: Auto-Populate Date
        getCurrentReviewDate({recordId: this.parentRecordId})
                .then(result =>{
                    console.log("Current Review Date: ", result);
                    this.reviewDate = result;
                })
                .catch(error =>{
                    console.log("Error: ", error);
                })
        this.modalState = true
    }
    closeModal() {
        this.modalState = false
    }

    saveMethod() {
        console.log("Save Comment: ", this.comment);
        console.log("Review Date: ", this.reviewDate);

        const convertedDate = new Date(this.reviewDate);
        const Today = new Date();

        //Compare the Review Date to Today
        if(!(convertedDate < Today)){
            insertReviewDate({recordId: this.parentRecordId, reviewDate: this.reviewDate})
                .then(result => {
                if(result){
                    console.log("Success: ", JSON.stringify(result));
                    //Refresh the Current Review Date
                    const newRDEvent = new CustomEvent('reviewdateinserted', {
                        detail: true,
                    });
                    this.dispatchEvent(newRDEvent);
                }
                else{
                    console.log("Error: ", result);
                }})
                .catch(error => {
                    console.log("Error: ", JSON.stringify(error));
                });
            this.closeModal();
        }
        else{
            //Toast Start
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Review Date must be greater than Today.',
            });
            this.dispatchEvent(event);
            //Toast End
        }
    }

    removeReviewDateButton(){
        removeReviewDateDB({recordId: this.parentRecordId})
            .then(result => {
            if(result){
                console.log("Removal Review Date Success", JSON.stringify(result));
                //Refresh the Current Review Date
                const newRDEvent = new CustomEvent('reviewdateinserted', {
                    detail: true,
                });
                this.dispatchEvent(newRDEvent);
            }
            else{
                console.log("Error: ", result);
    }
    })
    .catch(error => {
            console.log("Error: ", JSON.stringify(error));
    });
        this.closeModal();
    }
}