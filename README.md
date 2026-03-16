# Full Stack Application

Central parent repository for all full-stack applications managed as Git submodules.

## Purpose

This repository acts as a scalable hub for multiple full-stack projects.
Each application is maintained in its own dedicated GitHub repository and linked here as a Git submodule.
That keeps every application isolated, independently versioned, and easy to add without restructuring the parent repository.

## Repository Convention

Each application added to this hub must follow the same pattern:

1. Create a dedicated repository for the application.
2. Keep the full application inside that repository, including its frontend and backend.
3. Add the application repository to this parent repository as a submodule.
4. Commit the updated `.gitmodules` file and submodule reference in the parent repository.
5. Push both the child repository and the parent repository.

## Current Applications

| Application | Purpose | Repository |
| --- | --- | --- |
| Blog Application | CMS blog application containing both frontend and backend code | https://github.com/SivaPrasannaS/Blog-Application |
| Content Hub Manager | Content management platform with frontend and backend modules for articles, pages, media, analytics, and administration | https://github.com/SivaPrasannaS/Content-Hub-Manager |
| Event Hub | Event management platform with frontend and backend modules for events, venues, media, RSVPs, analytics, and administration | https://github.com/SivaPrasannaS/Event-Hub |

See `APPLICATIONS.md` for the maintained application index.

## Standard Layout

```text
Full-Stack-Application/
	README.md
	.gitmodules
	scripts/
	Blog Application/
	Content Hub Manager/
	Event Hub/
	Future Application 2/
	Future Application 3/
```

Each folder listed at the root is a Git submodule backed by its own standalone repository.

## Add A New Application

Use the helper script in `scripts/add-application-submodule.ps1` after creating and pushing the child repository.

Example:

```powershell
.\scripts\add-application-submodule.ps1 -Name "Inventory Application" -RepositoryUrl "https://github.com/SivaPrasannaS/Inventory-Application.git" -Purpose "Inventory management application"
```

The script will:

1. Add the new application as a submodule.
2. Stage the submodule reference and `.gitmodules` change.
3. Update `APPLICATIONS.md` with the new application entry.
4. Create a parent-repository commit describing the addition.

## Bootstrap A New Application

Use `scripts/bootstrap-application.ps1` to create a brand-new child repository and register it in the parent automatically.

Example:

```powershell
.\scripts\bootstrap-application.ps1 -Name "Inventory Application" -Purpose "Inventory management platform" -Visibility public
```

The bootstrap script will:

1. Create a local child repository folder beside the parent repository.
2. Generate a minimal application scaffold.
3. Initialize and commit the child repository.
4. Create and push the GitHub repository through GitHub CLI.
5. Register the new child repository in the parent as a submodule.
6. Update `APPLICATIONS.md` and commit the parent repository changes.

## Clone With Submodules

```bash
git clone --recurse-submodules <parent-repo-url>
```

## Initialize Submodules After Clone

```bash
git submodule update --init --recursive
```

## Update All Applications

```bash
git submodule update --remote --merge
```

## Scaling Rules

1. Never move existing application submodule paths after publication unless absolutely necessary.
2. Keep one application per repository and one submodule per application.
3. Use clear application names in both the GitHub repository and parent submodule folder.
4. Update this README whenever a new application is added.
