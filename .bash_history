wsl -l -v
sudo apt update && sudo apt upgrade -y
sudo apt install -y   curl unzip git jq make   ca-certificates gnupg lsb-release
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
docker run hello-world
curl -LO https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
curl -LO https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
sudo passwd dchambers
sudo mv kubectl /usr/local/bin/
pwd
ls
curl -LO https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
ls kubectl
curl -s https://dl.k8s.io/release/stable.txt
v1.30.3
curl -Ls https://dl.k8s.io/release/stable.txt
v1.30.3
KVER=$(curl -Ls https://dl.k8s.io/release/stable.txt)
echo $KVER
curl -LO "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
ls
pwd
ls
kubectl version --client
which kubectl
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
sudo apt update && sudo apt install terraform -y
mkdir -p iac/modules/{network,cluster,storage,observability,cost}
mkdir -p k8s/{base,apps,monitoring}
mkdir -p app/{preprocess,inference}
mkdir -p pipelines/github-actions
mkdir -p docs/{architecture,runbooks}
kind create cluster --name ai-lab
autoModeConfig:
aws eks update-kubeconfig --name ai-eks --region us-east-1
kubectl get nodes -o wide
kubectl get pods -A
kubectl config current-context
kubectl get ns
eksctl get nodegroup --cluster ai-eks --region us-east-1
eksctl utils describe-stacks --cluster ai-eks --region us-east-1
cat eksctl-ai-eks.yaml
aws cloudformation describe-stack-events   --stack-name eksctl-ai-eks-nodegroup-admin-ng   --region us-east-1   --max-items 20   --query "StackEvents[].{Time:Timestamp,Status:ResourceStatus,Type:ResourceType,LogicalId:LogicalResourceId,Reason:ResourceStatusReason}"   --output table
[200~aws ec2 describe-instances --region us-east-1   --filters "Name=tag:eks:cluster-name,Values=ai-eks" "Name=instance-state-name,Values=pending,running,stopping,stopped"   --query "Reservations[].Instances[].{Id:InstanceId,State:State.Name,AZ:Placement.AvailabilityZone,Type:InstanceType,PrivateIP:PrivateIpAddress}"   --output table
kubectl get nodes -w
gcloud container clusters list
gcloud container node-pools list --cluster <CLUSTER_NAME> --zone <ZONE>
gcloud container node-pools update <NODEPOOL_NAME>   --cluster <CLUSTER_NAME>   --zone <ZONE>   --num-nodes=0
gcloud container clusters delete ai-gke
eksctl get nodegroup --cluster ai-eks --region us-east-1
aws elbv2 describe-load-balancers --region us-east-1
kubectl get pvc -A
aws ec2 describe-volumes --region us-east-1   --filters Name=tag:kubernetes.io/cluster/ai-eks,Values=owned   --query "Volumes[].{Id:VolumeId,Size:Size,State:State}"   --output table
cat <<'EOF' > pvc-test.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-gp3-test
spec:
  accessModes: [ "ReadWriteOnce" ]
  storageClassName: gp3
  resources:
    requests:
      storage: 4Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: pvc-writer
spec:
  containers:
  - name: app
    image: public.ecr.aws/docker/library/busybox:1.36
    command: ["sh","-c","echo ok > /data/ok.txt && sleep 300"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: ebs-gp3-test
EOF

kubectl apply -f pvc-test.yaml
kubectl get pvc ebs-gp3-test
kubectl get pod pvc-writer -o wide
kubectl get pvc ebs-gp3-test
kubectl get pod pvc-writer -o wide
kubectl get pvc ebs-gp3-test
kubectl get pod pvc-writer -o wide
kubectl get storageclass
kubectl describe pvc ebs-gp3-test
cat <<'EOF' > gp3-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
parameters:
  type: gp3
  encrypted: "true"
EOF

kubectl apply -f gp3-sc.yaml
kubectl get storageclass
kubectl get pvc ebs-gp3-test
kubectl get pod pvc-writer -o wide
kubectl delete pod pvc-writer
kubectl describe pvc ebs-gp3-test | tail -n 30
kubectl apply -f pvc-test.yaml
kubectl get pvc ebs-gp3-test
kubectl get pod pvc-writer -o wide
kubectl describe pvc ebs-gp3-test | tail -n 50
kubectl -n kube-system logs deploy/ebs-csi-controller -c csi-provisioner --tail=80
kubectl describe pod pvc-writer | tail -n 40
kubectl delete pod pvc-writer
cat <<'EOF' > pvc-writer-only.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-writer
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "admin"
    effect: "NoSchedule"
  containers:
  - name: app
    image: public.ecr.aws/docker/library/busybox:1.36
    command: ["sh","-c","echo ok > /data/ok.txt && sleep 300"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: ebs-gp3-test
EOF

kubectl apply -f pvc-writer-only.yaml
kubectl get pod pvc-writer -o wide
kubectl get pvc ebs-gp3-test
kubectl exec -it pvc-writer -- cat /data/ok.txt
kubectl delete pod pvc-writer
kubectl delete pvc ebs-gp3-test
aws ec2 describe-volumes --region us-east-1   --filters Name=tag:kubernetes.io/cluster/ai-eks,Values=owned   --query "Volumes[].{Id:VolumeId,State:State,Size:Size}"   --output table
aws ec2 describe-volumes --region us-east-1   --filters Name=tag:kubernetes.io/cluster/ai-eks,Values=owned   --query "Volumes[].{Id:VolumeId,State:State,Size:Size}"   --output table
kubectl patch storageclass gp3 -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl patch storageclass gp2 -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl get storageclass
kubectl get nodes -o wide
kubectl -n kube-system get pods | egrep "karpenter|coredns|aws-node|kube-proxy"
kubectl get storageclass
aws configure get region
aws eks list-clusters --region us-west-2
helm repo add karpenter https://charts.karpenter.sh
helm repo update
kubectl create namespace karpenter
export CLUSTER_NAME="YOUR_CLUSTER"
export AWS_REGION="us-west-2"
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export KARPENTER_NAMESPACE="karpenter"
export KARPENTER_SA="karpenter"
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --region $AWS_REGION --approve
cat > karpenter-controller-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KarpenterController",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateLaunchTemplate",
        "ec2:CreateFleet",
        "ec2:RunInstances",
        "ec2:CreateTags",
        "ec2:TerminateInstances",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeImages",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "pricing:GetProducts",
        "ssm:GetParameter",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-policy   --policy-name KarpenterControllerPolicy-${CLUSTER_NAME}   --policy-document file://karpenter-controller-policy.json
eksctl create iamserviceaccount   --cluster $CLUSTER_NAME   --region $AWS_REGION   --namespace $KARPENTER_NAMESPACE   --name $KARPENTER_SA   --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/KarpenterControllerPolicy-${CLUSTER_NAME}   --approve   --override-existing-serviceaccounts
export KARPENTER_NODE_ROLE="KarpenterNodeRole-${CLUSTER_NAME}"
aws iam create-role   --role-name ${KARPENTER_NODE_ROLE}   --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }'
aws iam attach-role-policy --role-name ${KARPENTER_NODE_ROLE} --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name ${KARPENTER_NODE_ROLE} --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam attach-role-policy --role-name ${KARPENTER_NODE_ROLE} --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam attach-role-policy --role-name ${KARPENTER_NODE_ROLE} --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam create-instance-profile --instance-profile-name ${KARPENTER_NODE_ROLE}
aws iam add-role-to-instance-profile --instance-profile-name ${KARPENTER_NODE_ROLE} --role-name ${KARPENTER_NODE_ROLE}
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query "cluster.endpoint" --output text)"
export KARPENTER_IAM_ROLE_ARN="$(aws iam get-role --role-name ${KARPENTER_NODE_ROLE} --query "Role.Arn" --output text)"
aws configure get region
aws eks list-clusters --region us-west-2 --output table
aws eks list-clusters --region us-east-1 --output table
export AWS_REGION="us-east-1"
export CLUSTER_NAME="ai-eks"
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export KARPENTER_NODE_ROLE="KarpenterNodeRole-$ai-eks"
aws iam delete-instance-profile --instance-profile-name "KarpenterNodeRole-YOUR_CLUSTER"
export KARPENTER_NODE_ROLE="KarpenterNodeRole-${CLUSTER_NAME}"
echo $KARPENTER_NODE_ROLE
aws iam get-instance-profile   --instance-profile-name "KarpenterNodeRole-YOUR_CLUSTER"   --query "InstanceProfile.Roles[].RoleName"   --output text
aws iam remove-role-from-instance-profile   --instance-profile-name "KarpenterNodeRole-YOUR_CLUSTER"   --role-name "KarpenterNodeRole-YOUR_CLUSTER"
aws iam delete-instance-profile --instance-profile-name "KarpenterNodeRole-YOUR_CLUSTER"
aws iam create-instance-profile --instance-profile-name "$KARPENTER_NODE_ROLE"
aws iam add-role-to-instance-profile --instance-profile-name "$KARPENTER_NODE_ROLE" --role-name "$KARPENTER_NODE_ROLE"
aws iam get-instance-profile --instance-profile-name "$KARPENTER_NODE_ROLE"   --query "InstanceProfile.Roles[].RoleName" --output text
aws iam create-role   --role-name "$KARPENTER_NODE_ROLE"   --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }'
aws iam attach-role-policy --role-name "$KARPENTER_NODE_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name "$KARPENTER_NODE_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam attach-role-policy --role-name "$KARPENTER_NODE_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam attach-role-policy --role-name "$KARPENTER_NODE_ROLE" --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam add-role-to-instance-profile   --instance-profile-name "$KARPENTER_NODE_ROLE"   --role-name "$KARPENTER_NODE_ROLE"
aws iam get-instance-profile --instance-profile-name "$KARPENTER_NODE_ROLE"   --query "InstanceProfile.Roles[].RoleName" --output text
kubectl -n kube-system get configmap aws-auth -o yaml > aws-auth.yaml
nano aws-auth.yaml
kubectl apply -f aws-auth.yaml
kubectl -n kube-system get configmap aws-auth -o yaml | sed -n '/mapRoles:/,/mapUsers:/p'
kubectl get ns | grep karpenter
kubectl -n karpenter get pods
helm -n karpenter list
kubectl -n karpenter get sa
kubectl -n karpenter get sa karpenter -o yaml | sed -n '/annotations:/,/secrets:/p'
kubectl -n karpenter create serviceaccount karpenter
eksctl utils associate-iam-oidc-provider --cluster ai-eks --region us-east-1 --approve
export AWS_REGION="us-east-1"
export CLUSTER_NAME="ai-eks"
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
cat > karpenter-controller-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KarpenterController",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateLaunchTemplate",
        "ec2:CreateFleet",
        "ec2:RunInstances",
        "ec2:CreateTags",
        "ec2:TerminateInstances",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeImages",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeTags",
        "pricing:GetProducts",
        "ssm:GetParameter",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-policy   --policy-name KarpenterControllerPolicy-${CLUSTER_NAME}   --policy-document file://karpenter-controller-policy.json || true
eksctl create iamserviceaccount   --cluster $CLUSTER_NAME   --region $AWS_REGION   --namespace karpenter   --name karpenter   --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/KarpenterControllerPolicy-${CLUSTER_NAME}   --approve   --override-existing-serviceaccounts
kubectl -n karpenter get sa karpenter -o yaml | sed -n '/annotations:/,/secrets:/p'
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --query "cluster.endpoint" --output text)"
echo $CLUSTER_ENDPOINT
helm repo add karpenter https://charts.karpenter.sh
helm repo update
helm upgrade --install karpenter karpenter/karpenter   --namespace karpenter   --set serviceAccount.create=false   --set serviceAccount.name=karpenter   --set settings.clusterName=${CLUSTER_NAME}   --set settings.clusterEndpoint=${CLUSTER_ENDPOINT}
kubectl -n karpenter get pods -w
kubectl get nodes -w
kubectl describe pod gpu-smoke | sed -n '/Events:/,$p'
aws eks delete-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ng
gcloud container node-pools list --cluster ai-gke --zone us-central1-a
kubectl describe pod gpu-trigger | sed -n '1,220p'
gcloud compute regions describe us-central1   --format="table(quotas.metric,quotas.limit,quotas.usage)"   | grep -i l4
# T4 on-demand + preemptible
gcloud compute regions describe us-central1 --format="value(quotas[metric=NVIDIA_T4_GPUS].limit,quotas[metric=NVIDIA_T4_GPUS].usage)"
gcloud compute regions describe us-central1 --format="value(quotas[metric=PREEMPTIBLE_NVIDIA_T4_GPUS].limit,quotas[metric=PREEMPTIBLE_NVIDIA_T4_GPUS].usage)"
# L4 on-demand + preemptible
gcloud compute regions describe us-central1 --format="value(quotas[metric=NVIDIA_L4_GPUS].limit,quotas[metric=NVIDIA_L4_GPUS].usage)"
gcloud compute regions describe us-central1 --format="value(quotas[metric=PREEMPTIBLE_NVIDIA_L4_GPUS].limit,quotas[metric=PREEMPTIBLE_NVIDIA_L4_GPUS].usage)"
# A100 (sometimes enabled when others aren't)
gcloud compute regions describe us-central1 --format="value(quotas[metric=NVIDIA_A100_GPUS].limit,quotas[metric=NVIDIA_A100_GPUS].usage)"
gcloud compute regions describe us-central1 --format="value(quotas[metric=PREEMPTIBLE_NVIDIA_A100_GPUS].limit,quotas[metric=PREEMPTIBLE_NVIDIA_A100_GPUS].usage)"
aws --version
eksctl version
kubectl version --client --short
helm version
sudo apt update
sudo apt install -y awscli unzip
aws --version
sudo apt install awscli
sudo apt update
sudo apt install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
aws --version
ARCH=$(uname -m)
[ "$ARCH" = "x86_64" ] && ARCH=amd64
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${ARCH}.tar.gz"
tar -xzf eksctl_Linux_${ARCH}.tar.gz
sudo mv eksctl /usr/local/bin/
eksctl version
aws configure
aws sts get-caller-identity
aws configure
aws sts get-caller-identity
aws configure
aws sts get-caller-identity
export AWS_REGION=us-east-1
aws sts get-caller-identity --region $AWS_REGION
ARCH=$(uname -m)
[ "$ARCH" = "x86_64" ] && ARCH=amd64
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${ARCH}.tar.gz"
tar -xzf eksctl_Linux_${ARCH}.tar.gz
sudo mv eksctl /usr/local/bin/
eksctl version
which eksctl
eksctl version
aws configure set region us-east-1
aws configure get region
eksctl create cluster -f eksctl-ai-eks.yaml
pwd
ls
find ~ -name eksctl-ai-eks.yaml 2>/dev/null
mv /path/to/eksctl-ai-eks.yaml ~/
cd ~
cat << 'EOF' > eksctl-ai-eks.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ai-eks
  region: us-east-1
  tags:
    karpenter.sh/discovery: ai-eks

