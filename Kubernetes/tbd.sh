# V006:
# Review the process on the node that runs the pod.
kubectl get pods -o wide
ssh ec2-user@ip-192-168-79-9.eu-west-1.compute.internal
ps -aux | grep hello-app
exit