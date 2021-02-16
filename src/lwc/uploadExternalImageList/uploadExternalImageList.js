/**
 * Created by chris on 1/27/2020.
 */

import { api, LightningElement, track } from 'lwc';
import getExternalImageURLs from '@salesforce/apex/UploadExternalImageController.getExternalImageURLs';
const columns = [{label: 'External Image URL', fieldName: 'External_URL__c', type: 'String'}];

export default class UploadExternalImageList extends LightningElement {
    @api parentRecordId;
    @track columns = columns;
    @track eius;
    @track catchError;

    connectedCallback() {
            this.getEUIs();
        }

    @api
    getEUIs() {
        getExternalImageURLs({kavId: this.parentRecordId})
            .then(result => {
                console.log("Success: ", JSON.stringify(result));
                this.eius = result;
            })
            .catch(error => {
                console.log("Error: ", error);
                this.catchError = error
            });
    }
}