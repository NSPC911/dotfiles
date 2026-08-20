; https://github.com/thomasschafer/scooter.hx
(require "scooter/scooter.scm")


; https://github.com/Ciflire/presence.hx
; (require (prefix-in helix-discord-rpc. "helix-discord-rpc/helix-discord-rpc.scm"))
; (helix-discord-rpc.discord-rpc-connect)


; https://github.com/Xerxes-2/wakatime.hx
(require "wakatime/wakatime.scm")


; https://github.com/RoastBeefer00/fidget.hx
; (require "fidget.hx/fidget.scm")


; scroll snapped to center
; (require "./smooth-scroll.scm")


; show one key once at a time
(require "./showkeys.scm")
(showkeys-toggle)


; no installation command
(require "./flash.scm")


; changed path it saves to and better keybinds
(require "./streal.scm")


; changed keybinds a bit
(require "./forest.scm")
(forest-configure! 'left #:ignore (list ".git" "target" "__pycache__" "node_modules" "venv" ".venv" ".ruff_cache" ".pytest_cache"))
(forest-set-style! 'snacks) ; or 'mini or 'snacks
(forest-set-keybinds!
  (hash 'down "k"
        'up "i"
        'enter "l"
        'back "j"
        'search "/"
        'create "n"
        'rename "r"
        'delete "d"
        'refresh "R"
        'toggle-hidden "."
        'toggle-git-ignored "I"
        'wider "+"
        'narrower "_"
        'quit "q"
  )
)

; https://github.com/Ra77a3l3-jar/moka.hx
; cant even run it bruh
; (require "moka/moka.scm")
; (moka-configure!
;  #:sections
;  (list
;   (moka-section (list (moka-segment 'mode) (moka-segment 'file)) #:align 'left)
;   (moka-section (list (moka-segment 'lsp) (moka-segment 'git-branch) (moka-segment 'position)) #:align 'right)))

; (moka-enable!)
