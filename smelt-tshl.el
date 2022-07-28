;;; smelt-tshl.el --- Support for tree-sitter-hl-mode  -*- lexical-binding: t; coding: utf-8 -*-

;;; Commentary:

;;; Code:

(require 'smelt-core)
(require 'smelt-ts)

(require 'tree-sitter-hl)

(defface tree-sitter-hl-face:warning
  '((default :inherit font-lock-warning-face))
  "Face for warnings."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:type-def
  '((default :inherit tree-sitter-hl-face:type :slant italic))
  "Face for type definitions."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:module-def
  '((default :inherit tree-sitter-hl-face:variable :weight bold))
  "Face for module definitions."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:interface-def
  '((default :inherit tree-sitter-hl-face:type-def :weight bold))
  "Face for interface definitions."
  :group 'tree-sitter-hl-faces)

(defconst smelt-tshl-highlights-file
  (concat (file-name-as-directory smelt--dir) "smelt-tshl-highlights.scm"))

(defconst smelt-tshl--hl-default-patterns
  (condition-case nil
      (with-temp-buffer
        (insert-file-contents smelt-tshl-highlights-file)
        (buffer-string))
    (file-missing nil)))

(defun smelt-tshl--setup ()
  "Configure and enable `tree-sitter-hl-mode' for `smelt-mode'."
  (if (null font-lock-defaults)
      (setq-local font-lock-defaults '(())))
  (setq-local tree-sitter-hl-default-patterns smelt-tshl--hl-default-patterns)
  (tree-sitter-hl-mode +1)
)
(add-hook 'smelt-mode--setup-hook #'smelt-tshl--setup 1)

(provide 'smelt-tshl)

;;; smelt-tshl.el ends here
