       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATAPURGE.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-CUSTOMER-ID        PIC X(10).
       EXEC SQL END DECLARE SECTION END-EXEC.

       01  WS-RESPONSE           PIC X(100).
       01  WS-CONFIRMATION       PIC X VALUE SPACES.
           88  CONFIRM-YES       VALUE 'Y'.
           88  CONFIRM-NO        VALUE 'N'.

       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  LK-CUSTOMER-ID    PIC X(10).
           05  LK-CONFIRM-FLAG   PIC X(01).

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           MOVE LK-CUSTOMER-ID TO HV-CUSTOMER-ID
           MOVE LK-CONFIRM-FLAG TO WS-CONFIRMATION

           IF CONFIRM-YES
               PERFORM PURGE-CUSTOMER-DATA
           ELSE IF CONFIRM-NO
               MOVE 'DATA PURGE CANCELLED BY USER' TO WS-RESPONSE
               DISPLAY WS-RESPONSE
           ELSE
               MOVE 'INVALID CONFIRMATION FLAG' TO WS-RESPONSE
               DISPLAY WS-RESPONSE
           END-IF

           GOBACK.

       PURGE-CUSTOMER-DATA.
           DISPLAY "INITIATING DATA PURGE FOR CUSTOMER: " HV-CUSTOMER-ID

           EXEC SQL
               DELETE FROM CUSTOMER_INTERACTIONS
               WHERE CUSTOMER_ID = :HV-CUSTOMER-ID
           END-EXEC

           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
               DISPLAY "ERROR PURGING INTERACTIONS: " SQLCODE
           END-IF

           EXEC SQL
               DELETE FROM CUSTOMER_COMPLAINTS
               WHERE CUSTOMER_ID = :HV-CUSTOMER-ID
           END-EXEC

           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
               DISPLAY "ERROR PURGING COMPLAINTS: " SQLCODE
           END-IF

           EXEC SQL
               DELETE FROM CUSTOMER_RELATIONSHIP
               WHERE PRIMARY_CUSTOMER_ID = :HV-CUSTOMER-ID
                  OR RELATED_CUSTOMER_ID = :HV-CUSTOMER-ID
           END-EXEC

           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
               DISPLAY "ERROR PURGING RELATIONSHIPS: " SQLCODE
           END-IF

           EXEC SQL
               DELETE FROM ACCOUNTS
               WHERE CUSTOMER_ID = :HV-CUSTOMER-ID
           END-EXEC

           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
               DISPLAY "ERROR PURGING ACCOUNTS: " SQLCODE
           END-IF

           EXEC SQL
               DELETE FROM CUSTOMER_MASTER
               WHERE CUSTOMER_ID = :HV-CUSTOMER-ID
           END-EXEC

           IF SQLCODE = 0
               MOVE 'CUSTOMER DATA PURGED SUCCESSFULLY' TO WS-RESPONSE
           ELSE
               MOVE 'ERROR PURGING CUSTOMER RECORD' TO WS-RESPONSE
               DISPLAY "SQLCODE: " SQLCODE
           END-IF

           DISPLAY WS-RESPONSE.
