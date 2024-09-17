###################################
###                             ###
###     Learn Kubernetes TV     ###
###                             ###
###################################

#################
### Video 001 ###
#################

# Pre-reqs: aws cli, eksctl cli, kubectl.
# C:\Users\amirs\.aws\credentials

# Create Aliases
Set-Alias -Name k -Value "kubectl"
alias k='kubectl'

# Check what AWS account and credenstials.
aws sts get-caller-identity
aws s3 ls

# Create a simple Kubernetes cluster with eksctl.
eksctl create cluster \
    --name lkt-temp-03 \
    --region eu-west-1 \
    --fargate \
    --version 1.30 \
    --tags "env=dev,owner=it"

eksctl --help
eksctl get cluster

# Add the cluster credentials to the local config file.
# Config file path: ~/.kube/config
# The config could also be setup as an env var: echo $KUBECONFIG
aws eks --region eu-west-1 update-kubeconfig --name lkt-temp-03

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

# API Resources.
kubectl cluster-info

kubectl api-resources

# Use kubectl explain to explore resource properties.
kubectl explain pods
kubectl explain pods.spec
kubectl explain pods.spec.containers

kubectl apply -f pod1.yaml
kubectl get pod

# Key Differences between kubectl apply and kubectl create:
# Idempotency: kubectl apply is idempotent, meaning you can run it multiple times, and it will only make changes if there are differences between the manifest and the current state in the cluster. kubectl create is not idempotent; it will fail if the resource already exists.
# Resource updates: kubectl create does not update resources, while kubectl apply is designed for both creation and updates.

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
kubectl get deploy -A
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

# Try to access our cluster
kubectl get pods -v 6

# Put our backup kubeconfig back
cp ~/.kube/config.main ~/.kube/config

# Test out access to the API Server
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