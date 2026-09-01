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
ansible-lint v26.8.0
batrachian-toad v0.6.20
gitfetch v1.3.2 [required:  git+https://github.com/matars/gitfetch@4a113b5e05d200c83422d30e21391b47886186e0]
hike v1.4.0
mistral-vibe v2.24.5
poethepoet v0.48.0
poetry v2.4.2 [with: more-itertools==11.0.2]
ptf v0.1.0 [required:  git+https://github.com/nspc911/ptf]
pyright v1.1.411
rich-cli v1.8.1
rovr v0.10.1.post1 [required:  git+https://github.com/NSPC911/rovr]
ruff v0.16.5
ty v0.0.49 [required: ==0.0.49]
```

#### pnpm global installs

<!--pnpm list -g, remove header-->

```
@ansible/ansible-language-server@26.6.0
@astrojs/language-server@2.16.15
@fsouza/prettierd@0.27.0
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
| PSEverything                         | everything integration into powershell | `Install-Module PSEverything`                         |

#### Previously used, but no longer using

| Type                | App                                                                   | Location                                                           |
| ------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Terminal emulator   | [rio](https://github.com/raphamorim/rio)                              | `AppData/Local/rio/`                                               |
| Terminal emulator   | [alacritty](https://github.com/alacritty/alacritty)                   | `AppData/Roaming/alacritty/`                                       |
| File Explorer (TUI) | [superfile](https://github.com/yorukot/superfile)                     | `AppData/Local/superfile/`                                         |

### Stats

<!--tokei --sort lines-->

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Language              Files        Lines         Code     Comments       Blanks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 JSON                     21         3848         3848            0            0
 CSS                      11         3310         2674          246          390
 Scheme                    7         2458         2044          128          286
 TOML                     12         1750         1439          169          142
 PowerShell                8         1356         1189           67          100
 YAML                      2          334          313           17            4
 Lua                       1          281          250           15           16
 Markdown                 10          205            0          158           47
 BASH                      1           84           60           13           11
 SVG                       2           46           46            0            0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Total                    75        13672        11863          813          996
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

<p align="center">
  <picture>
    <source srcset="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/dark/spaced.svg?sanitize=true" width="100%" media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)" />
    <source srcset="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/light/spaced.svg?sanitize=true" width="100%" media="(prefers-color-scheme: dark)" />
    <img src="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/dark/spaced.svg?sanitize=true" width="100%" />
  </picture>
</p>
