#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  setup-killercoda.sh — Preparación automatizada del entorno GitOps         ║
# ║                                                                            ║
# ║  Autor:   Jhon Edison Hincapie Garcia                                      ║
# ║  Módulo:  Maestría en Arquitectura de Software — Politécnico Grancolombiano║
# ║  Uso:     Ejecutar en la terminal de Killercoda (clúster Kubernetes real)   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Qué hace este script:
#   1. Instala Argo CD en el namespace "argocd"
#   2. Espera a que todos los Pods de Argo CD estén listos
#   3. Expone el servidor de Argo CD en NodePort 30007
#   4. Crea la Application de Argo CD apuntando al repositorio GitHub
#   5. Muestra las credenciales de acceso y los puertos de conexión

set -euo pipefail

# ── Colores para la salida ────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # Sin color

# ── Variables de configuración ────────────────────────────────────────────────
ARGOCD_NAMESPACE="argocd"
ARGOCD_NODEPORT=30007
APP_NODEPORT=32000
GITHUB_REPO="https://github.com/jhoney787813/gke-gitops-autotrust.git"
GITHUB_BRANCH="main"
MANIFEST_PATH="manifests"
ARGOCD_APP_NAME="autotrust-web"
ARGOCD_VERSION="v2.14.11"

# ══════════════════════════════════════════════════════════════════════════════
# PASO 1: Instalar Argo CD
# ══════════════════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  PASO 1/5 — Instalando Argo CD ${ARGOCD_VERSION}${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}\n"

kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n "${ARGOCD_NAMESPACE}" \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo -e "${GREEN}✔ Argo CD instalado en el namespace '${ARGOCD_NAMESPACE}'${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# PASO 2: Esperar a que los Pods estén listos
# ══════════════════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  PASO 2/5 — Esperando que Argo CD esté listo…${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}⏳ Esto puede tardar entre 1 y 3 minutos…${NC}"
kubectl wait --for=condition=available deployment/argocd-server \
  -n "${ARGOCD_NAMESPACE}" --timeout=300s

echo -e "${GREEN}✔ Argo CD Server está disponible${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# PASO 3: Exponer Argo CD en NodePort 30007
# ══════════════════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  PASO 3/5 — Exponiendo Argo CD en NodePort ${ARGOCD_NODEPORT}${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}\n"

kubectl patch svc argocd-server -n "${ARGOCD_NAMESPACE}" -p "{
  \"spec\": {
    \"type\": \"NodePort\",
    \"ports\": [
      {
        \"name\": \"http\",
        \"port\": 80,
        \"targetPort\": 8080,
        \"nodePort\": ${ARGOCD_NODEPORT},
        \"protocol\": \"TCP\"
      },
      {
        \"name\": \"https\",
        \"port\": 443,
        \"targetPort\": 8080,
        \"protocol\": \"TCP\"
      }
    ]
  }
}"

echo -e "${GREEN}✔ Argo CD accesible en el puerto ${ARGOCD_NODEPORT}${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# PASO 4: Obtener la contraseña inicial de Argo CD
# ══════════════════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  PASO 4/5 — Obteniendo credenciales de Argo CD${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}\n"

# Esperar a que el Secret esté disponible
echo -e "${YELLOW}⏳ Esperando el Secret de contraseña inicial…${NC}"
until kubectl get secret argocd-initial-admin-secret -n "${ARGOCD_NAMESPACE}" &>/dev/null; do
  sleep 2
done

ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret \
  -n "${ARGOCD_NAMESPACE}" \
  -o jsonpath='{.data.password}' | base64 -d)

echo -e "${GREEN}✔ Credenciales obtenidas${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# PASO 5: Crear la Application de Argo CD (GitOps)
# ══════════════════════════════════════════════════════════════════════════════
echo -e "\n${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  PASO 5/5 — Creando la Application '${ARGOCD_APP_NAME}'${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════${NC}\n"

kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${ARGOCD_APP_NAME}
  namespace: ${ARGOCD_NAMESPACE}
spec:
  project: default
  source:
    repoURL: "${GITHUB_REPO}"
    targetRevision: "${GITHUB_BRANCH}"
    path: "${MANIFEST_PATH}"
  destination:
    server: "https://kubernetes.default.svc"
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

echo -e "${GREEN}✔ Application '${ARGOCD_APP_NAME}' creada con auto-sync habilitado${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✅  ¡ENTORNO GitOps CONFIGURADO EXITOSAMENTE!         ${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Argo CD UI:${NC}"
echo -e "    URL:       ${CYAN}https://<KILLERCODA_HOST>:${ARGOCD_NODEPORT}${NC}"
echo -e "    Usuario:   ${YELLOW}admin${NC}"
echo -e "    Contraseña:${YELLOW} ${ARGOCD_PASSWORD}${NC}"
echo ""
echo -e "  ${BOLD}Aplicación Web:${NC}"
echo -e "    URL:       ${CYAN}http://<KILLERCODA_HOST>:${APP_NODEPORT}${NC}"
echo ""
echo -e "  ${BOLD}Repositorio GitOps (fuente de verdad):${NC}"
echo -e "    ${CYAN}${GITHUB_REPO}${NC}"
echo ""
echo -e "  ${BOLD}Verificación rápida:${NC}"
echo -e "    ${YELLOW}kubectl get pods -l app=static-web${NC}"
echo -e "    ${YELLOW}kubectl get svc static-web-service${NC}"
echo -e "    ${YELLOW}kubectl get applications -n ${ARGOCD_NAMESPACE}${NC}"
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════${NC}"
