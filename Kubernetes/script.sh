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

# Executing tasks with Jobs.
# The restartPolicy must be OnFailure or Never.
kubectl apply -f job.yaml

# Follow job status with a watch
kubectl get job --watch

# Get the list of Pods, status is Completed and Ready is 0/1
kubectl get pods

# Get some more details about the job.
kubectl describe job hello-world-job

#Get the logs from stdout from the Job Pod
kubectl get pods -l job-name=hello-world-job 
kubectl logs hello-world-job-sbjps

# The Job is completed, but it still exists as a resource. We can go ahead and delete ths job.
kubectl delete job hello-world-job

# This will also delete it's Pods
kubectl get pods

# BackoffLimit allows us to retry running failed job.
# We'll use Never for backoffLimit so our pods aren't deleted after backoffLimit is reached.
kubectl apply -f job-failure-OnFailure.yaml

# Review the pods, enters a backoffloop after 2 crashes.
kubectl get pods --watch

# The pods aren't deleted so we can troubleshoot here if needed.
kubectl get pods

# The job won't have any completions and it doesn't get deleted.
kubectl get jobs 

# Let's review what the job did.
kubectl describe jobs

# Clean up this job
kubectl delete jobs hello-world-job-fail
kubectl get pods

# Defining a Parallel Job
kubectl apply -f ParallelJob.yaml

# 10 Pods will run in parallel up until 50 completions.
kubectl get pods

# We can 'watch' the Statuses with watch.
watch 'kubectl describe job | head -n 15'

#We'll get to 50 completions very quickly
kubectl get jobs

# Let's clean up.
kubectl delete job hello-world-job-parallel

# Scheduling tasks with CronJobs
kubectl apply -f CronJob.yaml

# Get the job and it's schedule
kubectl get cronjobs

# Look closer at the job.
kubectl describe cronjobs

# Get a overview again...
kubectl get cronjobs

# The pods will stick around, in the event we need their logs or other inforamtion.
kubectl get pods --watch

# The pods will stick around for successfulJobsHistoryLimit, which defaults to three.
kubectl get cronjobs -o yaml

# Clean up the job.
kubectl delete cronjob hello-world-cron

# Deletes all the Pods too.
kubectl get pods

#################
### Video 019 ###
#################

# Setup NFS in AWS by creating an EFS volume. Make sure to adjust the secuirty groups on the EFS resource to allow access from the worker nodes.
# Login to each one of the workder nodes to mount the EFS file system.
sudo yum install -y nfs-utils
sudo mkdir /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0d224492c2b75a83d.efs.eu-west-1.amazonaws.com:/ /mnt/efs
df -h
sudo vi /etc/fstab
fs-0d224492c2b75a83d.efs.eu-west-1.amazonaws.com:/ /mnt/efs nfs4 defaults,_netdev 0 0
cd /mnt/efs

# Static Provisioning Persistent Volumes
#Create a PV with the read/write many and retain as the reclaim policy
kubectl apply -f efs.pv.yaml
kubectl get pv

# Review the created resources, Status, Access Mode and Reclaim policy is set to Reclaim rather than Delete. 
kubectl get PersistentVolume pv-efs-data
kubectl describe PersistentVolume pv-efs-data

# Create a PVC on the PV
kubectl apply -f efs.pvc.yaml

# Check the status, now it's Bound due to the PVC on the PV.
kubectl get PersistentVolume
kubectl get PersistentVolume pv-efs-data

# Check the status, Bound.
# We defined the PVC it statically provisioned the PV but it's not mounted yet.
kubectl get PersistentVolumeClaim
kubectl get PersistentVolumeClaim pvc-efs-data
kubectl describe PersistentVolumeClaim pvc-efs-data

# Create some content on our EFS.
sudo bash -c 'echo "Hello from our EFS mount!!!" > /mnt/efs/pod/demo.html'
more /mnt/efs/pod/demo.html

# Let's create a Pod (in a Deployment and add a Service) with a PVC on pvc-nfs-data
kubectl apply -f efs.nginx.yaml
kubectl get service nginx-efs-service
SERVICEIP=$(kubectl get service | grep nginx-efs-service | awk '{ print $3 }')

# Check to see if our pods are Running before proceeding
kubectl get pods

# Let's access that application to see our application data...
curl http://$SERVICEIP/web-app/pod/demo.html
curl http://10.100.194.10/web-app/pod/demo.html
curl http://192.168.44.229/web-app/pod/demo.html

# Check the "Mounted By" output for which Pod(s) are accessing this storage
kubectl describe PersistentVolumeClaim pvc-efs-data

# If we go 'inside' the Pod/Container, we can find out where the PV is mounted
kubectl exec -it nginx-efs-deployment-b4955796b-c58kx -- /bin/bash
ls /usr/share/nginx/html/web-app/pod
more /usr/share/nginx/html/web-app/pod/demo.html
exit

# Identify the node the pod is running on.
kubectl get pods -o wide

# Log into that node and look at the mounted volumes.
# kubelets makes the device/mount available.
mount | grep nfs
exit

# Delete the pod and see if we still have access to our data in our PV.
kubectl get pods
kubectl delete pods nginx-efs-deployment-b4955796b-c58kx

# We get a new pod, but is our app data still there.
kubectl get pods

#Let's access that application to see our application data...yes!
curl http://$SERVICEIP/web-app/demo.html

# Controlling PV access with Access Modes and persistentVolumeReclaimPolicy.
# scale up the deployment to 4 replicas.
kubectl scale deployment nginx-efs-deployment --replicas=4

# All 4 pods are attached to the PVC.
#Our AccessMode for this PV and PVC is RWX ReadWriteMany.
kubectl describe PersistentVolumeClaim

# Now when we access our application we're getting load balanced across all the pods hitting the same PV data
curl http://$SERVICEIP/web-app/demo.html

# Let's delete our deployment
kubectl delete deployment nginx-nfs-deployment

# The status of the PV is still bound.
kubectl get PersistentVolume 

# Because the PVC still exists.
kubectl get PersistentVolumeClaim

# We can re-use the same PVC and PV from a Pod definition. Because we didn't delete the PVC.
kubectl apply -f efs.nginx.yaml
kubectl get pods 

#But if we delete the deployment AND the PersistentVolumeClaim
kubectl delete deployment nginx-efs-deployment
kubectl delete PersistentVolumeClaim pvc-efs-data

# The status of the PV is now Released, which means no one can claim this PV
kubectl get PersistentVolume

# But let's try to use it and see what happend, recreate the PVC for this PV. PVC cannot be recreated.
kubectl apply -f efs.pvc.yaml

# Then try to use the PVC/PV in a Pod definition
kubectl apply -f efs.nginx.yaml
kubectl get pods

# The PVC Status is Pending because that PV is Released and our Reclaim Policy is Retain.
kubectl get PersistentVolumeClaim
kubectl get PersistentVolume

# We need to delete the PV if we want to 'reuse' that exact PV and 're-create' the PV
kubectl delete deployment nginx-efs-deployment
kubectl delete pvc pvc-efs-data
kubectl delete pv pv-efs-data

# If we recreate the PV, PVC, and the pods. we'll be able to re-deploy. 
# The clean up of the data is defined by the reclaim policy. (Delete will clean up for you, useful in dynamic provisioning scenarios)
# But in this case, since it's EFS, we have to clean it up and remove the files
# Nothing will prevent a user from getting this acess to this data, so it's imperitive to clean up. 
kubectl apply -f efs.pv.yaml
kubectl apply -f efs.pvc.yaml
kubectl apply -f efs.nginx.yaml
kubectl get pods 

# Time to clean up for the next demo
kubectl delete -f efs.nginx.yaml
kubectl delete pvc pvc-efs-data
kubectl delete pv pv-efs-data


#################
### Video 020 ###
#################

# StorageClasses and Dynamic Provisioning in the AWS
# Install Amazon EBS CSI Driver add-on in the EKS cluster.
# Check out the  list of available storage classes. Notice the Provisioner, Parameters and ReclaimPolicy.
kubectl get StorageClass
kubectl describe StorageClass gp2

# Create a Deployment of an nginx pod with a ReadWriteOnce disk, 
# We create a PVC and a Deployment that creates Pods that use that PVC
kubectl apply -f AWSDisk.yaml

# Check out the Access Mode, Reclaim Policy, Status, Claim and StorageClass
kubectl get PersistentVolume

#Check out the Access Mode on the PersistentVolumeClaim, status is Bound and it's Volume is the PV dynamically provisioned
kubectl get PersistentVolumeClaim

# Check out single pod was created (the Status can take a second to transition to Running)
kubectl get pods

# Clean up the resources.
kubectl delete deployment nginx-awsdisk-deployment
kubectl delete PersistentVolumeClaim pvc-aws-managed

