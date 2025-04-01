       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTMSTR.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z16.
       OBJECT-COMPUTER. IBM-Z16.

       DATA DIVISION.

       WORKING-STORAGE SECTION.
       01  WS-CUSTOMER-ID        PIC X(10).
       01  WS-FUNCTION            PIC X(06).
           88  FUNC-CREATE        VALUE 'CREATE'.
           88  FUNC-READ          VALUE 'READ  '.
           88  FUNC-UPDATE        VALUE 'UPDATE'.
           88  FUNC-DELETE        VALUE 'DELETE'.

       01  WS-RESPONSE            PIC X(100).
       01  WS-RETURN-CODE         PIC 9(04) COMP.

       EXEC SQL INCLUDE SQLCA END-EXEC.
       EXEC SQL INCLUDE CUSTMST END-EXEC.

       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  LK-CUSTOMER-ID     PIC X(10).
           05  LK-NAME            PIC X(50).
           05  LK-ADDRESS         PIC X(100).
           05  LK-PHONE           PIC X(15).
           05  LK-EMAIL           PIC X(50).
           05  LK-SSN             PIC X(11).
           05  LK-FUNCTION        PIC X(06).

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           MOVE LK-CUSTOMER-ID TO WS-CUSTOMER-ID.
           MOVE LK-FUNCTION    TO WS-FUNCTION.

           EVALUATE TRUE
               WHEN FUNC-CREATE
                   PERFORM CREATE-CUSTOMER
               WHEN FUNC-READ
                   PERFORM READ-CUSTOMER
               WHEN FUNC-UPDATE
                   PERFORM UPDATE-CUSTOMER
               WHEN FUNC-DELETE
                   PERFORM DELETE-CUSTOMER
               WHEN OTHER
                   MOVE 'INVALID FUNCTION' TO WS-RESPONSE
           END-EVALUATE.

           GOBACK.

       CREATE-CUSTOMER.
           EXEC SQL
               INSERT INTO CUSTOMER_MASTER
                    (CUSTOMER_ID, NAME, ADDRESS, PHONE, EMAIL, SSN)
               VALUES (:LK-CUSTOMER-ID, :LK-NAME, :LK-ADDRESS,
                       :LK-PHONE, :LK-EMAIL, :LK-SSN)
           END-EXEC.

           IF SQLCODE = 0
               MOVE 'CUSTOMER CREATED SUCCESSFULLY' TO WS-RESPONSE
           ELSE
               MOVE 'ERROR CREATING CUSTOMER' TO WS-RESPONSE
               MOVE SQLCODE TO WS-RETURN-CODE
           END-IF.
           .

       READ-CUSTOMER.
           EXEC SQL
               SELECT NAME, ADDRESS, PHONE, EMAIL, SSN
               INTO :LK-NAME, :LK-ADDRESS, :LK-PHONE, :LK-EMAIL, :LK-SSN
               FROM CUSTOMER_MASTER
               WHERE CUSTOMER_ID = :LK-CUSTOMER-ID
           END-EXEC.

           IF SQLCODE = 0
               MOVE 'CUSTOMER FOUND' TO WS-RESPONSE
           ELSE
               MOVE 'CUSTOMER NOT FOUND' TO WS-RESPONSE
               MOVE SQLCODE TO WS-RETURN-CODE
           END-IF.
           .

       UPDATE-CUSTOMER.
           EXEC SQL
               UPDATE CUSTOMER_MASTER
               SET NAME = :LK-NAME,
                   ADDRESS = :LK-ADDRESS,
                   PHONE = :LK-PHONE,
                   EMAIL = :LK-EMAIL,
                   SSN = :LK-SSN
               WHERE CUSTOMER_ID = :LK-CUSTOMER-ID
           END-EXEC.

           IF SQLCODE = 0
               MOVE 'CUSTOMER UPDATED SUCCESSFULLY' TO WS-RESPONSE
           ELSE
               MOVE 'ERROR UPDATING CUSTOMER' TO WS-RESPONSE
               MOVE SQLCODE TO WS-RETURN-CODE
           END-IF.
           .

       DELETE-CUSTOMER.
           EXEC SQL
               DELETE FROM CUSTOMER_MASTER
               WHERE CUSTOMER_ID = :LK-CUSTOMER-ID
           END-EXEC.

           IF SQLCODE = 0
               MOVE 'CUSTOMER DELETED SUCCESSFULLY' TO WS-RESPONSE
           ELSE
               MOVE 'ERROR DELETING CUSTOMER' TO WS-RESPONSE
               MOVE SQLCODE TO WS-RETURN-CODE
           END-IF.
           .
