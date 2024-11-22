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
kubectl config use-context arn:aws:eks:eu-west-1:047838238778:cluster/lkt-temp-08
kubectl config delete-context arn:aws:eks:eu-west-1:047838238778:cluster/lkt-temp-08

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

# Delete the deployment.
kubectl delete deployment hello-world
kubectl delete pod hello-world-pod

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

# Delete the deployment.
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

# Create a node group and delete the fargate profile.
# Create a pod schedule on the node group.
kubectl apply -f pod.yaml
kubectl get pod

# Identify the node that's running the pod and restart the EC2 instance.
kubectl get pod -o wide

# The restart count increased by 1 after the container needed to be restarted.
kubectl get pods
kubectl describe pod hello-world-pod

kubectl delete pod hello-world-pod

# Explore pod restartPolicy
kubectl explain pods.spec.restartPolicy

# Create pods with the restart policy
cat  pod-restart-policy.yaml
kubectl apply -f pod-restart-policy.yaml

# Identify the node that's running the pod and restart the EC2 instance.
kubectl get pods -o wide

# Kill both  pods and see how the container restart policy reacts
kubectl get pods -o wide
kubectl describe pod hello-world-never-pod
kubectl describe pod hello-world-onfailure-pod 

# Kill our app again in onfailure-pod.
kubectl get pods -o wide
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

cat container-probes-startup.yaml
kubectl apply -f container-probes-startup.yaml

# Pod is restarting.
kubectl get pods
kubectl describe pods

#Change the startup probe from 8081 to 8080.
kubectl apply -f container-probes-startup.yaml

#Our pod should be up and Ready now.
kubectl get pods

# Delete the deployment.
kubectl delete -f container-probes-startup.yaml


#################
### Video 010 ###
#################

# Examining System Pods and their Controllers.
kubectl get all --namespace kube-system
kubectl get pod --namespace kube-system

# Look into codedns deployment.
kubectl get deployments coredns --namespace kube-system
kubectl describe deployments coredns --namespace kube-system
kubectl get pods --selector=k8s-app=kube-dns --namespace kube-system
kubectl describe pod coredns-5fb59c9c7b-pwf7l --namespace kube-system
kubectl exec -it coredns-5fb59c9c7b-pwf7l --namespace kube-system -- cat /etc/coredns/Corefile

# Daemonset Pods run on every node in the cluster by default, as new nodes are added these will be deployed to those nodes.
kubectl get daemonset --namespace kube-system
kubectl describe daemonset aws-node --namespace kube-system
kubectl get pods --selector=k8s-app=aws-node --namespace kube-system
kubectl describe pod aws-node-9kqh9 --namespace kube-system
kubectl get pod aws-node-9kqh9 --namespace kube-system -o jsonpath='{.spec.containers[*].name}'
kubectl exec -it aws-node-9kqh9 --namespace kube-system -- ls

kubectl describe daemonset kube-proxy --namespace kube-system
kubectl get pods --selector=k8s-app=kube-proxy --namespace kube-system
kubectl describe pod kube-proxy-9dwk5 --namespace kube-system
kubectl get pod kube-proxy-9dwk5 --namespace kube-system -o jsonpath='{.spec.containers[*].name}'
kubectl exec --namespace kube-system -it kube-proxy-9dwk5 -- ls

kubectl get nodes

#################
### Video 011 ###
#################

# Creating a Deployment Imperatively, with kubectl create.
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0
kubectl scale deployment hello-world --replicas=5

kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0 --replicas=5

kubectl get deployment 

# Remove our resources.
kubectl delete deployment hello-world

# Creat2 a deployment with a service declaratively.
kubectl apply -f deployment.yaml
kubectl get deployments hello-world

# Replicaset has the responsibility of keeping and maintaining the desired state of our application.
kubectl get replicasets
kubectl get pods
kubectl describe pods
kubectl describe deployment
kubectl set image deployment/hello-world hello-world=gcr.io/google-samples/hello-app:2.0
kubectl rollout restart deployment/hello-world

