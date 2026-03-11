from __future__ import annotations

import csv
import random
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
import re
from faker import Faker


BASE_DIR = Path(__file__).resolve().parent
PRODUCTS_CSV = BASE_DIR / "Pharmacy_Products.csv"
CUSTOMERS_CSV = BASE_DIR / "customer.csv"
EMPLOYEES_CSV = BASE_DIR / "employee.csv"
ORDERS_CSV = BASE_DIR / "order.csv"
SALES_CSV = BASE_DIR / "sales.csv"
PRESCRIPTIONS_CSV = BASE_DIR / "prescription.csv"
PRESCRIPTION_ITEMS_CSV = BASE_DIR / "prescription_items.csv"

ORDER_STATUSES = ["Pending", "Paid", "Packed", "Shipped", "Delivered", "Cancelled"]
PAYMENT_METHODS = ["Cash", "Card", "Insurance", "Wallet"]
EMPLOYEE_ROLES = [
    "Pharmacist",
    "Senior Pharmacist",
    "Pharmacy Technician",
    "Cashier",
    "Store Manager",
]


@dataclass(frozen=True)
class Product:
    product_id: int
    name: str
    packaging: str
    price: float
    discounted_price: float
    discount_percentage: str

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

def load_products(products_csv: Path) -> list[Product]:
    products: list[Product] = []

    with products_csv.open("r", newline="", encoding="utf-8-sig") as file:
        reader = csv.DictReader(file)
        for index, row in enumerate(reader, start=1):
            products.append(
                Product(
                    product_id=index,
                    name=row["name"].strip(),
                    packaging=row["packaging"].strip(),
                    price=float(row["price"]),
                    discounted_price=float(row["discounted_price"]),
                    discount_percentage=row["discount_percentage"].strip(),
                )
            )

    return products


def generate_customers(fake: Faker, count: int) -> list[dict[str, str]]:
    customers: list[dict[str, str]] = []

    for customer_id in range(1, count + 1):
        birthdate = fake.date_of_birth(minimum_age=18, maximum_age=85)
        first_name = fake.first_name()
        last_name = fake.last_name()
        customers.append(
            {
                "customer_id": str(customer_id),
                "first_name": first_name,
                "last_name": last_name,
                # "email": fake.unique.email(),
                "email" : generate_email(first_name, last_name),
                "phone": fake.phone_number(),
                "street": fake.street_address(),
                "city": fake.city(),
                "state": fake.state_abbr(),
                "zip": fake.postcode(),
                "birthdate": birthdate.isoformat(),
            }
        )

    return customers


