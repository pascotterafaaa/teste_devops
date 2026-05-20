#!/usr/bin/env bash
# =============================================================================
#  sprintDevOps_full_setup.sh — Rodar direto no Azure Cloud Shell
#  Executa em sequencia:
#  1. Provisionamento da VM Linux
#  2. Abertura das portas
#  3. Instalacao do Docker
#  4. Instalacao das ferramentas do projeto
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  PETCARE360 - SETUP COMPLETO AZURE"
echo "========================================"

echo ""
echo "Etapa 1/2 - Criando VM e portas..."
bash "$SCRIPT_DIR/sprintDevOps_azure_vm.sh"

echo ""
echo "Etapa 2/2 - Instalando Docker e ferramentas..."
bash "$SCRIPT_DIR/sprintDevOps_tools-vm-linux.sh"

echo ""
echo "========================================"
echo "  SETUP COMPLETO FINALIZADO!"
echo "========================================"
echo "A VM esta criada, com portas abertas, Docker e ferramentas instaladas."
echo "Agora conecte via SSH e siga o README-devops.md para clonar o projeto Java e subir o Docker Compose."
echo "========================================"
