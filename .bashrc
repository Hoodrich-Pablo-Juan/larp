export BAT_THEME="OneHalfDark"
export FZF_DEFAULT_OPTS="--color=bg+:#151515,bg:#0a0a0f,spinner:#999999,hl:#cccccc,fg:#aaaaaa,header:#999999,info:#888888,pointer:#cccccc,marker:#888888,fg+:#cccccc,prompt:#999999,hl+:#cccccc"
export LS_COLORS="di=38;5;251:ex=38;5;252:ln=38;5;245:pi=38;5;248:so=38;5;248:bd=38;5;251:cd=38;5;251:or=38;5;245"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

PS1='\[\e[38;5;252m\]\u\[\e[0m\]@\[\e[38;5;248m\]\h\[\e[0m\]:\[\e[38;5;251m\]\w\[\e[0m\] \[\e[38;5;245m\]>\[\e[0m\] '

eval "$(starship init bash)"
