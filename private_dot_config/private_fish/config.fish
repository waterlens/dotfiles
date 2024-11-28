if false && grep -q -i microsoft /proc/version
  set -gx PROXY_PORT 7890
  set -gx WSL_HOST (cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
  set -gx http_proxy http://{$WSL_HOST}:{$PROXY_PORT}
  set -gx https_proxy http://{$WSL_HOST}:{$PROXY_PORT}
  set -gx all_proxy http://{$WSL_HOST}:{$PROXY_PORT}
end

switch (uname)
  case Darwin
    eval (/opt/homebrew/bin/brew shellenv)
    set -gxp PATH ~/.orbstack/bin
    set -gxp PATH ~/Library/Application\ Support/Coursier/bin
    set -gxp PATH /opt/llvm/bin
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
if type -q moon
  moon shell-completion --shell fish > ~/.config/fish/completions/moon.fish
end
if type -q nodenv
  source (nodenv init -|psub)
  set -gxp PATH ~/.nodenv/bin
end
if type -q opam
  eval (opam env)
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
    eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<
