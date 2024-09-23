;========================================================================================
;
; zmidictl version 1.02 by �͂� (Hau) �� �݂� (miyu rose)
;
;                 Programmer  �݂� (miyu rose)
;                             X68KBBS�FX68K0001
;                             X(Twitter)�F@arith_rose
;
;            Special Adviser  �͂� (Hau) ����
;                     Tester  X68KBBS�FX68K0024
;                             X(Twitter)�F@Hau_oli
;
;========================================================================================

    .include    doscall.mac

    .cpu    68000

;=========================================================================================

    .text
    .even

;=========================================================================================

main:
    lea.l   mysp,sp                             ; �X�^�b�N�̈�����O�Ŋm��

;-----------------------------------------------------------------------------------------

SUPERVISORMODE:
    clr.l   -(sp)                               ; SUPERVISOR ���[�h
    DOS     _SUPER
    tst.l   d0                                  ; ���� SSP �A�h���X��
    bpl     @f                                  ; �������擾�ł����琬���Ȃ̂Ŏ���
    DOS     _EXIT
@@:
    move.l  d0, (sp)                            ; SUPERVISOR ���[�h�ɂȂꂽ�̂� SSP �ۑ�

    bsr     ZMIDI_set_accessmode                ; ZMIDI ���A�N�Z�X���[�h�Ɉڍs

;-----------------------------------------------------------------------------------------
  
.ifdef __DEBUG__
    bsr     ZMIDI_setup_sandbox                 ; �e�X�g���Z�b�g�A�b�v
.endif

;-----------------------------------------------------------------------------------------

    addq.l  #1,a2                               ; �����̃T�C�Y�͖���
arg_check:
    move.b  (a2)+,d0                            ; �����������t�F�b�`
    cmpi.b  #' ',d0                             ; ' ' �Ɣ�r����
    beq     arg_check                           ;  �����Ȃ�X�L�b�v
    cmpi.b  #'-',d0                             ; '-' �Ɣ�r����
    beq     arg_option                          ;  �����Ȃ�I�v�V���������`�F�b�N��
    tst.b   d0                                  ; �I�[�����Ɣ�r����
    beq     99f                                 ;  �����Ȃ�����`�F�b�N�I��

arg_help:
    bsr     disp_Help                           ; �w���v�\��
    bra     USERMODE                            ; �����܂�

arg_option:
    move.b  (a2)+,d0                            ; ��������(1������)���t�F�b�`
    or.b    #$20,d0                             ; ��������($00��' '�ɂȂ�܂�)

    cmpi.b  #'q',d0                             ; 'q' �Ɣ�r����
    bne     10f                                 ;  ������玟��
    ori.b   #%10000000,flag_zmidictl            ; quiet ���[�h�̃t���O���Z�b�g
    bra     arg_check                           ; ���̈��������`�F�b�N��

10:
    cmpi.b  #'d',d0                             ; 'd' �Ɣ�r����
    bne     20f                                 ;  ������玟��
    moveq.l #0,d0                               ; �����������₷���悤 0 ��
    moveq.l #0,d1                               ; �x�����Ԃ̉��l�� 0 �� 

    move.b  (a2),d0                             ; ���̈����� d0 �Ɏ擾
    cmp.b   #'0',d0                             ; '0' �� d0 �Ɣ�r
    blt     arg_help                            ;  d0 ����������΃w���v��
    cmp.b   #'9',d0                             ; '9' �� d0 �Ɣ�r
    bgt     arg_help                            ;  d0 ���傫����΃w���v��
    bra     12f                                 ; ����
11:
    move.b  (a2),d0                             ; ���̈����� d0 �Ɏ擾
    cmp.b   #'0',d0                             ; '0' �� d0 �Ɣ�r
    blt     19f                                 ;  d0 ����������Βx�����Ԑݒ��
    cmp.b   #'9',d0                             ; '9' �� d0 �Ɣ�r
    bgt     19f                                 ;  d0 ���傫����Βx�����Ԑݒ��
12:
    addq.l  #1,a2                               ; �����|�C���^��i�߂�
    and.b   #$0f,d0                             ; d0 �� 0�`9 �ɐ��l��

    lsl.l   #1,d1                               ; d1 *= 2
    move.l  d1,d2                               ; d2 = d1
    lsl.l   #2,d2                               ; d2 *= 4
    add.l   d2,d1                               ; d1 += d2
    add.l   d0,d1                               ; d1 += d0
    cmp.l   #1000,d1                            ; #1000 �� d1 ���r
    ble     11b                                 ;  d1<=1000 �Ȃ玟�̌���
    bra     arg_help                            ; �w���v�\��
19:
    move.l  d1,d0                               ; d0 = d1 (�x�����Ԃ��m��)
    bsr     ZMIDI_set_delaytime                 ; �x�����Ԃ�ݒ�
    bra     arg_check                           ; ���̈��������`�F�b�N��

20:
    cmpi.b  #'p',d0                             ; 'p' �Ɣ�r����
    bne     30f                                 ;  ������玟��

    move.b  (a2)+,d0                            ; ���̈������t�F�b�`
    cmp.b   #'0',d0                             ; '0' �Ɣ�r
    beq     22f                                 ;  �����Ȃ�p�b�`������
    cmp.b   #'1',d0                             ; '1' �Ɣ�r
    bne     arg_help                            ;  �������w���v�\��
21:
    bsr     ZMIDI_set_patch                     ; SC-55�o���N�Z���N�g��փp�b�`��L���ɂ���
    bra     arg_check                           ; ���̈��������`�F�b�N��
22:
    bsr     ZMIDI_unset_patch                   ; SC-55�o���N�Z���N�g��փp�b�`�𖳌��ɂ���
    bra     arg_check                           ; ���̈��������`�F�b�N��

30:
    cmpi.b  #'z',d0                             ; 'z' �Ɣ�r����
    bne     40f                                 ;  ������玟��

    move.b  (a2)+,d0                            ; ���̈������t�F�b�`
    cmp.b   #'0',d0                             ; '0' �Ɣ�r
    beq     32f                                 ;  �����Ȃ�ʏ탂�[�h�ݒ�
    cmp.b   #'1',d0                             ; '1' �Ɣ�r
    bne     arg_help                            ;  �������w���v�\��
31:
    bsr     ZMIDI_set_enable                    ; �A�N�Z�X���[�h�ɂ���
    bra     arg_check                           ; ���̈��������`�F�b�N��
32:
    bsr     ZMIDI_set_disable                   ; �ʏ탂�[�h�ɂ���
    bra     arg_check                           ; ���̈��������`�F�b�N��
40:
98:
    bra     arg_help                            ; �Y�����Ȃ��̂Ńw���v�\����

99:

;-----------------------------------------------------------------------------------------

    bsr     disp_title                          ; �^�C�g���\��
    bsr     disp_status                         ; ZMIDI BOARD �̏�ԕ\��
    bsr     disp_crlf                           ; ���s�\��

;-----------------------------------------------------------------------------------------

    bsr     ZMIDI_set_normalmode                ; ZMIDI ��ʏ탂�[�h�ɖ߂�

USERMODE:
    DOS     _SUPER                              ; USER ���[�h
    addq.l  #4,sp

;-----------------------------------------------------------------------------------------

EXIT:
    DOS        _EXIT                            ; �����܂�

;=========================================================================================

disp_title:
    btst.b  #7,flag_zmidictl                    ; Quiet �t���O��
    bne     99f                                 ; �I���Ȃ炨���܂�

    movem.l d0,-(sp)                            ; �g�p���W�X�^��ޔ�

    bsr     mlib_printtitle                     ; Title �\��

    pea.l   mlib_crlf                           ; ���s��
    DOS     _PRINT                              ;  �\�������
    addq.l  #4,sp

    movem.l (sp)+,d0                            ; �g�p���W�X�^�𕜌�
99:
    rts

;-----------------------------------------------------------------------------------------

disp_crlf:
    btst.b  #7,flag_zmidictl                    ; Quiet �t���O��
    bne     99f                                 ; �I���Ȃ炨���܂�

    movem.l d0,-(sp)                            ; �g�p���W�X�^��ޔ�

    pea.l   mlib_crlf                           ; ���s��
    DOS     _PRINT                              ;  �\�������
    addq.l  #4,sp

    movem.l (sp)+,d0                            ; �g�p���W�X�^�𕜌�
99:
    rts

;-----------------------------------------------------------------------------------------

disp_status:
    btst.b  #7,flag_zmidictl                    ; Quiet �t���O��
    bne     99f                                 ; �I���Ȃ炨���܂�

    movem.l d0-d1,-(sp)                         ; �g�p���W�X�^��ޔ�
10:

    bsr     ZMIDI_get_status                    ; ZMIDI�{�[�h�̌��݂̐ݒ���擾
    bmi     90f                                 ; ZMIDI�������̏ꍇ

20:
    pea.l   mes_delay                           ;�uMIDI�M���x�����ԁv
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp
    
    move.l d1,d0                                ; ��Q�Ԃ�l�� d0 ��
    andi.l #$ffff,d0                            ; ���ʃ��[�h�݂̂𒊏o
    bsr    mlib_printdec                        ; �\�i���\��

    pea.l   mes_ms                              ; �ums�v
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

    pea.l   mlib_crlf                           ; ���s��
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

30:
    pea.l   mes_patch                           ; �uMIDI�M���p�b�`�v
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

    move.l d1,d0                                ; ��Q�Ԃ�l�� d0 ��
    andi.l #$10000,d0                           ; �p�b�`�󋵂��擾
    beq    @f

    pea.l  mes_on                               ; �u�I���v
    DOS    _PRINT                               ;  �\��
    addq.l #4,sp

    bra    39f
@@:
    pea.l   mes_off                             ; �u�I�t�v
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp
39:
    pea.l   mlib_crlf                           ; ���s��
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

    bra    98f

90:

    pea.l   ZMIDI_Name                          ; ZMIDI �̖��O
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

    pea.l   mes_disabled                        ; �u���p�ł��܂���v
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

    pea.l   mlib_crlf                           ; ���s��
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

98:
    movem.l (sp)+,d0-d1                         ; �g�p���W�X�^�𕜌�
99:
    rts                                         ; �����܂�

;-----------------------------------------------------------------------------------------

disp_Help:
    btst.b  #7,flag_zmidictl                    ; Quiet �t���O��
    bne     99f                                 ; �I���Ȃ炨���܂�

    movem.l d0,-(sp)                            ; �g�p���W�X�^��ޔ�

    bsr     disp_title                          ; �^�C�g���\��

    pea.l   mes_help                            ; �w���v��
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

    pea.l   mlib_crlf                           ; ���s��
    DOS     _PRINT                              ;  �\��
    addq.l  #4,sp

    movem.l (sp)+,d0                            ; �g�p���W�X�^�𕜌�
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
    .dc.b   'Hau & �݂� (miyu rose)',$00

mes_help:
    .dc.b   ' zmidictl.x [options] ([options]...)',$0D,$0A
    .dc.b   '  [options]',$0D,$0A
    .dc.b   '   -q         : ���b�Z�[�W��\��',$0D,$0A
    .dc.b   '   -d[0-1000] : �x�����Ԏw��(ms)',$0D,$0A
    .dc.b   '   -p[0|1]    : �L���s�^�������Č��p�b�` ����|�L��',$0D,$0A
    .dc.b   '   -z[0|1]    : ZMIDI�{�[�h ����|�L��',$0D,$0A
    .dc.b   $00

mes_disabled:
    .dc.b   '�𗘗p�ł��܂���',$00
mes_delay:
    .dc.b   'MIDI�M���̒x�����ԁF',$00
mes_ms:
    .dc.b   'ms',$00
mes_patch:
    .dc.b   '�L���s�^�������Č��F',$00
mes_on:
    .dc.b   '�I��',$00
mes_off:
    .dc.b   '�I�t',$00

;-----------------------------------------------------------------------------------------

    .bss
    .even

;-----------------------------------------------------------------------------------------

flag_zmidictl:                                  ; bit76543210
    .ds.b   1                                   ;   %10000000 quiet ���[�h

;-----------------------------------------------------------------------------------------

    .stack
    .even

;-----------------------------------------------------------------------------------------

mystack:
    .ds.l   1024
mysp:
    .end    main

;=========================================================================================
