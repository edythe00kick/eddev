/**
 * Created by csalgado on 6/16/2020.
 */

import {api, track, LightningElement} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [/*{label: 'Contract Id', fieldName: 'Id', type: 'String'},*/
    {label: 'Account Name', fieldName: 'Account_Name__c', type: 'String'},
    {label: 'Contract Number', fieldName: 'ContractNumber', type: 'Integer'},
    {label: 'Start Date', fieldName: 'StartDate', type: 'Date'},
    {label: 'End Date', fieldName: 'EndDate', type: 'Date'},
    /*{label: 'Contract Name', fieldName: 'Name', type: 'String'}*/];

export default class CoTermTable extends LightningElement {
    @api contractList;
    @api error
    @track columns = columns;

    verifyContract(){
        //Get Selected Contracts
        let dataTbl = this.template.querySelector('lightning-datatable');
        const selectedContracts =  dataTbl.getSelectedRows();
        console.log('selectedContracts:', JSON.stringify(selectedContracts));

        // Create the event with data
        const selectedEvent = new CustomEvent("contractselect", {
            detail: selectedContracts[0].Id
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}