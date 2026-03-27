# Contributing to AutoVibe

Thank you for your interest in contributing to AutoVibe!

## How to Contribute

### 1. Document Improvements

The core value of AutoVibe is in its documents. You can improve:

- **PRD** (`docs/prd/`): Clarify requirements, add use cases
- **Plan** (`docs/plan/`): Improve Phase descriptions, add sub-tasks
- **Design Spec** (`docs/design/`): Add tech stack templates, improve file format examples

### 2. New Tech Stack Guides

Currently AutoVibe has customization guides for:
- NestJS + Next.js
- FastAPI + React
- Django + React
- Go + React

We need guides for:
- Rails + React/Vue
- Laravel + Vue
- Spring Boot + React
- Rust + React (Axum/Actix)
- Express + React

### 3. Hook Script Improvements

The hook scripts in `docs/design/av-ecosystem-design-spec.md` §6 can be improved:
- More sophisticated write monitors
- Better bash guard patterns
- Session discovery enhancements

### 4. Domain Templates

Phase 6 domain expansion templates for common domains:
- E-commerce (order, product, inventory)
- SaaS (subscription, billing, tenant)
- Healthcare (patient, appointment, record)
- Education (course, student, grade)

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/rails-guide`
3. Make your changes
4. Ensure docs are clear and Claude Code can follow them
5. Submit a Pull Request

## Document Quality Guidelines

When writing or improving documents for AutoVibe, ensure:

- **Claude Code Executable**: Claude Code should be able to read the doc and take action
- **Tech Stack Agnostic** (for base tier): Avoid assumptions about specific frameworks
- **AskUserQuestion Points**: Mark clearly where Claude should ask the user for input
- **File Templates**: Provide exact file content templates with `{{PLACEHOLDER}}` variables
- **Verification Steps**: Include how to verify each phase completed successfully

## Code of Conduct

- Be respectful and constructive in all communications
- Focus on improving documentation quality
- Test your contributions with actual Claude Code sessions

## Questions?

Open an issue with the `question` label.
