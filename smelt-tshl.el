;;; smelt-tshl.el --- Support for tree-sitter-hl-mode  -*- lexical-binding: t; coding: utf-8 -*-

;;; Commentary:

;;; Code:

;;;; Requirements

(require 'smelt-core)
(require 'smelt-ts)

(require 'tree-sitter-hl)

;;;; Customization (Faces)

;;;;; Warning

(defface tree-sitter-hl-face:warning
  '((default :inherit font-lock-warning-face))
  "Face for warnings."
  :group 'tree-sitter-hl-faces)

;;;;; Variables

(defface tree-sitter-hl-face:variable.use
  '((default :inherit default))
  "Face for variable definitions."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:variable.def
  ;; `tree-sitter-hl-face:variable' is documented as binding occurrence
  '((default :inherit tree-sitter-hl-face:variable))
  "Face for variable definitions (binding occurrences)."
  :group 'tree-sitter-hl-faces)

;;;;; Variants

(defface tree-sitter-hl-face:variant.def
  '((default :inherit tree-sitter-hl-face:variable.def :weight thin))
  "Face for enum variant definitions (binding occurrences)."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:variant.use
  '((default :inherit tree-sitter-hl-face:variable.use :weight thin))
  "Face for enum variant uses."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:variant.builtin
  '((default :inherit tree-sitter-hl-face:constant.builtin :weight bold))
  "Face for builtin enum variants."
  :group 'tree-sitter-hl-faces)

;;;;; Fields

(defface tree-sitter-hl-face:field
  '((default :inherit default :underline t))
  "Face for fields."
  :group 'tree-sitter-hl-faces)

;;;;; Types

(defface tree-sitter-hl-face:type.use
  '((default :inherit tree-sitter-hl-face:type))
  "Face for type uses."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:type.def
  '((default :inherit tree-sitter-hl-face:type :slant italic))
  "Face for type definitions (binding occurrences)."
  :group 'tree-sitter-hl-faces)

;;;;; Modules

(defface tree-sitter-hl-face:module.use
  '((default :inherit tree-sitter-hl-face:variable.use))
  "Face for module uses."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:module.def
  '((default :inherit tree-sitter-hl-face:variable.def :weight bold))
  "Face for module definitions (binding occurrences)."
  :group 'tree-sitter-hl-faces)

;;;;; Interfaces

(defface tree-sitter-hl-face:interface.use
  '((default :inherit tree-sitter-hl-face:type :weight bold))
  "Face for interface uses."
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-hl-face:interface.def
  '((default :inherit tree-sitter-hl-face:interface.use :slant italic))
  "Face for interface definitions (binding occurrences)."
  :group 'tree-sitter-hl-faces)

;;;; Public

(defconst smelt-tshl-highlights-file
  (concat (file-name-as-directory smelt--dir) "smelt-tshl-highlights.scm"))

;;;; Private

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

;;;; Footer

(provide 'smelt-tshl)

;;; smelt-tshl.el ends here
