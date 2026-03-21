source "$XDG_CONFIG_HOME/zsh/tmux-window-name.zsh"

local pokemon_file="$XDG_CONFIG_HOME/zsh/pokemon.txt"

if [[ -n "$TMUX" ]]; then
  pokemon=$(tmux show-environment TMUX_POKEMON 2>/dev/null)
  if [[ $? -eq 0 && -n "$pokemon" ]]; then
    pokemon="${pokemon#*=}"
  else
    local -a pokemon_list=("${(@f)$(<"$pokemon_file")}")
    pokemon=${pokemon_list[$((RANDOM % ${#pokemon_list[@]} + 1))]}
    tmux set-environment TMUX_POKEMON "$pokemon"
  fi
  krabby name "$pokemon" --no-title
else
  local -a pokemon_list=("${(@f)$(<"$pokemon_file")}")
  krabby name "${pokemon_list[$((RANDOM % ${#pokemon_list[@]} + 1))]}" --no-title
fi

~/.local/bin/ensure-tmux
