### :star: GitHub Actions workflow

#### :one: Tagging and labels for module releases

[tag_modules](https://github.com/Emyode-Annapurna/global-modules-registry/blob/main/.github/workflows/tag_modules.yml)

- This workflow automatically tags Terraform modules when a pull request (PR) is merged into
> **It relies heavily on labels on the PR to decide what to do**

#### When does the workflow run?
- The workflow runs when:

 - A pull request targeting main is closed (merged or closed without merge).

- The job only continues if:

- The PR was merged, and

- The PR does not have the unstable label.

- In other words:

- Merged + no unstable label **tagging logic runs**

- Merged + unstable label **workflow is skipped**

- Closed without merge **workflow is skipped**

### :two: Required labels for normal releases
> **For any PR that changes one or more modules under [azure](https://github.com/EmpireLife/backoffice-infrastructure/tree/main/azure) and is meant to be released, you must add exactly one semantic‑versioning label:**

- :label: semver:major

- :label: semver:minor

- :label: semver:patch

#### The workflow scans all labels on the PR and chooses the bump type:

- If it finds semver:major → bump type is major.

- Else if it finds semver:minor → bump type is minor.

- Else if it finds semver:patch → bump type is patch.

- If none of these labels is present and modules changed, the job fails with an error and asks you to add one of the semver labels.

**This bump type is used only for existing modules that already have tags**

### :three: Special labels
:label: unstable

- Use unstable when you do not want any tags or module version changes for this PR.

- If unstable is present, the whole job is skipped, even if:

- Modules changed, or

- Semver labels are set.

##### Typical use cases:

- WIP PRs that must merge but should not trigger releases.

- Internal refactors or experiments where you don’t want consumers to see a new module version.

### first_module_tag

**This label is for onboarding modules that do not yet have any tags.**

### It has two behaviors:

#### :one: For new modules touched by this PR (no existing tags):

- If the PR has first_module_tag, those modules get their first tag.

- The bump type is fixed to major for first tags.

- Changelogs are generated for those modules.

#### :two: For global onboarding (all modules):

> **If first_module_tag is present, an extra step runs that:**

- Scans all module directories under [azure](https://github.com/EmpireLife/backoffice-infrastructure/tree/main/azure) that have a main.tf.

- Finds modules with no tags yet.

- Gives each of them a first major tag and creates a minimal changelog entry.

:vertical_traffic_light: Use this label when:

- You introduce brand‑new modules and want to cut their first version.

- You want to bulk‑onboard all existing untagged modules into the versioning system.

### :four: How modules are detected

> **The workflow automatically detects which modules changed in the PR:**

- It computes the range between the PR base commit and the merge (or head) commit.

- It inspects changed files in that range.

- Any file whose path matches [azure](https://github.com/EmpireLife/backoffice-infrastructure/tree/main/azure) is treated as part of a module, where the module path is [azure](https://github.com/EmpireLife/backoffice-infrastructure/tree/main/azure)

> **Then it splits them into:**

Existing modules: modules that already have one or more tags matching <module_path>/v* (e.g. azure/network/vpc/v1.2.3).

New modules: modules under [azure](https://github.com/EmpireLife/backoffice-infrastructure/tree/main/azure) that have no tags yet.

If no modules are detected, the workflow exits early and does nothing.

### :five: How tagging works
**Existing modules**

#### For each existing module that changed:

- The workflow determines the bump type from the semver label (major, minor, or patch).

- It calls .github/scripts/bump-and-track.sh <module_path> <bump_type>, which:

- Calculates the next semver version.

- Creates a new Git tag in the format <module_path>/vX.Y.Z (for example, azure/network/vpc/v1.3.0).

- Updates module_versions.md (implementation is in the script).

- It writes/updates a changelog file in changelogs/<module_path_with_slashes_replaced>.md containing:

- The new version.

- Release date (from the tag commit).

- A summary section placeholder.

- A list of all commits in the PR affecting that module.

- Links back to the module path and the tag.

**New modules (per‑PR onboarding)**

#### For new modules that changed in the PR:

- If the PR includes first_module_tag:

- Each new module gets a first tag using a major bump.

- A changelog is created similar to existing modules, but the summary says it is the first tagged release.

> **If the PR does not include first_module_tag:**

- The workflow prints a message and skips first tagging for these new modules.

- They will remain unversioned until a future PR with first_module_tag.

#### Global onboarding (all untagged modules)
> **If the PR has first_module_tag, regardless of whether any modules changed:**

- The workflow looks for every directory under azure/** that contains main.tf.

- It filters to modules that currently do not have any <module_path>/v* tags.

- It assigns a first major tag to each of them via bump-and-track.sh.

- It generates minimal changelog entries for those modules (no per‑PR commit list; just a summary and release date).

> **This is a one‑time or rare operation, not something you typically do on every PR.**

### :six: Commit and push behavior
**At the end, if any of the following happened:**

- Existing modules were bumped, or

- New modules were first‑tagged from the PR, or

- Global onboarding with first_module_tag ran,

#### then the workflow:

- Stages module_versions.md and changelogs/**.

- If there are changes:

- Commits with message:
chore: auto tag modules on PR merge (<bump_type>)
(bump_type is from the semver label; may be empty for pure onboarding).

- Pushes the commit to main.

- Pushes all created tags to the remote.

### :seven: How to use this in practice
**Normal module change**

:one: Open a PR that changes one or more modules under [azure](https://github.com/EmpireLife/backoffice-infrastructure/tree/main/azure)

:two: Add exactly one of:

- :label: semver:major

- :label: semver:minor

- :label: semver:patch

:three: Do not add unstable.

:four: Merge the PR into main.

#### Result:

- Each changed existing module gets a new tag and changelog entry.

- New modules (no tags yet) remain untagged unless you also add first_module_tag.

#### First release of new modules only
:one: Open a PR that introduces or modifies new modules (no tags yet).

:two: Add one semver label to indicate the nature of changes for existing modules (if any).

:three: Add first_module_tag.

#### Result:
- Existing modules are bumped according to the semver label.

- New modules touched by the PR get their first major tag and changelog.

#### Global onboarding of all untagged modules
:one: Create a PR (even a no‑op change) that you plan to merge to main.

:two: Add first_module_tag.
Optionally also add a semver label if existing modules are changed and you want them bumped too.

:three: Merge the PR.

#### Result:

- All modules under azure/** with a main.tf and no existing tag get a first major tag.

- Changelogs and module_versions.md are updated.

- Existing modules are bumped if semver labels are present and they changed.

### Reference: label summary

| Label           | Required?             | Effet                                                                                       |
|----------------|-----------------------|---------------------------------------------------------------------------------------------|
| `semver:major` | Yes (for releases)    | Bumps existing modules by a **major** version when changed in the PR.                      |
| `semver:minor` | Yes (for releases)    | Bumps existing modules by a **minor** version when changed in the PR.                      |
| `semver:patch` | Yes (for releases)    | Bumps existing modules by a **patch** version when changed in the PR.                      |
| `unstable`     | Optional              | Skips the workflow entirely, no tags or changelog updates.                                 |
| `first_module_tag` | Optional          | First-tags new modules touched by the PR and globally onboards all previously untagged modules. |
