# nixfigs monolith integration plan

Plan for integrating sibling `../nixfigs-*` repositories into this monolithic repo (`nixfigs-refactor-mk-v`).

## Goals

- Consolidate the in-scope split flakes/repos into this monolith while preserving current behavior and outputs.
- Keep changes incremental, reviewable, and verifiable (one repo/logical group per commit).
- Remove now-redundant external `nixfigs-*` flake inputs once their contents are fully local and wired up.

## Out of scope / keep external

Do **not** integrate the following; keep them as external repos/inputs as applicable:

- `../nixfigs`
- `../nixfigs-work-container`
- `../nixfigs-*-private` (all private variants)
- `../shypkgs-private`
- `../nixfigs-secrets*`
- `../nixfigs-networks`
- `../hypr-dotw2k`

Note: `nixfigs-work` is in scope for integration (per request), but review its contents for sensitivity before committing into a public/shared monolith.

## Current state (baseline)

- Monolith already contains the core structure: `flake.nix`, `nix-support/`, `hosts/` (declarations + nixos/darwin/homes), `src/modules/{core,nixos,home,darwin}`, `src/systems/`, `src/homes/`, `packages/`, `overlays/`, `lib/`.
- Helpers/roles/systems and much common/hypr/home/package/overlay logic are already present locally in some form; integration should diff/merge and dedupe rather than blindly copy.
- `flake.lock` still references external inputs that are integration targets (e.g. `nixfigs-devenvs`, `nixfigs-doom-emacs-personal`); other targets may be partially reflected but still need to become source-of-truth here.
- `nixfigs-nur` appears effectively empty in `../` (verify before planning work). `nixfigs.template-nix` is a template derived from nixfigs and can be used as reference.

## Target mapping

| Source repo | Destination in monolith | Notes |
|---|---|---|
| `nixfigs-helpers` | `lib/`, `nix-support/{formatter,checks,devshell}.nix` (and related) | Largely aligned already; diff/merge and drop helper-flake indirection. |
| `nixfigs-roles` | `nix-support/roles.nix` | Already present; reconcile and keep local as source of truth. |
| `nixfigs-pkgs` | `packages/`, `overlays/`, `flake.nix` (`nixpkgs-config`) | Merge `pkgs/*` and `overlays/*`; reconcile with `overlays/default.nix` and existing package patches. |
| `nixfigs-common` | `src/modules/core/`, `src/modules/nixos/`, `src/modules/darwin/` (+ `home-manager`/`wsl`/`android` modules if needed) | Replace external common imports; resolve local diffs (e.g. core modules, missing patches/assets). |
| `nixfigs-homes` | `src/homes/`, `hosts/homes/`, `src/modules/home/` | Merge home configs/modules; align arg conventions (`lib`/`extraSpecialArgs`, host/user attrs) with monolith wiring. |
| `nixfigs-hypr` | `src/modules/home/{hypr,waybar,swaync,kanshi,win2k,wpaperd,...}`, `packages/`, `overlays/` | Dedupe with existing Hypr/home modules; fold overrides/patches into local packages/overlays. |
| `nixfigs-public` | `hosts/declarations/`, `src/systems/`, `src/modules/nixos/` (and darwin as needed) | Merge host definitions/configs/modules; adapt to monolith `mkHost`/`hosts/*/default.nix` conventions. |
| `nixfigs-work` | `hosts/declarations/`, `src/systems/`, `src/modules/` (scoped appropriately) | In scope; audit for sensitive/work-specific material before inclusion. |
| `nixfigs-devenvs` | `templates/` and `flake.nix` `outputs.templates` | Vendor templates, expose locally (e.g. `templates = import ./templates;` or attrset), remove `inputs.nixfigs-devenvs`. |
| `nixfigs-doom-emacs` | `config/doom-emacs/` (or another local config path, referenced by home modules) | Non-flake config; vendor and replace `inputs.nixfigs-doom-emacs-personal` with a local path ref. |
| `nixfigs-wallpapers` | `assets/wallpapers/` (or keep as a pinned/path input) | Asset-heavy repo: decide vendoring vs pinned/path input; if inlined, update consumers and drop `inputs.nixfigs-wallpapers`. |
| `nixfigs-virtual` | `virtual/` or `src/virtual/` (+ flake outputs if required) | Integrate if `oci`/`libvirt`/`nspawn` outputs or definitions are needed; otherwise defer. |
| `nixfigs-nur` | TBD (only if content exists) | Verify contents first; skip if empty/unused. |

