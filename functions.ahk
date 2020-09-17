#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Screen
#include config.ahk
get_title(plat)
{
    return % plat.title " ahk_exe " + plat.exePath
}
login(plat)
{
    WinActivate, % "ahk_exe " + plat.exePath
    if (plat.user_login)
    {
         ControlFocus, TEdit1
        send, % plat.user
        send, {Return}    
        sleep, 300

    }
       
    ControlFocus, THsEdit1
    send, % plat.passwd
    send, {Return}
    sleep, 200
    WinWait, % get_title(plat)
    sleep 10000
}

activeTrade(plat)
{
    exe =  % "ahk_exe " + plat.exePath
    IfWinNotExist, %exe%
    {
        ToolTip, 正在打开客户端
        run, % plat.exePath
        WinWait,  %exe%
        ToolTip
        login(plat)
    } 
    Else
    {
        IfWinExist, 系统已锁定  %exe%
        login(plat)
    }

}

algor_trade(plat, tp) 
{
   
    ControlClick, 算法
    warning_confirm()
    WinWaitActive, 算法交易委托
    if (tp = "limit")
    { tm := 325 
    }
    if (tp = "sell")
    { tm := 5
    }
    if (tp = "buy")
    { tm := 5
    }
    ControlSetText ,THsEdit3 , %tm%, 算法交易委托
	sleep, 500
	if (tp != "limit")
    { 
	;ControlClick , TCheckBox1, 算法交易委托
	   obj_click(plat.trade.checkbox)
       sleep, 500
	}
    ControlClick , THsButton1, 算法交易委托
    warning_confirm()
	sleep, 500
    warning_confirm()
    obj_click(plat.remove_menu)
    sleep, 500
}

common_trade(plat, tp) 
{
    if (tp = "limit") {
        obj_click(plat.set_price)
       ; ControlFocus THsComboBox5
        obj_click(plat.trade.limit)
        Loop, 3000 { 
           send 1
           sleep 200
           ControlGetText,txt , THsComboBox5
           
           n := InStr(txt, "涨停价")           
                if (n > 0)
                {
                    break
                }
            }
            
            
        }
    else
    {
     obj_click(plat.auto_trade)
    }

 ControlClick, 下单
 sleep, 500
 
 warning_confirm()
 warning_confirm()
 ;WinWaitActive, 确认信息
 ;ControlClick , THsButton2, 确认信息
 warning_confirm()
 sleep, 1000    
 obj_click(plat.remove_menu)
 sleep, 500

}


open_menu(plat, pos_)
{
    WinActivate, % get_title(plat)
    WinWaitActive, % get_title(plat)
    sleep, 500
    obj_click(plat.trade_manage) ;交易管理
    obj_click(pos_) ;组合交易
    obj_click(plat.remove_menu) ;让菜单消失    

}

subscribe(plat)
{
    open_menu(plat, plat.subscribe)
    if (plat.account)
    {
        obj_click(plat.account.subscribe)
    }
    ControlClick , 申购
    sleep, 500
     IfWinExist 确认信息
{
    ControlClick ,确定  
} 
   warning_confirm()
}

obj_click(pos_)
{
    x := pos_.x
    y := pos_.y
    click, %x% , %y%
    sleep, 500
}
warning_confirm()
{
    sleep 500
    IfWinExist 提示信息
    {        
        WinWaitActive, 提示信息
        ControlClick , 确定
        sleep 500
    }
    IfWinExist 确认信息
    {        
        WinWaitActive, 确认信息
        ControlClick , 确定
        sleep 500
    }
}
retreat(plat)
{
     open_menu(plat, plat.trade)
     obj_click(plat.trade_monitor)
     if (plat.retreat.rtt_pos)
    {
        obj_click(plat.retreat.rtt_pos)
    }
     obj_click(plat.retreat)
     warning_confirm()
     warning_confirm()
     sleep 2000
 }


trade(plat, tp)
{
    open_menu(plat, plat.trade)
    obj_click(plat.trade_panel) ;组合下单
    if (plat.account)
    {
        
        obj_click(plat.account.pos1)
        obj_click(plat.account.pos2)
        warning_confirm()
        sleep 2000
    }
    ControlFocus ,文件导入
    sleep, 1000
    obj_click(plat.file_button)  ;文件选择按钮
    WinWaitActive,打开
    actid =  plat.account_id
    ControlSetText, Edit1, %tp%_%actid%.csv
    ControlFocus ,Button2
    Send {Enter}
    sleep 3000
    warning_confirm()
    WinActivate, % "ahk_exe " + plat.exePath
    WinWaitActive, % "ahk_exe " + plat.exePath
    sleep, 500
    obj_click(plat.remove_menu) ;让菜单消失
    if (plat.trade_type = "algor")
    {
        algor_trade(plat, tp) 
    }
    Else
    {   
        common_trade(plat, tp) 

    }
    
    
}


main(plat, retreat_flag:=true)
{ 
    activeTrade(plat)
    sleep 1000
    if (retreat_flag)
    {
        retreat(plat)  
    }
    trade(plat, "sell")
    sleep 60000
    trade(plat, "buy")
    sleep 1000
    subscribe(plat)
}


