;;; smelt-ts-match.el --- Support for showing matching begin/end pairs using tree-sitter-mode  -*- lexical-binding: t; coding: utf-8 -*-

;;; Commentary:

;; Use tree-sitter grammar and queries to show matching begin/end pairs.
;; Inspired by similar functionality provided by SMIE.

;;; Code:

;;;; Requirements

(require 'cl-lib)

(require 'tree-sitter)

(require 'smelt-core)
(require 'smelt-ts)

;;;; Public

(defconst smelt-ts-match-patterns-file
  (concat (file-name-as-directory smelt--dir) "matches.scm"))

;;;; Private

(defconst smelt-ts-match--default-patterns
  (condition-case nil
      (with-temp-buffer
        (insert-file-contents smelt-ts-match-patterns-file)
        (buffer-string))
    (file-missing nil)))

(defvar-local smelt-ts-match--query nil
  "Tree-sitter query used for showing matching begin/end pairs, compiled from patterns.")

(defun smelt-ts-match--ensure-query ()
  "Return the tree-sitter query to be used for showing matching begin/end pairs in this buffer."
  (unless smelt-ts-match--query
    (setq smelt-ts-match--query
          (when smelt-ts-match--default-patterns
            (tsc-make-query
             tree-sitter-language
             (tsc--stringify-patterns smelt-ts-match--default-patterns)))))
  smelt-ts-match--query)

(defun smelt-ts-match--choose-match-data (fst snd)
  "Choose the \"better\" of FST and SND, which are results of functions suitable for `show-paren-data-function' (which see)."
  (pcase (cons fst snd)
    (`(nil . nil) nil)
    (`(nil . ,_)  snd)
    (`(,_  . nil) fst)
    (`((,fst-here-beg ,fst-here-end ,fst-there-beg ,fst-there-end ,_) .
       (,snd-here-beg ,snd-here-end ,snd-there-beg ,snd-there-end ,_))
     (let ((fst-left-beg (min fst-here-beg fst-there-beg))
           (fst-left-end (min fst-here-end fst-there-end))
           ;; (fst-right-beg (max fst-here-beg fst-there-beg))
           (fst-right-end (max fst-here-end fst-there-end))
           (snd-left-beg (min snd-here-beg snd-there-beg))
           (snd-left-end (min snd-here-end snd-there-end))
           ;;(snd-right-beg (max snd-here-beg snd-there-beg))
           (snd-right-end (max snd-here-end snd-there-end)))
       (cond
        ((or
          ;; fst precedes snd
          (<= fst-right-end snd-left-beg)
          ;; fst is contained in snd
          (and (<= snd-left-end fst-left-beg)
               (<= fst-right-end snd-right-end)))
         fst)
        ((or
          ;; snd precedes fst
          (<= snd-right-end fst-left-beg)
          ;; snd is contained in fst
          (and (<= fst-left-end snd-left-beg)
               (<= snd-right-end fst-right-end)))
         snd)
        ;; impossible?
        (t nil))))))

(defun smelt-ts-match--match-data (when-point-inside)
  "Find an opener/inner/closer \"near\" point and its match.

Returns either nil if there is no opener/inner/closer near point,
or a list of the form (HERE-BEG HERE-END THERE-BEG THERE-END MISMATCH),
where HERE-BEG..HERE-END is expected to be near point.
\(See `show-paren-data-function'.)

`smelt-ts-match--query' should hold a tree-sitter query with
patterns that capture nodes with capture names of the form
\"@opener\", \"@inner\", and \"@closer\".  Each pattern should
capture one \"@opener\", zero or more \"@inner\"s, and at most
one \"@closer\", where the \"@opener\" precedes all \"@inner\"s
and the \"@closer\" (if present) and all \"@inner\"s precede the
\"@closer\" (if present).  An \"@opener\" node behaves like an
open parenthesis (i.e., is found if the point immediately
precedes or is contained in the node) and matches with the
corresponding \"@closer\" node (if present).  An \"@inner\" or
a \"@closer\" node behaves like a close parenthesis (i.e., is found
if the point is contained in or immediately follows the node) and
matches with the corresponding \"@opener\" node.

If WHEN-POINT-INSIDE is non-nil, then an \"@opener\" is also
found if the point immediately follows the node and an \"@inner\"
or a \"@closer\" is also found if the point immediately precedes
the node.

Inspired by `smie--matching-block-data'."
  (let ((res nil))
    (tsc--save-context
      (let* ((root-node (tsc-root-node tree-sitter-tree))
             (query smelt-ts-match--query)
             (matches (tsc-query-matches query
                                         root-node
                                         #'tsc--buffer-substring-no-properties)))
        (seq-doseq (match matches)
          (let* ((captures (cdr match))
                 (opener (cdr (seq-find (lambda (capture)
                                          (equal 'opener (car capture)))
                                        captures
                                        '(opener . nil))))
                 (closer (cdr (seq-find (lambda (capture)
                                          (equal 'closer (car capture)))
                                        captures
                                        '(closer . nil))))
                 (inners (seq-mapcat (lambda (capture)
                                       (and (equal 'inner (car capture))
                                            (list (cdr capture))))
                                     captures)))
            (when opener
              (if (and closer
                       (<= (tsc-node-start-position opener) (point))
                       (if when-point-inside
                           (<= (point) (tsc-node-end-position opener))
                         (< (point) (tsc-node-end-position opener))))
                  (setq res
                        (smelt-ts-match--choose-match-data
                         res
                         (list (tsc-node-start-position opener)
                               (tsc-node-end-position opener)
                               (tsc-node-start-position closer)
                               (tsc-node-end-position closer)
                               nil))))
              (dolist (ender (append (ensure-list closer) inners))
                (if (and (if when-point-inside
                             (<= (tsc-node-start-position ender) (point))
                           (< (tsc-node-start-position ender) (point)))
                         (<= (point) (tsc-node-end-position ender)))
                    (setq res
                          (smelt-ts-match--choose-match-data
                           res
                           (list (tsc-node-start-position ender)
                                 (tsc-node-end-position ender)
                                 (tsc-node-start-position opener)
                                 (tsc-node-end-position opener)
                                 nil))))))))))
    res))

(defun smelt-ts-match--show-paren (orig)
  "Find an opener/inner/closer \"near\" point and its match.

It is a function suitable for `show-paren-data-function' (which see).

Inspired by `smie--matching-block-data'."
  (smelt-ts-match--choose-match-data
   (smelt-ts-match--match-data show-paren-when-point-inside-paren)
   orig))

(defun smelt-ts-match--setup ()
  "Configure and enable `tree-sitter-mode' for `smelt-mode'."
  (when (smelt-ts-match--ensure-query)
    (add-function :filter-return (local 'show-paren-data-function)
                  #'smelt-ts-match--show-paren)))
(add-hook 'smelt-mode--setup-hook #'smelt-ts-match--setup 1)

(provide 'smelt-ts-match)

;;; smelt-ts-match.el ends here
