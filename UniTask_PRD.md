# Product Requirements Document (PRD)

## UniTask — University Task Management App

**Version:** 1.0  
**Platform:** Android  
**Product Stage:** MVP  
**Primary Theme:** Modern Dark Mode  
**Target User:** University Students

---

## 1. Product Overview

UniTask adalah aplikasi mobile untuk membantu mahasiswa mengelola tugas universitas dalam satu tempat.

Fokus tahap awal adalah aktivitas akademik, terutama:

- mencatat tugas dari setiap mata kuliah;
- menyimpan deadline;
- menentukan prioritas;
- memecah tugas menjadi subtask;
- memantau progres pengerjaan;
- mengetahui tugas yang harus dikerjakan terlebih dahulu.

UniTask bukan sekadar to-do list. Aplikasi harus membantu pengguna menjawab:

> **"Apa yang harus saya kerjakan sekarang?"**

Fitur Home Screen Widget direncanakan sebagai bagian penting dari pengembangan berikutnya, tetapi MVP pertama berfokus pada aplikasi inti.

---

## 2. Problem Statement

Mahasiswa dapat memiliki banyak tugas dari beberapa mata kuliah dengan deadline yang berbeda.

Contoh tugas pengguna:

| Mata Kuliah | Tugas | Deadline |
|---|---|---|
| Jaringan Komunikasi Data | Menghitung Subnet Mask | Selasa minggu depan |
| Pemodelan Perangkat Lunak | Use Case & Misuse Case Diagram | Senin minggu depan |
| Proses Perangkat Lunak | Laporan Interview | Rabu minggu depan |

Masalah yang ingin diselesaikan:

- tugas dari berbagai mata kuliah tercampur;
- deadline sulit dipantau;
- pengguna dapat lupa tugas yang belum selesai;
- sulit menentukan tugas mana yang perlu dikerjakan terlebih dahulu;
- tugas yang kompleks tidak mudah dipantau progresnya;
- pengguna mengetahui deadline, tetapi belum tentu mengetahui langkah berikutnya.

---

## 3. Product Goals

### Primary Goal

Membantu mahasiswa mengelola tugas universitas secara cepat, sederhana, dan terstruktur.

### Secondary Goals

1. Memusatkan seluruh tugas universitas.
2. Menghubungkan setiap tugas dengan mata kuliah.
3. Menampilkan deadline secara jelas.
4. Membantu pengguna menentukan prioritas.
5. Memungkinkan tugas dipecah menjadi beberapa subtask.
6. Menampilkan progres pengerjaan.
7. Menyediakan gambaran tugas yang harus dikerjakan hari ini dan dalam waktu dekat.
8. Menjadi fondasi untuk Home Screen Widget pada versi berikutnya.

---

## 4. Product Scope

### In Scope — MVP

- Course management
- Task management
- Deadline
- Priority
- Task status
- Subtask
- Progress tracking
- Dashboard
- Upcoming tasks
- Today tasks
- Overdue tasks
- Search dan filter dasar
- Modern dark mode
- Local data storage

### Out of Scope — MVP

Fitur berikut tidak menjadi fokus versi pertama:

- sinkronisasi cloud;
- login/account;
- kolaborasi tugas;
- chat;
- calendar synchronization;
- AI assistant;
- attachment/file management;
- gamification;
- pekerjaan/internship management;
- personal habit tracking;
- keuangan;
- Home Screen Widget.

Fitur-fitur tersebut dapat dipertimbangkan pada versi berikutnya.

---

# 5. Target User

## Primary Persona

Mahasiswa aktif yang memiliki beberapa mata kuliah dan menerima tugas dengan deadline yang berbeda.

### User Needs

Pengguna membutuhkan cara untuk:

- mencatat tugas dengan cepat;
- mengetahui deadline;
- melihat tugas berdasarkan mata kuliah;
- mengetahui tugas yang paling dekat deadline-nya;
- mengetahui progres tugas;
- memecah tugas besar menjadi pekerjaan yang lebih kecil.

---

# 6. Core Concept

Struktur aplikasi:

