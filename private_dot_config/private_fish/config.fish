if grep -q -i microsoft /proc/version
  set -Ux PROXY_PORT 7890
  set -Ux WSL_HOST (cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
  set -Ux http_proxy http://{$WSL_HOST}:{$PROXY_PORT}
  set -Ux https_proxy http://{$WSL_HOST}:{$PROXY_PORT}
  set -Ux all_proxy http://{$WSL_HOST}:{$PROXY_PORT}
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_vi_key_bindings
end
