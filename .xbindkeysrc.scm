;;; Music functions

(map (lambda (binding) (xbindkey (car binding) (cdr binding)))
     (list '(F5 . "~/bin/music-show")
           '((Control F5) . "~/bin/music-playlist")
           '(F6 . "~/bin/music-random")
           '(F7 . "~/bin/music-choose")
           '(F8 . "mpc toggle")
           '((shift F8) . "ogg123 ~/documents/ambientShipTNG.ogg")
           '((mod1 F8) . "killall ogg123")
           '(F9 . "mpc prev")
           '(F10 . "mpc next")
           '((mod4 F12) . "vlc -f ~/documents/movies/misc/rick.flv"))) ;; tee hee

;;; notifications

(xbindkey '(mod1 F12) "notify-battery")

;;; network

(xbindkey '(mod4 mod1 n) "ery-net")
(xbindkey '(mod4 shift N)
          "notify-send wifi \"$(nmcli -f SSID dev wifi | grep -v SSID | uniq)\"")

;;; utilities

(xbindkey '(mod4 d) "gnome-display-properties")
(xbindkey '(mod4 F11) "setxkbmap -layout us; ctrl-fix")
(xbindkey '(mod4 shift F11) "setxkbmap -layout dvorak; ctrl-fix")

;;; launchers

(xbindkey '(mod4 b) "dbook.rb")
(xbindkey '(mod4 m) "nautilus $HOME/documents/movies")