# Defining a custom StorageClass in Azure
kubectl apply -f CustomStorageClass.yaml

# Get a list of the current StorageClasses kubectl get StorageClass.
kubectl get StorageClass

# Take a closer look at the SC, you can see the Reclaim Policy is Delete since we didn't set it in our StorageClass yaml.
kubectl describe StorageClass gp2-storage-class

# Use our new StorageClass
kubectl apply -f AWSDiskCustomStorageClass.yaml

# Take a closer look at our new Storage Class, Reclaim Policy Delete
kubectl get PersistentVolumeClaim
kubectl get PersistentVolume

# Clean up the resources
kubectl delete deployment nginx-awsdisk-deployment-standard-ssd
kubectl delete PersistentVolumeClaim pvc-aws-standard-ssd
kubectl delete StorageClass managed-standard-ssd

#################
### Video 021 ###
#################

# Passing Configuration into Containers using Environment Variables.
# Create two deployments, one for a database system and the other our application.
kubectl apply -f deployment-alpha.yaml
sleep 5
kubectl apply -f deployment-beta.yaml

# Look at the services
kubectl get service
kubectl describe service hello-world-alpha

# Get the name of one of our pods
PODNAME=$(kubectl get pods | grep hello-world-alpha | awk '{print $1}' | head -n 1)
echo $PODNAME

# Inside the Pod, read the enviroment variables from our container
# The alpha information is there but not the beta information. Since beta wasn't defined when the Pod started.
kubectl exec -it $PODNAME -- /bin/sh 
printenv | sort
exit

# If we delete the pod and it gets recreated, we will get the variables for the alpha and beta service information.
kubectl delete pod $PODNAME

# Get the new pod name and check the environment variables.
PODNAME=$(kubectl get pods | grep hello-world-alpha | awk '{print $1}' | head -n 1)
kubectl exec -it $PODNAME -- /bin/sh -c "printenv | sort"

# If we delete our serivce and deployment the enviroment variables stick around.
kubectl delete deployment hello-world-beta
kubectl delete service hello-world-beta
kubectl exec -it $PODNAME -- /bin/sh -c "printenv | sort"

# If we delete the pod to force it recreate it again we will only see the alpha enviroment variables in the pod.
kubectl delete pod $PODNAME
PODNAME=$(kubectl get pods | grep hello-world-alpha | awk '{print $1}' | head -n 1)
kubectl exec -it $PODNAME -- /bin/sh -c "printenv | sort"

#Let's clean up after our demo
kubectl delete -f deployment-alpha.yaml

#################
### Video 022 ###
#################

# Creating and accessing Secrets.
# Generic, creates a secret from a local file, directory or literal value. They keys and values are case sensitive
kubectl create secret generic app1 \
    --from-literal=USERNAME=app1login \
    --from-literal=PASSWORD='Pa55w0rd!'

# Type Opaque means it's an arbitrary user defined key/value pair. Data 2 means two key/value pairs in the secret.
# Other types include service accounts and container registry authentication info.
kubectl get secrets

# app1 has 2 Data elements.
kubectl describe secret app1

# Read the value of a secret.
# These are wrapped in bash expansion to add a newline to output for readability
echo $(kubectl get secret app1 --template={{.data.USERNAME}} )
echo $(kubectl get secret app1 --template={{.data.USERNAME}} | base64 --decode )

echo $(kubectl get secret app1 --template={{.data.PASSWORD}} )
echo $(kubectl get secret app1 --template={{.data.PASSWORD}} | base64 --decode )

# Accessing Secrets inside a Pod as environment variables.
kubectl apply -f deployment-secrets-env.yaml
PODNAME=$(kubectl get pods | grep hello-world-secrets-env | awk '{print $1}' | head -n 1)
echo $PODNAME

# Get our enviroment variables from our container.
kubectl exec -it $PODNAME -- /bin/sh
printenv | grep ^app1
exit

# Accessing Secrets as files
kubectl apply -f deployment-secrets-files.yaml
PODNAME=$(kubectl get pods | grep hello-world-secrets-files | awk '{print $1}' | head -n 1)
echo $PODNAME

# Look closely at the Pod we see volumes, appconfig and in Mounts.
kubectl describe pod $PODNAME

#Let's access a shell on the Pod
kubectl exec -it $PODNAME -- /bin/sh

# We see the path we defined in the Volumes part of the Pod Spec. A directory for each KEY and it's contents are the value.
ls /etc/appconfig
cat /etc/appconfig/USERNAME
cat /etc/appconfig/PASSWORD
exit

# Clean up after our demos.
kubectl delete secret app1
kubectl delete deployment hello-world-secrets-env
kubectl delete deployment hello-world-secrets-files

#Create a secret using clear text and the stringData field
kubectl apply -f secret.string.yaml
kubectl get secrets
kubectl describe secret app2

echo $(kubectl get secret app2 --template={{.data.USERNAME}} )
echo $(kubectl get secret app2 --template={{.data.USERNAME}} | base64 --decode )
echo $(kubectl get secret app2 --template={{.data.PASSWORD}} )
echo $(kubectl get secret app2 --template={{.data.PASSWORD}} | base64 --decode )

# Create a secret with encoded values, preferred over clear text.
echo -n 'app3login' | base64
echo -n 'P@ssWorD!' | base64
kubectl apply -f secret.encoded.yaml
kubectl get secrets

# Examine how each object is stored, look at the annotations for the app2 secret.
kubectl get secrets app2 -o yaml
kubectl get secrets app3 -o yaml

# Create the app1 secret again.
kubectl create secret generic app1 --from-literal=USERNAME=app1login --from-literal=PASSWORD='Pa55w0rd!'

# envFrom will create enviroment variables for each key in the named secret app1 with and set it's value set to the secrets value.
kubectl apply -f deployment-secrets-env-from.yaml

PODNAME=$(kubectl get pods | grep hello-world-secrets-env-from | awk '{print $1}' | head -n 1)
echo $PODNAME 
kubectl exec -it $PODNAME -- /bin/sh
printenv | sort
exit

kubectl delete secret app1
kubectl delete secret app2
kubectl delete secret app3
kubectl delete deployment hello-world-secrets-env-from

#################
### Video 023 ###
#################

# Pulling a Container from a Private Container Registry in AWS ECR.
# Pull down a hello-world image. This can be done one of the worker nodes.
docker image list
docker image pull psk8s.azurecr.io/hello-app:1.0

# Tagging our image and pushing it to ECR.
# source_ref: psk8s.azurecr.io/hello-app:1.0    #this is the image pulled from our repo
# target_ref: 047838238778.dkr.ecr.eu-west-1.amazonaws.com/kube:latest      #this is the image you want to push into your private repository
docker image tag psk8s.azurecr.io/hello-app:1.0 047838238778.dkr.ecr.eu-west-1.amazonaws.com/kube:latest
docker push 047838238778.dkr.ecr.eu-west-1.amazonaws.com/kube:latest

# Create our secret that we'll use for our image pull.
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 047838238778.dkr.ecr.eu-west-1.amazonaws.com
aws ecr get-login-password --region eu-west-1

kubectl create secret docker-registry private-ecr-cred \
    --docker-server=047838238778.dkr.ecr.eu-west-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password=$(aws ecr get-login-password --region eu-west-1) \
    --docker-email=unused@example.com

kubectl get secret private-ecr-cred -o yaml
kubectl get secret private-ecr-cred -o jsonpath='{.data.\.dockerconfigjson}' | base64 --decode

# Ensure the image doesn't exist on any of our nodes.
ctr images list
sudo ctr --namespace k8s.io image ls "name~=hello-app" -q | sudo xargs ctr --namespace k8s.io image rm
sudo ctr --namespace k8s.io image ls "name~=hello-app" -q | sudo xargs ctr --namespace k8s.io image rm
sudo ctr --namespace k8s.io image ls "name~=hello-app" -q | sudo xargs ctr --namespace k8s.io image rm

# Create a deployment using imagePullSecret in the Pod Spec.
kubectl apply -f deployment-private-registry.yaml
kubectl describe deployment hello-world-private-registry

# Check out Containers and events section to ensure the container was actually pulled.
kubectl describe pod hello-world-private-registry-57b79648ff-q9znn

# Clean up and remove the images from the worker node.
kubectl delete -f deployment-private-registry.yaml
kubectl delete secret private-reg-cred
docker image rmi psk8s.azurecr.io/hello-app:1.0

#################
### Video 024 ###
#################

# Creating ConfigMaps
# Create a PROD ConfigMap
kubectl create configmap appconfigprod \
    --from-literal=DATABASE_SERVERNAME=sql.example.local \
    --from-literal=BACKEND_SERVERNAME=be.example.local


# Create a QA ConfigMap
# We can source our ConfigMap from files or from directories
cat appconfigqa
kubectl create configmap appconfigqa \
    --from-file=appconfigqa

