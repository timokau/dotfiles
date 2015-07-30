# PATH
typeset -U path # No double entries
path=(~/bin ~/.local/bin $path) # $PATH is generated from this array
export path
