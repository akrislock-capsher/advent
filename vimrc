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
" These four lines set a block cursor in normal, visual modes
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"
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
" lemme try some simpler functions for any kind of movements...
:function PrepToReadLevels()
"  Add several blanks to the end of this line to assist movement
:  execute "normal! A   \<esc>0"
:endfunction

:function TakeLineSnapshot()
"  NOTE: Need to be super careful with any movements
"  ..... Take more control by recording the current position and current line
"  ..1.. Yank from where we are to the end of the line in register o
:  execute "normal! \"oy$"
"  ..2.. Yank the entire line in register a
:  execute "normal! 0\"ayy"
"  ..3.. Search to get back to "o"riginal position
:  execute "normal! 0/\<C-r>o\<cr>"
:endfunction

:function RestoreLineSnapshot()
"  Restore our snapshot of the current line
"  ..1.. Delete the whole line
:  execute "normal! dd"
"  ..2.. Paste our entire line from register a
:  execute "normal! \"aP"
"  ..3.. Use find to get back to "o"riginal position
:  execute "normal! 0/\<C-r>o\<cr>"
:endfunction

:function DeleteThisNumber()
"  Remove the number starting at the cursor position
:  execute "normal! df "
:endfunction

:function DeletePrevPrevNumber()
"  Remove the previous number starting at the cursor position
:  execute "normal! bbdf "
:endfunction

:function DeletePrevNumber()
"  Remove the previous number starting at the cursor position
:  execute "normal! bdf "
:endfunction

:function GetThisNumber()
"  Find the number starting at the cursor position
"  NOTE: The cursor will go back to where it was after the yank
:  execute "normal! yf "
"  Coerce what's in the yank register into a number
:  return 0 + @"
:endfunction

:function NextLine()
"  Just delete the current line
:  execute "normal! dd"
:endfunction

:function HowManyReportsAreSafe()
"  init totals
:  let w:total_safe = 0

"  try getting a number
:  call PrepToReadLevels()
:  let l:num = GetThisNumber()

"  while we have a number at the start of a line, loop
:  while l:num != 0
"    see if our report line is Safe, pass in first num for efficiency
:    let w:total_safe += IsReportSafe(l:num)
:    call NextLine()
:    call PrepToReadLevels()
:    let l:num = GetThisNumber()
:  endwhile

"  show result
:  let @t = w:total_safe
:  execute "normal ,lGo\<esc>\"tp,h"
:endfunction

:function IsReportSafe(num, ...)
:  let l:last_level = 0
:  let l:last_diff = 0
:  let l:level = a:num
:  let l:use_dampener = a:0 ? a:1 : 0
:  let l:found_problem = 0

:  while l:level != 0
"    only need to compare if I have two adjacent levels
:    if l:last_level > 0
"      compare this level to the last
:      let l:diff = l:level - l:last_level

"      if the diff is 0 or too big, we found a problem
:      if l:diff == 0 || l:diff < -3 || l:diff > 3
:        let l:found_problem = 1
:      endif

"      if the diff is a different direction than the last, we found a problem
:      if l:last_diff * l:diff < 0
:        let l:found_problem = 1
:      endif

"      if we found a problem, die if we already used the dampener
:      if l:found_problem && l:use_dampener > 0
:        return 0
:      endif

"      if we found a problem, try using the dampener
:      if l:found_problem
:        let l:use_dampener = 1

"        If we have a last diff, we have at least three numbers
:        if l:last_diff != 0
"          First try removing the 2nd previous level and recheck the whole report
:          call TakeLineSnapshot()
:          call DeletePrevPrevNumber()
:          execute "normal! 0"
:          let l:num = GetThisNumber()
:          if IsReportSafe(l:num, l:use_dampener)
:            return 1
:          endif
:        call RestoreLineSnapshot()
:        endif

"        Next try removing the previous level and recheck the whole report
:        call TakeLineSnapshot()
:        call DeletePrevNumber()
:        execute "normal! 0"
:        let l:num = GetThisNumber()
:        if IsReportSafe(l:num, l:use_dampener)
:          return 1
:        endif
:        call RestoreLineSnapshot()

"        If that didn't work, undo then remove this level
:        call TakeLineSnapshot()
:        call DeleteThisNumber()
:        execute "normal! 0"
:        let l:num = GetThisNumber()
:        if IsReportSafe(l:num, l:use_dampener)
:          return 1
:        endif

