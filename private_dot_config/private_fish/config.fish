alias gcb="git checkout -b"
alias gfa="git fetch --all"
alias gpl="git pull"
alias gph="git push"
alias ga="git add"
alias gcm="git commit -m"

if true
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

switch (uname)
    case Darwin
        eval (/opt/homebrew/bin/brew shellenv)
        set -gxp PATH ~/.orbstack/bin
        set -gxp PATH ~/Library/Application\ Support/Coursier/bin
        # set -gxp PATH /opt/llvm/bin
        set -gxp PATH /opt/mpl/bin
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

set -gx ZVM_INSTALL ~/.zvm/self
set -gxp PATH ~/.zvm/bin
set -gxp PATH ~/.zvm/self

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_vi_key_bindings
    if type -q atuin
        atuin init fish | source
    end
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/homebrew/Caskroom/miniforge/base/bin/conda
    eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" hook $argv | source
end
# <<< conda initialize <<<
