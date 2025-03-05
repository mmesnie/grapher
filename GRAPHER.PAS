{$N+}

PROGRAM GRAPHICS(INPUT,OUTPUT);

USES CRT,GRAPH;

CONST
  MAXSIZE1 = 100;
  MAXSIZE2 = 5;

TYPE
  EXPRESSION_TYPE = STRING[MAXSIZE1];
  NUMBER_STRING_TYPE = STRING[MAXSIZE2];
  ELEMENT_TYPE=EXTENDED;
  ELEMENT_TYPE2=CHAR;
  LIST_TYPE=ARRAY[1..MAXSIZE1] OF ELEMENT_TYPE;
  LIST_TYPE2=ARRAY[1..MAXSIZE1] OF ELEMENT_TYPE2;
  STACK_TYPE = RECORD
                 N:INTEGER;
                 LIST:LIST_TYPE;
               END;
  STACK_TYPE2 = RECORD
                  N:INTEGER;
                  LIST:LIST_TYPE2;
                END;



VAR
  GRAPHDRIVER,GRAPHMODE:INTEGER;
  LEFT,RIGHT,TOP,BOTTOM:EXTENDED;
  LEFTX,RIGHTX,TOPY,BOTTOMY:EXTENDED;
  XTICK,YTICK,INCREMENT,CURRENTX:EXTENDED;
  MIDDLEX,MIDDLEY:EXTENDED;
  BORDER_COLOR,AXIS_COLOR,TICK_COLOR:INTEGER;
  BACKGROUND_COLOR,PLOTTING_COLOR:INTEGER;
  POSTFIX,INFIX:EXPRESSION_TYPE;
  NUMBER_STRING:NUMBER_STRING_TYPE;
  NUMBER_STACK:STACK_TYPE;
  INFIX_STACK:STACK_TYPE2;
  NOISE:CHAR;
  SOUND_LEVEL:EXTENDED;
  UNDEFINED:BOOLEAN;
  CENTERX,CENTERY:EXTENDED;
  VALID_INFIX:BOOLEAN;


  PROCEDURE WAIT;
    VAR C:CHAR;
    BEGIN
      WRITELN;
      WRITE('ESCAPE FOR MAIN MENU');
      REPEAT
        C:=READKEY
      UNTIL C=CHR(27);
    END;

  PROCEDURE WAIT2;
    VAR C:CHAR;
    BEGIN
      SETCOLOR(WHITE);
      SETTEXTSTYLE(0,0,1);
      SETTEXTJUSTIFY(LEFTTEXT,TOPTEXT);
      OUTTEXTXY(ROUND(LEFT),ROUND(BOTTOM+27),'ESCAPE FOR MAIN MENU');
      REPEAT
        C:=READKEY
      UNTIL C=CHR(27);
      DELAY(250);
    END;

  PROCEDURE INITIALIZE_VARIABLES;
    BEGIN
      NOSOUND;
      GRAPHDRIVER:=DETECT;
      INITGRAPH(GRAPHDRIVER,GRAPHMODE,'c:\tp\bgi');
      RESTORECRTMODE;
      RIGHT:=GETMAXX;
      BOTTOM:=GETMAXY;
      LEFT:=0.0+25.0;
      RIGHT:=RIGHT-25.0;
      TOP:=0.0+25.0;
      BOTTOM:=BOTTOM-35.0;
      LEFTX:=-10.0;
      RIGHTX:=10.0;
      TOPY:=10.0;
      BOTTOMY:=-10.0;
      XTICK:=((RIGHT-LEFT)/(RIGHTX-LEFTX));
      YTICK:=((BOTTOM-TOP)/(TOPY-BOTTOMY));
      MIDDLEX:=ROUND(RIGHT - (RIGHTX*XTICK));
      MIDDLEY:=ROUND(TOP + (TOPY*YTICK));
      CENTERX:=GETMAXX/2;
      CENTERY:=GETMAXY/2;
      BORDER_COLOR:=15;
      AXIS_COLOR:=13;
      TICK_COLOR:=10;
      BACKGROUND_COLOR:=0;
      PLOTTING_COLOR:=15;
      INCREMENT:=0.1;
      NOISE:='1';
      SOUND_LEVEL:=0.3;
      NUMBER_STRING:='     ';
      INFIX:='SX.                                                                                                     ';
      POSTFIX:='X S                                                                                                          ';
      VALID_INFIX:=TRUE;
    END;

  PROCEDURE UPDATE_VARIABLES;
    BEGIN
      XTICK:= (RIGHT-LEFT) / (RIGHTX-LEFTX);
      YTICK:= (BOTTOM-TOP) / (TOPY-BOTTOMY);
      MIDDLEX:= RIGHT - (RIGHTX*XTICK);
      MIDDLEY:= TOP + (TOPY*YTICK);
    END;

  PROCEDURE ERROR_TONE;
  VAR I:INTEGER;
    BEGIN
      FOR I := 1 TO 6 DO
      BEGIN
        SOUND(75);
        DELAY(75);
        NOSOUND;
        DELAY(75);
      END;
      NOSOUND;
    END;

  PROCEDURE SUCCESS_TONE;
    BEGIN
      SOUND(2000);
      DELAY(50);
      NOSOUND;
    END;

  PROCEDURE ERROR_MESSAGE;
    BEGIN
      SETBKCOLOR(0);
      CLEARDEVICE;
      SETCOLOR(4);
      SETTEXTSTYLE(1,0,3);
      SETTEXTJUSTIFY(CENTERTEXT,CENTERTEXT);
      OUTTEXTXY(TRUNC(CENTERX)-4,TRUNC(CENTERY)-32,'INVALID ');
      DELAY(1000);
    END;

  PROCEDURE INVALID;
    BEGIN
      ERROR_TONE;
      ERROR_MESSAGE;
    END;

