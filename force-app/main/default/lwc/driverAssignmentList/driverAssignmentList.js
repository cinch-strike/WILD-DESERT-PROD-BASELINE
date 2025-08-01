import { LightningElement, api, wire, track} from 'lwc';
import getDriverAssignmentList from '@salesforce/apex/DriverAssignmentController.getDriverAssignmentList';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import{CurrentPageReference} from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';

export default class driverAssignmentList extends LightningElement {
    @api recordId;
    @track error;
    @track driverAssignmentList;
    @track isassetAssignment = false;
    @wire(getDriverAssignmentList, { transportjob: '$recordId' })
    driverAssign(value){
        this.driverAssignmentGet = value;

        const { data, error } = value; // destructure the provisioned value
        if (data) {
            this.driverAssignmentList = data;
            if(data.data) {
                this.myData = data.data;
            }

            //Check if there is a record
            if (this.driverAssignmentList.length > 0) {
                this.isassetAssignment = true;
            } else {
                this.isassetAssignment = false;
            }
        }
        else if (error) { this.error; }
        
    }

    //Refresh Driver list
    @wire (CurrentPageReference) pageRef;
    connectedCallback() {
        registerListener('driverlistrefresh' ,this.handleRefreshDriverList, this);

        registerListener('transportjobstatus' ,this.handleTransportJobStatus, this);

        //registerListener('transportjobtype' ,this.handleTransportJobType, this); // 02 OCT 2023: C+S - Removed logic related to Type

    }
        
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleRefreshDriverList(detail){
        //alert ('submit');
        refreshApex(this.driverAssignmentGet);
    }


    @track tjstatusapproved;
    handleTransportJobStatus(detail){
        //Transport Job status
        this.tjstatusapproved = detail.selectedtjstatus;
    }

    // 02 OCT 2023: C+S - Removed logic related to Type
    /*@track tjregulartype;
    handleTransportJobType(detail){
        //Transport Job status
        this.tjregulartype = detail.selectedtjtype;
    }*/


    //Buttons
    @api driverId;
    selectNewDriver(event) {
        event.preventDefault();

        this.driverId = 'new driver'; 
        var eventParam = {'selecteddriverid': this.recordId};

        fireEvent(this.pageRef, 'drivernew',eventParam);

    }
    
    @wire (CurrentPageReference) pageRef;
    selectDriver(event) {
        event.preventDefault();

        this.driverId = event.target.dataset.div; 
        var eventParam = {'selecteddriverid': this.driverId};

        fireEvent(this.pageRef, 'driverdetails',eventParam);

    }

    deleteDriver(event){

        deleteRecord(event.target.dataset.div)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Record Deleted',
                    message: 'Driver assignment deleted.',
                    variant: 'success',
                    mode: 'dismissable'
                })
            );
            return refreshApex(this.driverAssignmentGet);
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


        //Close the Driver Assignment details
        this.driverId = event.target.dataset.div; 
        var eventParam = {'selecteddriverid': this.driverId};

        fireEvent(this.pageRef, 'driverdelete',eventParam);
    }

}