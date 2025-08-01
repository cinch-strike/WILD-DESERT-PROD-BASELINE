import { LightningElement,api,wire,track} from 'lwc';
import fetchConfiguration from '@salesforce/apex/DriverAssignmentController.ConfigurationLookUp';
import{CurrentPageReference} from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
export default class ConfigurationDefaultList extends LightningElement {

//Identifying Transport Job ID
@wire (CurrentPageReference) pageRef;

@api getIdFromParent;
@api getConfigurationId;
@api getConfigurationName;
@track options = [];
@api searchKey;
@track searchValue = '';
@api objectName;
@api fieldName;
@api keyField;
@track selectedAccount;
@track showAccountsListFlag = false;
@track isSelection = false;
@wire(fetchConfiguration, {transportJobID:'$getIdFromParent'})
picklistvalues({data,error}){
        if(data){
        let picklistOptions = [{ key: '--None--', value: '--None--'}];
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
        if((this.getConfigurationId !== undefined) && (this.getConfigurationId !== null)){

            this.selectedAccount = this.getConfigurationName;

            //Currently this is used by Configuration field
            var eventParam = {'selectedvalueid': this.getConfigurationId};
            fireEvent(this.pageRef, 'configurationvalue',eventParam);
        
            if(!this.isSelection){
            this.isSelection = true;
            }
            console.log(this.isSelection);
            this.template
            .querySelector('.selectedOption')
            .classList.remove('slds-hide');
            this.template
            .querySelector('.accounts_list')
            .classList.add('slds-hide');
            this.template
            .querySelector('.defaultClass')
            .classList.add('slds-hide');
        }

    }


handleClick(){
    if (!this.showAccountsListFlag) {
    this.showAccountsListFlag = true;
    this.template
    .querySelector('.accounts_list')
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
    .querySelector('.accounts_list')
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
    this.selectedAccount = event.currentTarget.dataset.name;

    //Currently this is used by Configuration field
    var eventParam = {'selectedvalueid': event.currentTarget.dataset.id};
    fireEvent(this.pageRef, 'configurationvalue',eventParam);

    if(!this.isSelection){
    this.isSelection = true;
    }
    console.log(this.isSelection);
    this.template
    .querySelector('.selectedOption')
    .classList.remove('slds-hide');
    this.template
    .querySelector('.accounts_list')
    .classList.add('slds-hide');
    this.template
    .querySelector('.defaultClass')
    .classList.add('slds-hide');
}

handleRemoveSelectedOption() {
    //Configuration field set to null
    var eventParam = {'selectedvalueid': null};
    fireEvent(this.pageRef, 'configurationvalue',eventParam);
    
    this.template
    .querySelector('.selectedOption')
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
    .querySelector('.defaultClass')
    .classList.remove('slds-hide');
}

}