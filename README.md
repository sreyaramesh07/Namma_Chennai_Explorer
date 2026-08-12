# Namma Chennai Explorer V3

V3 keeps the existing Namma Chennai Explorer design and adds a Flask + Python + MySQL trip planner. Visitors can choose a 1–3 day trip, budget, interests and starting point to receive database-driven recommendations.

## Setup

1. Create a virtual environment (optional but recommended): `python -m venv .venv`
2. Activate it on PowerShell: `.\.venv\Scripts\Activate.ps1`
3. Install packages: `pip install -r requirements.txt`
4. Copy `.env.example` to `.env`, then set your MySQL password.
5. In MySQL Workbench, run `database.sql` to create/upgrade and seed `namma_chennai`.
6. Start the app: `python app.py`
7. Open `http://127.0.0.1:5000`.

## Project files

- `app.py` — Flask routes, validation, MySQL access and recommendation logic.
- `database.sql` — repeatable database schema upgrade and place data.
- `templates/` — original-style homepage and results page.
- `style.css` — original site stylesheet, deliberately retained.
- `static/css/v3.css` — small V3 form and results-card additions.
- `.env.example` — safe configuration template; real credentials stay in `.env`.
