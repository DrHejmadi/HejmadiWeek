# HejmadiWeek - Kalenderapp Oplæg

## Vision
En premium kalenderapp til hele Apple-økosystemet (iPhone, iPad, Mac, Apple Watch) med **det bedste månedsoverblik** på markedet. Inspireret af Week Calendar (WeekCal), men med moderne design, AI-funktioner og en "monthly-first" tilgang.

---

## 1. Konkurrentanalyse

### WeekCal (Week Calendar - Smart Planner)
**Styrker:**
- Dense, informationsrig Mini Month-visning med farveikoner der fungerer som heatmap
- Drag-and-drop rescheduling, tap-and-hold event creation
- Farveautomatisering baseret på titel/noter/lokation
- Event-templates til tilbagevendende begivenheder
- Synkronisering med iCloud, Google, Exchange/Outlook, Yahoo, CalDAV
- Vejrudsigt integreret i kalenderen
- Populære kalendere (sport, helligdage, natur)
- Apple Watch support

**Svagheder:**
- UI føles dateret/utilitarisk - travlt for moderne smag
- Aggressive in-app subscription-reklamer (brugere beskriver dem som "fuldstændig uacceptable")
- iPhone- og iPad-versionerne er separate køb
- Ikke universal app - mange finder dette uacceptabelt i 2026
- Innovationstakten er faldet

**Vores mulighed:** WeekCal er sårbar på tillid, forretningsmodel og platform-konsistens. En app med ét køb/abonnement der dækker alle enheder, ingen aggressive upsells, og et ægte "monthly-first" design kan stjæle kernebrugerne.

### Fantastical (Flexibits)
- **Styrke:** Æstetisk month view med heatmap, natural language input, polished design, 1:1 featureparitet Mac/iOS
- **Svaghed:** Dyrt abonnement (~$57/år individuelt), innovationstakt er aftaget, mange power users forlader platformen

### BusyCal
- **Styrke:** Fleksibel Week View (2-90 dage), nested Smart Filters, Calendar Sets med auto-switch, multiple tidszoner, tilpas font/farver/tidsformat, Info Panel sidebar
- **Svaghed:** Komplekse indstillinger, stejl læringskurve, month view mangler elegance

### Calendars by Readdle
- **Styrke:** Visuel balance, god drag-and-drop, naturligt sprog, $7/år (billigt), alle Apple-platforme
- **Svaghed:** Feature-paritet mellem Mac/iOS er inkonsistent

### Timepage (Moleskine)
- **Styrke:** Smuk, unik visuel identitet med heatmap-farver, vejr-integration, fantastisk rejsetids-visning
- **Svaghed:** Begrænset funktionalitet, kun iOS, ingen Mac-app

### Apple Calendar
- **Styrke:** Gratis, nul friktion, perfekt sync, Siri-integration
- **Svaghed:** Mangler ugenumre, event-densitet i grid, ingen power-user features

---

## 2. Must-Have Features (Baseline)

### Kalendervisninger
- **Dag** - Tidslinje med farveblokke
- **Uge** - Konfigurerbar (2-14 dage)
- **Mini Måned** - Hybrid liste/grid (WeekCals signatur)
- **Måned** - VORES DIFFERENTIATOR (se sektion 3)
- **År** - Heatmap overblik
- **Agenda** - Scrollende liste

### Kernefeatures
- Drag-and-drop rescheduling (inkl. mellem dage i month view)
- Natural language event creation ("Frokost med Sarah tirsdag kl 12")
- Multi-konto support (iCloud, Google, Exchange/Outlook, CalDAV)
- Farvekodet kategorisering med auto-regler
- Event-templates og gentagelsesmønstre
- Rejsetid med Apple Maps integration
- Vejrudsigt overlay
- Ugenumre (vigtigt for Skandinavien/Europa)
- Alternate kalendere (kinesisk, hebraisk, islamisk)
- Deltagerstyring og invitation via email/iMessage
- Join Meeting-knap til Zoom/Teams/Meet
- Reminders/Tasks integration i dedikeret visning
- Mørk tilstand + tilpasbare farveskemaer
- Tilpasseligt appikon (10+ farver)

---

## 3. Månedsoverblik - Vores Differentiator

### Design-filosofi: "Information Dense, Yet Calm"
Månedsvisningen skal vise MERE data end konkurrenterne, men føles RENERE.

### Tre informationslag
1. **Grid-lag:** Kalendergrid med farvekodede dots/bars der viser event-densitet per dag
2. **Preview-lag:** Tryk på en dag -> inline preview-panel glider op med dagens events (uden at forlade month view)
3. **Detail-lag:** Tryk på event i preview -> full event detaljer

