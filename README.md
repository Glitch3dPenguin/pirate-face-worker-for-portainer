# pf-worker — Pirate Face work lanes as a docker-compose stack

One container = one `pf work` lane = one queued model at a time, streamed from
Hugging Face, torrent built in memory, submitted to Pirate Face. No model bytes
ever touch disk; the only state is the lease checkpoint, kept in the per-worker
volume.

## Deploy (Portainer)
1. Put these files in a git repo (the `.github/workflows/build-image.yml`
   workflow builds + pushes the image to `ghcr.io/<owner>/<repo>` on push, on a
   daily schedule, and on demand — it resolves the current PyPI latest at build
   time and tags the image `:latest` + `:<version>`).
2. Make the GHCR package **public** (package settings) — machines then pull
   anonymously. Private = add one registry credential in Portainer instead.
3. Set the per-machine `LANE_NAME`s in `docker-compose.yml` (the image
   reference is already set for this repo).
4. Portainer → Stacks → New stack → the repo URL → add the real key as a
   **stack environment variable** named `PIRATEFACE_KEY` (one field in the
   stack UI, from https://pirateface.co/settings) → Deploy. The compose file
   refuses to start without it. Bare `docker compose` on a host: export the
   same variable first. The repo is public — the key never goes in the file.
5. Logs: the stack's Logs view (each worker prints its lane start line, then
   the pf output).

## Tuning per worker
- `LANE_NAME` — required to be unique per lane (1-24 chars, letters/digits/. _ -).
- `MAX_SIZE` — biggest model to take, GiB (the site's own cap is 500 GiB).
- `MAX_RATE` — per-lane Hugging Face download rate, decimal MB/s (pirateface
  0.2.24+; unset = unlimited). Total machine rate = sum of the lanes.

## Update mechanism
- `:latest` is rebuilt by the workflow whenever it runs (daily cron, or push,
  or from the Actions page) with whatever PyPI serves then.
- Portainer redeploy (re-pull + redeploy) picks it up. Pin `:<version>` in the
  compose to hold a fleet on a known-good release.

## Semantics worth knowing
- Restarting or stopping a worker is safe: nothing partial is ever submitted
  (the .torrent is one atomic upload after the full stream). The lease lapses
  after 10 minutes without renewal and the model goes back to the queue — no
  failure is recorded.
- On 0.2.24+ a restart inside the renewal window resumes the same leased job
  from the checkpoint in the worker's volume.
- The key file convention does not apply here: the key arrives as the
  `PIRATEFACE_KEY` env var (the CLI's first resolution path).