(***************************FUNCTIONS****************************************)

  FUNCTION ISP(A:CHAR):INTEGER;
    BEGIN
      CASE A OF
        'A': ISP:=3;
        'Q': ISP:=3;
        'L': ISP:=3;
        'E': ISP:=3;
        'C': ISP:=3;
        'T': ISP:=3;
        'S': ISP:=3;
        '^': ISP:=3;
        '*': ISP:=2;
        '/': ISP:=2;
        '+': ISP:=1;
        '-': ISP:=1;
        '(': ISP:=0;
      END;
    END;

  FUNCTION ICP(A:CHAR):INTEGER;
    BEGIN
      CASE A OF
        'A': ICP:=5;
        'Q': ICP:=5;
        'L': ICP:=5;
        'E': ICP:=5;
        'S': ICP:=5;
        'C': ICP:=5;
        'T': ICP:=5;
        '^': ICP:=4;
        '*': ICP:=2;
        '/': ICP:=2;
        '+': ICP:=1;
        '-': ICP:=1;
        '(': ICP:=6;
      END;
    END;

    FUNCTION POWER(A,B:EXTENDED):EXTENDED;
      VAR R:EXTENDED;
      BEGIN
        IF ((A=0)AND(B=0)) THEN
          BEGIN
            UNDEFINED:=TRUE;
            R:=0.0;
          END
        ELSE IF (A=0) THEN R:=0.0
        ELSE IF (B=0) THEN R:=1.0
        ELSE IF ((A<0)AND(B>0)) THEN
          BEGIN
            IF FRAC(B)=0 THEN
              BEGIN
                R:=EXP(B*LN(ABS(A)));
                IF ODD(TRUNC(B)) THEN R:=-R;
              END
            ELSE
              BEGIN
                UNDEFINED:=TRUE;
                R:=0.0;
              END;
          END
        ELSE IF ((A<0)AND(B<0)) THEN
          BEGIN
            IF FRAC(B)=0 THEN
              BEGIN
                R:=EXP(ABS(B)*LN(ABS(A)));
                R:=1/R;
                R:=-R;
              END
            ELSE
              BEGIN
                UNDEFINED:=TRUE;
                R:=0.0;
              END;
          END
        ELSE R:=EXP(B*LN(A));
        POWER:=R;
      END;

  FUNCTION INT(NUMSTR:NUMBER_STRING_TYPE):EXTENDED;
    VAR I:INTEGER;
    B,E:EXTENDED;
    NEGATIVE:BOOLEAN;
    BEGIN
      E:=-1.0;
      B:=0.0;
      FOR I:= MAXSIZE2 DOWNTO 1  DO
        BEGIN
          E:=E+1.0;
          CASE NUMSTR[I] OF
            ' ':E:=E-1.0;
            '0':B:=B;
            '1':B:=B + 1.0*POWER(10.0,E);
            '2':B:=B + 2.0*POWER(10.0,E);
            '3':B:=B + 3.0*POWER(10.0,E);
            '4':B:=B + 4.0*POWER(10.0,E);
            '5':B:=B + 5.0*POWER(10.0,E);
            '6':B:=B + 6.0*POWER(10.0,E);
            '7':B:=B + 7.0*POWER(10.0,E);
            '8':B:=B + 8.0*POWER(10.0,E);
            '9':B:=B + 9.0*POWER(10.0,E);
          END;
        END;
      INT:=B;
    END;


