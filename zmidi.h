;========================================================================================
;
;  zmidi.h version 1.13 by �͂� (Hau) �� �݂� (miyu rose)
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

.ifdef __DEBUG__
_ZMIDI_REG    .equ     $00A00000
.else
_ZMIDI_REG    .equ     $00EAFA00
.endif

    .offset 0

_ZMIDI_MODE:
    .ds.b   1       ; $EAFA00�FZMIDI ���[�h�ݒ�
                    ;  [READ]
                    ;   $ff�F�ʏ탂�[�h
                    ;   'S'�F�A�N�Z�X���[�h�iZMIDI ���W�X�^�ւ̃A�N�Z�X���\�ƂȂ�܂��j
                    ;  [WRITE]
                    ;   'Z'�ȊO�F�ʏ탂�[�h�ɖ߂�
                    ;   'Z'�@�@�F�A�N�Z�X���[�h�ɓ���i����㑬�₩�ɒʏ탂�[�h�ɖ߂����Ɓj

_ZMIDI_R00:
    .ds.b   1       ; $ECFA01�FR00 IVR (���荞�݃x�N�^�̓ǂݏo��) ����
                    ;  [READONLY]
                    ;  �o�X�G���[���N���Ȃ���� MIDI�{�[�h����

_ZMIDI_DELAY_UPPER:
    .ds.b   1       ; $EAFA02�FZMIDI �x���ݒ�i��ʃo�C�g�j
                    ;  [READ/WRITE] ���A�N�Z�X���[�h��
                    ;   �x������(0ms�F$0000�`1000ms�F$03E8) �̏�ʃo�C�g

_ZMIDI_R01:
    .ds.b   1       ; $EAFA03�FYM3802 R01 RGR (�V�X�e������) ����
                    ;  [WRITEONLY]

_ZMIDI_DELAY_LOWER:
    .ds.b   1       ; $EAFA04�FZMIDI �x���ݒ�i���ʃo�C�g�j(R/W)
                    ;  [READ/WRITE] ���A�N�Z�X���[�h��
                    ;   �x������(0ms�F$0000�`1000ms�F$03E8) �̏�ʃo�C�g

_ZMIDI_R02:
    .ds.b   1       ; $EAFA05�FYM3802 R02 ISR (���荞�݃X�e�[�^�X���) ����
                    ;  [READONLY]

_ZMIDI_PATCH:
    .ds.b   1       ; $EAFA06�FZMIDI MIDI�M���p�b�`
                    ;  [READ/WRITE] ���A�N�Z�X���[�h��
                    ;   0�F�p�b�`�Ȃ�
                    ;   1�FSC-55�o���N�Z���N�g��֋@�\�i�L���s�^�������Č��j

_ZMIDI_R03:
    .ds.b   1       ; $EAFA07�FYM3802 R03 ICR (���荞�݃N���A����) ����
                    ;  [WRITEONLY]

    .ds.b   1       ; $EAFA08�F����`

_ZMIDI_Rx4:
    .ds.b   1       ; $EAFA09�F
                    ;  [READONLY]
                    ;   �O���[�v�ԍ� 5�FYM3802 R54 TSR (���M�o�b�t�@�E�X�e�[�^�X) ����
                    ;   �O���[�v�ԍ� 6�FYM3802 R64 FSR (FSK�X�e�[�^�X) ����
                    ;   �O���[�v�ԍ� 7�FYM3802 R74 SRR (���R�[�f�B���O�E�J�E���^�ǂݏo��) ����
                    ;  [WRITEONLY]
                    ;   �O���[�v�ԍ� 0�FYM3802 R04 IOR (���荞�݃x�N�^�E�I�t�Z�b�g) ����
                    ;   �O���[�v�ԍ� 1�FYM3802 R14 DMR (MIDI ���A���^�C���E���b�Z�[�W����) ����
                    ;   �O���[�v�ԍ� 2�FYM3802 R24 RRR (��f�ʐM���C�g�ݒ�) ����
                    ;   �O���[�v�ԍ� 3�FYM3802 R34 RSR (��M�o�b�t�@�E�X�e�[�^�X) ����
                    ;   �O���[�v�ԍ� 4�FYM3802 R44 TRR (���M�ʐM���C�g�ݒ�) ����
                    ;   �O���[�v�ԍ� 8�FYM3802 R84 GTRL (�ėp�^�C�}���萔�ݒ�i���ʁj) ����
                    ;   �O���[�v�ԍ� 9�FYM3802 R94 EDR (�O��I/O�|�[�g�̓��o�͂̐ݒ�) ����

    .ds.b   1       ; $EAFA0A�F����`

_ZMIDI_Rx5:
    .ds.b   1       ; $EAFA0B�F
                    ;  [WRITEONLY]
                    ;   �O���[�v�ԍ� 0�FYM3802 R05 IMR (���荞�݃��[�h�E�R���g���[��) ����
                    ;   �O���[�v�ԍ� 1�FYM3802 R15 DCR (MIDI ���A���^�C���E���b�Z�[�W����) ����
                    ;   �O���[�v�ԍ� 2�FYM3802 R25 RMR (��M�p�����[�^) ����
                    ;   �O���[�v�ԍ� 3�FYM3802 R35 RCR (��M�o�b�t�@����) ����
                    ;   �O���[�v�ԍ� 4�FYM3802 R45 TMR (���M�p�����[�^) ����
                    ;   �O���[�v�ԍ� 5�FYM3802 R55 TCR (���M�o�b�t�@����) ����
                    ;   �O���[�v�ԍ� 6�FYM3802 R65 FCR (FSK����) ����
                    ;   �O���[�v�ԍ� 7�FYM3802 R75 SCR (��Ԋ�@����) ����
                    ;   �O���[�v�ԍ� 8�FYM3802 R85 GTRH (�ėp�^�C�}���萔�ݒ�i��ʁj) ����
                    ;   �O���[�v�ԍ� 9�FYM3802 R95 EOR (�O��I/O�|�[�g�̏o�̓f�[�^�̐ݒ�) ����

    .ds.b   1       ; $EAFA0C�F����`

_ZMIDI_Rx6:
    .ds.b   1       ; $EAFA0D�F
                    ;  [READONLY]
                    ;   �O���[�v�ԍ� 1�FYM3802 R16 DSR (FIRO-IRx) ����
                    ;   �O���[�v�ԍ� 3�FYM3802 R36 RDR (��M�o�b�t�@�@�f�[�^) ����
                    ;  [WRITEONLY]
                    ;   �O���[�v�ԍ� 0�FYM3802 R06 IER (���荞�ݐ���) ����
                    ;   �O���[�v�ԍ� 2�FYM3802 R26 AMR (�A�h���X�E�n���^����P) ����
                    ;   �O���[�v�ԍ� 5�FYM3802 R56 TDR (���M�o�b�t�@��������) ����
                    ;   �O���[�v�ԍ� 6�FYM3802 R66 CCR (�N���b�N�E�J�E���^����) ����
                    ;   �O���[�v�ԍ� 7�FYM3802 R76 SPRL (�v���C�o�b�N�E�J�E���^���萔�ݒ�i���ʁj) ����
                    ;   �O���[�v�ԍ� 8�FYM3802 R86 MTRL (MIDI �N���b�N�E�^�C�}���萔�ݒ�i���ʁj) ����
                    ;   �O���[�v�ԍ� 9�FYM3802 R96 EIR (�O��I/O�|�[�g�̓��̓f�[�^�̓ǂݏo��) ����
                    ;  [UNDEFINED]
                    ;   �O���[�v�ԍ� 4�FYM3802 R46 (����`) ����

_ZMIDI_ENABLED:
    .ds.b   1       ; $EAFA0E�FZMIDI �{�[�h�L��/�����̐؂�ւ��|�[�g
                    ;  [READ]
                    ;   ZMIDI BOARD �܂��� ����MIDI�{�[�h ����������Ă���Γǂ߂܂�
                    ;  [WRITE]
                    ;   'E','N','A' �Ə������ނƗL�����[�h
                    ;   'D','I','S' �Ə������ނƖ������[�h ���A�N�Z�X���[�h��

_ZMIDI_Rx7:
    .ds.b   1       ; $EAFA0F�F
                    ;  [WRITEONLY]
                    ;   �O���[�v�ԍ� 1�FYM3802 R17 DNR (FIFO-IRx�X�V) ����
                    ;   �O���[�v�ԍ� 2�FYM3802 R27 ADR (�A�h���X�E�n���^����Q) ����
                    ;   �O���[�v�ԍ� 6�FYM3802 R67 CDR (�N���b�N�E�J�E���^���萔�ݒ�) ����
                    ;   �O���[�v�ԍ� 7�FYM3802 R77 SPRH (�v���C�o�b�N�E�J�E���^���萔�ݒ�i��ʁj) ����
                    ;   �O���[�v�ԍ� 8�FYM3802 R87 MTRH (MIDI �N���b�N�E�^�C�}���萔�ݒ�i��ʁj) ����
