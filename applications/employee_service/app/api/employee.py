from flask import Blueprint, request, jsonify
from marshmallow import ValidationError

from shared.database.connection import SessionLocal

from ..repository.employee_repository import EmployeeRepository
from ..services.employee_service import EmployeeService
from ..schemas.employee_schema import (
    EmployeeRequestSchema,
    EmployeeResponseSchema,
)

employee_bp = Blueprint("employee", __name__)


# =======================================================
# Create Employee
# =======================================================
@employee_bp.route("/employees", methods=["POST"])
def create_employee():

    db = None

    try:
        # -------------------------------------------------
        # Validate that the request contains JSON
        # -------------------------------------------------
        if not request.is_json:
            return (
                jsonify(
                    {
                        "error": "Request must contain JSON",
                        "content_type": request.content_type,
                    }
                ),
                400,
            )

        # -------------------------------------------------
        # Read JSON body
        # -------------------------------------------------
        data = request.get_json(silent=True)

        if data is None:
            return (
                jsonify({"error": "Invalid JSON request body"}),
                400,
            )

        # -------------------------------------------------
        # Validate request schema
        # -------------------------------------------------
        request_schema = EmployeeRequestSchema()

        data = request_schema.load(data)

        # -------------------------------------------------
        # Create database session
        # -------------------------------------------------
        db = SessionLocal()

        # -------------------------------------------------
        # Repository
        # -------------------------------------------------
        repository = EmployeeRepository(db)

        # -------------------------------------------------
        # Service
        # -------------------------------------------------
        service = EmployeeService(repository)

        # -------------------------------------------------
        # Create employee
        # -------------------------------------------------
        employee = service.create_employee(
            first_name=data["first_name"],
            last_name=data["last_name"],
            email=data["email"],
            department=data["department"],
            designation=data["designation"],
            salary=data["salary"],
        )

        # -------------------------------------------------
        # Success response
        # -------------------------------------------------
        return (
            jsonify(
                {
                    "message": "Employee created successfully",
                    "employee_id": employee.employee_id,
                }
            ),
            201,
        )

    # -----------------------------------------------------
    # Marshmallow validation error
    # -----------------------------------------------------
    except ValidationError as err:

        return (
            jsonify(
                {
                    "error": "Validation failed",
                    "errors": err.messages,
                }
            ),
            400,
        )

    # -----------------------------------------------------
    # Business validation error
    # -----------------------------------------------------
    except ValueError as err:

        return (
            jsonify(
                {
                    "error": str(err),
                }
            ),
            400,
        )

    # -----------------------------------------------------
    # Unexpected error
    # -----------------------------------------------------
    except Exception as err:

        if db:
            db.rollback()

        return (
            jsonify(
                {
                    "error": "Internal Server Error",
                    "details": str(err),
                }
            ),
            500,
        )

    # -----------------------------------------------------
    # Close database connection
    # -----------------------------------------------------
    finally:

        if db:
            db.close()


# =======================================================
# Get All Employees
# =======================================================
@employee_bp.route("/employees", methods=["GET"])
def get_employees():

    db = SessionLocal()

    try:

        repository = EmployeeRepository(db)

        service = EmployeeService(repository)

        employees = service.get_all_employees()

        response_schema = EmployeeResponseSchema(many=True)

        return (
            jsonify(response_schema.dump(employees)),
            200,
        )

    except Exception as err:

        return (
            jsonify(
                {
                    "error": "Internal Server Error",
                    "details": str(err),
                }
            ),
            500,
        )

    finally:

        db.close()


# =======================================================
# Get Employee By ID
# =======================================================
@employee_bp.route("/employees/<employee_id>", methods=["GET"])
def get_employee(employee_id):

    db = SessionLocal()

    try:

        repository = EmployeeRepository(db)

        service = EmployeeService(repository)

        employee = service.get_employee(employee_id)

        response_schema = EmployeeResponseSchema()

        return (
            jsonify(response_schema.dump(employee)),
            200,
        )

    except ValueError as err:

        return (
            jsonify(
                {
                    "error": str(err),
                }
            ),
            404,
        )

    except Exception as err:

        return (
            jsonify(
                {
                    "error": "Internal Server Error",
                    "details": str(err),
                }
            ),
            500,
        )

    finally:

        db.close()


# =======================================================
# Update Employee
# =======================================================
@employee_bp.route("/employees/<employee_id>", methods=["PUT"])
def update_employee(employee_id):

    db = None

    try:

        # -------------------------------------------------
        # Validate JSON
        # -------------------------------------------------
        if not request.is_json:

            return (
                jsonify(
                    {
                        "error": "Request must contain JSON",
                        "content_type": request.content_type,
                    }
                ),
                400,
            )

        data = request.get_json(silent=True)

        if data is None:

            return (
                jsonify(
                    {
                        "error": "Invalid JSON request body",
                    }
                ),
                400,
            )

        # -------------------------------------------------
        # Check required update fields
        # -------------------------------------------------
        required_fields = [
            "department",
            "designation",
            "salary",
        ]

        missing_fields = [field for field in required_fields if field not in data]

        if missing_fields:

            return (
                jsonify(
                    {
                        "error": "Missing required fields",
                        "fields": missing_fields,
                    }
                ),
                400,
            )

        # -------------------------------------------------
        # Database session
        # -------------------------------------------------
        db = SessionLocal()

        repository = EmployeeRepository(db)

        service = EmployeeService(repository)

        employee = service.update_employee(
            employee_id=employee_id,
            department=data["department"],
            designation=data["designation"],
            salary=data["salary"],
        )

        return (
            jsonify(
                {
                    "message": "Employee updated successfully",
                    "employee_id": employee.employee_id,
                }
            ),
            200,
        )

    except ValueError as err:

        return (
            jsonify(
                {
                    "error": str(err),
                }
            ),
            404,
        )

    except Exception as err:

        if db:
            db.rollback()

        return (
            jsonify(
                {
                    "error": "Internal Server Error",
                    "details": str(err),
                }
            ),
            500,
        )

    finally:

        if db:
            db.close()


# =======================================================
# Delete Employee
# =======================================================
@employee_bp.route("/employees/<employee_id>", methods=["DELETE"])
def delete_employee(employee_id):

    db = SessionLocal()

    try:

        repository = EmployeeRepository(db)

        service = EmployeeService(repository)

        service.delete_employee(employee_id)

        return (
            jsonify(
                {
                    "message": "Employee deleted successfully",
                }
            ),
            200,
        )

    except ValueError as err:

        return (
            jsonify(
                {
                    "error": str(err),
                }
            ),
            404,
        )

    except Exception as err:

        if db:
            db.rollback()

        return (
            jsonify(
                {
                    "error": "Internal Server Error",
                    "details": str(err),
                }
            ),
            500,
        )

    finally:

        if db:
            db.close()
