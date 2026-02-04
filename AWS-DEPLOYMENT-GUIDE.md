# AWS ECS Deployment Guide

This guide provides step-by-step instructions for deploying the MERN application to AWS ECS.

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Docker installed locally
- MongoDB Atlas account (or AWS DocumentDB)

## Architecture Overview

```
┌─────────────┐
│   GitHub    │
│   Actions   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   AWS ECR   │
│ (Container  │
│  Registry)  │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────┐
│   AWS ECS   │────▶│  Frontend    │
│  (Fargate)  │     │     ALB      │
│             │     └──────────────┘
│             │
│             │     ┌──────────────┐
│             │────▶│  Backend     │
│             │     │     ALB      │
└─────────────┘     └──────────────┘
       │
       ▼
┌─────────────┐
│  MongoDB    │
│   Atlas     │
└─────────────┘
```

## Step-by-Step Deployment

### Phase 1: AWS Infrastructure Setup

#### 1.1 Run the Setup Script

```bash
chmod +x aws-setup.sh
./aws-setup.sh
```

This creates:
- ECR repositories for frontend and backend
- ECS cluster
- CloudWatch log groups

#### 1.2 Create VPC (if you don't have one)

```bash
# Create VPC
aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=mern-vpc}]'

# Note the VPC ID from the output
export VPC_ID=<your-vpc-id>

# Create Internet Gateway
aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=mern-igw}]'

export IGW_ID=<your-igw-id>

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID

# Create Subnets (at least 2 in different AZs)
aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=mern-subnet-1}]'

aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone us-east-1b \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=mern-subnet-2}]'
```

#### 1.3 Create Security Groups

```bash
# Security Group for Backend
aws ec2 create-security-group \
  --group-name mern-backend-sg \
  --description "Security group for MERN backend" \
  --vpc-id $VPC_ID

export BACKEND_SG_ID=<backend-sg-id>

# Allow inbound traffic on port 5000
aws ec2 authorize-security-group-ingress \
  --group-id $BACKEND_SG_ID \
  --protocol tcp \
  --port 5000 \
  --cidr 0.0.0.0/0

# Security Group for Frontend
aws ec2 create-security-group \
  --group-name mern-frontend-sg \
  --description "Security group for MERN frontend" \
  --vpc-id $VPC_ID

export FRONTEND_SG_ID=<frontend-sg-id>

# Allow inbound traffic on port 80
aws ec2 authorize-security-group-ingress \
  --group-id $FRONTEND_SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

#### 1.4 Create Application Load Balancers

```bash
# Create ALB for Backend
aws elbv2 create-load-balancer \
  --name mern-backend-alb \
  --subnets <subnet-1-id> <subnet-2-id> \
  --security-groups $BACKEND_SG_ID \
  --scheme internet-facing \
  --type application

# Create ALB for Frontend
aws elbv2 create-load-balancer \
  --name mern-frontend-alb \
  --subnets <subnet-1-id> <subnet-2-id> \
  --security-groups $FRONTEND_SG_ID \
  --scheme internet-facing \
  --type application
```

#### 1.5 Create Target Groups

```bash
# Backend Target Group
aws elbv2 create-target-group \
  --name mern-backend-tg \
  --protocol HTTP \
  --port 5000 \
  --vpc-id $VPC_ID \
  --target-type ip \
  --health-check-path /health

# Frontend Target Group
aws elbv2 create-target-group \
  --name mern-frontend-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID \
  --target-type ip \
  --health-check-path /
```

#### 1.6 Create Listeners

```bash
# Backend Listener
aws elbv2 create-listener \
  --load-balancer-arn <backend-alb-arn> \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=<backend-tg-arn>

# Frontend Listener
aws elbv2 create-listener \
  --load-balancer-arn <frontend-alb-arn> \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=<frontend-tg-arn>
```

### Phase 2: MongoDB Setup

#### Option A: MongoDB Atlas (Recommended)

1. Go to https://www.mongodb.com/cloud/atlas
2. Create a free cluster
3. Create a database user
4. Whitelist IP addresses (0.0.0.0/0 for testing, or specific AWS IPs for production)
5. Get your connection string:
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/mernapp?retryWrites=true&w=majority
   ```

#### Option B: AWS DocumentDB

```bash
aws docdb create-db-cluster \
  --db-cluster-identifier mern-docdb \
  --engine docdb \
  --master-username admin \
  --master-user-password <your-password> \
  --vpc-security-group-ids $BACKEND_SG_ID
```

### Phase 3: ECS Task Definitions

#### 3.1 Create Backend Task Definition

Save as `backend-task-def.json`:

```json
{
  "family": "mern-backend-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/mern-backend:latest",
      "portMappings": [
        {
          "containerPort": 5000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "PORT",
          "value": "5000"
        },
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "MONGODB_URI",
          "valueFrom": "arn:aws:secretsmanager:REGION:ACCOUNT_ID:secret:mongodb-uri"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/mern-backend",
          "awslogs-region": "YOUR_REGION",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
```

