;========================================================================================
;
; zmidictl version 1.02 by はう (Hau) ＆ みゆ (miyu rose)
;
;                 Programmer  みゆ (miyu rose)
;                             X68KBBS：X68K0001
;                             X(Twitter)：@arith_rose
;
;            Special Adviser  はう (Hau) さま
;                     Tester  X68KBBS：X68K0024
;                             X(Twitter)：@Hau_oli
;
;========================================================================================

    .include    doscall.mac

    .cpu    68000

;=========================================================================================

    .text
    .even

;=========================================================================================

main:
    lea.l   mysp,sp                             ; スタック領域を自前で確保

;-----------------------------------------------------------------------------------------

SUPERVISORMODE:
    clr.l   -(sp)                               ; SUPERVISOR モード
    DOS     _SUPER
    tst.l   d0                                  ; 元の SSP アドレスが
    bpl     @f                                  ; 正しく取得できたら成功なので次へ
    DOS     _EXIT
@@:
    move.l  d0, (sp)                            ; SUPERVISOR モードになれたので SSP 保存

    bsr     ZMIDI_set_accessmode                ; ZMIDI をアクセスモードに移行

;-----------------------------------------------------------------------------------------
  
.ifdef __DEBUG__
    bsr     ZMIDI_setup_sandbox                 ; テスト環境セットアップ
.endif

;-----------------------------------------------------------------------------------------

    addq.l  #1,a2                               ; 引数のサイズは無視
arg_check:
    move.b  (a2)+,d0                            ; 引数文字をフェッチ
    cmpi.b  #' ',d0                             ; ' ' と比較して
    beq     arg_check                           ;  同じならスキップ
    cmpi.b  #'-',d0                             ; '-' と比較して
    beq     arg_option                          ;  同じならオプション引数チェックへ
    tst.b   d0                                  ; 終端文字と比較して
    beq     99f                                 ;  同じなら引数チェック終了

arg_help:
    bsr     disp_Help                           ; ヘルプ表示
    bra     USERMODE                            ; おしまい

arg_option:
    move.b  (a2)+,d0                            ; 引数文字(1文字目)をフェッチ
    or.b    #$20,d0                             ; 小文字化($00は' 'になります)

    cmpi.b  #'q',d0                             ; 'q' と比較して
    bne     10f                                 ;  違ったら次へ
    ori.b   #%10000000,flag_zmidictl            ; quiet モードのフラグをセット
    bra     arg_check                           ; 次の引数文字チェックへ

10:
    cmpi.b  #'d',d0                             ; 'd' と比較して
    bne     20f                                 ;  違ったら次へ
    moveq.l #0,d0                               ; 引数を扱いやすいよう 0 に
    moveq.l #0,d1                               ; 遅延時間の仮値を 0 に 

    move.b  (a2),d0                             ; 次の引数を d0 に取得
    cmp.b   #'0',d0                             ; '0' を d0 と比較
    blt     arg_help                            ;  d0 が小さければヘルプへ
    cmp.b   #'9',d0                             ; '9' を d0 と比較
    bgt     arg_help                            ;  d0 が大きければヘルプへ
    bra     12f                                 ; 次へ
11:
    move.b  (a2),d0                             ; 次の引数を d0 に取得
    cmp.b   #'0',d0                             ; '0' を d0 と比較
    blt     19f                                 ;  d0 が小さければ遅延時間設定へ
    cmp.b   #'9',d0                             ; '9' を d0 と比較
    bgt     19f                                 ;  d0 が大きければ遅延時間設定へ
12:
    addq.l  #1,a2                               ; 引数ポインタを進める
    and.b   #$0f,d0                             ; d0 を 0～9 に数値化

    lsl.l   #1,d1                               ; d1 *= 2
    move.l  d1,d2                               ; d2 = d1
    lsl.l   #2,d2                               ; d2 *= 4
    add.l   d2,d1                               ; d1 += d2
    add.l   d0,d1                               ; d1 += d0
    cmp.l   #1000,d1                            ; #1000 と d1 を比較
    ble     11b                                 ;  d1<=1000 なら次の桁へ
    bra     arg_help                            ; ヘルプ表示
