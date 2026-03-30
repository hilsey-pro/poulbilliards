from app import db, Assignment, app
with app.app_context():
    db.create_all()
    if not Assignment.query.first():
        a = Assignment(course="Accounting", title="TIA Audit Project 2026", description="Due Friday!")
        db.session.add(a)
        db.session.commit()
        print("Data added for 30,000 students!")