"        We cannot dampen this problem, die
:        return 0
:      endif

"      remember last diff
:      let l:last_diff = l:diff
:    endif

"    remember last level
:    let l:last_level = l:level

"    move to and get next level
:    execute "normal! f l"
:    let l:level = GetThisNumber()
:  endwhile

"  if we survive that loop, report is safe
:  return 1
:endfunction

" }}}

" ==Day 3 {{{
" Ummm... I might be able to do this one with some pretty easy macros
" Part 1 regex and macros:
"  Finder Regex = /mul([0-9]\+,[0-9]\+)\<cr>
"  Recursive Macro built in pieces
"  @z = f(l"adt,l"bdt)
"  @y = ,lyypf=i+\<esc>f0x"apA * "bpk0
"  @x = ,hn
"  @m = @z@y@x@m
" Part 2 adjustment, just nuke everything between don't() and do()
"  Finder for do(n't) functions = /don\?'\?t\?()
"  Recursive Macro to add newlines
"  @w = s\<cr>D\<esc>n@w
" Be a bit careful to make sure every line but the first starts with Do
"  Finder for Don't functions = /Don't()
"  Recursive Macro to delete those lines
"  @v = s\<cr>D\<esc>n@w
" Then we can just use the Part 1 method again

:function SumMultiply()
"  After using the macros to copy data over, this will just calc it
"  Final value will be in register t
:  let l:total = 0
"... Lines populated by those macros
:  let @t = l:total
:endfunction
" }}}

" ==Day 4 {{{
" Slicing lists is pretty excellent in vimscript, maybe better than python.
" Hopefully I will try it soon.
:function GetDayFourData()
:  let w:xmasData = []

"  put a blank line at the end of file to stop loop and grab first line
:  execute "normal! Go\<esc>gg0y$"

