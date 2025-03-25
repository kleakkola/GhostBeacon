# Contributing to GhostBeacon

Thank you for your interest in contributing to GhostBeacon! This document provides guidelines for contributions.

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## How to Contribute

### Reporting Bugs

1. Check existing issues first
2. Use the bug report template
3. Include steps to reproduce
4. Provide environment details

### Suggesting Features

1. Check existing feature requests
2. Describe the use case clearly
3. Explain expected behavior
4. Consider implementation approach

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Update documentation
6. Submit PR with clear description

## Development Setup

```bash
# Clone repository
git clone https://github.com/kleakkola/GhostBeacon.git
cd GhostBeacon

# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm test
```

## Coding Standards

### Solidity

- Follow Solidity style guide
- Use NatSpec comments
- Maximum line length: 120 characters
- Always use latest stable compiler version

### JavaScript

- Use ES6+ syntax
- Follow Airbnb style guide
- Use async/await over callbacks
- Write descriptive variable names

### Testing

- Write unit tests for all functions
- Include integration tests
- Aim for >90% code coverage
- Test edge cases and failure scenarios

## Commit Messages

Follow conventional commits:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Tests
- `chore`: Maintenance
- `refactor`: Code refactoring

Example: `feat: add batch conversion submission`

## Review Process

1. Automated tests must pass
2. Code review by maintainers
3. Address feedback promptly
4. Squash commits before merge

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

