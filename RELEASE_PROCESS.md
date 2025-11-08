# CRAN Release Process

This document describes the process for releasing a new version of the tatooheene package to CRAN.

## Prerequisites

Before starting a release, ensure you have:

- [ ] R and RStudio installed
- [ ] All required packages installed (`devtools`, `usethis`, `rcmdcheck`, `pkgbuild`)
- [ ] Write access to the GitHub repository
- [ ] All tests passing locally
- [ ] All changes committed and pushed to GitHub

## Release Checklist

### 1. Prepare the Release Locally

Run the automated preparation script:

```r
source("dev/prepare-cran-release.R")
```

This script will:
- Help you increment the version number
- Remind you to update NEWS.md
- Update documentation
- Run tests
- Run R CMD check with CRAN settings
- Build the source package
- Update cran-comments.md

**Manual steps:**

- [ ] Update NEWS.md with detailed changes for the new version
- [ ] Review and fix any warnings or notes from R CMD check
- [ ] Update README.Rmd if needed (then knit to generate README.md)
- [ ] Review all vignettes for accuracy
- [ ] Check that all examples run correctly

### 2. Commit Changes

```bash
git add .
git commit -m "Prepare for CRAN release vX.X.X"
git push origin main
```

### 3. Trigger the Release Workflow

1. Go to [GitHub Actions](https://github.com/arnops/tatooheene/actions/workflows/cran-release.yaml)
2. Click "Run workflow"
3. Enter the version number (e.g., `0.19.0`)
4. Click "Run workflow"

The automated workflow will:
- Validate the version number
- Run R CMD check on multiple platforms (Ubuntu, Windows, macOS)
- Check all URLs in documentation
- Build the source tarball
- Create a git tag
- Create a GitHub release with the tarball attached

### 4. Monitor the Workflow

Watch the workflow progress at:
https://github.com/arnops/tatooheene/actions

All checks must pass before the release is created. If any checks fail:
- Review the error messages
- Fix the issues locally
- Commit and push the fixes
- Re-run the workflow

### 5. Submit to CRAN

Once the GitHub release is created:

1. Download the source tarball from the [GitHub release](https://github.com/arnops/tatooheene/releases)
2. Go to the [CRAN submission page](https://cran.r-project.org/submit.html)
3. Upload the tarball
4. Fill in the submission form:
   - Maintainer email (will receive confirmation email)
   - Copy cran-comments.md contents into the comments field
5. Confirm your email address
6. Wait for CRAN feedback (typically 24-48 hours)

### 6. Respond to CRAN Feedback

CRAN reviewers may request changes:

1. Address all requested changes
2. Increment the patch version (e.g., 0.19.0 → 0.19.1)
3. Update NEWS.md with "Resubmission" section
4. Update cran-comments.md with responses to reviewer comments
5. Repeat the release process from Step 2

### 7. After CRAN Acceptance

Once the package is accepted to CRAN:

1. Update README.Rmd to uncomment CRAN installation instructions:
   ```r
   install.packages("tatooheene")
   ```
2. Knit README.Rmd to update README.md
3. Commit and push:
   ```bash
   git commit -am "Update README with CRAN installation instructions"
   git push
   ```
4. Announce the release (Twitter, R-bloggers, etc.)

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **Major version (X.0.0)**: Incompatible API changes
- **Minor version (0.X.0)**: New functionality in a backward-compatible manner
- **Patch version (0.0.X)**: Backward-compatible bug fixes

Since the package is currently < 1.0.0, breaking changes can happen in minor versions.

## Common Issues and Solutions

### Check Failures

**Problem**: R CMD check fails with warnings or errors

**Solutions**:
- Review the check output carefully
- Run `devtools::check(cran = TRUE)` locally
- Fix all errors and warnings (notes are usually acceptable)
- Common issues:
  - Missing imports in DESCRIPTION
  - Undocumented functions or parameters
  - Examples that don't run
  - Long-running examples (use `\donttest{}`)

### URL Check Failures

**Problem**: Some URLs are broken or redirected

**Solutions**:
- Run `urlchecker::url_check()` locally
- Update or remove broken URLs
- Use DOIs for references when possible
- Wrap URLs in angle brackets in DESCRIPTION

### Test Failures on Specific Platforms

**Problem**: Tests pass locally but fail on Windows/macOS

**Solutions**:
- Use `devtools::check_win_devel()` for Windows-specific checks
- Consider platform-specific code with `if (.Platform$OS.type == "windows")`
- Use `normalizePath()` for file paths
- Be careful with case-sensitive file systems

### CRAN Policy Violations

**Problem**: CRAN rejects the package for policy violations

**Solutions**:
- Review the [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- Common violations:
  - Writing to user's home directory (use `tempdir()`)
  - Opening graphics devices in examples
  - Not using `\donttest{}` for long-running examples
  - Missing references in DESCRIPTION

## Additional Checks (Optional)

For thorough testing before CRAN submission:

```r
# Check on multiple platforms with rhub v2
rhub::rhub_check()

# Check on Windows development version
devtools::check_win_devel()

# Check URLs
urlchecker::url_check()

# Spell check
spelling::spell_check_package()

# Check reverse dependencies (if any)
revdepcheck::revdep_check()
```

## Timeline

Typical timeline for a CRAN release:

- **Week 1**: Prepare release, run checks, fix issues
- **Week 2**: Submit to CRAN
- **Week 2-3**: CRAN review and potential resubmission
- **Week 3-4**: Acceptance and publication on CRAN

Plan releases accordingly, especially before major R releases or holidays.

## Resources

- [R Packages book](https://r-pkgs.org/) - Comprehensive guide to R package development
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html)
- [r-lib/actions](https://github.com/r-lib/actions) - GitHub Actions for R packages
- [R Hub v2](https://r-hub.github.io/rhub/) - Multi-platform package checking

## Getting Help

If you encounter issues:

1. Check the [GitHub Actions logs](https://github.com/arnops/tatooheene/actions)
2. Review the R Packages book and CRAN policies
3. Ask on [R-package-devel mailing list](https://stat.ethz.ch/mailman/listinfo/r-package-devel)
4. Check [Stack Overflow](https://stackoverflow.com/questions/tagged/r+cran) with tags `[r]` and `[cran]`
