import { LightningElement, track, wire} from 'lwc';
import ADAID_FIELD from '@salesforce/schema/Asset_Driver_Assignment__c.Id';
import ADAODOMETER_FIELD from '@salesforce/schema/Asset_Driver_Assignment__c.Odometer_Reading__c';
import ASSETID_FIELD from '@salesforce/schema/Asset__c.Id';
import ASSETODOMETER_FIELD from '@salesforce/schema/Asset__c.Current_Odometer_Reading__c';
import getOdometerReading from '@salesforce/apex/AssetAssignmentController.getOdometerReading';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import {updateRecord} from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

export default class CommunityOdometer extends LightningElement {

    //@api recordId;

    //Query the Asset Assignment
    //List of Asset Assignment
    @track strUserId = Id;
    @track assetOdometerList;
    @track isOdometerRecord = false;
    @wire(getOdometerReading, { ownerId: '$strUserId'})
    odometerReading(value){
        this.assetOdometerget = value;

        const { data, error } = value; // destructure the provisioned value
        if (data) {
            this.assetOdometerList = data;
            if(data.data) {
                this.myData = data.data;
            }

            //alert (this.strUserId);
            
            //Check if there is a record
            if (this.assetOdometerList.length > 0) {
                this.isOdometerRecord = true;
            } else {
                this.isOdometerRecord = false;
            }
        }
        else if (error) { this.error; }
        
    }

    @track strcurrentodometer="";
    updateOdometerReading(event){

        this.strcurrentodometer = this.template.querySelector("lightning-input[data-id=" + event.target.dataset.adaid + "]").value;
        const strassetid = event.target.dataset.assetid;
        const strodometer = this.strcurrentodometer;
        const strodometercheck = parseInt(this.strcurrentodometer, 10);

        if ((this.strcurrentodometer == '') || (this.strcurrentodometer.length > 8) || (strodometercheck.toString() !== this.strcurrentodometer)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Update Warning',
                    message: 'Please enter correct Odometer Reading',
                    variant: 'warning',
                    mode: 'dismissable'
                })               
            );

        } else {
        
            // Create the recordInput object
            const fields = {};
            fields[ADAID_FIELD.fieldApiName] = event.target.dataset.adaid;
            fields[ADAODOMETER_FIELD.fieldApiName] = this.strcurrentodometer;
            const recordInput = { fields };

            //update asset driver assignment
            updateRecord(recordInput)
                .then(() => {

                    this.updateasset(strassetid, strodometer);

                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });


            
        }
    }

    updateasset(strassetid, strodometer){

        //alert('assetid: ' + strassetid);
        //alert('odometer: ' + strodometer);

        // Create the recordInput object
        const fields = {};
        fields[ASSETID_FIELD.fieldApiName] = strassetid;
        fields[ASSETODOMETER_FIELD.fieldApiName] = strodometer;

        const recordInput = { fields };
        
        //update asset 
        updateRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Update successfully',
                    message: 'Odometer Reading updated',
                    variant: 'success'
                })
            );
            // refresh asset list
            return refreshApex(this.assetOdometerget);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
            
        //return refreshApex(this.assetOdometerList);
    }

}