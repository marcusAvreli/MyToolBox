# Development Tracker — Hello World Proposal

## Goal

Build the smallest end-to-end proof of concept for a local development-time tracking product.

The first milestone is intentionally simple:

```text
Edit Hello.java
    ↓
Java WatchService
    ↓
SQLite
    ↓
Local REST API
    ↓
Angular
    ↓
D3 timeline
```

Do **not** begin with Git correlation, missions, AI estimation, SQL Server synchronization, Drupal integration, or enterprise deployment.

The Hello World is successful when modifying a Java file produces a timestamped event that can be visualized in Angular/D3.

---

## Expected Result

Create and modify:

```text
C:\DEVEL\tracker-demo\Hello.java
```

After a few saves, the application should contain events similar to:

```text
Hello.java

09:41:03  CREATED
09:41:17  MODIFIED
09:42:04  MODIFIED
09:44:31  MODIFIED
```

The D3 visualization should eventually display something like:

```text
09:41        09:42        09:43        09:44
  ●────────────●─────────────────────────●
 create       modify                      modify
```

This proves the architectural spine of the complete product.

---

# 1. Initial Runtime Architecture

Use one local Java executable.

```text
development-tracker.jar
│
├── Acquisition
│   └── Java WatchService
│
├── Persistence
│   └── SQLite
│
└── Local API
    └── HTTP / REST
          │
          ▼
       Angular
          │
          ▼
         D3
```

The Java process must continue acquiring data even when the Angular application is closed.

The logical components should remain separate even if they initially run inside one Java process.

---

# 2. First SQLite Schema

Use only one table for the Hello World.

```sql
CREATE TABLE IF NOT EXISTS file_event
(
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    event_time  TEXT NOT NULL,
    event_type  TEXT NOT NULL,
    file_path   TEXT NOT NULL
);
```

Do not add repository, mission, Git, synchronization, session, or analytics tables yet.

---

# 3. Java Dependencies

For the first version use:

```text
Java 11+
SQLite JDBC
```

Hibernate is not necessary for the Hello World.

Only two persistence operations are initially required:

```text
insertEvent(...)
findEvents(...)
```

Example Maven dependency:

```xml
<dependency>
    <groupId>org.xerial</groupId>
    <artifactId>sqlite-jdbc</artifactId>
    <version>${sqlite.version}</version>
</dependency>
```

---

# 4. Minimal Java File Watcher

```java
import java.nio.file.*;
import java.time.Instant;

public class FileWatcher {

    private final Path directory;
    private final EventRepository repository;

    public FileWatcher(
            Path directory,
            EventRepository repository) {

        this.directory = directory;
        this.repository = repository;
    }

    public void start() throws Exception {

        WatchService watchService =
            FileSystems.getDefault()
                .newWatchService();

        directory.register(
            watchService,
            StandardWatchEventKinds.ENTRY_CREATE,
            StandardWatchEventKinds.ENTRY_MODIFY,
            StandardWatchEventKinds.ENTRY_DELETE
        );

        System.out.println(
            "Watching: " + directory
        );

        while (true) {

            WatchKey key =
                watchService.take();

            for (WatchEvent<?> event :
                    key.pollEvents()) {

                Path relativePath =
                    (Path) event.context();

                String type =
                    event.kind().name();

                Instant now = Instant.now();

                System.out.println(
                    now
                        + " "
                        + type
                        + " "
                        + relativePath
                );

                repository.insert(
                    now,
                    type,
                    relativePath.toString()
                );
            }

            key.reset();
        }
    }
}
```

Initial console output might look like:

```text
2026-08-09T06:41:13Z ENTRY_CREATE Hello.java
2026-08-09T06:41:18Z ENTRY_MODIFY Hello.java
2026-08-09T06:41:52Z ENTRY_MODIFY Hello.java
```

This already demonstrates activity tracking before any Git commit exists.

---

# 5. Minimal SQLite Repository