"  while the line is not empty, loop to save and get the next line
:  while @" != ""
:    call add(w:xmasData, @")
:    execute "normal! j0y$"
:  endwhile
:endfunction

:function SearchForXMASPartOne()
:  let l:numXmas = 0

:  let r = 0
:  while r < len(w:xmasData)
:    let c = 0
:    while c < len(w:xmasData[r])
:      if w:xmasData[r][c] == "X"
"        check for nw search
:        if r >= 3 && c >= 3
:          let l:numXmas += w:xmasData[r-1][c-1] == "M" && w:xmasData[r-2][c-2] == "A" && w:xmasData[r-3][c-3] == "S"
:        endif

"        check for n search
:        if r >= 3
:          let l:numXmas += w:xmasData[r-1][c] == "M" && w:xmasData[r-2][c] == "A" && w:xmasData[r-3][c] == "S"
:        endif

"        check for ne search
:        if r >= 3 && c < len(w:xmasData[r]) - 3
:          let l:numXmas += w:xmasData[r-1][c+1] == "M" && w:xmasData[r-2][c+2] == "A" && w:xmasData[r-3][c+3] == "S"
:        endif

"        check for e search
:        if c < len(w:xmasData[r]) - 3
:          let l:numXmas += w:xmasData[r][c+1] == "M" && w:xmasData[r][c+2] == "A" && w:xmasData[r][c+3] == "S"
:        endif

"        check for se search
:        if r < len(w:xmasData) - 3 && c < len(w:xmasData[r]) - 3
:          let l:numXmas += w:xmasData[r+1][c+1] == "M" && w:xmasData[r+2][c+2] == "A" && w:xmasData[r+3][c+3] == "S"
:        endif

"        check for s search
:        if r < len(w:xmasData) - 3
:          let l:numXmas += w:xmasData[r+1][c] == "M" && w:xmasData[r+2][c] == "A" && w:xmasData[r+3][c] == "S"
:        endif

"        check for sw search
:        if r < len(w:xmasData) - 3 && c >= 3
:          let l:numXmas += w:xmasData[r+1][c-1] == "M" && w:xmasData[r+2][c-2] == "A" && w:xmasData[r+3][c-3] == "S"
:        endif

"        check for w search
:        if c >= 3
:          let l:numXmas += w:xmasData[r][c-1] == "M" && w:xmasData[r][c-2] == "A" && w:xmasData[r][c-3] == "S"
:        endif
:      endif
:      let c += 1
:    endwhile
:    let r += 1
:  endwhile

"  put the result in a register
:  let @r = l:numXmas
:endfunction

:function SearchForXMASPartTwo()
:  let l:numXmas = 0

"  Seems almost easier... We'll start to search for A
"  We can skip the entire first row, first col, last row, and last col
:  let r = 1
:  while r < len(w:xmasData) - 1
:    let c = 1
:    while c < len(w:xmasData[r]) - 1
"      Find A
:      let l:isXmas = w:xmasData[r][c] == "A"

"      Diagonal must be MAS or SAM
:      if l:isXmas
:        let l:isXmas = w:xmasData[r-1][c-1] == "M" && w:xmasData[r+1][c+1] == "S"
:        let l:isXmas = l:isXmas || (w:xmasData[r-1][c-1] == "S" && w:xmasData[r+1][c+1] == "M")
:      endif

"      Either sides or top and bottom must be equal
:      if l:isXmas
:        let l:isXmas = w:xmasData[r-1][c-1] == w:xmasData[r-1][c+1] && w:xmasData[r+1][c-1] == w:xmasData[r+1][c+1]
:        let l:isXmas = l:isXmas || (w:xmasData[r-1][c-1] == w:xmasData[r+1][c-1] && w:xmasData[r-1][c+1] == w:xmasData[r+1][c+1])
:      endif

:      let l:numXmas += l:isXmas
:      let c += 1
:    endwhile
:    let r += 1
:  endwhile

"  put the result in a register
:  let @r = l:numXmas
:endfunction
" }}}

" ==Day 5 {{{
" I get to use a pretty vimmy solution for the first part of this day
" Macros:
"   "find rule" @p = gg/[0-9]\+|[0-9]\+\<cr>y$
"   "invert rule" @i = "ydt|l"xd$
"   "get rule" @g = "xyt|f|l"yy$

:function CleanOutBadPrints()
"  Call the macros in a loop to clean out violating lines
:  let @" = ""
:  execute "normal @p"
:  while stridx(@", "|") > -1
:    execute "normal @i"

"    Do the find and delete functionally instead of macros
:    let l:pattern = @x . ",.*" . @y
:    let l:found = search(l:pattern)
:    while l:found
"      Move the violations over into another file for part 2
:      execute "normal dd,lP,h"
:      let l:found = search(l:pattern)
:    endwhile

"    Move to next rule, sanity check that it's a rule
:    let @" = ""
:    execute "normal @p"
:  endwhile
:endfunction

" WAIT: I can be more clever! The middle number will always have 
" ..... equal number of "left" and "right" rules.
" ... On second thought, this is an assumption... Try it anyways.
:function SumMidNumbersForBadPrints()
:  let l:total = 0

"  delete the first line, then loop as long as delete register is not empty
:  execute "normal! \"ddd"
:  while 0 + @d
"    analyze these pages over in the rule file
:    let l:pages = split(@d, ",")
:    execute "normal ,h"

"    double loop over those
:    for l:p1 in l:pages
:      let l:left = 0
:      let l:right = 0
:      for l:p2 in l:pages
:        if l:p1 != l:p2

"          search for rules with p1 and p2 in them
:          let l:pattern = l:p1 . "|" . l:p2
:          let l:found_rule = search(l:pattern)
:          if l:found_rule
:            let l:left += 1
:          else
:            let l:right += 1
:          endif
:        endif
:      endfor
:
"      if this number has equal # of left and right rules, it is the middle
:      if l:left == l:right
:        let l:total += 0 + l:p1
:        break
:      endif
:    endfor

"    next line
:    execute "normal ,l"
:    execute "normal! \"ddd"
:  endwhile
:  let @a = l:total
:endfunction

:function SumMidNumbers()
"  Hopefully the remaining are correct
:  let l:total = 0

"  delete the first line, then loop as long as delete register is not empty
:  execute "normal! \"ddd"
:  while 0 + @d
"    find mid number of pages to sum
:    let l:pages = split(@d, ",")
:    let l:index = len(pages) / 2
:    let l:total += 0 + l:pages[l:index]

"    next line
:    execute "normal! \"ddd"
:  endwhile
:  let @a = l:total
:endfunction
" }}}

" }}}


" Memorable quotes
"
" Chapter 21 Exercises: Drink a beer to console yourself about Vim's coercion of strings to integers.
"
" A quote from a different vim book:
" In the hands of a master, vim can shred text at the speed of thought.
