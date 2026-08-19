# Netflix Database Clone (MySQL Portfolio Project)

A fully normalized, realistic **relational database clone** inspired by a Netflix-style streaming catalog — built in MySQL 8+ as a SQL practice and portfolio project.

> ⚠️ **Disclaimer:** This is an independent **learning/portfolio project**. It is not affiliated with, endorsed by, or sourced from Netflix, Inc. All titles, actors' filmographies, ratings, and descriptions are either fictional or used purely for educational database-design purposes.

## 📌 Project Overview

This project models a streaming platform's core catalog: movies, TV shows, actors, genres, and ratings, connected through properly normalized junction tables. It was built to demonstrate:

- Relational schema design (3NF)
- Primary/foreign keys, constraints (`CHECK`, `UNIQUE`, `NOT NULL`, `DEFAULT`)
- Many-to-many relationship modeling with junction tables
- A polymorphic-style relationship (`ratings` → either a movie or a show) implemented safely with real foreign keys
- Realistic, internally consistent sample data (50 actors, 32 movies, 22 TV shows, 15 genres, 99 relationship rows, 54 ratings)
- SQL querying from beginner to advanced (joins, aggregation, subqueries, CTEs, window functions)

## 🗂️ Repository Structure

```text
netflix-database-clone/
│
├── README.md                    ← you are here
├── schema.sql                   ← database + table + index definitions only
├── data.sql                     ← all INSERT statements (genres, actors, movies, shows, ratings)
├── queries.sql                  ← 33 practice queries, beginner → advanced, each explained
```

## 🧩 Entity-Relationship Overview

```text
Movies
   |
   |--- movie_genres  (M:N) --- Genres
   |--- movie_actors  (M:N) --- Actors
   |--- Ratings       (1:1 per rating row, content_type = 'movie')

TV_Shows
   |
   |--- show_genres   (M:N) --- Genres
   |--- show_actors   (M:N) --- Actors
   |--- Ratings       (1:1 per rating row, content_type = 'show')
```

**Relationship types**

| Relationship | Type | How it's modeled |
|---|---|---|
| Movie ↔ Genre | Many-to-many | `movie_genres` junction table |
| Show ↔ Genre | Many-to-many | `show_genres` junction table |
| Movie ↔ Actor | Many-to-many | `movie_actors` junction table (with `role_name`) |
| Show ↔ Actor | Many-to-many | `show_actors` junction table (with `role_name`) |
| Movie/Show → Rating | One-to-many | `ratings.movie_id` / `ratings.show_id`, mutually exclusive via `content_type` + `CHECK` constraint |

**Why junction tables?** A movie can belong to several genres and a genre applies to many movies — a plain foreign key can only point one way, so a many-to-many relationship needs its own table holding pairs of foreign keys (one row per valid combination).

**Why the `ratings` design avoids a bad "polymorphic" pattern:** Rather than one nullable "content_id" column with no real foreign key (which MySQL cannot validate), `ratings` has *two* nullable foreign keys (`movie_id`, `show_id`) plus a `content_type` flag and a `CHECK` constraint that enforces exactly one of them is populated and it matches `content_type`. This keeps referential integrity fully enforced by the database engine.

## 🚀 Getting Started (MySQL Workbench)

1. **Open MySQL Workbench** and connect to your local MySQL 8+ server.
2. **Open a new SQL tab** (File → New Query Tab, or `Ctrl+T`).
3. **Paste the contents of `netflix_clone_complete.sql`** into the tab (this single file drops/recreates the database, builds every table, and loads all sample data).
4. **Execute** the whole script (the lightning-bolt icon, or `Ctrl+Shift+Enter` to run all statements).
5. **Refresh the Schemas panel** (right-click in the Navigator → Refresh All, or click the refresh icon) so `netflix_clone` appears.
6. **Expand `netflix_clone` → Tables** to see all 8 tables (`movies`, `tv_shows`, `actors`, `genres`, `movie_genres`, `show_genres`, `movie_actors`, `show_actors`, `ratings`).
7. **View table data** by right-clicking any table → "Select Rows – Limit 1000", or just `SELECT * FROM movies;`.
8. **Generate the EER diagram**: Database menu → "Reverse Engineer…" → pick the `netflix_clone` schema → follow the wizard. Once generated, export it as an image (File → Export → Export as PNG) and save it as `er_diagram.png` in this repo.
9. **Run the practice queries**: open `queries.sql` in a new tab and run them one at a time (or highlight a block and run selection) to practice joins, aggregation, subqueries, CTEs, and window functions.

## 🎯 Practice Queries

`queries.sql` contains 33 queries split into three tiers, each with a comment explaining **what it does**, **which SQL concept it teaches**, and the **expected result shape**:

- **Beginner (10):** `SELECT`, `WHERE`, `ORDER BY`, `LIKE`, `DISTINCT`, `IS NULL`, basic joins through a junction table
- **Intermediate (12):** `INNER JOIN`, `LEFT JOIN`, `GROUP BY`, `HAVING`, `COUNT`/`AVG`/`MIN`/`MAX`, multi-table joins, `UNION ALL`, `GROUP_CONCAT`
- **Advanced (11):** correlated subqueries, CTEs (`WITH`), window functions (`RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `SUM() OVER()`), `CASE` expressions, "most active actor," "top movie per genre," and year-over-year content analysis

## 🛠️ Tech / Design Notes

- **Engine:** InnoDB (foreign key + transaction support)
- **Character set:** `utf8mb4` for full Unicode support (accented names, international titles)
- **Normalization:** 3NF — no repeating groups, all non-key attributes depend only on the primary key, many-to-many relationships fully decomposed into junction tables
- **Data quality rules enforced by constraints:**
  - `end_year >= release_year` (or `NULL` for ongoing shows)
  - `rating_value BETWEEN 0 AND 10`
  - `duration_minutes > 0`, `number_of_seasons > 0`
  - `date_of_birth` cannot be in the future
  - Every actor credit references a movie/show released after that actor could plausibly have worked (all 50 actors have birth years early enough for every title in the dataset)

## 📈 Possible Extensions

- Add a `users` + `watch_history` table to model viewing behavior
- Add a `directors` table and a `movie_directors` / `show_directors` junction
- Add full-text search indexes on `title`/`description`
- Build a small reporting layer (views) on top of the advanced queries

## 📄 License

This project is released for educational/portfolio use. Sample data is fictional and not sourced from any proprietary Netflix database.

## 👤 Author

**Fuzail Salmani**

SQL Database Project | Netflix Clone

---

⭐ If you found this project useful, consider giving the repository a star!
