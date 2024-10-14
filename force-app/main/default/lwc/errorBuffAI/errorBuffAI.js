import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateErrorLogMetadata from '@salesforce/apex/ErrorLogMetadataUpdater.updateErrorLogMetadata';
import getCustomObjectApiNames from '@salesforce/apex/ErrorLogMetadataUpdater.getCustomObjectApiNames';
import updateSenderList from '@salesforce/apex/ErrorLogMetadataUpdater.updateSenderList';

export default class ErrorLogMetadataCreator extends LightningElement {
    @track objectApiNames = [];
    @track selectedObjectApiName = '';
    @track emailList = '';

    // Fetch available custom object API names
    @wire(getCustomObjectApiNames)
    wiredCustomObjectApiNames({ data, error }) {
        if (data) {
            this.objectApiNames = data.map((apiName) => ({ label: apiName, value: apiName }));
        } else if (error) {
            this.showToast('Error', 'Error retrieving custom object information', 'error');
        }
    }

    handleObjectChange(event) {
        this.selectedObjectApiName = event.target.value;
    }

    handleCreateMetadata() {
        if (this.selectedObjectApiName) {
            updateErrorLogMetadata({ errorLogObjectApiName: this.selectedObjectApiName })
                .then(() => {
                    this.showToast('Success', 'Metadata created successfully', 'success');
                })
                .catch((error) => {
                    this.showToast('Error', 'Error creating metadata: ' + error.body.message, 'error');
                });
        } else {
            this.showToast('Error', 'Please select an object before creating metadata', 'error');
        }
    }

    handleEmailListChange(event) {
        this.emailList = event.target.value;
    }

    handleUpdateSenderList() {
        if (this.emailList) {
            updateSenderList({ emailList: this.emailList })
                .then(() => {
                    this.showToast('Success', 'Sender list updated successfully', 'success');
                })
                .catch((error) => {
                    this.showToast('Error', 'Error updating sender list: ' + error.body.message, 'error');
                });
        } else {
            this.showToast('Error', 'Please enter email addresses before updating sender list', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}