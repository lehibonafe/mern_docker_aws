# Project Structure

```
mern-app/
├── .github/
│   └── workflows/
│       └── deploy-ecs.yml          # GitHub Actions workflow for AWS ECS deployment
├── backend/
│   ├── .dockerignore               # Docker ignore file
│   ├── .env                        # Environment variables (not in git)
│   ├── .env.example               # Example environment variables
│   ├── Dockerfile                 # Backend Docker configuration
│   ├── package.json               # Backend dependencies
│   └── server.js                  # Express server with API routes
├── frontend/
│   ├── public/
│   │   └── index.html            # HTML template
│   ├── src/
│   │   ├── App.css               # Main app styles
│   │   ├── App.js                # Main React component
│   │   ├── index.css             # Global styles
│   │   └── index.js              # React entry point
│   ├── .dockerignore             # Docker ignore file
│   ├── .env                      # Environment variables (not in git)
│   ├── .env.example             # Example environment variables
│   ├── Dockerfile               # Frontend Docker configuration (multi-stage)
│   ├── nginx.conf               # Nginx configuration for production
│   └── package.json             # Frontend dependencies
├── .gitignore                    # Git ignore file
├── AWS-DEPLOYMENT-GUIDE.md      # Comprehensive AWS ECS deployment guide
├── CONTRIBUTING.md              # Contribution guidelines
├── LICENSE                      # MIT License
├── Makefile                     # Common development commands
├── QUICK-START.md              # Quick start guide
├── README.md                   # Main project documentation
├── aws-setup.sh               # AWS infrastructure setup script
└── docker-compose.yml         # Local development Docker Compose configuration
```

## File Descriptions

### Root Level

| File | Description |
|------|-------------|
| `README.md` | Main project documentation with overview and setup instructions |
| `QUICK-START.md` | Quick start guide for running the app locally |
| `AWS-DEPLOYMENT-GUIDE.md` | Step-by-step AWS ECS deployment instructions |
| `CONTRIBUTING.md` | Guidelines for contributing to the project |
| `LICENSE` | MIT License |
| `Makefile` | Common commands for development and deployment |
| `docker-compose.yml` | Docker Compose configuration for local development |
| `aws-setup.sh` | Bash script to create AWS resources |
| `.gitignore` | Files and directories to ignore in Git |

### Backend (`/backend`)

| File | Description |
|------|-------------|
| `server.js` | Main Express server with API routes and MongoDB connection |
| `package.json` | Node.js dependencies and scripts |
| `Dockerfile` | Docker configuration for backend container |
| `.env` | Environment variables (MongoDB URI, port, etc.) |
| `.env.example` | Example environment variables template |
| `.dockerignore` | Files to exclude from Docker build |

### Frontend (`/frontend`)

| File | Description |
|------|-------------|
| `src/App.js` | Main React component with task management logic |
| `src/App.css` | Styles for the main application |
| `src/index.js` | React application entry point |
| `src/index.css` | Global CSS styles |
| `public/index.html` | HTML template |
| `package.json` | React dependencies and scripts |
| `Dockerfile` | Multi-stage Docker build (build + nginx) |
| `nginx.conf` | Nginx server configuration |
| `.env` | Environment variables (API URL) |
| `.env.example` | Example environment variables template |
| `.dockerignore` | Files to exclude from Docker build |

### GitHub Actions (`/.github/workflows`)

| File | Description |
|------|-------------|
| `deploy-ecs.yml` | CI/CD pipeline for building and deploying to AWS ECS |

## Key Components

### Backend Components
- **Express Server**: RESTful API with CRUD operations
- **MongoDB Integration**: Mongoose ODM for database operations
- **CORS Support**: Cross-origin resource sharing enabled
- **Health Check**: `/health` endpoint for monitoring

### Frontend Components
- **Task Manager UI**: Full CRUD interface for tasks
- **Responsive Design**: Mobile-friendly layout
- **Real-time Updates**: Automatic refresh after operations
- **Error Handling**: User-friendly error messages

### DevOps Components
- **Docker**: Containerization for all services
- **Docker Compose**: Local development orchestration
- **GitHub Actions**: Automated CI/CD pipeline
- **AWS ECS**: Production container orchestration
- **ECR**: Container registry for Docker images

## Environment Variables

### Backend Environment Variables
```env
PORT=5000                              # Server port
MONGODB_URI=mongodb://...              # MongoDB connection string
NODE_ENV=development                   # Environment mode
```

### Frontend Environment Variables
```env
REACT_APP_API_URL=http://localhost:5000  # Backend API URL
```

## Port Configuration

| Service | Port | Description |
|---------|------|-------------|
| Frontend | 3000 | React development server (local) |
| Frontend | 80 | Nginx server (Docker) |
| Backend | 5000 | Express API server |
| MongoDB | 27017 | MongoDB database |

## Technology Stack

### Backend
- **Runtime**: Node.js 18
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose
- **Container**: Docker (node:18-alpine)

### Frontend
- **Library**: React 18
- **Build Tool**: Create React App
- **HTTP Client**: Axios
- **Container**: Multi-stage (node:18-alpine + nginx:alpine)

### DevOps
- **Containerization**: Docker & Docker Compose
- **CI/CD**: GitHub Actions
- **Cloud**: AWS (ECS, ECR, ALB)
- **Orchestration**: AWS ECS Fargate

## Data Flow

```
User Browser
    ↓
Frontend (React) → http://localhost:3000
    ↓
Backend API (Express) → http://localhost:5000
    ↓
MongoDB Database → mongodb://localhost:27017
```

## Deployment Architecture

```
GitHub → GitHub Actions
    ↓
Build Docker Images
    ↓
Push to AWS ECR
    ↓
Update ECS Task Definitions
    ↓
Deploy to ECS Services (Fargate)
    ↓
Route Traffic via Application Load Balancer
    ↓
End Users
```

## Development Workflow

1. **Local Development**: Use Docker Compose
2. **Code Changes**: Edit files, auto-reload enabled
3. **Testing**: Manual testing via browser
4. **Commit**: Push to GitHub
5. **Deployment**: GitHub Actions automatically deploys to AWS

## Security Considerations

- Environment variables for sensitive data
- CORS configured for specific origins
- Docker containers run as non-root users
- AWS IAM roles for least privilege access
- HTTPS recommended for production (via ALB)

## Scalability

- Horizontal scaling via ECS service auto-scaling
- Database replication with MongoDB Atlas
- Load balancing with AWS ALB
- Container orchestration with ECS Fargate

## Monitoring and Logging

- CloudWatch Logs for container logs
- ECS service metrics
- Application health checks
- Custom CloudWatch alarms