### Innovative month view features
- **Heatmap-densitet:** Farveintensitet på hver dag viser hvor travl dagen er (grøn = ledig, rød = booket)
- **Event-bars:** Flerredges-events vises som farvede bjælker der spænder over dage (som Google Calendar desktop)
- **Quick-add i grid:** Long-press på en dag opretter event direkte i month view
- **Pinch-to-zoom:** Zoom mellem compact month (6 uger synlige) og expanded month (3 uger med mere detalje)
- **Scroll between months:** Vertikal scroll mellem måneder (uendeligt scrollende)
- **Drag events mellem dage:** Direkte i month view grid
- **Kontekst-sidebar (iPad/Mac):** Valgt dag viser fuld dagsoversigt i sidebar
- **Ugenummer-kolonne:** Klikbar for at åbne ugevisning

### UX-mønstre for Monthly View (fra Claude.ai analyse)

**Day Peek:** Tap på en dag åbner en "day peek" - en halvskærm der glider op med fuld dags-agenda. Ingen navigation væk fra monthly view.

**Event-density management:**
- Dage med > 3 events viser "komprimeret stack" - et lille chip-bundt med antal. Tap expander
- Tidlige morgen-events og sene aften-events kan collapses til "off-hours" indikator
- All-day events vises i en dedikeret top-strip per uge, ikke i dag-cellen selv

**Farvehierarki:**
- Kalender-farve er primær identifikation
- Event-prioritet (High/Normal/Low) tilføjer en subtil ring-signatur, *ikke* en anden farve
- Konflikter markeres med en orange kant på de involverede events - synlig i monthly view

**Typografi:**
- Dag-numre: stor, fed, høj kontrast
- Event-titler: lille, men aldrig under 11pt (accessibility)
- "Tomme" dage i grå; "i dag" i accent-farve; weekends i en subtil anden nuance

**Gestik-arkitektur:**
- Swipe op/ned: forrige/næste måned (med naturlig momentum)
- Pinch: zoom ud til år-view; zoom ind til uge-view
- Long-press: quick-add event
- Drag: flyt event mellem dage

### Konklusionsmatrix (fra Claude.ai)

| App | Monthly UX | Æstetik | Platform | Pris | Innovation |
|-----|-----------|---------|----------|------|------------|
| WeekCal | 3/5 | 3/5 | iOS/iPadOS | $7,5/år | 2/5 |
| Fantastical | 4/5 | 5/5 | Alle Apple | $57/år | 3/5 |
| BusyCal | 4/5 | 3/5 | Mac/iOS | $50 engang | 4/5 |
| Timepage | 5/5 | 5/5 | iOS/Mac | $20/år | 4/5 |
| Apple Cal | 2/5 | 3/5 | Alle | Gratis | 1/5 |

**Din niche:** Ingen af dem er designet fra bunden med monthly overview som primær view. De er alle enten weekly-first eller list-first. Det er din åbning.

**ChatGPT-indsigt:** WeekCals month view er speciel fordi den maksimerer informations-densitet og kontrol på et måneds-canvas. Fantastical behandler month view som et navigations-lag (farvedots der synkroniserer med en schedule nedenunder). BusyCal er den tætteste power-user rival - dens month view kan omdefineres til at vise 1-12 uger med font, farver, og tidsformat-tilpasning. Calendars by Readdle er i stigende grad et planner-produkt med habits og reflections. Men ingen har "best month grid" som deres primære identity.

### iPad/Mac specifikt
- Split view: Måned til venstre, dagdetaljer til højre
- Multi-window support (Stage Manager)
- Keyboard shortcuts (piltaster til navigation, Enter for ny event)

---

## 4. Innovative Features (2026 Differentiering)

### AI-Powered Time Intelligence
- **Smart Scheduling:** Foreslå bedste tidspunkt for nye events baseret på mønstre og energiniveauer
- **Prep Time:** Automatisk buffertid før vigtige møder
- **Predictive Travel:** Realtids-trafik justerer automatisk rejsetid-buffere
- **Kompleks NL:** "Planlæg et 1-times opfølgningsmøde med Sarah 3 dage efter vores møde tirsdag"
- **Schedule Suggestions:** "Du har ingen pauser mellem 9-17 i morgen - vil du flytte noget?"