# Rollback the update.
kubectl rollout undo deployment/hello-world
kubectl describe deployment hello-world
kubectl rollout history deployment/hello-world
kubectl rollout undo deployment/hello-world --to-revision=1

# Remove our resources.
kubectl delete deployment hello-world
kubectl delete service hello-world

# Deploy a Deployment which creates a ReplicaSet.
kubectl apply -f deployment.yaml
kubectl get replicaset

# Let's look at the selector and the labels in the pod template - Match Label.
kubectl describe replicaset hello-world

# Let's delete this deployment which will delete the replicaset.
kubectl delete deployment hello-world
kubectl get replicaset

# Deploy a ReplicaSet with matchExpressions.
kubectl apply -f deployment-me.yaml

# Check on the status of our ReplicaSet.
kubectl get replicaset

# Look at the Selector and the labels in the pod template - Match Expression.
kubectl describe replicaset hello-world

# Deleting a Pod in a ReplicaSet, application will self-heal itself
kubectl get pods
kubectl delete pods hello-world-64f9bb65b8-289cs
kubectl get pods

#################
### Video 012 ###
#################

kubectl apply -f deployment.yaml
kubectl get deployments hello-world 
kubectl describe deployments hello-world

# Isolating a Pod from a ReplicaSet.
kubectl get pods --show-labels

# Edit the label on one of the Pods in the ReplicaSet, the replicaset controller will create a new pod.
kubectl label pod hello-world-64f9bb65b8-k684n app=DEBUG --overwrite
kubectl get pods --show-labels

# Relabel that pod to bring it back into the scope of the replicaset.
kubectl label pod hello-world-64f9bb65b8-k684n app=hello-world-pod-me --overwrite

# One Pod will be terminated, since it will maintain the desired number of replicas at 5.
kubectl get pods --show-labels
kubectl describe ReplicaSets

# Node failures in ReplicaSets. Shutdown a node.
# Orphaned Pod goes Terminating and a new Pod will be deployed in the cluster.
kubectl get nodes --watch
kubectl get pods -o wide


# Node group create a new node and leave the old node in disbaled state.
kubectl get nodes
kubectl get pods -o wide

# let's clean up the deployment and service.
kubectl delete deployment hello-world
kubectl delete service hello-world


#################
### Video 013 ###
#################

# Updating a Deployment and checking our rollout status
kubectl apply -f deployment.yaml
kubectl get deployment hello-world
kubectl describe deployment hello-world

# Update the deployment.
kubectl apply -f deployment.v2.yaml

# Check the status of that rollout.
kubectl rollout status deployment hello-world

# Expect a return code of 0 from kubectl rollout status. That's how we know we're in the Complete status.
echo $?


#Let's walk through the description of the deployment...
#Check out Replicas, Conditions and Events OldReplicaSet (will only be populated during a rollout) and NewReplicaSet
#Conditions (more information about our objects state):
#     Available      True    MinimumReplicasAvailable
#     Progressing    True    NewReplicaSetAvailable (when true, deployment is still progressing or complete)
kubectl describe deployments hello-world

# Both replicasets remain. That will become very useful when we use a rollback.
kubectl get replicaset
kubectl get replicaset -o wide

# The NewReplicaSet detials.
kubectl describe replicaset hello-world-5b4bddcd4

# The OldReplicaSet details.
kubectl describe replicaset hello-world-58fc685665

# Clean-up the deployment.
kubectl delete deployment hello-world
kubectl delete service hello-world

#################
### Video 014 ###
#################

# Create our v1 deployment, then update it to v2
kubectl apply -f deployment.yaml
kubectl apply -f deployment.v2.yaml

# The new image wasn’t available, the ReplicaSet doesn't go below maxUnavailable.
# progressDeadlineSeconds set to 10 to get to failure state quickly.
kubectl apply -f deployment.broken.yaml

