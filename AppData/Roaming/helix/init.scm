; https://github.com/thomasschafer/scooter.hx
(require "scooter/scooter.scm")

; scroll snapped to center
(require "./smooth-scroll.scm")
; show one key once at a time
(require "./showkeys.scm")
; no installation command
; (require "./flash.scm")
; changed path it saves to, nothing else
(require "./streal.scm")
; (require "steel-pty/term.scm")

(showkeys-toggle)
