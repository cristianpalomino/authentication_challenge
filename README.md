# Authentication Challenge App

A Flutter application demonstrating user email verification and validation.

## Features

*   **Email Validation:** Validates email format before sending verification codes.
*   **Verification Code Sending:** Sends authentication codes to user emails.
*   **Code Verification:** Validates the 6-digit code entered by users.
*   **Verification Cancellation:** Allows users to cancel the verification process.
*   **Error Handling:** Provides clear feedback for various error scenarios.
*   **Loading States:** Manages loading states during asynchronous operations.

## Architecture

This project follows a layered MVVM-like architecture, primarily within the `lib` directory, promoting separation of concerns and maintainability. It utilizes the Riverpod package for state management and dependency injection, and GoRouter for navigation.

Firebase (Authentication and Cloud Functions) is used as the backend for authentication logic and user management.

## Firebase Functions

The project uses Firebase Cloud Functions to handle authentication logic. The following functions are implemented:

1. **hello_world**
   * A simple test function that returns "Hello world from on_call!"
   * Used to verify the Cloud Functions setup is working correctly

2. **send_auth_code_on_call**
   * Sends an authentication code to the provided email address
   * Requires `email` and `service` parameters
   * Supports two email sending services: "sengrid" for SendGrid and "dummy" for testing
   * Returns a verification ID and status information

3. **verify_auth_code_on_call**
   * Verifies the authentication code entered by the user
   * Requires `verification_id` and `code` parameters
   * Returns success status and user ID when verification succeeds
   * Returns appropriate error messages when verification fails

4. **delete_auth_code_on_call**
   * Deletes an authentication code from the system
   * Requires `verification_id` parameter
   * Used when canceling the verification process
   * Returns confirmation message upon successful deletion

These functions work with the `AuthService` class to manage the authentication flow, including code generation, storage, verification, and cleanup.

## Setup and Running

Follow these steps to get the application running:

1.  **Prerequisites:**
    *   Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
    *   Ensure you have a Firebase project set up.
    *   Enable Firebase Authentication (e.g., Email/Password).
    *   If using Cloud Functions, deploy the necessary functions to your Firebase project.
    *   Configure your Flutter app with Firebase using `flutterfire configure`.

2.  **Clone the repository**
    ```bash
    git clone https://github.com/cristianpalomino/authentication_challenge
    cd authentication_challenge
    ```

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the app (e.g., on Chrome):**
    Make sure Chrome is installed or an emulator/device is running. Then, run:
    ```bash
    flutter run -d chrome
    ```
    This will build and launch the application.

5.  **Running Unit Tests:**
    To run the unit tests included in the project, use:
    ```bash
    flutter test
    ```

## Media

**Screenshots:**

![Screenshot 1](media/Screenshot%202025-04-07%20at%209.04.46%E2%80%AFPM.png)
![Screenshot 2](media/Screenshot%202025-04-07%20at%209.04.53%E2%80%AFPM.png)
![Screenshot 3](media/Screenshot%202025-04-07%20at%209.04.59%E2%80%AFPM.png)
![Screenshot 4](media/Screenshot%202025-04-07%20at%209.05.07%E2%80%AFPM.png)
![Screenshot 5](media/Screenshot%202025-04-07%20at%209.05.23%E2%80%AFPM.png)
![Screenshot 6](media/Screenshot%202025-04-07%20at%209.07.10%E2%80%AFPM.png)

**Video Recording:**

[View Screen Recording](media/Simulator%20Screen%20Recording%20-%20iPhone%20SE%20(3rd%20generation)%20-%202025-04-07%20at%2021.05.50.mp4)

