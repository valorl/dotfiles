; treat string variables starting with "sql" as SQL
(
 (const_spec
  name: (identifier) @_id
  value: (expression_list (raw_string_literal) @injection.content))
 (#match? @_id "^sql")
 (#set! injection.language "sql")
)

; treat string variables starting with "gql" as GraphQL
(
 (const_spec
  name: (identifier) @_id
  value: (expression_list (raw_string_literal) @injection.content))
 (#match? @_id "^gql")
 (#set! injection.language "graphql")
)
