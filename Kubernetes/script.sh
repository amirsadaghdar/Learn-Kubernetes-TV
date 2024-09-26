###################################
###                             ###
###     Learn Kubernetes TV     ###
###                             ###
###################################

#################
### Video 001 ###
#################

# Pre-reqs: aws cli, eksctl, kubectl.
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
# https://eksctl.io/installation/
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

# Setup the AWS iam user.

# AWS credentials are stored in ~/.aws/credentials
cat ~/.aws/credentials

# Check what AWS account and credenstials.
aws sts get-caller-identity
aws s3 ls

# Create a simple Kubernetes cluster with eksctl.
# Make sure eksctl is updated.
eksctl --help
eksctl version
eksctl info
eksctl get cluster

eksctl create cluster \
    --name lkt-temp-04 \
    --region eu-west-1 \
    --fargate \
    --version 1.30 \
    --tags "env=dev,owner=it"

# Add the cluster credentials to the local config file.
# Kubeconfig file path: ~/.kube/config
# The config could also be setup as an env var: echo $KUBECONFIG
aws eks --region eu-west-1 update-kubeconfig --name lkt-temp-03
cat ~/.kube/config

# Use kubectl to interact with kubernetes content.
kubectl config current-context
kubectl config get-contexts
kubectl config view
kubectl config use-context arn:aws:eks:eu-west-1:047838238778:cluster/lkt-temp-03
kubectl config delete-context arn:aws:eks:eu-west-1:047838238778:cluster/lkt-temp-03

# Get all the pods.
kubectl get pod -A

#################
### Video 002 ###
#################

# Get infromation about the cluster we are connected to.
kubectl cluster-info

# Get a list of all API resources available to us in this cluster.
kubectl api-resources

# Use kubectl explain to explore resource structure and properties.
kubectl explain pods
kubectl explain pods.spec
kubectl explain pods.spec.containers

# Key Differences between kubectl apply and kubectl create:
# Idempotency: kubectl apply is idempotent, meaning you can run it multiple times, and it will only make changes if there are differences between the manifest and the current state in the cluster. kubectl create is not idempotent; it will fail if the resource already exists.
# Resource updates: kubectl create does not update resources, while kubectl apply is designed for both creation and updates.
kubectl apply -f pod1.yaml
kubectl get pod
kubectl delete pod nginx
kubectl create -f pod1.yaml
kubectl get pod

# --dry-run server and client
# --dry-run=client - Useful for basic syntax checks of your YAML manifest. It verifies if the manifest is well-formed, but it doesn't check if the resources exist in the cluster or whether the API server would accept it.
# --dry-run=server - Ideal for ensuring that the manifest would be accepted and applied by the cluster without actually making any changes. It can detect issues like resource types that don’t exist on the server or configuration conflicts.
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment-error1.yaml --dry-run=client
kubectl apply -f deployment-error1.yaml --dry-run=server
kubectl apply -f deployment-error2.yaml --dry-run=client
kubectl apply -f deployment-error2.yaml --dry-run=server

# Generate the YAML file to create a resource.
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment-dry-run.yaml
kubectl apply -f deployment-dry-run.yaml
kubectl get deployment
kubectl delete deployment nginx

# Use kubectl diff
# The attribute used to identify which deployments to compare is the name of the resource (in this case, the Deployment) combined with the namespace.
# kubectl diff requires diff to be installed on the system.

kubectl apply -f deployment.yaml
kubectl diff -f deployment-modified.yaml
kubectl apply -f deployment-modified.yaml
kubectl get deployment
kubectl delete deployment hello-world

#################
### Video 003 ###
#################

# API Resources.
kubectl api-resources
kubectl get deployment --all-namespaces
kubectl get deploy -A
kubectl get pod --all-namespaces
kubectl get po -A

kubectl api-resources --api-group=apps
kubectl api-resources --api-group=rbac.authorization.k8s.io

kubectl explain pod --api-version v1

# Structure of an API request.
kubectl apply -f pod2.yaml
kubectl get pod hello-world

