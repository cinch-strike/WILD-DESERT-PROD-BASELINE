import { LightningElement,api,wire,track} from 'lwc';
import fetchUnitLookup from '@salesforce/apex/AssetAssignmentController.UnitLookUp';
import{CurrentPageReference} from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
export default class UnitList extends LightningElement {

//Identifying Transport Job ID
@wire (CurrentPageReference) pageRef;

@api getOwnerUnitId;
@api getOwnerUnitName;
@track options = [];
@api searchKey;
@track searchValue = '';
@api objectName;
@api fieldName;
@api keyField;
@track selectedUnit;
@track showAccountsListFlag = false;
@track isSelection = false;

@wire(fetchUnitLookup, {})
picklistvalues(value){

        this.ownerUnitGet = value;
        const{data,error} = value;

        if(data){
        //let picklistOptions = [{ key: '--None--', value: '--None--'}];
        let picklistOptions = [{}];
        data.forEach(key=>{
        picklistOptions.push({
        key:key.Id,
        value:key.Name
        });
        });
        this.options = picklistOptions;
        }
        else if(error){
        console.log(error);
        }


        //Check for default value
        if((this.getOwnerUnitId !== undefined) && (this.getOwnerUnitId !== null)){

            this.selectedUnit = this.getOwnerUnitName;

            //alert(this.selectedUnit);
            //alert(this.isSelection);
            //alert(JSON.stringify(this.template.querySelector('.selectedUnitOption')));

            //Currently this is used by Configuration field
            var eventParam = {'selectedunitid': this.getOwnerUnitId};
            fireEvent(this.pageRef, 'ownerunitvalue',eventParam);
        
            if(!this.isSelection){
                this.isSelection = true;
            } 

            if(JSON.stringify(this.template.querySelector('.selectedUnitOption')) !== 'null'){
                console.log(this.isSelection);
                this.template.querySelector('.selectedUnitOption').classList.remove('slds-hide');
                this.template.querySelector('.units_list').classList.add('slds-hide');
                this.template.querySelector('.defaultUnitClass').classList.add('slds-hide');            
            } 
            

        }

    }


handleClick(){
    if (!this.showAccountsListFlag) {
    this.showAccountsListFlag = true;
    this.template
    .querySelector('.units_list')
    .classList.remove('slds-hide');
    this.template
    .querySelector('.slds-searchIcon')
    .classList.add('slds-hide');
    this.template
    .querySelector('.slds-icon-utility-down')
    .classList.remove('slds-hide');
    }
    this.template
    .querySelector('.slds-dropdown-trigger')
    .classList.add('slds-is-open');
}

handleKeyUp(event) {
    window.clearTimeout(this.delayTimeout);
    this.searchValue = event.target.value;
    const filter = this.searchValue.toUpperCase();
    const span = this.template.querySelector('.slds-listbox_vertical').childNodes;
    for (let i = 1; i < span.length; i++) {
    const option = span[i].textContent;
    if (option.toUpperCase().indexOf(filter) > -1) {
    span[i].style.display = "";
    } else {
    span[i].style.display = "none";
    }
}
// eslint-disable-next-line @lwc/lwc/no-async-operation
this.searchValue = this.searchValue;
if (this.searchValue === ''){
    this.template
    .querySelector('.units_list')
    .classList.add('slds-hide');
    this.template
    .querySelector('.slds-searchIcon')
    .classList.remove('slds-hide');
    this.template
    .querySelector('.slds-icon-utility-down')
    .classList.add('slds-hide');
    this.showAccountsListFlag = false;
}
}

@wire (CurrentPageReference) pageRef;
handleOptionSelect(event) {
    this.selectedUnit = event.currentTarget.dataset.name;

    //Currently this is used by Configuration field
    var eventParam = {'selectedunitid': event.currentTarget.dataset.id};
    fireEvent(this.pageRef, 'ownerunitvalue',eventParam);

    if(!this.isSelection){
    this.isSelection = true;
    }
    console.log(this.isSelection);
    this.template
    .querySelector('.selectedUnitOption')
    .classList.remove('slds-hide');
    this.template
    .querySelector('.units_list')
    .classList.add('slds-hide');
    this.template
    .querySelector('.defaultUnitClass')
    .classList.add('slds-hide');
}

handleRemoveSelectedUnit() {
    //Configuration field set to null
    var eventParam = {'selectedunitid': null};
    fireEvent(this.pageRef, 'ownerunitvalue',eventParam);
    
    this.template
    .querySelector('.selectedUnitOption')
    .classList.add('slds-hide');
    this.template
    .querySelector('.slds-searchIcon')
    .classList.remove('slds-hide');
    this.template
    .querySelector('.slds-icon-utility-down')
    .classList.add('slds-hide');
    this.template.querySelector('.searchvalue').value = '';
    this.searchKey = '';
    this.showAccountsListFlag = false;

    this.template
    .querySelector('.defaultUnitClass')
    .classList.remove('slds-hide');
}

}