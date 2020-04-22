eval %sh{kak-lsp --kakoune -s $kak_session}
hook global WinSetOption filetype=(rust|dart) %{
        lsp-enable-window
	map global normal <c-l> ':eum lsp<ret>'
}
hook -group make-rust global WinSetOption filetype=rust %[
        set-option window makecmd cargo
        set-option global compiler cargo
]