19:
    move.l  d1,d0                               ; d0 = d1 (遅延時間を確定)
    bsr     ZMIDI_set_delaytime                 ; 遅延時間を設定
    bra     arg_check                           ; 次の引数文字チェックへ

20:
    cmpi.b  #'p',d0                             ; 'p' と比較して
    bne     30f                                 ;  違ったら次へ

    move.b  (a2)+,d0                            ; 次の引数をフェッチ
    cmp.b   #'0',d0                             ; '0' と比較
    beq     22f                                 ;  同じならパッチ無効へ
    cmp.b   #'1',d0                             ; '1' と比較
    bne     arg_help                            ;  違ったらヘルプ表示
21:
    bsr     ZMIDI_set_patch                     ; SC-55バンクセレクト代替パッチを有効にする
    bra     arg_check                           ; 次の引数文字チェックへ
22:
    bsr     ZMIDI_unset_patch                   ; SC-55バンクセレクト代替パッチを無効にする
    bra     arg_check                           ; 次の引数文字チェックへ

30:
    cmpi.b  #'z',d0                             ; 'z' と比較して
    bne     40f                                 ;  違ったら次へ

    move.b  (a2)+,d0                            ; 次の引数をフェッチ
    cmp.b   #'0',d0                             ; '0' と比較
    beq     32f                                 ;  同じなら通常モード設定
    cmp.b   #'1',d0                             ; '1' と比較
    bne     arg_help                            ;  違ったらヘルプ表示
31:
    bsr     ZMIDI_set_enable                    ; アクセスモードにする
    bra     arg_check                           ; 次の引数文字チェックへ
32:
    bsr     ZMIDI_set_disable                   ; 通常モードにする
    bra     arg_check                           ; 次の引数文字チェックへ
40:
98:
    bra     arg_help                            ; 該当しないのでヘルプ表示へ

99:

;-----------------------------------------------------------------------------------------

    bsr     disp_title                          ; タイトル表示
    bsr     disp_status                         ; ZMIDI BOARD の状態表示
    bsr     disp_crlf                           ; 改行表示

;-----------------------------------------------------------------------------------------

    bsr     ZMIDI_set_normalmode                ; ZMIDI を通常モードに戻す

USERMODE:
    DOS     _SUPER                              ; USER モード
    addq.l  #4,sp

;-----------------------------------------------------------------------------------------

EXIT:
    DOS        _EXIT                            ; おしまい

;=========================================================================================

disp_title:
    btst.b  #7,flag_zmidictl                    ; Quiet フラグが
    bne     99f                                 ; オンならおしまい

    movem.l d0,-(sp)                            ; 使用レジスタを退避

    bsr     mlib_printtitle                     ; Title 表示

    pea.l   mlib_crlf                           ; 改行を
    DOS     _PRINT                              ;  表示するよ
    addq.l  #4,sp

    movem.l (sp)+,d0                            ; 使用レジスタを復元
99:
    rts

;-----------------------------------------------------------------------------------------

disp_crlf:
    btst.b  #7,flag_zmidictl                    ; Quiet フラグが
    bne     99f                                 ; オンならおしまい

    movem.l d0,-(sp)                            ; 使用レジスタを退避

    pea.l   mlib_crlf                           ; 改行を
    DOS     _PRINT                              ;  表示するよ
    addq.l  #4,sp

    movem.l (sp)+,d0                            ; 使用レジスタを復元
99:
    rts

;-----------------------------------------------------------------------------------------

disp_status:
    btst.b  #7,flag_zmidictl                    ; Quiet フラグが
    bne     99f                                 ; オンならおしまい

    movem.l d0-d1,-(sp)                         ; 使用レジスタを退避