# Kubectl output verbosity and debugging levela are from 0 to 9
kubectl get pod hello-world -v 6
kubectl get pod hello-world -v 7
kubectl get pod hello-world -v 8
kubectl get pod hello-world -v 9

# Use kubectl proxy to authneticate against the API Server. & allows us to run more commands.
kubectl proxy --port=8080 &
curl http://localhost:8080/api/v1/namespaces/default/pods/hello-world

# Get the pod details in different ways.
kubectl get pod hello-world
kubectl describe pod hello-world
kubectl get pod hello-world -o yaml

# The --watch flag tells kubectl to continuously monitor the resources for changes. So, instead of fetching the pod status once, it keeps the terminal open and updates the list in real-time whenever there's any change.
kubectl get pods --watch -v 6

#Delete the pod and we see the updates are written to our stdout..
kubectl delete pods hello-world

#But let's bring our Pod back.
kubectl apply -f pod2.yaml

# Accessing pod logs.
kubectl logs hello-world
kubectl logs hello-world -v 6

kubectl proxy --port=8080 &
curl http://localhost:8080/api/v1/namespaces/default/pods/hello-world/log

# Auth failure
cp ~/.kube/config  ~/.kube/config.main

# Edit the username
vi ~/.kube/config
kubectl get pods -v 6

# Put our backup kubeconfig back
cp ~/.kube/config.main ~/.kube/config
kubectl get pods

#Missing resources, we can see the response code for this resources is 404...it's Not Found.
kubectl get pods nginx-pod -v 6

# Creating and deleting a deployment. 
kubectl apply -f deployment.yaml -v 6
kubectl get deployment 

# Delete the deployment. We see a DELETE 200 OK and a GET 200 OK.
kubectl delete deployment hello-world -v 6

#################
### Video 004 ###
#################

# List of all the namespaces
kubectl get namespaces

# List of all the API resources and if they can be in a namespace
kubectl api-resources --namespaced=true | head
kubectl api-resources --namespaced=false | head

# Understand the status of namespaces
kubectl describe namespaces

# Get the details of a namespace
kubectl describe namespaces kube-system

# Get all pods across all namespaces.
kubectl get pods --all-namespaces
kubectl get pods -A

# Get all  resource across all namespaces
kubectl get all --all-namespaces

# Get pods in the kube-system namespace
kubectl get pods --namespace kube-system

# Imperatively create a namespace
kubectl create namespace pandora1

# Namespace character restrictions. Lower case and only dashes.
kubectl create namespace Pandora1

# Create a namespace
cat  namespace.yaml
kubectl apply -f namespace.yaml

#Get a list of all the current namespaces
kubectl get namespaces

# Create a deployment into our pandora namespace
cat deployment.yaml
kubectl apply -f deployment.yaml

# Create a resource imperatively
kubectl run hello-world-pod \
    --image=gcr.io/google-samples/hello-app:1.0 \
    --namespace pandora1

kubectl get pods

#List all the pods on our namespace
kubectl get pods --namespace pandora1
kubectl get pods -n pandora1
kubectl get pods -A

# List  all  resources in a namespace.
kubectl get all --namespace=pandora1

# Review fargate profile.

eksctl create fargateprofile \
  --cluster lkt-temp-03 \
  --name fp-pandora \
  --namespace pandora1inyaml \
  --namespace pandora1

# Delete all the pods in our namespace.
# Pods under the Deployment controller will be recreated.
kubectl delete pods --all --namespace pandora1
kubectl get pods -n pandora1

# Delete all of the resources in our namespace and the namespace.
kubectl delete namespaces pandora1
kubectl delete namespaces pandorainyaml

#List all resources in all namespaces, now our Deployment is gone.
kubectl get all
kubectl get all --all-namespaces
kubectl get all -A

#################
### Video 005 ###
#################

# Create pods with labels
cat CreatePodsWithLabels.yaml
kubectl apply -f CreatePodsWithLabels.yaml

# Show Pod labels
kubectl get pods --show-labels
kubectl describe pod nginx-pod01

