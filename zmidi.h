;========================================================================================
;
;  zmidi.h version 1.01 by はう (Hau) ＆ みゆ (miyu rose)
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

.ifdef __DEBUG__
_ZMIDI_REG    .equ     $00A00000
.else
_ZMIDI_REG    .equ     $00EAFA00
.endif

    .offset 0

_ZMIDI_MODE:
    .ds.b   1       ; $EAFA00：ZMIDI モード設定
                    ;  [READ]
                    ;   $ff：通常モード
                    ;   'S'：アクセスモード（ZMIDI レジスタへのアクセスが可能となります）
                    ;  [WRITE]
                    ;   'Z'以外：通常モードに戻る
                    ;   'Z'　　：アクセスモードに入る（操作後速やかに通常モードに戻すこと）

_ZMIDI_R00:
    .ds.b   1       ; $ECFA01：R00 IVR (割り込みベクタの読み出し) 相当
                    ;  [READONLY]
                    ;  バスエラーが起きなければ MIDIボード存在

_ZMIDI_DELAY_UPPER:
    .ds.b   1       ; $EAFA02：ZMIDI 遅延設定（上位バイト）
                    ;  [READ/WRITE] ※アクセスモード時
                    ;   遅延時間(0ms：$0000～1000ms：$03E8) の上位バイト

_ZMIDI_R01:
    .ds.b   1       ; $EAFA03：YM3802 R01 RGR (システム制御) 相当
                    ;  [WRITEONLY]

_ZMIDI_DELAY_LOWER:
    .ds.b   1       ; $EAFA04：ZMIDI 遅延設定（下位バイト）(R/W)
                    ;  [READ/WRITE] ※アクセスモード時
                    ;   遅延時間(0ms：$0000～1000ms：$03E8) の下位バイト

_ZMIDI_R02:
    .ds.b   1       ; $EAFA05：YM3802 R02 ISR (割り込みステータス情報) 相当
                    ;  [READONLY]

_ZMIDI_PATCH:
    .ds.b   1       ; $EAFA06：ZMIDI MIDI信号パッチ
                    ;  [READ/WRITE] ※アクセスモード時
                    ;   0：パッチなし
                    ;   1：SC-55バンクセレクト代替機能（キャピタル落ち再現）

_ZMIDI_R03:
    .ds.b   1       ; $EAFA07：YM3802 R03 ICR (割り込みクリア制御) 相当
                    ;  [WRITEONLY]

    .ds.b   1       ; $EAFA08：未定義

_ZMIDI_Rx4:
    .ds.b   1       ; $EAFA09：
                    ;  [READONLY]
                    ;   グループ番号 5：YM3802 R54 TSR (送信バッファ・ステータス) 相当
                    ;   グループ番号 6：YM3802 R64 FSR (FSKステータス) 相当
                    ;   グループ番号 7：YM3802 R74 SRR (レコーディング・カウンタ読み出し) 相当
                    ;  [WRITEONLY]
                    ;   グループ番号 0：YM3802 R04 IOR (割り込みベクタ・オフセット) 相当
                    ;   グループ番号 1：YM3802 R14 DMR (MIDI リアルタイム・メッセージ制御) 相当
                    ;   グループ番号 2：YM3802 R24 RRR (受診通信レイト設定) 相当
                    ;   グループ番号 3：YM3802 R34 RSR (受信バッファ・ステータス) 相当
                    ;   グループ番号 4：YM3802 R44 TRR (送信通信レイト設定) 相当
                    ;   グループ番号 8：YM3802 R84 GTRL (汎用タイマ時定数設定（下位）) 相当
                    ;   グループ番号 9：YM3802 R94 EDR (外部I/Oポートの入出力の設定) 相当

    .ds.b   1       ; $EAFA0A：未定義

_ZMIDI_Rx5:
    .ds.b   1       ; $EAFA0B：
                    ;  [WRITEONLY]
                    ;   グループ番号 0：YM3802 R05 IMR (割り込みモード・コントロール) 相当
                    ;   グループ番号 1：YM3802 R15 DCR (MIDI リアルタイム・メッセージ制御) 相当
                    ;   グループ番号 2：YM3802 R25 RMR (受信パラメータ) 相当
                    ;   グループ番号 3：YM3802 R35 RCR (受信バッファ制御) 相当
                    ;   グループ番号 4：YM3802 R45 TMR (送信パラメータ) 相当
                    ;   グループ番号 5：YM3802 R55 TCR (送信バッファ制御) 相当
                    ;   グループ番号 6：YM3802 R65 FCR (FSK制御) 相当
                    ;   グループ番号 7：YM3802 R75 SCR (補間器　制御) 相当
                    ;   グループ番号 8：YM3802 R85 GTRH (汎用タイマ時定数設定（上位）) 相当
                    ;   グループ番号 9：YM3802 R95 EOR (外部I/Oポートの出力データの設定) 相当

    .ds.b   1       ; $EAFA0C：未定義

_ZMIDI_Rx6:
    .ds.b   1       ; $EAFA0D：
                    ;  [READONLY]
                    ;   グループ番号 1：YM3802 R16 DSR (FIRO-IRx) 相当
                    ;   グループ番号 3：YM3802 R36 RDR (受信バッファ　データ) 相当
                    ;  [WRITEONLY]
                    ;   グループ番号 0：YM3802 R06 IER (割り込み制御) 相当
                    ;   グループ番号 2：YM3802 R26 AMR (アドレス・ハンタ制御１) 相当
                    ;   グループ番号 5：YM3802 R56 TDR (送信バッファ書き込み) 相当
                    ;   グループ番号 6：YM3802 R66 CCR (クリック・カウンタ制御) 相当
                    ;   グループ番号 7：YM3802 R76 SPRL (プレイバック・カウンタ時定数設定（下位）) 相当
                    ;   グループ番号 8：YM3802 R86 MTRL (MIDI クロック・タイマ時定数設定（下位）) 相当
                    ;   グループ番号 9：YM3802 R96 EIR (外部I/Oポートの入力データの読み出し) 相当
                    ;  [UNDEFINED]
                    ;   グループ番号 4：YM3802 R46 (未定義) 相当

_ZMIDI_ENABLED:
    .ds.b   1       ; $EAFA0E：ZMIDI ボード有効/無効の切り替えポート
                    ;  [READ]
                    ;   ZMIDI BOARD または 純正MIDIボード が装着されていれば読めます
                    ;  [WRITE]
                    ;   'E','N','A' と書き込むと有効モード
                    ;   'D','I','S' と書き込むと無効モード ※アクセスモード時

_ZMIDI_Rx7:
    .ds.b   1       ; $EAFA0F：
                    ;  [WRITEONLY]
                    ;   グループ番号 1：YM3802 R17 DNR (FIFO-IRx更新) 相当
                    ;   グループ番号 2：YM3802 R27 ADR (アドレス・ハンタ制御２) 相当
                    ;   グループ番号 6：YM3802 R67 CDR (クリック・カウンタ時定数設定) 相当
                    ;   グループ番号 7：YM3802 R77 SPRH (プレイバック・カウンタ時定数設定（上位）) 相当
                    ;   グループ番号 8：YM3802 R87 MTRH (MIDI クロック・タイマ時定数設定（上位）) 相当
