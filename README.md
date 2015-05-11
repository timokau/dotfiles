dotfiles
===============

# Introduction
The files are organized by application. Each application has its own folders, in which the config files are placed like they are relative to the home folder.  
To install one of the configurations, install [GNU Stow][1], clone the repository (for example to `$HOME/dotfiles`), change into the directory and call `stow *application*`.  

# Notes and Descriptions

### (neo)vim
[neovim][2] is an "ambitious Vim-fork focused on extensibility and agility".
The vim and neovim configurations are currently identical (hard linked).

[1]: https://www.gnu.org/software/stow
[2]: https://github.com/neovim/neovim
