# vim-term
vim-term is a Neovim script which all it does is run a shell command in bash, split the window and puts at the bottom a new terminal that runs the provided command.

## About
This script currently has only one command `:Cmd` which takes as an optional argument the shell command to be ran. If no arguments 
are provided, the command will show a dialog asking for the command. It works like that because I mapped `<C-q>` to `:Cmd` so I just 
press the shortcut and it asks for a command to be ran.

## Issues
The only issue at the moment is that if the terminal exits and the stream is not closed properly, the user has to `:bd Shell\ command` or 
try typing a character into the buffer for it to close. I don't know how to check for closed streams in Neovim and the only problem 
it causes is making `:Cmd` to no longer work properly, so it is isn't breaking anything if you just delete the buffer
