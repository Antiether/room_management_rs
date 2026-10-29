# SmarterBMS

**Smart Bed Management System** is a Flutter-based application prototype for visualizing and managing hospital rooms and bed availability. It provides an interactive floor plan to help hospital staff monitor room occupancy, patient assignments, bed bookings, and cleaning status from a single interface.

This project is currently under development and is intended for demonstration and early-stage system design.

## Features

- **Interactive Hospital Floor Plan** — Visualize rooms, beds, and hospital facilities in a spatial layout.
- **Bed Availability Monitoring** — Identify available, occupied, booked, and cleaning beds through color-coded status indicators.
- **Room Occupancy Summary** — Display key metrics such as total beds, available beds, occupied beds, bookings, and bed occupancy rate.
- **Patient Information** — View patient information associated with occupied beds.
- **Bed Booking Interaction** — Interact with available beds to explore the booking workflow.
- **Cleaning Status Tracking** — Display beds that require cleaning or are undergoing cleaning.
- **Zoom and Pan Controls** — Navigate the floor plan using zoom controls and canvas interactions.
- **Responsive Layout** — Support desktop and narrow browser viewports through separate desktop and mobile layouts.

## Tech Stack

- **Flutter** — Cross-platform UI framework.
- **Dart** — Application programming language.
- **Material Design** — UI components and visual styling.

## Application Preview

Add screenshots or a GIF of the application here.

```text
assets/
└── screenshots/
    ├── desktop-view.png
    └── mobile-view.png
```

Once the screenshots are added to the repository, embed them using:

```markdown
![Desktop View](assets/screenshots/desktop-view.png)
```

## Getting Started

### Prerequisites

Install the following tools before running the project:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Google Chrome](https://www.google.com/chrome/) for Flutter Web development
- Git

Verify your Flutter installation:

```bash
flutter doctor
```

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Antiether/room_management_rs.git
   ```

2. Navigate to the project directory:

   ```bash
   cd room_management
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application in Chrome:

   ```bash
   flutter run -d chrome
   ```

### Build for Production

To generate a production-ready Flutter Web build:

```bash
flutter build web --release
```

The generated web application will be available in:

```text
build/web/
```

The contents of this directory can be deployed to a compatible static web hosting service.

## Project Structure

```text
lib/
├── data/
│   └── mock_data.dart
├── models/
│   ├── patient.dart
│   ├── room_bed.dart
│   └── cleaning_task.dart
├── services/
│   └── hospital_state.dart
├── views/
│   ├── home_screen.dart
│   ├── desktop_layout.dart
│   └── mobile_layout.dart
├── widgets/
│   ├── ward_map_canvas.dart
│   ├── room_card.dart
│   ├── bed_tile.dart
│   ├── kpi_summary_bar.dart
│   ├── zoom_controls.dart
│   ├── bed_action_dialog.dart
│   ├── new_patient_dialog.dart
│   ├── cleaning_tracker_panel.dart
│   ├── patient_queue_panel.dart
│   └── research_info_dialog.dart
└── main.dart
```

## How It Works

1. Hospital room and bed information is represented through application data models.
2. The application displays rooms and their beds on an interactive floor plan.
3. Each bed is represented by a status indicator and associated information.
4. Users can interact with available beds to explore booking actions and view patient-related information.
5. Summary indicators provide an overview of bed availability and occupancy.

## Current Limitations

- The application is a prototype intended for demonstration and development.
- The current project includes mock data and does not establish a connection to a live hospital information system.
- Booking, patient management, and cleaning workflows should not be considered production-ready without further implementation and testing.
- Authentication, authorization, persistent database storage, and integration with hospital systems are not yet documented as implemented features.
- Responsive behavior and touch interactions should be tested across different screen sizes and devices.

**Important:** This prototype must not be used as the source of truth for actual patient assignments or hospital bed availability.

## Future Development

Potential improvements include:

- Database integration for persistent room, bed, and patient records.
- Role-based access for administrators, nurses, and other hospital staff.
- Real-time synchronization of bed status.
- Integration with hospital admission and discharge workflows.
- Booking validation and conflict prevention.
- Improved mobile touch interactions and accessibility.
- Automated testing and deployment pipelines.

## Contributing

Contributions, suggestions, and bug reports are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Open a pull request describing the changes.

## License

No license has been specified yet. Unless a license is added to this repository, reuse and redistribution remain subject to the applicable copyright rules.

---

*Developed as a prototype for hospital room and bed management.*