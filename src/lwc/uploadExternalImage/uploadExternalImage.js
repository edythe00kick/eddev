/**
 * Created by chris on 1/7/2020.
 */

import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertExternalImageURL from '@salesforce/apex/UploadExternalImageController.insertExternalImageURL';
import insertExternalImageURL2 from '@salesforce/apex/UploadExternalImageController.insertExternalImageURL2';
import sendExternalImageRequest from '@salesforce/apex/UploadExternalImageController.sendExternalImageRequest';
import {loadStyle, loadScript} from 'lightning/platformResourceLoader';


export default class UploadExternalImage extends LightningElement {
@api recordId;
@track modalState = false;
@track imageURL = '';
@track imageFile;

openModal() {
        this.modalState = true;
    }
    closeModal() {
        this.modalState = false;
    }

    saveMethod() {
            this.imageURL = '<img src="https://live.staticflickr.com/2441/3999457568_9e6f4e4fcf_m.jpg"/>';
            const event = new ShowToastEvent({
                        title: 'No Title',
                        message: 'Nothing happened..',
                    });
                    this.dispatchEvent(event);
            this.closeModal();
        }

    uploadMethod(){
        //Get Image File
        const tempFile = this.template.querySelector('input') /*document.getElementById('fileInput').files[0]*/;
        const selectedFile = tempFile.files[0];
        const reader = new FileReader();
        //reader.readAsText(selectedFile, 'UTF-8');
        reader.readAsDataURL(selectedFile);
        reader.onload = readerEvent => {
            const content = readerEvent.target.result;
            //console.log('**CSALGADO**  :  ' + content);
            //console.log('Image Here!');


            const http = new XMLHttpRequest();
            const url = 'https://alteryx-test.boomi.cloud/ws/simple/SFDC_To_Community_Inline;boomi_auth=UUFAYWx0ZXJ5eC05MjFYUkQuOVZJQkxaOjJkODMzNDEyLTk4ZWItNDJhZi1hZTNmLTQ0NTdjMzI5YWQ2YQ==';
            let obj = {request: {
                            data: {
                                type: 'image',
                                title: 'test title',
                                field: content,
                                description: 'test description'
                                }
                            }
                        };
            const jsonBody = JSON.stringify(obj);
            http.open('POST', url);
            http.setRequestHeader( 'Access-Control-Allow-Origin', '*');
            //http.send(jsonBody);
            http.send(jsonBody);
            http.onreadystatechange= (e) =>{
                console.log(http.responseText);
            }
        }


        //Authorize with Service
        /*let client = new JSO({
            client_id: ,
            authorization: "https://www.flickr.com/services/oauth/request_token",
        })*/

        //Send HTTP Post Request
        /*const HTTP = new XMLHttpRequest();
        const url = '';
        HTTP.open("GET", URL);
        HTTP.send();
        HTTP.onreadystatechange = (e) => {
            console.log(HTTP.responseText);
        }*/

        /*const input = document.createElement('input');
        input.type = 'file';
        input.onchange = e => {
            const file = e.target.files[0];

            const reader = new FileReader();
            reader.readAsText(file, 'UTF-8');
            reader.onload = readerEvent => {
                const content = readerEvent.target.result;
                console.log('Image Here!');
            }
        }
        input.click();*/
    }

    uploadMethod2(){
        this.imageURL = 'Waiting on server...';

        const tempFile = this.template.querySelector('input');
        if(Object.entries(tempFile.files).length !== 0){
            insertExternalImageURL2({kavId: this.recordId})
            .then(result1=>{
                console.log('**CSALGADO** Result1: ', result1);

                const selectedFile = tempFile.files[0];
                const reader = new FileReader();
                reader.readAsDataURL(selectedFile);
                reader.onload = readerEvent => {
                    const content = readerEvent.target.result;
                    console.log('**CSALGADO** Content: ', content);
                    sendExternalImageRequest({content: content, eiuId: result1 /*this.imageFile*/})
                        .then(result2=>{
                            console.log('**CSALGADO** Result2: ', result2);
                            //Toast Start
                            const event = new ShowToastEvent({
                                title: 'Success!',
                                message: 'Image uploading, click the Refresh List button until the External Image URL appears.',
                            });
                            this.dispatchEvent(event);
                            //Toast End

                            //This needs to trigger from the child to the parent, so need to swap LWC's
                            /*const newEIUEvent = new CustomEvent('insertedExternalImageURL', {
                                detail: true,
                            });
                            this.dispatchEvent(newEIUEvent);*/

                            this.refreshList();
                            //this.template.querySelector('c-upload-external-image-list').getEUIs();

                            this.closeModal();
                        })
                        .catch(error2=>{
                            console.log('**CSALGADO** Error2: ', error2);
                            //Toast Start
                            const event = new ShowToastEvent({
                                title: 'Error!',
                                message: 'Unable to save External Image URL.',
                            });
                            this.dispatchEvent(event);
                            //Toast End
                        });
                }
                //Temp Solution
                //this.imageURL = '<img src="https://live.staticflickr.com/2441/3999457568_9e6f4e4fcf_m.jpg"/>';

                //TEST CODE
                /* After the imageURL is returned from the server the EIU is inserted into Salesforce*/
                        /*insertExternalImageURL({kavId: this.recordId, externalURL: this.imageURL})
                            .then(result=>{
                                if(result){
                                    //Toast Start
                                    const event = new ShowToastEvent({
                                        title: 'Success!',
                                        message: 'External Image URL saved.',
                                    });
                                    this.dispatchEvent(event);
                                    //Toast End

                                    this.closeModal();
                                }
                                else{
                                    //Toast Start
                                    const event = new ShowToastEvent({
                                        title: 'Error!',
                                        message: 'Unknown Error.',
                                    });
                                    this.dispatchEvent(event);
                                    //Toast End
                                }
                            })
                            .catch(error=> {
                                 console.log("Error: ", JSON.stringify(error));
                                 //Toast Start
                                 const event = new ShowToastEvent({
                                    title: 'Error!',
                                    message: 'Unable to save External Image URL.',
                                 });
                                 this.dispatchEvent(event);
                                 //Toast End
                            });*/
                //END TEST
            })
            .catch(error1 => {
                console.log('ERROR1: ', error1);
            });
        }
        else{
            //Toast Start
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Need to choose a file before clicking Upload.',
            });
            this.dispatchEvent(event);
            //Toast End
        }
    }

    refreshList(){
        this.template.querySelector('c-upload-external-image-list').getEUIs();
    }
}