/**
 * Created by csalgado on 6/7/2020.
 */

import {api, track, LightningElement} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContracts from '@salesforce/apex/CoTermOppController.getContractList';
import searchContracts from '@salesforce/apex/CoTermOppController.searchContractList';

export default class CoTermList extends LightningElement {
    @api parentRecordId;
    @track activeContracts;
    @track getError;
    @track contractNumber;
    @track queryContracts;
    @track searchError;
    @track selectedContractId;
    @track selected = false;

    //(Init) Tab 1 - Get Related Active Contracts
    connectedCallback() {
        //Call Apex Class
        getContracts({oppId: this.parentRecordId})
            .then(result => {
                console.log("Success1: ", JSON.stringify(result));
                this.activeContracts = result;
            })
            .catch(error => {
                console.log("Error: ", error);
                this.getError = error
            });
    }

    //Tab 2 - Contract Search
    updateContractNumber(event){
        this.contractNumber = event.target.value;
    }

    searchContracts(){
        console.log('Search! - this.contractNumber: ', this.contractNumber);
        //Call Apex Class
        searchContracts({contractNumber: this.contractNumber})
            .then(result => {
                console.log("Success2: ", JSON.stringify(result));
                this.queryContracts = result;
            })
            .catch(error => {
                console.log("Error: ", error);
                this.searchError = error
            });
    }

    //Table Row Selected
    contractSelected(event){
        console.log('Contract Selected!');
        //Set Selected Contract
        this.selectedContractId = event.detail;

        //Move to Step 2
        this.selected = true;
    }

    //End Program
    closeParentModal(){
        //Close Modal
        const parentCloseModal = new CustomEvent('closemodalpass', {detail: true})
        this.dispatchEvent(parentCloseModal);
    }
}