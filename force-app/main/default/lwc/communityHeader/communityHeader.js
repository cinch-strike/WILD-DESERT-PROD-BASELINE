import { LightningElement, api, track, wire} from 'lwc';
import DRIVERNAME_FIELD from '@salesforce/schema/User.Name';
import {getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

export default class CommunityHeader extends LightningElement {

    //@api recordId;
    @track strUserId = Id;

    @track isdisplaydriver = true;
    @wire(getRecord, {recordId: '$strUserId', fields: [DRIVERNAME_FIELD]}) 
    getdriverassignment;    
    get drivername(){

        //alert ('Record ID: ' + this.recordId);
        //alert ('String: ' + this.strstring);
        //alert ('Id: ' + Id);
        var newDate = new Date(); 
        this.dateValue = newDate.toDateString();
       
        this.isdisplaydriver = true;

        return getFieldValue(this.getdriverassignment.data, DRIVERNAME_FIELD);

    }

}