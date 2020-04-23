source "%val{config}/plug.kak/rc/plug.kak"
plug "alexherbo2/auto-pairs.kak"
plug "andreyorst/smarttab.kak"
plug "andreyorst/fzf.kak" config %{
        map global normal <c-f> ':fzf-mode<ret>' -docstring 'fzf'
} defer "fzf" %{
        set-option global fzf_highlight_command 'chroma -f terminal16m -s solarized-light {}'
        set-option global fzf_file_command 'fd --type f --follow'
        set-option global fzf_sk_grep_command "rg -nSL"
}
plug "eraserhd/kak-ansi"