managedNodeGroups:
  - name: admin-ng
    instanceType: t3.large
    desiredCapacity: 1
    minSize: 1
    maxSize: 2
    labels:
      role: admin
EOF

ls -l eksctl-ai-eks.yaml
cat eksctl-ai-eks.yaml
eksctl create cluster -f eksctl-ai-eks.yaml
aws ec2 describe-instances --region us-east-1   --filters "Name=tag:eks:cluster-name,Values=ai-eks" "Name=instance-state-name,Values=pending,running,stopping,stopped"   --query "Reservations[].Instances[].{Id:InstanceId,State:State.Name,AZ:Placement.AvailabilityZone,Type:InstanceType,PrivateIP:PrivateIpAddress}"   --output table
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide
kubectl taint nodes -l role=admin dedicated=admin:NoSchedule
eksctl get nodegroup --cluster ai-eks --region us-east-1
kubectl -n kube-system describe pod coredns-6b9575c64c-5djzz | grep -i -A2 tolerations
kubectl -n kube-system describe pod metrics-server-7cbd59cb7c-56nqw | grep -i -A2 tolerations
eksctl utils update-cluster-logging --region us-east-1 --cluster ai-eks --enable-types=all
kubectl -n kube-system patch deployment coredns --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"dedicated","operator":"Equal","value":"admin","effect":"NoSchedule"}}
]'
kubectl -n kube-system patch deployment metrics-server --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"dedicated","operator":"Equal","value":"admin","effect":"NoSchedule"}}
]'
kubectl -n kube-system get deploy coredns metrics-server -o yaml | grep -i -A4 tolerations
eksctl utils update-cluster-logging --region us-east-1 --cluster ai-eks --enable-types=all --approve
aws eks describe-cluster --name ai-eks --region us-east-1 --query "cluster.logging" --output json
aws logs describe-log-groups --region us-east-1   --log-group-name-prefix "/aws/eks/ai-eks"   --query "logGroups[].logGroupName"   --output table
kubectl -n kube-system patch deployment coredns --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"dedicated","operator":"Equal","value":"admin","effect":"NoSchedule"}}
]'
kubectl -n kube-system patch deployment metrics-server --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"dedicated","operator":"Equal","value":"admin","effect":"NoSchedule"}}
]'
kubectl -n kube-system rollout status deploy/coredns
kubectl -n kube-system rollout status deploy/metrics-server
eksctl utils associate-iam-oidc-provider   --cluster ai-eks   --region us-east-1   --approve
aws eks describe-cluster --name ai-eks --region us-east-1   --query "cluster.identity.oidc.issuer" --output text
helm repo add eks https://aws.github.io/eks-charts
helm repo update
curl -sLO https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
aws iam create-policy   --policy-name AWSLoadBalancerControllerIAMPolicy-ai-eks   --policy-document file://iam_policy.json
eksctl utils associate-iam-oidc-provider   --cluster ai-eks   --region us-east-1   --approve
aws eks describe-cluster --name ai-eks --region us-east-1   --query "cluster.identity.oidc.issuer" --output text
eksctl create iamserviceaccount   --cluster ai-eks   --region us-east-1   --namespace kube-system   --name aws-load-balancer-controller   --attach-policy-arn arn:aws:iam::344322112774:policy/AWSLoadBalancerControllerIAMPolicy-ai-eks   --approve   --override-existing-serviceaccounts
helm repo add eks https://aws.github.io/eks-charts
helm repo update
VPC_ID=$(aws eks describe-cluster --name ai-eks --region us-east-1 --query "cluster.resourcesVpcConfig.vpcId" --output text)
echo $VPC_ID
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller   -n kube-system   --set clusterName=ai-eks   --set serviceAccount.create=false   --set serviceAccount.name=aws-load-balancer-controller   --set region=us-east-1   --set vpcId=$VPC_ID
kubectl -n kube-system get pods | grep aws-load-balancer-controller
kubectl -n kube-system logs deploy/aws-load-balancer-controller --tail=50
kubectl -n kube-system patch deployment aws-load-balancer-controller --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"dedicated","operator":"Equal","value":"admin","effect":"NoSchedule"}}
]'
kubectl -n kube-system rollout status deploy/aws-load-balancer-controller
kubectl -n kube-system get pods | grep aws-load-balancer-controller
kubectl taint nodes -l role=admin dedicated=admin:NoSchedule-
kubectl -n kube-system logs deploy/aws-load-balancer-controller --tail=80
kubectl -n kube-system delete lease aws-load-balancer-controller-leader
kubectl -n kube-system rollout restart deploy/aws-load-balancer-controller
kubectl -n kube-system rollout status deploy/aws-load-balancer-controller
kubectl -n kube-system get pods | grep aws-load-balancer-controller
kubectl -n kube-system logs deploy/aws-load-balancer-controller --tail=60
kubectl -n kube-system patch deployment aws-load-balancer-controller --type='merge' -p '
spec:
  template:
    spec:
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "admin"
        effect: "NoSchedule"
