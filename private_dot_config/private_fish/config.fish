if false && grep -q -i microsoft /proc/version
  set -gx PROXY_PORT 7890
  set -gx WSL_HOST (cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
  set -gx http_proxy http://{$WSL_HOST}:{$PROXY_PORT}
  set -gx https_proxy http://{$WSL_HOST}:{$PROXY_PORT}
  set -gx all_proxy http://{$WSL_HOST}:{$PROXY_PORT}
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_vi_key_bindings
end