def generate_employees(fake: Faker, count: int) -> list[dict[str, str]]:
    employees: list[dict[str, str]] = []

    for employee_id in range(1, count + 1):
        hire_date = fake.date_between(start_date="-10y", end_date="today")
        first_name = fake.first_name()
        last_name = fake.last_name()
        employees.append(
            {
                "employee_id": str(employee_id),
                "first_name": first_name,
                "last_name": last_name,
                "email": generate_email(first_name, last_name),
                "phone": fake.phone_number(),
                "role": random.choice(EMPLOYEE_ROLES),
                "hire_date": hire_date.isoformat(),
            }
        )

    return employees


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def build_orders_and_sales(
    fake: Faker,
    customers: list[dict[str, str]],
    employees: list[dict[str, str]],
    products: list[Product],
    min_orders_per_customer: int,
    max_orders_per_customer: int,
) -> tuple[
    list[dict[str, object]],
    list[dict[str, object]],
    list[dict[str, object]],
    list[dict[str, object]],
]:
    orders: list[dict[str, object]] = []
    sales: list[dict[str, object]] = []
    prescriptions: list[dict[str, object]] = []
    prescription_items: list[dict[str, object]] = []
    next_order_id = 1
    next_sale_id = 1
    next_prescription_item_id = 1
    next_prescription_id = 1

    for customer in customers:
        order_count = random.randint(min_orders_per_customer, max_orders_per_customer)

        for _ in range(order_count):
            order_id = next_order_id
            next_order_id += 1
            employee = random.choice(employees)

            product_count = random.randint(1, 4)
            selected_products = random.sample(products, k=product_count)
            order_date = fake.date_time_between(start_date="-18M", end_date="now")
            status = random.choice(ORDER_STATUSES)
            prescription_id = next_prescription_id
            next_prescription_id += 1

            issue_date = fake.date_between(start_date="-2y", end_date=order_date.date())
            valid_until = fake.date_between(start_date=issue_date, end_date="+1y")
            doctor_name = fake.name()
            notes = random.choice(
                [
                    "Take after meals",
                    "Take before bedtime",
                    "Use as directed by physician",
                    "Complete full course",
                    "No refill without consultation",
                ]
            )

            prescriptions.append(
                {
                    "prescription_id": prescription_id,
                    "customer_id": customer["customer_id"],
                    "doctor_name": doctor_name,
                    "issue_date": issue_date.isoformat(),
                    "valid_until": valid_until.isoformat(),
                    "notes": notes,
                }
            )

            subtotal = 0.0
            for product in selected_products:
                prescribed_quantity = random.randint(1, 3)
                prescription_items.append(
                    {
                        "prescription_item_id": next_prescription_item_id,
                        "prescription_id": prescription_id,
                        "product_id": product.product_id,
                        "product_name": product.name,
                        "packaging": product.packaging,
                        "prescribed_quantity": prescribed_quantity,
                    }
                )
                next_prescription_item_id += 1

                quantity = prescribed_quantity
                unit_price = product.discounted_price
                line_total = round(quantity * unit_price, 2)
                subtotal += line_total

                sales.append(
                    {
                        "sale_id": next_sale_id,
                        "order_id": order_id,
                        "customer_id": customer["customer_id"],
                        "product_id": product.product_id,
                        "product_name": product.name,
                        "packaging": product.packaging,
                        "quantity": quantity,
                        "unit_price": f"{unit_price:.2f}",
                        "line_total": f"{line_total:.2f}",
                        "discount_percentage": product.discount_percentage,
                        "sale_date": order_date.date().isoformat(),
                    }
                )
                next_sale_id += 1

            subtotal = round(subtotal, 2)
            tax_amount = round(subtotal * 0.07, 2)
            shipping_fee = 0.0 if subtotal >= 250 else round(random.uniform(5, 20), 2)
            total_amount = round(subtotal + tax_amount + shipping_fee, 2)

            orders.append(
                {
                    "order_id": order_id,
                    "customer_id": customer["customer_id"],
                    "employee_id": employee["employee_id"],
                    "employee_name": f"{employee['first_name']} {employee['last_name']}",
                    "prescription_id": prescription_id,
                    "order_date": order_date.isoformat(sep=" ", timespec="seconds"),
                    "status": status,
                    "payment_method": random.choice(PAYMENT_METHODS),
                    "items_count": len(selected_products),
                    "subtotal": f"{subtotal:.2f}",
                    "tax_amount": f"{tax_amount:.2f}",
                    "shipping_fee": f"{shipping_fee:.2f}",
                    "total_amount": f"{total_amount:.2f}",
                }
            )

    return orders, sales, prescriptions, prescription_items


def main(customer_count: int = 2500, employee_count: int = 35, seed: int = 4321) -> None:
    random.seed(seed)
    fake = Faker("en_US")
    fake.seed_instance(seed)

    products = load_products(PRODUCTS_CSV)
    customers = generate_customers(fake, customer_count)
    employees = generate_employees(fake, employee_count)
    orders, sales, prescriptions, prescription_items = build_orders_and_sales(
        fake=fake,
        customers=customers,
        employees=employees,
        products=products,
        min_orders_per_customer=5,
        max_orders_per_customer=50,
    )

    write_csv(
        CUSTOMERS_CSV,
        [
            "customer_id",
            "first_name",
            "last_name",
            "email",
            "phone",
            "street",
            "city",
            "state",
            "zip",
            "birthdate",
        ],
        customers,
    )
    write_csv(
        EMPLOYEES_CSV,
        [
            "employee_id",
            "first_name",
            "last_name",
            "email",
            "phone",
            "role",
            "hire_date",
        ],
        employees,
    )
    write_csv(
        ORDERS_CSV,
        [
            "order_id",
            "customer_id",
            "employee_id",
            "employee_name",
            "prescription_id",
            "order_date",
            "status",
            "payment_method",
            "items_count",
            "subtotal",
            "tax_amount",
            "shipping_fee",
            "total_amount",
        ],
        orders,
    )
    write_csv(
        SALES_CSV,
        [
            "sale_id",
            "order_id",
            "customer_id",
            "product_id",
            "product_name",
            "packaging",
            "quantity",
            "unit_price",
            "line_total",
            "discount_percentage",
            "sale_date",
        ],
        sales,
    )
    write_csv(
        PRESCRIPTIONS_CSV,
        [
            "prescription_id",
            "customer_id",
            "doctor_name",
            "issue_date",
            "valid_until",
            "notes",
        ],
        prescriptions,
    )
    write_csv(
        PRESCRIPTION_ITEMS_CSV,
        [
            "prescription_item_id",
            "prescription_id",
            "product_id",
            "product_name",
            "packaging",
            "prescribed_quantity",
        ],
        prescription_items,
    )

    print(
        f"Generated {len(customers)} customers, {len(employees)} employees, "
        f"{len(prescriptions)} prescriptions, {len(orders)} orders, "
        f"{len(sales)} sales rows, and {len(prescription_items)} prescription items "
        f"at {datetime.now().isoformat(timespec='seconds')}."
    )


if __name__ == "__main__":
    main()