```java
import java.sql.*;
import java.time.Instant;

public class EventRepository {

    private static final String URL =
        "jdbc:sqlite:development-tracker.db";

    public EventRepository()
            throws SQLException {

        try (
            Connection connection =
                DriverManager.getConnection(URL);

            Statement statement =
                connection.createStatement()
        ) {

            statement.execute(
                """
                CREATE TABLE IF NOT EXISTS file_event
                (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    event_time TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    file_path TEXT NOT NULL
                )
                """
            );
        }
    }

    public void insert(
            Instant time,
            String type,
            String path)
            throws SQLException {

        String sql =
            """
            INSERT INTO file_event
            (
                event_time,
                event_type,
                file_path
            )
            VALUES (?, ?, ?)
            """;

        try (
            Connection connection =
                DriverManager.getConnection(URL);

            PreparedStatement statement =
                connection.prepareStatement(sql)
        ) {

            statement.setString(
                1,
                time.toString()
            );

            statement.setString(
                2,
                type
            );

            statement.setString(
                3,
                path
            );

            statement.executeUpdate();
        }
    }
}
```

---

# 6. Minimal Agent Main Class

```java
import java.nio.file.Paths;

public class DevelopmentTracker {

    public static void main(
            String[] args)
            throws Exception {

        EventRepository repository =
            new EventRepository();

        FileWatcher watcher =
            new FileWatcher(
                Paths.get(
                    "C:/DEVEL/tracker-demo"
                ),
                repository
            );

        watcher.start();
    }
}
```

Run the tracker and modify:

```text
C:\DEVEL\tracker-demo\Hello.java
```

The resulting events should be persisted in:

```text
development-tracker.db
```

---

# 7. Local REST API

After file acquisition and persistence work, add the smallest possible local HTTP API.

For the proof of concept, the Java built-in HTTP server is sufficient. Jersey can be introduced later.

Conceptually:

```java
HttpServer server =
    HttpServer.create(
        new InetSocketAddress(
            "localhost",
            8085
        ),
        0
    );

server.createContext(
    "/events",
    exchange -> {
        // Query SQLite.
        // Serialize events as JSON.
        // Return JSON response.
    }
);

server.start();
```

Endpoint:

```text
GET http://localhost:8085/events
```

Example response:

```json
[
  {
    "time": "2026-08-09T09:41:03+03:00",
    "type": "ENTRY_CREATE",
    "file": "Hello.java"
  },
  {
    "time": "2026-08-09T09:41:17+03:00",
    "type": "ENTRY_MODIFY",
    "file": "Hello.java"
  }
]
```

---

# 8. Angular Hello World

Angular should only consume the local REST API.

Example service method:

```ts
getEvents() {
  return this.http.get<FileEvent[]>(
    'http://localhost:8085/events'
  );
}
```

Example component flow:

```ts
ngOnInit(): void {
  this.eventService
    .getEvents()
    .subscribe(events => {
      this.renderTimeline(events);
    });
}
```

Angular must not access SQLite or Git directly.

---

# 9. First D3 Visualization

Do not build a dashboard initially.

Draw one horizontal timeline.

Example input:

```ts
[
  {
    time: '2026-08-09T09:41:03',
    type: 'ENTRY_CREATE'
  },
  {
    time: '2026-08-09T09:42:17',
    type: 'ENTRY_MODIFY'
  },
  {
    time: '2026-08-09T09:44:31',
    type: 'ENTRY_MODIFY'
  }
]
```

Example scale:

```ts
const x = d3
  .scaleTime()
  .domain(
    d3.extent(
      events,
      d => new Date(d.time)
    ) as [Date, Date]
  )
  .range([40, 760]);
```

Example event rendering:

```ts
svg
  .selectAll('circle')
  .data(events)
  .join('circle')
  .attr(
    'cx',
    d => x(new Date(d.time))
  )
  .attr('cy', 80)
  .attr('r', 6);
```

Expected first visualization:

```text
Hello.java

09:41          09:42          09:43          09:44
  ●──────────────●────────────────────────────●
 CREATE         MODIFY                       MODIFY
```

---

# 10. Internal Architecture Direction

Even though the Hello World is small, keep acquisition logically separated from persistence.

Preferred dependency direction:

```text
WatchService
    ↓
DevelopmentEventPublisher
    ↓
EventRepository
    ↓
SQLite
```