## Integration workflow

1. **Prepare**
   - Start from a clean working tree on a branch.
   - Integrate one repo or a small logical group per step; commit incrementally (and squash/rebase into logical commits when done).

2. **Bring code in** (pick per repo)
   - *Snapshot (preferred when structure has diverged):* copy needed contents (exclude `.git`, `.direnv`, `flake.lock`, generated/irrelevant dirs), place into the mapped destinations, and discard the rest.
   - *Preserve history (optional):* `git subtree add --prefix=vendor/nixfigs-<name> ../nixfigs-<name> <ref> [--squash]`, relocate into the monolith layout, then remove the staging prefix.

3. **Wire into the monolith**
   - Update imports/module lists, `hosts/declarations`, `src/systems`/`src/homes` paths, and `flake.nix` outputs.
   - Replace `inputs.nixfigs-*` usages for integrated repos with local paths/modules.
   - Keep out-of-scope/private repos external (inputs/follows) as required.

4. **Reconcile and dedupe**
   - Align module argument/signature conventions across merged code (`lib` vs `libx`, `genPkgs`, `hostType`/`hostRoles`, HM embedding style, etc.).
   - Dedupe overlapping modules, packages, overlays, and patches; prefer a single canonical implementation.

5. **Format, lock, and verify (each step)**
   - For `.nix` edits, follow the repo's Nix formatting conventions/skill.
   - Run: `nix fmt` (if configured), then `nix flake lock` when inputs change, `nix flake show`, `nix flake check`.
   - Run targeted builds where practical, e.g. `nix build .#nixosConfigurations.<HOST>.config.system.build.toplevel` for affected hosts.

6. **Finalize**
   - Remove unused flake inputs/follows and any temporary `vendor/` staging paths.
   - Update docs (`README.md`, `docs/`) to reflect the monolithic layout.
   - Rebase/squash into logical, composable commits. When committing with assistance, include trailer: `Assisted-by: OpenCode <noreply@opencode.ai>`.

## Suggested integration order

1. `nixfigs-helpers` + `nixfigs-roles` (foundation: `lib/`, `nix-support/`)
2. `nixfigs-pkgs` (packages/overlays/nixpkgs config)
3. `nixfigs-common` (core/nixos/darwin base modules)
4. `nixfigs-homes` + `nixfigs-hypr` (home configs/modules and desktop components)
5. `nixfigs-public` (+ `nixfigs-work`, after review) (hosts/systems/modules)
6. `nixfigs-devenvs` (templates) and `nixfigs-doom-emacs` (local config)
7. `nixfigs-wallpapers`, `nixfigs-virtual`, `nixfigs-nur` (as needed, after content/size review)

## Risks / notes

- **Convention drift:** merged repos use slightly different module args and composition patterns; normalize carefully to avoid evaluation breakage.
- **Duplicate/conflicting logic:** Hyprland patches/overrides and home modules exist in multiple places—consolidate to one source of truth.
- **Secrets/sensitivity:** do not pull in out-of-scope/private repos; audit `nixfigs-work` before merging.
- **Large assets/history:** wallpapers and history-preserving imports can bloat the repo; prefer pinned inputs or shallow/squashed strategies where appropriate.
- **Flake input cleanup:** after inlining, remove stale inputs/follows from `flake.nix` and regenerate `flake.lock` to keep evaluation reproducible.
