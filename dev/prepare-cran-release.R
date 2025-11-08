# CRAN Release Preparation Script
# This script helps prepare the package for CRAN submission
# Run this locally before triggering the GitHub Actions release workflow

# Load required packages
library(devtools)
library(usethis)

cat("\n=== CRAN Release Preparation ===\n\n")

# Step 1: Check current version
current_version <- desc::desc_get_version()
cat("Current version:", as.character(current_version), "\n")

# Step 2: Prompt for version increment
cat("\nDo you want to increment the version? (y/n): ")
increment <- readline()

if (tolower(increment) == "y") {
  cat("\nSelect version increment type:\n")
  cat("1. Patch (0.0.x)\n")
  cat("2. Minor (0.x.0)\n")
  cat("3. Major (x.0.0)\n")
  cat("4. Custom\n")
  cat("Choice: ")
  choice <- readline()

  if (choice == "1") {
    usethis::use_version("patch")
  } else if (choice == "2") {
    usethis::use_version("minor")
  } else if (choice == "3") {
    usethis::use_version("major")
  } else if (choice == "4") {
    cat("Enter new version (e.g., 0.20.0): ")
    new_version <- readline()
    usethis::use_version(new_version)
  }

  new_version <- desc::desc_get_version()
  cat("\nVersion updated to:", as.character(new_version), "\n")
} else {
  new_version <- current_version
}

# Step 3: Remind to update NEWS.md
cat("\n=== ACTION REQUIRED ===\n")
cat("Please update NEWS.md with changes for version", as.character(new_version), "\n")
cat("Template:\n")
cat("# tatooheene", as.character(new_version), "\n")
cat("\n## New Features\n")
cat("* \n")
cat("\n## Improvements\n")
cat("* \n")
cat("\n## Bug Fixes\n")
cat("* \n")
cat("\n## Documentation\n")
cat("* \n\n")
cat("Press Enter when NEWS.md is updated...")
readline()

# Step 4: Update documentation
cat("\n=== Updating Documentation ===\n")
devtools::document()
cat("Documentation updated.\n")

# Step 5: Run tests
cat("\n=== Running Tests ===\n")
test_results <- devtools::test()
if (any(test_results$failed > 0)) {
  stop("Tests failed! Please fix before continuing.")
}
cat("All tests passed.\n")

# Step 6: Check package
cat("\n=== Running R CMD check ===\n")
cat("This may take a few minutes...\n")
check_results <- devtools::check(
  cran = TRUE,
  remote = TRUE,
  manual = TRUE,
  vignettes = TRUE
)

if (length(check_results$errors) > 0) {
  cat("\n!!! ERRORS FOUND !!!\n")
  print(check_results$errors)
  stop("Fix errors before proceeding.")
}

if (length(check_results$warnings) > 0) {
  cat("\n!!! WARNINGS FOUND !!!\n")
  print(check_results$warnings)
  cat("\nDo you want to continue despite warnings? (y/n): ")
  continue <- readline()
  if (tolower(continue) != "y") {
    stop("Aborted due to warnings.")
  }
}

cat("\nNotes:\n")
print(check_results$notes)

# Step 7: Build package
cat("\n=== Building Source Package ===\n")
tarball <- devtools::build(manual = TRUE, vignettes = TRUE)
cat("Source package built:", tarball, "\n")

# Step 8: Update cran-comments.md
cat("\n=== Updating cran-comments.md ===\n")
cran_comments <- sprintf(
  "## R CMD check results

There were no ERRORs, %d WARNING(s), and %d NOTE(s).

### Warnings

%s

### Notes

%s

## Test environments

* local: %s
* GitHub Actions:
  - ubuntu-latest (R-release, R-devel, R-oldrel-1)
  - windows-latest (R-release)
  - macos-latest (R-release)

## Downstream dependencies

There are currently no downstream dependencies for this package.
",
  length(check_results$warnings),
  length(check_results$notes),
  ifelse(length(check_results$warnings) > 0,
         paste("*", check_results$warnings, collapse = "\n"),
         "None"),
  ifelse(length(check_results$notes) > 0,
         paste("*", check_results$notes, collapse = "\n"),
         "None"),
  R.version.string
)

writeLines(cran_comments, "cran-comments.md")
cat("cran-comments.md updated.\n")

# Step 9: Summary and next steps
cat("\n=== PREPARATION COMPLETE ===\n\n")
cat("Summary:\n")
cat("- Version:", as.character(new_version), "\n")
cat("- Errors:", length(check_results$errors), "\n")
cat("- Warnings:", length(check_results$warnings), "\n")
cat("- Notes:", length(check_results$notes), "\n")
cat("- Source tarball:", tarball, "\n")

cat("\n=== NEXT STEPS ===\n\n")
cat("1. Review all changes and ensure NEWS.md is complete\n")
cat("2. Commit all changes:\n")
cat("   git add .\n")
cat("   git commit -m 'Prepare for CRAN release v", as.character(new_version), "'\n", sep = "")
cat("   git push\n\n")
cat("3. Trigger the GitHub Actions release workflow:\n")
cat("   - Go to: https://github.com/arnops/tatooheene/actions/workflows/cran-release.yaml\n")
cat("   - Click 'Run workflow'\n")
cat("   - Enter version:", as.character(new_version), "\n\n")
cat("4. After successful workflow:\n")
cat("   - Download the tarball from the GitHub release\n")
cat("   - Submit to CRAN: https://cran.r-project.org/submit.html\n")
cat("   - Monitor email for CRAN feedback\n\n")

cat("=== Optional: Additional Checks ===\n\n")
cat("You may also want to run:\n")
cat("- rhub::rhub_check() # rhub v2 for additional platform checks\n")
cat("- devtools::check_win_devel() # Windows development version check\n")
cat("- urlchecker::url_check() # Check all URLs in documentation\n")
cat("- spelling::spell_check_package() # Check spelling\n\n")