# After progressDeadlineSeconds which we set to 10 seconds the rollout stop (defaults to 10 minutes).
kubectl rollout status deployment hello-world

# Expect a return code of 1 from kubectl rollout status...that's how we know we're in the failed status.
echo $?

# Check out Pods, ImagePullBackoff/ErrImagePull.
# Deployment stopped the rollout 5 and 8 are online, let's look at why.
kubectl get pods

# maxUnavailable = 25%. So only two Pods in the ORIGINAL ReplicaSet are offline and 8 are online.
# maxSurge = 25%. So we have 13 total Pods, or 25% in addition to Desired number.
# Look at Replicas and OldReplicaSet 8/8 and NewReplicaSet 5/5.
# Available      True    MinimumReplicasAvailable
# Progressing    False   ProgressDeadlineExceeded
kubectl describe deployments hello-world 

# Check the rollout history.
kubectl rollout history deployment hello-world

# Check what revision you are on now.
kubectl describe deployments hello-world | head

# Look at the changes applied in each revision to see the new pod templates.
kubectl rollout history deployment hello-world --revision=2
kubectl rollout history deployment hello-world --revision=3

# Rollout to revision 2, which is our v2 container.
kubectl rollout undo deployment hello-world --to-revision=2
kubectl rollout status deployment hello-world
echo $?

kubectl get pods

# Delete this Deployment and Service.
kubectl delete deployment hello-world
kubectl delete service hello-world

#################
### Video 015 ###
#################

# Controlling the rate and update strategy of a Deployment update. Deploy a Deployment with Readiness Probes
kubectl apply -f deployment.probes-1.yaml --record

# Available is still 0 because of our Readiness Probe's initialDelaySeconds is 10 seconds.
kubectl describe deployment hello-world

# Check again, Replicas and Conditions, all Pods should be online and ready.
kubectl describe deployment hello-world

# Let's update from v1 to v2 with Readiness Probes Controlling the rollout, and record our rollout
diff deployment.probes-1.yaml deployment.probes-2.yaml
kubectl apply -f deployment.probes-2.yaml --record
kubectl describe deployment hello-world

# Lots of pods are created where most are not ready yet, but progressing.
kubectl get replicaset

# We use the update strategy settings of max unavailable and max surge to slow this rollout down.
kubectl describe deployment hello-world


# Let's update again, but I'm not going to tell you what I changed, we're going to troubleshoot it together
kubectl apply -f deployment.probes-3.yaml --record

# We stall at 4 out of 20 replicas updated.
kubectl rollout status deployment hello-world

# Let's check the status of the Deployment, Replicas and Condition.
kubectl describe deployment hello-world

# Let's look at our ReplicaSets, no Pods in the new RepllicaSets.
# That ReplicaSet with Desired 0 is from our V1 deployment, 18 is from our V2 deployment.
kubectl get replicaset

# A Readiness Probe keeps a pod from reporting ready
kubectl describe deployment hello-world
 
# We can read the Deployment's rollout history, and see our CHANGE-CAUSE annotations
kubectl rollout history deployment hello-world

# Let's rollback to revision 2 to undo that change.
kubectl rollout history deployment hello-world --revision=3
kubectl rollout history deployment hello-world --revision=2
kubectl rollout undo deployment hello-world --to-revision=2

# And check out our deployment to see if we get 20 Ready replicas
kubectl describe deployment
kubectl get deployment

# Let's clean up
kubectl delete deployment hello-world
kubectl delete service hello-world

# Restarting a deployment.
Create a fresh deployment so we have easier to read logs.
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0 --replicas=5

# Check the status of the deployment
kubectl get deployment

# Check the status of the pods.
kubectl get pods 

# Let's restart a deployment
kubectl rollout restart deployment hello-world 

# You get a new replicaset and the pods in the old replicaset are shutdown and the new replicaset are started up.
kubectl describe deployment hello-world

# All new pods in the replicaset 
kubectl get pods 

# Clean up the pods
kubectl delete deployment hello-world


