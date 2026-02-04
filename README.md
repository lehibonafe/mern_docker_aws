# MERN Stack Application with Docker & AWS ECS Deployment

A simple MERN (MongoDB, Express, React, Node.js) stack application with Docker containerization and automated deployment to AWS ECS using GitHub Actions.

## Project Structure

```
mern-app/
├── backend/                 # Node.js + Express API
├── frontend/               # React frontend
├── docker-compose.yml      # Local development setup
├── .github/
│   └── workflows/
│       └── deploy-ecs.yml  # GitHub Actions workflow
└── README.md
```

## Features

- **Backend**: RESTful API with Node.js, Express, and MongoDB
- **Frontend**: React application with modern UI
- **Dockerized**: Complete Docker setup for all services
- **CI/CD**: Automated deployment to AWS ECS via GitHub Actions

## Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- AWS Account
- GitHub Account

## Local Development

1. Clone the repository:
```bash
git clone <your-repo-url>
cd mern-app
```

2. Start the application with Docker Compose:
```bash
docker-compose up --build
```

3. Access the application:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - MongoDB: localhost:27017

## AWS ECS Deployment Setup

### 1. AWS Prerequisites

Create the following AWS resources:

#### a. ECR Repositories
```bash
aws ecr create-repository --repository-name mern-frontend
aws ecr create-repository --repository-name mern-backend
```

#### b. ECS Cluster
```bash
aws ecs create-cluster --cluster-name mern-cluster
```

#### c. IAM Role for ECS Task Execution
Create a role named `ecsTaskExecutionRole` with the `AmazonECSTaskExecutionRolePolicy` policy attached.

#### d. MongoDB Atlas (Recommended for Production)
- Create a free MongoDB Atlas account at https://www.mongodb.com/cloud/atlas
- Create a cluster and get your connection string
- Whitelist AWS IP ranges or use 0.0.0.0/0 (not recommended for production)

### 2. GitHub Secrets Configuration

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `AWS_REGION`: Your AWS region (e.g., us-east-1)
- `ECR_FRONTEND_REPOSITORY`: Your frontend ECR repository name (e.g., mern-frontend)
- `ECR_BACKEND_REPOSITORY`: Your backend ECR repository name (e.g., mern-backend)
- `ECS_CLUSTER`: Your ECS cluster name (e.g., mern-cluster)
- `ECS_SERVICE_FRONTEND`: Your frontend ECS service name (e.g., mern-frontend-service)
- `ECS_SERVICE_BACKEND`: Your backend ECS service name (e.g., mern-backend-service)
- `ECS_TASK_DEFINITION_FRONTEND`: Your frontend task definition name (e.g., mern-frontend-task)
- `ECS_TASK_DEFINITION_BACKEND`: Your backend task definition name (e.g., mern-backend-task)
- `MONGODB_URI`: Your MongoDB connection string

### 3. Create ECS Task Definitions

#### Backend Task Definition
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
      "environment": [
        {
          "name": "PORT",
          "value": "5000"
        },
        {
          "name": "MONGODB_URI",
          "value": "YOUR_MONGODB_URI"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/mern-backend",
          "awslogs-region": "YOUR_REGION",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

#### Frontend Task Definition
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
      "environment": [
        {
          "name": "REACT_APP_API_URL",
          "value": "http://YOUR_BACKEND_ALB_URL:5000"
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

### 4. Create ECS Services

After creating task definitions, create services for both frontend and backend.

### 5. Trigger Deployment

Push to the `main` branch to trigger the GitHub Actions workflow:

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

## Environment Variables

### Backend
- `PORT`: Server port (default: 5000)
- `MONGODB_URI`: MongoDB connection string
- `NODE_ENV`: Environment (development/production)

### Frontend
- `REACT_APP_API_URL`: Backend API URL

## API Endpoints

- `GET /api/items` - Get all items
- `POST /api/items` - Create a new item
- `PUT /api/items/:id` - Update an item
- `DELETE /api/items/:id` - Delete an item

## Tech Stack

- **Frontend**: React 18, Axios
- **Backend**: Node.js, Express, Mongoose
- **Database**: MongoDB
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Cloud**: AWS ECS, ECR

## License

MIT