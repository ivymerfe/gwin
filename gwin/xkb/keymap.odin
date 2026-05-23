package xkbcommon

KEY_BackSpace :: 0xff08 /* U+0008 BACKSPACE */
KEY_Tab :: 0xff09 /* U+0009 CHARACTER TABULATION */
KEY_Linefeed :: 0xff0a /* U+000A LINE FEED */
KEY_Clear :: 0xff0b /* U+000B LINE TABULATION */
KEY_Return :: 0xff0d /* U+000D CARRIAGE RETURN */
KEY_Pause :: 0xff13 /* Pause, hold */
KEY_Scroll_Lock :: 0xff14
KEY_Sys_Req :: 0xff15
KEY_Escape :: 0xff1b /* U+001B ESCAPE */
KEY_Delete :: 0xffff /* U+007F DELETE */

KEY_Home :: 0xff50
KEY_Left :: 0xff51 /* Move left, left arrow */
KEY_Up :: 0xff52 /* Move up, up arrow */
KEY_Right :: 0xff53 /* Move right, right arrow */
KEY_Down :: 0xff54 /* Move down, down arrow */
KEY_Prior :: 0xff55 /* Prior, previous */
KEY_Page_Up :: 0xff55 /* deprecated alias for Prior */
KEY_Next :: 0xff56 /* Next */
KEY_Page_Down :: 0xff56 /* deprecated alias for Next */
KEY_End :: 0xff57 /* EOL */
KEY_Begin :: 0xff58 /* BOL */


/* Misc functions */

KEY_Select :: 0xff60 /* Select, mark */
KEY_Print :: 0xff61
KEY_Execute :: 0xff62 /* Execute, run, do */
KEY_Insert :: 0xff63 /* Insert, insert here */
KEY_Undo :: 0xff65
KEY_Redo :: 0xff66 /* Redo, again */
KEY_Menu :: 0xff67
KEY_Find :: 0xff68 /* Find, search */
KEY_Cancel :: 0xff69 /* Cancel, stop, abort, exit */
KEY_Help :: 0xff6a /* Help */
KEY_Break :: 0xff6b
KEY_Mode_switch :: 0xff7e /* Character set switch */
KEY_script_switch :: 0xff7e /* non-deprecated alias for Mode_switch */
KEY_Num_Lock :: 0xff7f

/* Keypad functions, keypad numbers cleverly chosen to map to ASCII */

KEY_KP_Space :: 0xff80 /*<U+0020 SPACE>*/
KEY_KP_Tab :: 0xff89 /*<U+0009 CHARACTER TABULATION>*/
KEY_KP_Enter :: 0xff8d /*<U+000D CARRIAGE RETURN>*/
KEY_KP_F1 :: 0xff91 /* PF1, KP_A, ... */
KEY_KP_F2 :: 0xff92
KEY_KP_F3 :: 0xff93
KEY_KP_F4 :: 0xff94
KEY_KP_Home :: 0xff95
KEY_KP_Left :: 0xff96
KEY_KP_Up :: 0xff97
KEY_KP_Right :: 0xff98
KEY_KP_Down :: 0xff99
KEY_KP_Prior :: 0xff9a
KEY_KP_Page_Up :: 0xff9a /* deprecated alias for KP_Prior */
KEY_KP_Next :: 0xff9b
KEY_KP_Page_Down :: 0xff9b /* deprecated alias for KP_Next */
KEY_KP_End :: 0xff9c
KEY_KP_Begin :: 0xff9d
KEY_KP_Insert :: 0xff9e
KEY_KP_Delete :: 0xff9f
KEY_KP_Equal :: 0xffbd /*<U+003D EQUALS SIGN>*/
KEY_KP_Multiply :: 0xffaa /*<U+002A ASTERISK>*/
KEY_KP_Add :: 0xffab /*<U+002B PLUS SIGN>*/
KEY_KP_Separator :: 0xffac /*<U+002C COMMA>*/
KEY_KP_Subtract :: 0xffad /*<U+002D HYPHEN-MINUS>*/
KEY_KP_Decimal :: 0xffae /*<U+002E FULL STOP>*/
KEY_KP_Divide :: 0xffaf /*<U+002F SOLIDUS>*/

KEY_KP_0 :: 0xffb0 /*<U+0030 DIGIT ZERO>*/
KEY_KP_1 :: 0xffb1 /*<U+0031 DIGIT ONE>*/
KEY_KP_2 :: 0xffb2 /*<U+0032 DIGIT TWO>*/
KEY_KP_3 :: 0xffb3 /*<U+0033 DIGIT THREE>*/
KEY_KP_4 :: 0xffb4 /*<U+0034 DIGIT FOUR>*/
KEY_KP_5 :: 0xffb5 /*<U+0035 DIGIT FIVE>*/
KEY_KP_6 :: 0xffb6 /*<U+0036 DIGIT SIX>*/
KEY_KP_7 :: 0xffb7 /*<U+0037 DIGIT SEVEN>*/
KEY_KP_8 :: 0xffb8 /*<U+0038 DIGIT EIGHT>*/
KEY_KP_9 :: 0xffb9 /*<U+0039 DIGIT NINE>*/