```text
UniTask
│
├── Dashboard
│
├── Tasks
│
├── Courses
│
└── Settings
```

Relasi data:

```text
Course
   │
   ├── Task
   │    ├── Deadline
   │    ├── Priority
   │    ├── Status
   │    └── Subtasks
   │
   └── Task
```

Contoh:

```text
Jaringan Komunikasi Data
└── Menghitung Subnet Mask
    ├── Tentukan IP address
    ├── Tentukan prefix
    ├── Hitung subnet mask
    └── Tulis hasil
```

---

# 7. Information Architecture

```text
App
│
├── Dashboard
│   ├── Summary
│   ├── Today
│   ├── Upcoming
│   └── Quick Add
│
├── Tasks
│   ├── All
│   ├── Today
│   ├── Upcoming
│   ├── Overdue
│   └── Completed
│
├── Courses
│   ├── Course List
│   ├── Course Detail
│   └── Course Tasks
│
└── Settings
    ├── Appearance
    └── Data
```

---

# 8. Functional Requirements

## 8.1 Dashboard

Dashboard adalah halaman utama aplikasi.

Dashboard harus memberikan gambaran kondisi tugas tanpa membuat pengguna membuka banyak halaman.

### Required Information

- sapaan/waktu;
- jumlah tugas aktif;
- jumlah tugas yang mendekati deadline;
- deadline terdekat;
- daftar tugas upcoming;
- shortcut untuk membuat tugas.

### Example

```text
Good Evening 👋

3 Active Tasks
1 Due Soon

────────────────────

UPCOMING

Use Case & Misuse Case
Pemodelan Perangkat Lunak
Monday

Menghitung Subnet Mask
Jaringan Komunikasi Data
Tuesday

Laporan Interview
Proses Perangkat Lunak
Wednesday
```

Dashboard harus memprioritaskan informasi yang relevan dibanding menampilkan seluruh data.

---

# 9. Task Management

Pengguna dapat:

- membuat task;
- melihat task;
- mengubah task;
- menghapus task;
- mengubah status;
- menentukan deadline;
- menentukan priority;
- memilih course;
- menambahkan description;
- menambahkan subtask;
- menandai task selesai.

## Task Data

```text
id
title
description
courseId
deadline
priority
status
createdAt
updatedAt
```

---

# 10. Task Status

MVP menggunakan tiga status:

```text
TODO
IN PROGRESS
COMPLETED
```

### TODO

Tugas belum mulai dikerjakan.

### IN PROGRESS

Tugas sedang dikerjakan.

### COMPLETED

Tugas sudah selesai.

Status harus dapat diubah langsung dari task detail.

---

# 11. Priority

Gunakan tiga tingkat prioritas:

```text
HIGH
MEDIUM
LOW
```

Representasi visual:

```text
🔴 HIGH
🟡 MEDIUM
⚪ LOW
```

Priority adalah input dari pengguna.

Aplikasi dapat memberikan informasi tambahan berdasarkan kedekatan deadline, tetapi tidak mengganti pilihan priority pengguna secara otomatis.

---

# 12. Course Management

Pengguna dapat membuat dan mengelola mata kuliah.

### Course Data

```text
id
name
code
lecturer
createdAt
```

Contoh:

```text
Jaringan Komunikasi Data
Pemodelan Perangkat Lunak
Proses Perangkat Lunak
Analisis Kebutuhan Perangkat Lunak
HCI
```

Course Detail menampilkan:

- nama mata kuliah;
- informasi mata kuliah;
- jumlah task;
- task aktif;
- task completed.

---

# 13. Subtask

Task dapat memiliki beberapa subtask.

Contoh:

```text
Laporan Interview

☑ Menentukan objek interview
☑ Melakukan interview
☑ Mengumpulkan informasi
☐ Menentukan aktor
☐ Membuat use case
☐ Menulis laporan
☐ Finalisasi
```

Progress dihitung otomatis.

Contoh:

```text
3 / 7 completed

██████░░░░ 43%
```

### Subtask Data

```text
id
taskId
title
isCompleted
createdAt
```