10:

    bsr     ZMIDI_get_status                    ; ZMIDIボードの現在の設定を取得
    bmi     90f                                 ; ZMIDIが無効の場合

20:
    pea.l   mes_delay                           ;「MIDI信号遅延時間」
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp
    
    move.l d1,d0                                ; 第２返り値を d0 へ
    andi.l #$ffff,d0                            ; 下位ワードのみを抽出
    bsr    mlib_printdec                        ; 十進数表示

    pea.l   mes_ms                              ; 「ms」
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

    pea.l   mlib_crlf                           ; 改行を
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

30:
    pea.l   mes_patch                           ; 「MIDI信号パッチ」
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

    move.l d1,d0                                ; 第２返り値を d0 へ
    andi.l #$10000,d0                           ; パッチ状況を取得
    beq    @f

    pea.l  mes_on                               ; 「オン」
    DOS    _PRINT                               ;  表示
    addq.l #4,sp

    bra    39f
@@:
    pea.l   mes_off                             ; 「オフ」
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp
39:
    pea.l   mlib_crlf                           ; 改行を
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

    bra    98f

90:

    pea.l   ZMIDI_Name                          ; ZMIDI の名前
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

    pea.l   mes_disabled                        ; 「利用できません」
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

    pea.l   mlib_crlf                           ; 改行を
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

98:
    movem.l (sp)+,d0-d1                         ; 使用レジスタを復元
99:
    rts                                         ; おしまい

;-----------------------------------------------------------------------------------------

disp_Help:
    btst.b  #7,flag_zmidictl                    ; Quiet フラグが
    bne     99f                                 ; オンならおしまい

    movem.l d0,-(sp)                            ; 使用レジスタを退避

    bsr     disp_title                          ; タイトル表示

    pea.l   mes_help                            ; ヘルプを
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

    pea.l   mlib_crlf                           ; 改行を
    DOS     _PRINT                              ;  表示
    addq.l  #4,sp

    movem.l (sp)+,d0                            ; 使用レジスタを復元
99:
    rts

;=========================================================================================

    .data
    .even

;-----------------------------------------------------------------------------------------

mlib_title::
    .dc.b   'zmidictl ',$00
mlib_version::
    .dc.b   $F3,'v',$F3,'e',$F3,'r',$F3,'s',$F3,'i',$F3,'o',$F3,'n',$F3,' '
    .dc.b   $F3,'1',$F3,'.',$F3,'0',$F3,'2',$F3,' ',$00
mlib_by::
    .dc.b   ' ',$F3,'b',$F3,'y ',$00
mlib_author::
    .dc.b   'Hau & みゆ (miyu rose)',$00

mes_help:
    .dc.b   ' zmidictl.x [options] ([options]...)',$0D,$0A
    .dc.b   '  [options]',$0D,$0A
    .dc.b   '   -q         : メッセージ非表示',$0D,$0A
    .dc.b   '   -d[0-1000] : 遅延時間指定(ms)',$0D,$0A
    .dc.b   '   -p[0|1]    : キャピタル落ち再現パッチ 無効|有効',$0D,$0A
    .dc.b   '   -z[0|1]    : ZMIDIボード 無効|有効',$0D,$0A
    .dc.b   $00

mes_disabled:
    .dc.b   'を利用できません',$00
mes_delay:
    .dc.b   'MIDI信号の遅延時間：',$00
mes_ms:
    .dc.b   'ms',$00
mes_patch:
    .dc.b   'キャピタル落ち再現：',$00
mes_on:
    .dc.b   'オン',$00
mes_off:
    .dc.b   'オフ',$00

;-----------------------------------------------------------------------------------------

    .bss
    .even

;-----------------------------------------------------------------------------------------

flag_zmidictl:                                  ; bit76543210
    .ds.b   1                                   ;   %10000000 quiet モード

;-----------------------------------------------------------------------------------------

    .stack
    .even

;-----------------------------------------------------------------------------------------

mystack:
    .ds.l   1024
mysp:
    .end    main

;=========================================================================================
