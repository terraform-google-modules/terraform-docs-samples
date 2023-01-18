# [START terraform_eventarc_deploy_container]
echo "Get authentication credentials to interact with the cluster"
gcloud container clusters get-credentials eventarc-cluster \
   --region=us-central1

echo "Creating a deployment named hello-gke"
kubectl create deployment hello-gke \
   --image=gcr.io/cloudrun/hello

echo "Expose the deployment as a Kubernetes service"
# This creates a service with a stable IP accessible within the cluster.
kubectl expose deployment hello-gke \
 --type ClusterIP --port 80 --target-port 8080

# [END terraform_eventarc_deploy_container]
