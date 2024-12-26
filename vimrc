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

:function CollectRulesAndFixBadPrints()
:  let l:total = 0

"  yank the first line, then loop as long as delete register is not empty
:  execute "normal! \"dyy"
:  while 0 + @d
"    analyze these pages over in the rule file
:    let l:pages = split(@d, ",")
:    let l:midindex = len(l:pages) / 2
:    let l:rules = []
:    execute "normal ,h"

"    double loop over pages to find applicable rules
:    for l:p1 in l:pages
:      for l:p2 in l:pages
"        only loop over each pair once
:        if l:p1 == l:p2
:          break
:        endif

"        search for rules with p1 and p2 in them
:        let l:pattern = l:p1 . "|" . l:p2
:        let l:found_rule = search(l:pattern)
:        if l:found_rule
:          execute "normal! y$"
:          call add(l:rules, @")
:        endif
"        don't forget the reverse rule
:        let l:pattern = l:p2 . "|" . l:p1
:        let l:found_rule = search(l:pattern)
:        if l:found_rule
:          execute "normal! y$"
:          call add(l:rules, @")
:        endif
:      endfor
:    endfor

"    TODO: Yeargh, something about my algorithm is wrong
"    loop over rules, find pages which are only on the left
"    we only need to do this until we get to the mid index, then we win
:    let l:index = 0
:    let l:left_page = ""
:    while l:index < l:midindex - 1
"      for any rule, remove pages on the right
:      for l:rule in l:rules
:        call filter(l:pages, {idx, val -> 0 + val != 0 + l:rule[3:]})
:      endfor

"      take one of the surviving left-only pages, and remove any rule with it
:      call filter(l:rules, {idx, val -> val !~ l:pages[0]})
:      if len(l:pages) > 0
:        let l:left_page = remove(l:pages, 0)
:      let l:index += 1
:    endwhile

"    should have one surviving left-only page
:    let l:total += l:left_page

"    next line
:    execute "normal ,lj\"dyy"
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

" ==Day 6 {{{
" I get to use a pretty vimmy solution for the first part of this day
" For Part two, I need to track the blocks to see which direction they're hit
:function StrToHexnum(char)
:  let l:hexstr = "0x" . a:char
:  return 0 + l:hexstr
:endfunction

:function NumToHexstr(num)
:  if a:num < 10
:    return "" . a:num
:  endif
"  65 is A
:  return nr2char(65 + a:num - 10)
:endfunction

:function SetBlocker()
"  Search for any step along the guard's original path
:  let w:step_found = search("X")

"  Save the position
:  if w:step_found
:    let [junk, w:block_y, w:block_x, junk] = getpos(".")
:  else
:    let w:block_x = 0
:    let w:block_y = 0
:  endif

"  Put a block in
:  execute "normal! r#"
:  return w:step_found
:endfunction

:function RemoveBlocker(loop)
"  Go back to the blocker position, and replace with Y for a loop block or N
:  call setpos(".", [0, w:block_y, w:block_x, 0])
:  if a:loop
:    execute "normal! rY"
:  else
:    execute "normal! rN"
:  endif
:endfunction

:function DetectBlockBump(direction, step)
"  Detect bumping this block
:  let l:block_label = NumToHexstr(or(StrToHexnum(a:step), a:direction))
"  If we bumped it from this dir before, it's a loop!
:  if a:step == l:block_label
:    let l:looping = 1
:  else
:    let l:looping = 0
:  endif
:  execute "normal! r" . l:block_label
:  return l:looping
:endfunction

:function FindGuard()
"  Find the original guard position
:  let l:guard_pattern = "[v<>^]"
:  let l:guard_found = search(l:guard_pattern)
:  let [junk, w:guard_y, w:guard_x, junk] = getpos(".")
:endfunction

:function ReplaceGuard()
"  Go back to the original guard position, and put him back
:  call setpos(".", [0, w:guard_y, w:guard_x, 0])
:  execute "normal! r^"
:endfunction

:function ResetBlocks()
"  After we test for looping, reset all the blocks back to no bumps
:  let l:mark_found = search("[0-9A-F]")
:  while l:mark_found
:    execute "normal r#"
:    let l:mark_found = search("[0-9A-F]")
:  endwhile
:endfunction

:function WalkGuard()
"  This will be fun with vim
"  First find map extrema
:  execute "normal! G$"
:  let [junk, maxy, maxx, junk2] = getpos(".")

"  Tracking when blocks are hit by the guard from different sides
:  let l:n_bump = 1
:  let l:w_bump = 2
:  let l:s_bump = 4
:  let l:e_bump = 8

"  Find the guard store the original position of the guard
:  let l:guard_pattern = "[v<>^]"
:  let l:guard_found = search(l:guard_pattern)
:  let l:last_step = "."  "very first step can be dot, can't put a block there

"  Loop while guard is on screen or not stuck in a loop
:  let l:looping = 0
:  while l:guard_found && !l:looping
:    let [junk, y, x, junk2] = getpos(".")
:    execute "normal! yl"
:    let dir = @"

"    Simulation time
"
"    North
:    if dir == "^"
:      if y > 1
"        Not at the top, move up
:        execute "normal! kyl"

"        See what is there to step or turn
:        let step = @"
:        if step =~ "[0-9A-F#]"
"          Detect bumping this block
:          let l:looping = DetectBlockBump(l:n_bump, step)
:          if l:looping
"            Stop stepping
:            execute "normal! jr" . l:last_step
:            break
:          endif
"          Also, still turn
:          execute "normal! jr>"
:        else
"          Not a block, step
:          execute "normal! r^jr" . l:last_step
:          let l:last_step = step
:        endif
:      else
"        Step off the map
:        execute "normal! r" . l:last_step
:      endif
:    endif

"    West
:    if dir == "<"
:      if x > 1
"        Not at the left, move left
:        execute "normal! hyl"

"        See what is there to step or turn
:        let step = @"
:        if step =~ "[0-9A-F#]"
"          Detect bumping this block
:          let l:looping = DetectBlockBump(l:w_bump, step)
:          if l:looping
"            Stop stepping
:            execute "normal! lr" . l:last_step
:            break
:          endif
"          Also, still turn
:          execute "normal! lr^"
:        else
"          Not a block, step
:          execute "normal! r<lr" . l:last_step
:          let l:last_step = step
:        endif
:      else
"        Step off the map
:        execute "normal! r" . l:last_step
:      endif
:    endif

"    South
:    if dir == "v"
:      if y < maxy
"        Not at the bottom, move down
:        execute "normal! jyl"

"        See what is there to step or turn
:        let step = @"
:        if step =~ "[0-9A-F#]"
"          Detect bumping this block
:          let l:looping = DetectBlockBump(l:s_bump, step)
:          if l:looping
"            Stop stepping
:            execute "normal! kr" . l:last_step
:            break
:          endif
"          Also, still turn
:          execute "normal! kr<"
:        else
"          Not a block, step
:          execute "normal! rvkr" . l:last_step
:          let l:last_step = step
:        endif
:      else
"        Step off the map
:        execute "normal! r" . l:last_step
:      endif
:    endif

"    East
:    if dir == ">"
:      if x < maxx
"        Not at the right, move right
:        execute "normal! lyl"

"        See what is there to step or turn
:        let step = @"
:        if step =~ "[0-9A-F#]"
"          Detect bumping this block
:          let l:looping = DetectBlockBump(l:n_bump, step)
:          if l:looping
"            Stop stepping
:            execute "normal! hr" . l:last_step
:            break
:          endif
"          Also, still turn
:          execute "normal! hrv"
:        else
"          Not a block, step
:          execute "normal! r>hr" . l:last_step
:          let l:last_step = step
:        endif
:      else
"        Step off the map
:        execute "normal! r" . l:last_step
:      endif
:    endif

"    Find the guard again
:    redraw   " << Gamechanger!! :D
:    let l:guard_found = search(l:guard_pattern)
:  endwhile

"  At the end, report if the guard was looping
:  return l:looping
:endfunction

:function FindAllGuardLoops()
"  Let's tie these all together, start with part 1 solution with guard in place
"  Find each step the guard made before, try putting a new block there
:  while SetBlocker()
"    Walk the guard, see if he gets caught in a loop
:    let l:loop = WalkGuard()
"    Remove that blocker, but label it Y or N depending on loop
:    call RemoveBlocker(l:loop)
"    Reset everything for the next trial block
:    call ResetBlocks()
:    call ReplaceGuard()
:  endwhile
:endfunction
" }}}

" ==Day 7 {{{
:function PrepOperators(n)
"  For n = 1 just make a list of lists of each operator
:  if a:n == 1
:    return [["+"], ["*"]]
:  endif

"  Otherwise, duplicate each list and add each operator
:  let l:result = []
:  for l:op_list in PrepOperators(a:n - 1)
:    let l:result = add(l:result, l:op_list + ["+"])
:    let l:result = add(l:result, l:op_list + ["*"])
:  endfor
:  return l:result
:endfunction

:function TestOperatorLine()
"  Get the line, split into parts
:  let l:line = split(getline("."))
:  if !len(l:line)
:    return 0
:  endif

"  Very first number is the answer, slice off the :
:  let l:answer = 0 + remove(l:line, 0)[:-2]  " -2 that's a bit different than python...

"  Make another list of operators
:  let l:ops_list = PrepOperators(len(l:line) - 1)

"  Try each list of operators, compare them to the answer
:  for l:ops in l:ops_list
:    let l:trial = 0 + l:line[0]
:    let l:index = 1
:    for l:op in l:ops
:      if l:op == "*"
:        let l:trial = l:trial * l:line[l:index]
:      elseif l:op == "+"
:        let l:trial = l:trial + l:line[l:index]
:      endif
:      let l:index += 1
:    endfor

"    See if we got the answer
:    if l:trial == l:answer
:      let w:day_seven += l:answer
:      break
:    endif
:  endfor

"  Return true to say we got a line of data
:  return 1
:endfunction

:function TestOperatorLines()
:  let w:day_seven = 0
:  while TestOperatorLine()
"    Just move down, the other function does all the work
:    execute "normal! j"
:    redraw
:  endwhile
:  echom w:day_seven
:endfunction
" }}}

" }}}


" Memorable quotes
"
" Chapter 21 Exercises: Drink a beer to console yourself about Vim's coercion of strings to integers.
"
" A quote from a different vim book:
" In the hands of a master, vim can shred text at the speed of thought.
