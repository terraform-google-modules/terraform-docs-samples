#! /usr/bin/bash

echo "adding environment variable to your local machine replacing terraform variables from variables.tf"

 export TF_VAR_google_compute_instance_name=$INSTANCE_NAME
 export TF_VAR_google_compute_instance_machine_type=$INSTANCE_TYPE
 export TF_VAR_google_compute_instance_zone=$ZONE
 export TF_VAR_boot_disk_initialize_params_image=$IMAGE
 export TF_VAR_network_interface_network=$NETWORK
 
# confirming that env_variables have been propagated correctly
 echo "$TF_VAR_google_compute_instance_name"
 echo "$TF_VAR_google_compute_instance_machine_type"
 echo "$TF_VAR_google_compute_instance_zone"
 echo "$TF_VAR_boot_disk_initialize_params_image"
 echo "$TF_VAR_network_interface_network"
 
 
  
 

