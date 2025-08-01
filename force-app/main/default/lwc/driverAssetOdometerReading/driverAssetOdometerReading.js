import { LightningElement, api, wire, track} from 'lwc';
import { createRecord, deleteRecord, getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {CurrentPageReference} from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
import getOdometerReading from '@salesforce/apex/AssetAssignmentController.getOdometerReading';
import UserId from '@salesforce/user/Id';
import ASSETODOMETERREADING_OBJECT from '@salesforce/schema/Asset_Odometer_Reading__c';
import AORASSET_FIELD from '@salesforce/schema/Asset_Odometer_Reading__c.Asset__c';
import AORID_FIELD from '@salesforce/schema/Asset_Odometer_Reading__c.Id';
import AOROWNERID_FIELD from '@salesforce/schema/Asset_Odometer_Reading__c.OwnerId';
import AORODOMETERTODAY_FIELD from '@salesforce/schema/Asset_Odometer_Reading__c.Odometer_Today__c';


export default class DriverAssetOdometerReading extends LightningElement {

    //Current User ID
    @track strUserId = UserId;

    @wire (CurrentPageReference) pageRef;
    connectedCallback() {
        registerListener('assetvalue',this.handleAssetData, this);
    }

    //@track assetOdometerID;
    createAssetOdometer(event){

        if(this.selectedAsset == null){
            const evt = new ShowToastEvent({
                title: 'Application Error',
                message: 'You need to select an Asset first.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }else{

            const fields = {};
            fields[AORASSET_FIELD.fieldApiName] = this.selectedAsset;
            fields[AOROWNERID_FIELD.fieldApiName] = this.strUserId;
            const recordInput = { apiName: ASSETODOMETERREADING_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(assetodometerreading => {
                    //this.assetdriverassignID = assetdriverassign.id;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Asset Odometer Reading added ' ,
                            variant: 'success',
                        }),
                    );
                    return refreshApex(this.assetOdometerget);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error adding Asset Odometer Reading',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });

            this.selectedAsset = null;

            //Remove selected asset
            var eventParam = {'selectedassetid': this.selectedAsset};

            fireEvent(this.pageRef, 'removeselectedasset',eventParam);
            
        }
    }

    @track selectedAsset = null;
    handleAssetData(detail){
        this.selectedAsset = detail.selectedvalueid;
        
    }

    //List of Asset Odometer Reading
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
         
            //Check if there is a record
            if (this.assetOdometerList.length > 0) {
                this.isOdometerRecord = true;
            } else {
                this.isOdometerRecord = false;
            }
        }
        else if (error) { this.error; }
        
    }


    updateOdometerReading(event){

        const straorid = event.target.dataset.aorid;
        const strcurrentodometer = this.template.querySelector("lightning-input[data-currentodometer=" + event.target.dataset.aorid + "]").value;
        const strodometertoday = this.template.querySelector("lightning-input[data-odometertoday=" + event.target.dataset.aorid + "]").value;
        const strassetid = event.target.dataset.assetid;
        const intcurrentodometer = parseInt(strcurrentodometer, 10);
        const intodometertoday = parseInt(strodometertoday, 10);

        if ((strodometertoday == '') || (strodometertoday == null)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Odometer Today field should not be blank.',
                    variant: 'error',
                    mode: 'dismissable'
                })               
            );

        } else if (intcurrentodometer >= intodometertoday) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Odometer Today reading must be greater than Current Odometer.',
                    variant: 'error',
                    mode: 'dismissable'
                })               
            );

        } else {

            // Create the recordInput object
            const fields = {};
            fields[AORID_FIELD.fieldApiName] = straorid;
            fields[AORODOMETERTODAY_FIELD.fieldApiName] = intodometertoday;

            const recordInput = { fields };
            
            //update ASSET ODOMETER READING 
            updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Update successfully',
                        message: 'Current Odometer Reading updated.',
                        variant: 'success'
                    })
                );
                // refresh asset list
                return refreshApex(this.assetOdometerget);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Current Odometer Reading.',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });         
        }
    }

    deleteOdometerReading(event){

        deleteRecord(event.target.dataset.aoriddelete)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Record Deleted',
                    message: 'Odometer Reading has been removed from the list.',
                    variant: 'success',
                    mode: 'dismissable'
                })
            );
            return refreshApex(this.assetOdometerget);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Deleting Record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });


    }
    
}