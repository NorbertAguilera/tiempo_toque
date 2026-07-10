# Tiempo & Toque ⏱️🚀

**Tiempo & Toque** is a mobile application developed in Flutter, designed for running competition simulations and managing rankings in sports and activities where the final time is determined by adding the run time and accumulated penalties (e.g., canoe slalom, equestrian, obstacle courses, etc.).

---

## 📋 Main Features

### 1. Competition Stopwatch ⏱️
* Precise time tracking for each competitor (Start, Pause, Stop, and Reset).
* Real-time display of the elapsed time.

### 2. Dynamic Penalty System ⚠️
Allows adding penalties quickly using direct buttons during or at the end of the run:
* **Touch (+2 seconds):** Standard penalty for touching an obstacle or gate.
* **Missed Gate / Skip (+50 seconds):** Severe penalty for skipping a gate or obstacle.
* *Ability to configure or customize penalty times in the future.*

### 3. Participant Registration 👥
* Create a list of competitors before starting the runs.
* Assign a bib number and name to each participant.

### 4. Real-Time Ranking & Leaderboard 🏆
* Automatic sorting of competitors from lowest to highest total time.
* Ranking formula: 
  $$\text{Total Time} = \text{Run Time} + (\text{Touches} \times 2\text{s}) + (\text{Missed Gates} \times 50\text{s})$$
* Clear breakdown display of the base run time and penalties for each competitor.

---

## 🛠️ Tech Stack

* **Frontend:** [Flutter](https://flutter.dev) (Dart)
* **Compatibility:** Android & iOS

---

## 🚀 Getting Started

### Prerequisites

Make sure you have Flutter installed in your development environment. You can check the official guide at [Flutter Setup](https://docs.flutter.dev/get-started/install).

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/NorbertAguilera/tiempo_toque.git
   cd tiempo_toque/tiempo_toque_app
   ```

2. Get the project dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application on your simulator or device:
   ```bash
   flutter run
   ```


