       IDENTIFICATION DIVISION.
       PROGRAM-ID. TXNHIST.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-CUSTOMER-ID        PIC X(10).
       01  HV-ACCOUNT-ID         PIC X(12).
       01  HV-TXN-DATE           DATE.
       01  HV-TXN-TYPE           PIC X(10).
       01  HV-AMOUNT             PIC S9(9)V99 COMP-3.
       01  HV-DESCRIPTION        PIC X(100).
       EXEC SQL END DECLARE SECTION END-EXEC.

       01  WS-RESPONSE           PIC X(100).
       01  WS-COUNT              PIC 9(4) VALUE ZERO.

       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  LK-CUSTOMER-ID    PIC X(10).
           05  LK-ACCOUNT-ID     PIC X(12).

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           MOVE LK-CUSTOMER-ID TO HV-CUSTOMER-ID
           MOVE LK-ACCOUNT-ID  TO HV-ACCOUNT-ID

           DISPLAY "RETRIEVING TRANSACTION HISTORY FOR ACCOUNT: " HV-ACCOUNT-ID

           EXEC SQL
               DECLARE TXN_CURSOR CURSOR FOR
               SELECT TXN_DATE, TXN_TYPE, AMOUNT, DESCRIPTION
               FROM TRANSACTIONS
               WHERE ACCOUNT_ID = :HV-ACCOUNT-ID
                 AND CUSTOMER_ID = :HV-CUSTOMER-ID
               ORDER BY TXN_DATE DESC
           END-EXEC

           EXEC SQL OPEN TXN_CURSOR END-EXEC

           PERFORM UNTIL SQLCODE NOT = 0
               EXEC SQL
                   FETCH TXN_CURSOR INTO
                       :HV-TXN-DATE,
                       :HV-TXN-TYPE,
                       :HV-AMOUNT,
                       :HV-DESCRIPTION
               END-EXEC

               IF SQLCODE = 0
                   ADD 1 TO WS-COUNT
                   DISPLAY "------------------------------"
                   DISPLAY "DATE        : " HV-TXN-DATE
                   DISPLAY "TYPE        : " HV-TXN-TYPE
                   DISPLAY "AMOUNT      : " HV-AMOUNT
                   DISPLAY "DESCRIPTION : " HV-DESCRIPTION
                   DISPLAY "------------------------------"
               END-IF
           END-PERFORM

           EXEC SQL CLOSE TXN_CURSOR END-EXEC

           IF SQLCODE = 100 AND WS-COUNT = 0
               MOVE 'NO TRANSACTIONS FOUND' TO WS-RESPONSE
           ELSE
               MOVE 'TRANSACTION HISTORY RETRIEVED' TO WS-RESPONSE
           END-IF

           DISPLAY WS-RESPONSE
           GOBACK.
