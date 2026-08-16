import sys

with open('/Users/dimas/Face-Recognition-Based-Attendance-System/backend/main.py', 'r') as f:
    lines = f.readlines()

insert_idx = -1
for i, line in enumerate(lines):
    if '@app.post("/users/{user_id}/photo"' in line:
        insert_idx = i
        break

if insert_idx != -1:
    lines.insert(insert_idx, """
@app.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
        
    attendances = db.query(models.Attendance).filter(models.Attendance.user_id == user_id).all()
    for att in attendances:
        db.delete(att)
        
    db.delete(db_user)
    db.commit()
    return {"message": "User deleted successfully"}

""")
    with open('/Users/dimas/Face-Recognition-Based-Attendance-System/backend/main.py', 'w') as f:
        f.writelines(lines)
    print("Patched main.py successfully")
else:
    print("Could not find insertion point")
