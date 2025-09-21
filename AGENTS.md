It's a repo for a Neovim configuration.

- The whole configuration is in the `./init.lua`. Keep it so, don't ever split
  the file.
- Check the current Nvim version: `vim --appimage-extract-and-run --version` and
  ensure to write relevant code
- After you've change the code, run the check and fix any issues:
  `vim --appimage-extract-and-run --headless -c checkhealth -c quit`
