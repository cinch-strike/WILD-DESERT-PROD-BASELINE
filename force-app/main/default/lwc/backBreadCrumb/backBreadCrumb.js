import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class BackBreadCrumb extends NavigationMixin(LightningElement) {
  // Public Properties
  @api back_label; 
  @api back_url;
  @api current_label;
}