
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Carpentries-style lesson repository teaching gene expression microarray analysis using R and Bioconductor. The lesson is built using Jekyll and follows the Carpentries lesson template structure.

## Deployment

The site is deployed to GitHub Pages using GitHub Actions. The workflow is defined in `.github/workflows/jekyll.yml` and runs automatically when pushing to the `gh-pages` branch.

### GitHub Actions Workflow

- **Trigger**: Pushes to `gh-pages` branch or manual workflow dispatch
- **Ruby version**: 3.2
- **Jekyll version**: 4.3.2
- **Build process**: Uses bundler cache for faster builds, configures GitHub Pages, builds with Jekyll, and deploys via artifacts
- **Permissions**: Uses OIDC tokens for secure deployment (no secrets required)

### Local Development Setup

After updating dependencies, run:

```bash
# Install/update gems
bundle install

# Serve the site locally
bundle exec jekyll serve
# or
make serve
```

## Build System

### Converting R Markdown to Markdown

The lesson content is authored in R Markdown files (`.Rmd`) in `_episodes_rmd/` and converted to Markdown in `_episodes/`:

```bash
# Convert all R Markdown episodes to Markdown
make lesson-md

# Convert a specific Rmd file (the Makefile handles this automatically)
bin/knit_lessons.sh _episodes_rmd/01-InstallingBioC.Rmd _episodes/01-InstallingBioC.md
```

The conversion process:
1. Executes R code chunks using knitr
2. Generates figures in `fig/rmd-*` directories
3. Adds auto-generated warning to the YAML header
4. Chunk options are controlled by `bin/chunk-options.R`

**Important**: Never edit files in `_episodes/` directly - they are auto-generated from `_episodes_rmd/`.

### Building and Serving the Site

```bash
# Build and serve locally (requires Jekyll)
make serve

# Just build the site without serving
make site

# Build using Docker (if Jekyll not installed locally)
make docker-serve
```

The site is served on port 4000 by default.

### Validation and Cleanup

```bash
# Check for FIXME markers in source files
make lesson-fixme

# Validate lesson Markdown
make lesson-check

# Clean up generated files
make clean

# Remove generated R Markdown artifacts (figures, .md files)
make clean-rmd
```

## Repository Structure

### Key Directories

- `_episodes_rmd/`: Source R Markdown lesson files (edit these)
- `_episodes/`: Generated Markdown files (do not edit)
- `_extras/`: Additional pages (discussion, figures, guide, about)
- `_includes/`: Reusable snippets (links.md, site-links.md)
- `bin/`: Build scripts and R utilities
- `data/`: Microarray data files (GSE33146, GSE66417 datasets)
- `fig/`: Generated figures (including `fig/rmd-*` from R code)

### Configuration

- `_config.yml`: Jekyll configuration, uses remote theme `GTK-teaching/lesson-theme`
- `Makefile`: Build automation
- `bin/chunk-options.R`: knitr chunk options for consistent R output formatting

## Content Development Workflow

### Adding or Modifying Episodes

1. Edit `.Rmd` files in `_episodes_rmd/`
2. R code chunks will be executed during build
3. Run `make lesson-md` to regenerate Markdown
4. Preview changes with `make serve`

### Episode Naming Convention

Episodes follow a numbered prefix pattern: `01-InstallingBioC.Rmd`, `02-GEODataImport.Rmd`, etc.

### YAML Front Matter

Each episode has metadata including:
- `title`: Episode title
- `teaching`: Teaching time in minutes
- `exercises`: Exercise time in minutes
- `source`: "Rmd" for R Markdown episodes
- `questions`: Learning questions
- `objectives`: Learning objectives
- `keypoints`: Key takeaways

## R Environment

### Bioconductor Dependencies

The lesson uses Bioconductor packages for microarray analysis. The `bin/generate_md_episodes.R` script:
1. Automatically detects required packages from R code
2. Installs missing packages before generating episodes
3. Requires knitr version 1.9.20 or higher

### Installing Packages for Development

When setting up for development, the build system will automatically install:
- Packages required by episode R code (detected from `_episodes_rmd/`)
- Packages required by build tools (detected from `bin/`)

## Lesson Content Topics

The lesson covers:
1. Installing and working with Bioconductor
2. Importing data from GEO (Gene Expression Omnibus)
3. Working with Affymetrix platform data
4. Managing and exploring metadata
5. Data normalization techniques
6. Differential gene expression analysis
7. Factorial experimental designs
8. Annotating results
9. Downstream analysis approaches

## Jekyll Theme

Uses custom remote theme: `GTK-teaching/lesson-theme` (configured in `_config.yml`). Collections are defined for `episodes` and `extras` with custom permalinks. Theme skin is configured in `_data/theme.yml` (currently set to "NUS").

## Dependencies

### Ruby Gems (Gemfile)

- **Jekyll**: 4.3.2 (static site generator)
- **jekyll-remote-theme**: Enables using themes from other repositories
- **jekyll-paginate**: Pagination support
- **jekyll-sitemap**: Automatic sitemap generation
- **Ruby 3.2+ compatibility gems**: logger, csv, base64, bigdecimal (required for Ruby 3.2+)

After updating the Gemfile, regenerate Gemfile.lock with `bundle install`.

## Git Workflow

The `gh-pages` branch is the main branch for this repository. GitHub Actions automatically builds and deploys the site when changes are pushed to this branch.