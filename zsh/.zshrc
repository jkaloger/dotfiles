export XDG_CONFIG_HOME="$HOME/.config"

for conf in "$XDG_CONFIG_HOME/zsh/conf.d/"*.zsh; do
  source "$conf"
done