#################
### Video 016 ###
#################

# Create a deployment imperatively.
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0

# Check out the status of our deployment.
kubectl get deployment hello-world

# Scale our deployment from 1 to 10 replicas
kubectl scale deployment hello-world --replicas=10

# Check out the status of our deployment.
kubectl get deployment hello-world

# Delete the deployment.
kubectl delete deployment hello-world

# Deploy our Deployment via yaml.
kubectl apply -f deployment.yaml 

# Check the status of our deployment.
kubectl get deployment hello-world

# Apply a modified yaml file scaling from 10 to 20 replicas.
diff deployment.yaml deployment.20replicas.yaml
kubectl apply -f deployment.20replicas.yaml

# Check the status of the deployment
kubectl get deployment hello-world

# Check out the events where the replicaset is scaled to 20
kubectl describe deployment 

# Clean-up.
kubectl delete deployment hello-world
kubectl delete service hello-world

#################
### Video 017 ###
#################

# Creating a DaemonSet on All Nodes
kubectl get nodes
kubectl get daemonsets --namespace kube-system kube-proxy

# Create a DaemonSet with Pods on each node in our cluster.
kubectl apply -f DaemonSet.yaml

# We will get 2 pods on the 2 worker nodes.
kubectl get daemonsets
kubectl get daemonsets -o wide
kubectl get pods -o wide

# Review labels, Desired/Current Nodes Scheduled. Pod Status and Template and Events.
kubectl describe daemonsets hello-world

# Each Pods is created with our label, app=hello-world, controller-revision-hash and a pod-template-generation
kubectl get pods --show-labels

# Let's change the label to one of our Pods.
MYPOD=$(kubectl get pods -l app=hello-world-app | grep hello-world | head -n 1 | awk {'print $1'})
echo $MYPOD
kubectl label pods $MYPOD app=not-hello-world --overwrite

# We'll get a new Pod from the DaemonSet Controller.
kubectl get pods --show-labels

# Let's clean up this DaemonSet
kubectl delete daemonsets hello-world-ds
kubectl delete pods $MYPOD

# Creating a DaemonSet on a Subset of Nodes
# Let's create a DaemonSet with a defined nodeSelector
kubectl apply -f DaemonSetWithNodeSelector.yaml

#No pods created because we don't have any nodes with the appropriate label
kubectl get daemonsets

#We need a Node that satisfies the Node Selector. Let's label our nodes.
kubectl get nodes
kubectl describe node ip-192-168-104-199.eu-west-1.compute.internal
kubectl label node ip-192-168-104-199.eu-west-1.compute.internal node=hello-world-ns

# Let's see if a Pod gets created.
kubectl get daemonsets
kubectl get daemonsets -o wide
kubectl get pods -o wide

# Let's remove the label.
kubectl label node ip-192-168-104-199.eu-west-1.compute.internal node-

# It's going to terminate the Pod.
kubectl describe daemonsets hello-world-ds

# Clean up our demo
kubectl delete daemonsets hello-world-ds

# Updating a DaemonSet.
# Deploy our v1 DaemonSet.
kubectl apply -f DaemonSet.yaml

# Check out our image version, 1.0
kubectl get daemonsets
kubectl describe daemonsets hello-world

# Examine the update stategy. Defaults is rollingUpdate and maxUnavailable 1
kubectl get DaemonSet hello-world-ds -o yaml

# Update the container image from 1.0 to 2.0 and apply the config
diff DaemonSet.yaml DaemonSet-v2.yaml
kubectl apply -f DaemonSet-v2.yaml

# Check on the status of our rollout, slightly slower than a deployment due to maxUnavailable.
kubectl rollout status daemonsets hello-world-ds

# TheDaemonSet Container Image is now 2.0.
kubectl describe daemonsets

# The new controller-revision-hash and also an updated pod-template-generation
kubectl get pods --show-labels

# Vlean up the daemonset.
kubectl delete daemonsets hello-world-ds

#################
### Video 018 ###
#################