Register the task definition:

```bash
aws ecs register-task-definition --cli-input-json file://backend-task-def.json
```

#### 3.2 Create Frontend Task Definition

Save as `frontend-task-def.json`:

```json
{
  "family": "mern-frontend-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "frontend",
      "image": "YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/mern-frontend:latest",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "REACT_APP_API_URL",
          "value": "http://YOUR_BACKEND_ALB_DNS:80"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/mern-frontend",
          "awslogs-region": "YOUR_REGION",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

Register the task definition:

```bash
aws ecs register-task-definition --cli-input-json file://frontend-task-def.json
```

### Phase 4: ECS Services

#### 4.1 Create Backend Service

```bash
aws ecs create-service \
  --cluster mern-cluster \
  --service-name mern-backend-service \
  --task-definition mern-backend-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[<subnet-1>,<subnet-2>],securityGroups=[$BACKEND_SG_ID],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=<backend-tg-arn>,containerName=backend,containerPort=5000"
```

#### 4.2 Create Frontend Service

```bash
aws ecs create-service \
  --cluster mern-cluster \
  --service-name mern-frontend-service \
  --task-definition mern-frontend-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[<subnet-1>,<subnet-2>],securityGroups=[$FRONTEND_SG_ID],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=<frontend-tg-arn>,containerName=frontend,containerPort=80"
```

### Phase 5: GitHub Secrets Configuration

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `ECR_FRONTEND_REPOSITORY` | Frontend ECR repo name | `mern-frontend` |
| `ECR_BACKEND_REPOSITORY` | Backend ECR repo name | `mern-backend` |
| `ECS_CLUSTER` | ECS cluster name | `mern-cluster` |
| `ECS_SERVICE_FRONTEND` | Frontend service name | `mern-frontend-service` |
| `ECS_SERVICE_BACKEND` | Backend service name | `mern-backend-service` |
| `ECS_TASK_DEFINITION_FRONTEND` | Frontend task def family | `mern-frontend-task` |
| `ECS_TASK_DEFINITION_BACKEND` | Backend task def family | `mern-backend-task` |
| `MONGODB_URI` | MongoDB connection string | `mongodb+srv://...` |
| `REACT_APP_API_URL` | Backend ALB URL | `http://backend-alb-xxx.elb.amazonaws.com` |

### Phase 6: Deploy

1. Push your code to GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. The GitHub Actions workflow will automatically:
   - Build Docker images
   - Push to ECR
   - Update ECS task definitions
   - Deploy to ECS services

3. Monitor the deployment in GitHub Actions tab

### Phase 7: Verify Deployment

1. Get the ALB DNS names:
   ```bash
   aws elbv2 describe-load-balancers --names mern-frontend-alb mern-backend-alb
   ```

2. Test the backend:
   ```bash
   curl http://<backend-alb-dns>/health
   curl http://<backend-alb-dns>/api/items
   ```

3. Access the frontend:
   ```
   http://<frontend-alb-dns>
   ```

## Troubleshooting

### Check ECS Service Status
```bash
aws ecs describe-services --cluster mern-cluster --services mern-backend-service mern-frontend-service
```

### View Logs
```bash
aws logs tail /ecs/mern-backend --follow
aws logs tail /ecs/mern-frontend --follow
```

### Check Task Status
```bash
aws ecs list-tasks --cluster mern-cluster --service-name mern-backend-service
aws ecs describe-tasks --cluster mern-cluster --tasks <task-arn>
```

## Cost Optimization

1. Use Fargate Spot for non-production environments
2. Set up auto-scaling based on CPU/memory
3. Use AWS Savings Plans
4. Monitor with AWS Cost Explorer

## Security Best Practices

1. Use AWS Secrets Manager for sensitive data
2. Enable encryption at rest and in transit
3. Use IAM roles with least privilege
4. Enable VPC Flow Logs
5. Use private subnets for backend
6. Implement WAF rules on ALB
7. Enable CloudTrail for audit logging

## Monitoring

1. Set up CloudWatch alarms for:
   - CPU utilization
   - Memory utilization
   - Request count
   - Error rate

2. Use AWS X-Ray for distributed tracing

3. Set up SNS notifications for alerts

## Cleanup

To delete all resources:

```bash
# Delete ECS services
aws ecs delete-service --cluster mern-cluster --service mern-backend-service --force
aws ecs delete-service --cluster mern-cluster --service mern-frontend-service --force

# Delete ECS cluster
aws ecs delete-cluster --cluster mern-cluster

# Delete ECR repositories
aws ecr delete-repository --repository-name mern-backend --force
aws ecr delete-repository --repository-name mern-frontend --force

# Delete ALBs, target groups, listeners, security groups, etc.
# (Use AWS Console or specific delete commands)
```