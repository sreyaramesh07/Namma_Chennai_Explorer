"""Flask V3 web application for Namma Chennai Explorer."""

import os
from decimal import Decimal, InvalidOperation

import mysql.connector
from dotenv import load_dotenv
from flask import Flask, render_template, request, send_from_directory
from mysql.connector import Error

load_dotenv()

app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY", "change-this-in-production")

ALLOWED_DURATIONS = {1, 2, 3}
INTEREST_CATEGORIES = {
    "Food": ("Food",),
    "Beach": ("Beach",),
    "History": ("Historical Place", "Museum", "Temple"),
    "Shopping": ("Shopping",),
    "Nature": ("Nature", "Park"),
    "Entertainment": ("Entertainment",),
}


def database_config():
    """Build the connection settings without placing credentials in source code."""
    return {
        "host": os.getenv("MYSQL_HOST", "localhost"),
        "port": int(os.getenv("MYSQL_PORT", "3306")),
        "user": os.getenv("MYSQL_USER", "root"),
        "password": os.getenv("MYSQL_PASSWORD", ""),
        "database": os.getenv("MYSQL_DATABASE", "namma_chennai"),
    }


def get_connection():
    return mysql.connector.connect(**database_config())


def parse_preferences(form):
    """Validate browser input and return a clean preferences dictionary."""
    errors = []
    try:
        duration = int(form.get("duration", ""))
        if duration not in ALLOWED_DURATIONS:
            errors.append("Please choose a trip duration between 1 and 3 days.")
    except ValueError:
        duration = None
        errors.append("Please choose your trip duration.")

    budget_text = form.get("budget", "").replace(",", "").replace("₹", "").strip()
    try:
        budget = Decimal(budget_text)
        if budget <= 0:
            errors.append("Your budget must be greater than ₹0.")
        elif budget > Decimal("100000"):
            errors.append("Please enter a realistic trip budget.")
    except (InvalidOperation, ValueError):
        budget = None
        errors.append("Please enter a valid budget, for example 1000.")

    interests = [item for item in form.getlist("interests") if item in INTEREST_CATEGORIES]
    if not interests:
        errors.append("Select at least one interest so we can personalise your plan.")

    starting_point = form.get("starting_point", "").strip()
    if not starting_point:
        errors.append("Please enter your starting point.")
    elif len(starting_point) > 100:
        errors.append("Your starting point is too long.")

    return {
        "duration": duration,
        "budget": budget,
        "interests": interests,
        "starting_point": starting_point,
    }, errors


def fetch_places(interests, budget):
    """Retrieve matching place data from MySQL using a parameterised query."""
    categories = [category for interest in interests for category in INTEREST_CATEGORIES[interest]]
    placeholders = ", ".join(["%s"] * len(categories))
    query = f"""
        SELECT place_id, name, category, description, location, estimated_cost,
               visit_duration,
               TIME_FORMAT(opening_time, '%%h:%%i %%p') AS opening_time,
               TIME_FORMAT(closing_time, '%%h:%%i %%p') AS closing_time,
               best_time_to_visit
        FROM places
        WHERE category IN ({placeholders}) AND estimated_cost <= %s
        ORDER BY estimated_cost ASC, name ASC
    """
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute(query, (*categories, budget))
        return cursor.fetchall()
    finally:
        cursor.close()
        connection.close()


def nearby_score(location, starting_point):
    """Lightweight locality prioritisation; place records themselves remain in MySQL."""
    location = location.casefold()
    start = starting_point.casefold()
    if start in location or location in start:
        return 3
    nearby_areas = {
        "egmore": {"nungambakkam", "marina", "triplicane", "george town", "mylapore"},
        "central": {"egmore", "marina", "triplicane", "george town", "nungambakkam"},
        "mylapore": {"adyar", "besant nagar", "marina", "triplicane", "teynampet"},
        "t. nagar": {"teynampet", "nungambakkam", "mylapore", "velachery"},
    }
    return 1 if location in nearby_areas.get(start, set()) else 0


def build_recommendations(places, preferences):
    """Prioritise interest/location matches and keep the selected plan within budget."""
    category_order = {
        category: len(preferences["interests"]) - index
        for index, interest in enumerate(preferences["interests"])
        for category in INTEREST_CATEGORIES[interest]
    }
    ranked = sorted(
        places,
        key=lambda place: (
            -category_order.get(place["category"], 0),
            -nearby_score(place["location"], preferences["starting_point"]),
            Decimal(place["estimated_cost"]),
        ),
    )
    target_count = preferences["duration"] * 3
    selected, total = [], Decimal("0")
    for place in ranked:
        cost = Decimal(place["estimated_cost"])
        if total + cost <= preferences["budget"] and len(selected) < target_count:
            selected.append(place)
            total += cost

    # A free/low-cost fallback ensures a useful plan when a strict match is scarce.
    if len(selected) < min(2, target_count):
        used_ids = {place["place_id"] for place in selected}
        try:
            fallback = fetch_places(list(INTEREST_CATEGORIES), preferences["budget"])
        except Error:
            fallback = []
        for place in sorted(fallback, key=lambda item: Decimal(item["estimated_cost"])):
            cost = Decimal(place["estimated_cost"])
            if place["place_id"] not in used_ids and total + cost <= preferences["budget"]:
                selected.append(place)
                used_ids.add(place["place_id"])
                total += cost
            if len(selected) >= target_count:
                break
    return selected, total


@app.get("/")
def index():
    return render_template("index.html")


@app.get("/style.css")
def legacy_styles():
    """Serve the original stylesheet without changing its design or URLs."""
    return send_from_directory(app.root_path, "style.css")


@app.post("/plan")
def plan_trip():
    preferences, errors = parse_preferences(request.form)
    if errors:
        return render_template("index.html", errors=errors, form_data=request.form), 400

    try:
        places = fetch_places(preferences["interests"], preferences["budget"])
        recommendations, total_cost = build_recommendations(places, preferences)
    except Error:
        return render_template(
            "index.html",
            errors=["We could not reach the trip database. Please check the MySQL settings and try again."],
            form_data=request.form,
        ), 503

    message = None
    if not recommendations:
        message = "We could not find places within this budget. Try a higher budget or choose more interests."
    elif len(recommendations) < preferences["duration"] * 3:
        message = "Here are the closest matches available within your budget."
    return render_template(
        "results.html", preferences=preferences, places=recommendations,
        total_cost=total_cost, message=message,
    )


if __name__ == "__main__":
    app.run(debug=os.getenv("FLASK_DEBUG", "true").lower() == "true")
