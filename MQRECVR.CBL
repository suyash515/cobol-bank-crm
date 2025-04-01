       IDENTIFICATION DIVISION.
       PROGRAM-ID. MQRECVR.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       * MQ constants
       01  MQ-HCONN                PIC S9(9) COMP-5 VALUE 0.
       01  MQ-HOBJ                 PIC S9(9) COMP-5 VALUE 0.
       01  MQ-COMPCODE             PIC S9(9) COMP-5 VALUE 0.
       01  MQ-REASON               PIC S9(9) COMP-5 VALUE 0.
       01  MQ-OPEN-OPTIONS         PIC S9(9) COMP-5 VALUE 0.
       01  MQ-GMO-OPTIONS          PIC S9(9) COMP-5 VALUE 0.
       01  MQ-MSG-BUFFER           PIC X(1024).
       01  MQ-MSG-LENGTH           PIC S9(9) COMP-5 VALUE 1024.

       01  WS-RECEIVED-MESSAGE     PIC X(1024).
       01  WS-RESP-TEXT            PIC X(100).

       01  MQOD.
           05  MQOD-STRUCTID       PIC X(4) VALUE 'OD  '.
           05  MQOD-VERSION        PIC S9(9) COMP-5 VALUE 1.
           05  MQOD-OBJECTNAME     PIC X(48) VALUE SPACES.
           05  MQOD-OBJECTQ-MGR    PIC X(48) VALUE SPACES.

       01  MQMD.
           05  MQMD-STRUCTID       PIC X(4) VALUE 'MD  '.
           05  MQMD-VERSION        PIC S9(9) COMP-5 VALUE 1.
           05  MQMD-FORMAT         PIC X(8) VALUE 'MQSTR   '.
           05  MQMD-MSGTYPE        PIC S9(9) COMP-5 VALUE 8.
           05  MQMD-EXPIRY         PIC S9(9) COMP-5 VALUE -1.
           05  MQMD-ENCODING       PIC S9(9) COMP-5 VALUE 273.
           05  MQMD-CODEDCHARSETID PIC S9(9) COMP-5 VALUE 819.
           05  MQMD-MSGID          PIC X(24).
           05  MQMD-CORRELID       PIC X(24).

       01  MQGMO.
           05  MQGMO-STRUCTID      PIC X(4) VALUE 'GMO '.
           05  MQGMO-VERSION       PIC S9(9) COMP-5 VALUE 1.
           05  MQGMO-OPTIONS-FLAG  PIC S9(9) COMP-5 VALUE 0.
           05  MQGMO-WAITINTERVAL  PIC S9(9) COMP-5 VALUE 5000.

       PROCEDURE DIVISION.

       MAIN-LOGIC.

           MOVE 'CRM.INCOMING.QUEUE' TO MQOD-OBJECTNAME.
           MOVE 8192 TO MQ-OPEN-OPTIONS.        *> MQOO_INPUT_SHARED
           MOVE 0 TO MQ-COMPCODE MQ-REASON.

           CALL 'MQOPEN' USING MQ-HCONN
                               MQOD
                               MQ-OPEN-OPTIONS
                               MQ-HOBJ
                               MQ-COMPCODE
                               MQ-REASON.

           IF MQ-COMPCODE NOT = 0
               MOVE 'FAILED TO OPEN MQ QUEUE' TO WS-RESP-TEXT
               DISPLAY WS-RESP-TEXT
               GOBACK
           END-IF.

           MOVE 0 TO MQ-COMPCODE MQ-REASON.

           CALL 'MQGET' USING MQ-HCONN
                              MQ-HOBJ
                              MQMD
                              MQGMO
                              MQ-MSG-LENGTH
                              MQ-MSG-BUFFER
                              MQ-MSG-LENGTH
                              MQ-COMPCODE
                              MQ-REASON.

           IF MQ-COMPCODE = 0
               MOVE MQ-MSG-BUFFER TO WS-RECEIVED-MESSAGE
               DISPLAY "RECEIVED MQ MESSAGE:"
               DISPLAY WS-RECEIVED-MESSAGE
           ELSE
               MOVE 'NO MESSAGE RECEIVED OR MQ ERROR' TO WS-RESP-TEXT
               DISPLAY WS-RESP-TEXT
               DISPLAY "MQGET REASON CODE: " MQ-REASON
           END-IF.

           CALL 'MQCLOSE' USING MQ-HCONN
                                MQ-HOBJ
                                0
                                MQ-COMPCODE
                                MQ-REASON.

           CALL 'MQDISC' USING MQ-HCONN
                               MQ-COMPCODE
                               MQ-REASON.

           GOBACK.
