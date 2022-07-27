;;; smelt-tshl.el --- Support for tree-sitter-hl-mode  -*- lexical-binding: t; coding: utf-8 -*-

;;; Commentary:

;;; Code:

(require 'smelt-core)
(require 'smelt-ts)

(require 'tree-sitter-hl)

(defconst smelt-tshl-highlights-file
  (concat (file-name-as-directory smelt--dir) "smelt-tshl-highlights.scm"))

(defconst smelt-tshl--hl-default-patterns
  (condition-case nil
      (with-temp-buffer
        (insert-file-contents smelt-tshl-highlights-file)
        (buffer-string))
    (file-missing nil)))

(defun smelt-tshl--setup ()
  "Configure and enable `tree-sitter-hl-mode'."
  (setq-local font-lock-defaults '(()))
  (setq-local tree-sitter-hl-default-patterns smelt-tshl--hl-default-patterns)
  (tree-sitter-hl-mode +1)
)
(add-hook 'smelt-mode-hook #'smelt-tshl--setup -10)

(provide 'smelt-tshl)

;;; smelt-tshl.el ends here
