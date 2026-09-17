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
| `CL_CACHE_TTL` | `20` | seconds a list of agents is reused |
| `CL_NEG_TTL` | `3600` | seconds a host without an agent is left alone |

A host newly running an agent can take up to `CL_NEG_TTL` to appear if it was
recently found without one; `rm ~/.cache/cl/not-agents` forces a re-check.

Needs `tmux`, `flock`, and — for remote agents — `shrooms`, `python3` and SSH
keys on the peers.
