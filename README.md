# after-install

Things to put back on a fresh machine.

## cl — several Claudes, one per directory

`bin/cl` manages Claude Code sessions in tmux, so each project keeps its own
conversation and any of them can be picked up from a phone over SSH.

```bash
install -m 0755 bin/cl ~/.local/bin/cl
```

```
cl                    list; attach when there is exactly one
cl <name|number>      attach, starting it if it is not running
cl new [dir] [name]   start one for a directory (default: here)
cl ls                 list
cl kill <name|number> stop one
cl rm <name>          forget one (does not stop it)
```

Sessions are keyed by directory, because `claude --continue` resumes the last
conversation *for the working directory*. A registry in
`~/.config/cl/sessions` keeps the names across a reboot, so `cl <name>` brings
a stopped one back in the right place.

**Agents on other machines.** If [shrooms](https://github.com/vpavlin/shrooms)
is installed, `cl` also lists the `pi-agent` tmux session on every online peer
of the `office` mesh, and `cl <host>` attaches to it over SSH. Hosts come from
the mesh, so a new machine appears without editing anything and a sleeping one
is skipped without waiting on a timeout.

| variable | default | |
|---|---|---|
| `CL_CLAUDE_ARGS` | `--dangerously-skip-permissions` | arguments for `claude` |
| `CL_AGENT_MESHES` | `office` | meshes searched for agents; empty searches all |
| `CL_REMOTE_SESSION` | `pi-agent` | the tmux session name on those hosts |
| `CL_REMOTE_USER` | *(ssh's choice)* | account on those hosts, when it differs from yours |
| `CL_CACHE_TTL` | `20` | seconds a list of agents is reused |
| `CL_NEG_TTL` | `3600` | seconds a host without an agent is left alone |

A host newly running an agent can take up to `CL_NEG_TTL` to appear if it was
recently found without one; `rm ~/.cache/cl/not-agents` forces a re-check.

Needs `bash` and `tmux`, and — for remote agents — `shrooms`, `python3` and SSH
keys on the peers.

### On another machine

Nothing in it is specific to one host: paths go through `$HOME`, and every
default above can be overridden. What *is* specific is your setup, and worth
checking before relying on it:

- **`CL_CLAUDE_ARGS` defaults to `--dangerously-skip-permissions`**, so every
  session it starts runs without permission prompts. That suits a machine you
  drive from a phone; set it to something else anywhere it doesn't.
- **`office` and `pi-agent`** are this mesh's names. Change them if yours differ.
- **SSH to the peers uses your local username** unless `CL_REMOTE_USER` or
  `~/.ssh/config` says otherwise.
- **Host keys are accepted on first use** (`StrictHostKeyChecking=accept-new`).
  Over the mesh that is reasonable — an overlay address is only reachable
  through a WireGuard tunnel to the peer that owns it — but it is a choice.
- **`--continue` detection reads `~/.claude/projects/`**, which is Claude
  Code's internal layout. If that changes, `cl new` starts a fresh
  conversation rather than failing.

Runs on Linux and macOS. `timeout`, `getent` and `flock` are used where they
exist and not required: without `flock` the registry is written unlocked,
which only matters if two `cl new` run in the same instant.
