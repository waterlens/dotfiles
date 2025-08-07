switch (uname)
    case Darwin
        eval (/opt/homebrew/bin/brew shellenv)
        set -gxp PATH ~/.orbstack/bin
        set -gxp PATH ~/Library/Application\ Support/Coursier/bin
        # set -gxp PATH /opt/llvm/bin
        set -gxp PATH /opt/mpl/bin
        set -gxp PATH /opt/tinycc/bin
        if type -q xcrun
            set -gx SDKROOT (xcrun --show-sdk-path)
        end
        set -gx JAVA_HOME (/usr/libexec/java_home -v 17)
    case Linux
end

set -gxp PATH ~/.local/bin
set -gxp PATH ~/.ghcup/bin
set -gxp PATH ~/.cargo/bin
set -gxp PATH ~/.moon/bin
set -gxp PATH ~/.rbenv/bin
set -gxp PATH ~/.zvm/bin
set -gxp PATH ~/.zvm/self
set -gx ZVM_INSTALL ~/.zvm/self

# CUDA
set -gxp PATH /usr/local/cuda/bin
set -gxp LD_LIBRARY_PATH /usr/local/cuda/lib

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

abbr -a gcb -- git checkout -b
abbr -a gfa -- git fetch --all
abbr -a gpl -- git pull
abbr -a gph -- git push
abbr -a ga -- git add
abbr -a gcm -- git commit -m
abbr -a gst -- git status
abbr -a gc -- git checkout
abbr -a glg -- git log --graph --abbrev-commit --decorate --format="format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''%C(white)%s%C(reset) %C(dim white)- %an%C(reset)'" --all
if type -q zellij
    abbr -a zj -- zellij
end
if type -q helix
    set -gx EDITOR helix
    abbr -a hx -- helix
end
if type -q hx
    set -gx EDITOR hx
end

if false
    if grep -s -q -i microsoft /proc/version
        set -gx proxy_port 7890
        set -gx proxy_host (cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
    else
        set -gx proxy_port 7890
        set -gx proxy_host localhost
    end
    set -gx http_proxy http://{$proxy_host}:{$proxy_port}
    set -gx https_proxy http://{$proxy_host}:{$proxy_port}
    set -gx all_proxy http://{$proxy_host}:{$proxy_port}
end

ulimit -n 10240

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

# You are so slow !!!
function conda_init --description "Initialize conda"
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    if test -f conda
        eval conda "shell.fish" hook $argv | source
    end
    # <<< conda initialize <<<
end

function last_history_item
    echo $history[1]
end
function last_history_token
    echo $history[1] | read -t -a tokens
    echo $tokens[-1]
end
abbr -a !! --position anywhere --function last_history_item
abbr -a !, --position anywhere --function last_history_token

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/waterlens/.lmstudio/bin
# End of LM Studio CLI section
