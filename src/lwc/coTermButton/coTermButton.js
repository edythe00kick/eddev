/**
 * Created by csalgado on 6/7/2020.
 */

import {api, LightningElement, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CoTermButton extends LightningElement {
    @api recordId;
    @track modalState = false;

    openModal() {
        this.modalState = true
    }
    closeModal() {
        this.modalState = false
    }
}