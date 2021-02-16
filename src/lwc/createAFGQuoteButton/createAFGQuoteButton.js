/**
 * Created by ewong on 11/13/2020.
 * @Name Eddie Wong
 * @Work W-006358
 * @Date 11/16/2020
 * @Description Create AFG Quote lightning web component button
 */

import {api,wire,track,LightningElement} from 'lwc';
import {refreshApex} from '@salesforce/apex';
import createAFGOpportunity from '@salesforce/apex/CreateAFGQuote.createAFGOpportunity';

export default class CreateAfgQuoteButton extends LightningElement {
    @api recordId;
    @api isLoaded = false;

    toggle(){
        this.isLoaded = !this.isLoaded;
    }

    handleCreateAFGQuote() {
        console.log("inside  isLoaded2", this.isLoaded);
        this.isLoaded = true;
        console.log("inside isLoaded3", this.isLoaded);
        console.log("inside handleCreateAFGQuote",  this.recordId);

        createAFGOpportunity({recordId: this.recordId})
            .then(result => {
                if(result){
                    window.top.location.href = result;
                    console.log("Success: ", JSON.stringify(result));
                }
            })
            .catch(error => {
                console.log("Error: ", JSON.stringify(error));
            })

    }

}