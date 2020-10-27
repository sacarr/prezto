#
# Install deno completions
#
# Authors:
#

# Create teh deno cache folder if it does not exists
if [[ -d "${DENO_DIR:=$HOME/.cache/deno}" ]]; then
  : # No-op
else
  mkdir ${DENO_DIR:=$HOME/.cache/deno}
fi

# Brew install deno.
if  (( !$+commands[deno] )) && (( $+commands[brew] )); then
    brew install deno >/dev/null 2>&1
    unset deno_prefix

# Manually install deno.
elif (( !$+commands[deno] )) && (( $+commands[curl] )); then
    curl -fsSL https://deno.land/x/install/install.sh | sh
fi

# Load deno and known helper completions.
typeset -A compl_commands=(
  deno   'deno completions zsh'
)

for compl_command in "${(k)compl_commands[@]}"; do
  if (( $+commands[$compl_command] )); then
    cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/$compl_command-cache.zsh"

    # Completion commands are slow; cache their output if old or missing.
    if [[ "$commands[$compl_command]" -nt "$cache_file" \
          || "${ZDOTDIR:-$HOME}/.zpreztorc" -nt "$cache_file" \
          || ! -s "$cache_file" ]]; then
      mkdir -p "$cache_file:h"
      command ${=compl_commands[$compl_command]} >! "$cache_file" 2> /dev/null
    fi

    fpath=("$cache_file" $fpath)
    autoload -Uz compinit
    compinit -u
    unset cache_file
  fi
done

unset compl_command{s,}
