extern LoadIconA:proc
extern LoadCursorA:proc
extern GetStockObject:proc
extern RegisterClassA:proc
extern MessageBoxA:proc
extern CreateWindowExA:proc
extern ShowWindow:proc
extern UpdateWindow:proc
extern DefWindowProcA:proc
extern PostQuitMessage:proc
extern GetMessageA:proc
extern TranslateMessage:proc
extern DispatchMessageA:proc
extern BeginPaint:proc
extern EndPaint:proc
extern MoveToEx:proc
extern LineTo:proc
.data
    className db 'Application',0
    windowName db 'Application',0
    registerClassErrMsg db 'Failed While registering class!',0
.code
WndProc proc
mov [rsp+8],rcx ;hwnd
mov [rsp+010h],rdx  ;uMsg
mov [rsp+018h],r8   ;wParam
mov [rsp+020h],r9   ;lParam
sub rsp,078h
cmp qword ptr[rsp+088h],2 ;WM_DESTROY
je wm_destroy
cmp qword ptr[rsp+088h],0fh
je wm_paint
mov rcx,[rsp+080h]
mov rdx,[rsp+088h]
mov r8,[rsp+090h]
mov r9,[rsp+098h]
call DefWindowProcA
jmp recoveryStack
wm_destroy:
    xor rcx,rcx
    call PostQuitMessage
    jmp recoveryStack
wm_paint:
    mov rcx,[rsp+080h]
    lea rdx,[rsp+028h]
    call BeginPaint
    mov [rsp+020h],rax  ;hdc
    ;---------------------画线
    mov rcx,[rsp+020h]  ;hdc
    mov rdx,10      ;x
    mov r8,10       ;y
    mov r9,0        ;lppt
    call MoveToEx
    mov rcx,[rsp+020h]  ;hdc
    mov rdx,100     ;x
    mov r8,10       ;y
    call LineTo
    mov rcx,[rsp+080h]
    lea rdx,[rsp+028h]
    call EndPaint
    jmp recoveryStack
recoveryStack:
    add rsp,078h
    ret
WndProc endp
WinMain proc
mov [rsp+8],rcx ;hInstance
mov [rsp+010h],rdx  ;hPrevInstance
mov [rsp+018h],r8   ;lpCmdLine
mov [rsp+020h],r9   ;nCmdShoA
push rdi
sub rsp,0e0h
;---------------------------------------------WNDCLASS结构体-------------------------------------------------------------------------
mov qword ptr[rsp+060h],3  ;CS_VREDRAA|CS_HREDRAW
lea rdi,WndProc
mov qword ptr[rsp+068h],rdi ;lpfnWndProc
mov qword ptr[rsp+070h],0   ;cbClsExtra
mov qword ptr[rsp+074h],0   ;cbAndExtra
mov rdi,[rsp+0e8h]             ;hInstance
mov qword ptr[rsp+078h],rdi
xor rcx,rcx                  ;hIcon
mov rdx,32512
call LoadIconA
mov qword ptr[rsp+080h],rax
xor rcx,rcx                  ;hCursor
mov rdx,32512
call LoadCursorA
mov qword ptr[rsp+088h],rax
xor rcx,rcx              ;hbrBackground
call GetStockObject
mov qword ptr[rsp+090h],rax 
mov qword ptr[rsp+098h],0   ;lpszMenuName
lea rdi,className     ;lpszClassName
mov qword ptr[rsp+0A0h],rdi

lea rcx,[rsp+060h]
call RegisterClassA
cmp rax,0
jz registerClassError
;----------------------------------------创建窗体
mov rcx,0
lea rdx,className
lea r8,windowName
mov r9d,0cf0000h ;style
mov dword ptr[rsp+020h],080000000h ;x 
mov dword ptr[rsp+028h],080000000h ;y
mov dword ptr[rsp+030h],500 ;width
mov dword ptr[rsp+038h],400 ;height
mov qword ptr[rsp+040h],0   ;hParent
mov qword ptr[rsp+048h],0   ;hMenu
mov rdi,[rsp+0e8h]          ;hInstance
mov qword ptr[rsp+050h],rdi
mov qword ptr[rsp+058h],0   ;lParam
call CreateWindowExA
mov rcx,rax
push rcx
mov rdx,5
call ShowWindow
pop rcx
call UpdateWindow
;-------------------------------------------消息循环
msgLoop:
    lea rcx,[rsp+0a8h]
    xor rdx,rdx
    xor r8,r8
    xor r9,r9
    call GetMessageA
    cmp rax,0
    jnz msgHandler
    jmp recoveryStack
msgHandler:
    lea rcx,[rsp+0a8h]
    call TranslateMessage
    lea rcx,[rsp+0a8h]
    call DispatchMessageA
    jmp msgLoop
registerClassError:
    xor rcx,rcx
    lea rdx,registerClassErrMsg
    xor r8,r8
    xor r9,r9
    call MessageBoxA
recoveryStack:
    add rsp,0e0h
    pop rdi
WinMain endp                                                     
end