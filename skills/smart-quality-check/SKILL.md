# Smart Quality Check
**Purpose**: Run the appropriate quality assurance checks (ECS, Rector, PHPStan) depending on whether you are working in a Submodule or the Main Project.

## Context Detection
- **Submodule Mode**: If the current directory contains `composer.json` and a `vendor` directory (and is not the project root), treat it as a self-contained module.
- **Project Mode**: If the current directory is the project root (contains `src/` and `config/`), treat it as the main application.

## Workflow

### 1. Detect Context & Navigate
Determine if we should run in the current directory or `src/`.

### 2. Run Checks (Auto-Fix enabled for ECS)

#### Case A: Submodule (Library)
Run checks on the **current directory (`.`)**.
```bash
vendor/bin/ecs check . --fix
./vendor/bin/rector process --no-progress-bar .
vendor/bin/phpstan analyse -c phpstan.neon.dist .
```

#### Case B: Main Project (Application)
Run checks on the **source directory (`src/`)**.
```bash
vendor/bin/ecs check src/. --fix
./vendor/bin/rector process --no-progress-bar src
vendor/bin/phpstan analyse -c phpstan.neon.dist src/.
```

### 3. Handle Dependency Errors (Fallback Patching)
If PHPStan fails due to errors in `vendor/` files (e.g. missing types in dependencies):
1. **Identify the Vendor File**: Check the error log for paths inside `vendor/`.
2. **Apply Local Patch**: Use `sed` to patch the vendor file directly (e.g. adding missing property types).
3. **Re-run Analysis**: Confirm checks pass with the patch.
4. **Note the Issue**: Inform the user that a dependency issue was patched locally and ideally requires an upstream fix.

### 4. Report Changes
Present a summary of all changes made during the session (automatic or manual).
- Use `git diff` to show specific code changes.
- Summarize the nature of fixes (e.g. "Fixed type hint", "Imported missing class").

## User Preferences Captured
- **Assignments**: Align with spaces (e.g. `$var       = ...`).
- **Arrays**: Always use trailing commas.
- **Workflow**: Auto-fix ECS, Run Rector silent, Analyze with PHPStan.
- **Reporting**: Always show a summary of changes (git diff or list of modified files) at the end.
