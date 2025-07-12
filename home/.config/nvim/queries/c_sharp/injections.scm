; treat string variables (literal - ") starting with "sql" as SQL
(
 (variable_declarator
  name: (identifier) @_id
  (string_literal
   (string_literal_content) @injection.content
  )
 )
 (#match? @_id "^sql")
 (#set! injection.language "sql")
)

; treat string variables (raw literal - """) starting with "sql" as SQL
(
 (variable_declarator
  name: (identifier) @_id
  (raw_string_literal
   (raw_string_start)
   (raw_string_content) @injection.content
   (raw_string_end)
  )
 )
 (#match? @_id "^sql")
 (#set! injection.language "sql")
)

; treat interpolation string variables starting with "sql" as SQL
(
 (variable_declarator
  name: (identifier) @_id
  (interpolated_string_expression
   (interpolation_start)
   (interpolation_quote)
   (string_content) @injection.content
   ; also match nested strings (e.g. in interpolations / ternaries etc)
   ;( ... (string_literal_content) @injection.content )*
   ; yeah nope this doesn't work
   (interpolation_quote)
  )
 )
 (#match? @_id "^sql")
 (#set! injection.language "sql")
)