---

# 14. Deadline

Setiap task dapat memiliki deadline.

Deadline harus menyimpan:

```text
date
time
```

Jika pengguna hanya mengetahui tanggal, waktu dapat dibuat sebagai optional.

### Deadline State

```text
OVERDUE
DUE TODAY
DUE TOMORROW
UPCOMING
COMPLETED
```

Deadline yang sudah lewat dan task belum selesai harus ditandai sebagai overdue.

---

# 15. Task List

Halaman Tasks menyediakan daftar seluruh task.

Filter:

```text
ALL
TODAY
UPCOMING
OVERDUE
COMPLETED
```

Task dapat diurutkan berdasarkan:

- deadline;
- priority;
- created date.

Default sorting:

> Deadline terdekat terlebih dahulu.

---

# 16. Search

Pengguna dapat mencari task berdasarkan:

- judul task;
- nama mata kuliah.

Contoh:

```text
Search: "interview"

Result:

Laporan Interview
Proses Perangkat Lunak
```

---

# 17. Quick Add

Pengguna dapat membuat task dari tombol `+`.

Form minimal:

```text
Task Title
Course
Deadline
Priority
```

Description dan subtask bersifat optional.

Tujuan Quick Add adalah membuat task baru dalam waktu sesingkat mungkin.

---

# 18. Task Detail

Task Detail menampilkan informasi lengkap:

```text
Use Case & Misuse Case Diagram

Pemodelan Perangkat Lunak

Deadline
Monday, 28 September

Priority
HIGH

Status
IN PROGRESS

Progress
3 / 5

SUBTASKS

☑ Tentukan studi kasus
☑ Identifikasi aktor
☑ Identifikasi use case
☐ Buat use case diagram
☐ Buat misuse case diagram

DESCRIPTION

Membuat Use Case & Misuse Case Diagram
sesuai studi kasus yang diberikan.
```

Action:

```text
Edit
Delete
Change Status
Add Subtask
Mark Completed
```

---

# 19. Initial User Data

Untuk development/testing, aplikasi dapat menggunakan contoh data berikut:

## Course 1

**Jaringan Komunikasi Data**

Task:

> Menghitung Subnet Mask

Deadline:

> Selasa minggu depan

---

## Course 2

**Pemodelan Perangkat Lunak**

Task:

> Use Case & Misuse Case Diagram

Deadline:

> Senin minggu depan

---

## Course 3

**Proses Perangkat Lunak**

Task:

> Laporan Interview

Deadline:

> Rabu minggu depan

Tanggal aktual harus dihitung berdasarkan tanggal saat task dibuat atau diinput oleh pengguna, bukan hard-coded untuk production.

---

# 20. UX Principles

UniTask harus mengikuti prinsip:

### 1. Fast

Pengguna dapat mencatat tugas tanpa melewati banyak form.

### 2. Clear

Deadline dan status harus dapat dipahami dalam sekali melihat.

### 3. Focused

Dashboard tidak boleh penuh dengan informasi yang tidak diperlukan.

### 4. Consistent

Komponen UI, typography, spacing, iconography, dan interaction harus konsisten.

### 5. Low Cognitive Load

Pengguna tidak perlu berpikir terlalu banyak untuk memahami kondisi tugas.

---

# 21. Visual Design

## Design Direction

Style:

> **Modern, minimal, dark, clean, productivity-focused.**

Hindari:

- desain RGB gaming;
- glassmorphism berlebihan;
- gradient berlebihan;
- terlalu banyak warna;
- card yang terlalu besar;
- dekorasi yang tidak memiliki fungsi;
- UI yang terlihat seperti dashboard admin.

---

## Color System

Gunakan dark neutral sebagai dasar.

Contoh:

```text
Background
#0B0D10

Surface
#12151A

Elevated Surface
#181C22

Primary Text
#F5F7FA

Secondary Text
#9AA1AC

Border
#252A32
```

Accent color dapat digunakan secara terbatas untuk:

- active state;
- primary button;
- progress;
- selected navigation;
- interactive elements.

