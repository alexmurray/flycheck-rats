;;; flycheck-rats.el --- Integrate rats with flycheck

;; Copyright (c) 2017 Alex Murray

;; Author: Alex Murray <murray.alex@gmail.com>
;; Maintainer: Alex Murray <murray.alex@gmail.com>
;; URL: https://github.com/alexmurray/flycheck-rats
;; Version: 0.1
;; Package-Requires: ((flycheck "0.24") (emacs "24.4"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This packages integrates rats with flycheck to automatically check for
;; possible security weaknesses within your C/C++ code on the fly.

;;;; Setup

;; (with-eval-after-load 'flycheck
;;   (require 'flycheck-rats)
;;   (flycheck-rats-setup)
;;   ;; chain after cppcheck since this is the last checker in the upstream
;;   ;; configuration
;;   (flycheck-add-next-checker 'c/c++-cppcheck '(warning . rats)))

;; If you do not use cppcheck then chain after clang / gcc / other C checker
;; that you use

;; (flycheck-add-next-checker 'c/c++-clang '(warning . rats))

;;; Code:
(require 'flycheck)

(flycheck-def-args-var flycheck-rats-args rats)

(flycheck-def-option-var flycheck-rats-warning-level 2 rats
  "Set the warning level to use for rats."
  :type '(integer :tag "warning")
  :safe #'integerp)

(flycheck-define-checker rats
  "A checker using rats (Rough Auditing Tool for Security).

See `https://security.web.cern.ch/security/recommendations/en/codetools/rats.shtml`"
  :command ("rats"
            (eval flycheck-rats-args)
            (option "--warning" flycheck-rats-warning-level nil flycheck-option-int)
            source-inplace)
  ;; TODO add support for multi-line error messages
  :error-patterns ((info line-start (file-name) ":" line ": "
                         "Low: "
                         (message (one-or-more not-newline))
                         line-end)
                   (warning line-start (file-name) ":" line ": "
                            "Medium: "
                            (message (one-or-more not-newline))
                            line-end)
                   (error line-start (file-name) ":" line ": "
                          (or "High" "Default") ": "
                          (message (one-or-more not-newline))
                          line-end))
  :modes (c-mode c++-mode))

;;;###autoload
(defun flycheck-rats-setup ()
  "Setup flycheck-rats.

Add `rats' to `flycheck-checkers'."
  (interactive)
  ;; append to list
  (add-to-list 'flycheck-checkers 'rats t))

(provide 'flycheck-rats)

;;; flycheck-rats.el ends here
