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
    --name lkt-temp-08 \
    --region eu-west-1 \
    --fargate \
    --version 1.30 \
    --tags "env=dev,owner=it"

# Add the cluster credentials to the local config file.
# Kubeconfig file path: ~/.kube/config
aws eks --region eu-west-1 update-kubeconfig --name lkt-temp-08
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
kubectl apply -f pod1.yaml
kubectl get pod
kubectl delete pod nginx
kubectl create -f pod1.yaml
kubectl get pod

# --dry-run server and client
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

# Use get command
kubectl get deployment  
kubectl get pod

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
kubectl get pod hello-world -v 5
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

# The --watch flag tells kubectl to continuously monitor the resources for changes.
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

# Resources Not Found. We can see the response code for this resources is 404.
kubectl get pods nginx-pod -v 6

# Creating and deleting a deployment. First checks to get a 404 and then creates the reosuce and get a 201.
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

# Set limit and quota on a namespace.
kubectl apply -f ns-limit.yaml
kubectl apply -f ns-quota.yaml

# Get limit and quota of a namespace.
kubectl describe limitrange -n kube-system
kubectl describe resourcequota -n kube-system

# Remove limit and quota from a namespace.
kubectl delete limitrange example-limits -n kube-system
kubectl delete resourcequota example-quota -n kube-system

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
kubectl create namespace Pandora2
kubectl create namespace pandora3-

# Create a namespace
cat  namespace.yaml
kubectl apply -f namespace.yaml

# Get a list of all the current namespaces
kubectl get namespaces

# Create a deployment into our pandora namespace
cat deployment.yaml
kubectl apply -f deployment.yaml
kubectl get deployment -n pandora1
kubectl describe deployment hello-world -n pandora1

# Create a resource imperatively
kubectl run hello-world-pod \
    --image=gcr.io/google-samples/hello-app:1.0 \
    --namespace pandora1

kubectl get pods -n pandora1
kubectl describe pod hello-world-pod -n pandora1

# Create fargate profile.
eksctl create fargateprofile \
  --cluster lkt-temp-04 \
  --name fp-pandora \
  --namespace pandora1inyaml \
  --namespace pandora1

kubectl delete pods --all --namespace pandora1

# List all the pods on our namespace
kubectl get pods --namespace pandora1
kubectl get pods -n pandora1
kubectl get pods -A

# List  all  resources in a namespace.
kubectl get all --namespace pandora1

# Delete all the pods in our namespace.
# Pods under the Deployment controller will be recreated.
kubectl delete deployment hello-world --namespace pandora1
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
cat pods-labels.yaml
kubectl apply -f pods-labels.yaml

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
kubectl label pod nginx-pod01 another=Label
kubectl get pod nginx-pod01 --show-labels

# Removing an existing label
kubectl label pod nginx-pod01 another-
kubectl get pod nginx-pod01 --show-labels

# Performing an operation on a collection of pods based on a label query
kubectl get pod --show-labels
kubectl label pod --all tier=non-prod --overwrite
kubectl get pod --show-labels

# Delete all pods matching our non-prod label
kubectl delete pod -l tier=non-prod
kubectl get pods --show-labels

# Kubernetes Resource Management
# Create  a Deployment with 4 replicas.
kubectl apply -f deployment-label.yaml
kubectl get pods

# Expose the  Deployment as  Service.
kubectl apply -f service.yaml

# The deployment has a selector for app=hello-world
kubectl describe deployment hello-world
kubectl describe replicaset hello-world-58fc685665
kubectl describe pod hello-world-58fc685665-65gdk
kubectl describe replicaset hello-world

# The Pods have labels for app=hello-world and for the pod-temlpate-hash of the current ReplicaSet
kubectl get pods --show-labels

# Edit the label on one of the Pods in the ReplicaSet and review the results.
kubectl label pod hello-world-58fc685665-65gdk pod-template-hash=DEBUG --overwrite
kubectl get pods --show-labels

# Services use labels and selectors.
kubectl get service
kubectl describe service hello-world

# Get a list of all pods and IPs in the service.
kubectl describe endpoints hello-world
kubectl get pod -o wide
kubectl get pods --show-labels
kubectl label pod hello-world-58fc685665-65gdk app=DEBUG --overwrite
kubectl get pods --show-labels
kubectl describe endpoints hello-world
kubectl describe service hello-world

# Delete the deployment, service and the Pod removed from the replicaset
kubectl delete deployment hello-world
kubectl delete service hello-world
kubectl get pods --show-labels
kubectl delete pod hello-world-58fc685665-65gdk

# Scheduling a pod to a node
# Review how labels can be used to impact pod scheduling.
# Fargate does not support nodeSelector as part of pod config. We create a node group.
kubectl get nodes --show-labels

kubectl label node ip-192-168-25-61.eu-west-1.compute.internal disk=local_ssd
kubectl label node ip-192-168-79-9.eu-west-1.compute.internal hardware=local_gpu

kubectl get node -L disk,hardware

# Create three Pods, two using nodeSelector, one without.
cat pods-nodes.yaml
kubectl apply -f pods-nodes.yaml

# View the scheduling of the pods in the cluster.
kubectl get node -L disk,hardware
kubectl get pods -o wide

# Clean up when we're finished, delete our labels and Pods.
kubectl delete pod nginx-pod
kubectl delete pod nginx-pod-gpu
kubectl delete pod nginx-pod-ssd

#################
### Video 006 ###
#################

# Run kubectl get events --watch.
kubectl get events --watch &

# Create a pod to see the scheduling process.
kubectl apply -f pod.yaml

