# dotfiles

My Windows 11 config files, Nord + Translucency

## Screenshots

| ![fetch](https://github.com/NSPC911/dotfiles/blob/main/img/fetch.png?raw=true) <br> gitfetch + fastfetch |                  ![helix](https://github.com/NSPC911/dotfiles/blob/main/img/helixonly.png?raw=true) <br> helix                   |
| :------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------: |
|   ![zen browser](https://github.com/NSPC911/dotfiles/blob/main/img/zen.png?raw=true) <br> zen browser    | ![youtube music](https://github.com/NSPC911/dotfiles/blob/main/img/youtubemusic.png?raw=true) <br> youtube music (a bit scuffed) |
| ![rovr](https://github.com/NSPC911/dotfiles/blob/main/img/rovr.png?raw=true) <br> rovr, my file explorer |                                                                                                                                  |

## Apps

#### Categories

| Type                  | App                                                                                                                 | Location in repository                                                    |
| --------------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Tiling Manager        | [GlazeWM](https://github.com/glzr-io/glazewm)                                                                       | `dot_glzr/glazewm/config.yaml`                                            |
| Window Borders        | [Tacky Borders](https://github.com/lukeyou05/tacky-borders)                                                         | `dot_config/tacky-borders/config.yaml`                                    |
| Tiling Helper         | [AltSnap](https://github.com/RamonUnch/AltSnap)                                                                     | `readonly_scoop/persist/altsnap/AltSnap.ini`                              |
| Status Bar            | [yasb](https://github.com/amnweb/yasb)                                                                              | `dot_config/yasb/`                                                        |
| Terminal **emulator** | [wezterm](https://github.com/wezterm/wezterm)                                                                       | `.wezterm.lua`                                                            |
| Terminal              | [PowerShell 7.5](https://github.com/PowerShell/PowerShell)                                                          | `OneDrive/readonly_Documents/PowerShell/Microsoft.PowerShell_profile.ps1` |
| Fetch                 | [fastfetch](https://github.com/fastfetch-cli/fastfetch) + [gitfetch](https://github.com/Matars/gitfetch)            | fastfetch: `dot_config/fastfetch/config.jsonc`                            |
| Prompt                | [oh-my-posh](https://github.com/jandedobbeleer/oh-my-posh)                                                          | `dot_config/kushal.omp.json`                                              |
| Mod Manager           | [Windhawk](https://github.com/ramensoftware/windhawk)                                                               | `windhawk/`                                                               |
| Editor                | [helix](https://github.com/helix-editor/helix) [(custom built)](https://github.com/NSPC911-forks/helix/tree/patchy) | `AppData/Roaming/helix/`                                                  |
| File Explorer (TUI)   | [rovr](https://github.com/NSPC911/rovr)                                                                             | `AppData/Local/rovr/`                                                     |
| Browser               | [Zen](https://github.com/zen-browser/desktop)                                                                       | `zen/userChrome.css`                                                      |
| Discord Mod           | [Vencord](https://github.com/Vendicated/Vencord)                                                                    | [NSPC911/themes:vencord](https://github.com/NSPC911/themes/tree/vencord)  |
| Git UI                | [lazygit](https://github.com/jesseduffield/lazygit)                                                                 | `AppData/Local/lazygit/config.yml`                                        |
| File Output           | [bat](https://github.com/sharkdp/bat)                                                                               | `readonly_scoop/persist/bat/`                                             |
| Launcher              | [Flow Launcher](https://github.com/Flow-Launcher/Flow.Launcher)                                                     | `readonly_scoop/persist/flow-launcher/UserData/Settings/`                 |
| Pager                 | [ov](https://github.com/noborus/ov) | `dot_config/ov/config.yaml`

#### Wallpaper

Generally I switch between 3 options (screenshots from steam!)

|   ![Lost Cat.](https://images.steamusercontent.com/ugc/2459620193690498958/1CF63A48848CDB76FFEFC3A4B2B54D37FB142BA3/?imw=637&imh=358&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true) <br> [link](https://steamcommunity.com/sharedfiles/filedetails/?id=3352465485)   | ![Lost Cat 3](https://images.steamusercontent.com/ugc/2404452368859591676/D8CBBE411A86066BA5B3D9554BB1F8EEDB7DE61F/?imw=637&imh=358&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true) <br> [link](https://steamcommunity.com/sharedfiles/filedetails/?id=3360569178) |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| ![Sunset Cat [4k]](https://images.steamusercontent.com/ugc/43443618358467438/204AE1F0F54142B3670712E3546E6E2EE76D07BE/?imw=637&imh=358&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true) <br> [link](https://steamcommunity.com/sharedfiles/filedetails/?id=3373818743) |                                                                                                                                                                                                                                                                                 |

#### No config

| Type            | Link                                                                                               |
| --------------- | -------------------------------------------------------------------------------------------------- |
| Nerd Font       | [CaskaydiaCove NF](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/CascadiaCode) |
| Package Manager | [scoop](https://github.com/ScoopInstaller/scoop)                                                   |
| Utilities       | [PowerToys](https://github.com/Microsoft/PowerToys)                                                |
| Fun             | [bongocat](https://github.com/NSPC911/bongo-cat)                                                   |
| Pixel Art       | [Pixelorama](https://github.com/Orama-Interactive/Pixelorama)                                      |
| File Indexer    | [everything](https://voidtools.com)                                                                |
| Music           | [youtube-music](https://github.com/th-ch/youtube-music)                                            |
| Roblox Mod      | [BloxStrap](https://github.com/bloxstraplabs/bloxstrap)                                            |
| Cursor          | https://www.deviantart.com/jepricreations/art/Windows-11-Cursors-Concept-886489356                 |

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
frogmouth v0.9.2
gitfetch v1.3.2 [required:  git+https://github.com/matars/gitfetch@4a113b5e05d200c83422d30e21391b47886186e0]
mistral-vibe v1.3.3
poethepoet v0.39.0
poetry v2.2.1
ptf v0.1.0 [required:  git+https://github.com/nspc911/ptf]
pyright v1.1.407
rich-cli v1.8.1
rovr v0.7.0.dev1 [required:  git+https://github.com/nspc911/rovr@dev] [with: textual-speedups]
ruff v0.14.10
ty v0.0.8 [required: ==0.0.8]
```

#### pnpm global installs

<!--pnpm list -g, remove header-->
```
@ansible/ansible-language-server 1.2.3
@astrojs/language-server 2.16.2
@fsouza/prettierd 0.26.2
@github/copilot 0.0.352
@google/gemini-cli 0.13.0
@withgraphite/graphite-cli 1.7.14
cli-markdown 3.5.1
corepack 0.34.5
live-server 1.2.2
prettier 3.7.4
typescript 5.9.3
typescript-language-server 5.1.3
vscode-langservers-extracted 4.10.0
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
| PSReadLine                           | Read keybinds + autocomplete           | `Install-Module PSReadline`                           |
| scoop-completions                    | scoop completions                      | `scoop install scoop-completion`                      |
| PoshGit                              | git autocompletions                    | `Install-Module posh-git`                             |
| PS-Fzf                               | fzf in powershell                      | `Install-Module PSFzf`                                |
| Microsoft.PowerShell.ConsoleGuiTools | gui tools in the shell                 | `Install-Module Microsoft.PowerShell.ConsoleGuiTools` |
| Terminal-Icons                       | nerdfont icons in Get-ChildItem + more | `Install-Module Terminal-Icons`                       |
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
```shell
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Language              Files        Lines         Code     Comments       Blanks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 JSON                     41         5437         5436            0            1
 TOML                      9         1642         1384          152          106
 YAML                      5         1201         1114           28           59
 Scheme                    6          958          842           21           95
 CSS                       2          870          735           26          109
 PowerShell                1          817          680           50           87
 INI                       1          687          170          414          103
 Lua                       1          237          218            6           13
─────────────────────────────────────────────────────────────────────────────────
 Markdown                  2          160            0          129           31
 |- Shell                  1           18           18            0            0
 (Total)                              178           18          129           31
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Total                    68        12027        10597          826          604
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

<p align="center">
  <picture>
    <source srcset="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/dark/spaced.svg?sanitize=true" width="100%" media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)" />
    <source srcset="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/light/spaced.svg?sanitize=true" width="100%" media="(prefers-color-scheme: dark)" />
    <img src="https://raw.githubusercontent.com/nordtheme/assets/main/static/images/elements/separators/iceberg/footer/dark/spaced.svg?sanitize=true" width="100%" />
  </picture>
</p>
