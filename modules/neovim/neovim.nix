{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.neovim;
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf cfg.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============

    # Enable neovim system-wide and set as default editor
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = { config, ... }: {
      # Neovim configuration file
      xdg.configFile."nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/neovim/init.lua";

      # Generate stylix colors for neovim (based on stylix neovim.nix)
      xdg.configFile."nvim/lua/stylix-colors.lua".text = with config.lib.stylix.colors; ''
        local M = {}

        -- Base16 color palette
        M.palette = {
          base00 = "#${base00}",
          base01 = "#${base01}",
          base02 = "#${base02}",
          base03 = "#${base03}",
          base04 = "#${base04}",
          base05 = "#${base05}",
          base06 = "#${base06}",
          base07 = "#${base07}",
          base08 = "#${base08}",
          base09 = "#${base09}",
          base0A = "#${base0A}",
          base0B = "#${base0B}",
          base0C = "#${base0C}",
          base0D = "#${base0D}",
          base0E = "#${base0E}",
          base0F = "#${base0F}"
        }

        -- Stylix colorscheme setup function (adapted from stylix neovim.nix)
        M.setup = function()
          -- Try to use mini.base16 if available, fallback to manual highlights
          local ok, mini_base16 = pcall(require, 'mini.base16')
          if ok then
            mini_base16.setup({ palette = M.palette })
          else
            -- Manual highlight setup as fallback
            vim.cmd.highlight({ "Normal", "guifg=" .. M.palette.base05, "guibg=" .. M.palette.base00 })
            vim.cmd.highlight({ "Comment", "guifg=" .. M.palette.base03 })
            vim.cmd.highlight({ "String", "guifg=" .. M.palette.base0B })
            vim.cmd.highlight({ "Keyword", "guifg=" .. M.palette.base0E })
            vim.cmd.highlight({ "Function", "guifg=" .. M.palette.base0D })
            vim.cmd.highlight({ "Type", "guifg=" .. M.palette.base0A })
            vim.cmd.highlight({ "Constant", "guifg=" .. M.palette.base09 })
            vim.cmd.highlight({ "Error", "guifg=" .. M.palette.base08 })
            -- Add transparency if desired
            -- vim.cmd.highlight({ "Normal", "guibg=NONE", "ctermbg=NONE" })
          end
        end

        return M
      '';
    };
  };
}
