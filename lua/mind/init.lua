local mind_commands = require'mind.commands'
local mind_keymap = require'mind.keymap'
local mind_node = require'mind.node'
local mind_state = require'mind.state'

local M = {}

M.setup = function(opts)
  M.opts = vim.tbl_deep_extend('force', require'mind.defaults', opts or {})

  -- load tree state
  mind_state.load_state(M.opts)

  -- keymaps
  mind_keymap.init_keymaps(M.opts)
  mind_commands.precompute_commands()
end

-- Open the main tree.
M.open_main = function()
  mind_commands.open_tree(mind_state.state.tree, M.opts.persistence.data_dir, M.opts)
end

-- Open a project tree.
--
-- If `use_global` is set to `true`, will use the global persistence location.
M.open_project = function(use_global)
  M.wrap_project_tree_fn(
    function(tree, opts)
      mind_commands.open_tree(tree, mind_state.get_project_data_dir(), opts)
    end,
    use_global,
    M.opts
  )
end

-- Load state.
M.load_state = function()
  mind_state.load_state(M.opts)
end

-- Wrap a function call expecting a project tree.
--
-- If the project tree doesn’t exist, it is automatically created.
M.wrap_project_tree_fn = function(f, use_global, opts)
  local tree
  if (mind_state.local_tree == nil or use_global) then
    local cwd = vim.fn.getcwd()
    tree = mind_state.projects[cwd]

    if (tree == nil) then
      tree = {
        contents = {
          { text = cwd:match('^.+/(.+)$') },
        },
        type = mind_node.TreeType.ROOT,
        icon = M.opts.ui.root_marker,
      }
      mind_state.projects[cwd] = tree
    end
  else
    tree = mind_state.local_tree
  end

  f(tree, opts)
end

return M
