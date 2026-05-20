# PetCare360 - DevOps, Docker E Azure

Este material descreve como executar o PetCare360 em uma VM Linux na Azure usando Docker Compose com dois containers:

- `petcare360-api`: aplicacao Java Spring Boot.
- `oracle-petcare`: banco Oracle XE.

## 1. Descricao Do Projeto

O **PetCare360** e uma API REST para monitoramento de pets por coleiras inteligentes. A aplicacao recebe dados simulados de IoT, persiste historico de sensores, calcula o status atual do pet e gera alertas automaticos.

O backend foi desenvolvido em Java com Spring Boot e utiliza Oracle SQL para persistencia dos dados.

## 2. Beneficios Para O Negocio

- Monitoramento preventivo da saude dos pets.
- Historico de temperatura, batimentos, atividade, localizacao e bateria.
- Alertas automaticos para situacoes de risco.
- Reducao de resposta tardia a alteracoes de saude.
- Base pronta para integracao com dashboards, aplicativos mobile ou sistemas veterinarios.

## 3. Desenho Macro Da Arquitetura

O desenho macro da arquitetura deve ser colocado no PDF final da entrega.

Arquivos de apoio:

```text
spritDevOps/documentos/
```

Fluxo em nuvem:

```text
Usuario/Postman/Swagger
        |
        v
Azure VM - porta 8080
        |
        v
Container petcare360-api
        |
        v
Rede Docker petcare-network
        |
        v
Container oracle-petcare
        |
        v
Volume nomeado oracle-petcare-data
```

Os arquivos `.mmd` e as imagens exportadas dos diagramas devem ficar em `spritDevOps/documentos/diagramas`. No PDF final, inserir a imagem do desenho e uma legenda curta explicando o caminho da requisicao ate o banco.

## 4. Rotas Principais

### Auth

| Metodo | Rota | Descricao |
|---|---|---|
| POST | `/auth/register` | Cria usuario |
| POST | `/auth/login` | Autentica usuario e retorna JWT |

### Pets

| Metodo | Rota | Descricao |
|---|---|---|
| GET | `/pets/all` | Lista pets sem paginacao |
| POST | `/pets` | Cria pet, coleira e primeira leitura |
| GET | `/pets/{id}` | Busca pet por ID |
| PUT | `/pets/{id}` | Atualiza pet e registra nova leitura |
| DELETE | `/pets/{id}` | Remove pet |
| GET | `/pets/{id}/health-status` | Status atual de saude |
| GET | `/pets/{id}/alerts` | Alertas do pet |

### IoT

| Metodo | Rota | Descricao |
|---|---|---|
| POST | `/api/iot/data` | Recebe telemetria da coleira |

## 5. Arquivos Da Entrega DevOps

```text
spritDevOps/
├── Dockerfile.petcare360
├── docker-compose.yml
├── .env.example
├── README-devops.md
└── scriptAzure/
    └── sprintDevOps_full_setup.sh
```

## 6. How To - Instalacao Completa Na Azure

Este passo a passo considera o uso do **Azure Cloud Shell** para criar a VM e depois o acesso via SSH para subir a aplicacao com Docker Compose.

### 6.1 Clonar Este Repositorio DevOps No Azure Cloud Shell

No Azure Cloud Shell, clone o repositorio que contem a pasta `spritDevOps`.

> Troque a URL abaixo pela URL real do repositorio onde voce subiu estes arquivos DevOps.

```bash
git clone https://github.com/SEU_USUARIO/sprintDevOps.git sprintDevOps
cd sprintDevOps
```

Conferir os arquivos:

```bash
ls
ls scriptAzure
```

### 6.2 Criar A VM Pelo Azure CLI

Para atender ao requisito de um script completo em sequencia, execute:

```bash
bash scriptAzure/sprintDevOps_full_setup.sh
```

Esse script cria a VM, abre as portas, instala o Docker e instala as ferramentas necessarias.

Ele realiza:

- Criacao do Resource Group `sprintDevOps`.
- Criacao da VM Linux `sprintDevOps`.
- Uso de AlmaLinux 10.
- Abertura da porta `22` para SSH.
- Abertura da porta `8080` para a API Spring Boot.
- Abertura das portas extras previstas no roteiro da aula.
- Instalacao do Docker.
- Instalacao do Docker Compose Plugin.
- Instalacao de Git, nano, tree e Azure CLI.

