" iSlime2.vim - SLIME-like support for running Vim with iTerm2
" Maintainer:   Mat Schaffer <http://matschaffer.com>
" Version:      0.1

" Allows running arbitrary command with :ISlime2
command! -nargs=+ ISlime2 :call <SID>iTermSendNext("<args>")

" Rerun the previous iSlime2 command
nnoremap <leader>ff :call <SID>iTermRerun()<CR>
function! s:iTermRerun()
  if exists("g:islime2_last_command")
    call s:iTermSendNext(g:islime2_last_command)
  else
    echoerr "No previous command. Try running a test first (with <leader>ft). Or you can store a command with `ISlime2 my command`"
  endif
endfunction

" Send up and enter to re-run the previous command
nnoremap <leader>fp :call <SID>iTermSendUpEnter()<CR>
function! s:iTermSendUpEnter()
  call s:iTermSendNext("OA
")
endfunction

" Send the current visual selection or paragraph
inoremap <leader>cc <Esc>vip"ry:call <SID>iTermSendNext(@r)<CR>
vnoremap <leader>cc "ry:call <SID>iTermSendNext(@r)<CR>
nnoremap <leader>cc vip"ry:call <SID>iTermSendNext(@r)<CR>

" Send the whole file
nnoremap <leader>cf 1<S-v><S-g>"ry:call <SID>iTermSendNext(@r)<CR>

" Run script/deliver
nnoremap <leader>fd :call <SID>iTermSendNext("./script/deliver")<CR>

" Run rake
nnoremap <leader>fr :call <SID>iTermSendNext("rake")<CR>

" Run file as a spec (assumes ./bin/rspec)
nnoremap <leader>ft :call <SID>iTermRunTest(expand("%"))<CR>

" Run focused unit test (assumes ./bin/rspec understands file:line notation)
nnoremap <leader>fT :call <SID>iTermRunTest(expand("%") . ":" . line("."))<CR>

function! s:iTermRunTest(file)
  if filereadable("bin/rspec")
    call s:iTermSendNext("bin/rspec " . a:file)
  else
    echoerr "Couldn't execute " . getcwd() . "/bin/rspec, please create spec runner script."
  endif
endfunction

let s:current_file=expand("<sfile>")

" Sends the passed command to the next iTerm2 panel using Cmd+]
function! s:iTermSendNext(command)
  let l:run_command = fnamemodify(s:current_file, ":p:h:h") . "/bin/run_command.scpt"
  let g:islime2_last_command = a:command
  call system("osascript " . l:run_command . " " . s:shellesc(a:command))
endfunction

function! s:shellesc(arg) abort
  return '"'.escape(a:arg, '"').'"'
endfunction
