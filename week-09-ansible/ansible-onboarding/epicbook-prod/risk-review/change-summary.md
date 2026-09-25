# Change Summary: SSH Hardening on the EpicBook Server

**Author and decision owner:** Oluwagbade Odimayo

**Date:** 25 September 2026

**Target:** EpicBook app server on AWS (eu-west-2), managed by `../ansible/site.yml`

## 1. The change

Added one task and one handler to the `common` role:

- `Harden SSH by disabling root login`: `lineinfile` sets `PermitRootLogin no` in `/etc/ssh/sshd_config`,
  with `validate: /usr/sbin/sshd -t -f %s` so an invalid config can never be written.
- Handler `Restart SSH`: restarts the `ssh` service when the file changes.

## 2. Risk review before applying (dry run only)

`./ansible-check-review.sh reports/risky-change-report.txt` ran `ansible-playbook --check --diff`:

- Recap: `changed=2 failed=0`
- Changed tasks: `common : Harden SSH by disabling root login`, `common : Restart SSH`
- `[HIGH] Access and security` for both tasks, `[MEDIUM] Service disruption` for the restart
- Diff: `-#PermitRootLogin prohibit-password` becomes `+PermitRootLogin no`
- **Overall Status: FAILED, exit code 2.** Nothing was applied.

Claude Code (`/ansible-risk-review`) read the same evidence, quoted the diff, explained the lockout risk and
recommended the apply command for me to run. It did not apply anything; applying is blocked for it by
`CLAUDE.md` and by the `PreToolUse` hook.

## 3. Human decision

I applied the change because the evidence showed it only disables direct root login. I log in as
`ubuntu` with an SSH key, so my own access was not affected, and the config was validated before writing.
Before applying I opened a second SSH session as a lifeline, since existing sessions survive an SSH restart.

## 4. Apply and verification

- Applied manually: `ansible-playbook -i inventory.ini site.yml` from `../ansible`. Recap `ok=22 changed=2 unreachable=0 failed=0`: exactly the two changes the review predicted.
- `ansible web -i inventory.ini -m ping` returned `pong`.
- A brand-new SSH login with `-o ControlPath=none` succeeded and showed `PermitRootLogin no`.
  This matters: Ansible reuses open SSH connections (`ControlPersist`), so a ping alone cannot prove that
  new logins still work after an SSH change.

## 5. Review after applying

`/ansible-risk-review reports/post-apply-report.txt` reported **Overall Status: HEALTHY, exit code 0,
`changed=0`**: the server now matches the playbook.

## 6. Known limitations of the review tooling

Found by the Claude Code planning step and confirmed by me:

- `command` and `shell` tasks are skipped in `--check` mode, so a pending schema import or PM2 start would not
  appear as `changed`. The review must also read the skipped tasks in `reports/dry-run-output.log`.
- Risk is classified by task name, not by module. "Disable the default Nginx site" matches LOW even though it
  deletes a file (`state: absent`).
- The AI planning step also claimed the schema SQL "may drop tables". I checked: none of the SQL files contains
  `DROP`. It was speculation, which is why every verdict must quote evidence.

## 7. Next steps

- Classify by module and parameters (for example `state: absent`) as well as task names.
- Report `command`/`shell` tasks that would run, using the pre-computed check results.
- Keep the fresh-connection SSH check as a mandatory step after any access or SSH change.