# Each creation method yeilded a different structure in the ConfigMap
kubectl get configmap appconfigprod -o yaml
kubectl get configmap appconfigqa -o yaml

# Using ConfigMaps in Pod Configurations as environment variables
kubectl apply -f deployment-configmaps-env-prod.yaml

# Let's see or configured enviroment variables
PODNAME=$(kubectl get pods | grep hello-world-configmaps-env-prod | awk '{print $1}' | head -n 1)
echo $PODNAME

kubectl exec -it $PODNAME -- /bin/sh 
printenv | sort
exit

# Using ConfigMaps in Pod Configurations as files
kubectl apply -f deployment-configmaps-files-qa.yaml

#Let's see our configmap exposed as a file using the key as the file name.
PODNAME=$(kubectl get pods | grep hello-world-configmaps-files-qa | awk '{print $1}' | head -n 1)
echo $PODNAME

kubectl exec -it $PODNAME -- /bin/sh 
ls /etc/appconfig
cat /etc/appconfig/appconfigqa
exit

# Our ConfigMap key, was the filename we read in, and the values are inside the file.
# This is how we can read in whole files at a time and present them to the file system with the same name in one ConfigMap
kubectl get configmap appconfigqa -o yaml

# Updating a configmap, change BACKEND_SERVERNAME to beqa1.example.local
kubectl edit configmap appconfigqa

kubectl exec -it $PODNAME -- /bin/sh 
watch cat /etc/appconfig/appconfigqa
exit

# Cleaning up our demo.
kubectl delete deployment hello-world-configmaps-env-prod
kubectl delete deployment hello-world-configmaps-files-qa
kubectl delete configmap appconfigprod
kubectl delete configmap appconfigqa

# Reading from a directory, each file's basename will be a key in the ConfigMap...but you can define a key if needed
kubectl create configmap httpdconfigprod1 --from-file=./configs/

kubectl apply -f deployment-configmaps-directory-qa.yaml
PODNAME=$(kubectl get pods | grep hello-world-configmaps-directory-qa | awk '{print $1}' | head -n 1)
echo $PODNAME

kubectl exec -it $PODNAME -- /bin/sh 
ls /etc/httpd
cat /etc/httpd/httpd.conf
cat /etc/httpd/ssl.conf
exit

# Defining a custom key for a file. All configuration will be under that key in the filesystem.
kubectl create configmap appconfigprod1 --from-file=app1=appconfigprod
kubectl get configmap appconfigprod1 -o yaml
kubectl describe configmap appconfigprod1
kubectl apply -f deployment-configmaps-files-key-qa.yaml
PODNAME=$(kubectl get pods | grep hello-world-configmaps-files-key-qa | awk '{print $1}' | head -n 1)
echo $PODNAME

kubectl exec -it $PODNAME -- /bin/sh 
ls /etc/appconfig
ls /etc/appconfig/app1
cat /etc/appconfig/app1
exit

# Clean up after our demos
kubectl delete deployments hello-world-configmaps-files-key-qa
kubectl delete deployments hello-world-configmaps-directory-qa
kubectl delete configmap httpdconfigprod1
kubectl delete configmap appconfigprod1

#################
### Video 025 ###
#################

# Finding scheduling information
# Let's create a deployment with three replicas
kubectl apply -f deployment.yaml

# Pods spread out evenly across the Nodes due to our scoring functions for selector spread during Scoring.
kubectl get pods -o wide

# We can look at the Pods events to see the scheduler making its choice
kubectl describe pods

# Let's we scale our deployment to 4
kubectl scale deployment hello-world --replicas=4

# We can see that the scheduler works to keep load even across the nodes.
kubectl get pods -o wide

# We can see the nodeName populated for this node
kubectl get pods hello-world-676c65d7f6-lxq5h -o yaml

# Clean up this demo.
kubectl delete deployment hello-world

# Scheduling Pods with resource requests. Start a watch, the pods will go from Pending->ContainerCreating->Running
# Each pod has a 1 core CPU request.
kubectl get pods --watch &
kubectl apply -f requests.yaml

# We created three pods, one on each node
kubectl get pods -o wide

#Let's scale our deployment to 4 replica.  These pods will stay pending. Some pod names may be repeated.
kubectl scale deployment hello-world-requests --replicas=4

# We see that three Pods are pending...why?
kubectl get pods -o wide
kubectl get pods -o wide | grep Pending

# Let's look at why the Pod is Pending. Check out the Pod's events.
kubectl describe pods

# Now let's look at the node's Allocations...we've allocated 62% of our CPU...
# 1 user pod using 1 whole CPU or %50 of the capacity, 3 system pods using another %8.
# looking at allocatable resources, we have only 2 whole Cores available for use.
# The next pod coming along wants 1 whole core, and tha'ts not available.
# The scheduler can't find a place in this cluster to place our workload...is this good or bad?
kubectl get node
kubectl describe node ip-192-168-25-30.eu-west-1.compute.internal

# Clean up after this demo.
kubectl delete deployment hello-world-requests


#################
### Video 026 ###
#################

# Using Labels to Schedule Pods to Nodes.
# Using Affinity and Anti-Affinity to schedule Pods to Nodes.
# Affinity: we want to have always have a cache pod co-located on a Node where we a Web Pod.
kubectl apply -f deployment-affinity.yaml

# Check out the labels on the nodes, look for kubernetes.io/hostname which we're using for our topologykey.
kubectl describe nodes ip-192-168-25-30.eu-west-1.compute.internal
kubectl get nodes --show-labels

# We can see that web and cache are both on the name node
kubectl get pods -o wide

# If we scale the web deployment we'll still get spread across nodes in the ReplicaSet, so we don't need to enforce that with affinity
kubectl scale deployment hello-world-web --replicas=2
kubectl get pods -o wide

# Then when we scale the cache deployment, it will get scheduled to the same node as the other web server
kubectl scale deployment hello-world-cache --replicas=2
kubectl get pods -o wide

#Clean up the resources from these deployments
kubectl delete -f deployment-affinity.yaml

# Using anti-affinity.
# Test out anti-affinity, deploy web and cache again.
kubectl apply -f deployment-antiaffinity.yaml
kubectl get pods -o wide

# Scale the replicas in the web and cache deployments
kubectl scale deployment hello-world-web --replicas=4

# Two Pod will go Pending because we can have only 1 Web Pod per node when using requiredDuringSchedulingIgnoredDuringExecution in our antiaffinity rule
kubectl get pods -o wide --selector app=hello-world-web

# To 'fix' this we can change the scheduling rule to preferredDuringSchedulingIgnoredDuringExecution
# Also going to set the number of replicas to 4
kubectl apply -f deployment-antiaffinity-corrected.yaml
kubectl scale deployment hello-world-web --replicas=4

# Now we'll have 4 pods up an running.
kubectl get pods -o wide --selector app=hello-world-web

# Clean up the resources from this demos
kubectl delete -f deployment-antiaffinity-corrected.yaml

#################
### Video 027 ###
#################

# Controlling Pods placement with Taints and Tolerations.
# Add a Taint to one of the nodes.
kubectl get node
kubectl taint nodes ip-192-168-25-30.eu-west-1.compute.internal key=MyTaint:NoSchedule

# We can see the taint at the node level.
kubectl describe node ip-192-168-25-30.eu-west-1.compute.internal

# Create a deployment with three replicas
kubectl apply -f deployment.yaml

# Pods get placed on the non tainted nodes.
kubectl get pods -o wide

# We add a deployment with a Toleration.
kubectl apply -f deployment-tolerations.yaml

# We can see Pods get placed on the tainted nodes.
kubectl get pods -o wide

# Remove our Taint
kubectl taint nodes ip-192-168-25-30.eu-west-1.compute.internal key:NoSchedule-

# Clean up after our demo
kubectl delete -f deployment-tolerations.yaml
kubectl delete -f deployment.yaml

#################
### Video 028 ###
#################

# Node Cordoning.
# Create a deployment with three replicas.
kubectl apply -f deployment.yaml

# Pods spread out evenly across the node.s
kubectl get pods -o wide

# Cordon ip-192-168-25-30.eu-west-1.compute.internal
kubectl cordon ip-192-168-25-30.eu-west-1.compute.internal

# That won't evict any pods.
kubectl get pods -o wide

# If I scale the deployment the node we cordoned won't get any new pods. One of the other Nodes will get an extra Pod here.
kubectl scale deployment hello-world --replicas=6
kubectl get pods -o wide

# Drain (remove) the Pods from the cordoned node.
kubectl drain ip-192-168-25-30.eu-west-1.compute.internal

# Try that again since daemonsets aren't scheduled we need to work around them.
kubectl drain ip-192-168-25-30.eu-west-1.compute.internal --ignore-daemonsets

