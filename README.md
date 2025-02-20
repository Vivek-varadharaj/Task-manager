# Task Manager App

## Overview

Task Manager App is a Flutter-based application designed to help users efficiently manage their tasks through a clean and intuitive interface. The app supports both online and offline task management with extended features such as due date selection, priority indicators, and interactive swipe actions. It is built using a combination of Clean Architecture and MVVM, leveraging Provider for effective state management.

## APK Download

You can download the APK for the app from the following link:  
[APK Download](https://drive.google.com/file/d/1wvK8vVSTGh2XUz-1imxv8Uba9h-4bzP4/view?usp=drive_link)

## GitHub Repository

The project is fully implemented and available on GitHub. The main branch contains all the latest updates.  
[Task Manager Repository](https://github.com/Vivek-varadharaj/Task-manager)

## Flutter Version Details

- **Flutter:** 3.24.3 • channel stable ([Flutter GitHub](https://github.com/flutter/flutter.git))
- **Framework:** revision 2663184aa7 (5 months ago) • 2024-09-11 16:27:48 -0500
- **Engine:** revision 36335019a8
- **Tools:** Dart 3.5.3 • DevTools 2.37.3

## Architecture and Design

The app is built using a **Clean Architecture** approach combined with **MVVM**, which provides several benefits:

- **Better Separation of Concerns:**
  - **MVVM** divides the UI (View), business logic (ViewModel), and data (Model) within the presentation layer.
  - **Clean Architecture** ensures a well-defined structure across the Presentation, Domain, and Data layers.
  
- **Easier Testing & Maintainability:**
  - The ViewModel and domain layers (use cases, repositories, models) are independent of Flutter widgets, making them highly testable and easier to maintain.
  
- **Scalability & Reusability:**
  - New features can be added without breaking existing code.
  - ViewModels can be reused across multiple screens.
  
- **Enhanced State Management:**
  - Provider fits naturally with MVVM, where the ViewModel holds and exposes state while the UI listens and rebuilds as needed.

## Todo CRUD Operations

The app implements full CRUD operations for todos in both online and offline modes:

- **Offline Todos:**  
  - Create, read, update, and delete operations are fully supported with persistent storage using a local SQLite database (sqflite).
  
- **Online Todos:**  
  - Create, read, and update functionalities are implemented. However, online todos are session-based; changes persist only during the current session as the API is mock-based.

## Additional Features Implemented

### Dual Tabs for Task Management

- **Online Todos:**
  - Implements pagination for efficient loading of a large number of tasks.
  - Edited data persists only during the current session.
  
- **Offline Todos:**
  - All tasks are stored persistently using SQLite (sqflite), ensuring data remains available even after the app is closed.
  - Extended features include setting priority, due date, description, and dateAdded.
  - Tasks are grouped by due date for easy navigation.

### Enhanced Offline Task Features

- **Due Date Selection:**  
  Tapping the date button opens a user-friendly date picker to select a due date.
  
- **Interactive Swipe Actions:**  
  - Swiping left on a task reveals options to edit or mark it as complete.
  - Once marked complete, the task tile turns green with a tick mark, clearly indicating its status.
  - Completed tasks cannot be edited but can be deleted by swiping right.
  
- **Priority Indicator:**  
  Each offline task displays a colored indicator:
  - **Red:** High priority  
  - **Golden:** Medium priority  
  - **Green:** Low priority

### User Authentication & Profile Management

- Secure login is implemented using the provided dummy API.
- On first login, user profile data is stored in Shared Preferences and displayed in the profile section.
- A logout feature is included that clears both the token and user profile data, ensuring a secure sign-out.

### Unit Testing

- Unit test cases have been added for the Home Controller, Home Repository, Auth Controller, and Auth Repository.
- The **mocktail** package is used to mock dependencies and simulate API responses.
- All tests have been executed successfully, ensuring the reliability of these critical components.

## Installation & Setup

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/Vivek-varadharaj/Task-manager.git
