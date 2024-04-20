require("mmazoni.remap")
require("mmazoni.set")
require("mmazoni.lazy_init")
-- colorscheme 
require('catppuccin').setup()
vim.cmd.colorscheme "catppuccin"

-- telescope
require('telescope').setup({})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>pws', function()
local word = vim.fn.expand("<cword>")
builtin.grep_string({ search = word })
end)
vim.keymap.set('n', '<leader>pWs', function()
local word = vim.fn.expand("<cWORD>")
builtin.grep_string({ search = word })
end)
vim.keymap.set('n', '<leader>ps', function()
builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

-- treesitter
require("nvim-treesitter.configs").setup({
-- A list of parser names, or "all"
ensure_installed = {
    "vimdoc", "python", "dockerfile", "fish", "lua", "helm",
    "json", "bash", "yaml", "terraform", "xml", "java"
},

-- Install parsers synchronously (only applied to `ensure_installed`)
sync_install = false,

-- Automatically install missing parsers when entering buffer
-- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
auto_install = true,

indent = {
    enable = true
},

highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = { "markdown" },
},
})

-- lsp
local cmp = require('cmp')
local cmp_lsp = require("cmp_nvim_lsp")
local capabilities = vim.tbl_deep_extend(
"force",
{},
vim.lsp.protocol.make_client_capabilities(),
cmp_lsp.default_capabilities())

require("fidget").setup({})
require("mason").setup()
require("mason-lspconfig").setup({
ensure_installed = {
    "lua_ls",
    "ansiblels",
    "azure_pipelines_ls",
    "bashls",
    "docker_compose_language_service",
    "dockerls",
    "helm_ls",
    "powershell_es",
    "ruff_lsp",
    "terraformls",
},
handlers = {
    function(server_name) -- default handler (optional)

        require("lspconfig")[server_name].setup {
            capabilities = capabilities
        }
    end,

    ["lua_ls"] = function()
        local lspconfig = require("lspconfig")
        lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
                Lua = {
			runtime = { version = "Lua 5.1" },
                    diagnostics = {
                        globals = { "vim", "it", "describe", "before_each", "after_each" },
                    }
                }
            }
        }
    end,
}
})

local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
snippet = {
    expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
},
mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
}),
sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
}, {
    { name = 'buffer' },
})
})

vim.diagnostic.config({
-- update_in_insert = true,
float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
},
})

-- harpoon
local harpoon = require('harpoon')
harpoon:setup({})

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
local file_paths = {}
for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
end

require("telescope.pickers").new({}, {
    prompt_title = "Harpoon",
    finder = require("telescope.finders").new_table({
        results = file_paths,
    }),
    previewer = conf.file_previewer({}),
    sorter = conf.generic_sorter({}),
}):find()
end

vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
{ desc = "Open harpoon window" })
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

-- fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

local Mmazoni_Fugitive = vim.api.nvim_create_augroup("Mmazoni_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufWinEnter", {
group = Mmazoni_Fugitive,
pattern = "*",
callback = function()
    if vim.bo.ft ~= "fugitive" then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local opts = {buffer = bufnr, remap = false}
    vim.keymap.set("n", "<leader>p", function()
        vim.cmd.Git('push')
    end, opts)

    -- rebase always
    vim.keymap.set("n", "<leader>P", function()
        vim.cmd.Git({'pull',  '--rebase'})
    end, opts)

    -- NOTE: It allows me to easily set the branch i am pushing and any tracking
    -- needed if i did not set the branch up correctly
    vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
end,
})


vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>")
vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>")

-- undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- zenmode
vim.keymap.set("n", "<leader>zz", function()
    require("zen-mode").setup {
        window = {
            width = 90,
            options = { }
        },
    }
    require("zen-mode").toggle()
    vim.wo.wrap = false
    vim.wo.number = true
    vim.wo.rnu = true
end)


vim.keymap.set("n", "<leader>zZ", function()
    require("zen-mode").setup {
        window = {
            width = 80,
            options = { }
        },
    }
    require("zen-mode").toggle()
    vim.wo.wrap = false
    vim.wo.number = false
    vim.wo.rnu = false
    vim.opt.colorcolumn = "0"
end)

