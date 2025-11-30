*bandaid fixes
-chmod +x ~/.dumpsterpipe/bin/dumpsterpipe
 -no need to run this as root
-move the files inside of dumpsterpipe after cloning directly into .dumpsterpipe,and delete now empty dumpsterpipe folder inside of .dumpsterpipe fixing soon

##Poorly documented work in progress##

# dumpsterpipe
Meta package manager
##Installation##
```
mkdir ~/.dumpsterpipe
cd ~/.dumpsterpipe
git clone https://github.com/aScammer-Darkly/dumpsterpipe
```

##Commands##
```
dumpsterpipe install gh 
dumpsterpipe install pip 
dumpsterpipe cache update
dumpsterpipe uninstall
```

##Instructions##
Cache the pip index for completions
```
dumpsterpipe cache update
```
Set up completions
```
nano ~/.zshrc
```
Add to the bottom of your .zshrc 
source ~/.dumpsterpipe/completions/dp.zsh
autoload -Uz compinit && compinit -C  # -C skips checking the dump file
compdef _dp_complete dumpsterpipe
compdef _dp_complete dp

Tab should now provide completions for commands as well as pip packages

##Using dumpsterpipe install gh##
The syntax works like this 
```
dumpsterpipe install gh user/repo#branch 
#branch is optional, and if not specified master or main will be used
```
This will clone into the venvs directory and attempt to detect and build for you.

##Using dumpsterpipe install pip##
```
dumpsterpipe install pip <package>
```
This will create a new venv and install the pip package inside of it. 

##dp- shims##
Dumpsterpipe will attempt to detect an entry point and create a symlink dp-<entry> inside of .dumpsterpipe/bin.
These should not interfere with any system packages or dependencies. 

##Coming soon(tm)###
*make entry point detection suck less
*fix completions, again
*add backends for Flatpak, Go, crates, etc
*Make the readme actually useful
*add man page and make help commands actually work
*add cached package indexes for back ends, where feasible. 
