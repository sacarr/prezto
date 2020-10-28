#
# Install deno completions
#
# Authors:
#


# export DENO_DIR=~/.deno

# Deno is installed.  Do nothing
if (( $+commands[deno] )); then
  : # No-op

# Brew install deno.
elif  (( !$+commands[deno] )) && (( $+commands[brew] )); then
  brew install deno >/dev/null 2>&1

# Manually install deno.
elif (( !$+commands[deno] )) && (( $+commands[curl] )); then
  curl -fsSL https://deno.land/x/install/install.sh | sh >/dev/null 2>&1

# Cannot install deno.
else
  echo "Deno module installation failed.  Install brew and / or curl then try again."
fi

# Create the deno folder if it does not exists
if [[ -d "${DENO_DIR:=$HOME/.deno}/bin" ]]; then
  : # No-op
else
  mkdir ${DENO_DIR:=$HOME/.deno}/bin
fi

# Add deno compiled binaries folder to path
export PATH=${DENO_DIR:=$HOME/.deno}/bin:$PATH

# Create the deno cache folder if it does not exists
if [[ -d "${DENO_CACHE:=$HOME/.cache/deno}" ]]; then
  : # No-op
else
  mkdir ${DENO_CACHE:=$HOME/.cache/deno}
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
