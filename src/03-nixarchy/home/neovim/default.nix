{ pkgs, ... }:
let
  t = import ../theme/palette.nix;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      plenary-nvim
      telescope-nvim
      gitsigns-nvim
      nvim-web-devicons
    ];
    extraPackages = with pkgs; [
      ripgrep
      fd
      wl-clipboard
    ];
    initLua = ''
      vim.g.mapleader = " "
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.termguicolors = true
      vim.opt.clipboard = "unnamedplus"
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.signcolumn = "yes"
      require("tokyonight").setup({
        style = "night",
        on_colors = function(c)
          c.bg = "#${t.background}"
          c.bg_dark = "#${t.background}"
          c.bg_highlight = "#${t.surface}"
          c.fg = "#${t.foreground}"
          c.comment = "#${t.muted}"
          c.blue = "#${t.blue}"
          c.cyan = "#${t.cyan}"
          c.magenta = "#${t.purple}"
          c.green = "#${t.green}"
          c.yellow = "#${t.yellow}"
          c.red = "#${t.red}"
        end,
      })
      vim.cmd.colorscheme("tokyonight-night")
      require("gitsigns").setup()
      require("telescope").setup()
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Search text" })
      vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Find buffers" })
    '';
  };
}