# Query labels and selectors
kubectl get pods --selector tier=prod
kubectl get pods --selector tier=qa
kubectl get pods -l tier=prod
kubectl get pods -l tier=prod --show-labels
kubectl get pods -l 'tier=prod,app=WebApp' --show-labels
kubectl get pods -l 'tier=prod,app!=WebApp' --show-labels
kubectl get pods -l 'tier in (prod,qa)' --show-labels
kubectl get pods -l 'tier notin (prod,qa)' --show-labels

# Output a label in column format
kubectl get pods -L tier
kubectl get pods -L tier,app

# Edit an existing label on a pod
kubectl get pod nginx-pod01 --show-labels
kubectl label pod nginx-pod01 tier=non-prod --overwrite
kubectl get pod nginx-pod01 --show-labels

# Adding a new label to a pod
kubectl get pod nginx-pod01 --show-labels
kubectl label pod nginx-pod01 another=Label
kubectl get pod nginx-pod01 --show-labels

# Removing an existing label
kubectl get pod nginx-pod01 --show-labels
kubectl label pod nginx-pod01 another-
kubectl get pod nginx-pod01 --show-labels

# Performing an operation on a collection of pods based on a label query
kubectl get pod --show-labels
kubectl label pod --all tier=non-prod --overwrite
kubectl get pod --show-labels

# Delete all pods matching our non-prod label
kubectl get pod --show-labels
kubectl delete pod -l tier=non-prod
kubectl get pods --show-labels

# Kubernetes Resource Management
# Create  a Deployment with 3 replicas.
# This selector is telling Kubernetes that the Deployment should manage Pods whose labels include app: hello-world.
# The selector is used to match Pods that were either created by this Deployment or manually labeled with the same app label.
kubectl apply -f deployment-label.yaml

# Expose the  Deployment as  Service.
kubectl apply -f service.yaml

# The deployment has a selector for app=hello-world
kubectl describe deployment hello-world
kubectl describe replicaset hello-world-58fc685665
kubectl describe pod hello-world-58fc685665-c272r
kubectl describe replicaset hello-world

# The Pods have labels for app=hello-world and for the pod-temlpate-hash of the current ReplicaSet
kubectl get pods --show-labels

# Edit the label on one of the Pods in the ReplicaSet and review the results.
kubectl label pod hello-world-58fc685665-c272r pod-template-hash=DEBUG --overwrite
kubectl get pods --show-labels

# Services use labels and selectors.
kubectl get service
kubectl describe service hello-world

# Get a list of all pods and IPs in the service.
kubectl describe endpoints hello-world
kubectl get pod -o wide
kubectl get pods --show-labels
kubectl label pod hello-world-58fc685665-c272r app=DEBUG --overwrite
kubectl get pods --show-labels
kubectl describe endpoints hello-world

# Delete the deployment, service and the Pod removed from the replicaset
kubectl delete deployment hello-world
kubectl delete service hello-world
kubectl get pods --show-labels
kubectl delete pod hello-world-58fc685665-c272r

# Scheduling a pod to a node
# Fargate does not support nodeSelector part of pod config.
# Review how labels can be used to impact pod scheduling.
kubectl get nodes --show-labels

kubectl label node ip-192-168-10-6.eu-west-1.compute.internal disk=local_ssd
kubectl label node ip-192-168-80-2.eu-west-1.compute.internal hardware=local_gpu

kubectl get node -L disk,hardware

# Create three Pods, two using nodeSelector, one without.
cat PodsToNodes.yaml
kubectl apply -f PodsToNodes.yaml

# View the scheduling of the pods in the cluster.
kubectl get node -L disk,hardware
kubectl get pods -o wide

# Clean up when we're finished, delete our labels and Pods
kubectl label node fargate-ip-192-168-125-157.eu-west-1.compute.internal disk-
kubectl label node fargate-ip-192-168-99-249.eu-west-1.compute.internal hardware-
kubectl delete pod nginx-pod
kubectl delete pod nginx-pod-gpu
kubectl delete pod nginx-pod-ssd
