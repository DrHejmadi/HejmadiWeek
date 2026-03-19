# HejmadiWeek - Kalender Research Rapport

**Dato:** 18. marts 2026
**Formål:** Deep research af kalender-UI, automatisk TODO, Apple EventKit/ICS dataformat, og konkrete forbedringsforslag til HejmadiWeek.

---

## Indholdsfortegnelse

1. [Skærm-optimering & Overblik](#1-skærm-optimering--overblik)
2. [Automatisk TODO-liste Integration](#2-automatisk-todo-liste-integration)
3. [AI-drevne Kalender-funktioner](#3-ai-drevne-kalender-funktioner)
4. [Apple EventKit Datamodel - Komplet Oversigt](#4-apple-eventkit-datamodel---komplet-oversigt)
5. [ICS/iCalendar Format (RFC 5545)](#5-icsicalendar-format-rfc-5545)
6. [Deling af Kalenderdata - Hvad Kan Deles?](#6-deling-af-kalenderdata---hvad-kan-deles)
7. [EventKit Begrænsninger](#7-eventkit-begrænsninger)
8. [Konkrete Forslag til HejmadiWeek](#8-konkrete-forslag-til-hejmadiweek)

---

## 1. Skærm-optimering & Overblik

### Bedste Praksis fra Top-apps

#### Three-Pane Layout (Notion Calendar / Cron)
- Venstre: kalenderliste, mini-måned navigator
- Center: primært kalendergrid (dag/uge/måned)
- Højre: kontekst/detalje-panel til event-redigering, beskrivelser, deltagere
- Tastaturgeneve (1-9 for dagantal, D/W/M for view, T for i dag)

#### Mini-måned + Agenda (Google Calendar, Fantastical mobil)
- Kompakt månedsgrid øverst fungerer som navigation
- Tryk på dato scroller agendalist nedenunder
- "+N mere" overflow-indikatorer i månedsceller med popover

#### Pinch-to-Zoom View Switching
- Flydende overgang mellem dag/uge/måned granularitet
- Skaber mere/mindre plads mellem dage for at vise/skjule detaljer
- Effektivt brugt af Google Calendar mobil

#### Keyboard-First (Vimcal)
- Hver UI-komponent har en tastaturgeneve
- Drag-to-share tilgængelighed: marker åbne slots, generer poleret tekst til email
- Themes/farver til personalisering

#### Fantastical DayTicker
- Unik scrollbar dag-event liste der viser events for aktuel dag uden at skifte view
- Natural language input som guldstandard for event-oprettelse

### Informationstæthed vs. Læsbarhed

| Strategi | Brugt Af | Beskrivelse |
|---|---|---|
| Farvede dots/bars per event | Apple Calendar, WeekCal | Compact (enkelt bar), Stacked (bar per event), Details (titler) |
| Heatmap-farvning | BusyCal | Farvegradient fra lys (få events) til mørk (mange events) |
| Event-ikoner | WeekCal | Ikoner i stedet for farvede dots for hurtig kategori-genkendelse |
| Emoji-baseret visualisering | WeekCal | Tildel emojis til events via regler for hurtig scanning |
| Adaptiv event-tekst | Google Calendar | Viser kun titel ved små størrelser, udvides med tid/lokation ved større |

### Innovative Overbliksdesigns

#### Heatmaps for Travle Dage (BusyCal)
- Årsvisning med heatmap-tilstand farver hver dag baseret på antal events
- Tilgængelig som dedikeret widget ("Calendar & Heatmap")
- Menubar-udvidelse inkluderer mini-kalender med heatmap

#### Kanban-stil Kalendervisning
- **Dage som kolonner**: Hver kolonne = en ugedag, rækker = tidsblokke
- **Tidsdrevet proceskolonner**: Kolonner repræsenterer færdiggørelsesperioder

#### Gesture-baseret Navigation (2026 Standard)
| Gesture | Funktion |
|---|---|
| Swipe Right | Forrige (dag/uge/måned) |
| Swipe Left | Næste (dag/uge/måned) |
| Swipe Down | Opdater eller luk detalje |
| Long Press | Kontekstmenu (rediger/slet/flyt) |
| Pinch | Zoom mellem visningsmodes |

> Research viser at navigationsfrustration forårsager 40% af Day-1 frafald. Gesture-navigation giver +10-15% forbedring i task completion.

#### Adaptive Layouts (2026 Trend)
- AI-drevne interfaces tilpasser baseret på tidspunkt, brugeradfærd og indholdstæthed
- Bento grid layouts: modulære blokke af varierende størrelse
- Mikro-animationer øger opfattet performance med 30-40%

---

## 2. Automatisk TODO-liste Integration

### Førende Implementeringer

#### Amie (Mest Avanceret)
- Drag todos direkte på kalender med varighed og prioriteter
- AI Chat auto-estimerer task-varighed (fx "house repairs" -> planlægger 2 timer)
- AI mødenotater genererer action items der konverteres til todos
- Bi-directional sync med Apple Reminders (feb 2026), plus Linear, Todoist, Things, Notion
- Indbygget focus-timer for tidsbaseret task-session

#### Morgen AI Planner
- Konsoliderer tasks fra Notion, Todoist, Linear, ClickUp i ét view
- AI Planner skaber energi-bevidste daglige planer med pauser
- "Frames" = tilpasselige tidsblokke for forskellige task-typer (deep work, quick wins, personligt)
- Auto-planlægger rundt om eksisterende kalenderevents
- Bruger godkender plan før den scheduleres - aldrig auto-commits

#### Reclaim.ai
- AI auto-planlægger forberedelsestid og opfølgningstid omkring møder
- Prioritetsbaseret planlægning: P1 (kritisk) til P4 (lav)
- Smart Habits: definer fleksible tidsvinduer, AI finder optimale slots
- Auto-omplanering ved konflikter

#### TickTick
- To-vejs sync med Google Calendar, Outlook, iCloud
- Tasks vises som kalenderevents og omvendt
- Time blocking ved at trække tasks ind på skema
- Subtasks, prioriteter, tags, Pomodoro-timer, vane-tracking

### Automatiseringsmønstre

#### Meeting -> Action Items -> Tasks (Amie Flow)
1. AI optager mødelyd lokalt (ingen bot i mødet)
2. Genererer sammendrag + action items efter opkald
3. Action items konverteres til todos med ét klik
4. Todos kan trækkes ind på kalender for time-blocking
5. AI omorganiserer plan når planer ændres

#### Zapier Workflows
- Ny Google Calendar event -> auto-opret task i Todoist/TickTick/Notion
- Multi-action Zaps: opret task + post Slack notifikation

---

## 3. AI-drevne Kalender-funktioner

### Google Calendar + Gemini
- **"Help Me Schedule" (okt 2025):** Detekterer planlægningsintent i Gmail, foreslår tidsslots
- **"Ask Gemini" Panel (marts 2025):** Naturligt sprog spørgsmål om din plan
- **Focus Time (nov 2025):** Tasks med "optaget" status og forstyr-ikke

### Oversigt: AI Features på Tværs af Apps

| Feature | Google/Gemini | Motion | Reclaim | Morgen | Amie |
|---|---|---|---|---|---|
| Auto-schedule tasks | Nej | Ja (aggressiv) | Ja (blid) | Ja (godkendelse) | Ja (AI Chat) |
| Smart time blocking | Kun Focus Time | Fuld AI | Prioritetsbaseret | Frame-baseret | Drag + AI forslag |
| Mødeforberedelse/opfølgning | Nej | Nej | Ja (auto buffer) | Nej | Ja (AI noter -> todos) |
| Natural language input | Basal parsing | Ja | Nej | Nej | Ja (NLP) |
| Multi-calendar support | Kun Google | Google+Outlook | Google+Outlook | Google+Outlook+Apple | Google+Outlook |
| Energi-bevidst planlægning | Nej | Nej | Nej | Ja | Nej |

> Markedet for AI-drevne mødeassistenter forventes at vokse fra $2,68B (2024) til $24,6B i 2034 (24,8% CAGR).

---

## 4. Apple EventKit Datamodel - Komplet Oversigt

### EKEvent (Alle Properties)

| Property | Type | Læs/Skriv | Beskrivelse |
|---|---|---|---|
| `eventIdentifier` | String | R | Unik event identifier |
| `startDate` | Date | R/W | Start dato og tid |
| `endDate` | Date | R/W | Slut dato og tid |
| `isAllDay` | Bool | R/W | Om det er en heldags-event |
| `title` | String | R/W | Titel/emne |
| `location` | String? | R/W | Lokation som tekst |
| `structuredLocation` | EKStructuredLocation? | R/W | Struktureret lokation med geokoordinater |
| `notes` | String? | R/W | Noter/beskrivelse |
| `URL` | URL? | R/W | Tilknyttet URL |
| `calendar` | EKCalendar | R/W | Kalender dette tilhører |
| `availability` | EKEventAvailability | R/W | `.busy`, `.free`, `.tentative`, `.unavailable` |
| `status` | EKEventStatus | **R** | `.none`, `.confirmed`, `.tentative`, `.canceled` |
| `organizer` | EKParticipant? | **R** | Event-organisator (KUN LÆSNING) |
| `attendees` | [EKParticipant]? | **R** | Deltagere (KUN LÆSNING) |
| `alarms` | [EKAlarm]? | R/W | Alarmer/påmindelser |
| `recurrenceRules` | [EKRecurrenceRule]? | R/W | Gentagelsesregler |
| `timeZone` | TimeZone? | R/W | Tidszone |
| `isDetached` | Bool | R | Om event er løsrevet fra gentagelse |
| `occurrenceDate` | Date | R | Original dato for gentagende instans |
| `creationDate` | Date? | R | Oprettet dato |
| `lastModifiedDate` | Date? | R | Sidst ændret dato |

### EKReminder (Alle Properties)

| Property | Type | Læs/Skriv | Beskrivelse |
|---|---|---|---|
| `startDateComponents` | DateComponents? | R/W | Startdato |
| `dueDateComponents` | DateComponents? | R/W | Forfaldsdato |
| `isCompleted` | Bool | R/W | Om opgaven er fuldført |
| `completionDate` | Date? | R/W | Fuldførelsesdato |
| `priority` | Int | R/W | 0=ingen, 1-4=høj, 5=medium, 6-9=lav |
| `title` | String | R/W | Titel |
| `notes` | String? | R/W | Noter |
| `calendar` | EKCalendar | R/W | Kalender |
| `alarms` | [EKAlarm]? | R/W | Alarmer |
| `recurrenceRules` | [EKRecurrenceRule]? | R/W | Gentagelse |
| `URL` | URL? | R/W | URL |

### EKParticipant (ALLE Properties er KUN LÆSNING)

| Property | Type | Beskrivelse |
|---|---|---|
| `name` | String? | Visningsnavn |
| `url` | URL | URL (typisk mailto: URI) |
| `participantRole` | EKParticipantRole | `.required`, `.optional`, `.chair`, `.nonParticipant` |
| `participantStatus` | EKParticipantStatus | `.pending`, `.accepted`, `.declined`, `.tentative`, `.delegated` |
| `participantType` | EKParticipantType | `.person`, `.room`, `.resource`, `.group` |
| `isCurrentUser` | Bool | Om dette er den autentificerede bruger |

### EKAlarm

| Property | Type | Beskrivelse |
|---|---|---|
| `relativeOffset` | TimeInterval | Sekunder før event (negativt = før start) |
| `absoluteDate` | Date? | Absolut trigger dato/tid |
| `structuredLocation` | EKStructuredLocation? | Lokation for geofence-baserede alarmer |
| `proximity` | EKAlarmProximity | `.none`, `.enter`, `.leave` |

### EKStructuredLocation

| Property | Type | Beskrivelse |
|---|---|---|
| `title` | String | Lokationsnavn |
| `geoLocation` | CLLocation? | Bredde-/længdegrad |
| `radius` | Double | Geofence radius i meter |

### EKRecurrenceRule

| Property | Type | Beskrivelse |
|---|---|---|
| `frequency` | EKRecurrenceFrequency | `.daily`, `.weekly`, `.monthly`, `.yearly` |
| `interval` | Int | Hvor ofte (1=hver, 2=hver anden, etc.) |
| `daysOfTheWeek` | [EKRecurrenceDayOfWeek]? | Ugedage |
| `daysOfTheMonth` | [NSNumber]? | Månedsdage (+/- 1-31) |
| `monthsOfTheYear` | [NSNumber]? | Måneder (1-12) |
| `weeksOfTheYear` | [NSNumber]? | Uger af året |
| `recurrenceEnd` | EKRecurrenceEnd? | Slutbetingelse (antal eller dato) |
| `firstDayOfTheWeek` | Int | Ugens startdag |

### EKCalendar

| Property | Type | Læs/Skriv | Beskrivelse |
|---|---|---|---|
| `calendarIdentifier` | String | R | Unik identifier |
| `title` | String | R/W | Visningsnavn |
| `type` | EKCalendarType | R | `.local`, `.calDAV`, `.exchange`, `.subscription`, `.birthday` |
| `source` | EKSource | R/W | Konto/kilde |
| `cgColor` | CGColor | R/W | Visningsfarve |
| `allowedEntityTypes` | EKEntityMask | R | Tilladte typer (events/reminders) |
| `isSubscribed` | Bool | R | Om kalender er et abonnement |
| `isImmutable` | Bool | R | Om kalender kan ændres |
| `allowsContentModifications` | Bool | R | Om events/reminders kan tilføjes |

---

## 5. ICS/iCalendar Format (RFC 5545)

### Komponenter

| Komponent | Formål |
|---|---|
| `VCALENDAR` | Top-level container |
| `VEVENT` | Kalenderbegivenheder |
| `VTODO` | Opgaver/todos |
| `VJOURNAL` | Journal-indlæg |
| `VFREEBUSY` | Fri/optaget-info |
| `VTIMEZONE` | Tidszone-definitioner |
| `VALARM` | Alarmer/påmindelser |

### VEVENT Properties (Komplet)

| Property | Type | Obligatorisk | Beskrivelse |
|---|---|---|---|
| `UID` | TEXT | Ja | Globalt unik identifier |
| `DTSTAMP` | DATE-TIME | Ja | Oprettelsestidsstempel |
| `DTSTART` | DATE-TIME/DATE | Betinget | Starttid |
| `DTEND` | DATE-TIME/DATE | Nej | Sluttid |
| `DURATION` | DURATION | Nej | Varighed (eksklusiv med DTEND) |
| `SUMMARY` | TEXT | Nej | Titel |
| `DESCRIPTION` | TEXT | Nej | Fuld beskrivelse |
| `LOCATION` | TEXT | Nej | Lokation |
| `GEO` | FLOAT;FLOAT | Nej | Breddegrad;længdegrad |
| `URL` | URI | Nej | Tilknyttet URL |
| `ORGANIZER` | CAL-ADDRESS | Nej | Organisator email/URI |
| `ATTENDEE` | CAL-ADDRESS | Nej (multi) | Deltagere med parametre |
| `CATEGORIES` | TEXT | Nej (multi) | Kategori-tags |
| `CLASS` | TEXT | Nej | PUBLIC, PRIVATE, CONFIDENTIAL |
| `STATUS` | TEXT | Nej | TENTATIVE, CONFIRMED, CANCELLED |
| `TRANSP` | TEXT | Nej | OPAQUE eller TRANSPARENT |
| `PRIORITY` | INTEGER | Nej | 0-9 prioritet |
| `SEQUENCE` | INTEGER | Nej | Revisionssekvensnummer |
| `RRULE` | RECUR | Nej | Gentagelsesregel |
| `RDATE` | DATE-TIME/PERIOD | Nej (multi) | Ekstra gentagelsesdatoer |
| `EXDATE` | DATE-TIME/DATE | Nej (multi) | Undtagelsesdatoer |
| `RECURRENCE-ID` | DATE-TIME | Nej | Identificerer specifik gentagelse |
| `RELATED-TO` | TEXT | Nej (multi) | Relaterede komponenter |
| `RESOURCES` | TEXT | Nej (multi) | Nødvendige ressourcer |
| `ATTACH` | URI/BINARY | Nej (multi) | Vedhæftninger |
| `COMMENT` | TEXT | Nej (multi) | Kommentarer |
| `CONTACT` | TEXT | Nej (multi) | Kontaktinfo |
| `CREATED` | DATE-TIME | Nej | Oprettet tidsstempel |
| `LAST-MODIFIED` | DATE-TIME | Nej | Sidst ændret |
| `COLOR` (RFC 7986) | TEXT | Nej | CSS3 farvenavn |
| `CONFERENCE` (RFC 7986) | URI | Nej (multi) | Konference/møde-URI |
| `IMAGE` (RFC 7986) | URI/BINARY | Nej (multi) | Tilknyttet billede |

### VTODO Ekstra Properties (ud over VEVENT)

| Property | Type | Beskrivelse |
|---|---|---|
| `COMPLETED` | DATE-TIME | Hvornår opgaven blev fuldført |
| `PERCENT-COMPLETE` | INTEGER | 0-100 procent fuldført |
| `DUE` | DATE-TIME/DATE | Forfaldsdato |
| `STATUS` | TEXT | NEEDS-ACTION, COMPLETED, IN-PROCESS, CANCELLED |

### ATTENDEE Parametre

| Parameter | Værdier | Beskrivelse |
|---|---|---|
| `CUTYPE` | INDIVIDUAL, GROUP, RESOURCE, ROOM | Kalenderbrugertype |
| `ROLE` | CHAIR, REQ-PARTICIPANT, OPT-PARTICIPANT | Deltagerrolle |
| `PARTSTAT` | NEEDS-ACTION, ACCEPTED, DECLINED, TENTATIVE | Deltagerstatus |
| `RSVP` | TRUE/FALSE | Svar forventet? |
| `CN` | TEXT | Visningsnavn |
| `DELEGATED-TO` | CAL-ADDRESS | Delegeret til |
| `DELEGATED-FROM` | CAL-ADDRESS | Delegeret fra |
| `SENT-BY` | CAL-ADDRESS | Sendt på vegne af |

### RRULE (Gentagelsesregel) Komponenter

| Del | Beskrivelse |
|---|---|
| `FREQ` | DAILY, WEEKLY, MONTHLY, YEARLY |
| `UNTIL` | Slutdato |
| `COUNT` | Antal gentagelser |
| `INTERVAL` | Gentagelsesinterval |
| `BYDAY` | Ugedage (MO, TU, WE, TH, FR, SA, SU) |
| `BYMONTHDAY` | Månedsdage (1-31) |
| `BYMONTH` | Måneder (1-12) |
| `BYWEEKNO` | Uger af året |
| `BYYEARDAY` | Dage af året |
| `BYSETPOS` | Ordinal positionsfilter |
| `WKST` | Ugens startdag (standard MO) |

---

## 6. Deling af Kalenderdata - Hvad Kan Deles?

### CalDAV Deling (iCloud)
- **Fuld to-vejs sync** af alle event properties
- Understøtter deltagere, alarmer, gentagelse, lokationer, noter, URLs
- iCloud sender automatisk mødeinvitationer
- Data bevaret: 6 måneder bagud til 3 år frem

### ICS Fil Export/Import

#### Bevaret ved deling:
- SUMMARY (titel), DTSTART, DTEND, DURATION
- DESCRIPTION (noter)
- LOCATION
- ATTENDEE data (i filen, men modtager-apps kan fjerne)
- RRULE/RDATE/EXDATE (gentagelse)
- VALARM (alarmer)
- URL, ORGANIZER
- UID, DTSTAMP, SEQUENCE
- GEO koordinater
- STATUS, CLASS, PRIORITY, TRANSP

#### TABT ved deling:
- Kalenderfarver (fjernes ved import)
- Delingsrettigheder og relationer
- Sync-tilstand og live sync-forbindelser
- Kalendertilhørsforhold
- X-APPLE-* custom properties (ignoreres af ikke-Apple apps)

### Delte Kalendere via iCloud
- **Privat deling**: Kræver Apple Account; ejer tildeler Kun-Visning eller Redigering
- **Offentlig deling**: Alle med URL kan se (kun-læsning); intet Apple Account nødvendigt
- **INGEN per-event privatliv**: Alle events på en delt kalender er synlige for alle deltagere

### Apple-Proprietære Udvidelser (X-APPLE-*)

| Property | Formål |
|---|---|
| `X-APPLE-STRUCTURED-LOCATION` | Rig lokation med koordinater |
| `X-APPLE-TRAVEL-ADVISORY-BEHAVIOR` | Rejsetid-rådgivning |
| `X-APPLE-DEFAULT-ALARM` | Standard alarm-indstillinger |
| `X-APPLE-NEEDS-REPLY` | Om svar er nødvendigt |
| `X-APPLE-SUGGESTION-INFO-*` | Siri-forslagsdetaljer |

> Disse bevares i ICS-filer men ignoreres af al ikke-Apple kalendersoftware.

---

## 7. EventKit Begrænsninger

### Kritiske Begrænsninger

1. **Kan IKKE sætte deltagere/organisator** — `attendees` og `organizer` er kun-læsning. Man kan ikke programmatisk invitere folk til møder.

2. **Kan IKKE sende mødeinvitationer** — iCloud håndterer invitationer server-side; EventKit har ingen scheduling/iTIP support.

3. **Ingen granulerede ændringsnotifikationer** — Den eneste notifikation er `.EKEventStoreChanged` som betyder "noget ændrede sig, genhent alt."

4. **Ingen SwiftUI integration** — EKEvent og EKReminder trigger ikke SwiftUI view-opdateringer. Man skal manuelt bridge til observable state.

5. **Non-Sendable concurrency** — EKEventStore er non-Sendable og kan ikke deles på tværs af Swift concurrency isolation.

6. **Ingen vedhæftnings-oprettelse** — Vedhæftninger kan læses men ikke oprettes via EventKit.

7. **Ingen VJOURNAL eller VFREEBUSY support** — EventKit understøtter kun events (VEVENT) og reminders (VTODO).

8. **Write-only access (iOS 17+)** — Apps med write-only access kan ikke læse egne events, kalenderlisteen, eller oprette nye kalendere.

9. **Database-invalidering** — Eksterne ændringer kan ugyldiggøre EKEvent/EKReminder instances til enhver tid.

10. **Kun én EKEventStore** — Tung instantiering; kun én bør eksistere per app.

### Read-Only Properties (Kan IKKE ændres)

- **EKEvent:** `eventIdentifier`, `status`, `organizer`, `isDetached`, `occurrenceDate`
- **EKCalendarItem:** `calendarItemIdentifier`, `creationDate`, `lastModifiedDate`, `attendees`
- **EKParticipant:** ALLE properties
- **EKCalendar:** `calendarIdentifier`, `type`, `isSubscribed`, `isImmutable`

---

## 8. Konkrete Forslag til HejmadiWeek

### Prioritet 1: Skærm-optimering (Næste Sprint)

#### 1A. Heatmap i Månedsvisning
- Farvegradient på dagceller baseret på event-tæthed
- Lys = få events, mørk = mange events
- Giver instant overblik over travle perioder
- **Implementation:** Beregn event count per dag, map til opacity/farve

#### 1B. Konfigurerbare Dagcelle-modes
- **Compact**: Kun farvede dots (nuværende)
- **Stacked**: Farvet bar per event
- **Details**: Event-titler (nuværende implementering)
- Bruger vælger mode i indstillinger

#### 1C. Pinch-to-Zoom View Switching
- Knib på månedsvisning -> uge -> dag
- Flydende animation mellem modes
- **Implementation:** `MagnificationGesture` der trigger view-skift ved tærskler

### Prioritet 2: Automatisk TODO (Mellemlang Sigt)

#### 2A. Auto-generer Todos fra Events
- "Forbered til møde" todo skabes automatisk 1 dag før møder
- "Opfølgning" todo skabes efter møder
- Konfigurerbar per kalender/kategori
- **Implementation:** Observer `EKEventStoreChanged`, scan nye events, opret linked TodoItem

#### 2B. Drag-to-Schedule Todos
- Træk todo ind på kalendervisning for at tidsblokere
- Sæt varighed ved drag-størrelse
- Todo-event link bevares
- **Implementation:** Drag & drop fra TodoListView til WeekView/DayView

#### 2C. Prioritetsbaseret Auto-planlægning
- P1-P4 prioritetshierarki
- Højere prioriteter overskriver lavere ved konflikter
- Foreslå ledige tidsslots baseret på kalender-densitet
- **Implementation:** Scan `EKEventStore` for fri tid, match med todo-prioriteter

### Prioritet 3: Udvidet Data-udnyttelse (Længere Sigt)

#### 3A. Udnyt Alle EventKit Felter
Vi bruger i dag kun en delmængde. Yderligere felter vi kan udnytte:

| Felt | Nuværende | Forslag |
|---|---|---|
| `structuredLocation` | Ikke brugt | Vis kort-preview i day zoom |
| `availability` | Ikke brugt | Farvemarkér busy/free/tentative |
| `attendees` | Ikke brugt | Vis deltagerantal og navne |
| `recurrenceRules` | Delvist | Vis gentagelsesikon i dagcelle |
| `URL` | Ikke brugt | Klikbar link i event-detaljer |
| `alarms` | Ikke brugt | Vis alarm-ikon i dagcelle |
| `notes` | Ikke brugt | Vis noter-preview i day zoom |

#### 3B. Energi-bevidst Dagsoversigt (Morgen-inspireret)
- Morgen = deep work blokke (blå)
- Eftermiddag = møder (orange)
- Aften = lette opgaver (grøn)
- Visuel tidslinje der viser energi-flow

#### 3C. Smart Kalender-filtrering
- Filtrér baseret på deltagerantal (kun store møder)
- Filtrér baseret på availability (kun optagede slots)
- Filtrér baseret på lokation (kun fysiske møder)

### Prioritet 4: Delingsoptimering

#### 4A. ICS Export med Fuld Data
- Eksportér events med alle standardfelter
- Inkluder GEO, ATTENDEE, VALARM, CATEGORIES
- Tilbyd "Del dag/uge" funktion der genererer ICS

#### 4B. Webcal Abonnementsfeed
- Publicér HejmadiWeek-events som webcal:// feed
- Andre kan abonnere på specifikke kategorier
- Opdater automatisk via CloudKit

### Samlet Roadmap

```
Sprint 1 (Nu):
  [x] Månedsvisning redesign (done)
  [x] Kalenderfilter-cirkler (done)
  [x] Day zoom overlay (done)
  [x] Todo-redigering (done)
  [ ] Heatmap i månedsvisning
  [ ] Pinch-to-zoom view switching

Sprint 2 (Næste):
  [ ] Auto-generer todos fra events
  [ ] Drag-to-schedule todos
  [ ] Udnyt structuredLocation, availability, attendees
  [ ] Konfigurerbare dagcelle-modes

Sprint 3 (Fremtid):
  [ ] Prioritetsbaseret auto-planlægning
  [ ] Energi-bevidst dagsoversigt
  [ ] ICS eksport med fuld data
  [ ] Smart kalender-filtrering
  [ ] Webcal abonnementsfeed
```

---

## Kilder

- [Notion Calendar Guide](https://skywork.ai/blog/notion-calendar-comprehensive-guide-2025)
- [Eleken Calendar UI Examples](https://www.eleken.co/blog-posts/calendar-ui)
- [BusyCal](https://www.busymac.com/busycal/)
- [Amie](https://amie.so) - [Review 2026](https://efficient.app/apps/amie)
- [Morgen AI Planner](https://www.morgen.so/ai-planner)
- [Reclaim.ai](https://reclaim.ai)
- [Vimcal vs Fantastical](https://efficient.app/compare/vimcal-vs-fantastical)
- [Google Calendar AI](https://www.usecarly.com/blog/google-calendar-ai-features)
- [EventKit Framework - Apple Developer](https://developer.apple.com/documentation/eventkit)
- [RFC 5545 - iCalendar](https://www.rfc-editor.org/rfc/rfc5545)
- [RFC 7986 - New Properties for iCalendar](https://www.rfc-editor.org/rfc/rfc7986.html)
- [WWDC23 - Discover Calendar and EventKit](https://developer.apple.com/videos/play/wwdc2023/10052/)
- [UX/UI Trends 2026](https://www.promodo.com/blog/key-ux-ui-design-trends)
- [Mobile UX Patterns 2026](https://www.sanjaydey.com/mobile-ux-ui-design-patterns-2026-data-backed/)
- [AI Calendar Market](https://cognitivefuture.ai/ai-based-calendars/)