'
kubectl taint nodes -l role=admin dedicated=admin:NoSchedule
kubectl -n kube-system get pods -o wide | egrep "aws-load-balancer-controller|coredns|metrics-server"
kubectl -n kube-system describe lease aws-load-balancer-controller-leader
eksctl create iamserviceaccount   --cluster ai-eks   --region us-east-1   --namespace kube-system   --name ebs-csi-controller-sa   --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy   --approve   --override-existing-serviceaccounts
aws eks create-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --service-account-role-arn $(aws iam get-role --role-name eksctl-ai-eks-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa --query "Role.Arn" --output text)
ROLE_ARN=$(aws iam get-role \
  --role-name eksctl-ai-eks-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa \
  --query "Role.Arn" --output text)
echo $ROLE_ARN
aws cloudformation describe-stacks   --region us-east-1   --stack-name eksctl-ai-eks-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa   --query "Stacks[0].Outputs"   --output table
ROLE_ARN=$(aws cloudformation describe-stacks \
  --region us-east-1 \
  --stack-name eksctl-ai-eks-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa \
  --query "Stacks[0].Outputs[?contains(OutputKey,'Role')].OutputValue | [0]" \
  --output text)
echo $ROLE_ARN
aws eks create-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --service-account-role-arn "$ROLE_ARN"
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.status"   --output text
kubectl -n kube-system get pods -o wide | grep ebs
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.{status:status,issues:health.issues,version:addonVersion}"   --output json
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.health.issues"   --output table
kubectl -n kube-system get sa | grep ebs
kubectl -n kube-system get deployment,daemonset | grep -i ebs
kubectl get csidriver | grep -i ebs
aws eks delete-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1
kubectl -n kube-system delete serviceaccount ebs-csi-controller-sa
aws eks create-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --service-account-role-arn "$ROLE_ARN"   --resolve-conflicts OVERWRITE
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.status"   --output text
kubectl -n kube-system get pods -o wide | grep ebs
kubectl -n kube-system describe pod ebs-csi-controller-79c56548f6-wjk6f | tail -n 40
kubectl -n kube-system patch deployment ebs-csi-controller --type='merge' -p '
spec:
  template:
    spec:
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "admin"
        effect: "NoSchedule"
'
kubectl -n kube-system rollout status deploy/ebs-csi-controller
kubectl -n kube-system get pods -o wide | grep ebs
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.status"   --output text
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.health.issues"   --output table
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.{status:status,version:addonVersion,createdAt:createdAt,modifiedAt:modifiedAt,issues:health.issues}"   --output json
kubectl get csidriver
kubectl -n kube-system logs deploy/ebs-csi-controller --tail=60
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.health.issues"   --output table
aws eks update-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --service-account-role-arn "$ROLE_ARN"   --resolve-conflicts OVERWRITE
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.status"   --output text
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.status"   --output text
aws eks describe-addon   --cluster-name ai-eks   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.status"   --output text
aws eks describe-update   --name ai-eks   --region us-east-1   --update-id 92c8da9f-5d69-32b7-8fbf-3ed44c098c96   --query "update.{status:status,errors:errors}"   --output json
kubectl -n karpenter get pods -w
kubectl -n karpenter get events --sort-by=.lastTimestamp | tail -30
kubectl -n karpenter get deploy,rs,po
helm -n karpenter status karpenter
kubectl get nodes -o name
kubectl taint nodes node/ip-192-168-47-11.ec2.internal dedicated=admin:NoSchedule-
kubectl describe node <NODE_NAME> | sed -n '/Taints:/,/Unschedulable:/p'
kubectl describe node node/ip-192-168-47-11.ec2.internal untainted | sed -n '/Taints:/,/Unschedulable:/p'
kubectl describe node <NODE_NAME> | sed -n '/Taints:/,/Unschedulable:/p'
kubectl -n karpenter get pods -w
kubectl describe node ip-192-168-47-11.ec2.internal | sed -n '/Taints:/,/Unschedulable:/p'
kubectl -n karpenter get pods -o wide
kubectl -n karpenter scale deployment karpenter --replicas=1
kubectl -n karpenter get pods -o wide
kubectl -n karpenter logs karpenter-75b9474f68-4ldvb -c controller --tail=250
kubectl -n karpenter get pod karpenter-75b9474f68-4ldvb -o jsonpath='{.spec.containers[*].name}{"\n"}'
kubectl -n karpenter describe pod karpenter-75b9474f68-4ldvb | sed -n '/State:/,/Events:/p'
export AWS_REGION="us-east-1"
export CLUSTER_NAME="ai-eks"
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --query "cluster.endpoint" --output text)"
echo "$CLUSTER_ENDPOINT"
kubectl -n karpenter set env deployment/karpenter   CLUSTER_NAME="$CLUSTER_NAME"   CLUSTER_ENDPOINT="$CLUSTER_ENDPOINT"
kubectl -n karpenter rollout restart deployment/karpenter
kubectl -n karpenter get pods -w
kubectl -n karpenter logs deploy/karpenter -c controller --tail=80
helm -n karpenter upgrade karpenter karpenter/karpenter   --set serviceAccount.create=false   --set serviceAccount.name=karpenter   --set settings.clusterName=${CLUSTER_NAME}   --set settings.clusterEndpoint=${CLUSTER_ENDPOINT}
kubectl -n karpenter rollout status deployment/karpenter
kubectl -n karpenter scale deployment karpenter --replicas=1
kubectl -n karpenter rollout status deployment/karpenter
kubectl -n karpenter get pods -o wide
SUBNETS=$(aws eks describe-cluster --name ai-eks --region us-east-1 --query "cluster.resourcesVpcConfig.subnetIds" --output text)
CLUSTER_SG=$(aws eks describe-cluster --name ai-eks --region us-east-1 --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)
echo "SUBNETS=$SUBNETS"
echo "CLUSTER_SG=$CLUSTER_SG"
aws ec2 create-tags --region us-east-1   --resources $SUBNETS   --tags Key=karpenter.sh/discovery,Value=ai-eks
aws ec2 create-tags --region us-east-1   --resources $CLUSTER_SG   --tags Key=karpenter.sh/discovery,Value=ai-eks
cat > karpenter-cpu-v016.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: cpu-default
spec:
  subnetSelector:
    karpenter.sh/discovery: ai-eks
  securityGroupSelector:
    karpenter.sh/discovery: ai-eks
  instanceProfile: KarpenterNodeRole-ai-eks
  amiFamily: AL2
---
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: cpu-on-demand
spec:
  providerRef:
    name: cpu-default
  requirements:
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: ["m6i.large","m6i.xlarge","c6i.large","c6i.xlarge","r6i.large"]
  limits:
    resources:
      cpu: 64
  ttlSecondsUntilExpired: 604800
  consolidation:
    enabled: true
EOF

kubectl apply -f karpenter-cpu-v016.yaml
kubectl get provisioners
kubectl get awsnodetemplates
kubectl create deploy inflate --image=public.ecr.aws/eks-distro/kubernetes/pause:3.9
kubectl set resources deploy inflate --requests=cpu=250m,memory=256Mi
kubectl scale deploy inflate --replicas=30
kubectl get nodes -w
kubectl get pods -o wide | grep inflate
kubectl get nodes -o wide
kubectl -n kube-system get configmap aws-auth -o yaml | sed -n '/mapRoles:/,/mapUsers:/p'
kubectl scale deploy inflate --replicas=0
kubectl delete deploy inflate
kubectl patch provisioner cpu-on-demand --type merge -p '{
  "spec": {
    "ttlSecondsAfterEmpty": 60
  }
}'
kubectl get nodes -w
kubectl get provisioner,awsnodetemplate -A
export AWS_REGION="us-east-1"
export CLUSTER_NAME="ai-eks"
export EKS_VERSION="$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.version' --output text)"
echo $EKS_VERSION
cat > karpenter-gpu-v016.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: gpu-default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: KarpenterNodeRole-${CLUSTER_NAME}
  amiFamily: AL2
  amiSelector:
    aws::ssm:/aws/service/eks/optimized-ami/${EKS_VERSION}/amazon-linux-2-gpu/recommended/image_id: "*"
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    workload: gpu
---
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: gpu-on-demand
spec:
  providerRef:
    name: gpu-default
  labels:
    workload: gpu
  taints:
    - key: nvidia.com/gpu
      value: "true"
      effect: NoSchedule
  requirements:
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: ["g5.xlarge","g5.2xlarge","g4dn.xlarge","g4dn.2xlarge"]
  limits:
    resources:
      cpu: 64
  ttlSecondsUntilExpired: 604800
  consolidation:
    enabled: true
EOF

kubectl apply -f karpenter-gpu-v016.yaml
kubectl get provisioner,awsnodetemplate
helm repo add nvidia https://nvidia.github.io/k8s-device-plugin
helm repo update
helm upgrade --install nvidia-device-plugin nvidia/k8s-device-plugin   --namespace kube-system   --set failOnInitError=false
helm search repo nvidia --versions | head -40
helm upgrade --install nvidia-device-plugin nvidia/nvidia-device-plugin   --namespace kube-system   --set failOnInitError=false
kubectl -n kube-system get ds | grep -i nvidia
kubectl -n kube-system get pods | grep -i nvidia
helm search repo nvidia --versions | head -40
export AWS_REGION="us-east-1"
export CLUSTER_NAME="ai-eks"
export EKS_VERSION="$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.version' --output text)"
echo $EKS_VERSION
cat > karpenter-gpu-v016.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: gpu-default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: KarpenterNodeRole-${CLUSTER_NAME}
  amiFamily: AL2
  amiSelector:
    aws::ssm:/aws/service/eks/optimized-ami/${EKS_VERSION}/amazon-linux-2-gpu/recommended/image_id: "*"
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    workload: gpu
---
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: gpu-on-demand
spec:
  providerRef:
    name: gpu-default
  labels:
    workload: gpu
  taints:
    - key: nvidia.com/gpu
      value: "true"
      effect: NoSchedule
  requirements:
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: ["g5.xlarge","g5.2xlarge","g4dn.xlarge","g4dn.2xlarge"]
  limits:
    resources:
      cpu: 64
  ttlSecondsUntilExpired: 604800
  consolidation:
    enabled: true
EOF

