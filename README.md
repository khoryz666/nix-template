# nix-template

A personal Nix flake template: a reusable, generic `flake.nix` + `.envrc` pair
that gives any project a reproducible, per-project development environment
managed by Nix and auto-loaded by direnv.

## 1. One-time machine setup (fresh Nix install, WSL or Linux)

Run these once per machine, right after installing Nix. After this, your
machine can spin up a ready dev environment for *any* project that has a
`flake.nix` — including ones created from this template.

```bash
# 1. Install Nix (multi-user daemon install) — if not already installed
sh <(curl -L https://nixos.org/nix/install) --daemon

# 2. Enable flakes (Nix's flake support is still an "experimental feature")
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# 3. Install direnv + nix-direnv (nix-direnv caches nix develop output so
#    direnv doesn't rebuild the shell from scratch on every `cd`)
nix profile install nixpkgs#direnv nixpkgs#nix-direnv

# 4. Hook direnv into your shell
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc   # or ~/.zshrc with `zsh`
source ~/.bashrc

# 5. Point nix-direnv at your direnv config
mkdir -p ~/.config/direnv
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
```

Once this is done, getting a dev environment for **any** Nix-managed project
is always the same two commands, run inside that project's directory:

```bash
cd some-project/   # contains a flake.nix + .envrc using `use flake`
direnv allow       # trust it once; environment loads automatically from now on
```

`cd` into the project → environment loads. `cd` out → it unloads. No manual
`nix develop`, no global installs, nothing leaking into other projects.

## 2. Using this repo to set up a new project

```bash
mkdir my-project && cd my-project
nix flake init -t github:yourname/nix-templates   # copies templates/default/ here
```

This drops two files into `my-project/`:

- `flake.nix` — a `devShells.default` with an empty `packages = [ ... ]` list
- `.envrc` — `use flake`

Then:

```bash
# Edit flake.nix: add this project's dependencies to `packages`
direnv allow

# Launch your editor from this same shell — it inherits the environment,
# no extra editor config needed
```

Ongoing:

```bash
cd my-project    # env auto-loads
cd ..            # env auto-unloads

# Changed flake.nix (added/removed a package)?
direnv allow     # re-approve and reload

# Want the exact same environment somewhere else (another machine, a
# teammate, CI)? Just copy flake.nix + flake.lock and run:
direnv allow

# Update pinned dependency versions deliberately:
nix flake update

# Nuke the local env for this project and start clean:
rm -rf .direnv

# Reclaim disk space across all projects occasionally:
nix-collect-garbage -d
```

Deploying what you built:

```bash
nix build                                # self-contained result/ output
# or, for a container:
# pkgs.dockerTools.buildLayeredImage      # reproducible image, no Dockerfile
```

## 3. Pipeline: how the dependency management works

```
 flake.nix                        flake.lock
 (inputs: nixpkgs,      lock -->  (pinned commit + hash
  packages = [...])                for every input)
      |                                  |
      +------------------+---------------+
                         |
                         v
              .envrc: "use flake"
                         |
                         v
        direnv (shell hook, watches cwd)
                         |
              cd into project dir
                         |
                         v
           direnv invokes `nix develop`
                         |
                         v
     Nix evaluates flake.nix against flake.lock
                         |
                         v
   Nix store resolves each package to a fixed,
   content-addressed path:
      /nix/store/<hash>-<name>-<version>/
                         |
                         v
      Shell environment assembled purely from
      those store paths (PATH, env vars, etc.)
                         |
                         v
   Editor / terminal launched from this shell
   inherits the exact same environment
                         |
              cd out of project dir
                         |
                         v
      direnv unloads env, shell PATH restored
```

Because every dependency resolves to an immutable, hash-addressed store
path pinned by `flake.lock`, the same `flake.nix` + `flake.lock` pair
reproduces an identical environment on any machine, at any later date.

## 4. The full workflow this repo implements

**One-time install** (machine-level, see Section 1):
1. Install Nix (multi-user daemon install)
2. Enable flakes in `~/.config/nix/nix.conf`
3. Install direnv + nix-direnv via `nix profile install`
4. Hook direnv into your shell rc (`~/.bashrc` / `~/.zshrc`)
5. Create a personal flake template repo (GitHub) with a generic
   `flake.nix` + `.envrc` — **this repo**

**Per new project:**
6. `mkdir project && cd project`
7. `nix flake init -t github:yourname/nix-templates`
8. Edit `packages = [ ... ]` in `flake.nix` for that project's deps
9. `direnv allow`
10. Launch your terminal editor from that same shell — it inherits
    everything, no extra config needed

**Ongoing use:**
11. `cd` in → env auto-loads; `cd` out → auto-unloads
12. Edit `flake.nix` anytime → `direnv allow` again to approve changes
13. Commit `flake.nix` + `flake.lock` to git; gitignore `.direnv/`

**Dispose / recreate:**
14. Dispose: `rm -rf .direnv` (or just delete the project folder)
15. Recreate the exact same env anywhere: copy `flake.nix` + `flake.lock`
    → `direnv allow`
16. Update deps deliberately: `nix flake update`
17. Global cleanup occasionally: `nix-collect-garbage -d`

**Deploy:**
18. `nix build` → self-contained result, or
19. `pkgs.dockerTools.buildLayeredImage` → reproducible container, no
    Dockerfile needed
