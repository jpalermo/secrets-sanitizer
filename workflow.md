## Workflow

_This is a work in progress_

### Preparation
* Set up a repo for secrets.
* Set up a `~/.sanitizer` noting the secrets location, patterns, etc. (not available yet)

### For each repo
* set up a direnv, with the subfolder for this repo (not available yet)
* sanitize - first, do the yaml normalization. commit? (not available yet)
* run `sanitizer` to templatize secrets
* look at files for missed secrets, manually add them (not available yet)
* run `desanitizer` and compare to the committed versions
* commit the sanitized version
* commit and push secrets
* commit and push the sanitized repo

## Deploying
* sync repos, both the sanitized manifests and the secrets
* desanitize the manifests and stubs
* generate manifests
* deploy
* clear the old secrets files
* sanitize the manifests again
* commit new manifests and secrets

## Best practices
* in the regex files, give each regex its own line - `(oneregex|tworegex|three)` is less readable