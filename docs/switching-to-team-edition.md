# Switching an existing vault to the team edition

You ran `setup.sh` before the `--edition=team` flag existed, so you have a
**personal-edition** vault (it has `Personal/`, a personal Journal, and personal-life
areas). You want the **team / work edition** instead — an RS42 area, work-log daily
notes, and none of the personal-life machinery.

There are two routes. Pick by how much real work is already in the vault.

> The kit will **never auto-delete a vault that has your content.** Converting a
> non-empty vault is deliberately a manual, you-in-control procedure — so nothing
> you wrote can be lost to a script.

---

## Route A — the vault is empty (or only has starter content)

This is the common case for a freshly-onboarded collaborator who cloned, ran
`setup.sh`, and hasn't written anything yet. Just delete and regenerate:

```bash
# 1. Remove the empty personal-edition vault (nothing of yours is in it)
rm -rf <your-vault-path>

# 2. Get the latest kit (so --edition=team is available)
cd <path-to>/vault-setup-kit && git pull

# 3. Regenerate as the team edition
bash setup.sh --edition=team <your-vault-path>
```

Done — open `2. Projects/RS42/RS42-Onboarding/RS42-Onboarding.md` and start there.

---

## Route B — the vault already has real work in it

Don't delete it. Stand up a fresh team vault alongside it and move your content over.

```bash
# 1. Get the latest kit
cd <path-to>/vault-setup-kit && git pull

# 2. Generate a NEW, empty team-edition vault at a new path
bash setup-vault.sh --edition=team <new-work-vault-path>
```

3. **Move your own notes** from the old vault into the new one. Copy these folders'
   *contents* (your files, not the personal scaffolding):
   - `2. Projects/` → `2. Projects/RS42/` (your projects)
   - `6. Main Notes/`
   - `4. Contacts/`
   - `5. Resources/` (your own resources)
   - any real work logs from `1. Daily/`

4. **Do not copy** these — the team edition either ships its own or omits them on
   purpose:
   - `AGENTS.md` and `CLAUDE.md` (the team versions are already in the new vault)
   - `Personal/`, `3. Areas/Personal/`, and the `5. Resources/Personal/Journal/` tree

5. **Fix frontmatter on moved notes** as needed: change `area: personal` to
   `area: rs42` so they route into the RS42 dashboards.

6. **Re-point git** at the new vault: it gets its own initial commit from
   `setup-vault.sh`. Push it to your private repo and delete the old vault once you've
   confirmed everything moved.

---

## Why not an automatic converter?

Detecting "is this note yours or starter scaffolding?" reliably enough to delete
folders unattended is exactly the kind of guesswork that loses people's work. The
empty case (Route A) is a one-liner; the non-empty case (Route B) is a careful move
you should watch. If onboarding-on-the-wrong-edition becomes common, this is the
place a guarded helper script would land.
