;; *******************************************************************
;; Comments
;; *******************************************************************

[(block_comment) (line_comment)] @comment

;; *******************************************************************
;; Keywords
;; *******************************************************************

[
 ;; Reserved Words Core
 "abstype" "and" "andalso" "as" "case" "datatype" "do" "else" "end"
 "exception" "fn" "fun" "handle" "if" "in" "infix" "infixr" "let"
 "local" "nonfix" "of" "op" "open" "orelse" "raise" "rec" "then"
 "type" "val" "with" "withtype" "while"
 ;; Reserved Words Modules
 "eqtype" "functor" "include" "sharing" "sig" "signature" "struct"
 "structure" "where"
] @keyword

;; *******************************************************************
;; Reserved Words
;; *******************************************************************

;; Because tree-sitter uses context-sensitive scanning, a reserved word can be
;; parsed as an identifier if that reserved word cannot occur in a particular
;; context; for example, `val x = struct` is parsed as a valbind with `struct`
;; parsed as a vid.  Highlight such misinterpreted identifiers.
([(vid) (tycon) (strid) (sigid) (fctid)] @warning
 (#match? @warning "^(?:a(?:bstype|nd(?:also)?|s)|case|d(?:atatype|o)|e(?:lse|nd|qtype|xception)|f(?:n|un(?:ctor)?)|handle|i(?:n(?:clude|fixr?)|[fn])|l(?:et|ocal)|nonfix|o(?:pen|relse|[fp])|r(?:aise|ec)|s(?:haring|ig(?:nature)?|truct(?:ure)?)|t(?:hen|ype)|val|w(?:h(?:(?:er|il)e)|ith(?:type)?)|:|_|\\||=>|->|#)$"))

;; As an additional special case, The Defn of SML excludes `*` from tycon.
([(tycon)] @warning
 (#match? @warning "^\\*$"))

;; *******************************************************************
;; Constants
;; *******************************************************************

[(integer_scon) (word_scon) (real_scon)] @number
[(string_scon) (char_scon)] @string

;; *******************************************************************
;; Tyvar Identifiers
;; *******************************************************************

;; binding occurrences
(tyvarseq (["(" "," ")"] @type.def)? (tyvar) @type.def)

;; *******************************************************************
;; Value Identifiers (Constructors)
;; *******************************************************************

;; Assume value identifiers starting with capital letter are constructors.

;; binding occurrences
(conbind ((vid) @variant.def
          (#match? @variant.def "^[A-Z].*")))
(exbind ((vid) @variant.def
         (#match? @variant.def "^[A-Z].*")))
(condesc ((vid) @variant.def
          (#match? @variant.def "^[A-Z].*")))
(exdesc ((vid) @variant.def
         (#match? @variant.def "^[A-Z].*")))

;; use occurrences
((vid) @variant
 (#match? @variant "^[A-Z].*"))
(longvid ((vid) @vid
          (#match? @vid "^[A-Z].*"))) @variant

;; "true", "false", "nil", "::", and "ref" are built-in constructors.
((vid) @variant.builtin
 (#match? @variant.builtin "^(true|false|nil|::|ref)$"))
(longvid ((vid) @vid
          (#match? @vid "^(true|false|nil|::|ref)$"))) @variant.builtin

;; *******************************************************************
;; Value Identifiers
;; *******************************************************************

;;; binding occurrences
(vid_pat (longvid (vid) @variable))
(labvar_patrow (vid) @variable)
; (as_pat (vid) @variable)

(fmrule name: (vid) @variable)

(valdesc (vid) @variable)

;; *******************************************************************
;; Tycon Identifiers
;; *******************************************************************

;;; binding occurrences
(typbind name: (tycon) @type.def)
(datbind name: (tycon) @type.def)
(datarepl_dec name: (tycon) @type.def)

(wheretype_sigexp (longtycon) @type.def)

(typedesc (tycon) @type.def)
(datdesc (tycon) @type.def)
(datarepl_spec name: (tycon) @type.def)

(sharingtype_spec (longtycon) @type.def)

;; *******************************************************************
;; Structure Identifiers
;; *******************************************************************

;;; binding occurrences
(strbind name: (strid) @module.def)

(strdesc (strid) @module.def)

(sharing_spec (longstrid) @type.def)

(fctbind (strid) @module.def)

;; *******************************************************************
;; Signature Identifiers
;; *******************************************************************

;;; binding occurrences
(sigbind name: (sigid) @interface.def)

;;; use occurrencess
(sigid) @interface

;; *******************************************************************
;; Functor Identifiers
;; *******************************************************************

;;; binding occurrences
(fctbind name: (fctid) @module.def)

;; *******************************************************************
;; Types
;; *******************************************************************

(fn_ty "->" @type)
(tuple_ty "*" @type)
(paren_ty ["(" ")"] @type)
(tyvar_ty (tyvar) @type)
(record_ty
 ["{" "," "}"] @type
 (tyrow [(lab) ":"] @type)?
 (ellipsis_tyrow ["..." ":"] @type)?)
(tycon_ty
 (tyseq ["(" "," ")"] @type)?
 (longtycon) @type)

;; *******************************************************************
;; Misc
;; *******************************************************************

;; Record Labels
(recordsel_exp "#" @property)
(lab) @property

;; *******************************************************************
;; Punctuation
;; *******************************************************************

["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["." "," ":" ";" "|" "=>" ":>"] @punctuation.delimiter