kubectl apply -f karpenter-gpu-v016.yaml
kubectl get provisioner,awsnodetemplate
helm upgrade --install nvidia-device-plugin nvidia/nvidia-device-plugin   --namespace kube-system   --set failOnInitError=false
kubectl -n kube-system get ds | grep -i nvidia
cat > gpu-smoke-test.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: gpu-smoke
spec:
  restartPolicy: Never
  nodeSelector:
    workload: gpu
  tolerations:
    - key: "nvidia.com/gpu"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"
  containers:
    - name: cuda
      image: nvidia/cuda:12.2.0-base-ubuntu22.04
      command: ["bash","-lc","nvidia-smi && sleep 5"]
      resources:
        limits:
          nvidia.com/gpu: 1
EOF

kubectl apply -f gpu-smoke-test.yaml
kubectl get nodes -w
kubectl get pod gpu-smoke -o wide
kubectl logs gpu-smoke
kubectl describe pod gpu-smoke | sed -n '/Events:/,$p'
kubectl -n karpenter logs deploy/karpenter -c controller --tail=200
export AWS_REGION="us-east-1"
export CLUSTER_NAME="ai-eks"
export EKS_VERSION="$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.version' --output text)"
echo "EKS_VERSION=$EKS_VERSION"
GPU_AMI_ID=$(aws ssm get-parameter \
  --region $AWS_REGION \
  --name "/aws/service/eks/optimized-ami/${EKS_VERSION}/amazon-linux-2-gpu/recommended/image_id" \
  --query "Parameter.Value" --output text)
echo "GPU_AMI_ID=$GPU_AMI_ID"
kubectl patch awsnodetemplate gpu-default --type merge -p "{
  \"spec\": {
    \"amiSelector\": {
      \"aws-ids\": \"${GPU_AMI_ID}\"
    }
  }
}"
kubectl delete pod gpu-smoke
kubectl apply -f gpu-smoke-test.yaml
kubectl get nodes -w
kubectl get pod gpu-smoke -o wide
kubectl logs gpu-smoke
kubectl -n karpenter logs deploy/karpenter -c controller --tail=120 | egrep -i "gpu-on-demand|no amis|launching node|provisioning failed|accessdenied|insufficient|limit|quota|subnet|security group|instance profile"
kubectl delete pod gpu-smoke
cat > gpu-smoke-test.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: gpu-smoke
spec:
  restartPolicy: Never
  tolerations:
    - key: "nvidia.com/gpu"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"
  containers:
    - name: cuda
      image: nvidia/cuda:12.2.0-base-ubuntu22.04
      command: ["bash","-lc","nvidia-smi && sleep 5"]
      resources:
        limits:
          nvidia.com/gpu: 1
EOF

kubectl apply -f gpu-smoke-test.yaml
kubectl patch provisioner gpu-on-demand --type merge -p '{
  "spec": {
    "requirements": [
      {"key":"kubernetes.io/arch","operator":"In","values":["amd64"]},
      {"key":"karpenter.sh/capacity-type","operator":"In","values":["on-demand"]},
      {"key":"node.kubernetes.io/instance-type","operator":"In","values":["g4dn.xlarge","g4dn.2xlarge","g4dn.4xlarge","g5.xlarge","g5.2xlarge","g5.4xlarge"]}
    ]
  }
}'
kubectl get nodes -w
kubectl get pod gpu-smoke -o wide
kubectl logs gpu-smoke
kubectl delete awsnodetemplate gpu-default
cat > gpu-awsnodetemplate.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: gpu-default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: KarpenterNodeRole-${CLUSTER_NAME}
  amiFamily: AL2
  amiSelector:
    aws::ec2:image-id: "${GPU_AMI_ID}"
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    workload: gpu
EOF

kubectl apply -f gpu-awsnodetemplate.yaml
kubectl -n karpenter rollout restart deployment/karpenter
kubectl -n karpenter rollout status deployment/karpenter
kubectl delete pod gpu-smoke --ignore-not-found
kubectl apply -f gpu-smoke-test.yaml
kubectl get nodes -w
kubectl get pod gpu-smoke -o wide
kubectl -n karpenter logs deploy/karpenter -c controller --tail=120 | egrep -i "Launching node|provisioning failed|no amis|AccessDenied|Insufficient|limit|quota"
# 1) Set the GPU AMI selector the way Karpenter v0.16 expects (aws::ids)
kubectl patch awsnodetemplate gpu-default --type merge -p "{
  \"spec\": {
    \"amiSelector\": {
      \"aws::ids\": \"${GPU_AMI_ID}\"
    }
  }
}"
# 2) Nuke + recreate the test pod so Karpenter re-evaluates immediately
kubectl delete pod gpu-smoke --ignore-not-found
kubectl apply -f gpu-smoke-test.yaml
# 3) Watch Karpenter stop complaining about AMIs and start launching
kubectl -n karpenter logs deploy/karpenter -c controller --tail=200 | egrep -i "gpu-on-demand|Launching node|no amis|Provisioning failed"
# 4) Watch the GPU node join
kubectl get nodes -w
kubectl get awsnodetemplate gpu-default -o yaml | sed -n '/amiSelector:/,/tags:/p'
kubectl patch awsnodetemplate gpu-default --type json -p='[
  {"op":"remove","path":"/spec/amiSelector/aws::ec2:image-id"}
]'
kubectl get awsnodetemplate gpu-default -o yaml | sed -n '/amiSelector:/,/instanceProfile:/p'
amiSelector:
kubectl delete pod gpu-smoke --ignore-not-found
kubectl apply -f gpu-smoke-test.yaml
kubectl -n karpenter logs deploy/karpenter -c controller --tail=200 | egrep -i "gpu-on-demand|Launching node|Provisioning failed|AccessDenied|Insufficient|quota|limit"
kubectl delete awsnodetemplate gpu-default
cat > gpu-awsnodetemplate.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: gpu-default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: KarpenterNodeRole-${CLUSTER_NAME}
  amiFamily: AL2
  amiSelector:
    aws::ids:
      - "${GPU_AMI_ID}"
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    workload: gpu
EOF

kubectl apply -f gpu-awsnodetemplate.yaml
cat > gpu-awsnodetemplate.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: gpu-default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: KarpenterNodeRole-${CLUSTER_NAME}
  amiFamily: AL2
  amiSelector:
    aws::ids: "${GPU_AMI_ID}"
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    workload: gpu
EOF

kubectl apply -f gpu-awsnodetemplate.yaml
kubectl patch provisioner gpu-on-demand --type merge -p '{
  "spec": {
    "providerRef": { "name": "gpu-default" }
  }
}'
kubectl -n karpenter rollout restart deployment/karpenter
kubectl -n karpenter rollout status deployment/karpenter
kubectl delete pod gpu-smoke --ignore-not-found
kubectl apply -f gpu-smoke-test.yaml
kubectl get awsnodetemplate gpu-default -o yaml | sed -n '/apiVersion:/,/tags:/p'
kubectl get provisioner gpu-on-demand -o yaml | sed -n '/providerRef:/,/requirements:/p'
kubectl -n karpenter logs deploy/karpenter -c controller --tail=200 | egrep -i "gpu-on-demand|Launching node|Provisioning failed|no amis|AccessDenied|Insufficient|quota|limit|subnet|security"
kubectl get nodes -w
kubectl describe node <NEW_GPU_NODE> | egrep -i "nvidia.com/gpu|Capacity|Allocatable" -n
export AWS_REGION=us-east-1
export CLUSTER_NAME=ai-eks
export GPU_AMI_ID=ami-016835d5e961b0712
LT_NAME="${CLUSTER_NAME}-gpu-lt"
aws ec2 create-launch-template   --region "$AWS_REGION"   --launch-template-name "$LT_NAME"   --launch-template-data "{
    \"ImageId\":\"$GPU_AMI_ID\"
  }"   --tag-specifications "ResourceType=launch-template,Tags=[{Key=karpenter.sh/discovery,Value=$CLUSTER_NAME},{Key=workload,Value=gpu}]"
kubectl patch awsnodetemplate gpu-default --type merge -p "{
  \"spec\": {
    \"launchTemplate\": {
      \"name\": \"${CLUSTER_NAME}-gpu-lt\"
    }
  }
}"
kubectl patch awsnodetemplate gpu-default --type merge -p "{
  \"spec\": {
    \"launchTemplate\": \"${CLUSTER_NAME}-gpu-lt\"
  }
}"
kubectl patch awsnodetemplate gpu-default --type merge -p "{
  \"spec\": {
    \"launchTemplate\": \"lt-0a82cac36d8cce778\"
  }
}"
kubectl delete awsnodetemplate gpu-default
cat > gpu-awsnodetemplate.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: gpu-default
spec:
  provider:
    launchTemplate: ${CLUSTER_NAME}-gpu-lt
    amiFamily: AL2
    subnetSelector:
      karpenter.sh/discovery: ${CLUSTER_NAME}
    securityGroupSelector:
      karpenter.sh/discovery: ${CLUSTER_NAME}
    instanceProfile: KarpenterNodeRole-${CLUSTER_NAME}
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    workload: gpu
EOF

kubectl apply -f gpu-awsnodetemplate.yaml
kubectl patch provisioner gpu-on-demand --type merge -p '{
  "spec": { "providerRef": { "name": "gpu-default" } }
}'
kubectl delete awsnodetemplate gpu-default --ignore-not-found
cat > gpu-awsnodetemplate.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: gpu-default
spec:
  launchTemplate: ${CLUSTER_NAME}-gpu-lt
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: KarpenterNodeRole-${CLUSTER_NAME}
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    workload: gpu
EOF

kubectl apply -f gpu-awsnodetemplate.yaml
kubectl delete awsnodetemplate gpu-default --ignore-not-found
cat > gpu-awsnodetemplate.yaml <<EOF
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: gpu-default
spec:
  amiFamily: AL2
  amiSelector:
    aws-ids: "${GPU_AMI_ID}"
  subnetSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelector:
    karpenter.sh/discovery: ${CLUSTER_NAME}
  instanceProfile: KarpenterNodeRole-${CLUSTER_NAME}
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    workload: gpu
EOF

