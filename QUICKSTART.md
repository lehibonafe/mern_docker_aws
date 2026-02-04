# Quick Start Guide

Get the MERN application running locally in 5 minutes!

## Prerequisites

- Docker and Docker Compose installed
- Git installed

## Steps

### 1. Clone the Repository

```bash
git clone https://github.com/lehibonafe/mern_docker_aws.git
cd mern-app
```

### 2. Start the Application

```bash
docker-compose up --build
```

This command will:
- Build Docker images for frontend and backend
- Start MongoDB container
- Start backend API on port 5000
- Start frontend on port 3000

### 3. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **MongoDB**: localhost:27017

### 4. Test the Application

1. Open http://localhost:3000 in your browser
2. Create a new task using the form
3. View, complete, and delete tasks

## Development Mode

If you want to run the application in development mode with hot-reload:

### Backend Development

```bash
cd backend
npm install
npm run dev
```

### Frontend Development

```bash
cd frontend
npm install
npm start
```

Make sure MongoDB is running:
```bash
docker run -d -p 27017:27017 mongo:7
```

## Environment Variables

### Backend (.env)
```
PORT=5000
MONGODB_URI=mongodb://mongodb:27017/mernapp
NODE_ENV=development
```

### Frontend (.env)
```
REACT_APP_API_URL=http://localhost:5000
```

## API Endpoints

### GET /api/items
Get all items
```bash
curl http://localhost:5000/api/items
```

### POST /api/items
Create a new item
```bash
curl -X POST http://localhost:5000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"My Task","description":"Task description"}'
```

### PUT /api/items/:id
Update an item
```bash
curl -X PUT http://localhost:5000/api/items/123 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

### DELETE /api/items/:id
Delete an item
```bash
curl -X DELETE http://localhost:5000/api/items/123
```

## Stopping the Application

```bash
docker-compose down
```

To also remove volumes:
```bash
docker-compose down -v
```

## Troubleshooting

### Port Already in Use

If you get an error about ports already in use, you can either:

1. Stop the service using that port
2. Change the port in `docker-compose.yml`

### Connection Refused

If the frontend can't connect to the backend:

1. Make sure all containers are running: `docker-compose ps`
2. Check backend logs: `docker-compose logs backend`
3. Verify the API URL in frontend `.env` file

### MongoDB Connection Error

If you see MongoDB connection errors:

1. Check MongoDB container status: `docker-compose logs mongodb`
2. Verify MongoDB URI in backend `.env` file
3. Wait a few seconds for MongoDB to initialize

## Next Steps

- Deploy to AWS ECS: See [AWS-DEPLOYMENT-GUIDE.md](AWS-DEPLOYMENT-GUIDE.md)
- Customize the application
- Add authentication
- Implement additional features

## Need Help?

- Check the full [README.md](README.md)
- Review [AWS-DEPLOYMENT-GUIDE.md](AWS-DEPLOYMENT-GUIDE.md) for production deployment
- Check Docker logs: `docker-compose logs <service-name>`