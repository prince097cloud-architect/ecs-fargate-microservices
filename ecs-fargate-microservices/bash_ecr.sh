#!/bin/bash
set -e

echo "=========================================="
echo "   🚀 Building & Pushing Images to ECR"
echo "=========================================="

# Load .env AWS credentials
if [ -f .env ]; then
    echo "🔹 Loading .env..."
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ ERROR: .env file not found!"
    exit 1
fi

# Verify required vars
REQUIRED_VARS=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "AWS_DEFAULT_REGION" "AWS_ACCOUNT_ID")
for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR}" ]; then
    echo "❌ ERROR: Missing required variable: $VAR"
    exit 1
  fi
done

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
SERVICE_A_REPO="${ECR_REGISTRY}/service-a"
SERVICE_B_REPO="${ECR_REGISTRY}/service-b"

echo "Using ECR Registry: $ECR_REGISTRY"
echo "=========================================="

# Login to ECR
echo "🔹 Logging in to ECR..."
aws ecr get-login-password --region ${AWS_DEFAULT_REGION} \
  | docker login --username AWS --password-stdin ${ECR_REGISTRY}

echo "Login Succeeded!"
echo "=========================================="

##################################################
# Buildx Setup (Fix for M1/M2 Macs)
##################################################
echo "🔧 Ensuring buildx builder exists..."

if ! docker buildx ls | grep -q "ecs-builder"; then
    docker buildx create --name ecs-builder --use
else
    docker buildx use ecs-builder
fi

docker buildx inspect --bootstrap
echo "Buildx ready (platform linux/amd64 enabled)"
echo "=========================================="

##################################################
# Build + Push Service A
##################################################
echo "🔥 Building Service A (linux/amd64)..."

cd service-a
mvn clean package -DskipTests
cp target/*.jar app.jar

docker buildx build \
  --platform linux/amd64 \
  -t ${SERVICE_A_REPO}:latest \
  --push .

# Check architecture
echo "🔍 Checking architecture for Service A..."
docker inspect ${SERVICE_A_REPO}:latest | grep Architecture

cd ..
echo "✅ Service A (amd64) pushed!"
echo "=========================================="

##################################################
# Build + Push Service B
##################################################
echo "🔥 Building Service B (linux/amd64)..."

cd service-b
mvn clean package -DskipTests
cp target/*.jar app.jar

docker buildx build \
  --platform linux/amd64 \
  -t ${SERVICE_B_REPO}:latest \
  --push .

# Check architecture
echo "🔍 Checking architecture for Service B..."
docker inspect ${SERVICE_B_REPO}:latest | grep Architecture

cd ..
echo "=========================================="
echo "🎉 All images (amd64) pushed successfully!"
echo "=========================================="