kubectl apply -f gpu-awsnodetemplate.yaml
kubectl -n karpenter rollout restart deployment/karpenter
kubectl -n karpenter rollout status deployment/karpenter
kubectl delete pod gpu-smoke --ignore-not-found
kubectl apply -f gpu-smoke-test.yaml
kubectl -n karpenter logs deploy/karpenter -c controller --tail=120 | egrep -i "Launching node|Provisioning failed|no amis|AccessDenied|Insufficient|quota|limit|instance profile|security group|subnet"
kubectl get pod gpu-smoke -o wide
kubectl describe pod gpu-smoke | sed -n '/Events:/,$p'
kubectl get nodes -o wide
kubectl describe node ip-192-168-125-158.ec2.internal | sed -n '/Conditions:/,/Events:/p'
kubectl describe node ip-192-168-125-158.ec2.internal | sed -n '/Events:/,$p'
kubectl -n kube-system get pods -o wide | egrep -i "aws-node|kube-proxy|nvidia|coredns" | head -200
kubectl get node ip-192-168-125-158.ec2.internal -L node.kubernetes.io/instance-type -o wide
kubectl get node ip-192-168-125-158.ec2.internal -o jsonpath='{.metadata.labels.node\.kubernetes\.io/instance-type}{"\n"}'
kubectl -n kube-system get ds | egrep -i "nvidia"
kubectl -n kube-system describe ds nvidia-device-plugin | sed -n '/Selector:/,/Events:/p'
kubectl -n kube-system get ds nvidia-device-plugin -o yaml | sed -n '/nodeSelector:/,/tolerations:/p'
kubectl -n kube-system patch ds nvidia-device-plugin --type='json' -p='[
  {"op":"remove","path":"/spec/template/spec/nodeSelector"}
]'
kubectl -n kube-system patch ds nvidia-device-plugin --type='json' -p='[
  {"op":"add","path":"/spec/template/spec/tolerations","value":[
    {"key":"nvidia.com/gpu","operator":"Exists","effect":"NoSchedule"}
  ]}
]'
kubectl -n kube-system get pods -o wide | grep -i nvidia
kubectl describe node ip-192-168-125-158.ec2.internal | egrep -i "nvidia.com/gpu|Capacity|Allocatable" -n
kubectl -n kube-system get ds nvidia-device-plugin -o yaml | sed -n '/template:/,/status:/p' | egrep -n "affinity|nodeAffinity|matchExpressions|nodeSelectorTerms|nodeSelector|tolerations|runtimeClassName"
kubectl -n kube-system patch ds nvidia-device-plugin --type='json' -p='[
  {"op":"remove","path":"/spec/template/spec/affinity"}
]'
kubectl -n kube-system get ds nvidia-device-plugin
kubectl -n kube-system get pods -o wide | grep -i nvidia
kubectl describe node ip-192-168-125-158.ec2.internal | egrep -i "nvidia.com/gpu|Capacity|Allocatable" -n
kubectl get pod gpu-smoke -o wide
kubectl logs gpu-smoke
kubectl delete pod gpu-smoke --ignore-not-found
rm -f gpu-smoke-test.yaml
kubectl create ns gpu-jobs --dry-run=client -o yaml | kubectl apply -f -
cat > gpu-job-template.yaml <<'EOF'
apiVersion: batch/v1
kind: Job
metadata:
  name: gpu-job-template
  namespace: gpu-jobs
  labels:
    app: gpu-job
spec:
  backoffLimit: 0
  ttlSecondsAfterFinished: 120
  template:
    metadata:
      labels:
        app: gpu-job
    spec:
      restartPolicy: Never
      tolerations:
        - key: "nvidia.com/gpu"
          operator: "Equal"
          value: "true"
          effect: "NoSchedule"
      containers:
        - name: cuda-check
          image: nvidia/cuda:12.2.0-base-ubuntu22.04
          command: ["bash","-lc"]
          args:
            - |
              echo "Node: $(uname -n)"
              echo "Time: $(date -Is)"
              nvidia-smi
              echo "GPU job completed."
          resources:
            limits:
              nvidia.com/gpu: 1
              cpu: "500m"
              memory: "512Mi"
            requests:
              cpu: "200m"
              memory: "256Mi"
EOF

kubectl apply -f gpu-job-template.yaml
kubectl -n gpu-jobs get pods -w
kubectl -n gpu-jobs describe pod gpu-job-template-mdltt | sed -n '/Events:/,$p'
kubectl get nodes -o wide
kubectl describe node ip-192-168-125-158.ec2.internal | egrep -n "Taints:|nvidia.com/gpu|Capacity:|Allocatable:"
kubectl get pods -A -o wide | grep ip-192-168-125-158.ec2.internal
kubectl describe node ip-192-168-125-158.ec2.internal | sed -n '/Non-terminated Pods:/,/Allocated resources:/p'
kubectl describe node ip-192-168-118-26.ec2.internal | egrep -n "node.kubernetes.io/instance-type|Taints:|nvidia.com/gpu|Capacity:|Allocatable:"
kubectl get node ip-192-168-118-26.ec2.internal -L node.kubernetes.io/instance-type -o wide
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
kubectl get nodes -o wide | awk 'NR==1 || $6=="192.168.118.26"'
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.nvidia\.com/gpu}{"\n"}{end}'
NODE=<paste-node-name-here>
kubectl describe node "$NODE" | egrep -n "node.kubernetes.io/instance-type|Taints:|nvidia.com/gpu|Capacity:|Allocatable:"
kubectl get node "$NODE" -L node.kubernetes.io/instance-type -o wide
kubectl config current-context
kubectl cluster-info
aws ec2 describe-instances   --filters "Name=private-ip-address,Values=192.168.118.26"   --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,PrivateIP:PrivateIpAddress,LaunchTime:LaunchTime,Tags:Tags}"   --output table
kubectl -n gpu-jobs get pod gpu-job-template-mdltt -o wide
kubectl -n gpu-jobs describe pod gpu-job-template-mdltt | sed -n '/Events:/,$p'
kubectl -n karpenter logs deployment/karpenter --since=30m | egrep -i "terminate|deprovision|disruption|consolidat|empty|expired|ttl|finaliz|nodeclaim|nodepool|spot|drift|unhealthy|taint"
kubectl get nodeclaim
kubectl describe nodeclaim <nodeclaim-name>
kubectl get nodepool
kubectl describe nodepool gpu-on-demand
kubectl -n gpu-jobs get deploy
kubectl -n gpu-jobs get job
kubectl -n gpu-jobs get pods -o wide
kubectl -n gpu-jobs get pod <some-pod> -o jsonpath='{.metadata.ownerReferences[0].kind}{" "}{.metadata.ownerReferences[0].name}{"\n"}'
/bin/bash -lc "nvidia-smi && sleep 3600"
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-sleeper
  namespace: gpu-jobs
spec:
  restartPolicy: Never
  containers:
  - name: cuda
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["/bin/bash","-lc"]
    args:
      - |
        echo "Node:" $(hostname)
        nvidia-smi || true
        sleep 3600
    resources:
      limits:
        nvidia.com/gpu: "1"
YAML

kubectl -n gpu-jobs get pod gpu-sleeper -w
kubectl -n gpu-jobs get pod gpu-sleeper -o wide
kubectl -n gpu-jobs get pod gpu-sleeper -w
kubectl -n gpu-jobs describe pod gpu-sleeper | sed -n '/Events:/,$p'
kubectl get nodes -o wide
kubectl describe node ip-192-168-17-101.ec2.internal | sed -n '/Conditions:/,/Allocated resources:/p'
kubectl describe node ip-192-168-17-101.ec2.internal | egrep -n "Taints:|Ready|nvidia.com/gpu|Capacity:|Allocatable:|Instance Type|Labels:"
kubectl -n karpenter logs deployment/karpenter --since=10m | tail -n 200
kubectl -n kube-system get ds | egrep -i "nvidia|gpu|device"
kubectl -n kube-system get pods -o wide | egrep -i "nvidia|gpu|device"
kubectl -n kube-system get pods -o wide --field-selector spec.nodeName=ip-192-168-17-101.ec2.internal
kubectl describe node ip-192-168-17-101.ec2.internal | egrep -n "Ready|NetworkUnavailable|DiskPressure|MemoryPressure|PIDPressure|KubeletReady|Taints:|LastHeartbeatTime|LastTransitionTime|Message"
kubectl -n gpu-jobs patch pod gpu-sleeper --type='json' -p='[
  {"op":"add","path":"/spec/tolerations","value":[
    {"key":"nvidia.com/gpu","operator":"Equal","value":"true","effect":"NoSchedule"}
  ]}
]'
kubectl -n gpu-jobs get pod gpu-sleeper -w
kubectl -n gpu-jobs get pod gpu-sleeper -o wide
kubectl -n gpu-jobs delete pod gpu-sleeper --ignore-not-found
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-sleeper
  namespace: gpu-jobs
spec:
  restartPolicy: Never
  tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  containers:
  - name: cuda
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["/bin/bash","-lc"]
    args:
      - |
        echo "Node:" $(hostname)
        nvidia-smi
        sleep 3600
    resources:
      limits:
        nvidia.com/gpu: "1"
YAML

kubectl -n gpu-jobs get pod gpu-sleeper -o wide
kubectl -n gpu-jobs describe pod gpu-sleeper | sed -n '/Events:/,$p'
kubectl -n gpu-jobs delete pod gpu-sleeper --grace-period=0 --force
kubectl -n gpu-jobs get pod gpu-sleeper
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-sleeper
  namespace: gpu-jobs
spec:
  restartPolicy: Never
  tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  containers:
  - name: cuda
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["/bin/bash","-lc"]
    args:
      - |
        echo "Node:" $(hostname)
        nvidia-smi || true
        sleep 3600
    resources:
      limits:
        nvidia.com/gpu: "1"
YAML

kubectl -n gpu-jobs get pod gpu-sleeper -w
kubectl -n gpu-jobs describe pod gpu-sleeper | sed -n '/Events:/,$p'
kubectl get nodes -o wide
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.nvidia\.com/gpu}{"\n"}{end}'
kubectl -n gpu-jobs get pod gpu-sleeper -o jsonpath='{.spec.tolerations}{"\n"}'
NODE=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.nvidia\.com/gpu}{"\n"}{end}' | awk '$2!="" && $2!="0"{print $1; exit}')
echo $NODE
kubectl get pods -A -o wide --field-selector spec.nodeName=$NODE
kubectl describe node $NODE | egrep -n "Taints:|nvidia.com/gpu|Allocated resources:"
kubectl -n gpu-jobs logs gpu-sleeper --tail=50
kubectl -n gpu-jobs exec -it gpu-sleeper -- /bin/bash -lc 'nvidia-smi'
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-node-keeper
  namespace: gpu-jobs
