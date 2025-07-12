; treat sh(""" """) as shell scripts 
(
  (call
    function: (identifier) @_id
    arguments: (argument_list
      (string
        (string_start)
        (string_content) @injection.content
        (string_end)
      )
    )
  )
  (#match? @_id "sh")
  (#set! injection.language "bash")
)
