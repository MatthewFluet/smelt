;;; smelt-tshl.el --- Support for tree-sitter-mode  -*- lexical-binding: t; coding: utf-8 -*-

;;; Commentary:

;;; Code:

(require 'cl-lib)

(require 'tree-sitter)
(require 'tree-sitter-load)

(require 'smelt-core)

(defun smelt-ts--init-load-path ()
  "Add the directory of the compiled grammar to `tree-sitter-load-path'."
  (cl-pushnew smelt--bin-dir tree-sitter-load-path
              :test #'string-equal))
(smelt-ts--init-load-path)

(defun smelt-ts--init-major-mode-alist ()
  "Link `smelt-mode' to `sml' grammar."
  (cl-pushnew '(smelt-mode . sml) tree-sitter-major-mode-language-alist
              :key #'car))
(smelt-ts--init-major-mode-alist)

(defun smelt-ts--setup ()
  "Configure and enable `tree-sitter-mode' for `smelt-mode'."
  (tree-sitter-mode +1)
)
(add-hook 'smelt-mode--setup-hook #'smelt-ts--setup 1)

(provide 'smelt-ts)

;;; smelt-ts.el ends here