spec:
  restartPolicy: Always
  tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: "nvidia.com/gpu"
            operator: Exists
  containers:
  - name: pause
    image: public.ecr.aws/eks-distro/kubernetes/pause:3.9
YAML

kubectl -n gpu-jobs logs gpu-sleeper --tail=50
GPU_NODE=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.nvidia\.com/gpu}{"\n"}{end}' | awk '$2!="" && $2!="0"{print $1; exit}')
kubectl get node $GPU_NODE --show-labels | tr ',' '\n' | egrep -i 'instance-type|karpenter|nodegroup|eks|accelerator|gpu'
nodeSelector:
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-node-keeper
  namespace: gpu-jobs
spec:
  restartPolicy: Always
  nodeSelector:
    workload: gpu
  tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  containers:
  - name: pause
    image: public.ecr.aws/eks-distro/kubernetes/pause:3.9
    resources:
      requests:
        cpu: 5m
        memory: 16Mi
      limits:
        cpu: 50m
        memory: 64Mi
YAML

kubectl -n gpu-jobs get pod gpu-node-keeper -o wide
kubectl -n gpu-jobs delete pod gpu-node-keeper --grace-period=0 --force --ignore-not-found
kubectl -n gpu-jobs wait --for=delete pod/gpu-node-keeper --timeout=60s 2>/dev/null || true
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-node-keeper
  namespace: gpu-jobs
spec:
  restartPolicy: Always
  nodeSelector:
    workload: gpu
  tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  containers:
  - name: pause
    image: public.ecr.aws/eks-distro/kubernetes/pause:3.9
    resources:
      requests:
        cpu: 5m
        memory: 16Mi
      limits:
        cpu: 50m
        memory: 64Mi
YAML

kubectl -n gpu-jobs get pod gpu-node-keeper -w
kubectl -n gpu-jobs get pod gpu-node-keeper -o wide
kubectl get node -L workload -L node.kubernetes.io/instance-type | egrep -i "workload|gpu|g4dn|g5|p|trn"
kubectl -n karpenter logs deployment/karpenter --since=15m | egrep -i "consolidat|disrupt|terminat|delete|empty"
kubectl -n gpu-jobs get pod gpu-node-keeper -o wide
kubectl get nodes -o wide | egrep -i "g4dn|gpu|karpenter"
kubectl -n karpenter get deploy karpenter -o=jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n karpenter get pods -o wide
kubectl get nodepool -A -o yaml | sed -n '1,200p'
kubectl get ec2nodeclass -A -o yaml | sed -n '1,220p'
kubectl get provisioner -A -o yaml
kubectl get awsnodetemplate -A -o yaml
{   "Version": "2012-10-17",;   "Statement": [;     {       "Sid": "KarpenterLaunchTemplateCleanup",;       "Effect": "Allow",;       "Action": [;         "ec2:DeleteLaunchTemplate",;         "ec2:DeleteLaunchTemplateVersions";       ],;       "Resource": "*";     };   ]; }
kubectl -n karpenter get sa karpenter -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}{"\n"}'
kubectl get pdb -A
kubectl get pdb -A -o yaml | head -n 40
apiVersion: policy/v1
kind: PodDisruptionBudget
cat <<'YAML' | kubectl apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: gpu-node-keeper-pdb
  namespace: gpu-jobs
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: gpu-node-keeper
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpu-node-keeper
  namespace: gpu-jobs
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gpu-node-keeper
  template:
    metadata:
      labels:
        app: gpu-node-keeper
    spec:
      nodeSelector:
        workload: gpu
      tolerations:
      - key: "nvidia.com/gpu"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      containers:
      - name: pause
        image: public.ecr.aws/eks-distro/kubernetes/pause:3.9
        resources:
          requests:
            cpu: 5m
            memory: 16Mi
          limits:
            cpu: 50m
            memory: 64Mi
YAML

kubectl -n gpu-jobs delete pod gpu-node-keeper --ignore-not-found
kubectl -n gpu-jobs get deploy,pod -o wide | egrep -i "gpu-node-keeper|NAME"
kubectl -n karpenter get deploy karpenter -o=jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n karpenter get sa karpenter -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}{"\n"}'
cat > karpenter-lt-cleanup.json <<'JSON'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KarpenterLaunchTemplateCleanup",
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteLaunchTemplate",
        "ec2:DeleteLaunchTemplateVersions",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*"
    }
  ]
}
JSON

aws iam put-role-policy   --role-name eksctl-ai-eks-addon-iamserviceaccount-karpent-Role1-VZ8WtR4PdoTq   --policy-name KarpenterLaunchTemplateCleanup   --policy-document file://karpenter-lt-cleanup.json
kubectl -n karpenter rollout restart deployment/karpenter
kubectl -n karpenter logs deployment/karpenter --since=5m | egrep -i "launchtemplate|unauthorized|delete"
kubectl -n gpu-jobs describe pdb gpu-node-keeper-pdb
kubectl -n gpu-jobs get pods -l app=gpu-node-keeper -o wide
helm list -n karpenter
kubectl -n karpenter get deploy karpenter -o=jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl api-resources | egrep -i 'nodepool|ec2nodeclass|nodeclaim'
kubectl get nodepool -A
kubectl get ec2nodeclass -A
kubectl -n gpu-jobs describe pdb gpu-node-keeper-pdb
kubectl -n gpu-jobs get pods -l app=gpu-node-keeper
kubectl -n karpenter logs deployment/karpenter --since=15m | egrep -i "unauthorized|deletelaunchtemplate|launch template"
aws ec2 describe-launch-templates   --region us-east-1   --filters "Name=tag:karpenter.k8s.aws/cluster,Values=ai-eks"   --query "LaunchTemplates[].{Id:LaunchTemplateId,Name:LaunchTemplateName,Created:CreateTime}"   --output table
kubectl get crd | egrep -i 'karpenter|nodepool|nodeclaim|ec2nodeclass|provisioner|awsnodetemplate'
helm get values -n karpenter karpenter -a
kubectl get provisioner -o yaml > provisioners.backup.yaml
kubectl get awsnodetemplate -o yaml > awsnodetemplates.backup.yaml
kubectl -n karpenter get all -o yaml > karpenter.ns.backup.yaml
kubectl api-resources | egrep -i 'nodepool|nodeclaim|ec2nodeclass'
kubectl get nodepool -A
kubectl get ec2nodeclass -A
kubectl api-resources | egrep -i 'nodepool|nodeclaim|ec2nodeclass'
kubectl get nodepool -A
kubectl get ec2nodeclass -A
helm get values -n karpenter karpenter -
kubectl -n gpu-jobs get pod -l app=gpu-node-keeper --show-labels
kubectl -n gpu-jobs describe pdb gpu-node-keeper-pdb
helm uninstall karpenter -n karpenter
kubectl delete crd provisioners.karpenter.sh awsnodetemplates.karpenter.k8s.aws
export CLUSTER_NAME=ai-eks
export AWS_REGION=us-east-1
export KARPENTER_NAMESPACE=karpenter
export KARPENTER_IAM_ROLE_ARN=arn:aws:iam::344322112774:role/eksctl-ai-eks-addon-iamserviceaccount-karpent-Role1-VZ8WtR4PdoTq
# CRDs
helm upgrade --install karpenter-crd oci://public.ecr.aws/karpenter/karpenter-crd   --version 1.8.0   -n ${KARPENTER_NAMESPACE} --create-namespace
# Controller
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter   --version 1.8.0   -n ${KARPENTER_NAMESPACE}   --set serviceAccount.name=karpenter   --set serviceAccount.create=false   --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN}   --set settings.clusterName=${CLUSTER_NAME}   --set settings.clusterEndpoint=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query "cluster.endpoint" --output text)
kubectl api-resources | egrep -i 'nodepool|nodeclaim|ec2nodeclass'
kubectl get nodepool -A
kubectl get ec2nodeclass -A
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
spec:
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
spec:
kubectl apply -f gpu-ec2nodeclass.yaml
kubectl apply -f gpu-nodepool.yaml
kubectl api-resources | egrep -i 'nodepool|nodeclaim|ec2nodeclass'
kubectl get ec2nodeclass
kubectl get nodepool
kubectl -n karpenter logs deploy/karpenter --since=10m | egrep -i "error|unauthorized|capacity-block|pdb"
kubectl get nodes -L workload -L node.kubernetes.io/instance-type
cat > gpu-ec2nodeclass.yaml <<'YAML'
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: gpu-default
spec:
  amiFamily: AL2
  amiSelectorTerms:
    - id: ami-016835d5e961b0712
  role: KarpenterNodeRole-ai-eks
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ai-eks
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ai-eks
  tags:
    karpenter.sh/discovery: ai-eks
    workload: gpu
YAML

cat > gpu-nodepool.yaml <<'YAML'
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: gpu-on-demand
spec:
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 30s
  limits:
    cpu: "64"
  template:
    metadata:
      labels:
        workload: gpu
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: gpu-default
      taints:
        - key: nvidia.com/gpu
          value: "true"
          effect: NoSchedule
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["g4dn.xlarge","g4dn.2xlarge","g4dn.4xlarge","g5.xlarge","g5.2xlarge","g5.4xlarge"]
YAML

