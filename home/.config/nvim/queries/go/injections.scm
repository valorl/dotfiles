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

; treat sh(``) as shell scripts 
(
 (call_expression
  function: (identifier) @_id
  arguments: (argument_list
    (raw_string_literal) @injection.content
  ))
 (#match? @_id "sh")
 (#set! injection.language "bash")
)

; treat .Expr(``) as promql (Grafana Foundation SDK)
(call_expression
  function: (selector_expression
    field: (field_identifier) @func_name
  ) 
  arguments: (argument_list
    (raw_string_literal (raw_string_literal_content) @injection.content)
  )
  (#eq? @func_name "Expr")
  (#set! injection.language "promql")
)
