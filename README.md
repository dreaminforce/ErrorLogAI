# Error Log AI Integration for Salesforce

## Overview

This repository contains an integration between Salesforce error logging and OpenAI's API, designed to assist in debugging Salesforce errors. Whenever an error is logged in the Salesforce org (through `Error_Log__c`), the integration sends the details to OpenAI's GPT model to provide suggested next steps for resolution. This can help developers and admins resolve issues quickly.

### Key Features
- Automatically processes error logs through OpenAI API to generate suggestions for error resolution.
- Stores AI-generated suggestions back in the error log record.
- Sends email notifications to admins with error details and AI suggestions.
- Provides Lightning components and custom metadata for easy customization of the error logging process.

## Components

### Trigger on Error Log Object

The trigger `ErrorLogTrigger` listens for new records on the `Error_Log__c` object and enqueues a job (`SendToOpenAIQueueable`) to process the error log with OpenAI.

### Queueable Class for OpenAI API Callout

`SendToOpenAIQueueable` is a queueable Apex class that sends the error details to OpenAI's Chat API. It then updates the error log record with AI suggestions.

- **API Key Management**: Uses `Meta_Assistant__mdt` custom metadata to store the OpenAI API Key.
- **HTTP Callout**: Performs an HTTP POST request to OpenAI's endpoint to get error suggestions.

### Email Notification to Admins

Upon receiving a response from OpenAI, an email is sent to the admin email addresses stored in the custom metadata (`Error_Log_Metadata_Detail__mdt`).

### Custom Metadata Configuration

`ErrorLogMetadataUpdater` allows admins to easily update custom metadata to store relevant configurations for error logging. It can store custom fields from the error log object in custom metadata for future reference.

### Lightning Web Component (LWC)

The `ErrorLogMetadataCreator` component provides a UI for selecting custom objects and updating metadata accordingly.

- **Component Features**:
  - A combobox to select available custom objects.
  - A button to create/update metadata for the selected object.
  - Toast notifications for feedback on success or error.

## Setup Instructions [STILL Under Development]

1. **Clone the Repository**: Clone the repository to your local machine.

2. **Deploy to Salesforce**: Deploy the Apex classes, triggers, custom metadata types, and Lightning Web Components to your Salesforce org using a tool like SFDX.

3. **Configure API Key**:
   - Create a custom metadata record (`Meta_Assistant__mdt`) and add your OpenAI API key to the `OpenAI_API_Key__c` field.

4. **Configure Admin Emails**:
   - Update the `Error_Log_Metadata_Detail__mdt` custom metadata to include the email addresses of admins who should receive error notifications.

5. **Testing**:
   - Create an error log record in your Salesforce org. Ensure that the `SendToOpenAIQueueable` job is triggered, and check the error log for AI suggestions.

## Important Considerations

- **API Limits**: The OpenAI API has rate limits. Consider your usage volume and adjust accordingly.
- **Sensitive Information**: Ensure error descriptions do not contain sensitive information before sending to OpenAI.
- **Callout Timeouts**: Salesforce callouts have a timeout limit of 120 seconds, which has been accounted for in the code.

## Customization

- **Extend Error Log Fields**: Modify the `Error_Log__c` object to capture more information about errors in your Salesforce org.
- **Adjust OpenAI Model**: The current implementation uses the `gpt-4o-mini` model, but this can be adjusted to a different model available through OpenAI.

## Contributing

If you would like to contribute to this project, please submit a pull request or open an issue for discussion.

## License

This project is licensed under the MIT License.

## Contact

For any questions or support, feel free to open an issue or contact the repository maintainer.