(*************************STACK PROCEDURES***********************************)


  PROCEDURE INIT(VAR S:STACK_TYPE);
    BEGIN
      S.N:=0;
    END;

  PROCEDURE INIT2;
    BEGIN
      INFIX_STACK.N:=0;
    END;

  PROCEDURE PUSH(VAR S:STACK_TYPE;ELEM:ELEMENT_TYPE);
    BEGIN
      S.N:=S.N+1;
      S.LIST[S.N]:=ELEM;
    END;

  PROCEDURE POP(VAR S:STACK_TYPE;VAR ELEM:ELEMENT_TYPE);
    BEGIN
      ELEM:=S.LIST[S.N];
      S.N:=S.N - 1;
    END;

  PROCEDURE PUSH2(ELEM:ELEMENT_TYPE2);
    BEGIN
      INFIX_STACK.N:=INFIX_STACK.N+1;
      INFIX_STACK.LIST[INFIX_STACK.N]:=ELEM;
    END;

  PROCEDURE POP2(VAR ELEM:ELEMENT_TYPE2);
    BEGIN
      ELEM:=INFIX_STACK.LIST[INFIX_STACK.N];
      INFIX_STACK.N:=INFIX_STACK.N-1;
    END;

(*****************************PARSING****************************************)

  PROCEDURE PARSE_INFIX;
    VAR I,J:INTEGER;
    X:CHAR;
    BEGIN
      POSTFIX:='                                                                                                    ';
      I:=1;J:=0;VALID_INFIX:=TRUE;
      INIT2;
      WRITELN;
      REPEAT
        IF ((INFIX[I]='S')OR(INFIX[I]='C')OR(INFIX[I]='E')OR
             (INFIX[I]='L')OR(INFIX[I]='T')OR(INFIX[I]='A')
             OR(INFIX[I]='Q')) THEN
          BEGIN
            IF INFIX_STACK.N=0 THEN
              BEGIN
                PUSH2(INFIX[I]);
              END
            ELSE
              BEGIN
                WHILE((ISP(INFIX_STACK.LIST[INFIX_STACK.N])>=ICP(INFIX[I])) AND  (INFIX_STACK.N<>0))
                  DO
                    BEGIN
                      POP2(X);
                      J:=J+1;
                      POSTFIX[J]:=X;
                      J:=J+1;
                      POSTFIX[J]:=' '
                    END;
                PUSH2(INFIX[I]);
              END
          END
        ELSE IF ((INFIX[I]='^')OR(INFIX[I]='*')OR(INFIX[I]='/')
            OR(INFIX[I]='+')OR(INFIX[I]='-'))
        THEN
          BEGIN
            IF INFIX_STACK.N=0 THEN
              BEGIN
                PUSH2(INFIX[I]);
              END
            ELSE
              BEGIN
                WHILE ((ISP(INFIX_STACK.LIST[INFIX_STACK.N])>=ICP(INFIX[I])) AND (INFIX_STACK.N<>0))
                 DO
                  BEGIN
                    POP2(X);
                    J:=J+1;
                    POSTFIX[J]:=X;
                    J:=J+1;
                    POSTFIX[J]:=' ';
                  END;
                PUSH2(INFIX[I]);
              END;
          END
        ELSE IF INFIX[I]=')' THEN
          BEGIN
            WHILE INFIX_STACK.LIST[INFIX_STACK.N]<>'(' DO
              BEGIN
                POP2(X);
                J:=J+1;
                POSTFIX[J]:=X;
                J:=J+1;
                POSTFIX[J]:=' ';
              END;
            POP2(X);
          END
        ELSE IF INFIX[I]='(' THEN
          BEGIN
            PUSH2(INFIX[I]);
          END
        ELSE IF (INFIX[I] IN ['0'..'9'])
             THEN
               BEGIN
                 REPEAT
                   J:=J+1;
                   POSTFIX[J]:=INFIX[I];
                   I:=I+1;
                 UNTIL NOT (INFIX[I] IN ['0'..'9']);
                 J:=J+1;
                 POSTFIX[J]:=' ';
                 I:=I-1;
                END
        ELSE IF INFIX[I]='X' THEN
          BEGIN
                J:=J+1;
                POSTFIX[J]:='X';
                J:=J+1;
                POSTFIX[J]:=' ';
          END
        ELSE IF (INFIX[I]<>'.') THEN
          VALID_INFIX:=FALSE;
        I:=I+1;
      UNTIL ((I>MAXSIZE1)OR(INFIX[I]='.')OR(NOT VALID_INFIX));
      (*SOME ERROR CHECKS*)
      IF INFIX[I]<>'.' THEN VALID_INFIX:=FALSE;
      IF VALID_INFIX THEN
        WHILE INFIX_STACK.N<>0 DO
          BEGIN
            POP2(X);
            J:=J+1;
            POSTFIX[J]:=X;
            J:=J+1;
            POSTFIX[J]:=' ';
          END;
      IF INFIX_STACK.N<>0 THEN VALID_INFIX:=FALSE;
      OUTTEXTXY(0,400,POSTFIX);WAIT2;
    END;

  PROCEDURE PARSE_POSTFIX;
    VAR I,J,K:INTEGER;X,Y:ELEMENT_TYPE;
    BEGIN
      INIT(NUMBER_STACK);
      I:=1;
      REPEAT
        BEGIN
          IF POSTFIX[I]='X' THEN PUSH(NUMBER_STACK,CURRENTX)
          ELSE IF POSTFIX[I]='S' THEN
            BEGIN
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,SIN(X));
            END
          ELSE IF POSTFIX[I]='C' THEN
            BEGIN
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,COS(X));
            END
          ELSE IF POSTFIX[I]='A' THEN
            BEGIN
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,ABS(X));
            END
          ELSE IF POSTFIX[I]='Q' THEN
            BEGIN
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,-X);
            END
          ELSE IF POSTFIX[I]='T' THEN
            BEGIN
              POP(NUMBER_STACK,X);
              IF COS(X)=0 THEN
                BEGIN
                  UNDEFINED:=TRUE;
                  PUSH(NUMBER_STACK,0);
                END
              ELSE PUSH(NUMBER_STACK,SIN(X)/COS(X));
            END
          ELSE IF POSTFIX[I]='^' THEN
            BEGIN
              POP(NUMBER_STACK,Y);
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,POWER(X,Y));
            END
          ELSE IF POSTFIX[I]='E' THEN
            BEGIN
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,EXP(X));
            END
          ELSE IF POSTFIX[I]='L' THEN
            BEGIN
              POP(NUMBER_STACK,X);
              IF X<=0 THEN
                BEGIN
                  UNDEFINED:=TRUE;
                  PUSH(NUMBER_STACK,0)
                END
              ELSE PUSH(NUMBER_STACK,LN(X));
            END
          ELSE IF POSTFIX[I]='*' THEN
            BEGIN
              POP(NUMBER_STACK,Y);
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,X*Y);
            END
          ELSE IF POSTFIX[I]='/' THEN
            BEGIN
              POP(NUMBER_STACK,Y);
              POP(NUMBER_STACK,X);
              IF Y = 0 THEN
                         BEGIN
                           UNDEFINED:=TRUE;
                           PUSH(NUMBER_STACK,0);
                         END
              ELSE PUSH(NUMBER_STACK,X/Y);
            END
          ELSE IF POSTFIX[I]='+' THEN
            BEGIN
              POP(NUMBER_STACK,Y);
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,X+Y);
            END
          ELSE IF POSTFIX[I]='-' THEN
            BEGIN
              POP(NUMBER_STACK,Y);
              POP(NUMBER_STACK,X);
              PUSH(NUMBER_STACK,X-Y);
            END
          ELSE IF POSTFIX[I]<>' ' THEN
            BEGIN
              J:=1;
              REPEAT
                NUMBER_STRING[J]:=POSTFIX[I];
                I:=I+1;
                J:=J+1;
              UNTIL POSTFIX[I]=' ';
              FOR K:= J TO MAXSIZE2 DO
                NUMBER_STRING[K]:=' ';
              PUSH(NUMBER_STACK,INT(NUMBER_STRING));
              I:=I-1;
            END;
          I:=I+1;
        END;
      UNTIL ((POSTFIX[I]='.') OR (I > MAXSIZE1));
    END;