Status colors digunakan secara semantik:

```text
High / Overdue     Red
Medium             Amber
Success / Completed Green
Information        Blue
```

Warna status tidak boleh mendominasi keseluruhan interface.

---

# 22. Typography

Typography harus modern dan mudah dibaca.

Hierarchy:

```text
Display / Greeting
Large

Page Title
Large / Bold

Section Title
Medium / Semibold

Task Title
Medium / Semibold

Metadata
Small / Regular

Supporting Text
Small / Regular
```

Gunakan satu keluarga font utama untuk menjaga konsistensi.

---

# 23. Navigation

Gunakan bottom navigation sederhana:

```text
┌─────────────────────────────────┐
│                                 │
│          PAGE CONTENT           │
│                                 │
├─────────────────────────────────┤
│  Home     Tasks     Courses   ⚙ │
└─────────────────────────────────┘
```

Navigation utama:

- Home
- Tasks
- Courses
- Settings

Tombol `+` dapat dibuat sebagai floating action button atau action utama pada halaman Tasks.

---

# 24. Dashboard UI Structure

Urutan dashboard:

```text
[Greeting]

[Task Summary]

[Focus / Next Task]

[Upcoming Tasks]

[Quick Add]
```

Contoh:

```text
Good Evening

3 Tasks
1 Due Soon

┌──────────────────────────────┐
│ NEXT UP                      │
│                              │
│ Use Case & Misuse Case       │
│ Pemodelan Perangkat Lunak    │
│ Due Monday                   │
└──────────────────────────────┘

UPCOMING

┌──────────────────────────────┐
│ Menghitung Subnet Mask       │
│ Jaringan Komunikasi Data     │
│ Tuesday                 🔴   │
└──────────────────────────────┘

┌──────────────────────────────┐
│ Laporan Interview            │
│ Proses Perangkat Lunak       │
│ Wednesday               🟡   │
└──────────────────────────────┘
```

---

# 25. Empty States

Empty state harus informatif.

Jika belum ada task:

```text
No tasks yet

Add your first university task
and keep your deadlines organized.

[ + Add Task ]
```

Jika tidak ada task hari ini:

```text
You're clear today.

No tasks scheduled for today.
```

Jika semua task selesai:

```text
All tasks completed.

Nothing left to do.
```

---

# 26. Notification Requirements

Notification tidak wajib untuk MVP pertama, tetapi arsitektur harus memungkinkan penambahannya.

Jenis notification yang direncanakan:

```text
Task due tomorrow
Task due today
Task overdue
```

Contoh:

```text
UniTask

Use Case & Misuse Case Diagram
is due tomorrow.
```

---

# 27. Home Screen Widget — Future Feature

Widget merupakan fitur penting untuk versi setelah MVP.

Tujuan:

> Menampilkan informasi tugas paling penting tanpa membuka aplikasi.

## Small Widget

```text
TODAY

3 Tasks

Next:
Use Case & Misuse Case
```

## Medium Widget

```text
TODAY

🔴 Use Case & Misuse Case
   Due Monday

🟡 Subnet Mask
   Due Tuesday

⚪ Laporan Interview
   Due Wednesday
```

## Widget Interaction

User dapat:

- membuka task;
- membuka aplikasi;
- melihat task hari ini;
- pada versi lanjutan, menyelesaikan task langsung dari widget.

Widget harus menggunakan data yang sama dengan aplikasi utama.

---

# 28. Data Model

Relational model:

```text
COURSE
---------
id
name
code
lecturer
created_at

TASK
---------
id
course_id
title
description
deadline
priority
status
created_at
updated_at

SUBTASK
---------
id
task_id
title
is_completed
created_at
```

Relationship:

```text
Course 1 ───── N Task

Task 1 ───── N Subtask
```

---

# 29. Local-First Architecture

MVP menggunakan pendekatan local-first.

```text
Mobile App
    │
    ▼
Local Database
    │
    ├── Courses
    ├── Tasks
    └── Subtasks
```

Tidak diperlukan backend pada tahap pertama.

Keuntungan:

