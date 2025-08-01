import { LightningElement, api, wire, track} from 'lwc';
import { createRecord, deleteRecord, getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DRIVERASSIGNMENT_OBJECT from '@salesforce/schema/Driver_Assignment__c';
import DRIVERASSID_FIELD from '@salesforce/schema/Driver_Assignment__c.Id';
import TRANSPORTJOB_FIELD from '@salesforce/schema/Driver_Assignment__c.Transport_Job__c';
import DRIVERNAME_FIELD from '@salesforce/schema/Driver_Assignment__c.Driver__c';
import DRIVERFULLNAME_FIELD from '@salesforce/schema/Driver_Assignment__c.Driver__r.Name';
import ESTIMATEDTOTALJOBTIME_FIELD from '@salesforce/schema/Driver_Assignment__c.Estimated_total_job_time__c';
import NOTES_FIELD from '@salesforce/schema/Driver_Assignment__c.Notes__c';
import CONFIGURATION_FIELD from '@salesforce/schema/Driver_Assignment__c.Configuration__c';
import CONFIGURATIONNAME_FIELD from '@salesforce/schema/Driver_Assignment__c.Configuration__r.Name';
//import MAINTENANCECATEGORY_FIELD from '@salesforce/schema/Driver_Assignment__c.Maintenance_Category__c'; 02 OCT 2023: C+S - Removed logic related to Type
import CONFIGURATIONNEW_FIELD from '@salesforce/schema/Driver_Assignment__c.Configuration_pklist__c';
import DATRUCK_FIELD from '@salesforce/schema/Driver_Assignment__c.Truck__c';
import DATRUCKNAME_FIELD from '@salesforce/schema/Driver_Assignment__c.Truck__r.Name';
import DADATE_FIELD from '@salesforce/schema/Driver_Assignment__c.Driver_Assignment_Date__c';
import DAJOBITEMHOURLY_FIELD from '@salesforce/schema/Driver_Assignment__c.Quoted_Price_Job__c';
import DRIVERSTATUS_FIELD from '@salesforce/schema/Driver_Assignment__c.Driver_Status__c';
import STARTDATE_FIELD from '@salesforce/schema/Driver_Assignment__c.Start_Date_Time__c';
import ENDDATE_FIELD from '@salesforce/schema/Driver_Assignment__c.End_Date_Time__c';
import TRAVELDETAILS_FIELD from '@salesforce/schema/Driver_Assignment__c.Travel_Details__c';
import LOADDETAILS_FIELD from '@salesforce/schema/Driver_Assignment__c.Load_Details__c';
import WORKDIARY_FIELD from '@salesforce/schema/Driver_Assignment__c.Work_Diary_Number__c';
import WITHIN10KM_FIELD from '@salesforce/schema/Driver_Assignment__c.Transport_Job__r.Within_100km_Radius__c';
import PRESTARTREQUIRED_FIELD from '@salesforce/schema/Driver_Assignment__c.Daily_Pre_start_Required__c';
import ISDRIVERASSIGNMENTACCEPTED_FIELD from '@salesforce/schema/Driver_Assignment__c.Is_Driver_Assignment_Accepted__c';
import NOTIFYDRIVEROFUPDATES_FIELD from '@salesforce/schema/Driver_Assignment__c.Notify_Driver_of_Updates__c';
import SMSMESSAGE_FIELD from '@salesforce/schema/Driver_Assignment__c.SMS_Link__c';
import MINIMUM7HOURS_FIELD from '@salesforce/schema/Driver_Assignment__c.Minimum_7hrs_of_continuous_rest__c';
import SUFFICIENTWORKHOURS_FIELD from '@salesforce/schema/Driver_Assignment__c.Sufficient_work_hours_remaining__c';
import PLANPROVIDESOPPTY_FIELD from '@salesforce/schema/Driver_Assignment__c.Plan_provides_opportunities__c';
import DRIVERASSETASSIGNMENT_OBJECT from '@salesforce/schema/Asset_Driver_Assignment__c';
import ASSETNAME_FIELD from '@salesforce/schema/Asset_Driver_Assignment__c.WD_Asset__c';
import DRIVERASSIGNMENT_FIELD from '@salesforce/schema/Asset_Driver_Assignment__c.Driver_Assignment__c';
import getAssetAssignmentList from '@salesforce/apex/AssetAssignmentController.getAssetAssignmentList';
import fetchOwnerUnit from '@salesforce/apex/AssetAssignmentController.getOwnerUnit';
import {CurrentPageReference} from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
//import { createRecord, deleteRecord, getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';

export default class DriverAssignment extends LightningElement {

    @api recordId;
    @track strdriverassignmentid;
    @track isdisplaynew;
    @track isdisplayview;
    @track strtransportid;
    @track isDriverAssignmentView = false;
    @track isDriverAssignmentUpdate = false;

 
    //Identifying Transport Job ID and Driver Assignment ID
    @wire (CurrentPageReference) pageRef;
    connectedCallback() {
        registerListener('drivernew' ,this.handleDriverNew, this);

        registerListener('driverdetails' ,this.handleDriverDetails, this);
        
        registerListener('driverdelete',this.handleDriverDelete, this);

        registerListener('drivernamevalue',this.handleDriverNameData, this);

        registerListener('configurationvalue',this.handleConfigurationData, this);

        registerListener('truckvalue',this.handleTruckData, this);

        registerListener('ownerunitvalue',this.handleOwnerUnit, this);

        registerListener('assetvalue',this.handleAssetData, this);

        registerListener('transportjobstatus' ,this.handleTransportJobStatus, this); // TJ Status = Approved

        registerListener('transportjobstatusdraft' ,this.handleTransportJobStatusDraft, this); // TJ Status = Draft

        //registerListener('transportjobtype' ,this.handleTransportJobType, this); // 02 OCT 2023: C+S - Removed logic related to Type

        registerListener('transportjobdate' ,this.handleTransportJobDate, this); // 04 OCT 2023: C+S - Added Driver Assignment Date

        registerListener('transportjobDSJSStatus' ,this.handleTransportJobDSJSStatus, this);

        registerListener('transportjobResubmittedtoDSJ' ,this.handleTransportJobResubmittedtoDSJ, this);

        registerListener('transportjobisBillable' ,this.handletransportjobisBillable, this); //23 JUNE 2023 [C+S] Retrieve the Billable value

    }
        
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    //Driver Assignment Details page behaviour
    handleDriverNew(detail){
        this.strtransportid = detail.selecteddriverid;

        this.selectedDriverName = null;
        this.selectedConfiguration = '';
        this.selectedNotes = '';
        this.selectedEstimatedTotalJobTime = '';
        this.selectedTruck = '';
        
        this.isdisplaynew = true;
        this.isdisplayview = false;
        
    }

    handleDriverDetails(detail){
        this.strdriverassignmentid = detail.selecteddriverid;
        this.isdisplaynew = false;
        this.isdisplayview = true;
        this.isDriverAssignmentView = true;
        this.isDriverAssignmentUpdate = false;

        refreshApex(this.ownerUnitGet);

    }

    handleDriverDelete(detail){
        this.strdriverassignmentid = detail.selecteddriverid;
        this.isdisplaynew = false;
        this.isdisplayview = false;

        var eventParam = {'deketedriver': this.strdriverassignmentid};
        fireEvent(this.pageRef, 'driverAssignmentContractJobItemListrefresh', eventParam);
        fireEvent(this.pageRef, 'driverAssignmentConfigurationListrefresh', eventParam);
    }

    @track tjstatusapproved;
    handleTransportJobStatus(detail){
        //Transport Job status = Approved
        this.tjstatusapproved = detail.selectedtjstatus;
    }

    @track tjstatusdraft;
    handleTransportJobStatusDraft(detail){
        //Transport Job status = Draft
        this.tjstatusdraft = detail.selectedtjstatusdraft;
    }

    // 02 OCT 2023: C+S - Removed logic related to Type
    /*@track tjtyperegular;
    handleTransportJobType(detail){
        //Transport Job type
        this.tjtyperegular = detail.selectedtjtype;
    }*/

    // 04 OCT 2023: C+S - Added for Driver Assignment Date
    @track tjdate;
    handleTransportJobDate(detail){
        //Transport Job Date
        this.tjdate = detail.selectedtjdate;
    }


    @track tjDSJSStatus;
    @track isTJApprovedButEditable = false;
    handleTransportJobDSJSStatus(detail){
        //Transport Job DSJS Status
        this.tjDSJSStatus = detail.selectedtjDSJSStatus;

        if((this.tjDSJSStatus !== '') && (this.tjstatusapproved = true)){
            this.isTJApprovedButEditable = true;
        } else {
            this.isTJApprovedButEditable = false;
        }
    }


    @track tjResubmittedtoDSJ;
    handleTransportJobResubmittedtoDSJ(detail){
        //Transport Job Resubmitted to DSJ
        this.tjResubmittedtoDSJ = detail.selectedtjResubmittedtoDSJ;

    }

    
    @track isBillable;
    handletransportjobisBillable(detail){
        //Transport Job Billable
        this.isBillable = detail.selectedisBillable;
    }


    //DRIVER ASSIGNMENT

    @track drivername ='';
    //Create fields for new Driver Assignment

    @track selectedDriverName; 
    @track selectedNotes; 
    @track selectedEstimatedTotalJobTime;
    @track selectedConfiguration = '';
    //@track selectedMaintenanceCategory = '';
    @track selectedConfigurationnew = '';
    @track selectedTruckID = '';
    @track selectedTruck = '';
    @track selectedUnitID = '';

    handleDriverNameData(detail){
        this.selectedDriverName = detail.selectedvalueid;

    }

    handleConfigurationData(detail){
        this.selectedConfiguration = detail.selectedvalueid;

    }

    handleTruckData(detail){
        this.selectedTruck = detail.selectedvalueid;

    }

    handleOwnerUnit(detail){
        this.selectedUnitID = detail.selectedunitid;
        if(this.selectedUnitID == '--None--'){
            this.selectedUnitID = 'null';
        }

        refreshApex(this.ownerUnitGet);

    }

    handleEstimatedTotalJobTimeSelected(event) {
        this.selectedEstimatedTotalJobTime = event.detail;
    }


    handleNotesValueSelected(event) {
        this.selectedNotes = event.detail;
    }

    //02 OCT 2023: C+S - Removed logic related to Type
    /*handleMaintenanceCategorySelected(event) {
        this.selectedMaintenanceCategory = event.detail;
    }*/

    handleConfigurationSelected(event) {
        this.selectedConfigurationnew = event.detail;
    }

    editDriverAssignment(event){
        this.strtransportid = this.recordId;

        this.isDriverAssignmentView = false;
        this.isDriverAssignmentUpdate = true;

    }

    saveDriverAssignment(event){

        var startdate = this.template.querySelector("[data-field='StartDate']").value;
        var enddate = this.template.querySelector("[data-field='EndDate']").value;
        var estimatedtotaljobtimevalue = this.template.querySelector("[data-field='EstimatedTotalJobTime']").value;
        startdate = (startdate == null ? '' : startdate);
        enddate = (enddate == null ? '' : enddate);


        if ((this.isWithin100km == false) && (this.driverstatus == false) && (this.template.querySelector("[data-field='WorkDiaryNumber']").value == '')){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: 'Work Diary Number is required',
                    variant: 'error'
                })
            );

        } else if ((enddate !== '') && ((startdate == '') || (startdate > enddate))){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: 'Start Date/Time should have value or less than End Date/Time.',
                    variant: 'error'
                })
            );
        } else if ((estimatedtotaljobtimevalue == '') || (estimatedtotaljobtimevalue == null)){
            const evt = new ShowToastEvent({
                title: 'Application Error',
                message: 'You need to enter the Estimated Total Job Time.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else if ((this.selectedTruck == '') || (this.selectedTruck == null)){
            const evt = new ShowToastEvent({
                title: 'Application Error',
                message: 'You need to select the Truck.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {

            // Create the recordInput object
            const fields = {};
            fields[DRIVERASSID_FIELD.fieldApiName] = this.strdriverassignmentid;

            // 02 OCT 2023: Saved DA Date field
            fields[DADATE_FIELD.fieldApiName] = this.template.querySelector("[data-field='DriverAssignmentDate']").value;

            fields[ESTIMATEDTOTALJOBTIME_FIELD.fieldApiName] = this.template.querySelector("[data-field='EstimatedTotalJobTime']").value;
            fields[NOTES_FIELD.fieldApiName] = this.template.querySelector("[data-field='DriverNotes']").value;
            // 21 JUNE 2023: Saved for new Configuration
            fields[CONFIGURATIONNEW_FIELD.fieldApiName] =  this.selectedConfigurationnew;

            // 18 SEPT 2023: Saved for Unit
            fields[DATRUCK_FIELD.fieldApiName] = this.selectedTruck;


            // Transport Job Type = Regular
            /* 02 OCT 2023: C+S - Removed logic related to Type
            if (this.tjtyperegular == true){ */
                fields[CONFIGURATION_FIELD.fieldApiName] = this.selectedConfiguration;
                //fields[MAINTENANCECATEGORY_FIELD.fieldApiName] = '';
                fields[PRESTARTREQUIRED_FIELD.fieldApiName] = this.template.querySelector("[data-field='isPrestartRequired']").checked;
            /*} else {
                fields[CONFIGURATION_FIELD.fieldApiName] = '';
                if(this.selectedMaintenanceCategory !== '') {
                    fields[MAINTENANCECATEGORY_FIELD.fieldApiName] = this.selectedMaintenanceCategory;
                }

                fields[PRESTARTREQUIRED_FIELD.fieldApiName] = false;
            } */


            // Update for Driver Assignment status not draft or assigned
            if (this.driverstatus == false){
                fields[STARTDATE_FIELD.fieldApiName] = this.template.querySelector("[data-field='StartDate']").value;
                fields[ENDDATE_FIELD.fieldApiName] = this.template.querySelector("[data-field='EndDate']").value;
                fields[TRAVELDETAILS_FIELD.fieldApiName] = this.template.querySelector("[data-field='TravelDetails']").value;
                fields[LOADDETAILS_FIELD.fieldApiName] = this.template.querySelector("[data-field='LoadDetails']").value;
                fields[WORKDIARY_FIELD.fieldApiName] = this.template.querySelector("[data-field='WorkDiaryNumber']").value;      
            }

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Update successfully',
                            message: 'Driver Assignment updated.',
                            variant: 'success'
                        })
                    );

                    var eventParam = {'updatedriverid': this.strdriverassignmentid};
                    fireEvent(this.pageRef, 'driverlistrefresh', eventParam);
                    fireEvent(this.pageRef, 'driverAssignmentContractJobItemListrefresh', eventParam);
                    fireEvent(this.pageRef, 'driverAssignmentConfigurationListrefresh', eventParam);


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
            

            this.isDriverAssignmentView = true;
            this.isDriverAssignmentUpdate = false;
        }
    }

    cancelDriverAssignment(event){
        this.isDriverAssignmentView = true;
        this.isDriverAssignmentUpdate = false;
    }


    validateLookupField() {
        this.template.querySelector('c-custom-lookup').isValid();
    }


    // Create Asset Driver Assignment
    @track driverassignID;

    createDriverAssign(event){
        var isEstimatedTotalJobTime = this.template.querySelector("[data-field='isEstimatedTotalJobTime']").checked;
        var isSufficientWorkHours = this.template.querySelector("[data-field='isSufficientWorkHours']").checked;
        var isPlanProvidesOppty = this.template.querySelector("[data-field='isPlanProvidesOppty']").checked;

        if ((this.selectedDriverName == '') || (this.selectedDriverName == null)){
            const evt = new ShowToastEvent({
                title: 'Application Error',
                message: 'You need to select a Driver first.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

        } else if ((this.selectedEstimatedTotalJobTime == '') || (this.selectedEstimatedTotalJobTime == null)){
                const evt = new ShowToastEvent({
                    title: 'Application Error',
                    message: 'You need to enter the Estimated Total Job Time.',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

        } else if ((this.isBillable) && (!this.tjstatusdraft) && ((this.selectedConfigurationnew == '') || (this.selectedConfigurationnew == null))){
            const evt = new ShowToastEvent({
                title: 'Application Error',
                message: 'If Billable, the Driver Assignment should have Configuration selected.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);    

        } else if ((this.selectedTruck == '') || (this.selectedTruck == null)) {
                    const evt = new ShowToastEvent({
                        title: 'Application Error',
                        message: 'You need to select the Truck.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);               

        } else if ((this.isBillable) && (!this.tjstatusdraft) && ((this.selectedConfiguration == '') || (this.selectedConfiguration == null))){
            const evt = new ShowToastEvent({
                title: 'Application Error',
                message: 'If Billable, the Driver Assignment should have Contract Job Item selected.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);    

        } else if ((isEstimatedTotalJobTime == false) || (isSufficientWorkHours == false) || (isPlanProvidesOppty == false)){
                    const evt = new ShowToastEvent({
                        title: 'Application Error',
                        message: 'You can not create Driver Assignment until you click all the three (3) confirmation boxes.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
       
        } else {
            const fields = {};
            fields[TRANSPORTJOB_FIELD.fieldApiName] = this.strtransportid;
            fields[DRIVERNAME_FIELD.fieldApiName] = this.selectedDriverName; 
            fields[ESTIMATEDTOTALJOBTIME_FIELD.fieldApiName] = this.selectedEstimatedTotalJobTime;
            fields[NOTES_FIELD.fieldApiName] = this.selectedNotes;
            fields[MINIMUM7HOURS_FIELD.fieldApiName] = isEstimatedTotalJobTime;
            fields[SUFFICIENTWORKHOURS_FIELD.fieldApiName] = isSufficientWorkHours;
            fields[PLANPROVIDESOPPTY_FIELD.fieldApiName] = isPlanProvidesOppty;
            // 21 JUNE 2023: Saved for new Configuration
            fields[CONFIGURATIONNEW_FIELD.fieldApiName] = this.selectedConfigurationnew;

            // 04 OCT 2023: Saved DA Date field
            fields[DADATE_FIELD.fieldApiName] = this.template.querySelector("[data-field='DriverAssignmentDateCreate']").value;

            // 18 SEPT 2023: Saved for Unit
            fields[DATRUCK_FIELD.fieldApiName] = this.selectedTruck;
            
            // Transport Job Type = Regular
            /* 02 OCT 2023: C+S - Removed logic related to Type
            if (this.tjtyperegular == true){ */
                fields[CONFIGURATION_FIELD.fieldApiName] = this.selectedConfiguration;
                //fields[MAINTENANCECATEGORY_FIELD.fieldApiName] = '';
                fields[PRESTARTREQUIRED_FIELD.fieldApiName] = this.template.querySelector("[data-field='isPrestartRequired']").checked;
            /*} else {
                fields[CONFIGURATION_FIELD.fieldApiName] = '';
                fields[MAINTENANCECATEGORY_FIELD.fieldApiName] = this.selectedMaintenanceCategory;
                fields[PRESTARTREQUIRED_FIELD.fieldApiName] = false;
            }*/

            const recordInput = { apiName: DRIVERASSIGNMENT_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(driverassign => {
                    this.driverassignID = driverassign.id;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Driver Assignment added.',
                            variant: 'success',
                        }),
                    );
                    //display the new Drive Assignment record
                    this.strdriverassignmentid = this.driverassignID;

                    var eventParam = {'newdriverid': this.strdriverassignmentid};
                    fireEvent(this.pageRef, 'driverlistrefresh', eventParam);
                    fireEvent(this.pageRef, 'driverAssignmentContractJobItemListrefresh', eventParam);
                    fireEvent(this.pageRef, 'driverAssignmentConfigurationListrefresh', eventParam);

                    //Display Driver Assignment View        
                    this.isdisplaynew = false;
                    this.isdisplayview = true;

                    this.isDriverAssignmentView = true;
                    this.isDriverAssignmentUpdate = false;

                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error adding Driver',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );

                    //Display Driver Assignment View        
                    this.isdisplaynew = false;
                    this.isdisplayview = false;

                });
        }
    }


    //Driver Assignment to Cancelled 
    @track isModalCancelDAOpen = false;
    openCancelDAModal() {
        // to open modal set isModalCancelDAOpen track value as true
        this.isModalCancelDAOpen = true;
    }

    closeCancelDAModal() {
        // to close modal set isModalCancelDAOpen track value as false
        this.isModalCancelDAOpen = false;
    }


    driverAssignmentToCancelled() {

        const fields = {};

        fields[DRIVERASSID_FIELD.fieldApiName] = this.strdriverassignmentid;
        fields[DRIVERSTATUS_FIELD.fieldApiName] = 'Cancelled';

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Update successfully',
                        message: 'Driver Assignment set to Cancelled',
                        variant: 'success'
                    })
                );

                var eventParam = {'updatedriverid': this.strdriverassignmentid};
                fireEvent(this.pageRef, 'driverlistrefresh', eventParam);
                fireEvent(this.pageRef, 'driverAssignmentContractJobItemListrefresh', eventParam);
                fireEvent(this.pageRef, 'driverAssignmentConfigurationListrefresh', eventParam);

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
        

        this.isDriverAssignmentView = true;
        this.isDriverAssignmentUpdate = false;
        this.isModalCancelDAOpen = false;
    }

    
    //Send Notification of Driver Assignment updates
    @track isModalNotificationOpen = false;
    openNotificationModal() {
        // to open modal set isModalNotificationOpen track value as true
        this.isModalNotificationOpen = true;
    }

    closeNotificationModal() {
        // to close modal set isModalNotificationOpen track value as false
        this.isModalNotificationOpen = false;
    }

    driverAssignmentNotification() {

        const fields = {};

        fields[DRIVERASSID_FIELD.fieldApiName] = this.strdriverassignmentid;
        fields[NOTIFYDRIVEROFUPDATES_FIELD.fieldApiName] = true;
        //fields[SMSMESSAGE_FIELD.fieldApiName] = 'Test Message';

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Send Notification',
                        message: 'Message notification has been sent.',
                        variant: 'success'
                    })
                );

                var eventParam = {'updatedriverid': this.strdriverassignmentid};
                fireEvent(this.pageRef, 'driverlistrefresh', eventParam);
                fireEvent(this.pageRef, 'driverAssignmentContractJobItemListrefresh', eventParam);
                fireEvent(this.pageRef, 'driverAssignmentConfigurationListrefresh', eventParam);

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error sending message',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        

        this.isDriverAssignmentView = true;
        this.isDriverAssignmentUpdate = false;
        this.isModalNotificationOpen = false;
    }



    //ASSET DRIVER ASSIGNMENT

    //Query the Driver Assignment details
    objectDriverAssignment = DRIVERASSIGNMENT_OBJECT;
    DAfields = [DRIVERNAME_FIELD, NOTES_FIELD, CONFIGURATIONNEW_FIELD, CONFIGURATION_FIELD, DATRUCK_FIELD, DADATE_FIELD];
    DAfieldsreadonly = [DRIVERSTATUS_FIELD, STARTDATE_FIELD, ENDDATE_FIELD, TRAVELDETAILS_FIELD, LOADDETAILS_FIELD, WORKDIARY_FIELD, DATRUCK_FIELD, DADATE_FIELD];

    //Query Driver Status; if Draft hide the Driver Provided Information section
    @track isDriverStatusAssigned = false;
    @track isWithin100km = true;
    @track strDriverStatus = '';
    @track strConfigurationName = '';
    @track strConfigurationID = '';
    @track strDATruckName = '';
    @track strDATruckID = '';
    @track strDADate = '0';
    @api strDriverName;
    @api strDriverNameID;
    @wire(getRecord, {
        recordId: '$strdriverassignmentid', 
        fields: [DRIVERNAME_FIELD, DRIVERFULLNAME_FIELD, DADATE_FIELD, ESTIMATEDTOTALJOBTIME_FIELD, NOTES_FIELD, CONFIGURATION_FIELD, CONFIGURATIONNAME_FIELD, CONFIGURATIONNEW_FIELD,DATRUCK_FIELD, DATRUCKNAME_FIELD,
                PRESTARTREQUIRED_FIELD, ISDRIVERASSIGNMENTACCEPTED_FIELD, DRIVERSTATUS_FIELD, STARTDATE_FIELD, ENDDATE_FIELD, TRAVELDETAILS_FIELD, LOADDETAILS_FIELD, WORKDIARY_FIELD, DAJOBITEMHOURLY_FIELD]
    })
    getdriverassignment;

    get driverfullname() {  
        this.strDriverNameID = getFieldValue(this.getdriverassignment.data, DRIVERNAME_FIELD);
        this.strDriverName = getFieldValue(this.getdriverassignment.data, DRIVERFULLNAME_FIELD);
        return 'Driver Name : ' + this.strDriverName;
    }

    get estimatedtotaljobtime() {  
        return getFieldValue(this.getdriverassignment.data, ESTIMATEDTOTALJOBTIME_FIELD);
    }

    get drivernotes() {  
        return getFieldValue(this.getdriverassignment.data, NOTES_FIELD);
    }

    get driverconfiguration() {  
        this.strConfigurationID = getFieldValue(this.getdriverassignment.data, CONFIGURATION_FIELD);
        this.strConfigurationName = getFieldValue(this.getdriverassignment.data, CONFIGURATIONNAME_FIELD);

        return this.strConfigurationName;
    }

    //02 OCT 2023: C+S - Removed logic related to Type
    /*get maintenancecategory() {  
        return getFieldValue(this.getdriverassignment.data, MAINTENANCECATEGORY_FIELD);
    }*/

    get configurationnew() {  
        this.selectedConfigurationnew = getFieldValue(this.getdriverassignment.data, CONFIGURATIONNEW_FIELD);
        return getFieldValue(this.getdriverassignment.data, CONFIGURATIONNEW_FIELD);
    }

    get drivertruck() {  
        this.strDATruckID = getFieldValue(this.getdriverassignment.data, DATRUCK_FIELD);
        this.strDATruckName = getFieldValue(this.getdriverassignment.data, DATRUCKNAME_FIELD);

        return this.strDATruckName;
    }

    get dadate() {

        this.strDADate = getFieldValue(this.getdriverassignment.data, DADATE_FIELD);

        return this.strDADate;
    }

    get isPrestartRequired() {  
            return getFieldValue(this.getdriverassignment.data, PRESTARTREQUIRED_FIELD);
    }

    get isDriverAssignmentAccepted() {  
        return getFieldValue(this.getdriverassignment.data, ISDRIVERASSIGNMENTACCEPTED_FIELD);
    }

    get isDACancelled() {
        this.strDriverStatus = getFieldValue(this.getdriverassignment.data, DRIVERSTATUS_FIELD);        

        //check if DA is Cancelled
        if(this.strDriverStatus == 'Cancelled'){
            return true;
        } else {
            return false;
        }
       
    }

    get driverstatus() {
        this.strDriverStatus = getFieldValue(this.getdriverassignment.data, DRIVERSTATUS_FIELD);        

        if(( this.strDriverStatus == 'Draft') || ( this.strDriverStatus == 'Assigned')){
            this.isDriverStatusAssigned = true;
        } else {
            this.isDriverStatusAssigned = false;
        }
       
        return this.isDriverStatusAssigned;
    }

    get startdate() {  
        return getFieldValue(this.getdriverassignment.data, STARTDATE_FIELD);
    }

    get enddate() {  
        return getFieldValue(this.getdriverassignment.data, ENDDATE_FIELD);
    }

    get dajobitemhourly() {  
        return getFieldValue(this.getdriverassignment.data, DAJOBITEMHOURLY_FIELD);
    }

    get traveldetails() {  
        return getFieldValue(this.getdriverassignment.data, TRAVELDETAILS_FIELD);
    }

    get loaddetails() {  
        return getFieldValue(this.getdriverassignment.data, LOADDETAILS_FIELD);
    }

    get within100km() {
        this.isWithin100km = getFieldValue(this.getdriverassignment.data, WITHIN10KM_FIELD);     
       
        return this.isWithin100km;
    }

    get workdiary() {
        return getFieldValue(this.getdriverassignment.data, WORKDIARY_FIELD);        
    }

    //Query the Asset Assignment
    //List of Asset Assignment
    @track assetAssignList;
    @track isassetAssign = false;
    @wire(getAssetAssignmentList, { driverAssign: '$strdriverassignmentid'})
    assetAssign(value){
        this.assetAssignGet = value;

        const { data, error } = value; // destructure the provisioned value
        if (data) {
            this.assetAssignList = data;
            if(data.data) {
                this.myData = data.data;
            }
            
            //Check if there is a record
            if (this.assetAssignList.length > 0) {
                this.isassetAssign = true;
            } else {
                this.isassetAssign = false;
            }
        }
        else if (error) { this.error; }
        
    }

    //Get Owner's Unit
    @track strUnitId;
    @track strUnitName;
    @track strHelpText;
    @wire(fetchOwnerUnit, {transportJobID:'$recordId'})
    getOwnerUnit(value){

        this.ownerUnitGet = value;
        const{data,error} = value;

        if(data){
            data.forEach(key=>{
                this.strUnitId = key.Id;
                this.strUnitName = key.Name;
                this.strHelpText = "By default, the assets shown are for " + this.strUnitName + " unit. \n\n\nPress ESC to close the dropdown list.";
            });
        }
            else if(error){
            console.log(error);
        }

    }

   
    // Create Asset Driver Assignment
    @track assetdriverassignID;
    createAssetDriver(event){

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
            fields[ASSETNAME_FIELD.fieldApiName] = this.selectedAsset;
            fields[DRIVERASSIGNMENT_FIELD.fieldApiName] = this.strdriverassignmentid;
            const recordInput = { apiName: DRIVERASSETASSIGNMENT_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(assetdriverassign => {
                    this.assetdriverassignID = assetdriverassign.id;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Asset assignment added ' ,
                            variant: 'success',
                        }),
                    );
                    return refreshApex(this.assetAssignGet);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error adding asset',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });


            this.selectedAssetJSON = null;
            this.selectedAsset = null;

            //Remove selected asset
            var eventParam = {'selectedassetid': this.selectedAsset};

            fireEvent(this.pageRef, 'removeselectedasset',eventParam);
        }
    }

    //Check asset selected
    @track selectedAsset = null;
    handleAssetData(detail){
        this.selectedAsset = detail.selectedvalueid;
        
    }


    //Delete Asset record
    deleteAsset(event){
        deleteRecord(event.target.dataset.div)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Record Deleted',
                    message: 'Asset assignment deleted. ',
                    variant: 'success',
                    mode: 'dismissable'
                })
            );
            return refreshApex(this.assetAssignGet);
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


    //MISCELLANEOUS

    //Convert JSON string to string
    @api convertToString(text){
        text = JSON.stringify(text);
        
        text = text.replace("[",'');
        text = text.replace("]",'');
        text = text.replace(/[|]|"|"/g,'');

        return text;
    }


}