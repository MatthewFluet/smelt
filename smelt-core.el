;;; smelt-core.el --- Core -*- lexical-binding: t; coding: utf-8 -*-

;;; Commentary:

;;; Code:

;;;; Customization

(defgroup smelt nil
  "Support for Standard ML code."
  :group 'languages)

;;;; Constants

(defconst smelt--dir
  (when load-file-name (file-name-directory load-file-name))
  "Directory of the `smelt' library.")

(defconst smelt--bin-dir
  (concat (file-name-as-directory smelt--dir) "bin/")
  "Directory of (platform-dependent) support binaries.")

(defconst smelt--sml-keywords
  '(;; Reserved Words Core
    "abstype" "and" "andalso" "as" "case" "datatype" "do" "else" "end"
    "exception" "fn" "fun" "handle" "if" "in" "infix" "infixr" "let"
    "local" "nonfix" "of" "op" "open" "orelse" "raise" "rec" "then"
    "type" "val" "with" "withtype" "while"
    ;; Reserved Words Modules
    "eqtype" "functor" "include" "sharing" "sig" "signature" "struct"
    "structure" "where"))

;;;; Variables

(defvar smelt-mode--setup-hook nil)

;;;; Keymaps

(defvar smelt-mode-map
  (let ((map (make-sparse-keymap)))
    map))

;;;;; Syntax Table

(defvar smelt-mode-syntax-table 
 (let ((st (make-syntax-table)))
    ;; Comments
    (modify-syntax-entry ?\( "()1" st)
    (modify-syntax-entry ?\) ")(4" st)
    (modify-syntax-entry ?\* ". 23n" st)
    ;; Punctuation
    (mapc (lambda (c) (modify-syntax-entry c "."  st)) ".,;")
    ;; Identifiers
    ;;; Alphanumeric identifiers include ' and _
    (mapc (lambda (c) (modify-syntax-entry c "_"  st)) "'_")
    ;;; Symbolic identifiers
    (mapc (lambda (c) (modify-syntax-entry c "."  st)) "!%&$#+-/:<=>?@\\~`^|")
    st)
  "The syntax table used in `smelt-mode'.")

;;;;; Abbrev Table

(define-abbrev-table 'smelt-mode-abbrev-table nil
  "Abbrevs for `smelt-mode.'")

;;;; Mode

;;;###autoload
(define-derived-mode smelt-mode prog-mode "smelt"
  "Major mode for Standard ML code.

\\{smelt-mode-map}"
  :group 'smelt
  (run-hooks 'smelt-mode--setup-hook)
)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\(\\.s\\(ml\\|ig\\)\\|\\.fun\\)\\'" . smelt-mode))

;;;; Features

;;;;; Comment

(defun smelt-comment--setup ()
  "Configure comments for `smelt-mode'."
  (setq-local parse-sexp-ignore-comments t)
  (setq-local comment-start "(* ")
  (setq-local comment-end " *)")
  (setq-local comment-start-skip "(\\*+\\s-*")
  (setq-local comment-end-skip "\\s-*\\*+)")
  (setq-local comment-quote-nested nil)
)
(add-hook 'smelt-mode--setup-hook #'smelt-comment--setup 1)

;;;; Footer

(provide 'smelt-core)

;;; smelt-core.el ends here