# Now all the workload is on the other node.
kubectl get pods -o wide

# We can uncordon our node, but nothing will get scheduled there until there's an event like a scaling operation or an eviction. Something that will cause pods to get created
kubectl uncordon ip-192-168-25-30.eu-west-1.compute.internal

# Scale that Deployment and see where they get scheduled.
kubectl scale deployment hello-world --replicas=9

# All three get scheduled to the node that was cordoned.
kubectl get pods -o wide

# Clean up this demo.
kubectl delete deployment hello-world

# Manually scheduling a Pod by specifying nodeName
kubectl apply -f pod.yaml

# Our Pod should be on ip-192-168-25-30.eu-west-1.compute.internal
kubectl get pod -o wide

# Let's delete our pod, since there's no controller it won't get recreated.
kubectl delete pod hello-world-pod

# Now let's cordon ip-192-168-25-30.eu-west-1.compute.internal again
kubectl cordon ip-192-168-25-30.eu-west-1.compute.internal

# Try to recreate our pod
kubectl apply -f pod.yaml

# We can still place a pod on the node since the Pod isn't getting 'scheduled', status is SchedulingDisabled
kubectl get pod -o wide

# Can't remove the unmanaged Pod either since it's not managed by a Controller and won't get restarted
kubectl drain ip-192-168-25-30.eu-west-1.compute.internal --ignore-daemonsets 

# Clean up our demo, delete our pod and uncordon the node
kubectl delete pod hello-world-pod 
 
# Uncordon ip-192-168-25-30.eu-west-1.compute.internal so it's able to have pods scheduled to it.
kubectl uncordon ip-192-168-25-30.eu-west-1.compute.internal

#################
### Video 029 ###
#################

# Amazon EKS uses the Amazon VPC CNI plugin for pod networking.
# By default, pods are assigned IP addresses from the same VPC subnets as the nodes in your cluster.
# However, you can customize this behavior.

# Investigating Kubernetes Networking
# Get all Nodes and their IP information, INTERNAL-IP is the real IP of the Node
kubectl get nodes -o wide

# Deploy a basic workload, hello-world with 3 replicas to create some pods on the pod network.
kubectl apply -f Deployment.yaml

# Get all Pods, we can see each Pod has a unique IP on the Pod Network.
kubectl get pods -o wide

# Hop inside a pod and check out it's networking.
PODNAME=$(kubectl get pods --selector=app=hello-world -o jsonpath='{ .items[0].metadata.name }')
echo $PODNAME
kubectl exec -it $PODNAME -- /bin/sh
ip addr
exit

# For the Pod on ip-192-168-62-216.eu-west-1.compute.internal, let's find out how traffic is is routed.

# Look at the annotations, specifically the annotation alpha.kubernetes.io/provided-node-ip: 192.168.x.y.
# Check out the Addresses: InternalIP, that's the real IP of the Node.
kubectl describe node ip-192-168-62-216.eu-west-1.compute.internal

# Let's see how the traffic travels between two pods on two separate nodes.
# In Amazon EKS, traffic between pods on different nodes is facilitated by the Amazon VPC CNI plugin, which integrates Kubernetes networking with Amazon VPC networking.
# Each pod gets an IP address from the VPC CIDR range, and these IPs are routable within the VPC.
# Pods communicate with each other using these IPs, regardless of whether they are on the same node or different nodes.
# Amazon VPC CNI Plugin allocates secondary IPs from the VPC to pods.
# Each node has one or more ENIs attached to it. These ENIs are used to assign IPs to pods.
# VPC Route Table ensures that traffic between different subnets within the VPC is routed correctly.
# Kubernetes DNS resolves the target pod's IP if Pod A uses a service or pod name.
# 169.254.1.1 serves as the default gateway for all pods managed by the Amazon VPC CNI plugin.
# Each ENI is an attachment to the EC2 instance and is used to allocate IP addresses to pods.
# Each ENI can have multiple secondary IPs (depending on the instance type).
# These secondary IPs are assigned to pods running on the node.
# The plugin ensures that every pod gets a unique IP address from the VPC subnet.
kubectl exec -it $PODNAME -- /bin/sh
route
ip addr

# Log into one of the nodes and look at the interfaces.
ssh ip-192-168-62-216.eu-west-1.compute.internal
route
ip addr

# Delete the deployment.
kubectl delete -f Deployment.yaml 

#################
### Video 030 ###
#################

# Investigating the Cluster DNS Service.
# It's Deployed as a Service in the cluster with a Deployment in the kube-system namespace.
kubectl get service --namespace kube-system

# Two Replicas, Args injecting the location of the config file which is backed by ConfigMap mounted as a Volume.
# The DNS config is located in: /etc/coredns/Corefile
# Host Ports:  0/UDP, 0/TCP, 0/TCP - Kubernetes will dynamically allocate a port on the node to handle traffic to the container, meaning no fixed port binding exists on the host.
# This is common for deployments on AWS Fargate, where nodes are abstracted, and there’s no direct mapping of host ports.
# The Topology Spread Constraints feature in Kubernetes ensures even distribution of pods across failure domains (e.g., zones, nodes) to improve availability and fault tolerance.
# The Priority Class Name in Kubernetes defines the priority of a pod for scheduling and eviction. The value system-cluster-critical indicates that the CoreDNS deployment has a critical priority in the cluster.
# The CriticalAddonsOnly op=Exists in the Tolerations section of the deployment specifies a toleration that allows the CoreDNS pods to run on nodes marked for critical system add-ons.
kubectl describe deployment coredns --namespace kube-system
SERVICEIP=$(kubectl get service --namespace kube-system kube-dns -o jsonpath='{ .spec.clusterIP }')
kubectl run -i --tty --rm debug --image=busybox --namespace kube-system -- /bin/sh
nslookup www.google.com $SERVICEIP
nslookup www.yahoo.com $SERVICEIP

# The configmap defining the CoreDNS configuration and we can see the default forwarder is /etc/resolv.conf
# .:53 means CoreDNS will listen on all IP addresses (.) on port 53 (default DNS port).
# prometheus :9153: Exposes metrics for Prometheus on port 9153.
# forward . /etc/resolv.conf { max_concurrent 1000 } - Forwards unresolved queries to the servers in /etc/resolv.conf.
# reload - Enables automatic reloading of the Corefile if it is updated.
kubectl get configmaps --namespace kube-system coredns -o yaml

# Configuring CoreDNS to use custom Forwarders, spaces not tabs!
# Defaults use the nodes DNS Servers for fowarders
# Replaces forward . /etc/resolv.conf with forward . 1.1.1.1
# Add a conditional domain forwarder for a specific domain
# ConfigMap will take a second to update the mapped file and the config to be reloaded
kubectl apply -f CoreDNSConfigCustom.yaml --namespace kube-system

# To find out when the CoreDNS configuration file is updated in the pod we can tail the log looking for the reload the configuration file.
# Also look for any errors post configuration. Seeing [WARNING] No files matching import glob pattern: custom/*.override is normal.
kubectl logs --namespace kube-system --selector 'k8s-app=kube-dns' --follow

# Run some DNS queries from one of the workder nodes against the kube-dns service cluster ip to ensure everything works.
SERVICEIP=$(kubectl get service --namespace kube-system kube-dns -o jsonpath='{ .spec.clusterIP }')
kubectl run -i --tty --rm debug --image=busybox --namespace kube-system -- /bin/sh
nslookup www.google.com $SERVICEIP
nslookup www.yahoo.com $SERVICEIP

# Let's put the default configuration back, using . forward /etc/resolv.conf 
kubectl apply -f CoreDNSConfigDefault.yaml --namespace kube-system

# Configuring Pod DNS client Configuration
kubectl apply -f DeploymentCustomDns.yaml

# Check the DNS configuration of a Pod created with that configuration.
PODNAME=$(kubectl get pods --selector=app=hello-world-customdns -o jsonpath='{ .items[0].metadata.name }')
echo $PODNAME
kubectl exec -it $PODNAME -- cat /etc/resolv.conf
kubectl exec -it $PODNAME -- cnslookup www.google.com
kubectl exec -it $PODNAME -- cnslookup www.yahoo.com

#Clean up our resources
kubectl delete -f DeploymentCustomDns.yaml

# Get a pods DNS A record and a Services A record
# Create a deployment and a service
kubectl apply -f Deployment.yaml

# Get the pods and their IP addresses
kubectl get pods -o wide

# Get the address of our DNS Service again...just in case
SERVICEIP=$(kubectl get service --namespace kube-system kube-dns -o jsonpath='{ .spec.clusterIP }')
echo $SERVICEIP

