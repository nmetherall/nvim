"Keybinds
inoremap jk <Esc>
set number

inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function GitBranch()
    return trim(system("git rev-parse --abbrev-ref HEAD 2>/dev/null"))
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

set statusline+=%#CocListBlackBlue#%{StatuslineGit()}%#StatusLine#
set statusline+=\ \ %f 
set statusline+=%=
set statusline+=\ \ \ %{coc#status()}%{get(b:,'coc_current_function','')}\ 
set statusline+=\ \ %l:%c
set statusline+=\ %p%%
set statusline+=\ \ %#TermCursor#\ %{strftime('%X')}\ %#StatusLine#

call plug#begin("~/.vim/plugged")
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-dadbod'
  Plug 'tpope/vim-fugitive'
  Plug 'JoosepAlviste/nvim-ts-context-commentstring'

  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'prettier/vim-prettier'

  Plug 'airblade/vim-gitgutter'
  Plug 'nvim-lua/plenary.nvim'

  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim'

  Plug 'Mofiqul/vscode.nvim'

  Plug 'nvim-lua/completion-nvim' 

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

" lspconfig
lua << EOF
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[e', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']e', vim.diagnostic.goto_next, opts)
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

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

require("mason").setup{
  ui = {
    check_outdated_packages_on_open = true,
    icons = {
        server_installed = "✓",
        server_pending = "➜",
        server_uninstalled = "✗"
    }
  },
}

require('mason-lspconfig').setup{ automatic_installation = true }

require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
    root_dir = function() return vim.loop.cwd() end,
}
require('lspconfig')['svelte'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    root_dir = function() return vim.loop.cwd() end,
}
require('lspconfig')['cspell'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    root_dir = function() return vim.loop.cwd() end,
}
require('lspconfig')['codespell'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    root_dir = function() return vim.loop.cwd() end,
}

EOF

