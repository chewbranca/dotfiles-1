;; -*- lexical-binding: t -*-
(when (require 'exwm nil t)
  (require 'exwm-config)
  (exwm-config-default)

  (setq exwm-workspace-number 9)

  (require 'exwm-systemtray)
  (exwm-systemtray-enable)

  (add-hook 'exwm-manage-finish-hook
            (defun pnh-exwm-manage-hook ()
              (when (or (string= exwm-class-name "URxvt")
                        (string= exwm-class-name "love"))
                (exwm-input-release-keyboard))
              (when (string-match "Firefox" exwm-class-name)
                (exwm-layout-hide-mode-line))))

  (exwm-enable-ido-workaround)

  (dolist (k '(("s-l" "gnome-screensaver-command -l")
               ("s-v" "killall evrouter; evrouter /dev/input/*")
               ("s-s" "scrot")
               ("s-S-s" "scrot -s")
               ("s-<return>" "urxvt")
               ("<f7>" "music-choose")
               ("S-<f7>" "music-random")
               ("<f8>" "mpc toggle")
               ("<f10>" "mpc next")
               ("<XF86AudioLowerVolume>" "amixer sset Master 5%-")
               ("<XF86AudioRaiseVolume>" (concat "amixer set Master unmute; "
                                                 "amixer sset Master 5%+"))))
    (let ((f (lambda () (interactive)
               (save-window-excursion
                 (start-process-shell-command (cadr k) nil (cadr k))))))
      (exwm-input-set-key (kbd (car k)) f)))

  (defun pnh-run (command)
    (interactive (list (read-shell-command "$ ")))
    (start-process-shell-command command nil command))
  (define-key exwm-mode-map (kbd "C-x s-m") 'pnh-run)
  (global-set-key (kbd "C-x s-m") 'pnh-run)

  (exwm-input-set-simulation-keys
   (mapcar (lambda (c) (cons (kbd (car c)) (cdr c)))
           `(("C-b" . left)
             ("C-f" . right)
             ("C-p" . up)
             ("C-n" . down)
             ("C-a" . home)
             ("C-e" . end)
             ("M-v" . prior)
             ("C-v" . next)
             ("C-d" . delete)
             ("C-m" . return)
             ("C-i" . tab)
             ("C-g" . escape)
             ("C-s" . ?\C-f)
             ("C-y" . ?\C-v)
             ("M-w" . ?\C-c)
             ("M-<" . C-home)
             ("M->" . C-end)
             ("C-M-h" . C-backspace))))

  (when window-system
    (when (string= system-name "alto")
      (require 'exwm-randr)
      (setq exwm-randr-workspace-output-plist '(2 "eDP-1" 3 "DP-1" 1 "HDMI-2"
                                                  4 "DP-1" 5 "DP-1" 6 "DP-1"
                                                  7 "eDP-1" 8 "eDP-1" 9 "eDP-1"
                                                  0 "HDMI-2"))
      (add-hook 'exwm-randr-screen-change-hook
                (lambda ()
                  (start-process-shell-command "xrandr" nil "~/bin/rotated")))
      (exwm-randr-enable))

    (global-set-key (kbd "C-x m")
                    (defun pnh-eshell-per-workspace (n)
                      (interactive "p")
                      (eshell (+ (case n (4 10) (16 20) (64 30) (t 0))
                                 exwm-workspace-current-index))))
    (server-start))

  ;; todo:

  ;; * switch to char-mode in urxvt
  ;; * how to send C-f in simulation keys
  ;; * figure out how to recover "lost" floating windows
  ;; * allow global-set-key stuff in browser/urxvt
  ;; * sometimes gpg passphrase entry doesn't accept input

  ;; cheat sheet:
  ;; * C-c C-k: switch to char-mode
  ;; * C-c C-q: send next key literally
  ;; * C-c C-t C-f: toggle floating
  ;; * C-c C-t C-m: toggle modeline

  ;; * C-x ^: enlarge window vertically
  ;; * C-x }: enlarge window horizontally

  ;; * s-r: reset all
  )
