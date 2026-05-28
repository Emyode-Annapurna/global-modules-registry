#!/usr/bin/env bash
set -euo pipefail

MODULE_PATH="$1"
BUMP_TYPE="${2:-patch}"
TRACK_FILE="module_versions.md"

GITHUB_ORG="Emyode-Annapurna"
GITHUB_REPO="global-modules-registry"

if [[ -z "${MODULE_PATH}" ]]; then
  echo "MODULE_PATH is required (e.g. azure/network/vnet)" >&2
  exit 1
fi

# Ensure we have tags (useful in CI)
git fetch --tags --quiet || true

############################
# 1) BUMP + TAG ONE MODULE #
############################

# 1.1 Latest commit that touched this module path
TARGET_COMMIT=$(git log -1 --format=%H -- "${MODULE_PATH}" || true)

if [[ -z "${TARGET_COMMIT}" ]]; then
  echo "No commits found for path ${MODULE_PATH}" >&2
  TARGET_COMMIT_SHORT=""
  TARGET_COMMIT_MSG=""
  TARGET_COMMIT_DATE=""
else
  TARGET_COMMIT_SHORT=$(git log -1 --format=%h -- "${MODULE_PATH}")
  TARGET_COMMIT_MSG=$(git log -1 --format=%s -- "${MODULE_PATH}")
  TARGET_COMMIT_DATE=$(git show -s --format=%ci "${TARGET_COMMIT}")
fi

# 1.2 Last tag for this module (semantic, descending)
LAST_TAG=$(git tag --list "${MODULE_PATH}/v*" --sort=-v:refname | head -n1 || true)

if [[ -z "${LAST_TAG}" ]]; then
  CURRENT_VERSION="v0.0.0"
else
  CURRENT_VERSION="${LAST_TAG##*/}"
fi

VERSION="${CURRENT_VERSION#v}"
IFS='.' read -r MAJOR MINOR PATCH <<< "${VERSION}"

if [[ -n "${TARGET_COMMIT}" ]]; then
  case "${BUMP_TYPE}" in
    major)
      MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0;;
    minor)
      MINOR=$((MINOR + 1)); PATCH=0;;
    patch)
      PATCH=$((PATCH + 1));;
    *)
      echo "Unknown bump type: ${BUMP_TYPE} (use major|minor|patch)" >&2
      exit 1;;
  esac

  NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
  NEW_TAG="${MODULE_PATH}/${NEW_VERSION}"

  echo "Module path:    ${MODULE_PATH}"
  echo "Target commit:  ${TARGET_COMMIT}"
  echo "Current version ${CURRENT_VERSION} -> ${NEW_VERSION}"
  echo "New tag:        ${NEW_TAG}"

  # 1.3 If last tag already points to this commit, skip bump
  if [[ -n "${LAST_TAG}" ]]; then
    LAST_COMMIT_FOR_TAG=$(git rev-list -1 "${LAST_TAG}")
    if [[ "${LAST_COMMIT_FOR_TAG}" == "${TARGET_COMMIT}" ]]; then
      echo "Latest tag ${LAST_TAG} already points to ${TARGET_COMMIT}. Nothing to bump."
      NEW_TAG=""
      NEW_VERSION=""
    fi
  fi

  # 1.4 Create tag on the module's last commit if needed
  if [[ -n "${NEW_TAG}" ]]; then
    git tag "${NEW_TAG}" "${TARGET_COMMIT}"
  fi
else
  echo "No commit for ${MODULE_PATH}, skipping bump."
  NEW_TAG=""
  NEW_VERSION=""
fi

##############################################
# 2) REGENERATE module_versions.md FROM TAGS #
##############################################

TMP_FILE="$(mktemp)"

cat > "${TMP_FILE}" <<EOF
# Terraform modules – version tracking

| Module path | Version | Status | Last updated | Last commit | Tag & Terraform source |
|-------------|---------|--------|--------------|-------------|------------------------|
EOF

# List all tags matching the monorepo pattern: azure
while IFS= read -r tag; do
  # Example tag: azure/network/vnet/v1.0.0
  MODULE_PATH_TAG="${tag%/v*}"
  VERSION_TAG="${tag##*/}"
  echo "${MODULE_PATH_TAG} ${VERSION_TAG}"
done < <(git tag -l "azure/*/*/v*" | sort) \
  | awk '
    {
      path = $1;
      ver  = $2;

      if (!(path in maxver) || ver > maxver[path]) {
        maxver[path] = ver;
      }
    }
    END {
      for (p in maxver) {
        print p, maxver[p];
      }
    }
  ' | sort -k1,1 | while read -r path ver; do
    TAG="${path}/${ver}"

    COMMIT_HASH=$(git rev-list -1 "${TAG}")
    COMMIT_SHORT=$(git rev-parse --short "${COMMIT_HASH}")
    COMMIT_MSG=$(git show -s --format=%s "${COMMIT_HASH}")
    COMMIT_DATE=$(git show -s --format=%ci "${COMMIT_HASH}")

    SAFE_COMMIT_MSG=$(echo "${COMMIT_MSG}" | sed 's/|/-/g')

    STATUS_BADGE="![stable](https://img.shields.io/badge/status-stable-brightgreen)"

    TAG_LINK="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/tree/${TAG}/${path}"

    TF_SOURCE="git::https://github.com/${GITHUB_ORG}/${GITHUB_REPO}.git//${path}?ref=${TAG}"

    echo "| ${path} | ${ver} | ${STATUS_BADGE} | ${COMMIT_DATE} | \`${COMMIT_SHORT}\` ${SAFE_COMMIT_MSG} | [view](${TAG_LINK})<br>\`${TF_SOURCE}\` |" >> "${TMP_FILE}"
  done

mv "${TMP_FILE}" "${TRACK_FILE}"

#######################################
# 3) OUTPUTS FOR GITHUB ACTIONS JOBS  #
#######################################

echo "new_tag=${NEW_TAG:-}" >> "${GITHUB_OUTPUT:-/dev/stdout}"
echo "new_version=${NEW_VERSION:-}" >> "${GITHUB_OUTPUT:-/dev/stdout}"