#!/usr/bin/env fish

### Set up common tools

function cuda_init --description "Initialize CUDA path manually"
    # CUDA
    set -gxp PATH /usr/local/cuda/bin
    set -gxp LD_LIBRARY_PATH /usr/local/cuda/lib
end

function conda_init --description "Initialize conda manually"
    if type -q conda
        eval (conda "shell.fish" hook $argv)
    else
        echo "Error: conda command not found." >&2
    end
end

switch (uname)
    case Darwin
        eval (/opt/homebrew/bin/brew shellenv)
        set -gxp PATH ~/.orbstack/bin
        set -gxp PATH ~/Library/Application\ Support/Coursier/bin
        set -gxp PATH /opt/llvm/bin
        set -gxp PATH /opt/mpl/bin
        set -gxp PATH /opt/tinycc/bin
        if type -q xcrun
            set -gx SDKROOT (xcrun --show-sdk-path)
        end
        set -gx JAVA_HOME (/usr/libexec/java_home -v 17)
    case '*'
end

set -gxp PATH ~/.local/bin
set -gxp PATH ~/.ghcup/bin
set -gxp PATH ~/.cargo/bin
set -gxp PATH ~/.moon/bin
set -gxp PATH ~/.rbenv/bin
set -gxp PATH ~/.zvm/bin
set -gxp PATH ~/.zvm/self
set -gx ZVM_INSTALL ~/.zvm/self
# Added by LM Studio CLI (lms)
set -gxp PATH ~/.lmstudio/bin
# End of LM Studio CLI section

if type -q moon
    moon shell-completion --shell fish >~/.config/fish/completions/moon.fish
end
if type -q nodenv
    source (nodenv init -|psub)
    set -gxp PATH ~/.nodenv/bin
end
if type -q opam
    eval (opam env)
end
if type -q rbenv
    source (rbenv init -|psub)
end
if type -q xmake
    source ~/.xmake/profile
end

### Add abbreviations and aliases

abbr -a gcb -- git checkout -b
abbr -a gfa -- git fetch --all
abbr -a gpl -- git pull
abbr -a gph -- git push
abbr -a ga -- git add
abbr -a gcm -- git commit -m
abbr -a gst -- git status
abbr -a gc -- git checkout
abbr -a glg -- git log --graph --abbrev-commit --decorate --format="format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''%C(white)%s%C(reset) %C(dim white)- %an%C(reset)'" --all
abbr -a gcl -- git clone
abbr -a gd -- git diff
if type -q helix
    set -gx EDITOR helix
    abbr -a hx -- helix
else if type -q hx
    set -gx EDITOR hx
end
if type -q zellij
    abbr -a zj -- zellij
end

function __last_history_item
    echo $history[1]
end
function __last_history_token
    echo $history[1] | read -t -a tokens
    echo $tokens[-1]
end
function __last_history_prefix
    echo $history[1] | read -t -a tokens
    echo $tokens[1..-2]
end

abbr -a !! --position anywhere --function __last_history_item
abbr -a !. --position anywhere --function __last_history_token
abbr -a !, --position anywhere --function __last_history_prefix

for __index in (seq 1 9)
    function __last_history_token_at_$__index --inherit-variable __index
        echo $history[1] | read -l -t -a tokens
        echo $tokens[$__index]
    end
    abbr -a !$__index --position anywhere --function __last_history_token_at_$__index
end

### Set up tools in interactive shell mode

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_vi_key_bindings
    if type -q atuin
        atuin init fish | source
    end

    if test "$TERM_PROGRAM" != vscode
        if type -q zellij
            # Configure auto-attach/exit to your likings (default is off).
            set ZELLIJ_AUTO_ATTACH false
            set ZELLIJ_AUTO_EXIT true
            if not set -q ZELLIJ
                if test "$ZELLIJ_AUTO_ATTACH" = true
                    zellij attach -c
                else
                    zellij
                end

                if test "$ZELLIJ_AUTO_EXIT" = true
                    exec sh -c "exit $status"
                end
            end
        end
    end
end

### Set up proxy

function setup_proxy --description "Sets up proxy environment variables based on the OS"
    set -l proxy_port 7897 # Use a local variable for the port

    switch (uname)
        case Darwin
            set -g proxy_host localhost
        case Linux
            if grep -s -q -i microsoft /proc/version
                # WSL: get host IP from /etc/resolv.conf
                set -g proxy_host (cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
            else
                set -g proxy_host localhost
            end
    end

    if set -q proxy_host[1]
        set -gx http_proxy "http://{$proxy_host}:{$proxy_port}"
        set -gx https_proxy "http://{$proxy_host}:{$proxy_port}"
        set -gx all_proxy "http://{$proxy_host}:{$proxy_port}"
        set -gx no_proxy "127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,172.29.0.0/16,localhost,*.local,*.crashlytics.com,<local>"
    end
end

setup_proxy

### Misc

ulimit -n 10240
