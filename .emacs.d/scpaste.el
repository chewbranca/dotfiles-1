;;; scpaste.el --- Paste to the web via scp.

;; Copyright (C) 2008 Phil Hagelberg

;; Author: Phil Hagelberg
;; URL: http://www.emacswiki.org/cgi-bin/wiki/SCPaste
;; Version: 0.3
;; Created: 2008-04-02
;; Keywords: convenience hypermedia
;; EmacsWiki: SCPaste

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;; This will place an HTML copy of a buffer on the web on a server
;; that the user has shell access on.

;; It's similar in purpose to services such as http://paste.lisp.org
;; or http://rafb.net, but it's much simpler since it assumes the user
;; has an account on a publicly-accessible HTTP server. It uses `scp'
;; as its transport and uses Emacs' font-lock as its syntax
;; highlighter instead of relying on a third-party syntax highlighter
;; for which individual language support must be added one-by-one.

;; It has been tested in Emacs 23, but it should work in 22.

;;; Install

;; To install, copy this file into your Emacs source directory, set
;; `scpaste-http-destination' and `scpaste-scp-destination' to
;; appropriate values, and add this to your .emacs file:

;; (autoload 'scpaste "scpaste" "Paste the current buffer." t nil)

;;; Usage

;; M-x scpaste, enter a name, and press return. The name will be
;; incorporated into the URL by escaping it and adding it to the end
;; of `scpaste-http-destination'. The URL for the pasted file will be
;; pushed onto the kill ring.

;; You can autogenerate a splash page that gets uploaded as index.html
;; in `scpaste-http-destination' by invoking M-x scpaste-index. This
;; will upload an explanation as well as a listing of existing
;; pastes. If a paste's filename includes "private" it will be skipped.

;; You probably want to set up SSH keys for your destination to avoid
;; having to enter your password once for each paste. Also be sure the
;; key of the host referenced in `scpaste-scp-destination' is in your
;; known hosts file--scpaste will not prompt you to add it but will
;; simply hang.

;;; Todo:

;; Make htmlize convert all URLs to hyperlinks

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(require 'url) ;; Included in recent version of Emacs; available for pre-22.
(require 'htmlize) ;; http://fly.srk.fer.hr/~hniksic/emacs/htmlize.el.html

(defvar scpaste-http-destination
  "http://p.hagelb.org"
  "Publicly-accessible (via HTTP) location for pasted files.")

(defvar scpaste-scp-destination
  "p.hagelb.org:p.hagelb.org"
  "SSH-accessible directory corresponding to `scpaste-http-destination'.
You must have write-access to this directory via `scp'.")

(defvar scpaste-footer
  (concat "<p style='font-size: 8pt; font-family: monospace;'>Generated by "
	  user-full-name
	  " using <a href='http://p.hagelb.org'>scpaste</a> at %s "
	  (cadr (current-time-zone)) ".</p>")
  "HTML message to place at the bottom of each file.")

(defvar scpaste-tmp-dir "/tmp"
  "Writable location to store temporary files.")

;;;###autoload
(defun scpaste (original-name)
  "Paste the current buffer via `scp' to `scpaste-http-destination'."
  (interactive "MName (defaults to buffer name): ")
  (let* ((b (htmlize-buffer))
	 (name (url-hexify-string (if (equal "" original-name)
				      (buffer-name)
				    original-name)))
	 (full-url (concat scpaste-http-destination "/" name ".html"))
	 (scp-destination (concat scpaste-scp-destination "/" name ".html"))
	 (tmp-file (concat scpaste-tmp-dir "/" name)))

    ;; Save the file (while adding footer)
    (save-excursion
      (switch-to-buffer b)
      (search-forward "  </body>\n</html>")
      (insert (format scpaste-footer (current-time-string)))
      (write-file tmp-file)
      (kill-buffer b))

    ;; Could use shell-command here instead of eshell-command if you don't
    ;; want to load eshell and you don't mind the popup password prompt.
    (eshell-command (concat "scp " tmp-file " " scp-destination))
    (ignore-errors (kill-buffer "*EShell Command Output*"))

    ;; Notify user and put the URL on the kill ring
    (kill-new full-url)
    (message "Pasted to %s (on kill ring)" full-url)))

(defun scpaste-index ()
  "Generate an index of all existing pastes on server on the splash page."
  (interactive)
  (let ((dest-parts (split-string scpaste-scp-destination ":")))
    (eshell-command (concat "ssh " (car dest-parts) " ls " (cadr dest-parts)))
    (save-excursion
      (switch-to-buffer "*EShell Command Output*")
      (flush-lines "^Password: $" (point-min) (point-max))
      (flush-lines "private" (point-min) (point-max))
      (let ((file-list (split-string (buffer-string) "\n")))
	(with-temp-buffer
	  (insert-file-contents "~/.emacs.d/scpaste.el") ;; TODO: find elisp's __FILE__
	  (goto-char (point-min))
	  (search-forward ";;; Commentary")
	  (previous-line)
	  (insert "\n;;; Pasted Files\n\n")
	  (mapcar (lambda (file) (insert (concat ";; * <" scpaste-http-destination "/" file ">\n"))) file-list)
	  (emacs-lisp-mode) (font-lock-fontify-buffer) (rename-buffer "SCPaste")
	  (scpaste "index")))
      (ignore-errors (kill-buffer "*EShell Command Output*")))))

(provide 'scpaste)
;;; scpaste.el ends here