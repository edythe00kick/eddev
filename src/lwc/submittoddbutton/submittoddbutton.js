/**
 * Created by ewong on 4/1/2020.
 */


import {api,wire,track,LightningElement} from 'lwc';
import {refreshApex} from '@salesforce/apex';
import updateQuoteOwnerToDD from '@salesforce/apex/SubmitToDealDeskController.updateQuoteOwnerToDD';

export default class Submittodealdeskbutton extends LightningElement {
    @api recordId;
    @api isLoaded = false;

    toggle(){
        this.isLoaded = !this.isLoaded;
    }


    handleSubmitToDD() {
        console.log("inside isLoaded2", this.isLoaded);
        this.isLoaded = true;
        console.log("inside isLoaded3", this.isLoaded);
        console.log("inside handleSubmitToDD",  this.recordId);

        updateQuoteOwnerToDD({recordId: this.recordId})
            .then(result => {
                if(result){
                    window.location.reload();
                    console.log("Success: ", JSON.stringify(result));
                }

            })
            .catch(error => {
                console.log("Error: ", JSON.stringify(error));
        })
    }



}