## Workflow

_This is a work in progress_

### Preparation
* Set up a repo for secrets.
* Set up a `~/.sanitizer` noting the secrets location, patterns, etc. (not available yet)

### For each repo
We think it's a good idea to verify that the round trip - manifest to sanitized manifest and back - works before committing it.

* are there pipelines which use this repo? update those appropriately.
* set up a direnv, with the subfolder for this repo (not available yet)
* sanitize - first, do the yaml normalization. commit? (not available yet)
* run `sanitizer` to templatize secrets
* look at files for missed secrets, manually add them (not available yet)
* commit the sanitized templates, but don't push yet!
* run `desanitizer` and compare to the committed versions - `git diff head~1` (or `~2` if there was a commit for the normalized version)
* commit the sanitized version
* commit and push secrets
* commit and push the sanitized repo

## Generating manifests
If you generate manifests, you should regenerate secrets; some items are position-sensitive.

* clear the old secrets files
* sanitize the manifests again
* commit new manifests and secrets

## Best practices
* in the regex files, give each regex its own line - `(oneregex|tworegex|three)` is less readable