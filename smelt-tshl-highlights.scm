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
;; Constructors
;; *******************************************************************

;; Assume value identifiers starting with capital letter are constructors.
((vid) @constructor
 (#match? @constructor "^[A-Z].*"))
(longvid ((vid) @vid
          (#match? @vid "^[A-Z].*"))) @constructor

;; "true", "false", "nil", "::", and "ref" are built-in constructors.
((vid) @constant.builtin
 (#match? @constant.builtin "true"))
((vid) @constant.builtin
 (#match? @constant.builtin "false"))
((vid) @constant.builtin
 (#match? @constant.builtin "nil"))
((vid) @constant.builtin
 (#match? @constant.builtin "::"))
((vid) @constant.builtin
 (#match? @constant.builtin "ref"))
(longvid ((vid) @vid
          (#match? @vid "true"))) @constant.builtin
(longvid ((vid) @vid
          (#match? @vid "false"))) @constant.builtin
(longvid ((vid) @vid
          (#match? @vid "nil"))) @constant.builtin
(longvid ((vid) @vid
           (#match? @vid "::"))) @constant.builtin
(longvid ((vid) @vid
          (#match? @vid "ref"))) @constant.builtin

;; *******************************************************************
;; Identifiers (binding occurrences)
;; *******************************************************************

;; Tyvar identifiers
(tyvarseq (["(" "," ")"] @type-def)? (tyvar) @type-def)

;; Value identifiers
(vid_pat (longvid (vid) @variable))
(fvalbind (fmrule name: (vid) @variable))

(valdesc (vid) @variable)

;; Tycon identifiers
(typbind name: (tycon) @type-def)
(datbind name: (tycon) @type-def)
(datarepl_dec name: (tycon) @type-def)

(typedesc (tycon) @type-def)
(datdesc (tycon) @type-def)
(datarepl_spec name: (tycon) @type-def)

;; Structure identifiers
(strbind name: (strid) @module-def)

(strdesc (strid) @module-def)

(fctbind (strid) @module-def)

;; Signature identifiers
(sigbind name: (sigid) @interface-def)

;; Functor identifiers
(fctbind name: (fctid) @module-def)

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

;; Record Selector Expressions
(recordsel_exp "#" (lab)) @label

;; *******************************************************************
;; Punctuation
;; *******************************************************************

["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["." "," ":" ";" "|" "=>" ":>"] @punctuation.delimiter
