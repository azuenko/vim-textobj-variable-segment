function! s:select(object_type, right_boundary)
    let left_boundaries = ['_\+\k', '-\+\k', '\<', '\l\u', '\u\u\ze\l', '\a\d', '\d\a']
    call search(join(left_boundaries, '\|'), 'bce')
    let start_position = getpos('.')

    call search('\>', 'c')
    let word_end = getpos('.')
    call setpos('.', start_position)

    call search(a:right_boundary, 'c')
    for _ in range(v:count1 - 1)
        if getpos('.') != word_end
            call search(a:right_boundary)
        endif
    endfor
    let end_position = getpos('.')

    return ['v', start_position, end_position]
endfunction

function! s:select_a()
    let right_boundaries = ['_', '-', '\l\u', '\u\u\l', '\a\d', '\d\a', '\k\>']
    let right_boundary = join(right_boundaries, '\|')
    let [type, start_position, end_position] = s:select('a', right_boundary)
    let [_, start_line, start_column, _] = start_position

    call search('\k\>', 'c')
    if end_position == getpos('.') &&
     \ getline(start_line)[start_column - 2] =~# '_'
        let start_position[2] -= 1
    endif

    let was_small_camel = match(expand('<cword>'), '^_*\l.*\u') != -1
    if was_small_camel
        call search('\<', 'bc')
        let [_, _, word_start, _] = getpos('.')

        if start_column - 2 <= word_start ||
         \ getline(start_line)[:start_column - 2] =~# '^_*$'
            call setpos('.', end_position)
            let l:tildeop = &tildeop
            set notildeop
            normal! l~
            let &tildeop = l:tildeop
        endif
    endif

    return [type, start_position, end_position]
endfunction

function! s:select_i()
    let right_boundaries = ['\k_', '\k-', '\l\u', '\u\u\l', '\a\d', '\d\a', '\k\>']
    return s:select('i', join(right_boundaries, '\|'))
endfunction

function! textobj#variable_segment#select_i() abort
  return s:select_i()
endfunction

function! textobj#variable_segment#select_a() abort
  return s:select_a()
endfunction
