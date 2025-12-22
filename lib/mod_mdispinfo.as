; -----------------------------------------------------------------------------
; mod_mdispinfo.as - マルチディスプレイ情報取得モジュール
; Version 1.3 [ 2025.08.08 ]
; Copyright (c) 2025 Miecat, Lala Madotuki
; -----------------------------------------------------------------------------
; 商用・非商用を問わず、自由に自作プログラムに組み込んでご使用頂けますが、
; 使用結果については無保証です。
; このプログラムは、以下のスレッドを参考に作成しました。ありがとうございます。
; https://hsp.tv/play/pforum.php?mode=pastwch&num=88050
; -----------------------------------------------------------------------------

#ifndef __MOD_MDISPINFO__
#define global __MOD_MDISPINFO__

#module mod_mdispinfo

	#uselib "user32.dll"
	#cfunc EnumDisplayMonitors "EnumDisplayMonitors" sptr,sptr,sptr,int
	#func  GetMonitorInfo "GetMonitorInfoA" sptr,sptr
	#uselib "kernel32.dll"
	#func  VirtualProtect "VirtualProtect" int,int,int,var

// マルチディスプレイ情報を取得
; -----------------------------------------------------------------------------
; GetMultiDispInfo p1
; p1: サーチする最大ディスプレイ数
; 戻り値(stat) 0: 失敗  1: 成功
; -----------------------------------------------------------------------------
#deffunc GetMultiDispInfo int _max, array _prm, array _rect, local _bin, local _p
	dim _rect,_max*4
	dim _bin,24

	_bin     = 0x83ec8b55, 0x5653d8c4, 0x145d8b57, 0x28d845c7, 0x8d000000
	_bin( 5) = 0x8b50d845, 0xff520855, 0x75c08513, 0xebc03304, 0xfc558b2e
	_bin(10) = 0x7501fa83, 0x084b8b06, 0x8b0c4b89, 0x538b0843, 0x04e0c110
	_bin(15) = 0x8b104d8b, 0x0004b9f1, 0x3c8d0000, 0x0001b802, 0xa5f30000
	_bin(20) = 0x5f0843ff, 0xe58b5b5e, 0x0010c25d

	_prm = varptr(GetMonitorInfo),_max,0,0,varptr(_rect)
	VirtualProtect varptr(_bin),96,$40,_p		// メモリプロテクトの設定
	_p = EnumDisplayMonitors(0,0,varptr(_bin),varptr(_prm))
	return _p

// ディスプレイの最大サイズを取得
; -----------------------------------------------------------------------------
; GetDispMaxSize var1, var2
; var1: 幅を受け取る変数  var2: 高さを受け取る変数
; 戻り値(stat) 0: 失敗  1: 成功
; -----------------------------------------------------------------------------
#deffunc GetDispMaxSize var _w, var _h, local _prm, local _rect, local _x, local _y, local _p
	GetMultiDispInfo 16,_prm,_rect
	_w=0: _h=0
	repeat _prm(2)
		_p=cnt*4
		_x=abs(_rect(_p)-_rect(_p+2))
		_y=abs(_rect(_p+1)-_rect(_p+3))
		if _x>_w { _w=_x }
		if _y>_h { _h=_y }
	loop
	return

// 指定座標を含むディスプレイ座標を取得
; -----------------------------------------------------------------------------
; GetCurrentDisp p1, p2, var1, var2, var3, var4
; p1, p2: 指定座標 X, Y
; var1: X1を受け取る変数  var2: Y1を受け取る変数
; var3: X2を受け取る変数  var4: Y2を受け取る変数
; 戻り値(stat) 0: 見つかった  0以外: 見つからなかった(範囲外)
; -----------------------------------------------------------------------------
#deffunc GetCurrentDisp int _x, int _y, var _x1, var _y1, var _x2, var _y2, local _prm, local _rect, local _p
	GetMultiDispInfo 16,_prm,_rect
	repeat _prm(2)
		_p=cnt*4
		_x1=_rect(_p): _y1=_rect(_p+1): _x2=_rect(_p+2): _y2=_rect(_p+3)
		if _x>=_x1 & _x<=_x2 & _y>=_y1 & _y<=_y2 { _prm=0: break }
	loop
	// 範囲外の場合はプライマリディスプレイの情報を返す(必要であればコメントアウトを外す)
;	if _prm { _x1=0: _y1=0: _x2=ginfo_dispx: _y2=ginfo_dispy }
	return _prm

#global
#endif

