"Keybinds
inoremap jk <Esc>
set number

function GitBranch()
    return trim(system("git rev-parse --abbrev-ref HEAD 2>/dev/null"))
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

set statusline+=%#Folded#%{StatuslineGit()}%#StatusLine#
set statusline+=\ \ %f 
set statusline+=%=
" set statusline+=\ \ \ %{coc#status()}%{get(b:,'coc_current_function','')}\ 
set statusline+=\ \ %l:%c
set statusline+=\ %p%%
set statusline+=\ \ %#TermCursor#\ %{strftime('%X')}\ %#StatusLine#

call plug#begin("~/.vim/plugged")
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-dadbod'
  Plug 'tpope/vim-fugitive'

  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'JoosepAlviste/nvim-ts-context-commentstring'

  Plug 'prettier/vim-prettier'

  Plug 'airblade/vim-gitgutter'

  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim'

  Plug 'Mofiqul/vscode.nvim'

  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'

  Plug 'jose-elias-alvarez/null-ls.nvim'

  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'neovim/nvim-lspconfig'
call plug#end()

lua << EOF
  -- For dark theme (neovim's default)
  vim.o.background = 'dark'
  local c = require('vscode.colors')
  require('vscode').setup({
      -- Enable transparent background
      transparent = true,

      -- Enable italic comment
      italic_comments = true,

      -- Disable nvim-tree background color
      disable_nvimtree_bg = true,

      -- Override highlight groups (see ./lua/vscode/theme.lua)
      group_overrides = {
          -- this supports the same val table as vim.api.nvim_set_hl
          -- use colors from this colorscheme by requiring vscode.colors!
          -- Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
      }
  })
EOF

" Tabs As Spaces
set smartindent
set tabstop=2
set expandtab
set shiftwidth=2

" Folding
autocmd FileType * setl foldmethod=syntax
autocmd FileType * setl foldlevelstart=99

" Prettier
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
" autocmd InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.svelte,*.yaml,*.html PrettierAsync

" Telescope
lua << EOF
require('telescope').setup{
  defaults = {
    file_ignore_patterns = { "node_modules" },
  }
}
EOF
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

lua << EOF
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "vim", "typescript", "tsx", "json", "fish", "bash", "javascript", "css", "scss", "html", "svelte", "typescript" },
  highlight = {
    enable = true,
    custom_captures = {
      ["property"] = "TSVariable",
      ["parameter"] = "TSVariable",
      ["variable.function"] = "TSVariable",
    },
  },
  context_commentstring = {
    enable = true
  }
})
EOF

set completeopt=menu,menuone,noselect

" lspconfig
lua << EOF
-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.diagnostic.config({
  virtual_text = false,
  signs = false
})
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev{severity='ERROR'} end, opts)
vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next{severity='ERROR'} end, opts)
vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']g', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workleader_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>aw', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

vim.o.updatetime = 250
vim.api.nvim_create_autocmd("CursorHold", {
  buffer = bufnr,
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      scope = 'cursor',
    }
    vim.diagnostic.open_float(nil, opts)
  end
})

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

require("mason").setup{}

require('mason-lspconfig').setup{ 
  automatic_installation = true,
  -- ensure_installed = { "cspell" }
}

require('lspconfig')['sumneko_lua'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "lua" },
    root_dir = function() return vim.loop.cwd() end,
}
require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
    root_dir = function() return vim.loop.cwd() end,
}
require('lspconfig')['tailwindcss'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    root_dir = function() return vim.loop.cwd() end,
}
require('lspconfig')['svelte'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    root_dir = function() return vim.loop.cwd() end,
}

local null_ls = require('null-ls')
require('null-ls').setup{
  sources = {
    null_ls.builtins.diagnostics.cspell.with({ 
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity["WARN"]
      end,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
      -- extra_args = { '--config', '~/.config/nvim/cspell.json' }
    }),
    null_ls.builtins.code_actions.cspell,
  },
  on_attach = on_attach
}
EOF
