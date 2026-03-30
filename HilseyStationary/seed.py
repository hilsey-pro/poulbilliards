from app import app, db, Assignment
with app.app_context():
    db.create_all()
    # Add a fresh assignment for TIA students
    if not Assignment.query.filter_by(course='Accounting').first():
        new_task = Assignment(course='Accounting', title='TIA Final Audit Report 2026')
        db.session.add(new_task)
        db.session.commit()
        print("✅ Success: Assignment added to the TIA Database!")
    else:
        print("🚀 Database already has data.")