# For one of the pods replace the dots in the IP address with dashes for example 192.168.206.68 becomes 192-168-206-68
# We'll look at some additional examples of Service Discovery in the next module too.
kubectl run -i --tty --rm debug --image=busybox --namespace kube-system -- /bin/sh
nslookup 192-168-59-10.default.pod.cluster.local 10.100.0.10

# Our Services also get DNS A records
kubectl get service
nslookup hello-world.default.svc.cluster.local 10.100.0.10

# Clean up our resources
kubectl delete -f Deployment.yaml

# Verify your DNS forwarder configuration. 
# Recreate the custom configuration by applying the custom configmap defined in CoreDNSConfigCustom.yaml
# Logging in CoreDNS will log the query, but not which forwarder it was sent to.
# We can use tcpdump to listen to the packets on the wire to see where the DNS queries are being sent to.
kubectl apply -f CoreDNSConfigCustom.yaml --namespace kube-system

# Find the name of a Node running one of the DNS Pods running. So we're going to observe DNS queries there.
DNSPODNODENAME=$(kubectl get pods --namespace kube-system --selector=k8s-app=kube-dns -o jsonpath='{ .items[0].spec.nodeName }')
echo $DNSPODNODENAME

# Let's log into that node running the dns pod and start a tcpdump to watch our dns queries in action.
# Your interface (-i) name may be different
sudo tcpdump -i ens33 port 53 -n 

# In a second terminal, let's test our DNS configuration from a pod to make sure we're using the configured forwarder.
# When this pod starts, it will point to our cluster dns service.
# Install dnsutils for nslookup and dig
kubectl run -it --rm debian --image=debian
apt-get update && apt-get install dnsutils -y

# In our debian pod let's look at the dns config and run two test DNS queries
# The nameserver will be your cluster dns service cluster ip.
# We'll query two domains to generate traffic for our tcpdump
cat /etc/resolv.conf
nslookup www.google.com
nslookup www.yahoo.com

# Switch back to our second terminal and review the tcpdump, confirming each query is going to the correct forwarder
# Here is some example output...www.google.com is going to 1.1.1.1 and www.centinosystems.com is going to 9.9.9.9
# 23:03:25.387166 IP 192.168.62.216.15047 > 9.9.9.9.domain: 59620+ A? www.google.com. (32)
# 23:03:25.388776 IP 9.9.9.9.domain > 192.168.62.216.15047: 59620 1/0/0 A 216.58.204.68 (48)
# 23:03:33.110370 IP 192.168.62.216.31321 > 1.1.1.1.domain: 30402+ A? www.yahoo.com.eu-west-1.compute.internal. (58)
# 23:03:33.133091 IP 1.1.1.1.domain > 192.168.62.216.31321: 30402 NXDomain 0/1/0 (133)

# Exit the tcpdump
ctrl+c

#################
### Video 031 ###
#################

# Exposing and accessing applications with Services.
# Creating a ClusterIP Service.
# Imperative, create a deployment with one replica.
kubectl create deployment hello-world-clusterip \
    --image=psk8s.azurecr.io/hello-app:1.0

# When creating a service, you can define a type, if you don't define a type, the default is ClusterIP
kubectl expose deployment hello-world-clusterip \
    --port=80 --target-port=8080 --type ClusterIP

# Get a list of services, examine the Type, CLUSTER-IP and Port
# Kubernetes is a default service in every Kubernetes cluster. This service is automatically created by Kubernetes and represents the Kubernetes API server.
kubectl get service

# Get the Service's ClusterIP and store that for reuse.
SERVICEIP=$(kubectl get service hello-world-clusterip -o jsonpath='{ .spec.clusterIP }')
echo $SERVICEIP

# Access the service inside the cluster from one from the noes.
curl http://$SERVICEIP

# Get a listing of the endpoints for a service, we see the one pod endpoint registered.
kubectl get endpoints hello-world-clusterip
kubectl get pods -o wide

# Access the pod's application directly on the Target Port on the Pod, not the service's Port, useful for troubleshooting.
kubectl get endpoints hello-world-clusterip
PODIP=$(kubectl get endpoints hello-world-clusterip -o jsonpath='{ .subsets[].addresses[].ip }')
echo $PODIP
curl http://$PODIP:8080

# Scale the deployment, new endpoints are registered automatically
kubectl scale deployment hello-world-clusterip --replicas=6
kubectl get endpoints hello-world-clusterip

# Access the service inside the cluster, this time our requests will be load balanced.
curl http://$SERVICEIP

# The Service's Endpoints match the labels, let's look at the service and it's selector and the pods labels.
kubectl describe service hello-world-clusterip
kubectl get pods --show-labels

# Clean up these resources for the next demo
kubectl delete deployments hello-world-clusterip
kubectl delete service hello-world-clusterip

# Creating a NodePort Service.
# Imperative, create a deployment with one replica
kubectl create deployment hello-world-nodeport \
    --image=psk8s.azurecr.io/hello-app:1.0

# When creating a service, you can define a type, if you don't define a type, the default is ClusterIP.
kubectl expose deployment hello-world-nodeport \
    --port=80 --target-port=8080 --type NodePort

# Check out the services details.
# There's the Node Port after the : in the Ports column. It's also got a ClusterIP and Port.
# This NodePort service is available on that NodePort on each node in the cluster.
kubectl get service

CLUSTERIP=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.clusterIP }')
PORT=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.ports[].port }')
NODEPORT=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.ports[].nodePort }')
echo $CLUSTERIP $PORT $NODEPORT

# Access the services on the Node Port.
# We can do that on each node in the cluster and from outside the cluster, regardless of where the pod actually is

#We have only one pod online supporting our service
kubectl get pods -o wide

# We can access the service by hitting the node port on any node in the cluster on the node's IP or Name.
# This will forward to the cluster IP and get load balanced to a Pod. Even if there is only one Pod.
kubectl get node
curl http://192.168.25.30:31273
curl http://192.168.25.216:31273

#And a Node port service is also listening on a Cluster IP, in fact the Node Port traffic is routed to the ClusterIP
echo $CLUSTERIP:$PORT
curl http://10.100.74.16:80

#Let's delete that service
kubectl delete service hello-world-nodeport
kubectl delete deployment hello-world-nodeport


# Create LoadBalancer Services.
# Let's create a deployment.
kubectl create deployment hello-world-loadbalancer \
    --image=psk8s.azurecr.io/hello-app:1.0

# When creating a service, you can define a type, if you don't define a type, the default is ClusterIP.
kubectl expose deployment hello-world-loadbalancer \
    --port=80 --target-port=8080 --type LoadBalancer

# Get the service details and test accessing it.
kubectl get service
LOADBALANCERIP=$(kubectl get service hello-world-loadbalancer -o jsonpath='{ .status.loadBalancer.ingress[].hostname }')
PORT=$(kubectl get service hello-world-loadbalancer -o jsonpath='{ .spec.ports[].port }')
echo $LOADBALANCERIP $PORT
curl http://$LOADBALANCERIP:$PORT

# The loadbalancer, which is 'outside' your cluster, sends traffic to the NodePort Service which sends it to the ClusterIP to get to your pods!
# Your cloud load balancer will have health probes checking the health of the node port service on the node IPs.
# This isn't the health of our application, that still needs to be configured via readiness/liveness probes and maintained by your Deployment configuration
kubectl get service hello-world-loadbalancer

# Clean up the resources from this demo
kubectl delete deployment hello-world-loadbalancer
kubectl delete service hello-world-loadbalancer

# Declarative examples
# Create a ClusterIP service.
kubectl apply -f service-hello-world-clusterip.yaml
kubectl get service

# Create a NodePort with a predefined port, first with a port outside of the NodePort range then a corrected one.
kubectl apply -f service-hello-world-nodeport-incorrect.yaml
kubectl apply -f service-hello-world-nodeport.yaml
kubectl get service

# Create a cloud load balancer
kubectl apply -f service-hello-world-loadbalancer.yaml
kubectl get service

# Clean up these resources
kubectl delete -f service-hello-world-loadbalancer.yaml
kubectl delete -f service-hello-world-nodeport.yaml
kubectl delete -f service-hello-world-clusterip.yaml

#################
### Video 032 ###
#################

#Service Discovery
#Cluster DNS

# Create a deployment in the default namespace
kubectl create deployment hello-world-clusterip \
    --image=psk8s.azurecr.io/hello-app:1.0

# Expose the deployment as a ClusterIP service.
kubectl expose deployment hello-world-clusterip \
    --port=80 --target-port=8080 --type ClusterIP

# We can use nslookup or dig to investigate the DNS record
# 10.100.0.10 is the ClusterIP service for the DNS service.
kubectl get service kube-dns --namespace kube-system

# Each service gets a DNS record, we can use this in our applications to find services by name.
# The A record is in the form <servicename>.<namespace>.svc.<clusterdomain>
kubectl run -it --rm debian --image=debian
apt-get update && apt-get install dnsutils -y