Ao final, o script mostra o IP publico da VM.

Guarde o IP para conectar via SSH.

### 6.3 Conectar Na VM

Use o IP exibido pelo script:

```bash
ssh admlnx@IP_DA_VM
```

Depois de conectar pela primeira vez, rode:

```bash
newgrp docker
```

Confira se o Docker Compose esta disponivel:

```bash
docker compose version
```

### 6.4 Clonar Este Repositorio DevOps Dentro Da VM

Dentro da VM, clone novamente o repositorio DevOps para obter o `docker-compose.yml`, `Dockerfile.petcare360` e `.env.example`.

> Troque a URL abaixo pela URL real do repositorio onde voce subiu estes arquivos DevOps.

```bash
cd ~
git clone https://github.com/SEU_USUARIO/sprintDevOps.git sprintDevOps
cd ~/sprintDevOps
```

Conferir a estrutura:

```bash
ls
```

### 6.5 Clonar O Projeto Java

Ainda dentro de `~/sprintDevOps`, clone o repositorio Java usando o nome `petcare360_java`, porque o `docker-compose.yml` espera esse nome de pasta:

```bash
git clone https://github.com/PetCare-360/Sprint1-Java.git petcare360_java
```

A estrutura deve ficar assim:

```text
sprintDevOps/
├── Dockerfile.petcare360
├── docker-compose.yml
├── .env.example
└── petcare360_java/
    ├── pom.xml
    └── src/
```

### 6.6 Configurar Variaveis De Ambiente

Crie o arquivo `.env`:

```bash
cp .env.example .env
nano .env
```

Conteudo esperado:

```env
ORACLE_PASSWORD=OracleRoot123
ORACLE_APP_USER=petcare
ORACLE_APP_PASSWORD=Petcare123
PETCARE360_JWT_SECRET=petcare360-devops-secret-key-change-before-production-2026
PETCARE360_JWT_EXPIRATION_MINUTES=120
```

### 6.7 Subir App E Banco Com Docker Compose

Execute:

```bash
docker compose up -d --build
```

Verifique os containers:

```bash
docker compose ps
```

Verifique os logs:

```bash
docker compose logs oracle-petcare
docker compose logs petcare360-api
```

### 6.8 Acessar A API

Dentro da VM:

```bash
curl http://localhost:8080/swagger-ui/index.html
```

Fora da VM:

```text
http://IP_DA_VM:8080/swagger-ui/index.html
```

## 7. Docker Compose

O arquivo `docker-compose.yml` cria:

- Banco Oracle em `oracle-petcare`.
- API Java em `petcare360-api`.
- Rede Docker `petcare-network`.
- Volume nomeado `oracle-petcare-data`.

Trecho principal:

```yaml
services:
  oracle-petcare:
    container_name: oracle-petcare
    image: gvenzl/oracle-xe:21-slim
    ports:
      - "1521:1521"
    networks:
      - petcare-network
    volumes:
      - oracle-petcare-data:/opt/oracle/oradata
    restart: unless-stopped
    env_file:
      - .env

  petcare360-api:
    container_name: petcare360-api
    build:
      context: ./petcare360_java
      dockerfile: ../Dockerfile.petcare360
    ports:
      - "8080:8080"
    networks:
      - petcare-network
    env_file:
      - .env
    depends_on:
      oracle-petcare:
        condition: service_healthy
    restart: unless-stopped
```

## 8. Verificar Containers, Logs, Rede E Volume

```bash
docker compose ps
docker compose logs oracle-petcare
docker compose logs petcare360-api
docker volume ls
docker network ls
```

Inspecionar volume e rede:

```bash
docker volume inspect oracle-petcare-data
docker network inspect petcare-network
```

## 9. Como Usar O JWT Nos Testes

Primeiro registre um usuario:

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Rafael DevOps",
    "email": "rafael.devops@gmail.com",
    "password": "senha123"
  }'
```

Depois faca login e salve automaticamente o JWT na variavel `TOKEN`:

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "rafael.devops@gmail.com",
    "password": "senha123"
  }' | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
```

Conferir se o token foi capturado:

```bash
echo $TOKEN
```

Nas rotas protegidas, use:

```bash
-H "Authorization: Bearer $TOKEN"
```

## 10. Teste Rapido CRUD De Pets

