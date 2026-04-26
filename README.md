# git-demo

A hands-on demonstration repository for learning and practising core Git concepts, conventional commits, automated versioning, and Docker-based deployment.

## Overview

This repo serves as a practical playground covering:

- Git fundamentals (staging, rebasing, branching)
- Conventional commit workflows with Commitizen
- Commit linting with `commitlint`
- Automated changelog generation and semantic versioning with `standard-version`
- Git hooks via Husky
- Containerised Node.js app with Docker

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) v20+
- [Docker](https://www.docker.com/) (optional, for containerised runs)

### Installation

```bash
git clone https://github.com/Roma-rgb-tech/git-demo.git
cd git-demo
npm install
```

## Usage

### Making a Conventional Commit

Instead of `git commit` directly, use the interactive Commitizen CLI:

```bash
npm run commit
```

This walks you through selecting a commit type (feat, fix, chore, etc.), scope, and description — ensuring every commit follows the [Conventional Commits](https://www.conventionalcommits.org/) spec.

### Releasing a New Version

```bash
npm run release
```

This uses `standard-version` to automatically bump the version in `package.json`, update `CHANGELOG.md`, and create a Git tag.

### Running with Docker

```bash
docker build -t git-demo .
docker run git-demo
```

The image is based on `node:20-alpine` and runs `index.js` as a non-root user.

## Project Structure

```
git-demo/
├── .github/workflows/   # GitHub Actions CI/CD pipelines
├── .husky/              # Git hooks (pre-commit, commit-msg)
├── commands/            # Helper command scripts
├── git_basics.md        # Notes on Git fundamentals
├── git_rebase_interactive.md  # Guide to interactive rebase
├── git_staging.md       # Guide to Git staging area
├── commitlint.config.js # Commitlint rule configuration
├── Dockerfile           # Docker build definition
├── Jenkinsfile          # Jenkins pipeline definition
├── index.js             # Application entry point
└── package.json         # Project metadata and scripts
```

## Git Concepts Covered

- **Staging** — selective `git add`, hunks, and the index (`git_staging.md`)
- **Interactive Rebase** — squashing, reordering, and editing commits (`git_rebase_interactive.md`)
- **Basics** — initialising repos, branching, merging, and remotes (`git_basics.md`)

## Tooling

| Tool | Purpose |
|---|---|
| [Commitizen](https://commitizen-tools.github.io/commitizen/) | Interactive conventional commit prompts |
| [commitlint](https://commitlint.js.org/) | Enforces commit message format |
| [Husky](https://typicode.github.io/husky/) | Runs linting hooks on commit |
| [standard-version](https://github.com/conventional-changelog/standard-version) | Automated versioning and changelog |

## CI/CD

GitHub Actions workflows are defined in `.github/workflows/`. A `Jenkinsfile` is also included for Jenkins-based pipelines.

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for a full history of releases.

## License

This project is intended for educational purposes.
