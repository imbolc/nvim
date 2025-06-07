;; extends

; Injects SQL into sqlx macros that use raw string literals.
; e.g., sqlx::query!(r"SELECT * FROM users")
(
 (macro_invocation
  (scoped_identifier
   path: (identifier) @_path
   name: (identifier) @_name)
  (token_tree
   (raw_string_literal (string_content) @injection.content)))
 (#eq? @_path "sqlx")
 (#match? @_name
  "^(query|query_as|query_as_unchecked|query_scalar|query_scalar_unchecked|query_unchecked)$")
 (#set! injection.language "sql")
)

; Injects SQL into sqlx macros that use regular string literals.
; e.g., sqlx::query!("SELECT * FROM users")
(
 (macro_invocation
  (scoped_identifier
   path: (identifier) @_path
   name: (identifier) @_name)
  (token_tree
   (string_literal (string_content) @injection.content)))
 (#eq? @_path "sqlx")
 (#match? @_name
  "^(query|query_as|query_as_unchecked|query_scalar|query_scalar_unchecked|query_unchecked)$")
 (#set! injection.language "sql")
)