(**********************GRAPHING PROCEDURES***********************************)


  PROCEDURE DRAW_AXIS;
    BEGIN
      SETLINESTYLE(0,0,1);
      SETCOLOR(AXIS_COLOR);
      LINE(ROUND(MIDDLEX),ROUND(TOP),ROUND(MIDDLEX),ROUND(BOTTOM));
      LINE(ROUND(LEFT),ROUND(MIDDLEY),ROUND(RIGHT),ROUND(MIDDLEY));
    END;

  PROCEDURE DRAW_BORDER;
    BEGIN
      SETLINESTYLE(0,0,3);
      SETCOLOR(BORDER_COLOR);
        LINE(ROUND(LEFT),ROUND(TOP),ROUND(RIGHT),ROUND(TOP));
        LINE(ROUND(RIGHT),ROUND(TOP),ROUND(RIGHT),ROUND(BOTTOM));
        LINE(ROUND(RIGHT),ROUND(BOTTOM),ROUND(LEFT),ROUND(BOTTOM));
        LINE(ROUND(LEFT),ROUND(BOTTOM),ROUND(LEFT),ROUND(TOP));
    END;

  PROCEDURE DRAW_TICKS;
  VAR T,I:EXTENDED;
    BEGIN
      SETCOLOR(TICK_COLOR);
      SETLINESTYLE(0,0,1);
      T:=5.0;
      IF XTICK>10.0 THEN
        BEGIN
          I:=MIDDLEX+XTICK;
          WHILE I <= RIGHT DO
            BEGIN
              LINE(ROUND(I),ROUND(MIDDLEY-T),ROUND(I),ROUND(MIDDLEY+T));
              I:=I+XTICK;
            END;
          I:=MIDDLEX-XTICK;
          WHILE I >= LEFT DO
            BEGIN
              LINE(ROUND(I),ROUND(MIDDLEY-T),ROUND(I),ROUND(MIDDLEY+T));
              I:=I-XTICK;
            END;
        END;
      IF YTICK>10.0 THEN
        BEGIN
          I:=MIDDLEY+YTICK;
          WHILE I <= BOTTOM DO
            BEGIN
              LINE(ROUND(MIDDLEX-T),ROUND(I),ROUND(MIDDLEX+T),ROUND(I));
              I:=I+YTICK;
            END;
          I:=MIDDLEY-YTICK;
          WHILE I >= TOP DO
            BEGIN
              LINE(ROUND(MIDDLEX-T),ROUND(I),ROUND(MIDDLEX+T),ROUND(I));
              I:=I-YTICK;
            END;
        END;
    END;

    PROCEDURE PLOT_POINTS;
      VAR X,Y:EXTENDED;
      XP,YP:EXTENDED;
      BEGIN
        X:=LEFTX;
        WHILE ((X<=RIGHTX) AND (NOT KEYPRESSED))  DO
          BEGIN
            CURRENTX:=X;
            UNDEFINED:=FALSE;
            PARSE_POSTFIX;
            Y:=NUMBER_STACK.LIST[1];
            XP:=X*XTICK+MIDDLEX;
            YP:=-Y*YTICK+MIDDLEY;
            IF NOT UNDEFINED THEN
              BEGIN
                IF (YP>TOP)AND(YP<BOTTOM) THEN
                  BEGIN
                    PUTPIXEL(ROUND(XP),ROUND(YP),PLOTTING_COLOR);
                    IF NOISE='1' THEN SOUND(ROUND((3*BOTTOM-YP)*SOUND_LEVEL));
                  END
                ELSE NOSOUND;
              END;
            SETCOLOR(14);
            LINE(ROUND(LEFT),ROUND(BOTTOM+20.0),ROUND(XP),ROUND(BOTTOM+20.0));
            X:=X+INCREMENT;
          END;
          NOSOUND;
      END;

    PROCEDURE OUTPUT_BORDERS;
      VAR LSTR,RSTR,TSTR,BSTR:STRING[10];
      BEGIN
        STR(LEFTX:3:2,LSTR);
        STR(RIGHTX:3:2,RSTR);
        STR(TOPY:3:2,TSTR);
        STR(BOTTOMY:3:2,BSTR);
        SETTEXTJUSTIFY(CENTERTEXT,CENTERTEXT);
        OUTTEXTXY(ROUND(MIDDLEX),ROUND(TOP-10),TSTR);
        SETTEXTJUSTIFY(CENTERTEXT,CENTERTEXT);
        OUTTEXTXY(ROUND(MIDDLEX),ROUND(BOTTOM+11),BSTR);
        SETTEXTSTYLE(0,1,1);
        SETTEXTJUSTIFY(CENTERTEXT,CENTERTEXT);
        OUTTEXTXY(ROUND(LEFT-10),ROUND(MIDDLEY),LSTR);
        SETTEXTJUSTIFY(CENTERTEXT,CENTERTEXT);
        OUTTEXTXY(ROUND(RIGHT+10),ROUND(MIDDLEY),RSTR);
      END;


    PROCEDURE DRAW;
      BEGIN
        SETGRAPHMODE(GRAPHMODE);
        SETBKCOLOR(BACKGROUND_COLOR);
        DRAW_TICKS;
        DRAW_AXIS;
        DRAW_BORDER;
        OUTPUT_BORDERS;
        SETTEXTSTYLE(2,0,6);
        SETTEXTJUSTIFY(LEFTTEXT,BOTTOMTEXT);
        OUTTEXTXY(ROUND(LEFT),ROUND(TOP-10),'Y = ');
        OUTTEXTXY(ROUND(LEFT+42),ROUND(TOP-10),INFIX);
        PLOT_POINTS;
        WAIT2;
      END;

