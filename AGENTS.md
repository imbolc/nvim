It's a repo for a Neovim configuration.

## Conventions

- The entire configuration is in `./init.lua`. Keep it that way; never split the
  file.
- Follow the existing code style consistently.
- Check the current Nvim version with `vim --appimage-extract-and-run --version`
  and make sure the code you write is compatible.

## Coding tasks

- Always comment any code you add. In the comment, explain what the code does
  and its purpose in the context of the task.
- After completing a task, run the check and fix any issues:
  `vim --appimage-extract-and-run --headless -c checkhealth -c quit`
