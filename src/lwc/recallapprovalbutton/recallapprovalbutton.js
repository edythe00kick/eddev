/**
 * Created by ewong on 4/14/2020.
 */

import {api,wire,track,LightningElement} from 'lwc';
import updateRecallQuoteApproval from '@salesforce/apex/RecallApprovalController.updateRecallQuoteApproval';

export default class Recallapprovalbutton extends LightningElement {
    @api recordId;

    handleRecallApproval(){
        updateRecallQuoteApproval({recordId: this.recordId})
            .then(result => {
                if(result){
                    //window.location.reload();
                    console.log("Success: ", JSON.stringify(result));
                }
        })
        .catch(error => {
            console.error("Error: ", JSON.stringify(error));
        })
    }
}