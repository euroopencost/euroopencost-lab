#!/bin/bash
set -e

# --- STYLING ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}###############################################${NC}"
echo -e "${BLUE}#        EURO OPEN COST LAB - BOOTSTRAP       #${NC}"
echo -e "${BLUE}#      The Founder Edition | Salad1n-Dev      #${NC}"
echo -e "${BLUE}###############################################${NC}"

# 1. KUBECONFIG CHECK
if [ -f "$HOME/.kube/config" ]; then
    echo -e "${GREEN}[OK]${NC} Kubeconfig gefunden. Verbindung wird geprüft..."
    export KUBECONFIG=$HOME/.kube/config
else
    echo -e "${YELLOW}[ERROR]${NC} Keine Kubeconfig unter ~/.kube/config! Abbruch."
    exit 1
fi

# Verbindungstest
kubectl get nodes > /dev/null 2>&1 || { echo -e "${YELLOW}Fehler:${NC} Cluster nicht erreichbar!"; exit 1; }

# 2. NAMESPACES
echo -e "\n${BLUE}>>> Phase 1: Namespaces erschaffen...${NC}"
for ns in traefik cert-manager adguard argocd; do
    kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
done

# 3. HELM REPOS
echo -e "\n${BLUE}>>> Phase 2: Helm Charts laden...${NC}"
helm repo add traefik https://traefik.github.io/charts
helm repo add jetstack https://charts.jetstack.io
helm repo update

# 4. CORE INFRASTRUCTURE
echo -e "\n${BLUE}>>> Phase 3: Deploying Gatekeeper (Traefik)${NC}"
# Wir verzichten komplett auf --values, um Schema-Konflikte zu vermeiden
helm upgrade --install traefik traefik/traefik \
  --namespace traefik \
  --set service.spec.loadBalancerIP=192.168.10.50 \
  --set rbac.enabled=true

echo -e "\n${BLUE}>>> Phase 4: Deploying SSL-Power (Cert-Manager)${NC}"
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true

# 5. CLOUDFLARE SECRETS
echo -e "\n${BLUE}>>> Phase 5: Cloudflare API Integration${NC}"
CF_TOKEN=$(grep 'cloudflare_token' globals.yaml | awk '{print $2}' | tr -d '"' | tr -d '[:space:]')

if [ -z "$CF_TOKEN" ]; then
    echo -e "${YELLOW}WARNUNG:${NC} Kein cloudflare_token in globals.yaml gefunden!"
else
    kubectl create secret generic cloudflare-api-token \
      --from-literal=api-token="$CF_TOKEN" \
      --namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -
    echo -e "${GREEN}[OK]${NC} Cloudflare Secret injiziert."
fi

# 6. ARGOCD BOOTSTRAP
echo -e "\n${BLUE}>>> Phase 6: ArgoCD GitOps Engine starten...${NC}"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "\n${GREEN}##################################################${NC}"
echo -e "${GREEN}#    BASE READY. TIME TO BUILD THE IMPERIUM!     #${NC}"
echo -e "${GREEN}##################################################${NC}"
echo -e "ArgoCD Passwort kommt gleich..."
sleep 5
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo