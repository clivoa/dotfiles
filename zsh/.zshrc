# ------------------------------
# Spaceship Prompt
# ------------------------------
source /opt/homebrew/opt/spaceship/spaceship.zsh
ZSH_THEME="spaceship"

# ------------------------------
# Dracula Colors for Spaceship (combina com o tmux)
# ------------------------------
# dir = roxo, git branch = verde, char ok = rosa, char erro = vermelho
SPACESHIP_DIR_COLOR="141"
SPACESHIP_GIT_BRANCH_COLOR="84"
SPACESHIP_CHAR_COLOR_SUCCESS="212"
SPACESHIP_CHAR_COLOR_FAILURE="203"
SPACESHIP_EXIT_CODE_COLOR="203"

# ------------------------------
# Zsh Completion System
# ------------------------------
autoload -Uz compinit
compinit

# ------------------------------
# Interactive Completion Menu
# ------------------------------
zmodload zsh/complist
zstyle ':completion:*' menu select

# ------------------------------
# Case-insensitive Completion
# ------------------------------
# Digitar "doc<Tab>" completa "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# ------------------------------
# Dracula Colors for Completion
# ------------------------------
# Explicação:
# ma = trecho que deu match → azul acinzentado (Dracula comment)
# di = diretórios → roxo Dracula
# fi = arquivos normais → cyan Dracula
# sb = highlight do item selecionado no menu → current-line Dracula
zstyle ':completion:*:default' list-colors \
"ma=48;5;60;38;5;255" \
"di=38;5;141" \
"fi=38;5;117" \
"sb=48;5;237;38;5;255"

# This is for openvpn
export PATH="/opt/homebrew/Cellar/openvpn/2.6.17/sbin:$PATH"

# brew vim
alias vim=$(find /opt/homebrew/Cellar/vim -name vim -type f | sort -Vr | head -n 1)

source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.4.1 # run chruby to see actual version

# ------------------------------
# Autosuggestions (sugestão em cinza enquanto digita; → aceita)
# ------------------------------
# Sugestão no azul acinzentado "comment" do Dracula (mesmo tom do ma= acima)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=60"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ------------------------------
# fzf (Ctrl+R busca fuzzy no histórico, Ctrl+T arquivos)
# ------------------------------
# Paleta Dracula oficial para o fzf
export FZF_DEFAULT_OPTS="
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
source <(fzf --zsh)

# ------------------------------
# zoxide (cd inteligente: "z proj" acha o diretório)
# ------------------------------
eval "$(zoxide init zsh)"

# ------------------------------
# Syntax Highlighting (deve ser o último source do arquivo)
# ------------------------------
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ------------------------------
# Dracula Colors for Syntax Highlighting
# ------------------------------
# comando válido = verde, inválido = vermelho, strings = amarelo,
# flags = cyan, paths = sublinhado, comentários = azul acinzentado
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=203"
ZSH_HIGHLIGHT_STYLES[command]="fg=84"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=84"
ZSH_HIGHLIGHT_STYLES[function]="fg=84"
ZSH_HIGHLIGHT_STYLES[alias]="fg=84"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=84,underline"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=228"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=228"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=228"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=117"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=117"
ZSH_HIGHLIGHT_STYLES[path]="underline"
ZSH_HIGHLIGHT_STYLES[comment]="fg=60"