# Create a Deployment with 1 replica.
kubectl apply -f deployment.yaml

# Scale a Deployment to 2 replicas.
kubectl scale deployment hello-world --replicas=2

# Scale down to 1 replica.
kubectl scale deployment hello-world --replicas=1

kubectl get pods -A

# Run a command inside our container.
kubectl exec --help
kubectl exec mypod -- date
kubectl -v 6 exec -it hello-world-7ccb7779c9-fhm6k -- /bin/sh
ps
exit

# Review the process on the node that runs the pod.
kubectl get pods -o wide

# Log into a node via ssm
ps -aux | grep hello-app
exit

# Access Pod's application directly, without a service.
kubectl port-forward hello-world-58fc685665-xl659 8080:8080 &

# Kubectl port-forward will send the traffic through the API server to the Pod
curl http://localhost:8080

# Kill our port forward session.
fg
ctrl+c

kubectl delete deployment hello-world
kubectl delete pod hello-world-pod

# Kill off the kubectl get events
fg
ctrl+c

# Static pods
# Create a pod manifest.
kubectl run hello-world --image=gcr.io/google-samples/hello-app:2.0 --dry-run=client -o yaml --port=8080

# Log into a node via ssm
sudo su -
systemctl status kubelet

# Find the static pod path.
sudo cat /etc/kubernetes/kubelet/kubelet-config.json
sudo vi /etc/kubernetes/kubelet/kubelet-config.json

# Add the static pod path details.
"staticPodPath": "/etc/kubernetes/manifests",

# Create a Pod manifest in the staticPodPath.
sudo vi /etc/kubernetes/manifests/mypod.yaml
ls /etc/kubernetes/manifests

# Get the pod detials running on the node.
ps aux | grep -i 'hello-world'

# Remove the static pod manifest on the node
sudo rm /etc/kubernetes/manifests/mypod.yaml

# The pod is now gone.
kubectl get pods 

#################
### Video 007 ###
#################

# Review the multi container pod definition
cat multicontainer-pod.yaml

# Create our multi-container Pod.
kubectl apply -f multicontainer-pod.yaml
kubectl get pods

# Cnnect to our Pod.
kubectl exec -it multicontainer-pod -- /bin/sh
ls -la /var/log
tail /var/log/index.html
exit

# Specify a container name and access the web container in our Pod
kubectl exec -it multicontainer-pod --container web -- /bin/sh
ls -la /usr/share/nginx/html
tail /usr/share/nginx/html/index.html
exit

#This application listens on port 80, we'll forward from 8080->80
kubectl port-forward multicontainer-pod 8080:80 &
curl http://localhost:8080

# Kill our port-forward.
fg
ctrl+c

kubectl delete pod multicontainer-pod

# Init container.
# Init container runs to completion. Then the other container will start and the Pod status changes to Running.
kubectl get pods --watch &

cat init-containers.yaml
kubectl apply -f init-containers.yaml

# Each init container starta serially and then the application container starts last.
kubectl describe pods init-containers

# Delete the pod
kubectl delete -f init-containers.yaml

#################
### Video 008 ###
#################

# Start  kubectl get events.
kubectl get events --watch &

# Create a pod.
kubectl apply -f pod.yaml

# Use killall to kill the hello-app process inside our container
kubectl exec -it hello-world-pod -- /bin/sh
ps
exit

kubectl exec -it hello-world-pod -- /usr/bin/killall hello-app

# The restart count increased by 1 after the container needed to be restarted.
kubectl get pods
kubectl describe pod hello-world-pod

kubectl delete pod hello-world-pod

fg
ctrl+c

# Explore pod restartPolicy
kubectl explain pods.spec.restartPolicy

# Create pods with the restart policy
cat  pod-restart-policy.yaml
kubectl apply -f pod-restart-policy.yaml

kubectl get pods 

# Kill our apps in both our pods and see how the container restart policy reacts
kubectl exec -it hello-world-never-pod -- /usr/bin/killall hello-app
kubectl get pods
kubectl describe pod hello-world-never-pod

kubectl exec -it hello-world-onfailure-pod -- /usr/bin/killall hello-app
kubectl get pods 

# Kill our app again in onfailure-pod.
kubectl exec -it hello-world-onfailure-pod -- /usr/bin/killall hello-app
kubectl get pods 
kubectl describe pod hello-world-onfailure-pod 

# The pod should be running, after the Backoff timer expires.
kubectl get pods 

kubectl delete pod hello-world-never-pod
kubectl delete pod hello-world-onfailure-pod

#################
### Video 009 ###
#################

# Liveness and Readiness probes.
kubectl get events --watch &

# Run a deployment with both a liveness probe and a readiness probe
cat container-probes.yaml
kubectl apply -f container-probes.yaml

fg
ctrl+c

# Container is not ready 0/1 and it's Restarts are increasing.
kubectl get pods

# Investigate the issue.
kubectl describe pods

# Change the probes to 8080 and redeploy the pod.
vi container-probes.yaml
kubectl apply -f container-probes.yaml

# Probes are pointing to the correct container port.
kubectl describe pods

# Check our status.
kubectl get pods 

kubectl delete deployment hello-world

# Work with startup probes.
kubectl get events --watch &

kubectl apply -f container-probes-startup.yaml

# Pod is restarting.
kubectl get pods

#Change the startup probe from 8081 to 8080
kubectl apply -f container-probes-startup.yaml

#Our pod should be up and Ready now.
kubectl get pods

fg
ctrl+c

kubectl delete -f container-probes-startup.yaml
