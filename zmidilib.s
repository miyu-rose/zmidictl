;========================================================================================
;
; zmidilib version 1.00 by はう (Hau) ＆ みゆ (miyu rose)
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
    .include    zmidi.h

    .cpu    68000

;========================================================================================

    .text
    .even

;========================================================================================
;
    ZMIDI_wait::                                ; BUSY回避ウェイト
;                                               ; 実際はH-SYNC(約31μs)では長すぎですが
;                                               ; お手軽かつ確実なのでとりあえずこれで。
;                                               ; (参考：CZ-6BM1は最長でも16μs）
;
;----------------------------------------------------------------------------------------

@@:
    btst.b     #7,$00E88001                     ; H-SYNC(MFP GPIP の bit7) が
    beq        @b                               ; 0 ならループ
@@:
    btst.b     #7,$00E88001                     ; H-SYNC(MFP GPIP の bit7) が
    bne        @b                               ; 1 (水平同期期間) ならループ

    rts

;========================================================================================
;
    ZMIDI_set_accessmode::                      ; アクセスモードに移行する
;
;   return d0.l                                 ; メイン返り値
;                                               ;   0：成功
;                                               ;  -1：失敗
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; 使用レジスタを退避
    moveq.l #-1,d7                              ; 返り値候補を失敗としておく

    move.l  sp,a0                               ; spを退避
    move.l  $0008.w,a1                          ; バスエラーベクタを退避
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDIが無効時）

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたらZMIDIが無効なのでおしまい

    ;; アクセスモードに移行
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
.ifdef __DEBUG__
    move.b  #'S',_ZMIDI_REG+_ZMIDI_MODE         ; 'S' を _ZMIDI_MODE へ 書き込む
.else.
    move.b  #'Z',_ZMIDI_REG+_ZMIDI_MODE         ; 'Z' を _ZMIDI_MODE へ 書き込む
.endif
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; _ZMIDI_MODE を d0 へ 読み出す
    cmp.b   #'S',d0                             ; 'S' を d0.b と比較
    bne     99f                                 ; 違うなら変更失敗

    moveq.l #1,d7                               ; 返り値候補を成功にする

99:
    move.l  a0,sp                               ; spを復元
    move.l  a1,$0008.w                          ; バスエラーのベクタを復元

    move.l  d7,d0                               ; 返り値を確定する

    movem.l (sp)+,d7/a0-a1                      ; 使用レジスタを復元

    rts                                         ; おしまい

;========================================================================================
;
    ZMIDI_set_normalmode::                      ; 通常モードに移行する
;
;   return d0.l                                 ; メイン返り値
;                                               ;   0：成功
;                                               ;  -1：失敗
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; 使用レジスタを退避
    moveq.l #-1,d7                              ; メイン返り値候補を失敗としておく

    move.l  sp,a0                               ; spを退避
    move.l  $0008.w,a1                          ; バスエラーベクタを退避
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDIが無効時）

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたらZMIDIが無効なのでおしまい

    ;; 通常モードに移行
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
.ifdef __DEBUG__
    move.b  #$ff,_ZMIDI_REG+_ZMIDI_MODE         ; $ff を_ZMIDI_MODE へ 書き込む
.else
    move.b  #$00,_ZMIDI_REG+_ZMIDI_MODE         ; $00 を_ZMIDI_MODE へ 書き込む
.endif
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; _ZMIDI_MODE を d0 へ 読み出す
    cmp.b   #$ff,d0                             ; $ff を d0.b と比較
    bne     99f                                 ; 違うなら変更失敗
    
    moveq.l #0,d7                               ; 返り値候補を成功にする

99:
    move.l  a0,sp                               ; spを復元
    move.l  a1,$0008.w                          ; バスエラーのベクタを復元

    move.l  d7,d0                               ; メイン返り値を確定する

    movem.l (sp)+,d7/a0-a1                      ; 使用レジスタを復元
    rts                                         ; おしまい

;========================================================================================
;
    ZMIDI_set_delaytime::                       ; 遅延時間を設定
;
;   arg    d0.w                                 ; 設定する時間(ms)
;
;   return d0.l                                 ; メイン返り値
;                                               ;   0：成功
;                                               ;  -1：失敗
;
;----------------------------------------------------------------------------------------

    movem.l d1/d7/a0-a1,-(sp)                   ; 使用レジスタを退避
    moveq.l #-1,d7                              ; メイン返り値候補を失敗としておく
    moveq.l #0,d1                               ; 遅延時間設定を 0(ms) としておく

    move.l  sp,a0                               ; spを退避
    move.l  $0008.w,a1                          ; バスエラーベクタを退避
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDIが無効時）

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d1           ; バスエラーが起きたらZMIDIが無効なのでおしまい

    cmp.b   #$ff,d1                             ; $ff を d1.b と比較
    beq     1f                                  ;  同じなら少なくとも現在アクセスモードではない
    cmp.b   #'S',d1                             ; 'S' を d1.b と比較
    beq     2f                                  ;  同じなら現在アクセスモード
    bra     99f                                 ;  違うならZMIDIが異常なのでおしまい

1:  ;; 現在、アクセスモードではない
    move.w  d0,d1                               ; 遅延時間 を d1 にコピー
    bsr     ZMIDI_set_accessmode                ; アクセスモードに移行する
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    move.w  sr,-(sp)                            ; sr を退避
    ori.w   #$0700,sr                           ; sr の bit8-10 を立てる(割り込み禁止)

    ror.w   #8,d1                               ; d1.b を遅延時間の上位バイト
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  d1,_ZMIDI_REG+_ZMIDI_DELAY_UPPER    ; d1.b を _ZMIDI_DELAY_UPPER に書き込む
    rol.w   #8,d1                               ; d1.b を遅延時間の下位バイト
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  d1,_ZMIDI_REG+_ZMIDI_DELAY_LOWER    ; d1.b を _ZMIDI_DELAY_UPPER に書き込む

    move.w  (sp)+,sr                            ; sr を復元

    bsr     ZMIDI_set_normalmode                ; 通常モードに戻す
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    moveq.l #0,d7                               ; メイン返り値候補を成功にする
    bra     99f                                 ; おしまい

2:  ;; 現在、アクセスモード
    move.w  sr,-(sp)                            ; sr を退避
    ori.w   #$0700,sr                           ; sr の bit8-10 を立てる(割り込み禁止)

    ror.w   #8,d0
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  d0,_ZMIDI_REG+_ZMIDI_DELAY_UPPER    ; 
    rol.w   #8,d0
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  d0,_ZMIDI_REG+_ZMIDI_DELAY_LOWER

    move.w  (sp)+,sr                            ; sr を復元

    moveq.l #0,d7                               ; 返り値候補を成功にする

99:
    move.l  a0,sp                               ; spを復元
    move.l  a1,$0008.w                          ; バスエラーのベクタを復元

    move.l  d7,d0                               ; メイン返り値を確定する

    movem.l (sp)+,d1/d7/a0-a1                   ; 使用レジスタを復元
    rts                                         ; おしまい

;========================================================================================
;
    ZMIDI_set_patch::                           ; SC-55バンクセレクト代替機能を有効にする
;
;   return d0.l                                 ; メイン返り値
;                                               ;   0：成功
;                                               ;  -1：失敗
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; 使用レジスタを退避
    moveq.l #-1,d7                              ; メイン返り値候補を失敗としておく

    move.l  sp,a0                               ; spを退避
    move.l  $0008.w,a1                          ; バスエラーベクタを退避
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDIが無効時）

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたらZMIDIが無効なのでおしまい

    cmp.b   #$ff,d0                             ; $ff を d0.b と比較
    beq     1f                                  ;  同じなら少なくとも現在アクセスモードではない
    cmp.b   #'S',d0                             ; 'S' を d0.b と比較
    beq     2f                                  ;  同じなら現在アクセスモード
    bra     99f                                 ;  違うならZMIDIが異常なのでおしまい

1:  ;; 現在、アクセスモードではない
    bsr     ZMIDI_set_accessmode                ; アクセスモードに移行する
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #$01,_ZMIDI_REG+_ZMIDI_PATCH        ; $01 を _ZMIDI_PATCH へ 書き込む
    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; _ZMIDI_PATCH を d0.b へ読み込む
    cmp.b   #$01,d0                             ; $01 を d0.b と比較
    bne     99f                                 ;  違うならZMIDIが異常なのでおしまい

    bsr     ZMIDI_set_normalmode                ; 通常モードに戻す
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    moveq.l #0,d7                               ; メイン返り値候補を成功にする
    bra     99f                                 ; おしまい

2:  ;; 現在、アクセスモード
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #$01,_ZMIDI_REG+_ZMIDI_PATCH        ; $01 を _ZMIDI_ENABLED へ 書き込む
    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; バスエラーが起きたらZMIDIが異常なのでおしまい
    cmp.b   #$01,d0                             ; $01 を d0.b と比較
    bne     99f                                 ;  違うならZMIDIが異常なのでおしまい

    moveq.l #0,d7                               ; 返り値候補を成功にする

99:
    move.l  a0,sp                               ; spを復元
    move.l  a1,$0008.w                          ; バスエラーのベクタを復元

    move.l  d7,d0                               ; メイン返り値を確定する

    movem.l (sp)+,d7/a0-a1                      ; 使用レジスタを復元
    rts                                         ; おしまい

;========================================================================================
;
    ZMIDI_unset_patch::                         ; SC-55バンクセレクト代替機能を無効にする
;
;   return d0.l                                 ; メイン返り値
;                                               ;   0：成功
;                                               ;  -1：失敗
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; 使用レジスタを退避
    moveq.l #-1,d7                              ; メイン返り値候補を失敗としておく

    move.l  sp,a0                               ; spを退避
    move.l  $0008.w,a1                          ; バスエラーベクタを退避
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDIが無効時）

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたらZMIDIが無効なのでおしまい

    cmp.b   #$ff,d0                             ; $ff を d0.b と比較
    beq     1f                                  ;  同じなら少なくとも現在アクセスモードではない
    cmp.b   #'S',d0                             ; 'S' を d0.b と比較
    beq     2f                                  ;  同じなら現在アクセスモード
    bra     99f                                 ;  違うならZMIDIが異常なのでおしまい

1:  ;; 現在、アクセスモードではない
    bsr     ZMIDI_set_accessmode                ; アクセスモードに移行する
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #$00,_ZMIDI_REG+_ZMIDI_PATCH        ; $00 を _ZMIDI_PATCH へ 書き込む
    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; _ZMIDI_PATCH を d0.b へ読み込む
    cmp.b   #$00,d0                             ; $00 を d0.b と比較
    bra     99f                                 ;  違うならZMIDIが異常なのでおしまい

    bsr     ZMIDI_set_normalmode                ; 通常モードに戻す
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    moveq.l #0,d7                               ; メイン返り値候補を成功にする
    bra     99f                                 ; おしまい

2:  ;; 現在、アクセスモード
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #$00,_ZMIDI_REG+_ZMIDI_PATCH        ; $00 を _ZMIDI_ENABLED へ 書き込む
    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; バスエラーが起きたらZMIDIが異常なのでおしまい
    cmp.b   #$00,d0                             ; $00 を d0.b と比較
    bne     99f                                 ;  違うならZMIDIが異常なのでおしまい

    moveq.l #0,d7                               ; 返り値候補を成功にする

99:
    move.l  a0,sp                               ; spを復元
    move.l  a1,$0008.w                          ; バスエラーのベクタを復元

    move.l  d7,d0                               ; メイン返り値を確定する

    movem.l (sp)+,d7/a0-a1                      ; 使用レジスタを復元
    rts                                         ; おしまい

;========================================================================================
;
    ZMIDI_set_enable::                          ; ZMIDI ボードを有効にする
;
;   return d0.l                                 ; メイン返り値
;                                               ;   0：成功
;                                               ;  -1：失敗
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; 使用レジスタを退避
    moveq.l #-1,d7                              ; メイン返り値候補を失敗としておく

    move.l  sp,a0                               ; spを退避
    move.l  $0008.w,a1                          ; バスエラーベクタを退避
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDIが無効時）

    move.w  sr,-(sp)                            ; sr を退避
    ori.w   #$0700,sr                           ; sr の bit8-10 を立てる(割り込み禁止)

    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'E',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'E' を _ZMIDI_ENABLED へ 書き込む
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'N',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'N' を _ZMIDI_ENABLED へ 書き込む
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'A',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'A' を _ZMIDI_ENABLED へ 書き込む
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたらZMIDIが無効なのでおしまい

    move.w  (sp)+,sr                            ; sr を復元

    moveq.l #0,d7                               ; メイン返り値候補を成功にする

99:
    move.l  a0,sp                               ; spを復元
    move.l  a1,$0008.w                          ; バスエラーのベクタを復元

    move.l  d7,d0                               ; メイン返り値を確定する

    movem.l (sp)+,d7/a0-a1                      ; 使用レジスタを復元
    rts                                         ; おしまい

;========================================================================================
;
    ZMIDI_set_disable::                         ; ZMIDI ボードを無効にする
;
;   return d0.l                                 ; メイン返り値
;                                               ;   0：成功
;                                               ;  -1：失敗
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; 使用レジスタを退避
    moveq.l #-1,d7                              ; メイン返り値候補を失敗としておく

    move.l  sp,a0                               ; spを退避
    move.l  $0008.w,a1                          ; バスエラーベクタを退避
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDIが無効時）

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたらZMIDIが無効なのでおしまい
   
    cmp.b   #$ff,d0                             ; $ff を d0.b と比較
    beq     1f                                  ;  同じなら少なくとも現在アクセスモードではない
    cmp.b   #'S',d0                             ; 'S' を d0.b と比較
    beq     2f                                  ;  同じなら現在アクセスモード
    bra     99f                                 ;  違うならZMIDIが無効

1:  ;; 現在、アクセスモードではない
    bsr     ZMIDI_set_accessmode                ; アクセスモードに移行する
    bmi     99f                                 ; 変更できなかったらZMIDIが無効

    move.w  sr,-(sp)                            ; sr を退避
    ori.w   #$0700,sr                           ; sr の bit8-10 を立てる(割り込み禁止)

    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'D',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'D' を _ZMIDI_ENABLED へ 書き込む
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'I',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'I' を _ZMIDI_ENABLED へ 書き込む
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'S',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'S' を _ZMIDI_ENABLED へ 書き込む

    move.w  (sp)+,sr                            ; sr を復元

    move.l  #@f,$0008.w                         ; バスエラーベクタ上書き（無効化成功）
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたら無効化成功なので次へ

    bsr     ZMIDI_set_normalmode                ; 通常モードに戻す
    bra     99f                                 ; おしまい

@@:                                             ; 有効化失敗
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDI異常時）
    bsr     ZMIDI_set_normalmode                ; 通常モードに戻す
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    moveq.l #0,d7                               ; メイン返り値候補を通常モードにする
    bra     99f

2:  ;; 現在、アクセスモード
    move.w  sr,-(sp)                            ; sr を退避
    ori.w   #$0700,sr                           ; sr の bit8-10 を立てる(割り込み禁止)

    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'D',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'D' を _ZMIDI_ENABLED へ 書き込む
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'I',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'I' を _ZMIDI_ENABLED へ 書き込む
    bsr     ZMIDI_wait                          ; BUSY回避ウェイト
    move.b  #'S',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'S' を _ZMIDI_ENABLED へ 書き込む

    move.w  (sp)+,sr                            ; sr を復元

    move.l  #@f,$0008.w                         ; バスエラーベクタ上書き（無効化成功）
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたら無効化成功なので次へ
    bra     99f                                 ; おしまい
@@:
    moveq.l #0,d7                               ; 返り値候補を成功にする

99:
    move.l  a0,sp                               ; spを復元
    move.l  a1,$0008.w                          ; バスエラーのベクタを復元

    move.l  d7,d0                               ; メイン返り値を確定する

    movem.l (sp)+,d7/a0-a1                      ; 使用レジスタを復元
    rts                                         ; おしまい

;----------------------------------------------------------------------------------------



;========================================================================================
;
    ZMIDI_get_status::                          ; ZMIDIボードの現在の設定を取得
;
;   return  d0.l                                ; メイン返り値
;                                               ;   0：通常モード
;                                               ;   1：アクセスモード
;                                               ;  -1：ZMIDIが無効
;           d1.l                                ; [上位ワード]
;                                               ;   0:通常MIDIモード
;                                               ;   1:キャピタル落ち再現モード
;                                               ; [下位ワード]
;                                               ;  遅延時間設定値(ms)
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; 使用レジスタを退避
    moveq.l #-1,d7                              ; メイン返り値候補をZMIDIが無効としておく
    moveq.l #0,d1                               ; 第２引数を初期化しておく

    move.l  sp,a0                               ; spを退避
    move.l  $0008.w,a1                          ; バスエラーベクタを退避
    move.l  #99f,$0008.w                        ; バスエラーベクタ上書き（ZMIDIが無効時）

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; バスエラーが起きたらZMIDIが無効なのでおしまい
   
    cmp.b   #$ff,d0                             ; $ff を d0.b と比較
    beq     1f                                  ;  同じなら現在アクセスモードではない
    cmp.b   #'S',d0                             ; 'S' を d0.b と比較
    beq     2f                                  ;  同じなら現在アクセスモード
    bra     99f                                 ;  違うならZMIDIが異常なのでおしまい

1:  ;; 現在、アクセスモードではない
    bsr     ZMIDI_set_accessmode                ; アクセスモードに移行する
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    move.b  _ZMIDI_REG+_ZMIDI_DELAY_UPPER,d1    ; 遅延設定（上位バイト）を d1.b に読む
    lsl.w   #8,d1                               ; 実際に上位バイトへシフト
    move.b  _ZMIDI_REG+_ZMIDI_DELAY_LOWER,d1    ; 遅延設定（下位バイト）を d1.b に読む

    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; 現在のMIDI信号パッチモードを d0.b に読む
    beq     @f                                  ; パッチなしなら何もせず次へ
    ori.l   #$10000,d1                          ; メイン返り値候補をキャピタル落ち再現モードにする
@@:
    bsr     ZMIDI_set_normalmode                ; 通常モードに戻す
    bmi     99f                                 ; 変更できなかったらZMIDIが異常なのでおしまい

    moveq.l #0,d7                               ; メイン返り値候補を通常モードにする
    bra     99f                                 ; おしまい

2:  ;; 現在、アクセスモード
    move.b  _ZMIDI_REG+_ZMIDI_DELAY_UPPER,d1    ; 遅延設定（上位バイト）を d1.b に読む
    lsl.w   #8,d1                               ; 実際に上位バイトへシフト
    move.b  _ZMIDI_REG+_ZMIDI_DELAY_LOWER,d1    ; 遅延設定（下位バイト）を d1.b に読む

    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; 現在のMIDI信号パッチモードを d0.b に読む
    beq     @f                                  ; パッチなしなら何もせず次へ
    ori.l   #$10000,d1                          ; メイン返り値候補をキャピタル落ち再現モードにする
@@:
    moveq.l #1,d7                               ; 返り値候補をアクセスモードにする

99:
    move.l  a0,sp                               ; spを復元
    move.l  a1,$0008.w                          ; バスエラーのベクタを復元

    move.l  d7,d0                               ; メイン返り値を確定する

    movem.l (sp)+,d7/a0-a1                      ; 使用レジスタを復元
    rts                                         ; おしまい

;========================================================================================
.ifdef __DEBUG__
;========================================================================================
;
    ZMIDI_setup_sandbox::                       ; ZMIDIボードのテスト環境セットアップ
;
;----------------------------------------------------------------------------------------

    lea.l  _ZMIDI_REG,a6                        ; ZMIDIボードのレジスタの仮想アドレス

    cmp.b   #'Z',1(a6)
    beq     99f
    move.b  #$FF,(a6)+                          ; $EAFA00 相当
    move.b  #'Z',(a6)+                          ; $EAFA01 相当
    move.w  #$03FF,(a6)+                        ; $EAFA02-$EAFA03 相当
    move.l  #$E8FF00FF,(a6)+                    ; $EAFA04-$EAFA07 相当
    move.l  #$FFFFFFFF,(a6)+                    ; $EAFA08-$EAFA0B 相当
    move.l  #$FFFF00FF,(a6)+                    ; $EAFA0C-$EAFA0F 相当
99:
    rts                                         ; おしまい

;========================================================================================
.endif
;========================================================================================


;========================================================================================

    .data
    .even

;----------------------------------------------------------------------------------------

ZMIDI_Name::
    .dc.b   'ZMIDIボード',$00

;========================================================================================