### POST - Criar Pet

```bash
curl -X POST http://localhost:8080/pets \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Thor",
    "age": 4,
    "weight": 12.5,
    "breed": "Golden Retriever",
    "deviceId": "COLLAR_DEVOPS_001",
    "initialSensorData": {
      "timestamp": "2026-04-27T10:30:00Z",
      "temperature": 38.5,
      "heartRate": 110,
      "activityLevel": 72,
      "latitude": -23.6815,
      "longitude": -46.8755,
      "battery": 85
    }
  }'
```

Verifica no Oracle:

```bash
echo "SELECT id, name, breed, device_id FROM pets; EXIT;" | docker exec -i oracle-petcare sqlplus -s petcare/Petcare123@XEPDB1
```

### POST - Segundo Insert Significativo

```bash
curl -X POST http://localhost:8080/pets \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Luna",
    "age": 2,
    "weight": 6.8,
    "breed": "Shih Tzu",
    "deviceId": "COLLAR_DEVOPS_002",
    "initialSensorData": {
      "timestamp": "2026-04-27T11:00:00Z",
      "temperature": 39.8,
      "heartRate": 142,
      "activityLevel": 20,
      "latitude": -23.5505,
      "longitude": -46.6333,
      "battery": 31
    }
  }'
```

Verifica no Oracle:

```bash
echo "SELECT id, name, breed, device_id FROM pets; EXIT;" | docker exec -i oracle-petcare sqlplus -s petcare/Petcare123@XEPDB1
```

### GET - Listar Todos Os Pets

```bash
curl -X GET http://localhost:8080/pets/all \
  -H "Authorization: Bearer $TOKEN"
```

Verifica no Oracle:

```bash
echo "SELECT id, name, breed, device_id FROM pets; EXIT;" | docker exec -i oracle-petcare sqlplus -s petcare/Petcare123@XEPDB1
```

### GET - Buscar Um Pet

Troque `1` pelo ID retornado no POST.

```bash
curl -X GET http://localhost:8080/pets/1 \
  -H "Authorization: Bearer $TOKEN"
```

Verifica no Oracle:

```bash
echo "SELECT id, name, breed, device_id FROM pets WHERE id = 1; EXIT;" | docker exec -i oracle-petcare sqlplus -s petcare/Petcare123@XEPDB1
```

### PUT - Atualizar Pet

```bash
curl -X PUT http://localhost:8080/pets/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Thor Atualizado",
    "age": 5,
    "weight": 13.2,
    "breed": "Golden Retriever",
    "deviceId": "COLLAR_DEVOPS_001",
    "initialSensorData": {
      "timestamp": "2026-04-27T12:00:00Z",
      "temperature": 40.2,
      "heartRate": 145,
      "activityLevel": 10,
      "latitude": -23.6815,
      "longitude": -46.8755,
      "battery": 18
    }
  }'
```

Verifica no Oracle:

```bash
echo "SELECT id, name, age, weight, breed, device_id FROM pets WHERE id = 1; EXIT;" | docker exec -i oracle-petcare sqlplus -s petcare/Petcare123@XEPDB1
```

### DELETE - Remover Pet

```bash
curl -X DELETE http://localhost:8080/pets/1 \
  -H "Authorization: Bearer $TOKEN"
```

Verifica no Oracle:

```bash
echo "SELECT id, name, breed, device_id FROM pets; EXIT;" | docker exec -i oracle-petcare sqlplus -s petcare/Petcare123@XEPDB1
```

## 11. Verificar Persistencia No Banco Oracle

Entrar no Oracle:

```bash
docker exec -it oracle-petcare sqlplus petcare/Petcare123@XEPDB1
```

Consultar tabelas:

```sql
SHOW USER;
SELECT table_name FROM user_tables;
SELECT * FROM users;
SELECT * FROM pets;
SELECT * FROM devices;
SELECT * FROM sensor_data;
SELECT * FROM alerts;
EXIT;
```

## 12. Parar Ou Remover O Ambiente

Parar containers sem apagar volume:

```bash
docker compose down
```

Apagar containers e volume do banco:

```bash
docker compose down -v
```

## 13. Remover Recursos Da Azure

Ao final da entrega, remover a VM e os recursos criados:

```bash
az group delete --name sprintDevOps --yes --no-wait
```

Tire print da remocao para anexar ao PDF final.
