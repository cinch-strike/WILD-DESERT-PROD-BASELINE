import { LightningElement,api,wire,track} from 'lwc';
import fetchLookUpValues from '@salesforce/apex/DriverAssignmentController.fetchLookUpValues';
import{CurrentPageReference} from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
export default class ValidateDataList extends LightningElement {
@track options = [];
@api searchKey;
@track searchValue = '';
@api objectName;
@api fieldName;
@api keyField;
@track selectedAccount;
@track showAccountsListFlag = false;
@track isSelection = false;
@wire(fetchLookUpValues,{searchKey:'$searchKey',fieldName:'$fieldName',ObjectName:'$objectName',keyField:'$keyField'})
picklistvalues({data,error}){
        if(data){
        let picklistOptions = [{ key: '--None--', value: '--None--'}];
        data.forEach(key=>{
        picklistOptions.push({
        key:key[this.keyField],
        value:key[this.fieldName]
        });
        });
        this.options = picklistOptions;
        }
        else if(error){
        console.log(error);
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
  
    //alert(event.currentTarget.dataset.id);
    //alert(this.isSelection);

    //Currently this is used by Configuration field
    var eventParam = {'selectedvalueid': event.currentTarget.dataset.id};
    fireEvent(this.pageRef, 'validatedatavalue',eventParam);

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