(*******************************USER INPUT***********************************)

    PROCEDURE CHANGE_BORDERS;
      VAR LXSTR,RXSTR,TYSTR,BYSTR:STRING[10];
          SUCCESS:INTEGER;
      BEGIN
        CLEARDEVICE;
        SETTEXTSTYLE(1,0,5);SETCOLOR(WHITE);
        SETTEXTJUSTIFY(CENTERTEXT,TOPTEXT);
        OUTTEXTXY(ROUND(CENTERX),20,'DOMAIN AND RANGE ');
        SETTEXTJUSTIFY(LEFTTEXT,TOPTEXT);SETTEXTSTYLE(2,0,7);
        OUTTEXTXY(ROUND(LEFT)+15,137,'SMALLEST X = ');
        OUTTEXTXY(ROUND(LEFT)+15,186,'LARGEST  X = ');
        OUTTEXTXY(ROUND(LEFT)+15,234,'SMALLEST Y = ');
        OUTTEXTXY(ROUND(LEFT)+15,282,'LARGEST  Y = ');
        SETCOLOR(4);SETFILLSTYLE(1,4);
        PIESLICE(ROUND(LEFT),148,0,360,7);
        GOTOXY(25,10);READLN(LXSTR);
        SETCOLOR(1);SETFILLSTYLE(1,1);
        PIESLICE(ROUND(LEFT),148,0,360,7);
        SETCOLOR(4);SETFILLSTYLE(1,4);
        PIESLICE(ROUND(LEFT),197,0,360,7);
        GOTOXY(25,13);READLN(RXSTR);
        SETCOLOR(1);SETFILLSTYLE(1,1);
        PIESLICE(ROUND(LEFT),197,0,360,7);
        SETCOLOR(4);SETFILLSTYLE(1,4);
        PIESLICE(ROUND(LEFT),245,0,360,7);
        GOTOXY(25,16);READLN(BYSTR);
        SETCOLOR(1);SETFILLSTYLE(1,1);
        PIESLICE(ROUND(LEFT),245,0,360,7);
        SETCOLOR(4);SETFILLSTYLE(1,4);
        PIESLICE(ROUND(LEFT),293,0,360,7);
        GOTOXY(25,19);READLN(TYSTR);
        SETCOLOR(1);SETFILLSTYLE(1,1);
        PIESLICE(ROUND(LEFT),293,0,360,7);
        SUCCESS:=1;
        VAL(LXSTR,LEFTX,SUCCESS);
        VAL(RXSTR,RIGHTX,SUCCESS);
        VAL(BYSTR,BOTTOMY,SUCCESS);
        VAL(TYSTR,TOPY,SUCCESS);
        IF SUCCESS=0 THEN
          BEGIN
            IF ((LEFTX>=RIGHTX) OR (BOTTOMY>=TOPY)) THEN
              BEGIN
                INVALID;
                LEFTX:=-10;RIGHTX:=10.0;TOPY:=10.0;BOTTOMY:=-10.0;
              END
            ELSE SUCCESS_TONE;
          END
        ELSE
          BEGIN
            INVALID;
            LEFTX:=-10.0;RIGHTX:=10.0;TOPY:=10.0;BOTTOMY:=-10.0;
          END;

        UPDATE_VARIABLES;
        DELAY(250);
      END;

    PROCEDURE CHANGE_SOUND;
      VAR C1,C2:CHAR;
      BEGIN
        CLEARDEVICE;
        SETTEXTSTYLE(0,0,1);
        SETTEXTJUSTIFY(LEFTTEXT,TOPTEXT);
        OUTTEXTXY(ROUND(LEFT),ROUND(BOTTOM+27),'ESCAPE FOR MAIN MENU');
        SETTEXTSTYLE(1,0,5);
        SETCOLOR(WHITE);
        SETTEXTJUSTIFY(CENTERTEXT,TOPTEXT);
        OUTTEXTXY(ROUND(CENTERX),20,'SOUND  ');
        SETTEXTSTYLE(2,0,7);SETTEXTJUSTIFY(LEFTTEXT,TOPTEXT);
        OUTTEXTXY(ROUND(LEFT)+250,200,'ON');
        OUTTEXTXY(ROUND(LEFT)+250,250,'OFF');
        SETCOLOR(4);SETFILLSTYLE(1,4);
        IF NOISE='1' THEN
          PIESLICE(ROUND(LEFT)+225,210,0,360,7)
        ELSE
          PIESLICE(ROUND(LEFT)+225,262,0,360,7);
        REPEAT
          C1:=READKEY;
          IF C1=#0 THEN
          BEGIN
            C2:=READKEY;
            CASE ORD(C2) OF
              72: BEGIN
                    SETCOLOR(1);SETFILLSTYLE(1,1);
                    PIESLICE(ROUND(LEFT)+225,262,0,360,7);
                    DELAY(400);
                    SETCOLOR(4);SETFILLSTYLE(1,4);
                    PIESLICE(ROUND(LEFT)+225,210,0,360,7);
                    SUCCESS_TONE;
                  END;
              80: BEGIN
                    SETCOLOR(1);SETFILLSTYLE(1,1);
                    PIESLICE(ROUND(LEFT)+225,210,0,360,9);
                    DELAY(400);
                    SETCOLOR(4);SETFILLSTYLE(1,4);
                    PIESLICE(ROUND(LEFT)+225,262,0,360,7);
                    SUCCESS_TONE;
                  END;
            END;
          END;
        IF ORD(C2)=80 THEN NOISE:='2';
        IF ORD(C2)=72 THEN NOISE:='1';
        UNTIL C1=CHR(27);
      END;

    PROCEDURE CHANGE_FUNCTION;
      VAR I:INTEGER;
      BEGIN
        CLEARDEVICE;
        SETTEXTSTYLE(1,0,5);
        SETCOLOR(WHITE);
        SETTEXTJUSTIFY(CENTERTEXT,TOPTEXT);
        OUTTEXTXY(ROUND(CENTERX),20,'FUNCTION Y=F(X) ');
        SETTEXTSTYLE(2,0,7);SETTEXTJUSTIFY(LEFTTEXT,TOPTEXT);
        OUTTEXTXY(ROUND(LEFT),120,'CURRENT FUNCTION   Y = ');
        OUTTEXTXY(ROUND(LEFT)+275,120,INFIX);
        OUTTEXTXY(ROUND(LEFT),150,'PLEASE ENTER NEW FUNCTION.');
        OUTTEXTXY(ROUND(LEFT)+170,248,'Y = ');
        GOTOXY(32,17);
        I:=0;
        INFIX:='                                                                                                    ';
        WHILE NOT EOLN DO
          BEGIN
            I:=I+1;
            READ(INFIX[I]);
          END;
          READLN;
        PARSE_INFIX;
        IF NOT VALID_INFIX THEN
          BEGIN
            INVALID;
            INFIX:='SX.                                                                                                 ';
            PARSE_INFIX;
          END;
      END;

    PROCEDURE CHANGE_RESOLUTION;
      VAR RSTR:STRING[10];SUCCESS:INTEGER;
      BEGIN
        CLEARDEVICE;
        STR(INCREMENT:5:5,RSTR);
        SETTEXTSTYLE(1,0,5);
        SETCOLOR(WHITE);
        SETTEXTJUSTIFY(CENTERTEXT,TOPTEXT);
        OUTTEXTXY(ROUND(CENTERX),20,'RESOLUTION ');
        SETTEXTSTYLE(2,0,7);
        SETTEXTJUSTIFY(LEFTTEXT,TOPTEXT);
        OUTTEXTXY(ROUND(LEFT),200,'The current resolution is ');
        OUTTEXTXY(ROUND(LEFT+300),200,RSTR);
        OUTTEXTXY(ROUND(LEFT),233,'Please enter new resolution ');
        GOTOXY(45,16);
        SUCCESS:=1;
        READLN(RSTR);
        VAL(RSTR,INCREMENT,SUCCESS);
        IF SUCCESS = 0 THEN
          BEGIN
            IF INCREMENT<=0 THEN
              BEGIN
                INVALID;
                INCREMENT:=1.0;
              END
          END
        ELSE
          BEGIN
            INVALID;
            INCREMENT:=1.0;
          END;
        DELAY(250);
      END;

    PROCEDURE DIRECTIONS;
      VAR I,J:INTEGER;
        BEGIN
        I:=100;
        J:=ROUND(LEFT);
        CLEARDEVICE;
        SETBKCOLOR(1);
        SETTEXTSTYLE(4,0,5);
        SETTEXTJUSTIFY(CENTERTEXT,TOPTEXT);
        SETCOLOR(15);
        OUTTEXTXY(TRUNC(CENTERX),20,'Directions');
        SETTEXTSTYLE(2,0,5);
        SETTEXTJUSTIFY(LEFTTEXT,TOPTEXT);
        OUTTEXTXY(J,I,    'S = SINE             Y = SX.');
        OUTTEXTXY(J,I+20, 'C = COSINE           Y = CX.');
        OUTTEXTXY(J,I+40, 'T = TANGENT          Y = TX.');
        OUTTEXTXY(J,I+60, 'L = NATURAL LOG      Y = LX.');
        OUTTEXTXY(J,I+80, 'E = E TO THE X       Y = EX.');
        OUTTEXTXY(J,I+100,'^ = EXPONENT         Y = X^2. ');
        OUTTEXTXY(J,I+120,'N = NEGATIVE         Y = N1*X^2.');
        OUTTEXTXY(J,I+140,'A = ABSOLUTE VALUE   Y = AX.');
        WAIT2;
        END;


    PROCEDURE TITLE;
      BEGIN
        SETGRAPHMODE(GRAPHMODE);
        CLEARDEVICE;
        SETBKCOLOR(1);
        SETCOLOR(15);
        SETTEXTSTYLE(4,0,5);
        SETTEXTJUSTIFY(CENTERTEXT,CENTERTEXT);
        OUTTEXTXY(TRUNC(CENTERX),TRUNC(CENTERY)-120,'Created by ');
        OUTTEXTXY(TRUNC(CENTERX),TRUNC(CENTERY)-20,'Michael ');
        OUTTEXTXY(TRUNC(CENTERX),TRUNC(CENTERY)+80,'Mesnier ');
        DELAY(5000);
      END;


    PROCEDURE MENU;
      VAR C:CHAR;
      BEGIN
      REPEAT
        CLEARDEVICE;
        SETBKCOLOR(BLUE);
        SETCOLOR(WHITE);
        SETTEXTSTYLE(4,0,5);
        SETTEXTJUSTIFY(CENTERTEXT,BOTTOMTEXT);
        OUTTEXTXY(ROUND(CENTERX),50,'Main Menu  ');
        SETTEXTSTYLE(1,0,3);
        SETTEXTJUSTIFY(LEFTTEXT,BOTTOMTEXT);
        OUTTEXTXY(ROUND(CENTERX-140),120,'1. Graph Function');
        OUTTEXTXY(ROUND(CENTERX-140),170,'2. New Function');
        OUTTEXTXY(ROUND(CENTERX-140),220,'3. Domain and Range');
        OUTTEXTXY(ROUND(CENTERX-140),270,'4. Resolution');
        OUTTEXTXY(ROUND(CENTERX-140),320,'5. Sound');
        OUTTEXTXY(ROUND(CENTERX-140),370,'6. Directions');
        OUTTEXTXY(ROUND(CENTERX-140),420,'(Q)uit');
        C:=READKEY;
        SUCCESS_TONE;
        DELAY(250);
        CASE ORD(C) OF
          49:DRAW;
          50:CHANGE_FUNCTION;
          51:CHANGE_BORDERS;
          52:CHANGE_RESOLUTION;
          53:CHANGE_SOUND;
          54:DIRECTIONS;
        END;
        if C=CHR(81) then
          break;
        if C=CHR(113) then
          break;
      UNTIL False
      END;

 BEGIN
   CLRSCR;
   INITIALIZE_VARIABLES;
   TITLE;
   MENU;
   CLOSEGRAPH;
   RESTORECRTMODE;
 END.