### Natural Language Input (NLI)
- Kontekstuel NLI der forstår dansk ("tandlæge fredag eftermiddag" -> finder næste ledige fredag eftermiddag, tilføjer rejsetid fra din lokation)
- Kompleks logik: "Planlæg et 1-times opfølgningsmøde med Sarah 3 dage efter vores møde tirsdag"

### Sundhedsintegration (HealthKit)
- Vis søvndata fra Apple Health som baggrundsslag på monthly view (dage med dårlig søvn farves subtilt)
- Blokér automatisk "restitution" efter hård træning
- Synkroniser menstruationscyklus fra Health til calendar events (kræver omhyggeligt privacy-design)
- Vis energiniveau-estimat per dag baseret på HRV/søvn/aktivitet
- Stressniveau-indikator baseret på HRV-data

### Focus Mode Integration
- Automatisk skift mellem "Arbejde" og "Privat" kalendervisning baseret på iOS Focus
- "Arbejdsfokus" skjuler private events, "Personlig" skjuler arbejdsmøder
- Automations: Events med tag "Deep Work" aktiverer automatisk Focus Mode
- "Share Availability" status ændres automatisk
- Filtrering af kalendere per Focus Mode

### Rejsetid og Vejr i Monthly View
- Mini-vejrikon per dag i monthly view
- Farvekodet rejsetidsindikator på days med back-to-back events i forskellig lokation
- Live trafikdata som "Time to Leave"-alarmer (inspireret af BusyCal)

### Live Activities (Dynamic Island)
- Aktiveres automatisk 30 min før event
- Viser: event-navn, countdown, rejsetid i realtid (MapKit)
- Expanded state: kort til location, deltagere, noter
- "Running Late"-knap der sender pre-formateret besked til deltagere
- Ingen eksisterende kalenderapp udnytter dette optimalt - det er en åbning

### Kontekst-bevidst Planlægning
- Personal/Work toggle der re-filtrerer hele UI (inkl. widgets og complications)
- Lokationsbaseret auto-switch mellem kalender-sets
- "Travlheds-score" for ugen/måneden

### Social Features
- Delt kalendervisning med familie/partner
- "Stress-level" overlay for familiekalendere baseret på event-densitet
- Availability sharing link (som Calendly, men built-in)

---

## 5. Teknisk Arkitektur

### Platform: SwiftUI Multiplatform
```
HejmadiWeek/
├── HejmadiWeekApp/          # Shared SwiftUI app entry
├── Packages/
│   ├── HWCore/              # Pure Swift package - models, business logic
│   │   ├── Models/          # SwiftData @Model klasser
│   │   ├── Services/        # EventKit, CloudKit, sync logic
│   │   └── AI/              # Scheduling intelligence
│   ├── HWUI/                # Shared SwiftUI views
│   │   ├── MonthView/       # Månedsoverblik komponenter
│   │   ├── DayView/
│   │   ├── WeekView/
│   │   ├── EventEditor/
│   │   └── Components/      # Genbrugelige UI-komponenter
│   └── HWWidgets/           # Widget + Live Activity targets
├── iOS/                     # iPhone-specifik kode
├── iPadOS/                  # iPad-specifik layout
├── macOS/                   # Mac-specifik (menulinje, shortcuts)
├── watchOS/                 # Apple Watch app
└── Tests/
```

### Data Layer (fra Claude.ai arkitektur-analyse)
- **SwiftData** med `@Model` macro for alle entiteter
- Brug `ModelContainer` med `CloudKitDatabase` for automatisk iCloud-sync
- Opret et separat `localOnly` store til kladder og AI-genererede forslag der ikke skal synkroniseres
- **EventKit** er stadig obligatorisk: SwiftData gemmer *dine* ekstra metadata (farvetags, AI-noter, HealthKit-links), men selve events lever i EventKit/CalDAV-lageret
- Arkitekturen bliver: **EventKit** (source of truth for events) -> **SwiftData-model** (metadata-lag) -> **CloudKit** (sync af metadata)
- **Model Inheritance** for forskellige event-typer (Appointment, Habit, Task)

### EventKit-integration
- Brug `EKEventStore` med proper authorization flow
- Lyt på `EKEventStoreChangedNotification` for at holde din lokale cache synkron
- Hent events batch-vis med `EKEventStore.events(matching:)` med et `NSPredicate`-baseret tidsvindue (typisk +/- 6 måneder fra visning)

### Sync Strategi
- EventKit som primær datakilde (læs fra systemkalender)
- SwiftData/CloudKit til app-specifikke data (templates, preferences, AI-data)
- Offline-first: Alt fungerer uden netværk
- Conflict resolution: Last-write-wins med merge for noter

