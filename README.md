# Autopilot GKE Pub/Sub Consumer Demo
This is a demo use case on how to deploy a Pub/Sub Consumer service to the Autopilot GKE cluster. 

Please note that if you would like to run this for your own service, make sure the GCP project id is replaced.

## Build the Docker Image
To build the Docker Image for the Pub/Sub Consumer Services, run
```
gcloud builds submit
``` 

## Create Topic & Subscription
```
gcloud pubsub topics create autopilot-test-topic
gcloud pubsub subscriptions create autopilot-test-sub --topic autopilot-test-topic
```

## Setup Workload Identity
### For the consumer
- GSA name is: `pubsub-consumer-demo-sa@rocketech-de-pgcp-sandbox.iam.gserviceaccount.com` - requires the Pub/Sub Subscriber Role
- KSA name is `pubsub-consumer-demo-sa`
- Namespace is `pubsub-consumer-demo`

```
gcloud iam service-accounts add-iam-policy-binding pubsub-consumer-demo-sa@rocketech-de-pgcp-sandbox.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:rocketech-de-pgcp-sandbox.svc.id.goog[pubsub-consumer-demo/pubsub-consumer-demo-sa]"

```

### For the metric adapter service
In order to be able to access the pubsub metrics, the custom metric stackdriver adapter has to be deployed to the cluster. Follow guide [here](https://cloud.google.com/kubernetes-engine/docs/tutorials/autoscaling-metrics#step1). 

If it doesn't work the first time, recreate the service will solve the problem.

- GSA name is `custom-metrics-sa@rocketech-de-pgcp-sandbox.iam.gserviceaccount.com` - requires the Monitoring Viewer Role
- KSA name is `custom-metrics-stackdriver-adapter`.
- Namespace is `custom-metrics`

```
gcloud iam service-accounts add-iam-policy-binding custom-metrics-sa@rocketech-de-pgcp-sandbox.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:rocketech-de-pgcp-sandbox.svc.id.goog[custom-metrics/custom-metrics-stackdriver-adapter]"

```
Now deploy the metric adaptor. Note the service account policy binding above must be done first before deploying the metric adapter service.
```
kubectl apply -f deployment/metric-adaptor.yaml
```

### Deploy consumer
Deploy Consumer
```
kubectl apply -f deployment/pubsub.yaml
```

Deploy Consumer HPA
```
kubectl apply -f deployment/pubsub-hpa.yaml
```

### Manage Balloon Pods
Create priority class
```
kubectl apply -f deployment/balloon-priority.yaml
```

Deploy balloon pods
```
kubectl apply -f deployment/balloon-deploy.yaml
```