;;; smelt-fl.el --- Support for font-lock-mode  -*- lexical-binding: t; coding: utf-8 -*-

;;; Commentary:

;;; Code:

(require 'smelt-core)

(require 'font-lock)

(defconst smelt-fl--keywords
  `((,(regexp-opt smelt--sml-keywords 'symbols) . font-lock-keyword-face)))

(defconst smelt-fl--defaults
  '(smelt-fl--keywords nil nil ((?\\ . "\\"))))

(defun smelt-fl--setup ()
  "Configure `font-lock-mode'."
  (setq-local font-lock-defaults smelt-fl--defaults)
)
(add-hook 'smelt-mode-hook #'smelt-fl--setup -20)

(provide 'smelt-fl)

;;; smelt-fl.el ends here
