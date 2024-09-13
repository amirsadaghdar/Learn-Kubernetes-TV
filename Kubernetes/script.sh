# Create the Kubernetes cluster.

# Pre-reqs: aws cli, eksctl cli, kubectl.
# C:\Users\amirs\.aws\credentials

# Create Aliases
Set-Alias -Name k -Value "kubectl"
alias k='kubectl'

# Check what AWS account you are setup to communicate with:
aws sts get-caller-identity
aws s3 ls

# Create a simple Kubernetes cluster
eksctl create cluster \
    --name lkt-temp-02 \
    --region eu-west-1 \
    --fargate \
    --version 1.30 \
    --tags "env=dev,owner=it"

# Add a cluster to the local config file.
aws eks --region eu-west-1 update-kubeconfig --name lkt-temp-02

# Config file path: ~/.kube/config
# The config could also be setup as an env var: echo $KUBECONFIG
kubectl config current-context
kubectl config get-contexts
kubectl config view
kubectl config use-context arn:aws:eks:eu-west-1:047838238778:cluster/lkt-temp-02
kubectl config delete-context arn:aws:eks:eu-west-1:047838238778:cluster/lkt-temp-02

# Get all the pods.
kubectl get pod -A