function GoToModule()
    local P = function(value)
        print(vim.inspect(value))
    end
    local ts = vim.treesitter
    local parsers = require('nvim-treesitter.parsers')

    local parser = parsers.get_parser()
    local tree = parser:parse()[1]
    local root = tree:root()

    -- (attribute
    --   (identifier) @key
    --   (#eq? @key "source")
    --   (expression
    --     (literal_value (string_lit (template_literal) @value))
    --   )

    local t = function(node)
        return ts.get_node_text(node, 0)
    end

    local lang = parser:lang()

    local qs = [[
        (attribute
          (identifier) @key
          (#eq? @key "source")
          (expression
            (literal_value (string_lit (template_literal) @value))
          )
        ) @attr
    ]]
    local match = ""
    local query = ts.query.parse(lang, qs)
    for _, matches, _ in query:iter_matches(root, 0) do
         match = t(matches[2])
    end

    P(match)

    local job = require("plenary.job")
    job:new({
        command = "sh",
        args = {"-c", string.format("tmux new-window -n testing -d && tmux send-keys -t testing 'echo %s' Enter && tmux select-window -t testing", match)},
    }):sync()
end
