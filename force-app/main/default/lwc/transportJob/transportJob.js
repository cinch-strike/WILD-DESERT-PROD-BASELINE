import { LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TRANSPORTJOB_OBJECT from '@salesforce/schema/Transport_Job__c';
import TRANSPORTJOBID_FIELD from '@salesforce/schema/Transport_Job__c.Id';
//import TYPE_FIELD from '@salesforce/schema/Transport_Job__c.Types__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Transport_Job__c.Description__c';
import JOBDATE_FIELD from '@salesforce/schema/Transport_Job__c.Job_Date__c';
import STATUS_FIELD from '@salesforce/schema/Transport_Job__c.Status__c';
import KMRADIUS_FIELD from '@salesforce/schema/Transport_Job__c.Within_100km_Radius__c';
import TRANSPORTBASE_FIELD from '@salesforce/schema/Transport_Job__c.Transport_Base__c';
import SITE_FIELD from '@salesforce/schema/Transport_Job__c.Site__c';
import UNIT_FIELD from '@salesforce/schema/Transport_Job__c.Unit__c';
import BILLABLE_FIELD from '@salesforce/schema/Transport_Job__c.Billable__c';
import CATEGORY_FIELD from '@salesforce/schema/Transport_Job__c.Category__c';
import APPROVALNOTES_FIELD from '@salesforce/schema/Transport_Job__c.Approval_Notes__c';
import RESUBMITTEDTODSJ_FIELD from '@salesforce/schema/Transport_Job__c.Resubmitted_to_DSJ__c';
import DSJSSTATUS_FIELD from '@salesforce/schema/Transport_Job__c.DSJS_Status__c';
import{CurrentPageReference} from 'lightning/navigation';
import getDriverAssignNoContactJobItem from '@salesforce/apex/DriverAssignmentController.getDriverAssignNoContactJobItem';
import getDriverAssignNoConfiguration from '@salesforce/apex/DriverAssignmentController.getDriverAssignNoConfiguration';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
import {updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class TransportJob extends LightningElement {
    @api recordId;
    @wire (CurrentPageReference) pageRef;
    objectTransportJob = TRANSPORTJOB_OBJECT;
    TJfields = [DESCRIPTION_FIELD, JOBDATE_FIELD, KMRADIUS_FIELD, TRANSPORTBASE_FIELD, CATEGORY_FIELD];
    TJfieldsreadonly = [STATUS_FIELD, UNIT_FIELD, SITE_FIELD];
    handleSubmit(event) {
        const toastEvent = new ShowToastEvent({
            title: "Transport Job Updated",
            message: "Record updated",
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }

    @track isTJStatusDraft = true;
    @track isTJStatusCompleted = true;
    @track isTJStatusApproved = true;
    //@track isTJTypeRegular = true;   // 02 OCT 2023: C+S - Removed logic related to Type
    @track dteTJDate;  // 04 OCT 2023: C+S - Added for Driver Assignment Date
    @track isBillable = true;
    @track strstatus = '';
    @track strDSJSStatus = '';
    @track isResubmittedtoDSJ = false;
    @track isResubmitButtonDisplay = false;
    @wire(getRecord, {recordId: '$recordId', fields: [STATUS_FIELD, RESUBMITTEDTODSJ_FIELD, DSJSSTATUS_FIELD, BILLABLE_FIELD, JOBDATE_FIELD]}) 
    gettransportjob;

    get tjstatusdraft() {
        
        //If Status is Draft
        if(getFieldValue(this.gettransportjob.data, STATUS_FIELD) == 'Draft'){
            this.isTJStatusDraft = true;
            this.isTJStatusApproved = false;
        } else {
            this.isTJStatusDraft = false;

            //If Status is Completed
            if(getFieldValue(this.gettransportjob.data, STATUS_FIELD) == 'Completed'){
                this.isTJStatusCompleted = true;
                this.isTJStatusApproved = false;
            } else if (getFieldValue(this.gettransportjob.data, STATUS_FIELD) == 'Approved'){
                this.isTJStatusApproved = true;
                this.isTJStatusCompleted = false; 
            } else {
                this.isTJStatusCompleted = false;    
                this.isTJStatusApproved = false;
            }

        }



        //get Transport Job Type; if Regular = True
        // 02 OCT 2023: C+S - Removed logic related to Type
        /*if(getFieldValue(this.gettransportjob.data, TYPE_FIELD) == 'Regular') {
            this.isTJTypeRegular = true;
        } else {
            this.isTJTypeRegular = false;
        }*/

        // 04 OCT 2023: C+S - Added for Driver Assignment Date
        this.dteTJDate = getFieldValue(this.gettransportjob.data, JOBDATE_FIELD);

        //23 JUNE 2023 [C+S] get Billable
        this.isBillable = getFieldValue(this.gettransportjob.data, BILLABLE_FIELD);


        //get Transport Job DSJS_Status__c
        this.strDSJSStatus = getFieldValue(this.gettransportjob.data, DSJSSTATUS_FIELD);
        this.strDSJSStatus = (this.strDSJSStatus == null ? '' : this.strDSJSStatus);


        //get Transport Job Resubmitted_to_DSJ__c
        this.isResubmittedtoDSJ = getFieldValue(this.gettransportjob.data, RESUBMITTEDTODSJ_FIELD);



        //check if to display Resubmit to DSJ Button
        if ((this.strDSJSStatus !== '') && (this.isResubmittedtoDSJ == false) && (this.isTJStatusApproved == true)){
            this.isResubmitButtonDisplay = true;
        } else {
            this.isResubmitButtonDisplay = false;
        }

        // send values to Driver Assignment
        var eventParam = {'selectedtjstatus': this.isTJStatusApproved};
        fireEvent(this.pageRef, 'transportjobstatus', eventParam);

        var eventParam6 = {'selectedtjstatusdraft': this.isTJStatusDraft};
        fireEvent(this.pageRef, 'transportjobstatusdraft', eventParam6);

        // 02 OCT 2023: C+S - Removed logic related to Type
        /*var eventParam2 = {'selectedtjtype': this.isTJTypeRegular};
        fireEvent(this.pageRef, 'transportjobtype', eventParam2);*/

        // 04 OCT 2023: C+S - Added for Driver Assignment Date
        var eventParam2 = {'selectedtjdate': this.dteTJDate};
        fireEvent(this.pageRef, 'transportjobdate', eventParam2);

        var eventParam3 = {'selectedtjDSJSStatus': this.strDSJSStatus};
        fireEvent(this.pageRef, 'transportjobDSJSStatus', eventParam3);

        var eventParam4 = {'selectedtjResubmittedtoDSJ': this.isResubmittedtoDSJ};
        fireEvent(this.pageRef, 'transportjobResubmittedtoDSJ', eventParam4);
        
        var eventParam5 = {'selectedisBillable': this.isBillable};
        fireEvent(this.pageRef, 'transportjobisBillable', eventParam5);
       
        return this.isTJStatusDraft;
    }


    // 23 JUN 2023 [C+S] Check for Driver Assignment with blank Contract Job Item
    @track driverAssignmentContactJobItemList;
    @track hasBlankContactJobItem = false;
    @wire(getDriverAssignNoContactJobItem, { transportjob: '$recordId' })
    driverAssignContactJobItem(value){
        this.ContractJobItemGet = value;

        const { data, error } = value; // destructure the provisioned value
        if (data) {
            this.driverAssignmentContactJobItemList = data;
            if(data.data) {
                this.myData = data.data;
            }
            
            //Check if there is a record
            if (this.driverAssignmentContactJobItemList.length > 0) {
                this.hasBlankContactJobItem = true;
            } else {
                this.hasBlankContactJobItem = false;
            }
        }
        else if (error) { this.error; }
        
    }

    // 23 JUN 2023 [C+S] Check for Driver Assignment with blank Configuration
    @track driverAssignmentConfigurationList;
    @track hasBlankConfiguration = false;
    @wire(getDriverAssignNoConfiguration, { transportjob: '$recordId' })
    driverAssignConfiguration(value){
        this.ConfigurationGet = value;

        const { data, error } = value; // destructure the provisioned value
        if (data) {
            this.driverAssignmentConfigurationList = data;
            if(data.data) {
                this.myData = data.data;
            }
            
            //Check if there is a record
            if (this.driverAssignmentConfigurationList.length > 0) {
                this.hasBlankConfiguration = true;
            } else {
                this.hasBlankConfiguration = false;
            }
        }
        else if (error) { this.error; }
        
    }
    
    assignedTransportJob(event){
        
        // 23 JUN 2023 [C+S] verify if (Billable = TRUE and Contract Job Item = NULL) and (Configuration = NULL)
        if ((this.isBillable) && (this.hasBlankContactJobItem)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Update successfully',
                    message: 'If Billable, all Driver Assignments should have Contract Job Item before moving to Assigned.',
                    variant: 'error'
                })
            );
        }
        else if (this.hasBlankConfiguration) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: 'All Driver Assignments should have Configuration before moving to Assigned.',
                    variant: 'error'
                })
            );
        } else {
            // Create the recordInput object
            const fields = {};
            fields[TRANSPORTJOBID_FIELD.fieldApiName] = this.recordId;
            fields[STATUS_FIELD.fieldApiName] = "Assigned";

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Update successfully',
                            message: 'Status updated to Assigned',
                            variant: 'success'
                        })
                    );
                    var eventParam = {'selectedrecordid': this.recordId};
                    fireEvent(this.pageRef, 'driverlistrefresh', eventParam);

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

    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        
        const fields = {};
        fields[TRANSPORTJOBID_FIELD.fieldApiName] = this.recordId;
        fields[APPROVALNOTES_FIELD.fieldApiName] = this.template.querySelector("[data-field='ApprovalNotes']").value;
        fields[STATUS_FIELD.fieldApiName] = 'Approved';

        const recordInput = { fields };

        // 23 JUN 2023 [C+S] verify if (Billable = TRUE and Contract Job Item = NULL) and (Configuration = NULL)
        if ((this.isBillable) && (this.hasBlankContactJobItem)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Update successfully',
                    message: 'If Billable, all Driver Assignments should have Contract Job Item before moving to Assigned.',
                    variant: 'error'
                })
            );
        }
        else if (this.hasBlankConfiguration) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: 'All Driver Assignments should have Configuration before moving to Assigned.',
                    variant: 'error'
                })
            );
        } else {
            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Approved successfully',
                            message: 'Transport Job Approved',
                            variant: 'success'
                        })
                    );

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
            
            this.isModalOpen = false;
        }
    }

    //Resubmission to Daily site Job 
    @track isModalResubmitOpen = false;
    openModalResubmit() {
        // to open modal set isModalResubmitOpen tarck value as true
        this.isModalResubmitOpen = true;
    }
    closeResubmitModal() {
        // to close modal set isModalResubmitOpen tarck value as false
        this.isModalResubmitOpen = false;
    }

    resubmitToDSJ(){

        const fields = {};
        fields[TRANSPORTJOBID_FIELD.fieldApiName] = this.recordId;
        fields[RESUBMITTEDTODSJ_FIELD.fieldApiName] = true;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Resubmitted successfully',
                        message: 'Resubmitted to Daily Site Job',
                        variant: 'success'
                    })
                );

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
        
            this.isModalResubmitOpen = false;

    }


    //Refresh Driver Assignment Query
    @wire (CurrentPageReference) pageRef;
    connectedCallback() {
        registerListener('driverAssignmentContractJobItemListrefresh' ,this.handledriverAssignmentContractJobItemList, this);

        registerListener('driverAssignmentConfigurationListrefresh' ,this.handledriverAssignmentConfigurationList, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handledriverAssignmentContractJobItemList(detail){
        refreshApex(this.ContractJobItemGet);
    }

    handledriverAssignmentConfigurationList(detail){
        refreshApex(this.ConfigurationGet);
    }

}