/*
 * Auxiliary functions; note the duplicate definitions for left and right
 * function keys;  Sun keyboards and a few other manufacturers have such
 * function key groups on the left and/or right sides of the keyboard.
 * We've not found a keyboard with more than 35 function keys total.
 */

KEY_F1 :: 0xffbe
KEY_F2 :: 0xffbf
KEY_F3 :: 0xffc0
KEY_F4 :: 0xffc1
KEY_F5 :: 0xffc2
KEY_F6 :: 0xffc3
KEY_F7 :: 0xffc4
KEY_F8 :: 0xffc5
KEY_F9 :: 0xffc6
KEY_F10 :: 0xffc7
KEY_F11 :: 0xffc8

/* Modifiers */

KEY_Shift_L :: 0xffe1 /* Left shift */
KEY_Shift_R :: 0xffe2 /* Right shift */
KEY_Control_L :: 0xffe3 /* Left control */
KEY_Control_R :: 0xffe4 /* Right control */
KEY_Caps_Lock :: 0xffe5 /* Caps lock */
KEY_Shift_Lock :: 0xffe6 /* Shift lock */

KEY_Meta_L :: 0xffe7 /* Left meta */
KEY_Meta_R :: 0xffe8 /* Right meta */
KEY_Alt_L :: 0xffe9 /* Left alt */
KEY_Alt_R :: 0xffea /* Right alt */
KEY_Super_L :: 0xffeb /* Left super */
KEY_Super_R :: 0xffec /* Right super */
KEY_Hyper_L :: 0xffed /* Left hyper */
KEY_Hyper_R :: 0xffee /* Right hyper */

/*
 * Latin 1
 * (ISO/IEC 8859-1 = Unicode U+0020..U+00FF)
 * Byte 3 = 0
 */