nslookup hello-world-clusterip.default.svc.cluster.local 10.100.0.10
kubectl get service hello-world-clusterip

# Create a namespace, deployment with one replica and a service
kubectl create namespace ns1

# Create a deployment with the same name as the first one, but in our new namespace
kubectl create deployment hello-world-clusterip --namespace ns1 \
    --image=psk8s.azurecr.io/hello-app:1.0

kubectl expose deployment hello-world-clusterip --namespace ns1 \
    --port=80 --target-port=8080 --type ClusterIP

# Check the DNS record for the service in the namespace, ns1. See how ns1 is in the DNS record?
# <servicename>.<namespace>.svc.<clusterdomain>
nslookup hello-world-clusterip.ns1.svc.cluster.local 10.100.0.10

# Our service in the default namespace is still there, these are completely unique services.
nslookup hello-world-clusterip.default.svc.cluster.local 10.100.0.10

# Get the environment variables for the pod in our default namespace
# The service does not exist in the environment variables because the service was created after the pod was already up and running.
PODNAME=$(kubectl get pods -o jsonpath='{ .items[].metadata.name }')
echo $PODNAME
kubectl exec -it $PODNAME -- env | sort

# Environment variables are only created at pod start up, so let's delete the pod
kubectl delete pod $PODNAME

# Check the enviroment variables again.
PODNAME=$(kubectl get pods -o jsonpath='{ .items[].metadata.name }')
echo $PODNAME
kubectl exec -it $PODNAME -- env | sort

# ExternalName
# This create a CNAME record type in DNS.
kubectl apply -f service-externalname.yaml

# The record is in the form <servicename>.<namespace>.<clusterdomain>. You may get an error that says ** server can't find hello-world.api.example.com: NXDOMAIN this is ok.
kubectl run -it --rm debian --image=debian
apt-get update && apt-get install dnsutils -y
nslookup hello-world-api.default.svc.cluster.local 10.100.0.10

#Let's clean up our resources in this demo
kubectl delete service hello-world-api
kubectl delete service hello-world-clusterip
kubectl delete service hello-world-clusterip --namespace ns1
kubectl delete deployment hello-world-clusterip
kubectl delete deployment hello-world-clusterip --namespace ns1
kubectl delete namespace ns1

#################
### Video 033 ###
#################

# Deploying an ingress controller
# For our Ingress Controller, we're going to go with nginx, widely available and easy to use. 
https://kubernetes.github.io/ingress-nginx/deploy/
https://kubernetes.github.io/ingress-nginx/deploy/#aws

# In AWS this Ingress Controller will be exposed as a LoadBalancer service on a real public IP.
kubectl apply -f deploy.yaml

# Using this manifest, the Ingress Controller is in the ingress-nginx namespace but 
# It will monitor for Ingresses in all namespaces by default. It can be scoped to monitor a specific namespace if needed.
# Check the status of the pods to see if the ingress controller is online.
kubectl get pods --namespace ingress-nginx

# Now let's check to see if the service is online. This of type LoadBalancer, so do you have an EXTERNAL-IP?
kubectl get services --namespace ingress-nginx

# Check out the ingressclass nginx.
# We have not set the is-default-class so in each of our Ingresses we will need specify an ingressclassname.
kubectl describe ingressclasses nginx
kubectl annotate ingressclasses nginx "ingressclass.kubernetes.io/is-default-class=true"


# Single Service
# Create a deployment, scale it to 2 replicas and expose it as a serivce. 
# This service will be ClusterIP and we'll expose this service via the Ingress.
kubectl create deployment hello-world-service-single --image=psk8s.azurecr.io/hello-app:1.0
kubectl scale deployment hello-world-service-single --replicas=2
kubectl expose deployment hello-world-service-single --port=80 --target-port=8080 --type=ClusterIP

# Create a single Ingress routing to the one backend service on the service port 80 listening on all hostnames
kubectl apply -f ingress-single.yaml

# Get the status of the ingress. It's routing for all host names on that public IP on port 80
# This IP will be the same as the EXTERNAL-IP of the ingress controller. It will take a second to update
# If you don't define an ingressclassname and don't have a default ingress class the address won't be updated.
kubectl get ingress --watch
kubectl get services --namespace ingress-nginx

# Notice the backends are the Service's Endpoints. The traffic is going straight from the Ingress Controller to the Pod cutting out the kube-proxy hop.
# Also notice, the default backend is the same service, that's because we didn't define any rules and we just populated ingress.spec.backend.
kubectl describe ingress ingress-single

# Access the application via the exposed ingress on the public IP
INGRESSIP=$(kubectl get ingress -o jsonpath='{ .items[].status.loadBalancer.ingress[].hostname }')
curl http://$INGRESSIP

# Multiple Services with path based routing
# Create two additional services
kubectl create deployment hello-world-service-blue --image=psk8s.azurecr.io/hello-app:1.0
kubectl create deployment hello-world-service-red  --image=psk8s.azurecr.io/hello-app:1.0

kubectl expose deployment hello-world-service-blue --port=4343 --target-port=8080 --type=ClusterIP
kubectl expose deployment hello-world-service-red  --port=4242 --target-port=8080 --type=ClusterIP

# Create an ingress with paths each routing to different backend services.
kubectl apply -f ingress-path.yaml

# We now have two, one for all hosts and the other for our defined host with two paths.
# The Ingress controller is implementing these ingresses and we're sharing the one public IP.
kubectl get ingress --watch

# We can see the host, the path, and the backends.
kubectl describe ingress ingress-path

# Our ingress on all hosts is still routing to service single, since we're accessing the URL with an IP and not a domain name or host header.
curl http://$INGRESSIP/

# Our paths are routing to their correct services, if we specify a host header or use a DNS name to access the ingress. That's how the rule will route the request.
curl http://$INGRESSIP/red  --header 'Host: path.example.com'
curl http://$INGRESSIP/blue --header 'Host: path.example.com'

# If we don't specify a path we'll get a 404 while specifying a host header. 
# We'll need to configure a path and backend for / or define a default backend for the service
curl http://$INGRESSIP/     --header 'Host: path.example.com'

# Add a backend to the ingress listenting on path.example.com pointing to the single service
kubectl apply -f ingress-path-backend.yaml

# We can see the default backend, and in the Rules, the host, the path, and the backends.
kubectl describe ingress ingress-path

# Now we'll hit the default backend service, single
curl http://$INGRESSIP/ --header 'Host: path.example.com'

# Name based virtual hosts
# Route traffic to the services using named based virtual hosts rather than paths.
kubectl apply -f ingress-namebased.yaml
kubectl get ingress --watch

curl http://$INGRESSIP/ --header 'Host: red.example.com'
curl http://$INGRESSIP/ --header 'Host: blue.example.com'

# TLS Example
# Generate a certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout tls.key -out tls.crt -subj "//C=US/ST=ILLINOIS/L=CHICAGO/O=IT/OU=IT/CN=tls.example.com"

# Create a secret with the key and the certificate
kubectl create secret tls tls-secret --key tls.key --cert tls.crt

# Create an ingress using the certificate and key. This uses HTTPS for both / and /red 
kubectl apply -f ingress-tls.yaml
kubectl get ingress --watch

# Test access to the hostname. We need --resolve because we haven't registered the DNS name.
# TLS is a layer lower than host headers, so we have to specify the correct DNS name.
INGRESSIP=$(nslookup a4e34e646b930429bbd7d265c484429b-5dd26d48391017cc.elb.eu-west-1.amazonaws.com.)
curl https://tls.example.com:443 --resolve tls.example.com:443:$INGRESSIP --insecure --verbose

# Clean up from our demo
kubectl delete ingresses ingress-path
kubectl delete ingresses ingress-tls
kubectl delete ingresses ingress-namebased
kubectl delete deployment hello-world-service-single
kubectl delete deployment hello-world-service-red
kubectl delete deployment hello-world-service-blue
kubectl delete service hello-world-service-single
kubectl delete service hello-world-service-red
kubectl delete service hello-world-service-blue
kubectl delete secret tls-secret
rm tls.crt
rm tls.key

# Delete the ingress, ingress controller and other configuration elements
kubectl delete -f deploy.yaml

#################
### Video 034 ### NOT READY
#################

ssh aen@c1-cp1
cd ~/content/course/02/demo

#Note: this restore process is for a locally hosted etcd running in a static pod.


#Check out some of the key etcd configuration information
#Container image and tag, command, --data dir, and mounts and volumes for both etcd-certs and etcd-data
kubectl describe pod etcd-c1-cp1 -n kube-system


#The configuration for etcd comes from the static pod manifest, check out the listen-client-urls, data-dir, volumeMounts, volumes/
sudo more /etc/kubernetes/manifests/etcd.yaml


