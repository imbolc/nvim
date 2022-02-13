-- sudo npm install -g prettier lua-fmt yaml-unist-parser
-- pip3 install black isort
-- cargo install taplo-cli

local keymap = vim.api.nvim_set_keymap
local keyopts = {noremap = true, silent = true}

vim.g.mapleader = ","

vim.o.cursorline = true

-- Line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Wrapping
vim.o.wrap = false
vim.o.breakindent = true
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {noremap = true, expr = true, silent = true})
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {noremap = true, expr = true, silent = true})

-- Search
vim.o.incsearch = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- Indentation
vim.o.smarttab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.autoindent = true

-- Decrease update time
vim.o.updatetime = 100

-- don't lose selection when shifting
keymap("x", "<", "<gv", keyopts)
keymap("x", ">", ">gv", keyopts)

-- Splits
vim.o.splitbelow = true
vim.o.splitright = true

keymap("n", "<C-h>", "<C-w>h", keyopts)
keymap("n", "<C-j>", "<C-w>j", keyopts)
keymap("n", "<C-k>", "<C-w>k", keyopts)
keymap("n", "<C-l>", "<C-w>l", keyopts)

keymap("n", "<C-Up>", ":resize +3<CR>", keyopts)
keymap("n", "<C-Down>", ":resize -3<CR>", keyopts)
keymap("n", "<C-Left>", ":vertical resize +3<CR>", keyopts)
keymap("n", "<C-Right>", ":vertical resize -3<CR>", keyopts)

-- disable ex mode
keymap("n", "Q", "<nop>", keyopts)
keymap("n", "q:", "<nop>", keyopts)

-- Colorscheme
vim.o.termguicolors = true
vim.o.background = "light"
vim.cmd [[colorscheme PaperColor]]

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Switching between tabs by <tab> / <shift-tab>
keymap("n", "<tab>", "gt", keyopts)
keymap("n", "<s-tab>", "gT", keyopts)

-- don't lose selection when shifting
keymap("x", "<", "<gv", keyopts)
keymap("x", ">", ">gv", keyopts)

vim.api.nvim_command("autocmd BufWritePost *.json5 set filetype=json5")

-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap =
        vim.fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
end