KEY_space :: 0x0020 /* U+0020 SPACE */
KEY_exclam :: 0x0021 /* U+0021 EXCLAMATION MARK */
KEY_quotedbl :: 0x0022 /* U+0022 QUOTATION MARK */
KEY_numbersign :: 0x0023 /* U+0023 NUMBER SIGN */
KEY_dollar :: 0x0024 /* U+0024 DOLLAR SIGN */
KEY_percent :: 0x0025 /* U+0025 PERCENT SIGN */
KEY_ampersand :: 0x0026 /* U+0026 AMPERSAND */
KEY_apostrophe :: 0x0027 /* U+0027 APOSTROPHE */
KEY_quoteright :: 0x0027 /* deprecated */
KEY_parenleft :: 0x0028 /* U+0028 LEFT PARENTHESIS */
KEY_parenright :: 0x0029 /* U+0029 RIGHT PARENTHESIS */
KEY_asterisk :: 0x002a /* U+002A ASTERISK */
KEY_plus :: 0x002b /* U+002B PLUS SIGN */
KEY_comma :: 0x002c /* U+002C COMMA */
KEY_minus :: 0x002d /* U+002D HYPHEN-MINUS */
KEY_period :: 0x002e /* U+002E FULL STOP */
KEY_slash :: 0x002f /* U+002F SOLIDUS */
KEY_0 :: 0x0030 /* U+0030 DIGIT ZERO */
KEY_1 :: 0x0031 /* U+0031 DIGIT ONE */
KEY_2 :: 0x0032 /* U+0032 DIGIT TWO */
KEY_3 :: 0x0033 /* U+0033 DIGIT THREE */
KEY_4 :: 0x0034 /* U+0034 DIGIT FOUR */
KEY_5 :: 0x0035 /* U+0035 DIGIT FIVE */
KEY_6 :: 0x0036 /* U+0036 DIGIT SIX */
KEY_7 :: 0x0037 /* U+0037 DIGIT SEVEN */
KEY_8 :: 0x0038 /* U+0038 DIGIT EIGHT */
KEY_9 :: 0x0039 /* U+0039 DIGIT NINE */
KEY_colon :: 0x003a /* U+003A COLON */
KEY_semicolon :: 0x003b /* U+003B SEMICOLON */
KEY_less :: 0x003c /* U+003C LESS-THAN SIGN */
KEY_equal :: 0x003d /* U+003D EQUALS SIGN */
KEY_greater :: 0x003e /* U+003E GREATER-THAN SIGN */
KEY_question :: 0x003f /* U+003F QUESTION MARK */
KEY_at :: 0x0040 /* U+0040 COMMERCIAL AT */
KEY_A :: 0x0041 /* U+0041 LATIN CAPITAL LETTER A */
KEY_B :: 0x0042 /* U+0042 LATIN CAPITAL LETTER B */
KEY_C :: 0x0043 /* U+0043 LATIN CAPITAL LETTER C */
KEY_D :: 0x0044 /* U+0044 LATIN CAPITAL LETTER D */
KEY_E :: 0x0045 /* U+0045 LATIN CAPITAL LETTER E */
KEY_F :: 0x0046 /* U+0046 LATIN CAPITAL LETTER F */
KEY_G :: 0x0047 /* U+0047 LATIN CAPITAL LETTER G */
KEY_H :: 0x0048 /* U+0048 LATIN CAPITAL LETTER H */
KEY_I :: 0x0049 /* U+0049 LATIN CAPITAL LETTER I */
KEY_J :: 0x004a /* U+004A LATIN CAPITAL LETTER J */
KEY_K :: 0x004b /* U+004B LATIN CAPITAL LETTER K */
KEY_L :: 0x004c /* U+004C LATIN CAPITAL LETTER L */
KEY_M :: 0x004d /* U+004D LATIN CAPITAL LETTER M */
KEY_N :: 0x004e /* U+004E LATIN CAPITAL LETTER N */
KEY_O :: 0x004f /* U+004F LATIN CAPITAL LETTER O */
KEY_P :: 0x0050 /* U+0050 LATIN CAPITAL LETTER P */
KEY_Q :: 0x0051 /* U+0051 LATIN CAPITAL LETTER Q */
KEY_R :: 0x0052 /* U+0052 LATIN CAPITAL LETTER R */
KEY_S :: 0x0053 /* U+0053 LATIN CAPITAL LETTER S */
KEY_T :: 0x0054 /* U+0054 LATIN CAPITAL LETTER T */
KEY_U :: 0x0055 /* U+0055 LATIN CAPITAL LETTER U */
KEY_V :: 0x0056 /* U+0056 LATIN CAPITAL LETTER V */
KEY_W :: 0x0057 /* U+0057 LATIN CAPITAL LETTER W */
KEY_X :: 0x0058 /* U+0058 LATIN CAPITAL LETTER X */
KEY_Y :: 0x0059 /* U+0059 LATIN CAPITAL LETTER Y */
KEY_Z :: 0x005a /* U+005A LATIN CAPITAL LETTER Z */
KEY_bracketleft :: 0x005b /* U+005B LEFT SQUARE BRACKET */
KEY_backslash :: 0x005c /* U+005C REVERSE SOLIDUS */
KEY_bracketright :: 0x005d /* U+005D RIGHT SQUARE BRACKET */
KEY_asciicircum :: 0x005e /* U+005E CIRCUMFLEX ACCENT */
KEY_underscore :: 0x005f /* U+005F LOW LINE */
KEY_grave :: 0x0060 /* U+0060 GRAVE ACCENT */
KEY_quoteleft :: 0x0060 /* deprecated */
KEY_a :: 0x0061 /* U+0061 LATIN SMALL LETTER A */
KEY_b :: 0x0062 /* U+0062 LATIN SMALL LETTER B */
KEY_c :: 0x0063 /* U+0063 LATIN SMALL LETTER C */
KEY_d :: 0x0064 /* U+0064 LATIN SMALL LETTER D */
KEY_e :: 0x0065 /* U+0065 LATIN SMALL LETTER E */
KEY_f :: 0x0066 /* U+0066 LATIN SMALL LETTER F */
KEY_g :: 0x0067 /* U+0067 LATIN SMALL LETTER G */
KEY_h :: 0x0068 /* U+0068 LATIN SMALL LETTER H */
KEY_i :: 0x0069 /* U+0069 LATIN SMALL LETTER I */
KEY_j :: 0x006a /* U+006A LATIN SMALL LETTER J */
KEY_k :: 0x006b /* U+006B LATIN SMALL LETTER K */
KEY_l :: 0x006c /* U+006C LATIN SMALL LETTER L */
KEY_m :: 0x006d /* U+006D LATIN SMALL LETTER M */
KEY_n :: 0x006e /* U+006E LATIN SMALL LETTER N */
KEY_o :: 0x006f /* U+006F LATIN SMALL LETTER O */
KEY_p :: 0x0070 /* U+0070 LATIN SMALL LETTER P */
KEY_q :: 0x0071 /* U+0071 LATIN SMALL LETTER Q */
KEY_r :: 0x0072 /* U+0072 LATIN SMALL LETTER R */
KEY_s :: 0x0073 /* U+0073 LATIN SMALL LETTER S */
KEY_t :: 0x0074 /* U+0074 LATIN SMALL LETTER T */
KEY_u :: 0x0075 /* U+0075 LATIN SMALL LETTER U */
KEY_v :: 0x0076 /* U+0076 LATIN SMALL LETTER V */
KEY_w :: 0x0077 /* U+0077 LATIN SMALL LETTER W */
KEY_x :: 0x0078 /* U+0078 LATIN SMALL LETTER X */
KEY_y :: 0x0079 /* U+0079 LATIN SMALL LETTER Y */
KEY_z :: 0x007a /* U+007A LATIN SMALL LETTER Z */
KEY_braceleft :: 0x007b /* U+007B LEFT CURLY BRACKET */
KEY_bar :: 0x007c /* U+007C VERTICAL LINE */
KEY_braceright :: 0x007d /* U+007D RIGHT CURLY BRACKET */
KEY_asciitilde :: 0x007e /* U+007E TILDE */
