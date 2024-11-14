Dan = { lsp = {} }
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
    -- NOTE: First, some plugins that don't require any configuration

    -- Git related plugins
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    -- pairs of [] to help navigate
    'tpope/vim-unimpaired',

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            { 'williamboman/mason.nvim', config = true },
            'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
        },
    },

    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',

            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip',

            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
        },
    },

    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim',  opts = {} },
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
                    { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
                vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk,
                    { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
                vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk,
                    { buffer = bufnr, desc = '[P]review [H]unk' })
            end,
        },
    },

    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                icons_enabled = false,
                theme = 'nord',
                component_separators = '|',
                section_separators = '',
            },
            extensions = { 'quickfix', 'fugitive', 'fzf' },
        },
    },

    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        tag='v2.20.8',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        opts = {
            char = '┊',
            show_trailing_blankline_indent = false,
        },
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
    },

    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
    },
    -- ELIXIR TOOLS START
    {
        "elixir-tools/elixir-tools.nvim",
        version = "*",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local elixir = require("elixir")
            local elixirls = require("elixir.elixirls")

            elixir.setup {
                nextls = { enable = true },
                credo = {},
                elixirls = {
                    enable = true,
                    settings = elixirls.settings {
                        dialyzerEnabled = false,
                        enableTestLenses = false,
                    },

                    handlers = {
                        ["textDocument/publishDiagnostics"] = function() end,
                    },
                    on_attach = function(client, bufnr)
                        vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
                        vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
                        vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })

                        Dan.lsp.on_attach(client, bufnr)
                    end,
                }
            }
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },



    },
    -- ELIXIR TOOLS END
    -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
    --       These are some example plugins that I've included in the kickstart repository.
    --       Uncomment any of the lines below to enable them.
    -- require 'kickstart.plugins.autoformat',
    -- require 'kickstart.plugins.debug',

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
    --    up-to-date with whatever is in the kickstart repo.
    --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --
    --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    -- { import = 'custom.plugins' },
    { "rktjmp/lush.nvim" },
    {
        "vim-test/vim-test",
        cmd = {
            "TestNearest",
            "TestFile",
            "TestLast",
            "TestVisit",
            "TestSuite",
            "A",
            "AV",
        },
        keys = {
            { "<localleader>tn",            "<cmd>TestNearest<cr>", desc = "run (n)earest test" },
            { "<localleader>ta",            "<cmd>TestFile<cr>",    desc = "run (a)ll tests in file" },
            { "<localleader>tf",            "<cmd>TestFile<cr>",    desc = "run (a)ll tests in file" },
            { "<localleader>tl",            "<cmd>TestLast<cr>",    desc = "run (l)ast test" },
            { "<localleader>ts",            "<cmd>TestSuite<cr>",   desc = "run test (s)uite" },
            -- { "<localleader>tT", "<cmd>TestLast<cr>", desc = "run _last test" },
            { "<localleader>tv",            "<cmd>TestVisit<cr>",   desc = "(v)isit last test" },
            { "<localleader>tp",            "<cmd>A<cr>",           desc = "open alt (edit)" },
            { "<localleader><localleader>", "<cmd>A<cr>",           desc = "open alt (edit)" },
            { "<localleader>tP",            "<cmd>AV<cr>",          desc = "open alt (vsplit)" },
        },
        -- event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            {
                "tpope/vim-projectionist",
                event = { "BufReadPost", "BufNewFile" },
                ft = { "elixir", "javascript", "typescript", "heex", "eelixir", "surface" },
                config = function()
                    vim.g.projectionist_heuristics = {
                        ["mix.exs"] = {
                            ["lib/**/views/*_view.ex"] = {
                                type = "view",
                                alternate = "test/{dirname}/views/{basename}_view_test.exs",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}View do",
                                    "  use {dirname|camelcase|capitalize}, :view",
                                    "end",
                                },
                            },
                            ["test/**/views/*_view_test.exs"] = {
                                type = "test",
                                alternate = "lib/{dirname}/views/{basename}_view.ex",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}ViewTest do",
                                    "  use ExUnit.Case, async: true",
                                    "",
                                    "  alias {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}View",
                                    "end",
                                },
                            },
                            ["lib/**/controllers/*_controller.ex"] = {
                                type = "controller",
                                alternate = "test/{dirname}/controllers/{basename}_controller_test.exs",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}Controller do",
                                    "  use {dirname|camelcase|capitalize}, :controller",
                                    "end",
                                },
                            },
                            ["test/**/controllers/*_controller_test.exs"] = {
                                type = "test",
                                alternate = "lib/{dirname}/controllers/{basename}_controller.ex",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}ControllerTest do",
                                    "  use {dirname|camelcase|capitalize}.ConnCase, async: true",
                                    "end",
                                },
                            },
                            ["lib/**/controllers/*_html.ex"] = {
                                type = "html",
                                alternate = "test/{dirname}/controllers/{basename}_html_test.exs",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}HTML do",
                                    "  use {dirname|camelcase|capitalize}, :html",
                                    "",
                                    [[  embed_templates "{basename|snakecase}_html/*"]],
                                    "end",
                                },
                            },
                            ["test/**/controllers/*_html_test.exs"] = {
                                type = "test",
                                alternate = "lib/{dirname}/controllers/{basename}_html.ex",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}HTMLTest do",
                                    "  use {dirname|camelcase|capitalize}.ConnCase, async: true",
                                    "",
                                    "  alias {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}HTML",
                                    "end",
                                },
                            },
                            ["lib/**/components/*.ex"] = {
                                type = "component",
                                alternate = "test/{dirname}/components/{basename}_test.exs",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize} do",
                                    "  use Phoenix.Component",
                                    "end",
                                },
                            },
                            ["lib/**/components/*.html.heex"] = {
                                type = "html",
                                alternate = "lib/{dirname}/components/{basename}.ex",
                            },
                            ["test/**/components/*_test.exs"] = {
                                type = "test",
                                alternate = "lib/{dirname}/components/{basename}.ex",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}Test do",
                                    "  use {dirname|camelcase|capitalize}.ConnCase, async: true",
                                    "",
                                    "  alias {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}",
                                    "end",
                                },
                            },
                            ["lib/**/live/*_live.ex"] = {
                                type = "liveview",
                                alternate = "test/{dirname}/live/{basename}_live_test.exs",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}Live do",
                                    "  use {dirname|camelcase|capitalize}, :live_view",
                                    "end",
                                },
                            },
                            ["lib/**/live/*_live.html.heex"] = {
                                type = "html",
                                alternate = "lib/{dirname}/live/{basename}_live.ex",
                            },
                            ["test/**/live/*_live_test.exs"] = {
                                type = "test",
                                alternate = "lib/{dirname}/live/{basename}_live.ex",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}LiveTest do",
                                    "  use {dirname|camelcase|capitalize}.ConnCase",
                                    "",
                                    "  import Phoenix.LiveViewTest",
                                    "end",
                                },
                            },
                            ["lib/**/live/*_component.ex"] = {
                                type = "livecomponent",
                                alternate = "lib/{dirname}/live/{basename}_component.html.heex",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}Live do",
                                    "  use {dirname|camelcase|capitalize}, :live_view",
                                    "end",
                                },
                            },
                            ["lib/**/live/*_component.html.heex"] = {
                                type = "html",
                                alternate = "lib/{dirname}/live/{basename}_component.ex",
                            },
                            ["lib/**/channels/*_channel.ex"] = {
                                type = "channel",
                                alternate = "test/{dirname}/channels/{basename}_channel_test.exs",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}Channel do",
                                    "  use {dirname|camelcase|capitalize}, :channel",
                                    "end",
                                },
                            },
                            ["test/**/channels/*_channel_test.exs"] = {
                                type = "test",
                                alternate = "lib/{dirname}/channels/{basename}_channel.ex",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}ChannelTest do",
                                    "  use {dirname|camelcase|capitalize}.ChannelCase, async: true",
                                    "",
                                    "  alias {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}Channel",
                                    "end",
                                },
                            },
                            ["test/**/features/*_test.exs"] = {
                                type = "feature",
                                template = {
                                    "defmodule {dirname|camelcase|capitalize}.{basename|camelcase|capitalize}Test do",
                                    "  use {dirname|camelcase|capitalize}.FeatureCase, async: true",
                                    "end",
                                },
                            },
                            ["lib/*.ex"] = {
                                type = "source",
                                alternate = "test/{}_test.exs",
                                template = { "defmodule {camelcase|capitalize|dot} do", "end" },
                            },
                            ["test/*_test.exs"] = {
                                type = "test",
                                alternate = "lib/{}.ex",
                                template = {
                                    "defmodule {camelcase|capitalize|dot}Test do",
                                    "  use ExUnit.Case, async: true",
                                    "",
                                    "  alias {camelcase|capitalize|dot}",
                                    "end",
                                },
                            },
                        },
                    }
                end,
            },
            -- { "tpope/vim-dispatch"},
            -- { "elixir-editors/vim-elixir"}
            -- { "preservim/vimux"}
        },
        init = function()
            vim.g["test#strategy"] = "neovim"
            vim.g["test#ruby#use_binstubs"] = 0
            vim.g["test#ruby#bundle_exec"] = 0
            vim.g["test#filename_modifier"] = ":."
            vim.g["test#preserve_screen"] = 1
            -- vim.g["tslime_always_current_session"] = 1
            -- vim.g["tslime_always_current_window"] = 1
            -- vim.g["tslime_autoset_pane"] = 1
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    { "othree/xml.vim" }
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]resume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
    modules = {},
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'elixir', 'heex', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript',
        'vimdoc', 'vim' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,
    sync_install = true,
    ignore_install = {},

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>A'] = '@parameter.inner',
            },
        },
    },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
Dan.lsp.on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    nmap('gR', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- tsserver = {},
    -- html = { filetypes = { 'html', 'twig', 'hbs'} },

    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = Dan.lsp.on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        }
    end
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
-- local luasnip = require 'luasnip'
-- require('luasnip.loaders.from_vscode').lazy_load()
-- luasnip.config.setup {}

cmp.setup {
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            -- elseif luasnip.expand_or_locally_jumpable() then
            --     luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            -- elseif luasnip.locally_jumpable(-1) then
            --     luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    }),
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- TELESCOPE START
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, {})
-- TELESCOPE END
-- Color scheme
vim.opt.background = 'dark'
vim.g.colorscheme = 'nordish'
local lush = require('lush')
lush(require('dan.lush_theme.nordish'))

-- Don't let neovim steal Y, leave it for yank line
vim.api.nvim_exec(
    [[
nnoremap Y Y
]], true)

vim.opt.mouse = ""

-- Diff mappings
vim.keymap.set('n', '<leader>dgh', ':diffget //2<CR>', {})
vim.keymap.set('n', '<leader>dgl', ':diffget //3<CR>', {})