#You can get the runtime values from ps -aux
ps -aux | grep etcd




#Let's get etcdctl on our local system here...by downloading it from github.
#TODO: Update RELEASE to match your release version!!!
#We can find out the version of etcd we're running by using etcd --version inside the etcd pod.
kubectl exec -it etcd-c1-cp1 -n kube-system -- /bin/sh -c 'ETCDCTL_API=3 /usr/local/bin/etcd --version' | head
export RELEASE="3.5.6"
wget https://github.com/etcd-io/etcd/releases/download/v${RELEASE}/etcd-v${RELEASE}-linux-amd64.tar.gz
tar -zxvf etcd-v${RELEASE}-linux-amd64.tar.gz
cd etcd-v${RELEASE}-linux-amd64
sudo cp etcdctl /usr/local/bin


#Quick check to see if we have etcdctl...
ETCDCTL_API=3 etcdctl --help | head 




#First, let's create create a secret that we're going to delete and then get back when we run the restore.
kubectl create secret generic test-secret \
    --from-literal=username='svcaccount' \
    --from-literal=password='S0mthingS0Str0ng!'


#Define a variable for the endpoint to etcd
ENDPOINT=https://127.0.0.1:2379


#Verify we're connecting to the right cluster...define your endpoints and keys
sudo ETCDCTL_API=3 etcdctl --endpoints=$ENDPOINT \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    member list


#Take the backup saving it to /var/lib/dat-backup.db...
#Be sure to copy that to remote storage when doing this for real
sudo ETCDCTL_API=3 etcdctl --endpoints=$ENDPOINT \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /var/lib/dat-backup.db


#Read the metadata from the backup/snapshot to print out the snapshot's status 
sudo ETCDCTL_API=3 etcdctl --write-out=table snapshot status /var/lib/dat-backup.db


#now let's delete an object and then run a restore to get it back
kubectl delete secret test-secret 


#Run the restore to a second folder...this will restore to the current directory
sudo ETCDCTL_API=3 etcdctl snapshot restore /var/lib/dat-backup.db


#Confirm our data is in the restore directory 
sudo ls -l


#Move the old etcd data to a safe location
sudo mv /var/lib/etcd /var/lib/etcd.OLD


#Restart the static pod for etcd...
#if you kubectl delete it will NOT restart the static pod as it's managed by the kubelet not a controller or the control plane.
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps | grep etcd
CONTAINER_ID=$(sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps  | grep etcd | awk '{ print $1 }')
echo $CONTAINER_ID


#Stop the etcd container for our etcd pod and move our restored data into place
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock stop $CONTAINER_ID
sudo mv ./default.etcd /var/lib/etcd


#Wait for etcd, the scheduler and controller manager to recreate
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps



#Is our secret back? This may take a minute or two to come back due to caching.
kubectl get secret test-secret

###NOTE - if the secret doesn't come back...you may need to reboot all of the nodes in the cluster to clear the cache.


#Another common restore method is to update the data-path to the restored data path in the static pod manifest.
#The kubelet will restart the pod due to the configuation change


#Let's delete an object again then run a restore to get it back
kubectl delete secret test-secret 


#Using the same backup from earlier
#Run the restore to a define data-dir, rather than the current working directory
sudo ETCDCTL_API=3 etcdctl snapshot restore /var/lib/dat-backup.db --data-dir=/var/lib/etcd-restore


#Update the static pod manifest to point to that /var/lib/etcd-restore...in three places
#Update 
#    - --data-dir=/var/lib/etcd-restore
#...
#   volumeMounts:
#    - mountPath: /var/lib/etcd-restore
#...
#   volumes:
#    - hostPath:
#        name: etcd-data
#        path: /var/lib/etcd-restore
sudo cp /etc/kubernetes/manifests/etcd.yaml .
sudo vi /etc/kubernetes/manifests/etcd.yaml


#This will cause the control plane pods to restart...let's check it at the container runtime level
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps


#Is our secret back?
kubectl get secret test-secret 


#remove etcdctl from the Control Plane Node node if you want. 
#Put back the original etcd.yaml
kubectl delete secret test-secret 
sudo cp etcd.yaml /etc/kubernetes/manifests/
sudo rm /var/lib/dat-backup.db 
sudo rm /usr/local/bin/etcdctl
sudo rm -rf /var/lib/etcd.OLD
sudo rm -rf /var/lib/etcd-restore
rm ~/content/course/02/demo/etcd-v${RELEASE}-linux-amd64.tar.gz


#################
### Video 035 ### NOT READY
#################

ssh aen@c1-cp1
cd ~/content/course/02/demo



#1 - Find the version you want to upgrade to. 
#You can only upgrade one minor version to the next minor version
sudo apt update
apt-cache policy kubeadm


#What version are we on? #--short has been deprecated, you can remove this parameter if needed.
kubectl version --short
kubectl get nodes


#First, upgrade kubeadm on the Control Plane Node
#Replace the version with the version you want to upgrade to.
sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.26.1-00
sudo apt-mark hold kubeadm


#All good?
kubeadm version


#Next, Drain any workload on the Control Plane Node node
kubectl drain c1-cp1 --ignore-daemonsets


#Run upgrade plan to test the upgrade process and run pre-flight checks
#Highlights additional work needed after the upgrade, such as manually updating the kubelets
#And displays version information for the control plan components
sudo kubeadm upgrade plan v1.26.1


#Run the upgrade, you can get this from the previous output.
#Runs preflight checks - API available, Node status Ready and control plane healthy
#Checks to ensure you're upgrading along the correct upgrade path
#Prepulls container images to reduce downtime of control plane components
#For each control plane component, 
#   Updates the certificates used for authentication
#   Creates a new static pod manifest in /etc/kubernetes/mainifests and saves the old one to /etc/kubernetes/tmp
#   Which causes the kubelet to restart the pods
#Updates the Control Plane Node's kubelet configuration and also updates CoreDNS and kube-proxy
sudo kubeadm upgrade apply v1.26.1  #<---this format is different than the package's version format


#Look for [upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.xx.yy". Enjoy!


#Uncordon the node
kubectl uncordon c1-cp1 


#Now update the kubelet and kubectl on the control plane node(s)
sudo apt-mark unhold kubelet kubectl 
sudo apt-get update
sudo apt-get install -y kubelet=1.26.1-00 kubectl=1.26.1-00
sudo apt-mark hold kubelet kubectl


#Check the update status
kubectl version --short
kubectl get nodes


#Upgrade any additional control plane nodes with the same process.


#Upgrade the workers, drain the node, then log into it. 
#Update the enviroment variable so you can reuse those code over and over.
kubectl drain c1-node[XX] --ignore-daemonsets
ssh aen@c1-node[XX]


#First, upgrade kubeadm 
sudo apt-mark unhold kubeadm 
sudo apt-get update
sudo apt-get install -y kubeadm=1.26.1-00
sudo apt-mark hold kubeadm


#Updates kubelet configuration for the node
sudo kubeadm upgrade node


#Update the kubelet and kubectl on the node
sudo apt-mark unhold kubelet kubectl 
sudo apt-get update
sudo apt-get install -y kubelet=1.26.1-00 kubectl=1.26.1-00
sudo apt-mark hold kubelet kubectl


#Log out of the node
exit


#Get the nodes to show the version...can take a second to update
kubectl get nodes 


#Uncordon the node to allow workload again
kubectl uncordon c1-node[XX]


#check the versions of the nodes
kubectl get nodes


####TO DO###
####BE SURE TO UPGRADE THE REMAINING WORKER NODES#####


#check the versions of the nodes
kubectl get nodes


#################
### Video 036 ### 2 and 3 - NODES IS NOT READY
#################

# Review pod logs
# Check the logs for a single container pod.
kubectl create deployment nginx --image=nginx
PODNAME=$(kubectl get pods -l app=nginx -o jsonpath='{ .items[0].metadata.name }')
echo $PODNAME
kubectl logs $PODNAME

# Clean up that deployment
kubectl delete deployment nginx

# Create a multi-container pod that writes some information to stdout
kubectl apply -f multicontainer.yaml

# Pods a specific container in a Pod and a collection of Pods
PODNAME=$(kubectl get pods -l app=loggingdemo -o jsonpath='{ .items[0].metadata.name }')
echo $PODNAME

# Get the logs from the multicontainer pod.
# It defualts to the first container.
kubectl logs $PODNAME

# We can to specify which container inside the pods
kubectl logs $PODNAME -c container1
kubectl logs $PODNAME -c container2

# We can access all container logs which will dump each containers in sequence
kubectl logs $PODNAME --all-containers

# If we need to follow a log, we can do that. It's helpful in debugging real time issues
# This works for both single and multi-container pods
kubectl logs $PODNAME --all-containers --follow
ctrl+c

