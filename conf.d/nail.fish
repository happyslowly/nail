status is-interactive || exit

set --query _nail_symbol_prompt || set --global _nail_symbol_prompt ❱
set --query _nail_symbol_git_dirty || set --global _nail_symbol_git_dirty •
set --query _nail_symbol_git_ahead || set --global _nail_symbol_git_ahead ↑
set --query _nail_symbol_git_behind || set --global _nail_symbol_git_behind ↓

set --global _nail_git_info _nail_git_$fish_pid

function $_nail_git_info --on-variable $_nail_git_info
    commandline --function repaint
end

function _nail_git
    command kill $_nail_git_last_pid 2>/dev/null

    if test (pwd) != "$_nail_last_pwd"
        set --erase $_nail_git_info
        set --universal _nail_last_pwd (pwd)
    end

    set --local git_root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    if not set --query git_root[1]
        return
    end

    fish --private --command "
        set --local branch (
            command git symbolic-ref --short HEAD 2>/dev/null ||
            command git describe --tags --exact-match HEAD 2>/dev/null ||
            command git rev-parse --short HEAD 2>/dev/null |
                string replace --regex -- '(.+)' '@\$1'
        )
        test -z \"\$$_nail_git_info\" && set --universal $_nail_git_info \$branch

        ! command git diff-index --quiet HEAD 2>/dev/null ||
            count (command git ls-files --others --exclude-standard) >/dev/null &&
            set state \"$_nail_symbol_git_dirty\"

        command git rev-list --count --left-right @{upstream}...@ 2>/dev/null | read behind ahead
        switch \"\$behind \$ahead\"
            case \"0 0\"
            case \"0 *\"
                set upstream \" $_nail_symbol_git_ahead\$ahead\"
            case \"* 0\"
                set upstream \" $_nail_symbol_git_behind\$behind\"
            case \*
                set upstream \" $_nail_symbol_git_ahead\$ahead $_nail_symbol_git_behind\$behind\"
        end
        set --universal $_nail_git_info \"\$branch\$state\$upstream\"
        " &
        set --global _nail_git_last_pid (jobs --last --pid)
end

function _nail_pwd --on-variable PWD
    set --function pwd (prompt_pwd)
    set --function parts (string split -m1 -r / $pwd)
    if test (count $parts) -gt 1
        set --global _nail_pwd (printf '%s/%s%s%s' $parts[1] (set_color -o) $parts[2] (set_color normal))
    else
        set --global _nail_pwd (printf '%s%s%s' (set_color -o) $parts[1] (set_color normal))
    end
end

function _nail_prompt --on-event fish_prompt
    set --query _nail_pwd || _nail_pwd
    _nail_git
end


function _nail_fish_exit --on-event fish_exit
    set --erase $_nail_git_info
end

function fish_mode_prompt; end