A small abstraction can be introduced early:

```java
public interface DevelopmentEventPublisher {
    void publish(DevelopmentEvent event);
}
```

Initially the implementation can simply persist locally.

This makes it possible to add other consumers later without coupling `WatchService` to analytics, Git, synchronization, or messaging.

---

# 11. Relationship to `application_framework_suite`

The tracker can follow the same modular philosophy as `application_framework_suite`, while remaining a separate business application.

Start small:

```text
development-tracker-parent
│
├── tracker-core
├── tracker-acquisition
├── tracker-persistence
└── tracker-app
```

Later add:

```text
tracker-web
tracker-git
tracker-analytics
tracker-sync
```

Possible final structure:

```text
development-tracker-parent
│
├── tracker-core
│   ├── domain objects
│   ├── configuration
│   └── common tracker interfaces
│
├── tracker-acquisition
│   ├── WatchService
│   ├── recursive directory monitoring
│   ├── debounce
│   ├── SHA-256
│   └── file activity
│
├── tracker-persistence
│   ├── SQLite
│   ├── schema initialization
│   └── repositories
│
├── tracker-git
│   ├── repository detection
│   ├── branch detection
│   ├── commit scanning
│   └── commit/file statistics
│
├── tracker-analytics
│   ├── development sessions
│   ├── mission correlation
│   └── duration calculations
│
├── tracker-web
│   ├── localhost REST API
│   ├── JSON DTOs
│   └── timeline/statistics endpoints
│
├── tracker-sync
│   ├── optional enterprise synchronization
│   ├── pending/synced processing
│   └── SQL Server enterprise ingestion client
│
└── tracker-app
    ├── main()
    ├── startup
    ├── shutdown
    └── module wiring
```

Tracker-specific domain objects such as the following should stay outside the generic framework suite:

```text
FileEvent
DevelopmentSession
TrackedRepository
Mission
GitCommit
ActivityPeriod
```

---

# 12. `fw_messaging` Position

`fw_messaging` may become useful later, particularly when the system becomes asynchronous or enterprise-oriented.

Do not require JMS for the Hello World.

Initial flow:

```text
WatchService
    ↓
DevelopmentEventPublisher
    ↓
SQLite
```

Later:

```text
File activity
    ↓
DevelopmentEventPublisher
    │
    ├── SQLite persistence
    ├── Git correlation
    ├── Session analysis
    └── Synchronization
```

Enterprise messaging could eventually look like:

```text
Developer Agent
    ↓
SQLite
    ↓
Sync Service
    ↓
Enterprise Collector
    ↓
fw_messaging / JMS
    │
    ├── SQL Server ingestion
    ├── Analytics processing
    └── Audit/integration consumers
```

The `DevelopmentEventPublisher` abstraction allows this evolution without forcing messaging infrastructure into the local MVP.

---

# 13. Implementation Order

Implement features in this order:

1. Watch one directory and record events.
2. Persist events in SQLite.
3. Expose `GET /events`.
4. Render one Angular/D3 timeline.
5. Debounce duplicate `MODIFY` events.
6. Calculate SHA-256 and ignore unchanged content.
7. Add recursive directory watching.
8. Detect current Git branch.
9. Import/detect Git commits.
10. Calculate development sessions.
11. Correlate activity with a mission/branch.
12. Add local statistics.
13. Add AI-assisted estimation.
14. Add optional enterprise synchronization to SQL Server/T-SQL.
15. Add optional Drupal presentation/integration.

---

# 14. Definition of Done for Hello World

The Hello World is complete when this sequence works end to end:

```text
1. Start development-tracker.jar.

2. Create or modify:
   C:\DEVEL\tracker-demo\Hello.java

3. Java WatchService detects the event.

4. Event is written to SQLite.

5. GET /events returns the event as JSON.

6. Angular loads the JSON.

7. D3 renders a point at the correct timestamp.
```

The essential acceptance statement is:

> Change `Hello.java`, refresh Angular, and see the modification appear as a D3 point at the correct timestamp.

Once this works, the core architecture of the larger development analytics product has been proven.