kubectl apply -f gpu-ec2nodeclass.yaml
kubectl apply -f gpu-nodepool.yaml
kubectl apply -f gpu-ec2nodeclass.yaml
kubectl apply -f gpu-nodepool.yaml
kubectl get ec2nodeclass
kubectl get nodepool
kubectl -n karpenter logs deploy/karpenter --since=10m --tail=200
kubectl -n gpu-jobs get pod -l app=gpu-node-keeper
kubectl -n gpu-jobs describe pdb gpu-node-keeper-pdb | sed -n '/Status:/,$p'
kubectl get ec2nodeclass -o yaml
kubectl get nodepool -o yaml
kubectl -n karpenter logs deploy/karpenter --since=10m --tail=200
# show container args + env (this usually reveals it immediately)
kubectl -n karpenter get deploy karpenter -o yaml | egrep -n "feature|gate|StaticCapacity|FEATURE|env:|args:" -n
# show just env in a clean view
kubectl -n karpenter get deploy karpenter -o jsonpath='{range .spec.template.spec.containers[0].env[*]}{.name}={.value}{"\n"}{end}' | egrep -i "FEATURE|GATE|STATIC"
kubectl -n karpenter set env deploy/karpenter FEATURE_GATES-
kubectl -n karpenter rollout restart deploy/karpenter
kubectl -n karpenter get pods -w
kubectl -n karpenter logs deploy/karpenter --tail=80
kubectl -n karpenter get deploy karpenter -o jsonpath='{.spec.template.spec.containers[0].args}{"\n"}'
kubectl get nodepool
kubectl get ec2nodeclass
kubectl -n karpenter logs deploy/karpenter --since=5m | egrep -i "nodepool|nodeclass|reconcil|error|AccessDenied"
kubectl -n karpenter get deploy karpenter -o jsonpath='{.spec.template.spec.containers[0].env}{"\n"}'
kubectl -n karpenter get deploy karpenter -o jsonpath='{.spec.template.spec.containers[0].args}{"\n"}'
subnetSelectorTerms:
securityGroupSelectorTerms:
subnetSelectorTerms:
securityGroupSelectorTerms:
# Get the cluster VPC ID
VPC_ID=$(aws eks describe-cluster --name ai-eks --region us-east-1 --query "cluster.resourcesVpcConfig.vpcId" --output text)
echo $VPC_ID
# Tag ALL subnets in that VPC (adjust if you only want private subnets)
for s in $(aws ec2 describe-subnets --region us-east-1 --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[].SubnetId" --output text); do   aws ec2 create-tags --region us-east-1 --resources $s --tags Key=karpenter.sh/discovery,Value=ai-eks; done
# Tag the primary EKS cluster security group (the one EKS created)
CLUSTER_SG=$(aws eks describe-cluster --name ai-eks --region us-east-1 --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)
aws ec2 create-tags --region us-east-1 --resources $CLUSTER_SG --tags Key=karpenter.sh/discovery,Value=ai-eks
kubectl -n karpenter rollout restart deploy/karpenter
cat > karpenter-instanceprofile.json <<'JSON'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KarpenterInstanceProfileRead",
      "Effect": "Allow",
      "Action": [
        "iam:ListInstanceProfiles",
        "iam:GetInstanceProfile",
        "iam:ListInstanceProfileTags"
      ],
      "Resource": "*"
    },
    {
      "Sid": "KarpenterInstanceProfileWrite",
      "Effect": "Allow",
      "Action": [
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:TagInstanceProfile",
        "iam:UntagInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile"
      ],
      "Resource": "*"
    }
  ]
}
JSON

aws iam put-role-policy   --role-name eksctl-ai-eks-addon-iamserviceaccount-karpent-Role1-VZ8WtR4PdoTq   --policy-name KarpenterInstanceProfileAccess   --policy-document file://karpenter-instanceprofile.json
kubectl -n karpenter rollout restart deploy/karpenter
kubectl -n karpenter logs deploy/karpenter --since=5m | egrep -i "AccessDenied|instanceprofile|no subnets found|nodeclass"
kubectl get ec2nodeclass
kubectl get nodepool
kubectl describe ec2nodeclass gpu-default | sed -n '/Status:/,$p'
kubectl describe nodepool gpu-on-demand | sed -n '/Status:/,$p'
cat > gpu-smoke.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: gpu-smoke
  namespace: gpu-jobs
spec:
  restartPolicy: Never
  tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  nodeSelector:
    workload: gpu
  containers:
  - name: sleep
    image: public.ecr.aws/docker/library/busybox:1.36
    command: ["sh","-c","echo hello && sleep 3600"]
    resources:
      limits:
        nvidia.com/gpu: 1
YAML

kubectl apply -f gpu-smoke.yaml
kubectl -n gpu-jobs describe pod gpu-smoke | sed -n '/Events:/,$p'
kubectl get nodeclaim -A
helm get values -n karpenter karpenter -a | egrep -i "feature|gate"
# ServiceAccount should show eks.amazonaws.com/role-arn
kubectl -n karpenter get sa karpenter -o yaml | egrep -i "role-arn|eks.amazonaws.com"
# Also confirm the actual pod is using that SA
kubectl -n karpenter get pod -l app.kubernetes.io/name=karpenter -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.serviceAccountName}{"\n"}{end}'
ROLE_NAME="eksctl-ai-eks-addon-iamserviceaccount-karpent-Role1-VZ8WtR4PdoTq"
aws iam list-role-policies --role-name "$ROLE_NAME"
aws iam get-role-policy --role-name "$ROLE_NAME" --policy-name KarpenterInstanceProfileAccess
aws iam get-role --role-name "$ROLE_NAME" --query 'Role.PermissionsBoundary' --output json
IP_NAME="ai-eks-karpenter-nodes"
NODE_ROLE="KarpenterNodeRole-ai-eks"
aws iam create-instance-profile --instance-profile-name "$IP_NAME" || true
aws iam add-role-to-instance-profile --instance-profile-name "$IP_NAME" --role-name "$NODE_ROLE" || true
kubectl explain ec2nodeclass.spec | egrep -i "instanceprofile|role"
kubectl get ec2nodeclass gpu-default -o yaml | egrep -i "instanceProfile|role"
kubectl get ec2nodeclass gpu-default -o yaml | sed -n '/status:/,$p'
kubectl get nodepool gpu-on-demand -o yaml | sed -n '/status:/,$p'
kubectl -n karpenter logs deploy/karpenter --since=3m | egrep -i "instanceprofile|nodeclaim|launch|error|AccessDenied"
kubectl -n karpenter get sa karpenter -o yaml | egrep -i "role-arn|eks.amazonaws.com"
aws iam list-role-policies --role-name eksctl-ai-eks-addon-iamserviceaccount-karpent-Role1-VZ8WtR4PdoTq
# show the nodes Karpenter created for this NodePool
kubectl get nodes -L karpenter.sh/nodepool,workload,nvidia.com/gpu
# label all nodes created by the gpu-on-demand NodePool
for n in $(kubectl get nodes -l karpenter.sh/nodepool=gpu-on-demand -o name); do   kubectl label $n workload=gpu --overwrite; done
# confirm the labels are there
kubectl get nodes -l karpenter.sh/nodepool=gpu-on-demand -L workload,nvidia.com/gpu
kubectl -n gpu-jobs delete pod gpu-smoke --ignore-not-found
kubectl apply -f gpu-smoke.yaml
kubectl -n gpu-jobs get pod gpu-smoke -w
kubectl -n gpu-jobs delete pod gpu-smoke --ignore-not-found
kubectl delete nodepool gpu-on-demand
kubectl delete nodeclaim -A --all
kubectl get nodeclaim -A
kubectl get nodes -L karpenter.sh/nodepool,nvidia.com/gpu,workload
kubectl delete ec2nodeclass gpu-default
kubectl get ec2nodeclass
aws ec2 describe-instances   --region us-east-1   --filters "Name=tag:karpenter.sh/nodepool,Values=gpu-on-demand" "Name=instance-state-name,Values=pending,running,stopping,stopped"   --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,AZ:Placement.AvailabilityZone}"   --output table
kubectl get node ip-192-168-119-183.ec2.internal -o jsonpath='{.spec.providerID}{"\n"}'
aws ec2 terminate-instances --region us-east-1 --instance-ids i-xxxxxxxxxxxxxxxxx
kubectl get nodes
aws ec2 terminate-instances --region us-east-1 --instance-ids i-00bf671b0d96ad55f
aws ec2 describe-instances --region us-east-1 --instance-ids i-00bf671b0d96ad55f   --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType}" --output table
kubectl delete nodepool gpu-on-demand
kubectl get nodepool
kubectl delete nodeclaim gpu-on-demand-b79rn gpu-on-demand-czq4w
kubectl get nodeclaim -A
kubectl get node ip-192-168-83-196.ec2.internal  -o jsonpath='{.spec.providerID}{"\n"}'
kubectl get node ip-192-168-107-109.ec2.internal -o jsonpath='{.spec.providerID}{"\n"}'
aws ec2 terminate-instances --region us-east-1 --instance-ids i-REPLACE1 i-REPLACE2
kubectl get ec2nodeclass
aws ec2 describe-instances --region us-east-1   --filters "Name=instance-state-name,Values=pending,running,stopping,stopped"   --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name'].Value|[0]}"   --output table
aws ec2 terminate-instances --region us-east-1 --instance-ids i-00bf671b0d96ad55f
kubectl get node ip-192-168-83-196.ec2.internal  -o jsonpath='{.spec.providerID}{"\n"}'
kubectl get node ip-192-168-107-109.ec2.internal -o jsonpath='{.spec.providerID}{"\n"}'
kubectl get nodeclaim -A
aws ec2 describe-instances --region us-east-1   --filters "Name=instance-state-name,Values=pending,running,stopping,stopped"             "Name=instance-type,Values=g4dn.*,g5.*,p3.*,p4d.*,p4de.*,p5.*"   --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,AZ:Placement.AvailabilityZone}"   --output table
kubectl get nodepool
kubectl -n gpu-jobs delete pod gpu-smoke --ignore-not-found
aws eks list-nodegroups --region us-east-1 --cluster-name ai-eks
aws eks update-nodegroup-config --region us-east-1 --cluster-name ai-eks   --nodegroup-name NODEGROUP_NAME   --scaling-config minSize=0,maxSize=0,desiredSize=0
aws eks update-nodegroup-config --region us-east-1 --cluster-name ai-eks   --nodegroup-name admin-ng   --scaling-config minSize=0,maxSize=1,desiredSize=0
aws eks describe-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ng   --query "nodegroup.status" --output text
kubectl get nodes
aws eks delete-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ng
aws eks delete-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ngaws eks delete-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ngkkkkklkaws eks list-nodegroups --region us-east-1 --cluster-name ai-eks
kubectl get secret -n storage minio -o jsonpath="{.data.root-user}" | base64 -d
kubectl get secret -n storage minio -o jsonpath="{.data.root-password}" | base64 -d
kubectl get pods -A | grep -i minio
kubectl get svc -A | grep -i minio
helm ls -A | grep -i minio
kubectl get secrets -n storage | grep -i minio
kubectl get secret -n storage <SECRET_NAME> -o jsonpath="{.data.root-user}" | base64 -d; echo
kubectl get secret -n storage <SECRET_NAME> -o jsonpath="{.data.root-password}" | base64 -d; echo
kubectl get secret -n storage Opaque -o jsonpath="{.data.root-user}" | base64 -d; echo
kubectl get secret -n storage Opaque -o jsonpath="{.data.root-password}" | base64 -d; echo
kubectl get secret -n storage minio-creds -o jsonpath="{.data.root-user}" | base64 -d; echo
kubectl get secret -n storage minio-creds -o jsonpath="{.data.root-password}" | base64 -d; echo
kubectl get secret -n storage minio-creds -o jsonpath="{.data.root-user}" | base64 -d; echo
kubectl get secret -n storage minio-creds -o jsonpath="{.data.root-password}" | base64 -d; echo
kubectl get secret -n storage minio-creds -o jsonpath='{.data}' ; echo
kubectl get secret -n storage minio-creds -o jsonpath='{.data}' | tr ',' '\n' | tr -d '{}"' ; echo
kubectl get secret -n storage minio-creds -o jsonpath='{.data.MINIO_ROOT_USER}' | base64 -d; echo
kubectl get secret -n storage minio-creds -o jsonpath='{.data.MINIO_ROOT_PASSWORD}' | base64 -d; echo
cat > input.csv << 'EOF'
id,value
1,10
2,20
3,
4,40
EOF

