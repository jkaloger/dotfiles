export XDG_CONFIG_HOME="$HOME/.config"

# Skip for non interactive shells
if [[ "${-}" != *i* ]]; then
    return
fi

for conf in "$XDG_CONFIG_HOME/zsh/conf.d/"*.zsh; do
  source "$conf"
done
