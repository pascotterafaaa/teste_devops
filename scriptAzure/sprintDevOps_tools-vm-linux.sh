#!/usr/bin/env bash
# =============================================================================
#  sprintDevOps_tools-vm-linux.sh — Rodar direto no Azure Cloud Shell
#  Instala ferramentas na VM sprintDevOps
# =============================================================================
set -euo pipefail

# Configuracoes
RESOURCE_GROUP="sprintDevOps"
VM_NAME="sprintDevOps"
ADMIN_USER="admlnx"
ADMIN_PASS='Fiap@2tdsvms'

echo "Iniciando instalacao de ferramentas na VM $VM_NAME..."

echo "Instalando tree..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    sudo dnf install -y tree
  "

echo "Atualizando pacotes e instalando Git, nano e yum-utils..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    sudo dnf update -y
    sudo dnf install -y git nano yum-utils
  "

echo "Instalando Azure CLI..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf install -y https://packages.microsoft.com/config/rhel/10/packages-microsoft-prod.rpm
    sudo dnf install -y azure-cli
  "

echo "Instalando Docker..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  "

echo "Configurando Docker..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    sudo systemctl start docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo usermod -aG docker $ADMIN_USER
  "

PUBLIC_IP=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --show-details \
  --query publicIps \
  --output tsv)

echo ""
echo "========================================"
echo "  VM CONFIGURADA COM SUCESSO!"
echo "========================================"
echo "  Nome:     $VM_NAME"
echo "  Grupo:    $RESOURCE_GROUP"
echo "  Usuario:  $ADMIN_USER"
echo "  IP:       $PUBLIC_IP"
echo ""
echo "  Softwares instalados:"
echo "  - tree"
echo "  - Git"
echo "  - nano"
echo "  - Azure CLI"
echo "  - Docker"
echo ""
echo "  Para conectar via SSH:"
echo "  ssh ${ADMIN_USER}@${PUBLIC_IP}"
echo ""
echo "  Senha:"
echo "  $ADMIN_PASS"
echo ""
echo "  Ao conectar pela primeira vez, rode:"
echo "  newgrp docker"
echo "========================================"
