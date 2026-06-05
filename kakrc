
### Pretty I
set-option global tabstop 4
set-option global indentwidth 4
set-option global scrolloff 3,5
set-option global aligntab true
set-option global eolformat lf
set-option global incsearch true
set-option global grepcmd 'rg -Hn --no-heading --vimgrep --smart-case'
add-highlighter global/ number-lines -hlcursor -relative -separator "  " -cursor-separator " |"
add-highlighter global/ regex \h+$ 0:Error
add-highlighter global/ wrap -word -indent
add-highlighter global/ show-matching

### Plugins
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload
## Plugins
# autopairs
plug "alexherbo2/auto-pairs.kak" config %{
  enable-auto-pairs
}
# powerline
plug "andreyorst/powerline.kak" defer kakoune-themes %{
  powerline-theme pastel
} defer powerline %{
  powerline-format global "git lsp bufname filetype mode_info lsp line_column position"
  set-option global powerline_separator_thin ""
  set-option global powerline_separator ""
} config %{
  powerline-start
}
# enhanced selection
plug "evanrelf/byline.kak" config %{
  require-module "byline"
}
# future proof just in case
plug "gustavo-hms/luar" %{
  require-module luar
}
# buffers
plug 'delapouite/kakoune-buffers' %{
  map global normal ^ q
  map global normal <a-^> Q
  map global normal q b
  map global normal Q B
  map global normal <a-q> <a-b>
  map global normal <a-Q> <a-B>
  map global normal b ': enter-buffers-mode<ret>' -docstring 'buffers'
  map global normal B ': enter-user-mode -lock buffers<ret>' -docstring 'buffers (lock)'
}
plug 'occivink/kakoune-buffer-switcher'
# to change or print the working directory
plug 'delapouite/kakoune-cd' %{
  # Suggested mapping
  map global user c ': enter-user-mode cd<ret>' -docstring 'cd'
  # Suggested aliases
  alias global cdb change-directory-current-buffer
  alias global cdr change-directory-project-root
  alias global ecd edit-current-buffer-directory
  alias global pwd print-working-directory
}
# jump between dependent files
plug 'delapouite/kakoune-goto-file' %{
  # Suggested mappings
  map global goto f '<esc>: goto-file<ret>' -docstring 'file'
  map global goto F f -docstring 'file (legacy)'
}
# npm and yarn
plug 'delapouite/kakoune-npm'
# clipboard
plug "lePerdu/kakboard" %{
    hook global WinCreate .* %{ kakboard-enable }
}
# lol
plug "delapouite/kakoune-text-objects"
plug "https://gitlab.com/Screwtapello/kakoune-inc-dec"
# handle tabs
plug "andreyorst/smarttab.kak"
# lol II (requires procps-ng)
plug "andreyorst/pmanage.kak"
# vscode
plug "andreyorst/tagbar.kak" defer "tagbar" %{
    set-option global tagbar_sort false
    set-option global tagbar_size 40
    set-option global tagbar_display_anon false
} config %{
    # if you have wrap highlighter enamled in you configuration
    # files it's better to turn it off for tagbar, using this hook:
    hook global WinSetOption filetype=tagbar %{
        remove-highlighter window/wrap
        # you can also disable rendering whitespaces here, line numbers, and
        # matching characters
    }
}
# enable lsp
eval %sh{kak-lsp}
lsp-enable
lsp-auto-hover-enable
lsp-auto-signature-help-enable
## Hooks
# softwrap in markdown
hook global WinSetOption filetype=markdown %{
  add-highlighter -override global/markdown-wrap wrap -word

  hook -once -always window WinSetOption filetype=.* %{
    remove-highlighter global/markdown-wrap
  }
}

hook global InsertCompletionShow .* %{
    try %{
        execute-keys -draft 'h<a-K>\h<ret>'
        map window insert <tab> <c-n>
        map window insert <s-tab> <c-p>
        hook -once -always window InsertCompletionHide .* %{
            map window insert <tab> <tab>
            map window insert <s-tab> <s-tab>
        }
    }
}
### Pretty II and other bullshits i dont give a fuck about or appendix
plug "caksoylar/kakoune-mysticaltutor" theme %{ colorscheme mysticaltutor }
plug "andreyorst/powerline.kak" defer powerline %{
    set-option global powerline_ignore_warnings true
    powerline-separator global none
} config %{
    powerline-start
}
plug "jordan-yee/kakoune-mysticaltutor-powerline" defer powerline_mysticaltutor %{
    powerline-theme mysticaltutor
}
hook global BufWritePre .* %{
    try %{ execute-keys -draft '%s\h+$<ret>d' }
}
hook global WinSetOption filetype=(rust|go|c|cpp) %{
    set-option window tabstop 4
    set-option window indentwidth 4
}
hook global WinSetOption filetype=(javascript|typescript|html|css|json|yaml|markdown) %{
    set-option window tabstop 2
    set-option window indentwidth 2
}
declare-option -hidden str git_diff_out
define-command -hidden update-git-gutter %{
    nop %sh{
        (
            diff=$(git diff -U0 -- "$kak_buffile" 2>/dev/null | grep -E '^@@' | awk '{print $3}')
            # 格式化輸出並安全傳回 Kakoune
            printf "set-option buffer git_diff_out '%s'" "$diff" | kak -p "$kak_session"
        ) >/dev/null 2>&1 &
    }
}
hook global BufOpenFile .* %{ update-git-gutter }
hook global BufWritePost .* %{ update-git-gutter }
plug "andreyorst/fzf.kak"
