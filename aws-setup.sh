#!/bin/bash

# AWS ECS Setup Script for MERN Application
# This script helps you set up the required AWS resources

set -e

echo "🚀 MERN Stack - AWS ECS Setup Script"
echo "====================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Get AWS Region
read -p "Enter AWS Region (default: ap-southeast-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-ap-southeast-1}

echo -e "\n${YELLOW}Step 1: Creating ECR Repositories${NC}"
echo "-----------------------------------"

# Create ECR repositories
echo "Creating frontend ECR repository..."
aws ecr create-repository \
    --repository-name mern-frontend \
    --region $AWS_REGION \
    --image-scanning-configuration scanOnPush=true \
    2>/dev/null || echo "Frontend repository already exists"

echo "Creating backend ECR repository..."
aws ecr create-repository \
    --repository-name mern-backend \
    --region $AWS_REGION \
    --image-scanning-configuration scanOnPush=true \
    2>/dev/null || echo "Backend repository already exists"

echo -e "${GREEN}✓ ECR repositories created${NC}"

echo -e "\n${YELLOW}Step 2: Creating ECS Cluster${NC}"
echo "-----------------------------"

# Create ECS cluster
aws ecs create-cluster \
    --cluster-name mern-cluster \
    --region $AWS_REGION \
    2>/dev/null || echo "Cluster already exists"

echo -e "${GREEN}✓ ECS cluster created${NC}"

echo -e "\n${YELLOW}Step 3: Creating CloudWatch Log Groups${NC}"
echo "---------------------------------------"

# Create CloudWatch log groups
aws logs create-log-group \
    --log-group-name /ecs/mern-backend \
    --region $AWS_REGION \
    2>/dev/null || echo "Backend log group already exists"

aws logs create-log-group \
    --log-group-name /ecs/mern-frontend \
    --region $AWS_REGION \
    2>/dev/null || echo "Frontend log group already exists"

echo -e "${GREEN}✓ CloudWatch log groups created${NC}"

echo -e "\n${YELLOW}Step 4: Getting AWS Account ID${NC}"
echo "------------------------------"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $ACCOUNT_ID"

echo -e "\n${GREEN}✓ Setup completed!${NC}"
echo ""
echo "====================================="
echo "Next Steps:"
echo "====================================="
echo ""
echo "1. Create VPC and Security Groups for your ECS tasks"
echo "2. Set up Application Load Balancer (ALB) for frontend and backend"
echo "3. Create ECS Task Definitions (sample provided in README.md)"
echo "4. Create ECS Services"
echo "5. Add the following secrets to your GitHub repository:"
echo ""
echo "   AWS_ACCESS_KEY_ID"
echo "   AWS_SECRET_ACCESS_KEY"
echo "   AWS_REGION: $AWS_REGION"
echo "   ECR_FRONTEND_REPOSITORY: mern-frontend"
echo "   ECR_BACKEND_REPOSITORY: mern-backend"
echo "   ECS_CLUSTER: mern-cluster"
echo "   ECS_SERVICE_FRONTEND: <your-frontend-service-name>"
echo "   ECS_SERVICE_BACKEND: <your-backend-service-name>"
echo "   ECS_TASK_DEFINITION_FRONTEND: <your-frontend-task-def>"
echo "   ECS_TASK_DEFINITION_BACKEND: <your-backend-task-def>"
echo "   MONGODB_URI: <your-mongodb-connection-string>"
echo "   REACT_APP_API_URL: <your-backend-alb-url>"
echo ""
echo "6. Push to main branch to trigger deployment"
echo ""
echo "For detailed instructions, see README.md"