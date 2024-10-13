import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateErrorLogMetadata from '@salesforce/apex/ErrorLogMetadataUpdater.updateErrorLogMetadata';
import getCustomObjectApiNames from '@salesforce/apex/ErrorLogMetadataUpdater.getCustomObjectApiNames';

export default class ErrorLogMetadataCreator extends LightningElement {
    @track objectApiNames = [];
    @track selectedObjectApiName = '';

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

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}