# For all pods matching the selector, get all the container logs and write it to stdout and then file
kubectl get pods --selector app=loggingdemo
kubectl logs --selector app=loggingdemo --all-containers 
kubectl logs --selector app=loggingdemo --all-containers  > allpods.txt

# Also helpful is tailing the bottom of a log.
# Here we're getting the last 5 log entries across all pods matching the selector
kubectl logs --selector app=loggingdemo --all-containers --tail 5




#2 - Nodes
#Get key information and status about the kubelet, ensure that it's active/running and check out the log. 
#Also key information about it's configuration is available.
systemctl status kubelet.service


#If we want to examine it's log further, we use journalctl to access it's log from journald
# -u for which systemd unit. If using a pager, use f and b to for forward and back.
journalctl -u kubelet.service


#journalctl has search capabilities, but grep is likely easier
journalctl -u kubelet.service | grep -i ERROR


#Time bounding your searches can be helpful in finding issues add --no-pager for line wrapping
journalctl -u kubelet.service --since today --no-pager



#3 - Control plane
#Get a listing of the control plane pods using a selector
kubectl get pods --namespace kube-system --selector tier=control-plane


#We can retrieve the logs for the control plane pods by using kubectl logs
#This info is coming from the API server over kubectl, 
#it instructs the kubelet will read the log from the node and send it back to you over stdout
kubectl logs --namespace kube-system kube-apiserver-c1-cp1  


#But, what if your control plane is down? Go to crictl or to the file system.
#kubectl logs will send the request to the local node's kubelet to read the logs from disk
#Since we're on the Control Plane Node/control plane node already we can use crictl for that.
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps


#Grab the log for the api server pod, paste in the CONTAINER ID using crictl
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps | grep kube-apiserver
CONTAINER_ID=$(sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps | grep kube-apiserver | awk '{ print $1 }')
echo $CONTAINER_ID
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock logs $CONTAINER_ID


#But, what if containerd isn't not available?
#They're also available on the filesystem, here you'll find the current and the previous logs files for the containers. 
#This is the same across all nodes and pods in the cluster. This also applies to user pods/containers.
#These are json formmatted which is the docker/containerd logging driver default
sudo ls /var/log/containers
sudo tail /var/log/containers/kube-apiserver-c1-cp1*

# Review Events
# Show events for all objects in the cluster in the default namespace
# Look for the deployment creation and scaling operations from above.
kubectl get events -A

# It can be easier if the data is actually sorted.
# sort by isn't for just events, it can be used in most output
kubectl get events -A --sort-by='.metadata.creationTimestamp'
 
# Create a flawed deployment
kubectl create deployment nginx --image ngins

# We can filter the list of events using field selector
kubectl get events --field-selector type=Warning
kubectl get events --field-selector type=Warning,reason=Failed

# We can also monitor the events as they happen with watch
kubectl scale deployment loggingdemo --replicas=5
kubectl get events --watch &

# We can look in another namespace too if needed.
kubectl get events --namespace kube-system

# These events are also available in the object as part of kubectl describe, in the events section
kubectl describe deployment nginx
kubectl describe replicaset nginx-79654b8786 #Update to your replicaset name
kubectl describe pods nginx

# Clean up our resources
kubectl delete -f multicontainer.yaml
kubectl delete deployment nginx

# The event data is still availble from the cluster's events, even though the objects are gone.
kubectl get events --sort-by='.metadata.creationTimestamp'

#################
### Video 037 ###
#################

# Accessing information with jsonpath
# Create a workload and scale it
kubectl create deployment hello-world --image=psk8s.azurecr.io/hello-app:1.0
kubectl scale  deployment hello-world --replicas=3
kubectl get pods -l app=hello-world

# We're working with the json output of our objects, in this case pods
# Let's start by accessing that list of Pods, inside items.
# Look at the items, find the metadata and name sections in the json output
kubectl get pods -l app=hello-world -o json > pods.json

# It's a list of objects, so let's display the pod names
kubectl get pods -l app=hello-world -o jsonpath='{ .items[*].metadata.name }'

# Display all pods names, this will put the new line at the end of the set rather then on each object output to screen.
# Additional tips on formatting code in the examples below including adding a new line after each object
kubectl get pods -l app=hello-world -o jsonpath='{ .items[*].metadata.name }{"\n"}'

#It's a list of objects, so let's display the first (zero'th) pod from the output
kubectl get pods -l app=hello-world -o jsonpath='{ .items[0].metadata.name }{"\n"}'

#Get all container images in use by all pods in all namespaces
kubectl get pods --all-namespaces -o jsonpath='{ .items[*].spec.containers[*].image }{"\n"}'

#Filtering a specific value in a list
#Let's say there's an list inside items and you need to access an element in that list.
#  ?() - defines a filter
#  @ - the current object
kubectl get nodes -o json
kubectl get nodes -o jsonpath="{.items[*].status.addresses[?(@.type=='InternalIP')].address}"

# Sorting
#Use the --sort-by parameter and define which field you want to sort on. It can be any field in the object.
kubectl get pods -A -o jsonpath='{ .items[*].metadata.name }{"\n"}' --sort-by=.metadata.name


#Now that we're sorting that output, maybe we want a listing of all pods sorted by a field that's part of the 
#object but not part of the default kubectl output. like creationTimestamp and we want to see what that value is
#We can use a custom colume to output object field data, in this case the creation timestamp
kubectl get pods -A -o jsonpath='{ .items[*].metadata.name }{"\n"}' \
    --sort-by=.metadata.creationTimestamp \
    --output=custom-columns='NAME:metadata.name,CREATIONTIMESTAMP:metadata.creationTimestamp'

# Clean up our resources
kubectl delete deployment hello-world 

# Let's use the range operator to print a new line for each object in the list
kubectl get pods -l app=hello-world -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

# Combining more than one piece of data, we can use range again to help with this
kubectl get pods -l app=hello-world -o jsonpath='{range .items[*]}{.metadata.name}{.spec.containers[*].image}{"\n"}{end}'

# All container images across all pods in all namespaces
# Range iterates over a list performing the formatting operations on each element in the list
# We can also add in a sort on the container image name
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].image}{"\n"}{end}' \
    --sort-by=.spec.containers[*].image

# We can use range again to clean up the output if we want
kubectl get nodes -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}'
kubectl get nodes -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="Hostname")].address}{"\n"}{end}'

# We used --sortby when looking at Events earlier, let's use it for another something else now.
# Let's take our container image output from above and sort it
kubectl get pods -A -o jsonpath='{ .items[*].spec.containers[*].image }' --sort-by=.spec.containers[*].image
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.name }{"\t"}{.spec.containers[*].image }{"\n"}{end}' --sort-by=.spec.containers[*].image

# Adding in a spaces or tabs in the output to make it a bit more readable
kubectl get pods -l app=hello-world -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.containers[*].image}{"\n"}{end}'
kubectl get pods -l app=hello-world -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].image}{"\n"}{end}'

#################
### Video 038 ###
#################

# Get the Metrics Server deployment manifest from github. https://github.com/kubernetes-sigs/metrics-server
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.0/components.yaml

# Add these two lines to metrics server's container args, around line 132
# - --kubelet-insecure-tls
# - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname

# Deploy the manifest for the Metrics Server
kubectl apply -f components.yaml
kubectl get pods --namespace kube-system

# We can get core information about memory and CPU.
kubectl top nodes

# If you have any issues check out the logs for the metric server.
kubectl logs --namespace kube-system -l k8s-app=metrics-server

# Let's check the perf data for pods, but there's no pods in the default namespace
kubectl top pods 

# We can look at our system pods, CPU and memory 
kubectl top pods --all-namespaces

# Deploy a pod that will burn a lot of CPU, but single threaded we have two vCPUs in our nodes.
kubectl apply -f cpuburner.yaml

# And create a deployment and scale it.
kubectl create deployment nginx --image=nginx
kubectl scale  deployment nginx --replicas=3

# Are our pods up and running?
kubectl get pods -o wide

# How about that CPU now, one of the nodes should have about 50% CPU, one should be 1000m+  Recall 1000m = 1vCPU.
# We can see the resource allocations across the nodes in terms of CPU and memory.
kubectl top nodes

# Get the perf across all pods. It can take a second after the deployments are create to get data
kubectl top pods 

# We can use labels and selectors to query subsets of pods
kubectl top pods -l app=cpuburner

# We have primitive sorting, top CPU and top memory consumers across all Pods
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory

# Now, that cpuburner, let's look a little more closely at it we can ask for perf for the containers inside a pod
kubectl top pods --containers

# Clean up  our resources
kubectl delete deployment cpuburner
kubectl delete deployment nginx


# Delete the Metrics Server and it's configuration elements
kubectl delete -f components.yaml
