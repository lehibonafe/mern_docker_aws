# Contributing to MERN Stack Application

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/mern-app.git
   cd mern-app
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/mern-app.git
   ```

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or updates

### 2. Make Your Changes

#### Backend Changes
```bash
cd backend
npm install
npm run dev
```

#### Frontend Changes
```bash
cd frontend
npm install
npm start
```

### 3. Test Your Changes

- Ensure all existing tests pass
- Add tests for new features
- Test locally with Docker:
  ```bash
  docker-compose up --build
  ```

### 4. Commit Your Changes

Follow conventional commit messages:

```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

Examples:
```bash
git commit -m "feat(backend): add user authentication endpoint"
git commit -m "fix(frontend): resolve task deletion issue"
git commit -m "docs(readme): update installation instructions"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Code Style Guidelines

### JavaScript/React
- Use ES6+ features
- Use functional components with hooks
- Follow Airbnb style guide
- Use meaningful variable names
- Add comments for complex logic

### Node.js/Express
- Use async/await over promises
- Proper error handling
- Validate input data
- Use environment variables for configuration

### Docker
- Keep images small
- Use multi-stage builds
- Don't store secrets in images

## Pull Request Guidelines

### Before Submitting
- [ ] Code follows project style guidelines
- [ ] Tests pass locally
- [ ] New features include tests
- [ ] Documentation is updated
- [ ] Commit messages follow conventions
- [ ] No merge conflicts

### PR Description Should Include
- Summary of changes
- Related issue numbers
- Screenshots (for UI changes)
- Testing instructions
- Breaking changes (if any)

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How to test these changes

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

## Testing Guidelines

### Backend Tests
```bash
cd backend
npm test
```

### Frontend Tests
```bash
cd frontend
npm test
```

### Integration Tests
```bash
docker-compose up --build
# Run integration tests
```

## Documentation

### Update Documentation When
- Adding new features
- Changing API endpoints
- Modifying environment variables
- Updating deployment process
- Changing architecture

### Documentation Files
- `README.md` - Project overview
- `QUICK-START.md` - Quick start guide
- `AWS-DEPLOYMENT-GUIDE.md` - AWS deployment
- `CONTRIBUTING.md` - This file
- Code comments for complex logic

## Issue Reporting

### Bug Reports Should Include
- Clear title and description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)
- Environment details (OS, Node version, etc.)

### Feature Requests Should Include
- Clear description of the feature
- Use case and benefits
- Possible implementation approach
- Screenshots or mockups (if applicable)

## Code Review Process

1. Maintainer reviews the PR
2. Feedback is provided
3. Updates are made by contributor
4. Once approved, PR is merged

### Review Criteria
- Code quality and style
- Test coverage
- Documentation
- Performance impact
- Security considerations

## Environment Setup

### Required Tools
- Node.js 18+
- Docker & Docker Compose
- Git
- Code editor (VS Code recommended)

### Recommended VS Code Extensions
- ESLint
- Prettier
- Docker
- GitLens
- Thunder Client (API testing)

### Environment Variables
Copy `.env.example` files:
```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

## Common Tasks

### Adding a New API Endpoint

1. Add route in `backend/server.js`
2. Add validation
3. Update documentation
4. Add tests

### Adding a New React Component

1. Create component in `frontend/src/components/`
2. Add styles
3. Import in parent component
4. Update documentation

### Updating Dependencies

```bash
# Backend
cd backend
npm update
npm audit fix

# Frontend
cd frontend
npm update
npm audit fix
```

## Questions?

- Open an issue for questions
- Join discussions
- Check existing documentation

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT).

## Thank You!

Your contributions make this project better for everyone!