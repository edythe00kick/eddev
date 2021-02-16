/**
 * Created by chris on 1/28/2020.
 */

import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import archiveKnowledgeArticle2 from '@salesforce/apex/KnowledgeArchiveOverrideController.archiveKnowledgeArticle';

export default class ArchiveKnowledgeArticle extends LightningElement {
    @api recordId;

    archiveArticle(){
        archiveKnowledgeArticle2({knowledgeId: this.recordId})
            .then(result => {
                console.log('Result: ', result);
                if(result === 'Success'){
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Knowledge Article successfully archived. Please refresh tab/ page',
                    });
                    this.dispatchEvent(event);
                    //Toast End
                    //Refresh the Page
                    eval("$A.get('e.force:refreshView').fire();");
                }
                else if(result === 'Archive Issue'){
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'Unable to archive Knowledge Article. Please make sure there is no Draft Version.',
                    });
                    this.dispatchEvent(event);
                    //Toast End
                }
                else if(result === 'Already Archived'){
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'Knowledge Article already archived.',
                    });
                    this.dispatchEvent(event);
                    //Toast End
                }
                else if(result === 'Only Published'){
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'Only Published Knowledge Article can be archived.',
                    });
                    this.dispatchEvent(event);
                    //Toast End
                }
                else if(result === 'Not Latest'){
                    //Toast Start
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'Only the latest Knowledge Article can be archived.',
                    });
                    this.dispatchEvent(event);
                    //Toast End
                }
                else{
                    console.log('Error: Unknown Issue!')
                }
            })
            .catch(error => {
                console.log('Error: ', error);
            });
        }
    }