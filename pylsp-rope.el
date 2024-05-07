;;; pylsp-rope.el --- Pylsp rope commands -*- lexical-binding: t;
;;
;; Copyright (C) 2023 Tassilo Neubauer
;;
;; Author: Tassilo Neubauer <tassilo.neubauer@gmail.com>
;; Maintainer: Tassilo Neubauer <tassilo.neubauer@gmail.com>
;; Created: May 06, 2024
;; Modified: May 06, 2024
;; Version: 0.0.1
;; Keywords: calendar comm convenience
;; Homepage: https://github.com/tassilo/
;;
;; Package-Requires: ((emacs "27.1") (lsp-mode "8.0"))
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;;
;;; Code:

(require 'lsp-mode)

(defun pylsp-rope--plist-subset-p (subset-plist full-plist)
  "Return t if SUBSET-PLIST is a subset of FULL-PLIST."
  (cl-loop for (key value) on subset-plist by #'cddr
           always (equal (plist-get full-plist key) value)))

(defun pylsp-rope-lsp-execute-code-action-by-command (command-name &optional key-values)
  "Execute code action by COMMAND-NAME, considering only certain KEY-VALUES."
  (if-let ((action (->> (lsp-get-or-calculate-code-actions nil)
                        (-filter (-lambda ((&CodeAction :command? (&Command :command :arguments?)))
                                   (let ((args-plist (and arguments? (aref arguments? 0)))) ; No eval or quote needed.
                                     (and (string= command-name command)
                                          (or (not key-values)
                                              (pylsp-rope--plist-subset-p key-values args-plist)))))) ;turning args into list
                        lsp--select-action)))
      (lsp-execute-code-action action)
    (signal 'lsp-no-code-actions `(,command-name))))

(defmacro pylsp-rope-make-interactive-code-action (func-name command-name &optional key-values)
  "Define an interactive function FUNC-NAME that executes a specific
CODE-ACTION-COMMAND, considering only KEY-VALUES."
  (let ((function-symbol (intern (concat "pylsp-rope-" (symbol-name func-name)))))
    `(defun ,function-symbol ()
       ,(format "Execute the `%s` code action with specific\n attributes, if available." command-name)
       (interactive)
       (let ((lsp-auto-execute-action t))
         (t/print ,command-name)
         (condition-case nil
             (pylsp-rope-lsp-execute-code-action-by-command ,command-name ',key-values)
           (lsp-no-code-actions
            (when (called-interactively-p 'any)
              (lsp--info ,(format "%s action not available" command-name)))))))))


(pylsp-rope-make-interactive-code-action extract-method "pylsp_rope.refactor.extract.method")
(pylsp-rope-make-interactive-code-action inline "pylsp_rope.refactor.inline")
(pylsp-rope-make-interactive-code-action local-to-field "pylsp_rope.refactor.local_to_field")
(pylsp-rope-make-interactive-code-action organize-import "pylsp_rope.source.organize_import")
(pylsp-rope-make-interactive-code-action introduce-parameter "pylsp_rope.refactor.introduce_parameter")
(pylsp-rope-make-interactive-code-action generate-variable "pylsp_rope.quickfix.generate" (:generate_kind "variable"))
(pylsp-rope-make-interactive-code-action generate-function "pylsp_rope.quickfix.generate" (:generate_kind "function"))
(pylsp-rope-make-interactive-code-action generate-class "pylsp_rope.quickfix.generate" (:generate_kind "class"))
(pylsp-rope-make-interactive-code-action generate-module "pylsp_rope.quickfix.generate" (:generate_kind "module"))
(pylsp-rope-make-interactive-code-action generate-package "pylsp_rope.quickfix.generate" (:generate_kind "package"))


(provide 'pylsp-rope)
