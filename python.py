"""Namma Chennai Explorer V1 - a simple Python and MySQL project."""

import mysql.connector
from mysql.connector import Error


# Change these values to match your MySQL Workbench/MySQL Server login.
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "YOUR_MYSQL_PASSWORD",
    "database": "namma_chennai",
}


def connect_database():
    """Connect to the namma_chennai MySQL database."""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            print("Connected to the Namma Chennai database.\n")
            return connection
    except Error as error:
        print("Could not connect to MySQL:", error)
        print("Run database.sql first and check DB_CONFIG in python.py.")
    return None


def print_places(rows):
    """Display place rows in an easy-to-read format."""
    if not rows:
        print("No places found.\n")
        return

    for row in rows:
        print(f"\n{row[0]}. {row[1]} ({row[2]})")
        print(f"Location: {row[3]}")
        print(f"Description: {row[4]}")
        print(f"Entry fee: Rs. {row[5]}")
        print(f"Hours: {row[6]} - {row[7]}")
        print(f"Best time to visit: {row[8]}")
    print()


def show_all_places(connection):
    """Show every place stored in the database."""
    query = """SELECT place_id, name, category, location, description,
                      entry_fee, opening_time, closing_time, best_time_to_visit
               FROM places ORDER BY name"""
    cursor = connection.cursor()
    cursor.execute(query)
    print_places(cursor.fetchall())
    cursor.close()


def search_by_category(connection):
    """Find places using a category entered by the user."""
    category = input("Enter category (example: Beach, Temple, Museum): ").strip()
    if not category:
        print("Please enter a category.\n")
        return

    query = """SELECT place_id, name, category, location, description,
                      entry_fee, opening_time, closing_time, best_time_to_visit
               FROM places WHERE category LIKE %s ORDER BY name"""
    cursor = connection.cursor()
    cursor.execute(query, (f"%{category}%",))
    print_places(cursor.fetchall())
    cursor.close()


def search_by_location(connection):
    """Find places using a location or area entered by the user."""
    location = input("Enter location or area (example: Mylapore): ").strip()
    if not location:
        print("Please enter a location.\n")
        return

    query = """SELECT place_id, name, category, location, description,
                      entry_fee, opening_time, closing_time, best_time_to_visit
               FROM places WHERE location LIKE %s ORDER BY name"""
    cursor = connection.cursor()
    cursor.execute(query, (f"%{location}%",))
    print_places(cursor.fetchall())
    cursor.close()


def search_by_budget(connection):
    """Show places whose entry fee is within the user's maximum budget."""
    try:
        maximum_budget = float(input("Enter maximum entry fee in rupees: "))
        if maximum_budget < 0:
            print("Budget cannot be negative.\n")
            return
    except ValueError:
        print("Please enter a valid number.\n")
        return

    query = """SELECT place_id, name, category, location, description,
                      entry_fee, opening_time, closing_time, best_time_to_visit
               FROM places WHERE entry_fee <= %s ORDER BY entry_fee, name"""
    cursor = connection.cursor()
    cursor.execute(query, (maximum_budget,))
    print_places(cursor.fetchall())
    cursor.close()


def search_food(connection):
    """Search food recommendations by food name, type, or location."""
    keyword = input("Enter food, type, or location (press Enter for all): ").strip()
    cursor = connection.cursor()

    if keyword:
        query = """SELECT food_id, name, `type`, location, description, average_price
                   FROM food
                   WHERE name LIKE %s OR `type` LIKE %s OR location LIKE %s
                   ORDER BY name"""
        search_value = f"%{keyword}%"
        cursor.execute(query, (search_value, search_value, search_value))
    else:
        cursor.execute("SELECT food_id, name, `type`, location, description, average_price FROM food ORDER BY name")

    rows = cursor.fetchall()
    if not rows:
        print("No food recommendations found.\n")
    else:
        for row in rows:
            print(f"\n{row[0]}. {row[1]} - {row[2]}")
            print(f"Location: {row[3]}")
            print(f"Description: {row[4]}")
            print(f"Average price: Rs. {row[5]}")
        print()
    cursor.close()


def close_connection(connection):
    """Close MySQL safely before the program ends."""
    if connection and connection.is_connected():
        connection.close()
        print("Database connection closed. Goodbye!")


def main():
    """Run the command-line menu."""
    connection = connect_database()
    if not connection:
        return

    try:
        while True:
            print("===== NAMMA CHENNAI EXPLORER =====")
            print("1. Show all places")
            print("2. Search places by category")
            print("3. Search places by location")
            print("4. Search places by budget")
            print("5. Search food recommendations")
            print("6. Exit")

            choice = input("Enter your choice (1-6): ").strip()
            if choice == "1":
                show_all_places(connection)
            elif choice == "2":
                search_by_category(connection)
            elif choice == "3":
                search_by_location(connection)
            elif choice == "4":
                search_by_budget(connection)
            elif choice == "5":
                search_food(connection)
            elif choice == "6":
                break
            else:
                print("Invalid choice. Please enter a number from 1 to 6.\n")
    except KeyboardInterrupt:
        print("\nProgram stopped by user.")
    finally:
        close_connection(connection)


if __name__ == "__main__":
    main()