ls
mkdir -p app/preprocess
cat > app/preprocess/main.py << 'EOF'
import os
import pandas as pd
import boto3

S3_ENDPOINT = os.getenv("S3_ENDPOINT", "http://minio.storage.svc.cluster.local:9000")
S3_ACCESS_KEY = os.getenv("S3_ACCESS_KEY", "minioadmin")
S3_SECRET_KEY = os.getenv("S3_SECRET_KEY", "minioadmin")

RAW_BUCKET = os.getenv("RAW_BUCKET", "raw-data")
RAW_KEY = os.getenv("RAW_KEY", "input.csv")
OUT_BUCKET = os.getenv("OUT_BUCKET", "processed-data")
OUT_KEY = os.getenv("OUT_KEY", "clean.csv")

s3 = boto3.client(
    "s3",
    endpoint_url=S3_ENDPOINT,
    aws_access_key_id=S3_ACCESS_KEY,
    aws_secret_access_key=S3_SECRET_KEY,
)

def main():
    obj = s3.get_object(Bucket=RAW_BUCKET, Key=RAW_KEY)
    df = pd.read_csv(obj["Body"])

    df_clean = df.dropna()
    s3.put_object(
        Bucket=OUT_BUCKET,
        Key=OUT_KEY,
        Body=df_clean.to_csv(index=False).encode("utf-8"),
        ContentType="text/csv",
    )

    print(f"Wrote s3://{OUT_BUCKET}/{OUT_KEY} rows={len(df_clean)}")

if __name__ == "__main__":
    main()
EOF

cat > app/preprocess/Dockerfile << 'EOF'
FROM python:3.11-slim
RUN pip install --no-cache-dir pandas boto3
WORKDIR /app
COPY main.py /app/main.py
CMD ["python", "/app/main.py"]
EOF

docker build -t preprocess:local app/preprocess
kind load docker-image preprocess:local --name ai-lab
mkdir -p k8s/apps
cat > k8s/apps/preprocess-job.yaml << 'EOF'
apiVersion: batch/v1
kind: Job
metadata:
  name: preprocess-job
  namespace: storage
spec:
  backoffLimit: 1
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: preprocess
          image: preprocess:local
          env:
            - name: S3_ENDPOINT
              value: "http://minio.storage.svc.cluster.local:9000"
            - name: S3_ACCESS_KEY
              value: "minioadmin"
            - name: S3_SECRET_KEY
              value: "minioadmin"
            - name: RAW_BUCKET
              value: "raw-data"
            - name: RAW_KEY
              value: "input.csv"
            - name: OUT_BUCKET
              value: "processed-data"
            - name: OUT_KEY
              value: "clean.csv"
EOF

kubectl apply -f k8s/apps/preprocess-job.yaml
kubectl get jobs -n storage
kubectl logs -n storage job/preprocess-job
git add .
git commit -m "Day 2: Object storage and Kubernetes preprocessing pipeline"
mkdir -p app/inference
cat > app/inference/main.py << 'EOF'
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Inference API", version="1.0")

class InferenceRequest(BaseModel):
    values: list[float]

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/infer")
def infer(req: InferenceRequest):
    return {
        "prediction": sum(req.values),
        "count": len(req.values)
    }
EOF

cat > app/inference/requirements.txt << 'EOF'
fastapi==0.115.0
uvicorn[standard]==0.30.6
pydantic==2.8.2
EOF

cat > app/inference/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
EOF

docker build -t inference:local app/inference
kind load docker-image inference:local --name ai-lab
cat > k8s/apps/inference.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inference
  namespace: storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: inference
  template:
    metadata:
      labels:
        app: inference
    spec:
      containers:
        - name: inference
          image: inference:local
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 3
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: inference
  namespace: storage
spec:
  selector:
    app: inference
  ports:
    - port: 8080
      targetPort: 8080
EOF

kubectl apply -f k8s/apps/inference.yaml
kubectl get pods -n storage
kubectl port-forward -n storage svc/inference 8080:8080
aws eks update-nodegroup-config --region us-east-1 --cluster-name ai-eks   --nodegroup-name admin-ng   --scaling-config minSize=0,maxSize=1,desiredSize=0
aws eks describe-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ng   --query "nodegroup.status" --output text
kubectl get nodes
aws eks delete-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ng
curl -s http://127.0.0.1:8080/health
curl -s -X POST http://127.0.0.1:8080/infer   -H "Content-Type: application/json"   -d '{"values":[1,2,3,4.5]}'
ls
git add .
git commit -m "Day 3: FastAPI inference service deployed to Kubernetes"
gcloud --version || echo "gcloud not installed"
gcloud init
gcloud --help
gcloud auth login
gcloud config set project nth-baton-205216
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
gcloud config set project nth-baton-205216
gcloud config set compute/zone us-central1-a
gcloud config set compute/region us-central1
gcloud container clusters create ai-gke   --num-nodes=1   --machine-type=e2-standard-2   --enable-ip-alias   --release-channel=regular
gcloud auth login
gcloud container clusters create ai-gke   --num-nodes=1   --machine-type=e2-standard-2   --enable-ip-alias   --release-channel=regular
gcloud config set project nth-baton-205216
gcloud container clusters describe ai-gke --zone us-central1-a --format="value(status)"
gcloud container clusters get-credentials ai-gke --zone us-central1-a
kubectl get nodes
kubectl get pods -A | head
lsb_release -a
sudo apt update
sudo apt install -y google-cloud-cli-gke-gcloud-auth-plugin
which gke-gcloud-auth-plugin
gke-gcloud-auth-plugin --version
sudo apt update
sudo apt install -y apt-transport-https ca-certificates gnupg curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update
sudo apt install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
which gke-gcloud-auth-plugin
gke-gcloud-auth-plugin --version
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> ~/.bashrc
gcloud config set project nth-baton-205216
gcloud container clusters get-credentials ai-gke --zone us-central1-a
gcloud components update
kubectl get nodes
gcloud container node-pools create gpu-spot   --cluster ai-gke   --zone us-central1-a   --accelerator type=nvidia-tesla-t4,count=1   --machine-type n1-standard-4   --spot   --num-nodes 0   --enable-autoscaling   --min-nodes 0   --max-nodes 2   --node-labels=gpu=true
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.15.0/nvidia-device-plugin.yml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.16.2/deployments/static/nvidia-device-plugin.yml
kubectl get pods -n kube-system | grep nvidia
kubectl get daemonset -n kube-system | grep nvidia
kubectl get pods -n kube-system | grep nvidia
kubectl get daemonset -n kube-system | grep nvidia
kubectl get pods -n kube-system | grep nvidia
kubectl get nodes
gcloud container node-pools create gpu-spot   --cluster ai-gke   --zone us-central1-a   --accelerator type=nvidia-tesla-t4,count=1   --machine-type n1-standard-4   --spot   --num-nodes 0   --enable-autoscaling --min-nodes 0 --max-nodes 1   --node-labels=gpu=true
cat > gpu-trigger.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: gpu-trigger
spec:
  restartPolicy: Never
  nodeSelector:
    gpu: "true"
  containers:
  - name: cuda
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["bash","-lc","nvidia-smi || true; sleep 60"]
    resources:
      limits:
        nvidia.com/gpu: 1
EOF

kubectl apply -f gpu-trigger.yaml
kubectl get pods -w
aws eks list-nodegroups --region us-east-1 --cluster-name ai-eks
aws eks delete-cluster --region us-east-1 --name ai-eks
aws eks describe-cluster --region us-east-1 --name ai-eks
[200~aws eks update-nodegroup-config --region us-east-1 --cluster-name ai-eks   --nodegroup-name admin-ng   --scaling-config minSize=0,maxSize=1,desiredSize=0
~aws eks update-nodegroup-config --region us-east-1 --cluster-name ai-eks   --nodegroup-name admin-ng   --scaling-config minSize=0,maxSize=1,desiredSize=0
aws eks update-nodegroup-config --region us-east-1 --cluster-name ai-eks   --nodegroup-name admin-ng   --scaling-config minSize=0,maxSize=1,desiredSize=0
aws eks delete-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ng
[200~aws eks describe-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ng   --query "nodegroup.status" --output text
aws eks describe-nodegroup --region us-east-1 --cluster-name ai-eks --nodegroup-name admin-ng   --query "nodegroup.status" --output text
