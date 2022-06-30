function fish_prompt
    test -n "$$_nail_git_info" && set --local git_span (set_color -o brblack)"$$_nail_git_info"(set_color normal)

    set --local prompt (string join -n ' ' \
        $_nail_pwd $git_span $_nail_symbol_prompt)

    echo -e "$prompt "
end

