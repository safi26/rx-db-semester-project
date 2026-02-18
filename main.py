# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
from __future__ import annotations

import csv
from concurrent.futures import ThreadPoolExecutor
from datetime import date
from faker import Faker
import re
import random
import uuid
import csv



def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print(f'Hi, {name}')  # Press Ctrl+F8 to toggle the breakpoint.

def slugify(text: str) -> str:
    """Make name safe for email."""
    text = text.lower()
    text = re.sub(r"[^a-z0-9]", "", text)
    return text

def generate_email(first_name: str, last_name: str) -> str:
    domains = ["gmail.com", "yahoo.com", "outlook.com", "example.com"]

    first = slugify(first_name)
    last = slugify(last_name)

    patterns = [
        f"{first}.{last}",
        f"{first}_{last}",
        f"{first}{last}",
        f"{first[0]}{last}",
        f"{first}{last[0]}",
        f"{first}.{last}{random.randint(1,99)}",
    ]
    username = random.choice(patterns)
    domain = random.choice(domains)

    return f"{username}@{domain}"

def generate_person(_: int) -> dict:
    """
    Worker function for ThreadPoolExecutor.
    NOTE: Faker isn't guaranteed to be thread-safe if you share one instance,
    so we create a Faker() per call (cheap enough for most use cases).
    """
    fake = Faker("en_US")

    bday: date = fake.date_of_birth(minimum_age=18, maximum_age=80)
    first_name = fake.first_name()
    last_name = fake.last_name()
    return {
        "first_name": first_name,
        "last_name": last_name,
        # "name": fake.name(),
        # "email": fake.email(),
        "email" : generate_email(first_name, last_name),
        "phone": fake.phone_number(),
        "street": fake.street_address(),
        "city": fake.city(),
        "state": fake.state_abbr(),
        "zip": fake.postcode(),
        "birthdate": bday.isoformat(),
        "job": fake.job(),
        "company": fake.company(),
    }


def main(
    out_csv: str = "people.csv",
    num_people: int = 10_000,
    max_workers: int | None = None,
) -> None:
    fieldnames = [
        "first_name",
        "last_name",
        # "name",
        "email",
        "phone",
        "street",
        "city",
        "state",
        "zip",
        "birthdate",
        "job",
        "company",
    ]

    with ThreadPoolExecutor(max_workers=max_workers) as pool:
        # executor.map preserves input order; we just need an iterable of indexes
        rows_iter = pool.map(generate_person, range(num_people), chunksize=200)

        with open(out_csv, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
            writer.writeheader()
            writer.writerows(rows_iter)

    print(f"Wrote {num_people} rows to {out_csv}")


PRODUCTS = [
    "Laptop",
    "Keyboard",
    "Mouse",
    "Monitor",
    "USB Cable",
    "Headphones",
    "Webcam",
]

ORDER_STATUSES = ["pending", "paid", "shipped", "delivered", "cancelled"]


def generate_order(person: dict) -> dict:
    quantity = random.randint(1, 5)
    price = round(random.uniform(10, 500), 2)

    fake = Faker("en_US")
    return {
        "order_id": str(uuid.uuid4()),
        "person_id": person["id"],
        "customer_name": f"{person['first_name']} {person['last_name']}",
        "email": person["email"],
        "product": random.choice(PRODUCTS),
        "quantity": quantity,
        "unit_price": price,
        "total_amount": round(quantity * price, 2),
        "status": random.choice(ORDER_STATUSES),
        "order_date": fake.date_time_between(start_date="-1y", end_date="now").isoformat(),
        "shipping_city": fake.city(),
        "shipping_state": fake.state_abbr(),
    }


def generate_orders_for_people(persons, min_orders=1, max_orders=3):
    orders = []

    for person in persons:
        for _ in range(random.randint(min_orders, max_orders)):
            orders.append(generate_order(person))

    return orders

if __name__ == "__main__":
    # main(out_csv="people.csv", num_people=30_000, max_workers=64)

    persons = ['Dave', 'Person 2']
    orders = generate_orders_for_people(persons)

    for o in orders[:3]:
        print(o)
# Press the green button in the gutter to run the script.
# if __name__ == '__main__':
#     print_hi('PyCharm')

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
