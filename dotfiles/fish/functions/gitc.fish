function gitc --description "git commit with nvim in insert mode"
  GIT_EDITOR="nvim -c 'startinsert'" git commit
end
