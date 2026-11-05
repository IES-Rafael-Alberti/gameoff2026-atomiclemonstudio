# itch.io auto-publish: butler, CI/CD and repository setup

How ColorShift is built and published to itch.io from GitHub Actions.

- Game page: <https://atomic-lemon-studio.itch.io/colorshift>
- Flow: pull request to `main` builds the Web export; merging into `main` builds it and publishes it with butler.

## Status

| Item | State |
|---|---|
| Web export preset (`ColorShift/export_presets.cfg`, Compatibility renderer, no threads) | Done |
| Lowercase folders, so the project works on the Linux runner | Done |
| butler: itch.io project, first upload, API key | Pending |
| Repository variables and secret | Pending |
| Workflow `.github/workflows/itch.yml` | Pending |
| Branch protection on `main` | Pending |

---

## 1. butler (itch.io side)

butler is itch.io's command-line uploader. It sends only the files that changed, so later pushes are fast.

### Project setup
1. The itch.io project's *Kind of project* must be **HTML**.
2. Keep the page **Draft / Restricted** until the final release.
3. Make the **first upload by hand**, from `ColorShift/` after exporting:
   ```bash
   butler push build/web atomic-lemon-studio/colorshift:html
   ```
   Syntax: `butler push <folder> <user>/<game>:<channel>`. The channel name is free; we use `html`, and always the same one, so each push updates the same file.
4. After that first upload, open *Edit game* and tick **"This file will be played in the browser"** for it. butler cannot do this: it has to be done from the web page once the first build exists.
5. Set the embed viewport (the project is 1024×768) and enable the fullscreen button.

### Useful flags
- `--userversion <text>`: version label shown on itch.io (we pass the short commit SHA).
- `--if-changed`: skip the push when the files are identical to the latest build.
- `--dry-run`: show what would be pushed without uploading.

### API key
1. Run `butler login` locally (download butler from <https://itch.io/docs/butler/>).
2. Copy the key from `%USERPROFILE%\.config\itch\butler_creds`, or from <https://itch.io/user/settings/api-keys>, where the key you need has its *source* set to `wharf`.
3. Never paste it in chat, commits or issues. If it ever appears in a public log, revoke it on the API keys page.

In CI, butler reads the key from the `BUTLER_API_KEY` environment variable.

---

## 2. CI/CD (GitHub Actions)

File: `.github/workflows/itch.yml` (to be written).

### Triggers

| Event | What it does |
|---|---|
| `pull_request` to `main` | Builds the Web export only. Nothing is published. |
| `push` to `main` | Builds the Web export and publishes it with butler. |

Since `main` is protected (section 3), the only push that can reach it is a merged PR. So "publish on push to `main`" means "publish only when a PR is merged". `develop` does not publish.

There is deliberately no manual trigger (`workflow_dispatch`): it would allow publishing without a PR.

### Steps
1. Run on `ubuntu-24.04`, in the `barichello/godot-ci` container, after `actions/checkout@v4`.
2. Move the export templates to `~/.local/share/godot/export_templates/<version>.stable`, as the godot-ci reference workflow does.
3. From `ColorShift/`:
   ```bash
   godot --headless --export-release "Web" build/web/index.html
   ```
4. Fail if `build/web/index.html` is missing.
5. **Only on `push`:** install butler and run
   ```bash
   butler push build/web "$ITCHIO_USERNAME/$ITCHIO_GAME:html" --userversion "<short SHA>"
   ```
6. Add a `concurrency` group so two quick merges do not overlap.

### Godot version
- The Docker image, the export templates and the project must use the **exact same** Godot version.
- The local editor is 4.7.1; the latest stable release is 4.7.2.
- Not confirmed yet: whether a `barichello/godot-ci` tag exists for that version. Check <https://hub.docker.com/r/barichello/godot-ci> first. If there is no tag, download the Godot binary and templates in the workflow instead.

### Releases
- Every merge into `main` refreshes the `html` channel on itch.io, and the page stays private until the end.
- For the final build (`v1.0`): after the last merge, create the tag and GitHub Release on `main`. The tag only labels the commit and does not trigger a second publish.
- For the submission: make the page public and check it from a browser with no session.

---

## 3. Repository configuration

### Variables and secret
In **Settings → Secrets and variables → Actions** (admin rights needed):

| Name | Type | Value |
|---|---|---|
| `ITCHIO_USERNAME` | Variable | `atomic-lemon-studio` |
| `ITCHIO_GAME` | Variable | `colorshift` |
| `BUTLER_API_KEY` | **Secret** | the butler key from section 1 |

The first two are public, so they are variables. Only the key is a secret.

From the terminal:
```bash
R=IES-Rafael-Alberti/gameoff2026-atomiclemonstudio
gh variable set ITCHIO_USERNAME --repo $R --body "atomic-lemon-studio"
gh variable set ITCHIO_GAME     --repo $R --body "colorshift"
gh secret set BUTLER_API_KEY    --repo $R   # paste the key when asked
```
`gh secret set` without `--body` keeps the key out of your shell history. Check with `gh variable list --repo $R` and `gh secret list --repo $R` (names only).

The workflow reads them as `${{ vars.ITCHIO_USERNAME }}`, `${{ vars.ITCHIO_GAME }}` and `${{ secrets.BUTLER_API_KEY }}`.

Optional: put them in a GitHub *Environment* called `itch`, restricted to the `main` branch, so no other branch can use the key.

### Protecting `main`
Write the workflow first and let it run once on a PR, so the check name exists. Then add a rule for `main` in **Settings → Branches** (or Rulesets):

- Require a pull request before merging, with at least 1 approval.
- Require the build check to pass.
- Block force pushes and branch deletion.
- Apply the rule to administrators too, so nobody can bypass it.

Branch protection on a private repository may need a paid plan. Check this for the repo.

### Files the CI relies on
- `ColorShift/export_presets.cfg`: preset `Web`, `variant/thread_support=false`, export path `build/web/index.html`. It holds no secrets, so it is committed.
- `ColorShift/.gitignore` ignores `build/`.
- All project folders are lowercase (`scenes/`, `scripts/`, `assets/`): the runner is Linux and case-sensitive, so a mix of `Scripts/` and `scripts/` would break the build.

---

## Sources
- butler push: <https://itch.io/docs/butler/pushing.html>
- butler login and CI: <https://itch.io/docs/butler/login.html>
- godot-ci: <https://github.com/abarichello/godot-ci>
- godot-ci reference workflow: <https://github.com/abarichello/godot-ci/blob/master/.github/workflows/godot-ci.yml>
- Godot releases: <https://github.com/godotengine/godot/releases>
