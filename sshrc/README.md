# Overview

sshrc is a tool that allows you to execute custom scripts and commands on a remote server when you connect via SSH.
It works by sending the file named `.sshrc` and the folder named `.sshrc.d` in the user's home directory on the remote server, and executing any commands or scripts defined in that file when the user connects via SSH. 

This can be useful for setting up environment variables, running custom scripts, or performing any other setup tasks that you want to happen automatically when you connect to a remote server.

# Installation

[GitHub](https://github.com/cdown/sshrc/tree/master)

```bash
$ wget https://raw.githubusercontent.com/Russell91/sshrc/master/sshrc && 
chmod +x sshrc && 
sudo mv sshrc /usr/local/bin #or anywhere else on your PATH
```

## Configuration

Move (or symlink) the file `.sshrc` and the directory `.sshrc.d` to your $HOME directory
to be able to use sshrc.

```bash
ln -s .sshrc ~/.sshrc
ln -s .sshrc.d ~/.sshrc.d
```

Then, you can edit the file `.sshrc` to add your custom configuration and scripts that will be executed on the remote server when you connect via SSH.

# Usage

```bash
sshrc user@remote-server -p PORT
```
