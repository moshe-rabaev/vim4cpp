" Entry point for the plugin

function! FileNotEmpty(name)
    echom a:name
	if(!filereadable(a:name))
		return 0
	endif

	let l:data = readfile(a:name) 
	for d in data
		if(d == '')
			continue
		endif
		return 1
	endfor

	return 0
endfunction

function! TryHeaderInsertion(file_path, file_name) 
	if(FileNotEmpty(a:file_path))
		return 
	endif

	let l:file_parts = split(a:file_name, "[.]")
	if(len(l:file_parts) > 1 && file_parts[len(l:file_parts)-1][0] == 'h')
		call append(0,"#ifndef " . toupper(l:file_parts[0]) . "_H_DEFINE")
		call append(1,"#define " . toupper(l:file_parts[0]) . "_H_DEFINE")
		call append(3,"#endif")
	endif
endfunction

function! MakeMain()
    execute "normal! G"
	call setline('.', ["#include <iostream>", "","using namespace std;","","int main(int argc, char** argv) {", "", "\treturn 0;", "", "}"])
endfunction
	
function TryMainInsertion(file_path, file_name)
	if(FileNotEmpty(a:file_path))
		return
	endif
	if(tolower(a:file_name) == "main.cpp") 
		call MakeMain()
	endif
endfunction

function! CheckForNewBuffer() 
    augroup MyGroup
        autocmd!
        autocmd BufRead,BufNewFile main.cpp call TryMainInsertion(expand("%:p"), expand("%:t"))
        autocmd BufRead,BufNewFile *.h* call TryHeaderInsertion(expand("%:p"), expand("%:t"))
    augroup END
endfunction

command! Main : if confirm("Are you sure you want a main function?") | call MakeMain() | endif

call CheckForNewBuffer()
