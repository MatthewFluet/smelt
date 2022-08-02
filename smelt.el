;;; smelt.el --- Forging Standard ML (SML) with emacs -*- lexical-binding: t; coding: utf-8 -*-

;; Copyright (C) 2022 Matthew Fluet.

;; Version: 0.1.0
;; Author: Matthew Fluet <Matthew.Fluet@gmail.com> (https://github.com/MatthewFluet)
;; SPDX-License-Identifier: MIT
;; Keywords: sml languages
;; Homepage: https://github.com/MatthewFluet/smelt

;; Package-Requires:

;;; Commentary:

;; This package implements a major-mode for editing SML source code.

;;; Code:

;;;; Core

(require 'smelt-core)

;;;; Features

(require 'smelt-fl)
(require 'smelt-ts)
(require 'smelt-ts-hl)
(require 'smelt-ts-match)

;;; _

(defun smelt-reload ()
  "Reload smelt package."
  (interactive)
  (unload-feature 'smelt)
  (unload-feature 'smelt-ts-match)
  (unload-feature 'smelt-ts-hl)
  (unload-feature 'smelt-ts)
  (unload-feature 'smelt-fl)
  (unload-feature 'smelt-core)
  (require 'smelt)
  (smelt-mode))

;;;; Footer

(provide 'smelt)

;;; smelt.el ends here
