import os
import uuid
import secrets
from dotenv import load_dotenv
from abc import ABC, abstractmethod
from firebase_admin import firestore
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from datetime import datetime, timedelta, timezone

class EmailSender(ABC):
    """Abstract base class for email sending functionality."""
    @abstractmethod
    def send_email(self, to_email: str, subject: str, html_content: str) -> None:
        """Send an email with the given parameters."""
        pass

class SendGridEmailSender(EmailSender):
    """SendGrid implementation of EmailSender."""
    def __init__(self):
        load_dotenv()
        self.api_key = os.getenv("SENDGRID_API_KEY")
        self.sender_email = os.getenv("SENDGRID_SENDER_EMAIL")
        if not self.api_key or not self.sender_email:
            raise ValueError("SendGrid API key and sender email are required")

    def send_email(self, to_email: str, subject: str, html_content: str) -> None:
        message = Mail(
            from_email=self.sender_email,
            to_emails=to_email,
            subject=subject,
            html_content=html_content,
        )

        try:
            sg = SendGridAPIClient(self.api_key)
            response = sg.send(message)

            if response.status_code >= 300:
                raise AuthServiceError(f"SendGrid failed to send email. Status: {response.status_code}")
        except Exception as e:
            raise AuthServiceError(f"Failed to send email: {e}") from e

class DummyEmailSender(EmailSender):
    """Dummy implementation of EmailSender for testing."""
    def send_email(self, to_email: str, subject: str, html_content: str) -> None:
        print(f"Dummy email sent to: {to_email}")
        print(f"Subject: {subject}")
        print(f"Content: {html_content}")

class AuthServiceError(Exception):
    """Custom exception for AuthService errors."""
    pass

class AuthService:
    def __init__(self):
        self.db = firestore.client()
        self.CODE_VALIDITY_MINUTES = 10

    def generate_code(self) -> str:
        """Generates a 6-digit cryptographically secure random code."""
        code = secrets.randbelow(900000) + 100000
        return str(code)

    def save_code_to_firestore(self, email: str, code: str) -> str:
        """Saves the email and code to Firestore under a generated UUID.
        Returns the generated UUID as verification_id.
        """
        verification_id = str(uuid.uuid4())
        try:
            doc_ref = self.db.collection("auth_codes").document(verification_id)
            doc_ref.set({
                "email": email,
                "code": code,
                "timestamp": firestore.SERVER_TIMESTAMP
            })
            return verification_id
        except Exception as e:
            print(f"Error saving code to Firestore for {email} (ID: {verification_id}): {e}")
            raise AuthServiceError(f"Failed to save code for {email}: {e}") from e

    def send_email_with_code(self, email: str, code: str, email_sender: EmailSender):
        """Sends the code to the specified email using configured email sender."""
        try:
            email_sender.send_email(
                to_email=email,
                subject="Your Authentication Code",
                html_content=f"<strong>Your authentication code is: {code}</strong>"
            )
        except Exception as e:
            print(f"Error sending email to {email}: {e}")
            raise AuthServiceError(f"Failed to send email to {email}: {e}") from e

    def process_auth_request(self, email: str, email_sender: EmailSender) -> dict:
        """Handles the full auth code process: generate, save, send.
        Returns a dictionary containing the status, message, and verification_id.
        """
        if not email:
            raise ValueError("Email cannot be empty.")

        code = self.generate_code()

        try:
            verification_id = self.save_code_to_firestore(email, code)
            self.send_email_with_code(email, code, email_sender)
            return {
                "status": "success",
                "message": "Verification code sent successfully.",
                "verification_id": verification_id
            }
        except AuthServiceError as e:
            print(f"AuthServiceError during processing for {email}: {e}")
            raise
        except Exception as e:
            print(f"Unexpected error during processing for {email}: {e}")
            raise AuthServiceError(f"An unexpected error occurred for {email}: {e}") from e

    def verify_code(self, verification_id: str, user_code: str) -> dict:
        """Verifies the provided code against the stored one using verification_id.
        If valid, creates a user record and deletes the code.
        Returns a dict with status and user_id on success, or status and message on error.
        """
        try:
            doc_ref = self.db.collection("auth_codes").document(verification_id)
            doc_snapshot = doc_ref.get()

            if not doc_snapshot.exists:
                print(f"Verification failed: No record found for ID {verification_id}")
                return {"status": "error", "message": "Invalid or expired verification ID."}

            stored_data = doc_snapshot.to_dict()
            stored_code = stored_data.get("code")
            timestamp = stored_data.get("timestamp")
            email = stored_data.get("email")

            if stored_code != user_code:
                print(f"Verification failed: Code mismatch for ID {verification_id}")
                return {"status": "error", "message": "Incorrect verification code."}

            if timestamp.tzinfo is None:
                timestamp = timestamp.replace(tzinfo=timezone.utc)

            expiration_time = timestamp + timedelta(minutes=self.CODE_VALIDITY_MINUTES)
            now = datetime.now(timezone.utc)

            if now > expiration_time:
                print(f"Verification failed: Code expired for ID {verification_id}")
                doc_ref.delete()
                return {"status": "error", "message": "Verification code has expired."}

            if not email:
                print(f"Error: Email missing in verification record {verification_id}")
                return {"status": "error", "message": "Internal error: User email not found."}

            user_id = str(uuid.uuid4())
            user_doc_ref = self.db.collection("users").document(user_id)
            user_doc_ref.set({
                "email": email,
                "verifiedEmail": True,
                "createdAt": firestore.SERVER_TIMESTAMP
            })
            print(f"User record created for {email} with ID {user_id}")

            doc_ref.delete()
            print(f"Verification code deleted for ID {verification_id}")

            return {"status": "success", "user_id": user_id}

        except AuthServiceError as e:
            print(f"AuthServiceError during code verification for ID {verification_id}: {e}")
            return {"status": "error", "message": "An error occurred during verification."}
        except Exception as e:
            print(f"Unexpected error during code verification for ID {verification_id}: {e}")
            return {"status": "error", "message": "An unexpected error occurred."}

    def delete_auth_code(self, verification_id: str):
        """Deletes the authentication code document from Firestore."""
        if not verification_id:
            raise ValueError("Verification ID cannot be empty.")

        try:
            doc_ref = self.db.collection("auth_codes").document(verification_id)
            doc_snapshot = doc_ref.get()

            if not doc_snapshot.exists:
                print(f"Auth code document not found for ID {verification_id}. Assuming deleted.")
                return

            doc_ref.delete()
            print(f"Successfully deleted auth code document for ID {verification_id}")

        except Exception as e:
            print(f"Error deleting auth code document for ID {verification_id}: {e}")
            raise AuthServiceError(f"Failed to delete code for {verification_id}: {e}") from e