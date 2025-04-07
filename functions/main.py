from firebase_functions import https_fn
from firebase_admin import initialize_app
import json

from auth_service import AuthService, AuthServiceError, DummyEmailSender, SendGridEmailSender

initialize_app()

@https_fn.on_call()
def hello_world(request: https_fn.CallableRequest) -> str:
    return "Hello world from on_call!"


@https_fn.on_call()
def send_auth_code_on_call(request: https_fn.CallableRequest) -> dict:
    """Sends an authentication code via AuthService (Callable)."""

    email = request.data.get("email")
    service = request.data.get("service")

    if not email or not service:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="The function must be called with the 'email' and 'service' arguments.",
        )

    return send_auth_code(email, service)

def send_auth_code(email: str, service: str) -> dict:
    """Handles sending an authentication code via AuthService.
    Returns a result dictionary on success, raises HttpsError on failure.
    """

    try:
        if service == "sengrid":
            auth_service = AuthService()
            result = auth_service.process_auth_request(email, email_sender=SendGridEmailSender())
            return result
        elif service == "dummy":
            auth_service = AuthService()
            result = auth_service.process_auth_request(email, email_sender=DummyEmailSender())
            return result
        else:
            raise ValueError("Invalid service specified.")


    except AuthServiceError as e:
        print(f"AuthService error for {email}: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message=f"Authentication service failed: {e}",
        )
    except ValueError as e:
        print(f"Invalid argument for {email}: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message=str(e),
        )
    except Exception as e:
        print(f"Unexpected error processing request for {email}: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message="An unexpected error occurred.",
        )

@https_fn.on_call()
def verify_auth_code_on_call(request: https_fn.CallableRequest) -> dict:
    """Verifies an authentication code via AuthService (Callable)."""

    verification_id = request.data.get("verification_id")
    user_code = request.data.get("code")

    if not verification_id or not user_code:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="The function must be called with 'verification_id' and 'code' arguments.",
        )

    try:
        auth_service = AuthService()
        result = auth_service.verify_code(verification_id, user_code)
        if result.get("status") == "success":
             print(f"Successfully verified code for verification_id: {verification_id}")
             return {"status": "success", "user_id": result.get("user_id"), "message": "Code verified successfully."}
        else:
             print(f"Code verification failed for {verification_id}: {result.get('message')}")
             raise https_fn.HttpsError(
                 code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
                 message=result.get("message", "Code verification failed.")
             )

    except AuthServiceError as e:
        print(f"AuthService error verifying code for {verification_id}: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message=f"Authentication service failed during verification: {e}",
        )
    except Exception as e:
        print(f"Unexpected error verifying code for {verification_id}: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message="An unexpected error occurred during code verification.",
        )

@https_fn.on_call()
def delete_auth_code_on_call(request: https_fn.CallableRequest) -> dict:
    """Deletes an authentication code via AuthService (Callable)."""

    verification_id = request.data.get("verification_id")

    if not verification_id:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="The function must be called with the 'verification_id' argument.",
        )

    try:
        auth_service = AuthService()
        auth_service.delete_auth_code(verification_id)
        print(f"Successfully deleted auth code for verification_id: {verification_id}")
        return {"message": "Authentication code successfully deleted."}

    except AuthServiceError as e:
        print(f"AuthService error deleting code for {verification_id}: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message=f"Authentication service failed: {e}",
        )
    except Exception as e:
        print(f"Unexpected error deleting code for {verification_id}: {e}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message="An unexpected error occurred while deleting the code.",
        )