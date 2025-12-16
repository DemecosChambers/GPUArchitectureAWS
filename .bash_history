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