### Performance på Monthly View
Monthly view er det mest datakrævende view - du renderer potentielt 5-6 uger x 7 dage x N events. Kritiske valg:
- Forhåndshent 3 måneder frem og 1 måned tilbage i baggrunden ved app-launch
- Brug `LazyVGrid` med fixede celledimensioner - *ikke* dynamisk højde per celle
- Cache rendered event-chips som `@State`-arrays per dag - genbrug dem ved scroll
- Brug `background(in:)` og `drawingGroup()` modifier til komplekse grafiklag (heatmap, vejr-overlays)

### Concurrency
- `@MainActor` for UI-heavy kalender-rendering
- Background actors for CloudKit sync og EventKit queries
- Structured concurrency med TaskGroups for parallel data loading

### Key Frameworks
- **EventKit** - Kalender og Reminders API
- **WeatherKit** - Vejrudsigt
- **MapKit** - Rejsetid beregning
- **HealthKit** - Søvn, træning, HRV data
- **WidgetKit** - Widgets og Live Activities
- **WatchConnectivity** - Watch <-> iPhone kommunikation
- **AppIntents** - Siri integration og Shortcuts

---

## 6. Widget Strategi

### iOS/iPadOS Widgets
| Størrelse | Indhold |
|-----------|---------|
| **Small** | Næste event + countdown |
| **Medium** | Dagens agenda (3-4 events) |
| **Large** | Mini-månedsgrid med event-dots + dagens agenda |
| **Extra Large** (iPad) | Fuld månedsvisning med event-bars |

### Interaktive Widgets (iOS 17+)
- Check-off tasks direkte fra widget
- "Join Meeting" knap på næste virtuelle møde
- Quick-add event knap
- "Running Late" knap der sender besked til deltagere

### Live Activities
- **Event Countdown:** Når event er inden for 30 min, vis countdown på Lock Screen og Dynamic Island
- **Rejse-tracking:** Vis rejsetid til næste event med live trafik
- **"I et møde":** Vis current meeting med sluttid

### macOS Widgets
- Menu bar widget med dagens agenda
- Desktop widget med månedsvisning
- Notification Center widget

---

## 7. Apple Watch

### Watch App-filosofi
Watch er *ikke* en miniaturiseret iPhone-kalender. Den er et "hvad sker der lige nu/snart"-instrument.

### Complications
| Type | Indhold |
|------|---------|
| **Graphic Circular** | Pie-chart af dagen (arbejde/personlig/fri) |
| **Modular Large** | Næste event + tid + rejsetid-advarsel |
| **Rectangular** | Næste 2 events med tid og titel |
| **Inline** | "2 events - Næste: Tandlæge 14:00" |
| **Corner** | Tidspunkt for næste event |

### Standalone Watch App
- **Mini-månedsvisning** med Digital Crown zoom (compact <-> detailed)
- **Dagens agenda** med scroll
- **Quick-add** event via voice/scribble
- **Smart Stack** integration - Siri foreslår kalenderen på relevante tidspunkter
- **Offline-first** - fungerer uden iPhone via WatchConnectivity + lokalt cache
- **Data sync minimal** - Watch skal kun hente 48 timer frem og 24 timer tilbage
- **Haptic reminders** - customizable vibrations per kalender

---

## 8. Monetisering

### Anbefalet: Freemium + Subscription + Lifetime

**Gratis (HejmadiWeek Free):**
- Alle grundlæggende kalendervisninger inkl. måned
- 1 widget
- EventKit sync (iCloud/Google/Exchange)
- Basic farvetemaer

**HejmadiWeek Pro (Subscription: 49 DKK/år ELLER 249 DKK lifetime):**
- Alle widgets (small/medium/large/XL)
- Live Activities
- Alle visninger inkl. Year
- Ubegrænsede farvetemaer og app-ikoner
- Event-templates
- Vejrudsigt overlay
- Populære kalendere
- Apple Watch app med complications

**HejmadiWeek AI (Tilkøb: 29 DKK/md):**
- AI smart scheduling
- Sundhedsintegration (HealthKit)
- Predictive travel time
- Schedule optimization forslag
- "Running Late" auto-messaging

### Prissætnings-rationale
- Subscription fatigue er den #1 klage - derfor tilbyd lifetime
- AI-features kræver serverside processing - berettiget som separat subscription
- Gratis tier skal være god nok til at skabe word-of-mouth
- Universal app - ÉT køb dækker iPhone, iPad, Mac, Watch

