;========================================================================================
;
; zmidilib version 1.00 by �͂� (Hau) �� �݂� (miyu rose)
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
    .include    zmidi.h

    .cpu    68000

;========================================================================================

    .text
    .even

;========================================================================================
;
    ZMIDI_wait::                                ; BUSY����E�F�C�g
;                                               ; ���ۂ�H-SYNC(��31��s)�ł͒������ł���
;                                               ; ����y���m���Ȃ̂łƂ肠��������ŁB
;                                               ; (�Q�l�FCZ-6BM1�͍Œ��ł�16��s�j
;
;----------------------------------------------------------------------------------------

@@:
    btst.b     #7,$00E88001                     ; H-SYNC(MFP GPIP �� bit7) ��
    beq        @b                               ; 0 �Ȃ烋�[�v
@@:
    btst.b     #7,$00E88001                     ; H-SYNC(MFP GPIP �� bit7) ��
    bne        @b                               ; 1 (������������) �Ȃ烋�[�v

    rts

;========================================================================================
;
    ZMIDI_set_accessmode::                      ; �A�N�Z�X���[�h�Ɉڍs����
;
;   return d0.l                                 ; ���C���Ԃ�l
;                                               ;   0�F����
;                                               ;  -1�F���s
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; �g�p���W�X�^��ޔ�
    moveq.l #-1,d7                              ; �Ԃ�l�������s�Ƃ��Ă���

    move.l  sp,a0                               ; sp��ޔ�
    move.l  $0008.w,a1                          ; �o�X�G���[�x�N�^��ޔ�
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI���������j

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N������ZMIDI�������Ȃ̂ł����܂�

    ;; �A�N�Z�X���[�h�Ɉڍs
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
.ifdef __DEBUG__
    move.b  #'S',_ZMIDI_REG+_ZMIDI_MODE         ; 'S' �� _ZMIDI_MODE �� ��������
.else.
    move.b  #'Z',_ZMIDI_REG+_ZMIDI_MODE         ; 'Z' �� _ZMIDI_MODE �� ��������
.endif
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; _ZMIDI_MODE �� d0 �� �ǂݏo��
    cmp.b   #'S',d0                             ; 'S' �� d0.b �Ɣ�r
    bne     99f                                 ; �Ⴄ�Ȃ�ύX���s

    moveq.l #1,d7                               ; �Ԃ�l���𐬌��ɂ���

99:
    move.l  a0,sp                               ; sp�𕜌�
    move.l  a1,$0008.w                          ; �o�X�G���[�̃x�N�^�𕜌�

    move.l  d7,d0                               ; �Ԃ�l���m�肷��

    movem.l (sp)+,d7/a0-a1                      ; �g�p���W�X�^�𕜌�

    rts                                         ; �����܂�

;========================================================================================
;
    ZMIDI_set_normalmode::                      ; �ʏ탂�[�h�Ɉڍs����
;
;   return d0.l                                 ; ���C���Ԃ�l
;                                               ;   0�F����
;                                               ;  -1�F���s
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; �g�p���W�X�^��ޔ�
    moveq.l #-1,d7                              ; ���C���Ԃ�l�������s�Ƃ��Ă���

    move.l  sp,a0                               ; sp��ޔ�
    move.l  $0008.w,a1                          ; �o�X�G���[�x�N�^��ޔ�
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI���������j

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N������ZMIDI�������Ȃ̂ł����܂�

    ;; �ʏ탂�[�h�Ɉڍs
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
.ifdef __DEBUG__
    move.b  #$ff,_ZMIDI_REG+_ZMIDI_MODE         ; $ff ��_ZMIDI_MODE �� ��������
.else
    move.b  #$00,_ZMIDI_REG+_ZMIDI_MODE         ; $00 ��_ZMIDI_MODE �� ��������
.endif
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; _ZMIDI_MODE �� d0 �� �ǂݏo��
    cmp.b   #$ff,d0                             ; $ff �� d0.b �Ɣ�r
    bne     99f                                 ; �Ⴄ�Ȃ�ύX���s
    
    moveq.l #0,d7                               ; �Ԃ�l���𐬌��ɂ���

99:
    move.l  a0,sp                               ; sp�𕜌�
    move.l  a1,$0008.w                          ; �o�X�G���[�̃x�N�^�𕜌�

    move.l  d7,d0                               ; ���C���Ԃ�l���m�肷��

    movem.l (sp)+,d7/a0-a1                      ; �g�p���W�X�^�𕜌�
    rts                                         ; �����܂�

;========================================================================================
;
    ZMIDI_set_delaytime::                       ; �x�����Ԃ�ݒ�
;
;   arg    d0.w                                 ; �ݒ肷�鎞��(ms)
;
;   return d0.l                                 ; ���C���Ԃ�l
;                                               ;   0�F����
;                                               ;  -1�F���s
;
;----------------------------------------------------------------------------------------

    movem.l d1/d7/a0-a1,-(sp)                   ; �g�p���W�X�^��ޔ�
    moveq.l #-1,d7                              ; ���C���Ԃ�l�������s�Ƃ��Ă���
    moveq.l #0,d1                               ; �x�����Ԑݒ�� 0(ms) �Ƃ��Ă���

    move.l  sp,a0                               ; sp��ޔ�
    move.l  $0008.w,a1                          ; �o�X�G���[�x�N�^��ޔ�
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI���������j

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d1           ; �o�X�G���[���N������ZMIDI�������Ȃ̂ł����܂�

    cmp.b   #$ff,d1                             ; $ff �� d1.b �Ɣ�r
    beq     1f                                  ;  �����Ȃ班�Ȃ��Ƃ����݃A�N�Z�X���[�h�ł͂Ȃ�
    cmp.b   #'S',d1                             ; 'S' �� d1.b �Ɣ�r
    beq     2f                                  ;  �����Ȃ猻�݃A�N�Z�X���[�h
    bra     99f                                 ;  �Ⴄ�Ȃ�ZMIDI���ُ�Ȃ̂ł����܂�

1:  ;; ���݁A�A�N�Z�X���[�h�ł͂Ȃ�
    move.w  d0,d1                               ; �x������ �� d1 �ɃR�s�[
    bsr     ZMIDI_set_accessmode                ; �A�N�Z�X���[�h�Ɉڍs����
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    move.w  sr,-(sp)                            ; sr ��ޔ�
    ori.w   #$0700,sr                           ; sr �� bit8-10 �𗧂Ă�(���荞�݋֎~)

    ror.w   #8,d1                               ; d1.b ��x�����Ԃ̏�ʃo�C�g
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  d1,_ZMIDI_REG+_ZMIDI_DELAY_UPPER    ; d1.b �� _ZMIDI_DELAY_UPPER �ɏ�������
    rol.w   #8,d1                               ; d1.b ��x�����Ԃ̉��ʃo�C�g
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  d1,_ZMIDI_REG+_ZMIDI_DELAY_LOWER    ; d1.b �� _ZMIDI_DELAY_UPPER �ɏ�������

    move.w  (sp)+,sr                            ; sr �𕜌�

    bsr     ZMIDI_set_normalmode                ; �ʏ탂�[�h�ɖ߂�
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    moveq.l #0,d7                               ; ���C���Ԃ�l���𐬌��ɂ���
    bra     99f                                 ; �����܂�

2:  ;; ���݁A�A�N�Z�X���[�h
    move.w  sr,-(sp)                            ; sr ��ޔ�
    ori.w   #$0700,sr                           ; sr �� bit8-10 �𗧂Ă�(���荞�݋֎~)

    ror.w   #8,d0
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  d0,_ZMIDI_REG+_ZMIDI_DELAY_UPPER    ; 
    rol.w   #8,d0
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  d0,_ZMIDI_REG+_ZMIDI_DELAY_LOWER

    move.w  (sp)+,sr                            ; sr �𕜌�

    moveq.l #0,d7                               ; �Ԃ�l���𐬌��ɂ���

99:
    move.l  a0,sp                               ; sp�𕜌�
    move.l  a1,$0008.w                          ; �o�X�G���[�̃x�N�^�𕜌�

    move.l  d7,d0                               ; ���C���Ԃ�l���m�肷��

    movem.l (sp)+,d1/d7/a0-a1                   ; �g�p���W�X�^�𕜌�
    rts                                         ; �����܂�

;========================================================================================
;
    ZMIDI_set_patch::                           ; SC-55�o���N�Z���N�g��֋@�\��L���ɂ���
;
;   return d0.l                                 ; ���C���Ԃ�l
;                                               ;   0�F����
;                                               ;  -1�F���s
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; �g�p���W�X�^��ޔ�
    moveq.l #-1,d7                              ; ���C���Ԃ�l�������s�Ƃ��Ă���

    move.l  sp,a0                               ; sp��ޔ�
    move.l  $0008.w,a1                          ; �o�X�G���[�x�N�^��ޔ�
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI���������j

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N������ZMIDI�������Ȃ̂ł����܂�

    cmp.b   #$ff,d0                             ; $ff �� d0.b �Ɣ�r
    beq     1f                                  ;  �����Ȃ班�Ȃ��Ƃ����݃A�N�Z�X���[�h�ł͂Ȃ�
    cmp.b   #'S',d0                             ; 'S' �� d0.b �Ɣ�r
    beq     2f                                  ;  �����Ȃ猻�݃A�N�Z�X���[�h
    bra     99f                                 ;  �Ⴄ�Ȃ�ZMIDI���ُ�Ȃ̂ł����܂�

1:  ;; ���݁A�A�N�Z�X���[�h�ł͂Ȃ�
    bsr     ZMIDI_set_accessmode                ; �A�N�Z�X���[�h�Ɉڍs����
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #$01,_ZMIDI_REG+_ZMIDI_PATCH        ; $01 �� _ZMIDI_PATCH �� ��������
    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; _ZMIDI_PATCH �� d0.b �֓ǂݍ���
    cmp.b   #$01,d0                             ; $01 �� d0.b �Ɣ�r
    bne     99f                                 ;  �Ⴄ�Ȃ�ZMIDI���ُ�Ȃ̂ł����܂�

    bsr     ZMIDI_set_normalmode                ; �ʏ탂�[�h�ɖ߂�
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    moveq.l #0,d7                               ; ���C���Ԃ�l���𐬌��ɂ���
    bra     99f                                 ; �����܂�

2:  ;; ���݁A�A�N�Z�X���[�h
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #$01,_ZMIDI_REG+_ZMIDI_PATCH        ; $01 �� _ZMIDI_ENABLED �� ��������
    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; �o�X�G���[���N������ZMIDI���ُ�Ȃ̂ł����܂�
    cmp.b   #$01,d0                             ; $01 �� d0.b �Ɣ�r
    bne     99f                                 ;  �Ⴄ�Ȃ�ZMIDI���ُ�Ȃ̂ł����܂�

    moveq.l #0,d7                               ; �Ԃ�l���𐬌��ɂ���

99:
    move.l  a0,sp                               ; sp�𕜌�
    move.l  a1,$0008.w                          ; �o�X�G���[�̃x�N�^�𕜌�

    move.l  d7,d0                               ; ���C���Ԃ�l���m�肷��

    movem.l (sp)+,d7/a0-a1                      ; �g�p���W�X�^�𕜌�
    rts                                         ; �����܂�

;========================================================================================
;
    ZMIDI_unset_patch::                         ; SC-55�o���N�Z���N�g��֋@�\�𖳌��ɂ���
;
;   return d0.l                                 ; ���C���Ԃ�l
;                                               ;   0�F����
;                                               ;  -1�F���s
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; �g�p���W�X�^��ޔ�
    moveq.l #-1,d7                              ; ���C���Ԃ�l�������s�Ƃ��Ă���

    move.l  sp,a0                               ; sp��ޔ�
    move.l  $0008.w,a1                          ; �o�X�G���[�x�N�^��ޔ�
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI���������j

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N������ZMIDI�������Ȃ̂ł����܂�

    cmp.b   #$ff,d0                             ; $ff �� d0.b �Ɣ�r
    beq     1f                                  ;  �����Ȃ班�Ȃ��Ƃ����݃A�N�Z�X���[�h�ł͂Ȃ�
    cmp.b   #'S',d0                             ; 'S' �� d0.b �Ɣ�r
    beq     2f                                  ;  �����Ȃ猻�݃A�N�Z�X���[�h
    bra     99f                                 ;  �Ⴄ�Ȃ�ZMIDI���ُ�Ȃ̂ł����܂�

1:  ;; ���݁A�A�N�Z�X���[�h�ł͂Ȃ�
    bsr     ZMIDI_set_accessmode                ; �A�N�Z�X���[�h�Ɉڍs����
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #$00,_ZMIDI_REG+_ZMIDI_PATCH        ; $00 �� _ZMIDI_PATCH �� ��������
    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; _ZMIDI_PATCH �� d0.b �֓ǂݍ���
    cmp.b   #$00,d0                             ; $00 �� d0.b �Ɣ�r
    bra     99f                                 ;  �Ⴄ�Ȃ�ZMIDI���ُ�Ȃ̂ł����܂�

    bsr     ZMIDI_set_normalmode                ; �ʏ탂�[�h�ɖ߂�
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    moveq.l #0,d7                               ; ���C���Ԃ�l���𐬌��ɂ���
    bra     99f                                 ; �����܂�

2:  ;; ���݁A�A�N�Z�X���[�h
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #$00,_ZMIDI_REG+_ZMIDI_PATCH        ; $00 �� _ZMIDI_ENABLED �� ��������
    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; �o�X�G���[���N������ZMIDI���ُ�Ȃ̂ł����܂�
    cmp.b   #$00,d0                             ; $00 �� d0.b �Ɣ�r
    bne     99f                                 ;  �Ⴄ�Ȃ�ZMIDI���ُ�Ȃ̂ł����܂�

    moveq.l #0,d7                               ; �Ԃ�l���𐬌��ɂ���

99:
    move.l  a0,sp                               ; sp�𕜌�
    move.l  a1,$0008.w                          ; �o�X�G���[�̃x�N�^�𕜌�

    move.l  d7,d0                               ; ���C���Ԃ�l���m�肷��

    movem.l (sp)+,d7/a0-a1                      ; �g�p���W�X�^�𕜌�
    rts                                         ; �����܂�

;========================================================================================
;
    ZMIDI_set_enable::                          ; ZMIDI �{�[�h��L���ɂ���
;
;   return d0.l                                 ; ���C���Ԃ�l
;                                               ;   0�F����
;                                               ;  -1�F���s
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; �g�p���W�X�^��ޔ�
    moveq.l #-1,d7                              ; ���C���Ԃ�l�������s�Ƃ��Ă���

    move.l  sp,a0                               ; sp��ޔ�
    move.l  $0008.w,a1                          ; �o�X�G���[�x�N�^��ޔ�
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI���������j

    move.w  sr,-(sp)                            ; sr ��ޔ�
    ori.w   #$0700,sr                           ; sr �� bit8-10 �𗧂Ă�(���荞�݋֎~)

    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'E',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'E' �� _ZMIDI_ENABLED �� ��������
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'N',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'N' �� _ZMIDI_ENABLED �� ��������
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'A',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'A' �� _ZMIDI_ENABLED �� ��������
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N������ZMIDI�������Ȃ̂ł����܂�

    move.w  (sp)+,sr                            ; sr �𕜌�

    moveq.l #0,d7                               ; ���C���Ԃ�l���𐬌��ɂ���

99:
    move.l  a0,sp                               ; sp�𕜌�
    move.l  a1,$0008.w                          ; �o�X�G���[�̃x�N�^�𕜌�

    move.l  d7,d0                               ; ���C���Ԃ�l���m�肷��

    movem.l (sp)+,d7/a0-a1                      ; �g�p���W�X�^�𕜌�
    rts                                         ; �����܂�

;========================================================================================
;
    ZMIDI_set_disable::                         ; ZMIDI �{�[�h�𖳌��ɂ���
;
;   return d0.l                                 ; ���C���Ԃ�l
;                                               ;   0�F����
;                                               ;  -1�F���s
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; �g�p���W�X�^��ޔ�
    moveq.l #-1,d7                              ; ���C���Ԃ�l�������s�Ƃ��Ă���

    move.l  sp,a0                               ; sp��ޔ�
    move.l  $0008.w,a1                          ; �o�X�G���[�x�N�^��ޔ�
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI���������j

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N������ZMIDI�������Ȃ̂ł����܂�
   
    cmp.b   #$ff,d0                             ; $ff �� d0.b �Ɣ�r
    beq     1f                                  ;  �����Ȃ班�Ȃ��Ƃ����݃A�N�Z�X���[�h�ł͂Ȃ�
    cmp.b   #'S',d0                             ; 'S' �� d0.b �Ɣ�r
    beq     2f                                  ;  �����Ȃ猻�݃A�N�Z�X���[�h
    bra     99f                                 ;  �Ⴄ�Ȃ�ZMIDI������

1:  ;; ���݁A�A�N�Z�X���[�h�ł͂Ȃ�
    bsr     ZMIDI_set_accessmode                ; �A�N�Z�X���[�h�Ɉڍs����
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI������

    move.w  sr,-(sp)                            ; sr ��ޔ�
    ori.w   #$0700,sr                           ; sr �� bit8-10 �𗧂Ă�(���荞�݋֎~)

    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'D',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'D' �� _ZMIDI_ENABLED �� ��������
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'I',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'I' �� _ZMIDI_ENABLED �� ��������
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'S',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'S' �� _ZMIDI_ENABLED �� ��������

    move.w  (sp)+,sr                            ; sr �𕜌�

    move.l  #@f,$0008.w                         ; �o�X�G���[�x�N�^�㏑���i�����������j
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N�����疳���������Ȃ̂Ŏ���

    bsr     ZMIDI_set_normalmode                ; �ʏ탂�[�h�ɖ߂�
    bra     99f                                 ; �����܂�

@@:                                             ; �L�������s
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI�ُ펞�j
    bsr     ZMIDI_set_normalmode                ; �ʏ탂�[�h�ɖ߂�
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    moveq.l #0,d7                               ; ���C���Ԃ�l����ʏ탂�[�h�ɂ���
    bra     99f

2:  ;; ���݁A�A�N�Z�X���[�h
    move.w  sr,-(sp)                            ; sr ��ޔ�
    ori.w   #$0700,sr                           ; sr �� bit8-10 �𗧂Ă�(���荞�݋֎~)

    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'D',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'D' �� _ZMIDI_ENABLED �� ��������
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'I',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'I' �� _ZMIDI_ENABLED �� ��������
    bsr     ZMIDI_wait                          ; BUSY����E�F�C�g
    move.b  #'S',_ZMIDI_REG+_ZMIDI_ENABLED      ; 'S' �� _ZMIDI_ENABLED �� ��������

    move.w  (sp)+,sr                            ; sr �𕜌�

    move.l  #@f,$0008.w                         ; �o�X�G���[�x�N�^�㏑���i�����������j
    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N�����疳���������Ȃ̂Ŏ���
    bra     99f                                 ; �����܂�
@@:
    moveq.l #0,d7                               ; �Ԃ�l���𐬌��ɂ���

99:
    move.l  a0,sp                               ; sp�𕜌�
    move.l  a1,$0008.w                          ; �o�X�G���[�̃x�N�^�𕜌�

    move.l  d7,d0                               ; ���C���Ԃ�l���m�肷��

    movem.l (sp)+,d7/a0-a1                      ; �g�p���W�X�^�𕜌�
    rts                                         ; �����܂�

;----------------------------------------------------------------------------------------



;========================================================================================
;
    ZMIDI_get_status::                          ; ZMIDI�{�[�h�̌��݂̐ݒ���擾
;
;   return  d0.l                                ; ���C���Ԃ�l
;                                               ;   0�F�ʏ탂�[�h
;                                               ;   1�F�A�N�Z�X���[�h
;                                               ;  -1�FZMIDI������
;           d1.l                                ; [��ʃ��[�h]
;                                               ;   0:�ʏ�MIDI���[�h
;                                               ;   1:�L���s�^�������Č����[�h
;                                               ; [���ʃ��[�h]
;                                               ;  �x�����Ԑݒ�l(ms)
;
;----------------------------------------------------------------------------------------

    movem.l d7/a0-a1,-(sp)                      ; �g�p���W�X�^��ޔ�
    moveq.l #-1,d7                              ; ���C���Ԃ�l����ZMIDI�������Ƃ��Ă���
    moveq.l #0,d1                               ; ��Q���������������Ă���

    move.l  sp,a0                               ; sp��ޔ�
    move.l  $0008.w,a1                          ; �o�X�G���[�x�N�^��ޔ�
    move.l  #99f,$0008.w                        ; �o�X�G���[�x�N�^�㏑���iZMIDI���������j

    move.b  _ZMIDI_REG+_ZMIDI_MODE,d0           ; �o�X�G���[���N������ZMIDI�������Ȃ̂ł����܂�
   
    cmp.b   #$ff,d0                             ; $ff �� d0.b �Ɣ�r
    beq     1f                                  ;  �����Ȃ猻�݃A�N�Z�X���[�h�ł͂Ȃ�
    cmp.b   #'S',d0                             ; 'S' �� d0.b �Ɣ�r
    beq     2f                                  ;  �����Ȃ猻�݃A�N�Z�X���[�h
    bra     99f                                 ;  �Ⴄ�Ȃ�ZMIDI���ُ�Ȃ̂ł����܂�

1:  ;; ���݁A�A�N�Z�X���[�h�ł͂Ȃ�
    bsr     ZMIDI_set_accessmode                ; �A�N�Z�X���[�h�Ɉڍs����
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    move.b  _ZMIDI_REG+_ZMIDI_DELAY_UPPER,d1    ; �x���ݒ�i��ʃo�C�g�j�� d1.b �ɓǂ�
    lsl.w   #8,d1                               ; ���ۂɏ�ʃo�C�g�փV�t�g
    move.b  _ZMIDI_REG+_ZMIDI_DELAY_LOWER,d1    ; �x���ݒ�i���ʃo�C�g�j�� d1.b �ɓǂ�

    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; ���݂�MIDI�M���p�b�`���[�h�� d0.b �ɓǂ�
    beq     @f                                  ; �p�b�`�Ȃ��Ȃ牽����������
    ori.l   #$10000,d1                          ; ���C���Ԃ�l�����L���s�^�������Č����[�h�ɂ���
@@:
    bsr     ZMIDI_set_normalmode                ; �ʏ탂�[�h�ɖ߂�
    bmi     99f                                 ; �ύX�ł��Ȃ�������ZMIDI���ُ�Ȃ̂ł����܂�

    moveq.l #0,d7                               ; ���C���Ԃ�l����ʏ탂�[�h�ɂ���
    bra     99f                                 ; �����܂�

2:  ;; ���݁A�A�N�Z�X���[�h
    move.b  _ZMIDI_REG+_ZMIDI_DELAY_UPPER,d1    ; �x���ݒ�i��ʃo�C�g�j�� d1.b �ɓǂ�
    lsl.w   #8,d1                               ; ���ۂɏ�ʃo�C�g�փV�t�g
    move.b  _ZMIDI_REG+_ZMIDI_DELAY_LOWER,d1    ; �x���ݒ�i���ʃo�C�g�j�� d1.b �ɓǂ�

    move.b  _ZMIDI_REG+_ZMIDI_PATCH,d0          ; ���݂�MIDI�M���p�b�`���[�h�� d0.b �ɓǂ�
    beq     @f                                  ; �p�b�`�Ȃ��Ȃ牽����������
    ori.l   #$10000,d1                          ; ���C���Ԃ�l�����L���s�^�������Č����[�h�ɂ���
@@:
    moveq.l #1,d7                               ; �Ԃ�l�����A�N�Z�X���[�h�ɂ���

99:
    move.l  a0,sp                               ; sp�𕜌�
    move.l  a1,$0008.w                          ; �o�X�G���[�̃x�N�^�𕜌�

    move.l  d7,d0                               ; ���C���Ԃ�l���m�肷��

    movem.l (sp)+,d7/a0-a1                      ; �g�p���W�X�^�𕜌�
    rts                                         ; �����܂�

;========================================================================================
.ifdef __DEBUG__
;========================================================================================
;
    ZMIDI_setup_sandbox::                       ; ZMIDI�{�[�h�̃e�X�g���Z�b�g�A�b�v
;
;----------------------------------------------------------------------------------------

    lea.l  _ZMIDI_REG,a6                        ; ZMIDI�{�[�h�̃��W�X�^�̉��z�A�h���X

    cmp.b   #'Z',1(a6)
    beq     99f
    move.b  #$FF,(a6)+                          ; $EAFA00 ����
    move.b  #'Z',(a6)+                          ; $EAFA01 ����
    move.w  #$03FF,(a6)+                        ; $EAFA02-$EAFA03 ����
    move.l  #$E8FF00FF,(a6)+                    ; $EAFA04-$EAFA07 ����
    move.l  #$FFFFFFFF,(a6)+                    ; $EAFA08-$EAFA0B ����
    move.l  #$FFFF00FF,(a6)+                    ; $EAFA0C-$EAFA0F ����
99:
    rts                                         ; �����܂�

;========================================================================================
.endif
;========================================================================================


;========================================================================================

    .data
    .even

;----------------------------------------------------------------------------------------

ZMIDI_Name::
    .dc.b   'ZMIDI�{�[�h',$00

;========================================================================================
