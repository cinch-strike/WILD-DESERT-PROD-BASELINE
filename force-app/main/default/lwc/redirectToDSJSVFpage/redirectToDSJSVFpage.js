import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RedirectToDSJSVFpage extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback() {
        this.navigateToVisualforcePage();
    }

    navigateToVisualforcePage() {
        if (this.recordId) {
            const visualforcePageUrl = '/apex/DailySiteJobSummary_VF?Id=' + this.recordId;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: visualforcePageUrl
                }
            });
        }
    }
}