/**
 * Created by csalgado on 6/16/2020.
 */

import {api, LightningElement} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import coTermOpportunity from '@salesforce/apex/CoTermOppController.coTermOpp';

export default class CoTermForm extends LightningElement {
    @api parentRecordId;
    @api  selectedContractId;

    @api
    coTermOpp() {
        console.log('coTermOpp - selectedContract.Id: ', this.selectedContractId);
        coTermOpportunity({oppId: this.parentRecordId, contractId: this.selectedContractId})
            .then(result => {
                console.log('Result: ', result);
                if(result){
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Updated Opp Id: ' + this.parentRecordId + ' with Amended Contract Id: ' + this.selectedContractId,
                        duration: 10000
                    });
                    this.dispatchEvent(event);
                    //Toast End

                    //Close Modal

                    const parentCloseModal = new CustomEvent('updatecomplete', {detail: true})
                    this.dispatchEvent(parentCloseModal);
                }
                else{
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Unable to update Opp Id: ' + this.parentRecordId + ' with Amended Contract Id: ' + this.selectedContractId
                    });
                    this.dispatchEvent(event);
                    //Toast End
                }
            })
            .catch(error => {
                console.log('error: ', error);
            });
    }
}