### Vigtige principper (fra Claude.ai)
- Ét abonnement dækker iPhone, iPad, Mac, Watch - *uden undtagelse*
- Gratis-niveau er genuint brugbart (ikke artificielt kastreret)
- Aldrig in-app reklamer - hverken på gratis eller Pro
- Family Sharing understøttes
- WeekCals primære kritik er opdelt platformkøb og aggressiv upsell - undgå dette totalt

---

## 9. Accessibility

- Full VoiceOver support med semantiske labels på alle calendar grid celler
- Dynamic Type support (tilpas tekststørrelse)
- Reduce Motion respekteret (ingen animationer)
- Høj kontrast-tilstand
- Switch Control kompatibel
- Keyboard navigation (Mac/iPad med tastatur)
- Farveblindhedsvenlige paletter (ikke kun farve som indikator - brug også former/ikoner)
- Haptic feedback på Watch og iPhone
- Siri Shortcuts til alle hovedhandlinger

---

## 10. Udviklings-Roadmap

### Fase 1: MVP (3-4 måneder)
- [ ] SwiftUI multiplatform projekt setup med SPM packages
- [ ] EventKit integration (læs/skriv fra systemkalender)
- [ ] Månedsvisning (heatmap + preview panel)
- [ ] Dag- og ugevisning
- [ ] Grundlæggende event CRUD
- [ ] iPhone + iPad layout
- [ ] Mørk tilstand
- [ ] 1 widget (medium - dagens agenda)

### Fase 2: Core Features (2-3 måneder)
- [ ] Mac app (Catalyst eller native macOS target)
- [ ] Drag-and-drop i alle views
- [ ] Natural language event creation
- [ ] Event-templates og gentagelser
- [ ] Alle widget-størrelser
- [ ] Farvetemaer og app-ikoner
- [ ] Ugenumre
- [ ] Rejsetid integration

### Fase 3: Watch + Premium (2 måneder)
- [ ] Apple Watch app med complications
- [ ] Live Activities
- [ ] Vejrudsigt overlay
- [ ] Populære kalendere
- [ ] Pro subscription / IAP implementation
- [ ] TestFlight beta

### Fase 4: AI + Innovation (2-3 måneder)
- [ ] AI scheduling engine
- [ ] HealthKit integration
- [ ] Focus Mode integration
- [ ] Smart suggestions
- [ ] Availability sharing
- [ ] App Store launch

---

## 11. Teknisk Stack Oversigt

| Komponent | Teknologi |
|-----------|-----------|
| UI Framework | SwiftUI |
| Data Persistence | SwiftData |
| Cloud Sync | CloudKit (via SwiftData) |
| Calendar API | EventKit |
| Weather | WeatherKit |
| Maps/Travel | MapKit |
| Health Data | HealthKit |
| Widgets | WidgetKit |
| Watch Comm | WatchConnectivity |
| AI/ML | Core ML + server-side API |
| Voice | AppIntents (Siri) |
| Notifications | UserNotifications + Live Activities |
| Analytics | TelemetryDeck (privacy-first) |
| Crash Reporting | Apple's built-in crash reports |
| CI/CD | Xcode Cloud |

---

## 12. Brugerklager at Løse

Baseret på research af eksisterende apps' reviews, er disse de hyppigste klager:

1. **"Sync Conflict Ghosting"** - Events forsvinder eller duplikeres mellem Mac/iPhone -> Løs med robust EventKit-baseret sync + conflict UI
2. **"Subscription Fatigue"** - Brugere hader at betale monthly for "bare en kalender" -> Tilbyd lifetime option
3. **"Information Overload"** - Månedsvisninger der ligner hav af dots uden kontekst -> Vores 3-lags month view løser dette
4. **"Aggressive upsells"** - WeekCals store svaghed -> Ingen nag-screens, fair gratis-tier
5. **"Separate køb per enhed"** - Universal app fra dag 1
6. **"Manglende ugenumre"** - Standard feature i vores app
7. **"Kan ikke se events i month view"** - Vores event-bars og inline preview løser dette

---

## Research Kilder
- App Store: Week Calendar - Smart Planner (analyseret via Apple App Store DK)
- Gemini 3 deep research: Competitive analysis, architecture, monetization
- Claude.ai Sonnet 4.6: WeekCal styrker/svagheder, konkurrentanalyse
- ChatGPT 5.4 Thinking: Extended research (stadig i gang under kompilering)
- Web: TechRadar, Zapier, Readdle, BusyMac, SetApp - kalenderapp sammenligninger 2026
