set termguicolors
let s:width=nvim_get_option("columns")
let s:height=nvim_get_option("lines")
let s:staging=[]
let s:files=[]
let s:path="./"
let s:wins=[]
let s:wins_number=0

function s:config(x,y,width,height,focusable=v:false)
  return {"style":"minimal","relative":"editor","width":a:width,"height":a:height,"row":a:y,"col":a:x,"focusable":a:focusable}
endfunction

function s:create(x,y,width,height)
  let id=nvim_open_win(nvim_create_buf(v:false,v:true),v:true,s:config(a:x,a:y,a:width,a:height))
  call nvim_win_set_option(id,"winhighlight","Normal:WindowColor")
  return id
endfunction

function git#get_mode()
  let mode=mode()
  if mode=="i"
    return "Insert"
  elseif mode=="v"
    return "Visual"
  elseif mode=="V"
    return "Visual Line"
  elseif mode=="\x16"
    return "Visual Block"
  elseif mode=="t"
    return "Terminal"
  elseif mode=="n"
    return "Normal"
  elseif mode=="c"
    return "Command"
  endif
endfunction

function git#get_branch()
  let log=system('git branch --contains')[2:-2]
  if v:shell_error
    return ""
  else
    return "(".log.")"
  endif
endfunction

function git#init()
  set statusline=%#WarningMsg#%{git#get_mode()}\ \%#Normal#%f%m%{git#get_branch()}%=%p%%\ \%y
endfunction

function git#add(file="")
  if a:file==""
    call system("git add ".expand("%f"))
  else
    call system("git add ".a:file)
  endif
endfunction

function git#commit(msg)
  call system('git commit -m "'.a:msg.'"')
endfunction

function git#push(branch="main")
  let remote=split(system("git remote -v"),"\t")[0]
  call system('git push '.remote.' '.a:branch)
  echo "To ".system("git remote get-url ".remote)
  call git#upotsu()
endfunction

function git#upotsu()
  let s:current_win=win_getid()
  let s:wins=[]
  let y=rand()%(s:height-3)+1
  let win=s:create(s:width-7,y,6,1)
  call setline(1,"うぽつ")
  let s:wins=s:wins+[[win,s:width-7,y]]
  let s:wins_number=0
  call win_gotoid(s:current_win)
  call timer_start(100,function("git#loop"))
endfunction

function git#loop(timer) abort
  let s:wins_number+=1
  for i in range(len(s:wins))
    let win=s:wins[i][0]
    let x=s:wins[i][1]
    let y=s:wins[i][2]
    if x > 0
      call nvim_win_set_config(win,s:config(x-1,y,6,1))
      let s:wins[i]=[win,x-1,y]
    endif
    if x==0
      call win_execute(win,"q")
      let s:wins[i]=[win,-1,y]
    endif
  endfor
  if s:wins_number < 500 && s:wins_number%10==0
    let y=rand()%(s:height-3)+1
    let win=s:create(s:width-7,y,6,1)
    call setline(1,"うぽつ")
    let s:wins=s:wins+[[win,s:width-7,y]]
    call win_gotoid(s:current_win)
  endif
  if len(s:wins) > 0
    call timer_start(50,function("git#loop"))
  endif
endfunction
