#!/usr/bin/env bash
# =============================================================================
#  sprintDevOps_azure_vm.sh — Rodar direto no Azure Cloud Shell
#  Cria a VM sprintDevOps usando AlmaLinux 10
# =============================================================================
set -euo pipefail

# Configuracoes
VM_NAME="sprintDevOps"
RESOURCE_GROUP="sprintDevOps"
LOCATION="mexicocentral"
VM_SIZE="Standard_B2als_v2"
IMAGE="almalinux:almalinux-x86_64:10-gen2:latest"
ADMIN_USER="admlnx"
ADMIN_PASS='Fiap@2tdsvms'

echo "Criando Resource Group: $RESOURCE_GROUP..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output table

echo "Criando VM $VM_NAME com AlmaLinux 10..."
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "$IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --admin-password "$ADMIN_PASS" \
  --authentication-type password \
  --public-ip-sku Standard \
  --os-disk-size-gb 64 \
  --output table

echo "Porta 22 (SSH) ja e criada pela Azure durante o provisionamento da VM."

echo "Abrindo porta 5000 (API Flask)..."
az vm open-port \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --port 5000 \
  --priority 1100 \
  --output none

echo "Abrindo porta 8080 (API Spring Boot)..."
az vm open-port \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --port 8080 \
  --priority 1150 \
  --output none

echo "Abrindo porta 5432 (PostgreSQL)..."
az vm open-port \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --port 5432 \
  --priority 1200 \
  --output none

PUBLIC_IP=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --show-details \
  --query publicIps \
  --output tsv)

echo ""
echo "========================================"
echo "  VM CRIADA COM SUCESSO!"
echo "========================================"
echo "  Nome:     $VM_NAME"
echo "  Grupo:    $RESOURCE_GROUP"
echo "  Imagem:   AlmaLinux 10"
echo "  Usuario:  $ADMIN_USER"
echo "  IP:       $PUBLIC_IP"
echo ""
echo "  Proximo passo — conectar via SSH:"
echo "  ssh ${ADMIN_USER}@${PUBLIC_IP}"
echo ""
echo "  Para instalar as ferramentas, rode:"
echo "  bash scriptAzure/sprintDevOps_tools-vm-linux.sh"
echo ""
echo "  Para deletar tudo ao final:"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo "========================================"
