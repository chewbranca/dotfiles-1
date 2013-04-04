(setq compilation-scroll-output t ; byte-compilation fails w/o this
      ido-enable-tramp-completion nil
      vc-follow-symlinks t
      tags-revert-without-query t ; why would you ever not want this?
      markdown-command "redcarpet"
      ruby-insert-encoding-magic-comment nil)

;; plz not to refresh log buffer when I cherry-pick, mkay?
(eval-after-load 'magit
  '(ignore-errors
     (setq magit-diff-refine-hunk t)
     (define-key magit-log-mode-map (kbd "A")
       (lambda ()
         (interactive)
         (flet ((magit-need-refresh (f)))
           (magit-cherry-pick-item))))))

;; come on guys; autoloads are not rocket science
(autoload 'marmalade-upload-buffer "marmalade" nil t)

(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))

(autoload 'yaml-mode "yaml-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

(add-hook 'oddmuse-mode-hook
          (lambda ()
            (unless (string-match "question" oddmuse-post)
              (setq oddmuse-post (concat "uihnscuskc=1;" oddmuse-post)))))

(setq-default ispell-program-name "aspell")

;; TODO: this does nothing
(add-to-list 'ido-ubiquitous-command-exceptions 'ucs-insert)
(add-to-list 'ido-ubiquitous-function-exceptions 'read-char-by-name)

;; doesn't have a way to store credentials safely yet
(eval-after-load 'gh-auth
  '(when (not (featurep 'chorts))
    (load-file "~/.chorts/chorts.el.gpg")))

;; could do without the quotations
(eval-after-load 'nrepl
  '(setq nrepl-words-of-inspiration
         (remove-if (lambda (s) (string-match " -" s))
                    nrepl-words-of-inspiration)))

;; starter kit version has stupid formatting
(defun insert-date ()
  (interactive)
  (insert (format-time-string "%Y-%m-%d %H:%M:%S" (current-time))))

;; cl.el byte compiler warnings can suuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuck it!
(defalias 'byte-compile-cl-warn 'identity)

(setenv "GHI_NO_COLOR" "y")
