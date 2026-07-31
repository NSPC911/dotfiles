# dotfiles

The alternate side, the linux version. Still Nord + Transparency.

## Screenshots

| ![fetch](img/fetch.png) <br> gitfetch + fastfetch |      ![helix](img/helixonly.png) <br> helix       |
| :-----------------------------------------------: | :-----------------------------------------------: |
|   ![zen browser](img/zen.png) <br> zen browser    | ![rovr](img/rovr.png) <br> rovr, my file explorer |

## Apps

#### Categories

| Type                  | App                                                                                                                 | Location in repository                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Window Manager        | [niri](https://github.com/niri-wm/niri)                                                                             | `dot_config/niri/config.kdl`                                             |
| GUI Shell             | [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)                                               | `dot_config/DankMaterialShell/settings.json`                             |
| Terminal **emulator** | [wezterm](https://github.com/wezterm/wezterm)                                                                       | `dot_wezterm.lua`                                                        |
| Terminal              | [PowerShell 7.5](https://github.com/PowerShell/PowerShell)                                                          | `dot_config/powershell/Microsoft.PowerShell_profile.ps1`                 |
| Fetch                 | [fastfetch](https://github.com/fastfetch-cli/fastfetch) + [gitfetch](https://github.com/Matars/gitfetch)            | fastfetch: `dot_config/fastfetch/config.jsonc`                           |
| Prompt                | [oh-my-posh](https://github.com/jandedobbeleer/oh-my-posh)                                                          | `dot_config/kushal.omp.json`                                             |
| Editor                | [helix](https://github.com/helix-editor/helix) [(custom built)](https://github.com/NSPC911-forks/helix/tree/patchy) | `dot_config/helix/`                                                      |
| File Explorer (TUI)   | [rovr](https://github.com/NSPC911/rovr)                                                                             | `dot_config/rovr/`                                                       |
| Browser               | [Zen](https://github.com/zen-browser/desktop)                                                                       | `zen/`                                                                   |
| Discord Mod           | [Vencord](https://github.com/Vendicated/Vencord)                                                                    | [NSPC911/themes:vencord](https://github.com/NSPC911/themes/tree/vencord) |
| Git UI                | [lazygit](https://github.com/jesseduffield/lazygit)                                                                 | `dot_config/lazygit/config.yml`                                          |
| File Output           | [bat](https://github.com/sharkdp/bat)                                                                               | `dot_config/bat/config`                                                  |
| Pager                 | [ov](https://github.com/noborus/ov)                                                                                 | `dot_config/ov/config.yaml`                                              |

#### No config

| Type            | Link                                                                                               |
| --------------- | -------------------------------------------------------------------------------------------------- |
| Nerd Font       | [CaskaydiaCove NF](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/CascadiaCode) |
| Package Manager | [yay](https://github.com/jguer/yay)                                                                |
| Pixel Art       | [Pixelorama](https://github.com/Orama-Interactive/Pixelorama)                                      |
| Roblox          | [Sober](https://sober.vinegarhq.org/)                                                              |
| Cursor          | [Bibata](https://github.com/ful1e5/Bibata_Cursor)                                                  |

#### cargo installations

```
tokei
> cargo install --git https://github.com/XAMPPRocky/tokei.git tokei
helix
> cargo xtask steel
```

#### uv tools

<!--uv tool list --show-with --show-extras --show-version-specifiers, remove `- `-->

```
ansible-lint v26.6.0
batrachian-toad v0.6.20
gitfetch v1.3.2 [required:  git+https://github.com/matars/gitfetch@4a113b5e05d200c83422d30e21391b47886186e0]
hike v1.4.0
mistral-vibe v2.22.0
poethepoet v0.48.0
poetry v2.4.1 [with: more-itertools==11.0.2]
ptf v0.1.0 [required:  git+https://github.com/nspc911/ptf]
pyright v1.1.411
rich-cli v1.8.1
rovr v0.10.0.dev1 [required:  git+https://github.com/NSPC911/rovr]
ruff v0.15.22
ty v0.0.49 [required: ==0.0.49]
```

#### pnpm global installs

<!--pnpm list -g, remove header-->

```
@agentclientprotocol/claude-agent-acp@0.38.0
@ansible/ansible-language-server@26.6.0
@astrojs/language-server@2.16.13
@fsouza/prettierd@0.27.0
@github/copilot@1.0.73
@google/gemini-cli@0.42.0
live-server@1.2.2
oxfmt@0.51.0
typescript@6.0.3
typescript-language-server@5.3.0
vscode-langservers-extracted@4.10.0
```

#### Browser extensions (zen)

| Name                                                               | Location                             |
| ------------------------------------------------------------------ | ------------------------------------ |
| [Refined GitHub](https://github.com/refined-github/refined-github) | `zen/extensions/refined_github.json` |
| [tabliss](https://tabliss.io/)                                     | `zen/extensions/tabliss.json`        |
| [vimium](https://github.com/philc/vimium)                          | `zen/extensions/vimium-options.json` |

#### powershell modules

| Name                                 | Description                            | Installer                                             |
| ------------------------------------ | -------------------------------------- | ----------------------------------------------------- |
| PSReadLine                           | read keybinds + autocomplete           | `Install-Module PSReadline`                           |
| PoshGit                              | git autocompletions                    | `Install-Module posh-git`                             |
| PS-Fzf                               | fzf in powershell                      | `Install-Module PSFzf`                                |
| Microsoft.PowerShell.ConsoleGuiTools | gui tools in the shell                 | `Install-Module Microsoft.PowerShell.ConsoleGuiTools` |
| Terminal-Icons                       | nerdfont icons in Get-ChildItem + more | `Install-Module Terminal-Icons`                       |
| PwshSpectreConsole                   | advanced console features              | `Install-Module PwshSpectreConsole`                   |
| PSToml                               | toml parsing                           | `Install-Module PSToml`                               |
| scoop-completions                    | scoop completions                      | `scoop install scoop-completion`                      |
| PSEverything                         | everything integration into powershell | `Install-Module PSEverything`                         |

#### Previously used, but no longer using

| Type                | App                                                                   | Location                                                           |
| ------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Terminal emulator   | [rio](https://github.com/raphamorim/rio)                              | `AppData/Local/rio/`                                               |
| Terminal emulator   | [alacritty](https://github.com/alacritty/alacritty)                   | `AppData/Roaming/alacritty/`                                       |
| Tiling Manager      | [komorebi](https://github.com/LGUG2Z/komorebi)                        | `komorebi.json`                                                    |
| File Explorer (TUI) | [superfile](https://github.com/yorukot/superfile)                     | `AppData/Local/superfile/`                                         |
| File Explorer (GUI) | [OneCommanger](https://www.onecommander.com)                          | `readonly_scoop/persist/onecommander/Settings/OneCommanderV3.json` |
| Hotkey Daemon       | [whkd](https://github.com/LGUG2Z/whkd)                                | `dot_config/whkdrc`                                                |
| Transparency        | [MicaForEveryone](https://github.com/MicaForEveryone/MicaForEveryone) | `AppData/Local/Mica For Everyone/MicaForEveryone.conf`             |

### Stats

<!--tokei --sort lines-->

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Language              Files        Lines         Code     Comments       Blanks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 JSON                     21         4329         4329            0            0
 CSS                      11         3310         2674          246          390
 TOML                     12         1735         1427          169          139
 PowerShell                7         1314         1144           69          101
 Scheme                    6          983          850           36           97
 YAML                      2          334          313           17            4
 Lua                       1          243          219           12           12
 Markdown                 10          215            0          163           52
 BASH                      1           84           60           13           11
 SVG                       2           46           46            0            0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Total                    73        12593        11062          725          806
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

<p align="center">
  <picture>
    <source srcset="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/dark/spaced.svg?sanitize=true" width="100%" media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)" />
    <source srcset="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/light/spaced.svg?sanitize=true" width="100%" media="(prefers-color-scheme: dark)" />
    <img src="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/dark/spaced.svg?sanitize=true" width="100%" />
  </picture>
</p>
