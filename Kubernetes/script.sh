#########################
## Learn Kubernetes TV ##
#########################

## Video 001 ##

# Pre-reqs: aws cli, eksctl cli, kubectl.
# C:\Users\amirs\.aws\credentials

# Create Aliases
Set-Alias -Name k -Value "kubectl"
alias k='kubectl'

# Check what AWS account you are setup to communicate with:
aws sts get-caller-identity
aws s3 ls

# Create a simple Kubernetes cluster.
eksctl create cluster \
    --name lkt-temp-03 \
    --region eu-west-1 \
    --fargate \
    --version 1.30 \
    --tags "env=dev,owner=it"

eksctl --help
eksctl get cluster

# Add a cluster to the local config file.
aws eks --region eu-west-1 update-kubeconfig --name lkt-temp-03

# Config file path: ~/.kube/config
# The config could also be setup as an env var: echo $KUBECONFIG
kubectl config current-context
kubectl config get-contexts
kubectl config view
kubectl config use-context arn:aws:eks:eu-west-1:047838238778:cluster/lkt-temp-03
kubectl config delete-context arn:aws:eks:eu-west-1:047838238778:cluster/lkt-temp-03

# Get all the pods.
kubectl get pod -A


## Video 002 ##

# API Resources.
kubectl cluster-info

kubectl api-resources

kubectl explain pods
kubectl explain pods.spec
kubectl explain pods.spec.containers

kubectl apply -f pod1.yaml
kubectl get pod

# Key Differences between kubectl apply and kubectl create:
# Idempotency: kubectl apply is idempotent, meaning you can run it multiple times, and it will only make changes if there are differences between the manifest and the current state in the cluster. kubectl create is not idempotent; it will fail if the resource already exists.
# Resource updates: kubectl create does not update resources, while kubectl apply is designed for both creation and updates.



# YAML


# dry-run=


# diff