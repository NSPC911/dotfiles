When working with testing scripts, do not write them to `/tmp`. Write them to `~/tmp` instead. You should preferably keep these scripts in a subfolder of `~/tmp` named after the project, or the focus of the chat
- For instance, if we are working on directory `~/Git/NSPC911/rovr`, you should write testing scripts to `~/tmp/rovr` instead of `/tmp`.
- If I'm talking about creating a script to measure the difference in performance of `fastjsonschema` and `jsonschema-rs`, you should write the script to `~/tmp/fastjsonschema-vs-jsonschema-rs` instead of `/tmp`.

This is a wezterm session, so wezterm commands work.
- `wezterm cli spawn`: spawns a new tab. provide an optional command to run in the new tab. `--cwd` can be specified for the working directory
- `wezterm cli split-pane`: splits the current pane. same as spawn.
- `wezterm cli get-text --pane-id <pane-id>`: gets the text in the pane. `--escapes` includes escape sequences.
- `wezterm cli send-text --pane-id <pane-id> <text>`: sends text to the pane. `--no-paste` sends it as key events instead of sending as bracketed paste.
- `wezterm cli list --json`: lists all windows, tabs, and panes in JSON format. useful for getting pane ids.
- `wezterm cli kill-pane --pane-id <pane-id>`: kills the specified pane.

In a python project, NEVER run just `python <command>`. Do not assume the venv is activated; always run `uv run python <command>` to ensure the correct environment is used.

YOU ARE NOT ALLOWED TO USE SUB-AGENTS.
