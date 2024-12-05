" Let's learn some vimscript. Loosely following this online book
" https://learnvimscriptthehardway.stevelosh.com/
" I'm more interested in learning vimscript than in correct code, so I may be
" brute forcing a lot of stuff...

" You can symlink this file to ~/.vimrc in windows Git Bash:
" - Make a ~/.bash_profile file and put in "export MSYS=winsymlinks:nativestrict"
" - Run git bash in administrator mode
" - "ln -s /path/to/advent/vimrc ~/.vimrc"


" Basic vimrc setup for convenient stuff I like... {{{
" Use pathogen as a vim plugin manager {{{
" Comment this out if you don't have pathogen installed
execute pathogen#infect()
" }}}

" Tabs suck, use spaces {{{
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
" }}}

" Other basic options {{{
set hlsearch
set nowrap
" }}}

" Mappings {{{
let mapleader = ","

noremap <Leader>w :w<Enter>
noremap <Leader>q :q<Enter>

inoremap jk <Esc>

noremap <Leader>h <C-w><Left>
noremap <Leader>j <C-w><Down>
noremap <Leader>k <C-w><Up>
noremap <Leader>l <C-w><Right>
" }}}

" Quick open .vimrc file and reload it after saving {{{
nnoremap <Leader>ev :split $MYVIMRC<Enter>
nnoremap <Leader>sv :source $MYVIMRC<Enter>
" }}}

" Setup folding for vimscript files {{{
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}
" }}}

" ===== Advent ===== {{{

" ==Day 1 {{{
:function GetDayOneData()
"  window scoped variables
:  let w:group_one = []
:  let w:group_two = []

"  put a blank line at the end of file to stop loop and grab first line
:  execute "normal! Go\<esc>gg0y$"

"  while the line is not empty, loop
:  while @" != ""
:    let l:split_line = split(@", "   ")
"    coerce the strings to numbers
:    let w:group_one += [0 + l:split_line[0]]
:    let w:group_two += [0 + l:split_line[1]]
"    grab the next line
:    execute "normal! j0y$"
:  endwhile

"  might as well sort em right now
:  let w:group_one = sort(w:group_one, 'n')
:  let w:group_two = sort(w:group_two, 'n')
:  echom w:group_one
:  echom w:group_two

"  cleanup that blank line
:  execute "normal! Gddgg"
:endfunction

:function FindDifferences()
"  running total
:  let w:total_diff = 0
:  let l:index = 0
:  while index < len(w:group_one)

"    get from sorted data
:    let l:one = w:group_one[index]
:    let l:two = w:group_two[index]

"    calculate diff
:    if l:two > l:one
:      let w:total_diff += l:two - l:one
:    else
:      let w:total_diff += l:one - l:two
:    endif

"    loop increment
:    let l:index += 1
:  endwhile

"  result
:  echom w:total_diff
:endfunction

:function FindSimilarities()
"  running total, and a dict so I don't have to repeat myself
:  let w:total_sim = 0
:  let w:sim_dict = {}

"  loop over first list, find similarity in second list
:  for l:one in w:group_one

"    need to determine similarity if we don't have it yet
:    if !has_key(w:sim_dict, l:one)

"      loop over second list, find similarity with first item
:      let l:sim_count = 0
:      for l:two in w:group_two
:        if l:one == l:two
:          let l:sim_count += 1
:        endif
:      endfor
:      let w:sim_dict[l:one] = l:one * l:sim_count
:    endif

"    now we have the similarity, add it to our total
:    let w:total_sim += w:sim_dict[l:one]
:  endfor

"  result
:  echom w:total_sim
:endfunction
" }}}

" ==Day 2 {{{
:function HowManyReportsAreSafe()
"  init total
:  let w:total_safe = 0

"  put a blank line at the end of file to stop loop
:  execute "normal! Go\<esc>gg"

"  yank the first line
:  execute "normal! 0y$"

"  while the line is not empty, loop
:  while @" != ""
:    let w:total_safe += IsReportSafe(@")
:    execute "normal! j0y$"
:  endwhile

"  cleanup that blank line, show result
:  echom w:total_safe
:  execute "normal! Gddgg"
:endfunction

:function IsReportSafe(report)
:  let l:report = split(a:report, " ")
:  let l:last_level = 0
:  let l:last_diff = 0

:  for l:level in l:report
"    only need to compare if I have two adjacent
:    if l:last_level > 0
"      compare this level to the last
:      let l:diff = l:level - l:last_level

"      if the diff is 0 or too big, die
:      if l:diff == 0 || l:diff < -3 || l:diff > 3
:        return 0
:      endif

"      if the diff is a different direction than the last, die
:      if l:last_diff * l:diff < 0
:        return 0
:      endif

"      remember last diff
:      let l:last_diff = l:diff
:    endif

"    remember last level
:    let l:last_level = l:level
:  endfor

"  if we survive that loop, report is safe
:  return 1
:endfunction
" }}}

" }}}


" Memorable quotes
"
" Chapter 21 Exercises: Drink a beer to console yourself about Vim's coercion of strings to integers.
"
" A quote from a different vim book:
" In the hands of a master, vim can shred text at the speed of thought.
