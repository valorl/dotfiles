local todo_comments = prequire("todo-comments")
if todo_comments then
  todo_comments.setup({
    highlight = {
      keyword = "bg",
      pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
    },
  })
end

local gitlinker = prequire("gitlinker")
if gitlinker then
  gitlinker.setup()
end

local comment = prequire("Comment")
if comment then
  comment.setup()
end

local oil = prequire("oil")
if oil then
  oil.setup({})
end

local gitsigns = prequire("gitsigns")
if gitsigns then
  gitsigns.setup()
end

local git_conflict = prequire("git-conflict")
if git_conflict then
  git_conflict.setup()
end

local cronex = prequire("cronex")
if cronex then
  cronex.setup({})
end

local fidget = prequire("fidget")
if fidget then
  fidget.setup({})
end