return require("packer").startup(
    function(use)
        use("wbthomason/packer.nvim")

        use {
            "numToStr/Comment.nvim",
            config = function()
                require("Comment").setup()
            end
        }

        use {
            "mhartington/formatter.nvim",
            config = function()
                function prettier_default(...)
                    return {
                        exe = "prettier",
                        args = {
                            "--stdin-filepath",
                            vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
                            ...
                        },
                        stdin = true
                    }
                end
                require("formatter").setup(
                    {
                        filetype = {
                            html = {prettier_default},
                            json = {prettier_default},
                            json5 = {prettier_default},
                            yaml = {prettier_default},
                            css = {prettier_default},
                            vue = {prettier_default},
                            markdown = {prettier_default},
                            javascript = {
                                function()
                                    return {
                                        exe = "prettier",
                                        args = {
                                            "--stdin-filepath",
                                            vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
                                            "--tab-width",
                                            4
                                        },
                                        stdin = true
                                    }
                                end
                            },
                            lua = {
                                function()
                                    return {
                                        exe = "luafmt",
                                        args = {"--stdin"},
                                        stdin = true
                                    }
                                end
                            },
                            rust = {
                                function()
                                    return {
                                        exe = "rustfmt",
                                        args = {"--emit=stdout"},
                                        stdin = true
                                    }
                                end
                            },
                            toml = {
                                function()
                                    return {
                                        exe = "taplo",
                                        args = {"fmt", "-"},
                                        stdin = true
                                    }
                                end
                            },
                            python = {
                                function()
                                    return {
                                        exe = "isort",
                                        args = {"--profile", "black", "-"},
                                        stdin = true
                                    }
                                end,
                                function()
                                    return {
                                        exe = "black",
                                        args = {"-"},
                                        stdin = true
                                    }
                                end
                            }
                        }
                    }
                )
                vim.api.nvim_exec(
                    [[
			augroup FormatAutogroup
				autocmd!
				autocmd BufWritePost * silent! FormatWrite
			augroup END
			]],
                    true
                )
            end
        }

        use "NLKNguyen/papercolor-theme"

        -- Telescope
        use(
            {
                "nvim-telescope/telescope.nvim",
                requires = "nvim-lua/plenary.nvim",
                module = "telescope",
                after = {
                    "telescope-fzf-native.nvim",
                    "telescope-packer.nvim"
                },
                config = function()
                    local telescope = require("telescope")

                    telescope.setup(
                        {
                            defaults = {
                                file_ignore_patterns = {".git", "node_modules"}
                            },
                            extensions = {
                                fzf = {
                                    fuzzy = true,
                                    override_generic_sorter = true,
                                    override_file_sorter = true
                                }
                            }
                        }
                    )

                    telescope.load_extension("fzf")
                    telescope.load_extension("packer")
                end
            }
        )
        use({"nvim-telescope/telescope-fzf-native.nvim", run = "make"})
        use("nvim-telescope/telescope-packer.nvim")

        --- LSP
        use(
            {
                "neovim/nvim-lspconfig",
                config = function()
                    local on_attach = function(client, bufnr)
                        local function keymap(...)
                            vim.api.nvim_buf_set_keymap(bufnr, ...)
                        end

                        require("lsp_signature").on_attach(lspSignatureCfg)
                        require("illuminate").on_attach(client)

                        -- Mappings.
                        local opts = {noremap = true, silent = true}
                        keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                        keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
                        keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
                        keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                        keymap("n", "<space>k", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
                        keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
                        keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
                        keymap(
                            "n",
                            "<space>wl",
                            "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
                            opts
                        )
                        keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
                        keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                        keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
                        keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
                        keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
                        keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
                        keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
                        keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setqflist()<CR>", opts)

                        -- Set some keybinds conditional on server capabilities
                        if client.resolved_capabilities.document_formatting then
                            keymap("n", "<space>f", ":lua vim.lsp.buf.formatting()<CR>", opts)
                            vim.cmd(
                                [[
                                augroup lsp_format
                                    autocmd! * <buffer>
                                    autocmd BufWritePost <buffer> lua vim.lsp.buf.formatting_sync()
                                augroup END
                                ]]
                            )
                        elseif client.resolved_capabilities.document_range_formatting then
                            keymap("n", "<space>rf", ":lua vim.lsp.buf.range_formatting_sync()<CR>", opts)
                        end
                    end

                    local function make_config()
                        local capabilities = vim.lsp.protocol.make_client_capabilities()
                        capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
                        return {
                            capabilities = capabilities,
                            on_attach = on_attach
                        }
                    end

                    local lsp_installer = require("nvim-lsp-installer")

                    lsp_installer.on_server_ready(
                        function(server)
                            local config = make_config()

                            if server.name == "sumneko_lua" then
                                config = require("lsp.servers.sumneko_lua").setup(config, on_attach)
                            end

                            if server.name == "texlab" then
                                config = require("lsp.servers.texlab").setup(config, on_attach)
                            end

                            if server.name == "html" then
                                config = require("lsp.servers.html").setup(config, on_attach)
                            end

                            if server.name == "jsonls" then
                                config = require("lsp.servers.jsonls").setup(config, on_attach)
                            end

                            if server.name == "tsserver" then
                                config = require("lsp.servers.tsserver").setup(config, on_attach)
                            end

                            if server.name == "yamlls" then
                                config = require("lsp.servers.yamlls").setup(config, on_attach)
                            end

                            if server.name == "volar" then
                                config = require("lsp.servers.volar").setup(config, on_attach)
                            end

                            if server.name == "rust_analyzer" then
                                config = require("lsp.servers.rust_analyzer").setup(config, on_attach)
                            end

                            server:setup(config)
                            vim.cmd([[ do User LspAttachBuffers ]])
                        end
                    )
                end
            }
        )
        use("williamboman/nvim-lsp-installer")

        -- Automatically set up your configuration after cloning packer.nvim
        -- Put this at the end after all plugins
        if packer_bootstrap then
            require("packer").sync()
        end
    end
)
