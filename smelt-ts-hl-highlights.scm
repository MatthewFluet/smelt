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
(conbind name: ((vid) @variant.def
                (#match? @variant.def "^[A-Z].*")))
(exbind name: ((vid) @variant.def
               (#match? @variant.def "^[A-Z].*")))
(condesc name: ((vid) @variant.def
                (#match? @variant.def "^[A-Z].*")))
(exdesc name: ((vid) @variant.def
               (#match? @variant.def "^[A-Z].*")))

;; use occurrences
(vid_exp (longvid ((vid) @vid
                   (#match? @vid "^[A-Z].*"))) @variant.use)
(exbind def: (longvid ((vid) @vid
                       (#match? @vid "^[A-Z].*"))) @variant.use)
(vid_pat (longvid ((vid) @vid
                   (#match? @vid "^[A-Z].*"))) @variant.use)

;; "true", "false", "nil", "::", and "ref" are built-in constructors.
(vid_exp (longvid ((vid) @vid
                   (#match? @vid "^(true|false|nil|::|ref)$"))) @variant.builtin)
(vid_pat (longvid ((vid) @vid
                   (#match? @vid "^(true|false|nil|::|ref)$"))) @variant.builtin)

;; *******************************************************************
;; Value Identifiers
;; *******************************************************************

;; binding occurrences
(fmrule name: (vid) @variable)

(infix_dec (vid) @variable.def)
(infixr_dec (vid) @variable.def)
(nonfix_dec (vid) @variable.def)

(vid_pat (longvid . (vid) @variable.def))
(labvar_patrow (vid) @variable.def)
; (as_pat (vid) @variable.def)

(valdesc (vid) @variable)

;; use occurrences
(vid_exp (longvid) @variable.use)
(labvar_exprow (vid) @variable.use)

;; *******************************************************************
;; Tycon Identifiers
;; *******************************************************************

;; binding occurrences
(typbind name: (tycon) @type.def)
(datbind name: (tycon) @type.def)
(datarepl_dec name: (tycon) @type.def)

(wheretype_sigexp (longtycon) @type.def)

(typedesc (tycon) @type.def)
(datdesc (tycon) @type.def)
(datarepl_spec name: (tycon) @type.def)

(sharingtype_spec (longtycon) @type.def)

;; use occurrences: see `Types`

;; *******************************************************************
;; Structure Identifiers
;; *******************************************************************

;; binding occurrences
(strbind name: (strid) @module.def)

(strdesc (strid) @module.def)

(sharing_spec (longstrid) @type.def)

(fctbind (strid) @module.def)

;; use occurences
(open_dec (longstrid) @module.use)
(strid_strexp (longstrid) @module.use)

;; *******************************************************************
;; Signature Identifiers
;; *******************************************************************

;;; binding occurrences
(sigbind name: (sigid) @interface.def)

;;; use occurrencess
(sigid_sigexp (sigid) @interface)
(include_spec (sigid) @interface)

;; *******************************************************************
;; Functor Identifiers
;; *******************************************************************

;; binding occurrences
(fctbind name: (fctid) @module.def)

;; use occurrences
(fctapp_strexp (fctid) @module.def)

;; *******************************************************************
;; Types
;; *******************************************************************

(fn_ty "->" @type.use)
(tuple_ty "*" @type.use)
(paren_ty ["(" ")"] @type.use)
(tyvar_ty (tyvar) @type.use)
(record_ty
 ["{" "," "}"] @type.use
 (tyrow [(lab) ":"] @type.use)?
 (ellipsis_tyrow ["..." ":"] @type.use)?)
(tycon_ty
 (tyseq ["(" "," ")"] @type.use)?
 (longtycon) @type.use)

;; *******************************************************************
;; Labels
;; *******************************************************************

(recordsel_exp "#" @field)
(lab) @field

;; *******************************************************************
;; Punctuation
;; *******************************************************************

["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," ":" ";" "|" "=>" ":>"] @punctuation.delimiter
