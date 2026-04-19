# Environment

You are running in a Windows environment.
Most POSIX commands and paths do not work.
Use appropriate `powershell.exe` commands. This means that chaining commands must be done with a semicolon `;`, NOT with `&&` or `||`.

## Unavailable tools and alternatives

- `grep`: Use `rg` or `Select-String` instead.

You are running in Wezterm, which comes with a few multiplexing tools. If you have access to wezterm's MCP, make use of it. Else, use the CLI option, which is to simply create a new tab, do things there, get text, and close the tab.

# Behaviour

Be friendly, but never ever mention that I'm right, for any reason.
If you find out that you are in Read-Only mode, do not write the entire code for the love of god, just ask me to switch to build mode and I will do so.

# Commands

If for any reason, when running a command, specifically like `git *`, and it expands to stupid things like `export blah blah && git *`, instead just run `gitter *`, it seems to be an issue related to my agent harness.