- lebih sederhana;
- cepat;
- dapat digunakan tanpa internet;
- cocok untuk single-user;
- lebih mudah dikembangkan sebagai MVP.

Cloud synchronization dapat ditambahkan pada versi berikutnya.

---

# 30. Non-Functional Requirements

## Performance

- Dashboard harus terbuka dengan cepat.
- Perubahan task harus terasa instan.
- Data lokal harus dapat diakses tanpa internet.

## Reliability

- Data task tidak boleh hilang ketika aplikasi ditutup.
- Perubahan task harus tersimpan secara persistent.

## Usability

- Membuat task tidak boleh membutuhkan banyak langkah.
- Informasi deadline harus mudah ditemukan.
- Status task harus mudah diubah.

## Accessibility

- Text harus memiliki kontras yang cukup terhadap dark background.
- Touch target harus cukup besar.
- Jangan hanya menggunakan warna untuk membedakan status.

---

# 31. MVP User Flow

## First Launch

```text
Open App
   ↓
Dashboard
   ↓
No Tasks
   ↓
Add First Task
```

## Add Task

```text
Tap +
   ↓
Enter Task Title
   ↓
Select Course
   ↓
Select Deadline
   ↓
Select Priority
   ↓
Save
   ↓
Task appears on Dashboard
```

## Complete Task

```text
Dashboard
   ↓
Open Task
   ↓
Update Subtasks
   ↓
Progress reaches 100%
   ↓
Mark Completed
   ↓
Task moves to Completed
```

---

# 32. Acceptance Criteria

MVP dianggap berhasil jika:

### Course

- [ ] User dapat membuat course.
- [ ] User dapat mengedit course.
- [ ] User dapat menghapus course.
- [ ] User dapat melihat task berdasarkan course.

### Task

- [ ] User dapat membuat task.
- [ ] User dapat mengedit task.
- [ ] User dapat menghapus task.
- [ ] User dapat menentukan deadline.
- [ ] User dapat menentukan priority.
- [ ] User dapat mengubah status.
- [ ] User dapat menambahkan description.

### Subtask

- [ ] User dapat menambahkan subtask.
- [ ] User dapat menandai subtask selesai.
- [ ] Progress otomatis berubah berdasarkan subtask.

### Dashboard

- [ ] Dashboard menampilkan task aktif.
- [ ] Dashboard menampilkan deadline terdekat.
- [ ] Dashboard menampilkan task yang akan datang.
- [ ] Dashboard menyediakan quick add.

### Task List

- [ ] User dapat melihat seluruh task.
- [ ] User dapat filter berdasarkan status/deadline.
- [ ] User dapat mencari task.

### UI

- [ ] Dark mode menjadi tampilan utama.
- [ ] UI responsif terhadap ukuran layar.
- [ ] Kontras teks memenuhi kebutuhan keterbacaan.
- [ ] UI tidak menggunakan dekorasi visual berlebihan.

---

# 33. Future Roadmap

## V1 — MVP

```text
Courses
Tasks
Deadline
Priority
Status
Subtasks
Dashboard
Local Storage
Dark UI
```

## V2 — Productivity

```text
Notifications
Calendar View
Recurring Tasks
Advanced Filters
Task Statistics
```

## V3 — Home Screen

```text
Android Widget
Today's Tasks
Upcoming Tasks
Next Action
Quick Complete
```

## V4 — Smart Features

```text
Natural Language Task Input
Automatic Task Breakdown
Smart Deadline Reminder
Daily Planning
```

## V5 — Cloud

```text
Authentication
Cloud Sync
Backup
Multi-device
```

---

# 34. Product Principle

UniTask harus mengikuti satu prinsip utama:

> **Don't just store tasks. Help students know what to do next.**

Aplikasi tidak perlu menjadi aplikasi produktivitas yang memiliki semua fitur.

Tahap pertama harus sangat fokus:

**Mata kuliah → Tugas → Deadline → Prioritas → Progress → Selesai.**

Setelah alur tersebut solid, widget dan fitur intelligence dapat dibangun di atas fondasi yang sama.
