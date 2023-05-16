const functions = require('@google-cloud/functions-framework');

// Register a CloudEvent callback with the Functions Framework that will
// be executed when the Eventarc trigger sends a message.
functions.cloudEvent('entryPoint', cloudEvent => {

    console.log(`Triggered by a CloudEvent, type: ${cloudEvent.type}`);

    if (cloudEvent.bucket != undefined) {
        console.log(`The CloudEvent originated from a GCS bucket: ${cloudEvent.bucket}`);
    }
});
