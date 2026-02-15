# vim-term
vim-term is a Neovim script that all it does is ask for a bash command,
split the current window and execute the command in a new terminal

## Features ig
* The script is configurable but only by modifying the script itself since
its made to work for me
* `:Cmd` takes an optional argument which is the command to be ran. If no
arguments are provided, it will ask the user to provide a shell command,
and if none are provided, it will try to repeat the last command used in
that vim session. This command is supposed to be binded to a shortcut,
but it can still be used straight from the command line mode of vim
* `:CmdRepeat` does the same thing as `:Cmd`, but instead of reusing the
same terminal buffer, it starts a fresh new one every time it is ran

## Known issues
* If the terminal exits and the buffer remains open, the script breaks,
but can be fixed just by deleting the buffer or opening it in insert mode,
then pressing any key
* While using `:CmdRepeat`, the buffer number will become the last buffer
number + 2 for each command. Its because vim manages these numbers
internally and afaik its impossible to go lower
